// https://makerworld.com/en/models/1104112-center-finder-customizable


/* [Dimensions] */
Diameter=25;
Lenght=100;
Height=4;   
/* [Roller Dimensions] */
Roller_Height=20;
Roller_Radius=7;
Roller_Chamfer=1;
/* [Center Hole Radius] */
// Pencil inlet radius
Inlet_Radius=1.5;
// Pencil outlet radius (between rollers)
Outlet_Radius=0.9;
/* [Hidden] */
$fs=.5;
/* [Hidden] */
$fa=5;


difference()  {
    linear_extrude(Height){
        hull(){
            translate([(Diameter-Lenght)/2,0])circle(d=Diameter);
            translate([(Lenght-Diameter)/2,0]) circle(d=Diameter);
        }
    }
    cylinder (h = Height+0.1, r2=Outlet_Radius, r1=Inlet_Radius);
}

translate([(Diameter-Lenght)/2,0,0])
    cylinder (h = Roller_Height-Roller_Chamfer, r=Roller_Radius);
translate([(Diameter-Lenght)/2,0, Roller_Height-Roller_Chamfer])
    cylinder(h = Roller_Chamfer, r1 = Roller_Radius, r2 = Roller_Radius - Roller_Chamfer);
translate([(Lenght-Diameter)/2,0,0])
    cylinder (h = Roller_Height-Roller_Chamfer, r=Roller_Radius);
translate([(Lenght-Diameter)/2,0, Roller_Height-Roller_Chamfer])
    cylinder(h = Roller_Chamfer, r1 = Roller_Radius, r2 = Roller_Radius - Roller_Chamfer);