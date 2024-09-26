// from https://github.com/pastcompute/openscad-rpipico-rfm69-container

module pico() { translate([ 0, 0, 0.5 ]) rotate(a = [ 90, 0, 90 ]) import("Unnamed-Raspberry\ Pi\ Pico-R004.amf", convexity = 3); }

module pico_screws(h=4) {
  zoff = -h/2;
  d = 2.1;
  spacing_short = 11.4;
  spacing_long = 47;
  $fn = 30;
  
  translate([spacing_long/2, spacing_short/2, zoff]) cylinder(h=h, d=d, center=true);
  translate([spacing_long/2, -spacing_short/2, zoff]) cylinder(h=h, d=d, center=true);
  translate([-spacing_long/2, spacing_short/2, zoff]) cylinder(h=h, d=d, center=true);
  translate([-spacing_long/2, -spacing_short/2, zoff]) cylinder(h=h, d=d, center=true);
}

module pico_test() { color("green", .8) pico(); pico_screws(); }

//pico_test();

//projection(cut=false) pico_screws();