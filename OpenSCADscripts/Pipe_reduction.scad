/*
    OpenSCAD Script Name: Pipe reduction
    Author: Frantisek Nagy - hello@nagy.sh
    Date: 2025-03-07
    License: CC BY-NC-SA 4.0

    Copyright (c) 2025 Frantisek Nagy
*/

Diameter1 = 40;
Length1 = 30;
Bead1 = false;
Bead1_position = 5;
Bead1_size =  0.5; // [0.1:0.1:1]
Diameter2 = 30;
Length2 = 25;
Bead2 = false;
Bead2_position = 5;
Bead2_size =  0.5; // [0.1:0.1:1]
Transition_length = 10; // [1:1:50]
Wall_thickness = 2.2; // [0.5:0.1:10]
/* [Hidden] */
$fn=150;
fix = 0.001;


module adapter(Diameter1, Diameter2, Wall_thickness, Length1, lenght2) {
    difference(){
        union(){
        translate([0,0,0])cylinder(d = Diameter1, h = Length1);
        translate([0,0,Length1])cylinder(d1 = Diameter1, d2 = Diameter2, h = Transition_length);
        translate([0,0,Length1+Transition_length])cylinder(d = Diameter2, h = Length2);
    Bead1_position = Bead1_position < 0 ? Bead1_size : Bead1_position;
    if (Bead1==true) {translate([0, 0, Bead1_position])rotate_extrude(convexity = 10)translate([Diameter1/2, 0, 0])circle(r = Bead1_size, $fn = 100);}
    Bead2_position = Bead2_position < 0 ? Bead2_size : Bead2_position;
    if (Bead2==true) {translate([0, 0, Length1+Transition_length+Length2-Bead2_position])rotate_extrude(convexity = 10)translate([Diameter2/2, 0, 0])circle(r = Bead2_size, $fn = 100);}
        }
        union(){
        translate([0,0,-fix])cylinder(d = Diameter1-2*Wall_thickness, h = Length1+fix);
        translate([0,0,Length1-fix])cylinder(d1 = Diameter1-2*Wall_thickness, d2 = Diameter2-2*Wall_thickness, h = Transition_length+2*fix);
        translate([0,0,Length1+Transition_length])cylinder(d = Diameter2-2*Wall_thickness, h = Length2+fix);
        }
    }
}


adapter(Diameter1, Diameter2, Wall_thickness, Length1, Length2);
