/* [Knob] */
Diameter=40;
Full_height=15;
Head_height=7;
Head_width=15;
Head_fillet=2;
/* [Marker line] */
Line_width=1.5;
Line_height=10;
Line_depth=0.8;
/* [Shaft] */
// Shaft Diameter ⌀
Shaft_Diameter = 5.0;
// Diameter (across cut) >D<
D_Shaft_Diameter = 4.0;
Shaft_depth=10;
Shaft_rotation=0; //[0:90:270]
/* [Bottom] */

Bottom_type="Full"; // [Full, Inner, Outer]
Inner_diameter=15;
Wall_width=3;
Wall=Diameter-Wall_width;
Outher_Length = 10;
Outer_diameter = 13;
/* [Hidden] */
$fs=.3;
/* [Hidden] */
$fa=3;
Fillet_radius=Head_fillet+0.001;

module Knob(){
    difference(){
    cylinder(h=Full_height, d=Diameter);

        translate([-Diameter/2,Fillet_radius+Head_width/2,Diameter+Fillet_radius+Full_height-Head_height])
       rotate([0,90,0])minkowski()
            {
              cube([Diameter,Diameter,1]);
              cylinder(r=Fillet_radius,h=Diameter);
            }

        translate([-Diameter/2,-Fillet_radius-Head_width/2-Diameter,Diameter+Fillet_radius+Full_height-Head_height])
       rotate([0,90,0])minkowski()
            {
              cube([Diameter,Diameter,1]);
              cylinder(r=Fillet_radius,h=Diameter);
            }
            translate([Diameter/2,0,Full_height])
    cube([Line_height*2,Line_width,Line_depth*2], center=true);
    if (Bottom_type=="Inner") Hollow();
    }
}
module Hollow(){
    translate([0, 0, -0.001])difference() {
    if (Wall_width<=1) 
        cylinder(h = Full_height-Head_height-1, d = Diameter-1);
    else
        cylinder(h = Full_height-Head_height-Wall_width, d = Wall);
        
    translate([0, 0, 0])
        if (Inner_diameter<=Shaft_Diameter) 
            cylinder(h = Full_height, d = Shaft_Diameter+1);
        else
            cylinder(h = Full_height, d = Inner_diameter);
    }
}

module Shaft(){
        translate([0, 0, -0.001])rotate([0,0,270])difference(){
        cylinder(h=Shaft_depth, d=Shaft_Diameter);
        translate([0,D_Shaft_Diameter,(Shaft_depth/2)])
        cube([Shaft_Diameter,Shaft_Diameter,Shaft_depth], center=true);
    }
}
if (Bottom_type=="Outer"){
  difference(){
  union(){
    Knob();
    translate([0,0,0-Outher_Length])cylinder(h = Outher_Length, d = Outer_diameter);
    }
  rotate([0,0,Shaft_rotation])translate([0,0,0-Outher_Length])Shaft();
  }
}

if (Bottom_type!="Outer"){
    difference(){
        Knob();
        rotate([0,0,Shaft_rotation])
        Shaft();
    }
}

