//----------------------------
// cover3x3 game
// pieces fit inside gameboard
// v1.0.0


use <slide_top_box.scad>

//--- parameters
wall_thickness = 3;
piece_thickness = 2;
piece_spacing = 2;
sm_piece_diameter = 16;
air_gap = 1; // stacking clearance

// computed variables
sm = [sm_piece_diameter, sm_piece_diameter]; // small piece w, h
md = [sm.x+piece_thickness*2+air_gap, sm.y+piece_thickness+air_gap]; // medium
lg = [md.x+piece_thickness*2+air_gap, md.y+piece_thickness+air_gap]; // large

board_dim = 3 * (lg.x+air_gap*2 + (piece_spacing*2));
box_size = slide_top_box_size(
  size=[lg.y+2+(wall_thickness*2), board_dim, board_dim],
  thickness=wall_thickness,
  is_interior_size=true
);
lid_size = slide_top_lid_size(box_size, wall_thickness);


//--- modules

module torus(big_r=5, little_r=1.5, fs=0.5) {
  rotate_extrude($fs=fs)
  translate([big_r-little_r, 0, 0])
  circle(r=little_r, $fs=fs);
}

module round_inner(big_r=5, little_r=1.5, fs=0.5) {
  translate([0, 0, -little_r])
  difference() {
    cylinder(h=big_r, r=big_r, $fs=fs);
    torus(big_r+little_r, little_r, fs);
  }
}

module piece(w, h, thickness=1, marked=true, solid=false, fs=0.5) {
  r = w/2;
  h1 = h-thickness;
  r1 = r-thickness;
  t = thickness/2;

  difference() {
    hull() {
      translate([0,0,t]) torus(big_r=r, little_r=t);
      translate([0, 0, h/2+t/2]) cylinder($fs=fs, h=h-t, r=r, center=true);
    }
    if (marked) {
      translate([0,0,-t/2]) torus(r*.7, t);
    }
    if (!solid) {
      translate([0, 0, h1/2+thickness+t]) cylinder($fs=fs, h=h, r=r1, center=true);
    }
  }
}

module piece_set(sm, md, lg, thickness=4, marked=true) {
  gap = md.x - sm.x;
  translate([               0,    0, 0]) piece(sm.x, sm.y, thickness, marked, solid=true);
  translate([           -md.x,    0, 0]) piece(md.x, md.y, thickness, marked);
  translate([    -(md.x+lg.x),    0, 0]) piece(lg.x, lg.y, thickness, marked);
  translate([               0, lg.x, 0]) piece(lg.x, lg.y, thickness, marked);
  translate([         -(lg.x), lg.x, 0]) piece(md.x, md.y, thickness, marked);
  translate([-(lg.x+md.x), lg.x, 0]) piece(sm.x, sm.y, thickness, marked, solid=true);
}

module hole_grid(size, spacing=2, air_gap=1, fs=0.5) {
  module hole_row(w, h, s) {
    translate([w*0+s*0*2, 0, 0]) cylinder(h=h, r=w/2, $fs=fs);
    translate([w*1+s*1*2, 0, 0]) cylinder(h=h, r=w/2, $fs=fs);
    translate([w*2+s*2*2, 0, 0]) cylinder(h=h, r=w/2, $fs=fs);
  }
  w = size.x + air_gap*2;
  translate([w+spacing, w/2+spacing, 0]) {
    translate([0, w*0+spacing*0*2, 0]) hole_row(w, size.y, spacing);
    translate([0, w*1+spacing*1*2, 0]) hole_row(w, size.y, spacing);
    translate([0, w*2+spacing*2*2, 0]) hole_row(w, size.y, spacing);
  }
}

module rounder_grid(size, spacing=2, air_gap=1, f=3) {
  module rounder_row(w, r, s, f) {
    translate([w*0+s*0*2, 0, 0]) round_inner(r, f);
    translate([w*1+s*1*2, 0, 0]) round_inner(r, f);
    translate([w*2+s*2*2, 0, 0]) round_inner(r, f);
  }
  w = size.x + air_gap*2;
  r = w/2;
  translate([w+spacing, r+spacing, 0]) {
    translate([0, w*0+spacing*0*2, 0]) rounder_row(w, r+f, spacing, f);
    translate([0, w*1+spacing*1*2, 0]) rounder_row(w, r+f, spacing, f);
    translate([0, w*2+spacing*2*2, 0]) rounder_row(w, r+f, spacing, f);
  }
}

module box_and_gameboard() {
  union() {
    // box base
    slide_top_box(
      size=box_size,
      thickness=wall_thickness,
      lid_groove=wall_thickness/3
    );
    // piece plate
    translate([box_size.x, 0, 0])
    difference() {
      cube([wall_thickness, box_size.y, box_size.z]);
      translate([0, piece_spacing+air_gap, box_size.z-piece_spacing+lg.x/2]) rotate([0, 90, 0]) hole_grid(lg, piece_spacing, air_gap);
      translate([wall_thickness, piece_spacing+air_gap, box_size.z-piece_spacing+lg.x/2]) rotate([0, 90, 0]) rounder_grid(lg, piece_spacing, air_gap, wall_thickness/3);
    }
  }

  // lid, in front of box
  translate([box_size.x+wall_thickness, 0, 0]) {
    slide_top_lid(
      size=lid_size,
      thickness=wall_thickness,
      ridge=wall_thickness/3
    );
  }
}


//--- assembly

// gameboard
color("white") box_and_gameboard();

// pieces, behind box
translate([-lg.x/2-piece_thickness, lg.y/2+piece_thickness, 0]) {
  color("red")       translate([0,      0, 0]) piece_set(sm, md, lg, piece_thickness, marked=true);
  color("royalblue") translate([0, lg.x*2, 0]) piece_set(sm, md, lg, piece_thickness, marked=false);
}
