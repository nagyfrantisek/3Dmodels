// https://makerworld.com/en/models/1104436-customizable-knobs

/* [Knob Parameters] */
Knob_Radius = 20;
Knob_Chamfer = 2; // [0,1,2]
Knob_Height = 14;
Number_of_Grip_Cutouts = 16;
//Usually knob radius + half of the cutout size
Cutout_Radius = 22;
Cutout_Size = 3.5;

/* [Screwhead Parameters] */
Screw_Head_Size = 17;
Screw_Head_Height = 6;
Screw_Head_Offset = 0.2;
Screw_Diameter = 10;
Screw_Diameter_Offset = 0.2;
Screw_Diameter_withoffset = Screw_Diameter_Offset+Screw_Diameter;

radius = (Screw_Head_Offset+Screw_Head_Size) / sqrt(3);

/* [Hidden] */
$fs=.5;
/* [Hidden] */
$fa=5;

module hex_head() {
    linear_extrude(Screw_Head_Height+0.01) {
        polygon(points=[
            [radius, 0],
            [radius/2, radius * sqrt(3)/2],
            [-radius/2, radius * sqrt(3)/2],
            [-radius, 0],
            [-radius/2, -radius * sqrt(3)/2],
            [radius/2, -radius * sqrt(3)/2]
        ]);
    }
}

module knob() {
    translate([0, 0, Knob_Chamfer]) cylinder(h = Knob_Height-2*Knob_Chamfer, r = Knob_Radius);
    translate([0, 0, Knob_Height-Knob_Chamfer])
    cylinder(h = Knob_Chamfer, r1 = Knob_Radius, r2 = Knob_Radius-Knob_Chamfer);
    translate([0, 0, 0])
    cylinder(h = Knob_Chamfer, r1 = Knob_Radius-Knob_Chamfer, r2 = Knob_Radius);
}

difference()  {

    knob();

    translate([0, 0, Knob_Height-Screw_Head_Height])hex_head();

    translate([0, 0, -0.01])cylinder(h = Knob_Height + 0.02, d = Screw_Diameter_withoffset);

    for (i = [0 : Number_of_Grip_Cutouts - 1]) {
        angle = 360 / Number_of_Grip_Cutouts * i;
        x = Cutout_Radius * cos(angle);
        y = Cutout_Radius * sin(angle); 
        translate([x, y, -0.1]) {
            cylinder(h = Knob_Height+4+0.2, r = Cutout_Size);
        }
    }
}
