// https://makerworld.com/en/models/1108410-water-faucet-knob-customizable

Outer_diameter = 60;
Knob_height = 10;
Knob_wall_thickness = 8;
radius = Outer_diameter/4;
Knob_Chamfer = 1.5; //[0.0:2.0]
Number_of_spokes = 5;
Spoke_thickness = 8;
spoke_size = [Outer_diameter/2, Spoke_thickness, Knob_height];
//Usually 50% of the outer diameter ±1mm
Cutout_Radius = 31;
Knob_cutout_size = 3.8;
Number_of_Grip_Cutouts = 16;
Stem_radius=9;
Stem_height=25;
Stafthole_sides = 4; // [4,6] 
Stafthole_size = 8;
Stafthole_size_offset = 0.3;
Stafthole_size_withoffset = Stafthole_size+Stafthole_size_offset;
Stafthole_depht=20;

/* [Hidden] */
$fs=.5;
/* [Hidden] */
$fa=5;

module spokes(Number_of_spokes, radius, spoke_size) {
    for (i = [0:Number_of_spokes-1]) {
        angle = i * 360 / Number_of_spokes;
        x = (radius-Knob_wall_thickness/4) * cos(angle);
        y = (radius-Knob_wall_thickness/4) * sin(angle);
        translate([x, y, spoke_size[2] / 2])
            rotate([0, 0, angle])
                cube(spoke_size, center = true);
    }
}
module knob_circle() {
    difference() {
    union(){
    translate([0, 0, Knob_Chamfer]) cylinder(h = Knob_height-2*Knob_Chamfer, d = Outer_diameter);
    translate([0, 0, Knob_height-Knob_Chamfer])
    cylinder(h = Knob_Chamfer, r1 = radius*2, r2 = radius*2-Knob_Chamfer);
    translate([0, 0, 0])
    cylinder(h = Knob_Chamfer, r1 = Outer_diameter/2-Knob_Chamfer, r2 = Outer_diameter/2);
    }

     translate([0, 0, -0.1])   
        cylinder(h = Knob_height + 1, d = Outer_diameter - 2 * Knob_wall_thickness, center = false);
    }
}

module stafthole_polygon(Stafthole_sides, Stafthole_size_withoffset) {
    if (Stafthole_sides % 2 != 0) {
        echo("Error: Only even-sided polygons are allowed.");
    } else {
        radius = Stafthole_size_withoffset / (2 * cos(180 / Stafthole_sides));
        points = [
            for (i = [0:Stafthole_sides-1])
                [radius * cos(i * 360 / Stafthole_sides), radius * sin(i * 360 / Stafthole_sides)]
        ];
        linear_extrude(Stafthole_depht+0.1) polygon(points);
    }
}
difference() {
    union(){
        spokes(Number_of_spokes, radius, spoke_size);
        knob_circle();
        cylinder(Stem_height, r=Stem_radius);
    }
    for (i = [0 : Number_of_Grip_Cutouts - 1]) {
        angle = 360 / Number_of_Grip_Cutouts * i;
        x = Cutout_Radius * cos(angle);
        y = Cutout_Radius * sin(angle); 
        translate([x, y, -0.1]) {
            cylinder(h = Knob_height+4+0.2, r = Knob_cutout_size);
        }
        }

translate([0,0,Stem_height-Stafthole_depht])stafthole_polygon(Stafthole_sides, Stafthole_size_withoffset);
}