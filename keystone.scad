// Rack width in mm. 10'' = 254, 19'' = 482
rack_width = 254; // [254, 482]

// Height of one rack unit (don't modify)
u_height = 44.5;
front_plate_thickness = 3.5;

// The length of overlap over the rail
rail_overlap = 15.875;

// Screwholes for attaching to rack
rail_holes = "corner"; // ["corner", "center"]
rail_hole_diameter = 6.1;

units = 1;
rack_height = u_height * units;
usable_width = rack_width - rail_overlap * 2;

keystones = 12;
keystone_width = 14.7;
keystone_height = 19.6;
keystone_depth = 1.6;
keystone_padding_x = 1;
keystone_padding_y = 3;
keystone_total_width = keystone_width + keystone_padding_x * 2;
keystone_total_height = keystone_height + keystone_padding_y * 2;

stabilizer_width = 4;

module slanted_cube(x, y, z, scale, center=false) {
    tx = center ? 0 : x/2;
    ty = center ? 0 : y/2;
    translate([tx, ty, z]) {
        rotate([0, 180, 0]) {
            difference() {
                linear_extrude(z, scale=scale) {

                    square([x/scale, y*2], center=true);
                }
                for(a = [y, -y]) {
                    translate([0, a, 0]) {
                        linear_extrude(z) {
                            square([x, y], center=true);
                        }
                    }
                }
            }
        }
    }
}

union() {
    difference() {
        linear_extrude(front_plate_thickness) {
            difference() {
                // Baseplate
                square([rack_width, rack_height]);
                // Screwholes
                for (i = [0 : units - 1]) {
                    y_offset = i * u_height;
                    for (y = rail_holes == "corner" ? [6.375, 38.125] : [22.25]) {
                        for (x = [7.938, rack_width-7.938]) {
                            translate([x, y_offset + y, 0]) {
                                circle(d=rail_hole_diameter, $fn=200);
                            }
                        }
                    }
                }
            }
        }
        // Rail overlap cutouts
        translate([0, 0, front_plate_thickness - 0.5]) {
            cube([rail_overlap, units * u_height, 20]);
        }
        translate([rack_width - rail_overlap, 0, front_plate_thickness - 0.5]) {
            cube([rail_overlap, units * u_height, 20]);
        }

        // Keystone holes
        y_offset = u_height / 2 - keystone_height / 2;
        y_offset_2 = u_height / 2 - keystone_total_height / 2;
        spacing = (usable_width - keystone_total_width * keystones) / keystones;
        cutter_height = 50;
        for (i = [0 : keystones - 1]) {
            x_offset = rail_overlap + spacing / 2 + i * (keystone_total_width + spacing);
            translate([x_offset + keystone_padding_x, y_offset, -cutter_height/2]) {
                cube([keystone_width, keystone_height, cutter_height]);
            }
            translate([x_offset, y_offset_2, keystone_depth]) {
                cube([keystone_total_width, keystone_total_height, cutter_height]);
            }
        }
    }
    mid = (u_height - keystone_total_height) / 4;
    translate([rail_overlap, mid - stabilizer_width/2, front_plate_thickness]) {
        slanted_cube(usable_width, stabilizer_width, 10, 1.1);
    }
    translate([rail_overlap, u_height - mid - stabilizer_width/2, front_plate_thickness]) {
        slanted_cube(usable_width, stabilizer_width, 10, 1.1);
    }
}