module SlideSwitch(just_cutouts=false, screw_d=2.5) {
  plate_w = 19.5;
  plate_h = 5.8;
  plate_d = 0.4;
  depth = 5.2;
  box_h = plate_h;
  box_w = 10.7;
  swh = 3.5;
  sww = 6.5;
  between_holes = 12.7;
  between_hole_centers = between_holes + screw_d;
  lugd = 3;
  lugw = 1.4;
  lugh = 0.4;
  lugholew = 0.9;
  
  module SSBox() {
      translate([0, 0, depth/2]) cube([box_w, box_h, depth], center = true);
  }
  
  module SSPlate() {
    translate([0, 0, depth]) cube([plate_w, plate_h, plate_d], center = true);
  }
  
  module SSCutout() {
    translate([0, 0, depth]) cube([sww, swh, depth], center=true);
    translate([-between_hole_centers/2, 0, depth]) cylinder(depth, d=screw_d, center=true);
    translate([between_hole_centers/2, 0, depth]) cylinder(depth, d=screw_d, center=true);
  }
  
  module SSLugs() {
    module SSLugSingle() {
      translate([0, 0, -lugd/2+lugw/2])
      difference() {
        union() {
          cube([lugw, lugh, lugd-lugw], center=true);
          translate([0, lugh/2, -lugd/2+lugw/2]) rotate([90, 0, 0]) cylinder(h=lugh, d=1.4);
        }
        translate([0, lugh/2+0.01, -lugd/2+lugw/2+0.1]) rotate([90, 0, 0]) scale([1, 1.25]) cylinder(h=lugh*1.1, d=lugholew);
      }
    }
    
    SSLugSingle();
    translate([2.9, 0, 0]) SSLugSingle();
    translate([-2.9, 0, 0]) SSLugSingle();
  }
  
  module SSSwitch() {
    switchw = sww/2.5;
    switchoffset = sww/2-switchw/2;
    switchd = 6;
    translate([switchoffset, 0, depth+switchd/2]) cube([sww/2.5, swh, switchd], center=true);
  }
  
  if (just_cutouts) {
    SSCutout();
  } else {
    union() {
      difference() {
        union() {
          SSBox();
          SSPlate();
          SSLugs();
        }
        SSCutout();
      }
      SSSwitch();
    }
  }
}

module UsbSocket(just_cutouts=false, screw_d=3) {
  capsule_width = 25;
  capsule_height = 5.15;
  capsule_depth = 8.2;
  body_width = 12;
  body_depth = 10;
  body_height = 20;
  
  tail_height = 10;
  tail_diameter = 8;
  
  
  module CapsuleShape(width, depth, height) {
    spread = width/2 - depth/2;
    hull() {
      translate([spread, 0, 0]) cylinder(h=height, d=depth);
      translate([-spread, 0, 0]) cylinder(h=height, d=depth);
    }
  }
  
  module Body(width, depth, height, r=0.5) {
  unoffset = r * 2;
  linear_extrude(height=height)
    offset(r=r)
    square([width - unoffset, depth - unoffset], center=true);
  }
  
  module Tail(height, diameter, z_offset) {
  sub_h = height/11;
  small_d = diameter * 0.9;
  translate([0, 0, z_offset])
//    cylinder(height, d=diameter);
    union() {
      cylinder(2 * sub_h, d=diameter);
      translate([0, 0, 2 * sub_h]) cylinder(sub_h, d=small_d);
      translate([0, 0, 3 * sub_h]) cylinder(sub_h, d=diameter);
      translate([0, 0, 4 * sub_h]) cylinder(sub_h, d=small_d);
      translate([0, 0, 5 * sub_h]) cylinder(sub_h, d=diameter);
      translate([0, 0, 6 * sub_h]) cylinder(sub_h, d=small_d);
      translate([0, 0, 7 * sub_h]) cylinder(sub_h, d=diameter);
      translate([0, 0, 8 * sub_h]) cylinder(sub_h, d=small_d);
      translate([0, 0, 9 * sub_h]) cylinder(2 * sub_h, d=diameter);
    }
  }
  
  module Cutouts() {
    cutout_h = 12;
    module USB() {
      usb_d = 3.2;
      usb_spread = 9/2 - usb_d/2;
      hull() {
        translate([-usb_spread, 0, 0]) cylinder(cutout_h, d=usb_d, center=true);
        translate([usb_spread, 0, 0]) cylinder(cutout_h, d=usb_d, center=true);
      }
    }
    module Screws() {
      screw_spread = 13.4/2+screw_d/2;
      translate([screw_spread, 0, 0])
        cylinder(cutout_h, d=screw_d, center=true);
      translate([-screw_spread, 0, 0])
        cylinder(cutout_h, d=screw_d, center=true);
    }
    
    union() {
      USB();
      Screws();
    }
  }
  
  if (just_cutouts) {
    Cutouts();
  } else {
    difference() {
      union() {
        CapsuleShape(capsule_width, capsule_depth, capsule_height);
        Body(body_width, body_depth, body_height, r=0.5);
        Tail(tail_height, tail_diameter, body_height);
      }
      Cutouts();
    }
  }
}


module TestComponents() {
  translate([0, -10, 0]) SlideSwitch();
  translate([0, 10, 0]) UsbSocket();
}

//TestComponents();