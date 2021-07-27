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

module piece(w, h, thickness=4, solid=false, fs=0.5) {
  r = w/2;
  h1 = h-thickness;
  r1 = (w-(thickness*2))/2;

  difference() {
    translate([ -r, 0, h/2]) cylinder($fs=fs, h=h,  r=r,  center=true);
    if (!solid) {
      translate([-(r1+thickness), 0, h1/2+thickness]) cylinder($fs=fs, h=h1, r=r1, center=true);
    }
  }
}

module piece_set(sm, md, lg, thickness=4) {
  gap = md.x - sm.x;
  translate([                   0,    0, 0]) piece(sm.x, sm.y, thickness, solid=true);
  translate([               -md.x,    0, 0]) piece(md.x, md.y, thickness);
  translate([        -(md.x+lg.x),    0, 0]) piece(lg.x, lg.y, thickness);
  translate([                   0, lg.x, 0]) piece(lg.x, lg.y, thickness);
  translate([         -(lg.x+gap), lg.x, 0]) piece(md.x, md.y, thickness);
  translate([-(lg.x+gap+md.x+gap), lg.x, 0]) piece(sm.x, sm.y, thickness, solid=true);
}

module piece_grid(size, spacing=2, air_gap=1) {
  module piece_row(w, h, s) {
    translate([w*0+s*0*2, 0, 0]) piece(w, h, solid=true);
    translate([w*1+s*1*2, 0, 0]) piece(w, h, solid=true);
    translate([w*2+s*2*2, 0, 0]) piece(w, h, solid=true);
  }
  r = size.x + air_gap*2;
  translate([r+spacing, r/2+spacing, 0]) {
    translate([0, r*0+spacing*0*2, 0]) piece_row(r, size.y, spacing);
    translate([0, r*1+spacing*1*2, 0]) piece_row(r, size.y, spacing);
    translate([0, r*2+spacing*2*2, 0]) piece_row(r, size.y, spacing);
  }
}

//--- construction

// box and gameboard
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
    translate([0, piece_spacing, box_size.z-piece_spacing]) rotate([0, 90, 0]) piece_grid(lg, piece_spacing, air_gap);
  }
}

// lid, in front of box
translate([box_size.x+wall_thickness, 0, 0])
  slide_top_lid(
    size=lid_size,
    thickness=wall_thickness,
    ridge=wall_thickness/3
  );

// pieces, behind box
translate([-piece_thickness, lg.y/2+piece_thickness, 0]) {
  translate([0,      0, 0]) piece_set(sm, md, lg, piece_thickness);
  translate([0, lg.x*2, 0]) piece_set(sm, md, lg, piece_thickness);
}
