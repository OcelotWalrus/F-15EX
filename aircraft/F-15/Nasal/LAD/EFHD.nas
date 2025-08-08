# F-15EX Canvas EFHD (Engines-Fuel-Hydraulics Display)
# ---------------------------
# The EFHD is a tiny vertical rectangular screen placed on the bottom right
# part of the front cockpit interiors, replacing the engine and hydraulic
# gauges present in the older F-15s, such as the C and E variant. It gives
# basic status of the engines and information such as temperatures,
# oils pressures, fuel flow, RPM's, nozzle opening percentage, as well as the volume of fuel left
# and the total amount of fuel possible of total and different
# fuel compartments. It also show the BINGO fuel amount, and you can set it
# using a knob right below the EFHD screen.
# ---------------------------
# Some Notes :
# - Current proportions in the model are 5.867677165" (height) and 2.6861023622" (width),
# but are yet to be defined. This makes this screen's ratio approximately .457 (width/height)
# - Corner positions of the fuel tanks: (their white outline)
#  Center tank: UP R: 605, 1610; UP L: 335, 1610; DOWN R: 605, 1940; DOWN L: 335, 1940. 
#  Right tank: UP R: 880, 1790; UP L: 645, 1610; DOWN R: 885, 1940; DOWN L: 645, 1940. 
#  Left tank: UP R: 300, 1610; UP L: 65, 1800; DOWN R: 300, 1940; DOWN L: 60, 1940. 
# ---------------------------
# Planned Features :
# - Fully developed
# ---------------------------
# Author: Jimmy L. Miles
# ---------------------------

## Constant Variables
var touch_command = 0;
var fuel_display = 0;  # 0 total fuel, 1 center tank, 2 right tank, 3 left tank
var fuel_display_changed_time = 0;
var center_tank_quad = [[605, 1610], [335, 1610], [335, 1940], [605, 1940]];
var right_tank_quad = [[880, 1790], [645, 1610], [645, 1940], [885, 1940]];
var left_tank_quad = [[300, 1610], [65, 1800], [60, 1940], [300, 1940]];
var cursor_pos = [0, 0];
var gal_to_pound_ratio = .158730;  # Divide gals of fuel by this and you'll get pounds

# Measures
var screen_width = 937.5;  # defined by EFHD.svg
var screen_height = 2048;  # defined by EFHD.svg

# Preset Colors. These values are the same across all of the EX's displays, so make sure to update the others if you update that one
var prst_black = {"r": 0, "g": 0, "b": 0};
var prst_white = {"r": .98, "g": .98, "b": .98};
var prst_green = {"r": 0, "g": 255 / 255, "b": 58 / 255};
var prst_yellow = {"r": 234 / 255, "g": 255 / 255, "b": 0 / 255};
var prst_yellow_dark = {"r": 94 / 255, "g": 105 / 255, "b": 0 / 255};  # 2.5 times darker than regular yellow
var prst_purple = {"r": .7, "g": 0, "b": 1};
var prst_purple_dark = {"r": .28, "g": 0, "b": 0.4};  # 2.5 times darker than regular purple
var prst_rose = {"r": 1, "g": .21, "b": .635};
var prst_rose_dark = {"r": .4, "g": .084, "b": .254};  # 2.5 times darker than regular rose
var prst_cyan = {"r": 0, "g": 1, "b": .917};
var prst_cyan_dark = {"r": 0, "g": .4, "b": .382};  # 2.5 times darker than regular cyan
var prst_blue = {"r": .04, "g": .12, "b": .921};
var prst_blue_dark = {"r": .0016, "g": .048, "b": .3684};  # 2.5 times darker than regular blue
var prst_marron = {"r": .85, "g": .035, "b": .066};
var prst_marron_dark = {"r": .34, "g": .01912, "b": .14736};  # 2.5 times darker than regular marron
var prst_orange = {"r": 1, "g": .482, "b": 0};
var prst_orange_dark = {"r": .4, "g": .1928, "b": 0};  # 2.5 times darker than regular orange (basically brown)
var prst_red = {"r": .941, "g": .019, "b": .019};
var prst_red_dark = {"r": .3764, "g": .0076, "b": .0076};  # 2.5 times darker than regular orange (basically brown)

var EFHD_Device = {

    canvas_settings: {
        "name": "F15-EFHD",
        "size": [screen_width, screen_height],
        "view": [screen_width, screen_height],
        "mipmapping": 1
    },

    new: func(placement) {
        var m = {parents: [EFHD_Device]};
        m.svg = canvas.new(EFHD_Device.canvas_settings);
        m.svg.addPlacement(placement);

        m.svg.setColorBackground(prst_black.r,prst_black.g,prst_black.b, 1);  # dark-dark gray
        
        
        # Parse the EGD.svg file
        m.EFHDsvg = m.svg.createGroup();
        m.pres = canvas.parsesvg(m.EFHDsvg, "Nasal/LAD/EFHD.svg", {'font-mapper': aircraft.hud_font_mapper});
        m.EFHDsvg.setScale(3.8,3.8);
        m.EFHDsvg.setTranslation(0.0, 0.0);
        
        # We fix some of the parsed shit :
        m.EFHDsvg.getElementById("eng_l_status_title").setTranslation(-5,15);
        m.EFHDsvg.getElementById("eng_r_status_title").setTranslation(-7,15);
        m.EFHDsvg.getElementById("eng_l_status").setTranslation(-5,15);
        m.EFHDsvg.getElementById("eng_r_status").setTranslation(-7,15);
        m.EFHDsvg.getElementById("left_nozzle_title").setTranslation(0,15);
        m.EFHDsvg.getElementById("right_nozzle_title").setTranslation(0,15);
        m.EFHDsvg.getElementById("left_oil_press_status_title").setTranslation(-2,12);
        m.EFHDsvg.getElementById("right_oil_press_status_title").setTranslation(-2,14);
        
        m.left_engine_temp_value = m.EFHDsvg.getElementById("left_engine_temp_value");
        m.right_engine_temp_value = m.EFHDsvg.getElementById("right_engine_temp_value");
        m.left_eng_temp_carat = m.EFHDsvg.getElementById("left_eng_temp_carat");
        m.right_eng_temp_carat = m.EFHDsvg.getElementById("right_eng_temp_carat");
        
        m.center_tank_full = m.EFHDsvg.getElementById("center_tank_full");
        m.right_tank_full = m.EFHDsvg.getElementById("right_tank_full");
        m.left_tank_full = m.EFHDsvg.getElementById("left_tank_full");
        
        m.left_rpm_needle = m.EFHDsvg.getElementById("left_engine_rpm_needle");
        m.right_rpm_needle = m.EFHDsvg.getElementById("right_engine_rpm_needle");
        
        m.EFHDsvg.getElementById("left_engine_temp_title").setTranslation(0,35);
        m.EFHDsvg.getElementById("right_engine_temp_title").setTranslation(0,35);
        m.eng_l_status = m.EFHDsvg.getElementById("eng_l_status");
        m.eng_r_status = m.EFHDsvg.getElementById("eng_r_status");
        m.eng_l_status.setTranslation(3,-12);
        m.eng_r_status.setTranslation(3,-12);
        
        m.bingo_fuel = m.EFHDsvg.getElementById("bingo_fuel_amount");

        return m;
    },
};

var EFHDCanvas = nil;
var update_loop_ehd = nil;

# Utilities
var point_in_tri = func(px, py, a, b, c) {
    # This function is used to determine if a point is inside
    # a triangle. This is also used by point_in_quad() to determine 
    # if a point is inside any 4-cornered polygon.
    # ----------
    # px - should be the x coordinate of the point
    # py - should be the y coordinate of the point
    # a - should be a vector containing the x and y coordinate of the first triangle's corner in that order
    # b - should be a vector containing the x and y coordinate of the second triangle's corner in that order
    # c - should be a vector containing the x and y coordinate of the third triangle's corner in that order

    var sign = func(p1, p2, p3) {
        return (p1[0] - p3[0]) * (p2[1] - p3[1]) - (p2[0] - p3[0]) * (p1[1] - p3[1]);
    };

    p = [px, py];
    d1 = sign(p, a, b);
    d2 = sign(p, b, c);
    d3 = sign(p, c, a);

    has_neg = (d1 < 0) or (d2 < 0) or (d3 < 0);
    has_pos = (d1 > 0) or (d2 > 0) or (d3 > 0);

    return !(has_neg and has_pos);
};

var point_in_quad = func(point, quad) {
    # This function is used for the touchable function: it tells us if a point
    # (where the pilot touched) is inside a polygon defined by 4 corners.
    # How it works is that we split the quad into two triangles
    # and then used point_in_tri() to determine if the point is in either both
    # triangles. That works for any 4-cornered polygon.
    # ------------
    # point - should be a vector containing the x and y coordinates of the point in that order.
    # quad - should be a vector containing vectors of each of the 4 points of the quad in a following order.
    # You can find an example of the quad variable in the constant variables with center_tank_quad.
    
    a = quad[0];  # up r corner
    b = quad[1];  # up l corner
    c = quad[2];  # down l corner
    d = quad[3];  # down r corner
    
    return (point_in_tri(point[0], point[1], d, c, b) or point_in_tri(point[0], point[1], d, a, b));
}

update = func() {
    
    # We make sure we don't run none of that if the EFHD screen's offline
    if (getprop("sim/model/f15/controls/electrics/emerg-gen-switch") or getprop("fdm/jsbsim/systems/electrics/ac-left-main-bus") > 0) {
        # Update variables
        touch_command = getprop("sim/model/f15/controls/EFHD/screen-touch-cmd");
        
        # Engines gens texts update
        engine_l_out = getprop("sim/model/f15/lights/ca-l-gen-out");
        engine_r_out = getprop("sim/model/f15/lights/ca-r-gen-out");
        status_l = "ON";
        status_r = "ON";
        if (engine_l_out) {
            status_l = "OFF";
        }
        if (engine_r_out    ) {
            status_r = "OFF";
        }
        EFHDCanvas.eng_l_status.setText(status_l);
        EFHDCanvas.eng_r_status.setText(status_r);

        # Nozzle opening percentage texts update
        EFHDCanvas.EFHDsvg.getElementById("left_noz_percent").setText(sprintf("%02d", getprop("sim/multiplay/generic/float[10]") * 100));
        EFHDCanvas.EFHDsvg.getElementById("right_noz_percent").setText(sprintf("%02d", getprop("sim/multiplay/generic/float[11]") * 100));
        
        # Oil PSI & Fuel Flow updates
        EFHDCanvas.EFHDsvg.getElementById("left_oil_press_status").setText(sprintf("%03d", getprop("engines/engine[0]/oil-pressure-psi")));
        EFHDCanvas.EFHDsvg.getElementById("right_oil_press_status").setText(sprintf("%03d", getprop("engines/engine[1]/oil-pressure-psi")));
        EFHDCanvas.EFHDsvg.getElementById("fuel_flow_left").setText(sprintf("%05d", getprop("engines/engine[0]/fuel-flow_pph")));
        EFHDCanvas.EFHDsvg.getElementById("fuel_flow_right").setText(sprintf("%05d", getprop("engines/engine[1]/fuel-flow_pph")));
        
        # Update the engines' temperature carats
        eng_l_temp = getprop("engines/engine[0]/egt-degC");
        eng_r_temp = getprop("engines/engine[1]/egt-degC");
        if (eng_l_temp == nil) {  # at sim startup, these values are null
            eng_l_temp = 0;
        }
        if (eng_r_temp == nil) {
            eng_r_temp = 0;
        }
        
        EFHDCanvas.left_engine_temp_value.setText(sprintf("%04d", eng_l_temp * 1.8 + 32));
        EFHDCanvas.right_engine_temp_value.setText(sprintf("%04d", eng_r_temp * 1.8 + 32));
        
        EFHDCanvas.left_engine_temp_value.setTranslation(0, eng_l_temp * 22 / 300);
        EFHDCanvas.right_engine_temp_value.setTranslation(0, eng_r_temp * 22 / 300);
        EFHDCanvas.left_eng_temp_carat.setTranslation(0, eng_l_temp * 22 / 300);
        EFHDCanvas.right_eng_temp_carat.setTranslation(0, eng_r_temp * 22 / 300);
        
        # Update fuel levels
        current_fuel_lbs = getprop("sim/model/f15/instrumentation/fuel-gauges/total-display");
        volume_percent = getprop("consumables/fuel/total-fuel-norm");
        if (current_fuel_lbs == nil) {  # at sim startup, the values are null so that fixes errors printing, even though it doesn't prevent the thing to run properly after that
            current_fuel_lbs = 12000;
        }
        if (volume_percent == nil) {
            volume_percent = 100;
        }
        total_fuel_gal = getprop("consumables/fuel/tank[0]/capacity-gal_us") + getprop("consumables/fuel/tank[1]/capacity-gal_us") + getprop("consumables/fuel/tank[2]/capacity-gal_us") + getprop("consumables/fuel/tank[3]/capacity-gal_us") + getprop("consumables/fuel/tank[4]/capacity-gal_us") + getprop("consumables/fuel/tank[5]/capacity-gal_us") + getprop("consumables/fuel/tank[6]/capacity-gal_us") + getprop("consumables/fuel/tank[7]/capacity-gal_us") + getprop("consumables/fuel/tank[8]/capacity-gal_us") + getprop("consumables/fuel/tank[9]/capacity-gal_us");
        total_fuel_lbs = total_fuel_gal / gal_to_pound_ratio;
        
        # Note:
        # Outer Tanks includes External Droptanks and Conformals
        # Center tank internal tanks and external center tank
        left_capacity = getprop("consumables/fuel/tank[5]/capacity-gal_us") + getprop("consumables/fuel/tank[8]/capacity-gal_us");  # disabled tanks return 0
        left_level = getprop("consumables/fuel/tank[5]/level-gal_us") + getprop("consumables/fuel/tank[8]/level-gal_us");
        left_total_pounds = left_capacity / gal_to_pound_ratio;
        left_pounds = left_level / gal_to_pound_ratio;
        
        right_capacity = getprop("consumables/fuel/tank[6]/capacity-gal_us") + getprop("consumables/fuel/tank[9]/capacity-gal_us");
        right_level = getprop("consumables/fuel/tank[6]/level-gal_us") + getprop("consumables/fuel/tank[9]/level-gal_us");
        right_total_pounds = right_capacity / gal_to_pound_ratio;
        right_pounds = right_level / gal_to_pound_ratio;
        
        internal_capacity = getprop("consumables/fuel/tank[0]/capacity-gal_us") + getprop("consumables/fuel/tank[1]/capacity-gal_us") + getprop("consumables/fuel/tank[2]/capacity-gal_us") + getprop("consumables/fuel/tank[3]/capacity-gal_us") + getprop("consumables/fuel/tank[4]/capacity-gal_us") + getprop("consumables/fuel/tank[7]/capacity-gal_us");
        internal_level = getprop("consumables/fuel/tank[0]/level-gal_us") + getprop("consumables/fuel/tank[1]/level-gal_us") + getprop("consumables/fuel/tank[2]/level-gal_us") + getprop("consumables/fuel/tank[3]/level-gal_us") + getprop("consumables/fuel/tank[4]/level-gal_us") + getprop("consumables/fuel/tank[7]/level-gal_us");
        internal_total_pounds = internal_capacity / gal_to_pound_ratio;
        internal_pounds = internal_level / gal_to_pound_ratio;
        
        if (fuel_display == 0) {  # Total fuel, norm display
            EFHDCanvas.EFHDsvg.getElementById("total_fuel_levels").setText(sprintf("%05d / %05d lbs", current_fuel_lbs, total_fuel_lbs));
        } elsif (fuel_display == 1) {  # center tank fuel, screen touched
            EFHDCanvas.EFHDsvg.getElementById("total_fuel_levels").setText(sprintf("%05d / %05d lbs", internal_pounds, internal_total_pounds));
        } elsif (fuel_display == 2) {  # right tank fuel, screen touched
            EFHDCanvas.EFHDsvg.getElementById("total_fuel_levels").setText(sprintf("%05d / %05d lbs", right_pounds, right_total_pounds));
        } elsif (fuel_display == 3) {  # left tank fuel, screen touched
            EFHDCanvas.EFHDsvg.getElementById("total_fuel_levels").setText(sprintf("%05d / %05d lbs", left_pounds, left_total_pounds));
        }
        
        left_percentage = left_level / left_capacity;
        right_percentage = right_level / right_capacity;
        center_percentage = internal_level / internal_capacity;
        
        if (left_percentage == nil) {
            left_percentage = 0;
        }
        if (right_percentage == nil) {
            right_percentage = 0;
        }

        EFHDCanvas.center_tank_full.setTranslation(0,(1 - center_percentage) * 87.349);
        EFHDCanvas.left_tank_full.setTranslation(0,(1 - left_percentage) * 87.349);
        EFHDCanvas.right_tank_full.setTranslation(0,(1 - right_percentage) * 87.349);
        
        # Update engines RPM
        eng_l_rpm = getprop("engines/engine[0]/n2");
        eng_r_rpm = getprop("engines/engine[1]/n2");
        if (eng_l_rpm == nil) {  # is null at sim startup
            eng_l_rpm = 0;
        }
        if (eng_r_rpm == nil) {  # is null at sim startup
            eng_r_rpm = 0;
        }
        
        # 110 rpm = 90*
        # 70 rpm = 90*70/110
        EFHDCanvas.EFHDsvg.getElementById("left_engine_rpm_actual_number").setText(sprintf("%03d", eng_l_rpm));
        EFHDCanvas.EFHDsvg.getElementById("right_engine_rpm_actual_number").setText(sprintf("%03d", eng_r_rpm));
        
        EFHDCanvas.left_rpm_needle.setRotation((-95 * (eng_l_rpm / 110))*D2R);
        EFHDCanvas.right_rpm_needle.setRotation((95 * (eng_r_rpm / 110))*D2R);
        
        # Update bingo fuel level
        EFHDCanvas.bingo_fuel.setText(sprintf("BINGO %05d lbs", getprop("sim/model/f15/controls/fuel/bingo")));
        if (getprop("sim/model/f15/lights/ca-bingo-fuel")) {  # If we've reached bingo fuel, display the indicator in yellow!
            EFHDCanvas.bingo_fuel.setColor(prst_yellow.r, prst_yellow.g, prst_yellow.b);
        } else {
            EFHDCanvas.bingo_fuel.setColor(prst_white.r, prst_white.g, prst_white.b);
        }
        
        # Handle touch command
        if (touch_command == 1) {
            var cursor_pos = [getprop("sim/model/f15/controls/EFHD/screen-touch-x"), getprop("sim/model/f15/controls/EFHD/screen-touch-y")];
            
            # If we touched the center tank, we momentarily replace the total fuel
            # amount display by the center fuel amount display
            # same for right and left tanks' touchin'
            
            if (point_in_quad(cursor_pos, center_tank_quad)) {
                fuel_display = 1;
                fuel_display_changed_time = getprop("sim/time/elapsed-sec");
            } elsif (point_in_quad(cursor_pos, left_tank_quad)) {
                fuel_display = 3;
                fuel_display_changed_time = getprop("sim/time/elapsed-sec");
            } elsif (point_in_quad(cursor_pos, right_tank_quad)) {
                fuel_display = 2;
                fuel_display_changed_time = getprop("sim/time/elapsed-sec");
            }
        
            touch_command = 0;
            setprop("sim/model/f15/controls/EFHD/screen-touch-cmd", 0);  # reset property
        }
        
        if (fuel_display_changed_time + 7 < getprop("sim/time/elapsed-sec")) {  # If 7 seconds have elapsed since the the fuel display has been changed by touch, we reset it to normal
            fuel_display = 0;
        }
    }
}

EFHDCanvas = EFHD_Device.new({"node": "EFHDImage"});
update_loop_ehd = maketimer(.1, update);
update_loop_ehd.start();
