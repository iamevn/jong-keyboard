include <components.scad>
include <pico.scad>

smidge = 0.01;
$fn = 50;

spread = 50;
row_spacing = 0.5; // 0.5, 0.75, 1.0

x_offset = 0;
y_offset = 0;
WIDTH = 293.027;
HEIGHT_100 = 115.652;
HEIGHT_75 = 111.027;
HEIGHT_50 = 106.402;
HEIGHT = row_spacing == 0.5 ? HEIGHT_50 
       : row_spacing == 0.75 ? HEIGHT_75
       : HEIGHT_100;
       
file_suffix = row_spacing == 0.5 ? "0.5" 
       : row_spacing == 0.75 ? "0.75"
       : "1.0"; 
base_file = str("res/18.5 base - ", file_suffix, ".dxf");
plate_file = str("res/18.5 plate - ", file_suffix, ".dxf");
top_file = str("res/18.5 top - ", file_suffix, ".dxf");


base_thickness = 1.6;
plate_thickness = 1.2;
mid_thickness = 1.6;
top_thickness = 1.6;
open_thickness = 20;
side_thickness = 1.6;

side_panel_width = 60;
centered_side_panel = false;
side_panel_x = centered_side_panel ? WIDTH/2-25 : WIDTH-side_panel_width-22.5;
side_panel_y = HEIGHT - 5;

alpha = 0.9;

plate_screw_d = 2.5;
rpi_screw_d = 2.1;
usb_screw_d = 3.0;
switch_screw_d = 2.5;


base_offset = 0;
plate_offset = open_thickness + base_offset + base_thickness + smidge;
mid_offset = plate_offset + plate_thickness + smidge;
top_offset = mid_offset + mid_thickness + smidge;

screw_inset = 2.75;

module AllTogether() {
  color("darkred", alpha) Base();
  translate([0, 0, 1*spread]) color("red", alpha) Plate();
  translate([0, 0, 2*spread]) color("teal", alpha) Mid();
  translate([0, 0, 3*spread]) color("blue", alpha) Top();

  translate([0, 0, 0.5*spread]) SidePanel(side_panel_width, side_panel_x, side_panel_y, show_components=true);
  
  // sort of an approximation of the standoffs
  translate([0, 0, 0.5*spread]) ScrewHoles(screw_inset);
  
  translate([0, 0, 0.75*spread]) PositionedPi();
}

AllTogether();

//projection(cut=false) Plate();

//projection(cut = false)
//translate([0, -40, 0])
//  rotate([-90, 0, 0])
//  SidePanel(side_panel_width, 0, 0, show_components=false);
  

module Layer(file, z_offset, thickness) {
    translate([x_offset, y_offset, z_offset])
    linear_extrude(height=thickness)
    import(file);
}

module Base() {
  difference() {
    Layer(base_file, base_offset, base_thickness);
    ScrewHoles(screw_inset);
    SidePanel(side_panel_width, side_panel_x, side_panel_y);
  }
}

module PositionedPi(screw_h=4, just_screws=false) {
  translate([WIDTH/2, HEIGHT/4, plate_offset-screw_h])
  rotate([0, 180, 0]) {
    pico_screws(d=rpi_screw_d);
    if (!just_screws) color("green", alpha) pico();
  }
}

module Plate() {
  difference() {
    Layer(plate_file, plate_offset, plate_thickness);
    ScrewHoles(screw_inset);
    SidePanel(side_panel_width, side_panel_x, side_panel_y);
    translate([0, 0, 3]) PositionedPi(just_screws=true);
  }
}

module Top() {
  difference() {
    Layer(top_file, top_offset, top_thickness);
    ScrewHoles(screw_inset);
//    SidePanel(side_panel_width, side_panel_x, side_panel_y);
  }
}

module Mid() {
  difference() {
    Layer(top_file, mid_offset, mid_thickness);
    ScrewHoles(screw_inset);
    SidePanel(side_panel_width, side_panel_x, side_panel_y);
linear_extrude(height=100) offset(r=3) projection() hull() translate([0, 0, 5]) PositionedPi(just_screws=true);
  }
}

module SidePanel(width, x, y, show_components=false) {
  height = open_thickness;
  thickness = side_thickness;
  bottom_teeth = base_thickness + (2 * smidge);
  top_teeth = plate_thickness + top_thickness + (6 * smidge);
  
  module SPPositionedSwitch(just_cutouts=false) {
    translate([width/4, -5.5, height/2])
      rotate([-90, 0, 0])
      SlideSwitch(just_cutouts=just_cutouts, screw_d=switch_screw_d);
  }
  
  module SPPositionedUSB(just_cutouts=false) {
    translate([3*width/4, 0, height/2])
      rotate([90, 0, 0])
      UsbSocket(just_cutouts=just_cutouts, screw_d=usb_screw_d);
  }
  
  translate([x, y, base_thickness + smidge])
    union() {
      difference() {
        cube([width, thickness, height], center=false);
        SPPositionedSwitch(just_cutouts=true);
        SPPositionedUSB(just_cutouts=true);
      }
      translate([0, 0, -bottom_teeth]) cube([width/3, thickness, bottom_teeth], center=false);
      translate([width*2/3, 0, -bottom_teeth]) cube([width/3, thickness, bottom_teeth], center=false);
      translate([0, 0, height-smidge]) cube([width/3, thickness, top_teeth], center=false);
      translate([width*2/3, 0, height-smidge]) cube([width/3, thickness, top_teeth], center=false);
      if (show_components) {
        color("grey") SPPositionedSwitch();
        color("silver") SPPositionedUSB();
      }
    };
}

module ScrewHoles(inset) {
  height = base_thickness + open_thickness + plate_thickness + mid_thickness + top_thickness + (12*smidge);
  z_offset = -5 * smidge;
  d=plate_screw_d;
  r=d/2;
  union() {
    translate([inset+r, inset+r, z_offset])
      cylinder(h=height, d=d);
    translate([inset+r, HEIGHT-inset-r, z_offset])
      cylinder(h=height, d=d);
      
    translate([WIDTH/2, inset+r, z_offset])
      cylinder(h=height, d=d);
    translate([WIDTH/2, HEIGHT-inset-r, z_offset])
      cylinder(h=height, d=d);
      
//    translate([WIDTH/3, HEIGHT-inset-r, z_offset])
//      cylinder(h=height, d=d);
//    translate([WIDTH/3*2, HEIGHT-inset-r, z_offset])
//      cylinder(h=height, d=d);
      
    translate([WIDTH-inset-r, inset+r, z_offset])
      cylinder(h=height, d=d);
    translate([WIDTH-inset-r, HEIGHT-inset-r, z_offset])
      cylinder(h=height, d=d);
  }
}

module KeySwitch() {
  
}