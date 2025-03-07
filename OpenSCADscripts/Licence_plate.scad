// Parameters
Text = "AA-123AA";
Plate_width = 72;
Plate_height = 13;
Plate_thickness = 2;
Font_size = 10;
Blue_width=7;
Border=2;
Border_width=Border-2;
Hole_diameter = 4;
Hole_position = 1.5; // [-10:0.1:10]
/* [Hidden] */
Plate_radius = 2;
$fn = 120;
diff=0.01;

module licence_plate() {
    translate([-Plate_width / 2-Plate_radius, -Plate_height / 2-Plate_radius, 0])
        color([1, 1, 1])minkowski() {
            cube([Plate_width, Plate_height, Plate_thickness-1]);
            translate([Plate_radius, Plate_radius, 0])
                cylinder(r = Plate_radius, h = 1, $fn = 100);
        }
}
module border() {
    translate([-Plate_width / 2-Plate_radius, -Plate_height / 2-Plate_radius, diff])
    difference() {
        
        color([0, 0, 0])minkowski() {
            cube([Plate_width, Plate_height, Plate_thickness-1]);
            translate([Plate_radius, Plate_radius, 0])
                cylinder(r = Plate_radius, h = 1, $fn = 100);
        }
        minkowski() {
            cube([Plate_width-Border_width, Plate_height-Border_width, Plate_thickness]);
            translate([Plate_radius+Border_width/2, Plate_radius+Border_width/2, 0])
                cylinder(r = Plate_radius-1, h = 1, $fn = 100);
        }
    }
    translate([-Plate_width/2-Plate_radius/2, -Plate_height/2-Plate_radius/2, 1+diff])color("blue")cube([Blue_width, Plate_height+Plate_radius, Plate_thickness-1], center=false);

}

difference(){
union(){
licence_plate();
border();
color([0, 0, 0])translate([Blue_width/2, 0, diff])linear_extrude(height = Plate_thickness)text(text = Text, size = Font_size, font = "Liberation Sans:style=Regular", halign = "center", valign = "center");
}
 translate([(-Plate_width/2+Plate_radius/2)+Hole_position, 0, 0-diff])cylinder(h=Plate_height*5+diff, d=Hole_diameter);    
}