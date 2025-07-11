# F-15EX Canvas EHD (Engines-Hydraulics Display)
# ---------------------------
# The EHD is a tiny vertical rectangular screen placed on the bottom left
# part of the front cockpit interiors, replacing the engine and hydraulic
# gauges present in the older F-15s, such as the C and E variant. It gives
# basic status of the engines and information such as temperatures,
# hydraulic pressures and fuel flow, as well as the volume of left left
# and the total amount of fuel possible.
# ---------------------------
# Some Notes :
# Current proportions in the model are 5.867677165" (height) and 2.6861023622" (width),
# but are yet to be defined. This makes this screen's ratio approximatively .457 (width/height)
# ---------------------------
# Author: Jimmy L. Miles
# ---------------------------

## Constant Variables

# Measures
var screen_width = 937.5;  # defined by EHD.svg
var screen_height = 2048;  # defined by EHD.svg

# Preset Colors. These values are the same across all of the EX's displays, so make sure to update the others if you update that one
var prst_black = {"r": 0, "g": 0, "b": .07};
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

var EHD_Device = {

    canvas_settings: {
        "name": "F15-EHD",
        "size": [screen_width, screen_height],
        "view": [screen_width, screen_height],
        "mipmapping": 1
    },

    new: func(placement) {
        var m = {parents: [EHD_Device]};
        m.svg = canvas.new(EHD_Device.canvas_settings);
        m.svg.addPlacement(placement);

        m.svg.setColorBackground(prst_black.r,prst_black.g,prst_black.b, 1);  # dark-dark gray
        
        
        # Parse the EGD.svg file
        m.EHDsvg = m.svg.createGroup();
        m.pres = canvas.parsesvg(m.EHDsvg, "Nasal/LAD/EHD.svg", {'font-mapper': aircraft.hud_font_mapper});
        m.EHDsvg.setScale(3.8,3.8);
        m.EHDsvg.setTranslation(0.0, 0.0);
        
        # We fix some of the parsed shit :
        m.EHDsvg.getElementById("eng_l_status_title").setTranslation(-5,15);
        m.EHDsvg.getElementById("eng_r_status_title").setTranslation(-7,15);
        m.EHDsvg.getElementById("eng_l_status").setTranslation(-5,15);
        m.EHDsvg.getElementById("eng_r_status").setTranslation(-7,15);
        m.EHDsvg.getElementById("left_nozzle_title").setTranslation(0,15);
        m.EHDsvg.getElementById("right_nozzle_title").setTranslation(0,15);
        m.EHDsvg.getElementById("left_oil_press_status_title").setTranslation(-2,12);
        m.EHDsvg.getElementById("right_oil_press_status_title").setTranslation(-2,14);
        
        m.left_engine_temp_value = m.EHDsvg.getElementById("left_engine_temp_value");
        m.right_engine_temp_value = m.EHDsvg.getElementById("right_engine_temp_value");
        m.left_eng_temp_carat = m.EHDsvg.getElementById("left_eng_temp_carat");
        m.right_eng_temp_carat = m.EHDsvg.getElementById("right_eng_temp_carat");
        
        m.center_tank_full = m.EHDsvg.getElementById("center_tank_full");
        m.right_tank_full = m.EHDsvg.getElementById("right_tank_full");
        m.left_tank_full = m.EHDsvg.getElementById("left_tank_full");
        
        m.left_rpm_needle = m.EHDsvg.getElementById("left_engine_rpm_needle");
        m.right_rpm_needle = m.EHDsvg.getElementById("right_engine_rpm_needle");
        
        m.EHDsvg.getElementById("left_engine_temp_title").setTranslation(0,35);
        m.EHDsvg.getElementById("right_engine_temp_title").setTranslation(0,35);
        m.eng_l_status = m.EHDsvg.getElementById("eng_l_status");
        m.eng_r_status = m.EHDsvg.getElementById("eng_r_status");
        m.eng_l_status.setTranslation(3,-12);
        m.eng_r_status.setTranslation(3,-12);

        return m;
    },
};

var EHDCanvas = nil;
var update_loop_ehd = nil;

update = func() {
    
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
    EHDCanvas.eng_l_status.setText(status_l);
    EHDCanvas.eng_r_status.setText(status_r);

    # Nozzle opening percentage texts update
    EHDCanvas.EHDsvg.getElementById("left_noz_percent").setText(sprintf("%02d", getprop("sim/multiplay/generic/float[10]") * 100));
    EHDCanvas.EHDsvg.getElementById("right_noz_percent").setText(sprintf("%02d", getprop("sim/multiplay/generic/float[11]") * 100));
    
    # Util Oil Press Hydraulics status update
    util_pressure = getprop("fdm/jsbsim/systems/hydraulics/util-system-accumulator-psi");
    operable = util_pressure > 1200;  # It needs to be higher than 1,200 psi in order for the JFS to work
    saturated = getprop("fdm/jsbsim/systems/hydraulics/util-system-accumulator-psi/saturated");
    
    fail_hardover = getprop("fdm/jsbsim/systems/hydraulics/util-system-accumulator-psi/malfunction/fail_hardover");
    fail_stuck = getprop("fdm/jsbsim/systems/hydraulics/util-system-accumulator-psi/malfunction/fail_stuck");
    fail_zero = getprop("fdm/jsbsim/systems/hydraulics/util-system-accumulator-psi/malfunction/fail_zero");
    
    status = "";
    if (saturated) {
        status = "SATUR";
    } elsif (operable) {
        status = "OPER";
    } elsif (!operable) {
        status = "INOP";
    } elsif (fail_hardover) {
        status = "HARDOV";
    } elsif (fail_stuck) {
        status = "STUCK";
    } elsif (fail_zero) {
        status = "ZERO";
    } else { # that's a safety
        status = "INOP";
    }
    
    EHDCanvas.EHDsvg.getElementById("left_oil_press_status").setText(status);
    EHDCanvas.EHDsvg.getElementById("right_oil_press_status").setText(status);
    
    # Update the engines' temperature carats
    eng_l_temp = getprop("engines/engine[0]/egt-degC");
    eng_r_temp = getprop("engines/engine[1]/egt-degC");
    if (eng_l_temp == nil) {  # at sim startup, these values are null
        eng_l_temp = 0;
    }
    if (eng_r_temp == nil) {
        eng_r_temp = 0;
    }
    
    EHDCanvas.left_engine_temp_value.setText(sprintf("%04d", eng_l_temp * 1.8 + 32));
    EHDCanvas.right_engine_temp_value.setText(sprintf("%04d", eng_r_temp * 1.8 + 32));
    
    EHDCanvas.left_engine_temp_value.setTranslation(0, eng_l_temp * 22 / 300);
    EHDCanvas.right_engine_temp_value.setTranslation(0, eng_r_temp * 22 / 300);
    EHDCanvas.left_eng_temp_carat.setTranslation(0, eng_l_temp * 22 / 300);
    EHDCanvas.right_eng_temp_carat.setTranslation(0, eng_r_temp * 22 / 300);
    
    # Update fuel levels
    current_fuel_lbs = getprop("sim/model/f15/instrumentation/fuel-gauges/total-display");
    volume_percent = getprop("consumables/fuel/total-fuel-norm");
    if (current_fuel_lbs == nil) {  # at sim startup, the values are null so that fixes errors printing, even though it doesn't prevent the thing to run properly after that
        current_fuel_lbs = 12000;
    }
    if (current_fuel_lbs == nil) {
        volume_percent = 100;
    }
    total_fuel_gal = getprop("consumables/fuel/tank[0]/capacity-gal_us") + getprop("consumables/fuel/tank[1]/capacity-gal_us") + getprop("consumables/fuel/tank[2]/capacity-gal_us") + getprop("consumables/fuel/tank[3]/capacity-gal_us") + getprop("consumables/fuel/tank[4]/capacity-gal_us") + getprop("consumables/fuel/tank[5]/capacity-gal_us") + getprop("consumables/fuel/tank[6]/capacity-gal_us") + getprop("consumables/fuel/tank[7]/capacity-gal_us") + getprop("consumables/fuel/tank[8]/capacity-gal_us") + getprop("consumables/fuel/tank[9]/capacity-gal_us");
    total_fuel_lbs = total_fuel_gal / .158730;
    
    EHDCanvas.EHDsvg.getElementById("total_fuel_levels").setText(sprintf("%05d / %05d lbs", current_fuel_lbs, total_fuel_lbs));
    
    # Note:
    # Outer Tanks includes External Droptanks and Conformals
    # Center tank internal tanks and external center tank
    left_capacity = getprop("consumables/fuel/tank[5]/capacity-gal_us") + getprop("consumables/fuel/tank[8]/capacity-gal_us");  # disabled tanks return 0
    left_level = getprop("consumables/fuel/tank[5]/level-gal_us") + getprop("consumables/fuel/tank[8]/level-gal_us");
    
    right_capacity = getprop("consumables/fuel/tank[6]/capacity-gal_us") + getprop("consumables/fuel/tank[9]/capacity-gal_us");
    right_level = getprop("consumables/fuel/tank[6]/level-gal_us") + getprop("consumables/fuel/tank[9]/level-gal_us");
    
    interal_capacity = getprop("consumables/fuel/tank[0]/capacity-gal_us") + getprop("consumables/fuel/tank[1]/capacity-gal_us") + getprop("consumables/fuel/tank[2]/capacity-gal_us") + getprop("consumables/fuel/tank[3]/capacity-gal_us") + getprop("consumables/fuel/tank[4]/capacity-gal_us") + getprop("consumables/fuel/tank[7]/capacity-gal_us");
    internal_level = getprop("consumables/fuel/tank[0]/level-gal_us") + getprop("consumables/fuel/tank[1]/level-gal_us") + getprop("consumables/fuel/tank[2]/level-gal_us") + getprop("consumables/fuel/tank[3]/level-gal_us") + getprop("consumables/fuel/tank[4]/level-gal_us") + getprop("consumables/fuel/tank[7]/level-gal_us");
    
    left_percentage = left_level / left_capacity;
    right_percentage = right_level / right_capacity;
    center_percentage = internal_level / interal_capacity;

    EHDCanvas.center_tank_full.setTranslation(0,(1 - center_percentage) * 87.349);
    EHDCanvas.left_tank_full.setTranslation(0,(1 - left_percentage) * 87.349);
    EHDCanvas.right_tank_full.setTranslation(0,(1 - right_percentage) * 87.349);
    
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
    EHDCanvas.EHDsvg.getElementById("left_engine_rpm_actual_number").setText(sprintf("%03d", eng_l_rpm));
    EHDCanvas.EHDsvg.getElementById("right_engine_rpm_actual_number").setText(sprintf("%03d", eng_r_rpm));
    
    EHDCanvas.left_rpm_needle.setRotation((-95 * (eng_l_rpm / 110))*D2R);
    EHDCanvas.right_rpm_needle.setRotation((95 * (eng_r_rpm / 110))*D2R);
}

EHDCanvas = EHD_Device.new({"node": "EnginesDImage"});
update_loop_ehd = maketimer(.1, update);
update_loop_ehd.start();
