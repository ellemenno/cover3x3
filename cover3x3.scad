//----------------------------
// cover3x3 game
// pieces fit inside gameboard
// v0.0.5


use <slide_top_box.scad>

//--- parameters

wall_thickness = 5;
piece_thickness = 3;
piece_spacing = 3;
sm_piece_diameter = 24;
air_gap = 1; // stacking clearance

// computed variables
sm = sm_piece_diameter;
md = sm+piece_thickness*2+air_gap; // medium
lg = md+piece_thickness*2+air_gap; // large

board_dim = 3 * (lg+air_gap*2 + (piece_spacing*2));
box_size = slide_top_box_size(
  size=[lg+2+(wall_thickness*2), board_dim, board_dim],
  thickness=wall_thickness,
  is_interior_size=true
);

//--- assembly

echo("- - - - - - - -");
echo("cover3x3");
ind = "    ";
echo(str(ind, "v0.0.5"));
echo(str(ind, "board size of ", box_size));
echo(str(ind, sm_piece_diameter, "mm small piece"));
echo(str(ind, wall_thickness, "mm wall thickness"));
echo(str(ind, piece_thickness, "mm piece thickness"));
echo("- - - - - - - -");

// gameboard
color("white") box_and_gameboard(box_size, wall_thickness, [sm, md, lg], piece_spacing, air_gap);

// pieces, behind box
translate([-lg/2-piece_thickness, lg/2+piece_thickness, 0]) {
  color("red")       translate([0,    0, 0]) piece_set(sm, md, lg, piece_thickness, marked=true);
  color("royalblue") translate([0, lg*2, 0]) piece_set(sm, md, lg, piece_thickness, marked=false);
}


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

module round_linear(len, f, fs=0.5) {
  translate([0, -f, -f])
  difference() {
    cube([len,f*2, f*2], center=false);
    rotate([0, 90, 0]) translate([0, 0, -len*0.05]) cylinder(h=len*1.1, r=f, $fs=fs);
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
  gap = md - sm;
  translate([       0,  0, 0]) piece(sm, sm, thickness, marked, solid=true);
  translate([     -md,  0, 0]) piece(md, md, thickness, marked);
  translate([-(md+lg),  0, 0]) piece(lg, lg, thickness, marked);
  translate([       0, lg, 0]) piece(lg, lg, thickness, marked);
  translate([   -(lg), lg, 0]) piece(md, md, thickness, marked);
  translate([-(lg+md), lg, 0]) piece(sm, sm, thickness, marked, solid=true);
}

module hole_grid(diameter, spacing=2, air_gap=1, fs=0.5) {
  module hole_row(w, h, s) {
    translate([w*0+s*0*2, 0, 0]) cylinder(h=h, r=w/2, $fs=fs);
    translate([w*1+s*1*2, 0, 0]) cylinder(h=h, r=w/2, $fs=fs);
    translate([w*2+s*2*2, 0, 0]) cylinder(h=h, r=w/2, $fs=fs);
  }
  w = diameter + air_gap*2;
  r = w/2;
  translate([r+spacing, r+spacing, 0]) {
    translate([0, w*0+spacing*0*2, 0]) hole_row(w, diameter, spacing);
    translate([0, w*1+spacing*1*2, 0]) hole_row(w, diameter, spacing);
    translate([0, w*2+spacing*2*2, 0]) hole_row(w, diameter, spacing);
  }
}

module rounder_grid(diameter, spacing=2, air_gap=1, f=3) {
  module rounder_row(w, r, s, f) {
    translate([w*0+s*0*2, 0, 0]) round_inner(r, f);
    translate([w*1+s*1*2, 0, 0]) round_inner(r, f);
    translate([w*2+s*2*2, 0, 0]) round_inner(r, f);
  }
  w = diameter + air_gap*2;
  r = w/2;
  translate([r+spacing, r+spacing, 0]) {
    translate([0, w*0+spacing*0*2, 0]) rounder_row(w, r+f, spacing, f);
    translate([0, w*1+spacing*1*2, 0]) rounder_row(w, r+f, spacing, f);
    translate([0, w*2+spacing*2*2, 0]) rounder_row(w, r+f, spacing, f);
  }
}

module piece_holder(box_size, r, t, a, f, fs=0.5) {
  // r: piece radius
  // t: wall thickness
  // a: air gap
  x = box_size.x-t*2; // box cavity height / piece height
  yy = (box_size.y - (r+t+a)*4) / 2; // distance from edge of box to holder

  module u_holder() {
    difference() {
      hull() {
        translate([0, (r+t+a), (r+t+a)]) rotate([0, 90, 0]) cylinder(h=x, r=r+t+a, $fs=fs);
        translate([0, 0, (r+t+a)*2]) cube([x, (r+t+a)*2, (r+t+a)*2]);
      }
      translate([-a, t, t])
      hull() {
        translate([0, r+a, r+a]) rotate([0, 90, 0]) cylinder(h=x+a*2, r=r+a, $fs=fs);
        translate([0, 0, (r+t+t)*2]) cube([x+a*2, (r+a)*2, (r+a)*2]);
      }
    }
  }

  difference() {
    union() {
      cube([x, yy, t]);
      translate([0, yy, 0]) {
        translate([0, 0, -(r+t+a)*4+t]) u_holder();
        translate([0, (r+t+a)*2, -(r+t+a)*4+t]) u_holder();
      }
      translate([0, yy+((r+t+a)*4), 0]) cube([x, yy, t]);
    }

    gap = a+r+r+a;
    translate([0, yy+t, t]) rotate([ 0, 0, 0]) round_linear(x, f);
    translate([0, yy+t+gap, t]) rotate([90, 0, 0]) round_linear(x, f);
    translate([0, yy+t+gap+t+t, t]) rotate([ 0, 0, 0]) round_linear(x, f);
    translate([0, yy+t+gap+t+t+gap, t]) rotate([90, 0, 0]) round_linear(x, f);
  }
}

module box_and_gameboard(box_size, wall_thickness, pieces, piece_spacing, air_gap) {
  x = box_size.x + wall_thickness;
  y = box_size.y;
  z = box_size.z;
  f = wall_thickness/3;
  sm = pieces[0];
  md = pieces[1];
  lg = pieces[2];

  difference() {
    union() {
      // box base
      slide_top_box(box_size, wall_thickness, f);
      // piece holder
      translate([wall_thickness, 0, box_size.z-wall_thickness*2]) piece_holder(box_size, lg/2, wall_thickness, air_gap, f);
      // piece plate, minus holes, then rounded inner edges
      translate([box_size.x, 0, 0])
      difference() {
        cube([wall_thickness, box_size.y, box_size.z]);
        translate([0, 0, box_size.z-wall_thickness]) {
          translate([0, wall_thickness, 0]) rotate([0, 90, 0]) hole_grid(lg, piece_spacing, air_gap);
          translate([wall_thickness, wall_thickness, 0]) rotate([0, 90, 0]) rounder_grid(lg, piece_spacing, air_gap, f);
        }
      }
    }

    translate([0, y, 0]) rotate([-90,   0,   0]) round_linear(x, f);
    translate([0, y, z]) rotate([  0,   0,   0]) round_linear(x, f);
    translate([0, 0, z]) rotate([ 90,   0,   0]) round_linear(x, f);
    translate([0, 0, 0]) rotate([180,   0,   0]) round_linear(x, f);

    translate([0, 0, z]) rotate([  0,   0,  90]) round_linear(y, f);
    translate([x, 0, z]) rotate([ 90,   0,  90]) round_linear(y, f);
    translate([x, 0, 0]) rotate([180,   0,  90]) round_linear(y, f);
    translate([0, 0, 0]) rotate([-90,   0,  90]) round_linear(y, f);

    translate([0, y, 0]) rotate([  0, -90,   0]) round_linear(z, f);
    translate([x, y, 0]) rotate([  0, -90, -90]) round_linear(z, f);
    translate([x, 0, 0]) rotate([  0, -90, 180]) round_linear(z, f);
    translate([0, 0, 0]) rotate([  0, -90,  90]) round_linear(z, f);
  }

  // lid, in front of box
  lid_size = slide_top_lid_size(box_size, wall_thickness);
  translate([box_size.x+wall_thickness, 0, 0]) {
    difference() {
      slide_top_lid(
        size=lid_size,
        thickness=wall_thickness,
        ridge=f
      );
      translate([0, lid_size.y, lid_size.z]) rotate([0, 0, 0]) round_linear(lid_size.x, f);
    }
  }
}
