#
# F-15 Main Nasal Module
# ---------------------------
# Declares globals; provides update loop
# ---------------------------
# Richard Harrison (rjh@zaretto.com) 2014-11-23. Based on F-14b by xii
#
var stdFont =  "NotoF15HUD-SemiBold.ttf";#"richud.ttf";#"LiberationFonts/LiberationSans-Bold.ttf";#"notosansmono-black.ttf";
HUDFont =  VSDFont = TEWSFont = MPCDFont = stdFont;

var canvas_font_mapper = func(family, weight) {
#    print("font map ",family," ",weight);
    # return "HornetDisplay-Regular.ttf";
    return "notosansmono-black.ttf";
    return "HornetDisplay-Bold.ttf";
    return "monoMMM_5.ttf";
    return "LiberationFonts/LiberationSans-Bold.ttf";
};
var mpcd_font_mapper = func(family, weight)  {return MPCDFont;}
var vsd_font_mapper  = func(family, weight)  {return VSDFont;}
var hud_font_mapper  = func(family, weight)  {return HUDFont;}
var tews_font_mapper  = func(family, weight) {return TEWSFont;}

var CurrentIASnode = props.globals.getNode("velocities/airspeed-kt");
var acFrost = props.globals.getNode("environment/aircraft-effects/frost-level",1);
var sysFrost = props.globals.getNode("fdm/jsbsim/systems/ecs/windscreen-frost-amount",1);
#
# 2018.3 has improved stores handling - but this is turned
gui.external_stores_2018_1_compat = 0;

LOG_INFO = 3;
LOG_WARN = 4;
LOG_ALERT = 5;

if (props["UpdateManager"] == nil){
    print("Fallback update manager");
    props.UpdateManager = UpdateManager.UpdateManager;
}

var payload_dialog_reload = func(from) {
#    logprint(3, "payload_dialog_reload: ",from);
    setprop("sim/gui/dialogs/payload-reload",!getprop("sim/gui/dialogs/payload-reload",1) or 1);
}

var deltaT = 1.0;

var currentG = 1.0;
var minVersion = props.globals.getNode("/sim/version/flightgear/min-model-version",1);
minVersion.setValue(getprop("/sim/minimum-fg-version"));
# Version checking based on the work of Joshua Davidson
if (num(string.replace(getprop("/sim/version/flightgear"),".","")) < minVersion.getValue()*100) {
var error_mismatch = gui.Dialog.new("sim/gui/dialogs/fg-version/dialog", "Dialogs/error-mismatch.xml");
error_mismatch.open();
}
var fixAirframe = func {
    if (getprop("payload/armament/msg")==1 and !getprop("fdm/jsbsim/gear/unit[0]/WOW")) {
        screen.log.write(pylons.msgA);
    } else {
        setprop("controls/armament/combat-jettison-count",0);
    	setprop ("fdm/jsbsim/gear/damage-reset", 1);
    	setprop ("fdm/jsbsim/systems/flyt/min-g-reached", 0);
    	setprop ("fdm/jsbsim/systems/flyt/max-g-reached", 0);
    	repairMe();
    	settimer (func { setprop ("fdm/jsbsim/gear/damage-reset", 0); }, 1.3);
        setprop("controls/gear/gear-overspeed", 0);
        setprop("controls/flaps-overspeed", 0);
        setprop("controls/gear/brakes-blownout", 0);
        setprop("sim/model/f15/ejected", 0);
    }
}
#
# 2017.3 or earlier FG compatibility fixes
# Remove after 2017.4
string.truncateAt = func(src, match){
    var rv = nil;
    call(func {
    if (src != nil and match !=nil){
        var pos = find(match,src);
        if (pos>=0)
          src=substr(src,0,pos);
    }
},
        nil, var err = []);
    return src;

}
#
#

var hmd = modules.Module.new("f15_HMD"); # Module name
hmd.setDebug(0); # 0=(mostly) silent; 1=print setlistener and maketimer calls to console; 2=print also each listener hit, be very careful with this!
hmd.setFilePath(getprop("/sim/aircraft-dir")~"/Nasal/HUD");
hmd.setMainFile("hmd.nas");
hmd.load();

#----------------------------------------------------------------------------
# Nozzle opening
#----------------------------------------------------------------------------

# Variables
var Nozzle1Target = 0.0;
var Nozzle2Target = 0.0;
var Nozzle1 = 0.0;
var Nozzle2 = 0.0;

#----------------------------------------------------------------------------
# General aircraft values
#----------------------------------------------------------------------------

# Constants
var ThrottleIdle = 0.05;

# Variables
var CurrentMach = 0;
var CurrentAlt = 0;
var CurrentIAS = 0;
var Alpha = 0;
var Throttle = 0;
var e_trim = 0;
var rudder_trim = 0;
var aileron = props.globals.getNode("fdm/jsbsim/fcs/aileron-pos-norm", 1);
var radarStandbyNode = props.globals.getNode("instrumentation/radar/radar-standby",1);
var radarMPnode = props.globals.getNode("instrumentation/radar/radar-mode",1);


# Utilities #########

# Lighting
#setprop("sim/model/path","data/Aircraft/f15/F15.xml");

var anti_collision_switch = props.globals.getNode("sim/model/f15/controls/lighting/anti-collision-switch");
var position_sw = props.globals.getNode("sim/model/f15/controls/lighting/position-switch",1);
var lighting_taxi  = props.globals.getNode("controls/lighting/taxi-light", 1);


getprop("fdm/jsbsim/fcs/flap-pos-norm",0);
var sw_pos_prop = props.globals.getNode("sim/model/f15/controls/lighting/position-wing-switch", 1);
var position_intens = 0;
setprop("fdm/jsbsim/Factor1",1);
setprop("sim/fdm/surface/override-level", 0);

aircraft.tyresmoke_system.new(0, 1, 2);
aircraft.rain.init();
setprop("/environment/aircraft-effects/overlay-alpha",0.45);
setprop("/environment/aircraft-effects/use-overlay",1);
setprop("/environment/aircraft-effects/use-reflection",1);
setprop("/environment/aircraft-effects/reflection-strength",0.25);


#
#
# setprop within range
var  setprop_inrange = func(p,v,mn,mx)
{
    if (mn != nil and v < mn)
        v = mn;
    if (mx != nil and  v > mx)
        v = mx;
    setprop(p,v);
};



#
#
# ARA-63 (Carrier Landing System) support
var tuned_carrier_name=getprop("/sim/presets/carrier");
var carrier_ara_63_position = nil;
var carrier_heading = nil;
var carrier_ara_63_heading = nil;

var wow = 1;
setprop("fdm/jsbsim/fcs/roll-trim-actuator",0) ;
setprop("controls/flight/cas-roll",0);

# Init the targeting pod system
tgp.callInit();
flooptimer = maketimer(0, func tgp.fast_loop());
flooptimer.start();

# Init the CCRP computing system
fc.ccrp_loopTimer.start();

#
#
# set the splash vector for the new canopy rain.

# for tuning the vector; these will be baked in once finished
#setprop("sim/model/f15/sfx1",-0.1);
#setprop("sim/model/f15/sfx2",4);
#setprop("sim/model/f15/sf-x-max",400);
#setprop("sim/model/f15/sfy1",0);
#setprop("sim/model/f15/sfy2",0.1);
#setprop("sim/model/f15/sfz1",1);
#setprop("sim/model/f15/sfz2",-0.1);

#var vl_x = 0;
#var vl_y = 0;
#var vl_z = 0;
#var vsplash_precision = 0.001;
var splash_vec_loop = func
{
    var v_x = getprop("fdm/jsbsim/velocities/u-aero-fps");
    var v_y = getprop("fdm/jsbsim/velocities/v-aero-fps");
    var v_z = getprop("fdm/jsbsim/velocities/w-aero-fps");
#    var v_x = getprop("velocities/uBody-fps");
#    var v_y = getprop("velocities/vBody-fps");
#    var v_z = getprop("velocities/wBody-fps");
#    var v_x_max = getprop("sim/model/f15/sf-x-max");
    var v_x_max =400;

    if (v_x > v_x_max)
        v_x = v_x_max;

    if (v_x > 1)
        v_x = math.sqrt(v_x/v_x_max);
#var splash_x = -0.1 - 2.0 * v_x;
#var splash_y = 0.0;
#var splash_z = 1.0 - 1.35 * v_x;
#    var splash_x = getprop("sim/model/f15/sfx1") - getprop("sim/model/f15/sfx2") * v_x;
#    var splash_y = getprop("sim/model/f15/sfy1") - getprop("sim/model/f15/sfy2") * v_y;
#    var splash_z = getprop("sim/model/f15/sfz1") - getprop("sim/model/f15/sfz2") * v_z;

    var splash_x = -0.1 - 4   * v_x;
    var splash_y =  0   - 0.1 * v_y;
    var splash_z =  1   - 0.1 * v_z;

#if (math.abs(vl_x - v_x) >  vsplash_precision)
    setprop("/environment/aircraft-effects/splash-vector-x", splash_x);
#if (math.abs(vl_y - v_y) >  vsplash_precision)
    setprop("/environment/aircraft-effects/splash-vector-y", splash_y);
#if (math.abs(vl_z - v_z) >  vsplash_precision)
    setprop("/environment/aircraft-effects/splash-vector-z", splash_z);
#vl_x = v_x;
#vl_y = v_y;
#vl_z = v_z;

#    interpolate("/environment/aircraft-effects/splash-vector-z", splash_z, 0.01);

if (wow and getprop("gear/gear[0]/rollspeed-ms") < 30)
    settimer( func {splash_vec_loop() },2.5);
else
    settimer( func {splash_vec_loop() },1.2);

}

splash_vec_loop();

#
# Sound volumes; need to do it here because the sound calculation methods are not capable of this.

var updateVolume = func
{
#var n1_l = getprop("engines/engine[0]/n1");
#var n1_r = getprop("engines/engine[1]/n1");
var n2_l = getprop("engines/engine[0]/n2");
var n2_r = getprop("engines/engine[1]/n2");

    if(getprop("sim/current-view/internal"))
        setprop("fdm/jsbsim/systems/sound/cockpit-adjusted-external-volume",
                0.2
                + getprop("canopy/position-norm")-getprop("/controls/seat/pilot-helmet-volume-attenuation"));
    else
        setprop("fdm/jsbsim/systems/sound/cockpit-adjusted-external-volume",1);


    setprop_inrange("fdm/jsbsim/systems/sound/cockpit-effects-volume",
             0.3
             - getprop("/controls/seat/pilot-helmet-volume-attenuation"),0,1);

#
# cold end of the engines
    setprop_inrange("fdm/jsbsim/systems/sound/engine-jet-intake-l-volume",
             0.0133
             * n2_l
             * getprop("fdm/jsbsim/systems/sound/cockpit-adjusted-external-volume"),nil,1);

    setprop_inrange("fdm/jsbsim/systems/sound/engine-jet-intake-r-volume",
             0.0133
             * n2_r
             * getprop("fdm/jsbsim/systems/sound/cockpit-adjusted-external-volume"),nil,1);

    setprop_inrange("fdm/jsbsim/systems/sound/engine-n2-l-volume",
             0.015
             * n2_l
             * getprop("fdm/jsbsim/systems/sound/cockpit-adjusted-external-volume"),nil,0.4);
    setprop_inrange("fdm/jsbsim/systems/sound/engine-n2-r-volume",
             0.015
             * n2_r
             * getprop("fdm/jsbsim/systems/sound/cockpit-adjusted-external-volume"),nil,0.4);

#
# hot end of the engines.
# using PB (the gasgen based pressure at the burner) for this is more accurate
# however it doesn't produce the right sort of levels for external in-air (and flyby) views
# - the physics for sound volume is (a more complex version) of pressure and velocity - however
#   PB is relative to the engine so at speed the velocity of the aircraft isn't going to be added in
#   to produce realistic levels for an observer. I could take PB and add back in velocity but that would
#   effectively be the same as n2 as PB is based on N2 and mach.

#
#
# this is the fade out as the engines spool down. the noise from the stuff coming out the back
# decreases quite rapidly ; so I'm using ln(n) based on 40% n2.
# previous I did math.ln((getprop("engines/engine[0]/PB"))) but that doesn't work well at higher speeds
# as PB drops with forward velocity (because of the decreased resistance behind the engine).
#             math.ln((getprop("engines/engine[1]/PB")))

#var n2_r_f = 1;
#if (n2_r < 40)
#{
#    var v1 = 1-n2_r/40;
#    if (v1 != 0)
#        n2_r_f = math.ln(v1)/-3.82970;
#    else
#        n2_r_f = 0;
#}

#var n2_l_f = 1;
#if (n2_l < 40)
#{
#    var v1 = 1-n2_l/40;
#    if (v1 != 0)
#        n2_l_f = math.ln(v1)/-3.82970;
#    else
#        n2_l_f = 0;
#}
#=math.ln(math.max(0.01,n2_l*0.01))/4.605*5*(n2_l-30);

    setprop_inrange("fdm/jsbsim/systems/sound/engine-jet-exhaust-l-volume",
             (n2_l-30)/70
             * getprop("fdm/jsbsim/systems/sound/cockpit-adjusted-external-volume"), 0, 1.0);

    setprop_inrange("fdm/jsbsim/systems/sound/engine-jet-exhaust-r-volume",
             (n2_r-30)/70
             * getprop("fdm/jsbsim/systems/sound/cockpit-adjusted-external-volume"), 0, 1.0);

    setprop_inrange("fdm/jsbsim/systems/sound/engine-efflux-l-volume",
             (n2_l-30)/70
             * getprop("fdm/jsbsim/systems/sound/cockpit-adjusted-external-volume"), 0, 1.0);


    setprop_inrange("fdm/jsbsim/systems/sound/engine-efflux-r-volume",
             (n2_r-30)/70
             * getprop("fdm/jsbsim/systems/sound/cockpit-adjusted-external-volume"),0, 1.0);

    setprop_inrange("fdm/jsbsim/systems/sound/engine-jet-augmentation-l-volume",
             0.06
             * getprop("engines/engine[0]/afterburner")
             * getprop("fdm/jsbsim/systems/sound/cockpit-adjusted-external-volume"),nil,0.4);

    setprop_inrange("fdm/jsbsim/systems/sound/engine-jet-augmentation-r-volume",
             0.06
             * getprop("engines/engine[1]/afterburner")
             * getprop("fdm/jsbsim/systems/sound/cockpit-adjusted-external-volume"),nil,0.4);

#efflux was:
# cond  : engines/engine[0]/thrust_lb > 200 and instrumentation/airspeed-indicator/indicated-speed-kt > 100
# volume: 0.4
#
#exhaust was
# volume: -0.3 + 0.01 * engines/engine[0]/n2
}

var two_seater = getprop("fdm/jsbsim/metrics/two-place-canopy");
if (two_seater)
logprint(3, "F-15 two seat variant (B,D,E,EX)");

setlistener("sim/model/f15/controls/AFCS/cas-takeoff-trim", func(v) {
    logprint(3, "Takeoff trim");
    setprop("controls/flight/elevator-trim", -0.43);
});
#----------------------------------------------------------------------------
# View change: Ctrl-V switchback to view #0 but switch to Rio view when already
# in view #0.
#----------------------------------------------------------------------------

var CurrentView_Num = props.globals.getNode("sim/current-view/view-number");
var backseat_view_num = view.indexof("Backseat View");
var awareness_view_num = view.indexof("Awareness Camera");
var awareness_view_num_second = view.indexof("Awareness Camera (Belly)");
var tgp_view_num = view.indexof("TGP");

var toggle_cockpit_views = func() {
	cur_v = CurrentView_Num.getValue();
	if (cur_v != 0 ) {
		CurrentView_Num.setValue(0);
	} else if(two_seater) {
        CurrentView_Num.setValue(backseat_view_num);
    }
}

var toggle_awareness_views = func() {
	cur_v = CurrentView_Num.getValue();
	if ((cur_v != 0 and cur_v != awareness_view_num) or (cur_v == awareness_view_num_second)) {
		CurrentView_Num.setValue(0);
	} else if(cur_v == 0) {
        CurrentView_Num.setValue(awareness_view_num);
    } else if(cur_v == awareness_view_num) {
        CurrentView_Num.setValue(awareness_view_num_second);
    }
}

var LADView = func () {  # lean into the LAD
    if (getprop("sim/current-view/view-number") == 0) {
        var hd = getprop("sim/current-view/heading-offset-deg");
        var hd_t = 360;
        if (hd < 180) {
          hd_t = hd_t - 360;
        }
        interpolate("sim/current-view/field-of-view", 42.59, 0.66);
        interpolate("sim/current-view/heading-offset-deg", hd_t,0.66);
        interpolate("sim/current-view/pitch-offset-deg", -9.18,0.66);
        interpolate("sim/current-view/roll-offset-deg", 0,0.66);
        interpolate("sim/current-view/x-offset-m", 0, 1);
        interpolate("sim/current-view/y-offset-m", 1.26915, 1);
        interpolate("sim/current-view/z-offset-m", -5.09, 1);
    }
}

var quickstart = func() {
#    setprop("controls/electric/engine[0]/generator",1);
#    setprop("controls/electric/engine[1]/generator",1);
#    setprop("controls/electric/engine[0]/bus-tie",1);
#    setprop("controls/electric/engine[1]/bus-tie",1);
#    setprop("systems/electrical/outputs/avionics",1);
#    setprop("controls/electric/inverter-switch",1);
    if(total_lbs < 400)
        set_fuel(5500);

        settimer(func {

#    setprop("controls/lighting/panel-norm",1);
#    setprop("controls/lighting/instruments-norm",1);
    setprop("sim/model/f15/controls/HUD/brightness",1);
    setprop("sim/model/f15/controls/HUD/on-off",1);
    setprop("sim/model/f15/controls/VSD/brightness",1);
    setprop("sim/model/f15/controls/VSD/on-off",1);
    setprop("sim/model/f15/controls/TEWS/brightness",1);
    setprop("sim/model/f15/controls/MPCD/brightness",1);
    setprop("sim/model/f15/controls/MPCD/on-off",1);
    setprop("sim/model/f15/controls/MPCD/mode",2);
    setprop("sim/model/f15/lights/radio2-brightness",0.6);

#    setprop("sim/model/f15/controls/windshield-heat",1);
    setprop("sim/model/f15/controls/electrics/emerg-flt-hyd-switch",0);
    setprop("sim/model/f15/controls/electrics/emerg-gen-guard-lever",0);
	setprop("sim/model/f15/controls/electrics/emerg-gen-switch",1);
    setprop("sim/model/f15/controls/electrics/l-gen-switch",1);
    setprop("sim/model/f15/controls/electrics/master-test-switch",0);
	setprop("sim/model/f15/controls/electrics/r-gen-switch",1);

    setprop("controls/engines/engine[0]/cutoff",0);
    setprop("controls/engines/engine[1]/cutoff",0);
    setprop("engines/engine[0]/out-of-fuel",0);
    setprop("engines/engine[1]/out-of-fuel",0);
    setprop("engines/engine[0]/run",1);
    setprop("engines/engine[1]/run",1);
    setprop("sim/model/f15/controls/CAS/cas-pitch-enable",1);
    setprop("sim/model/f15/controls/CAS/cas-roll-enable",1);
    setprop("sim/model/f15/controls/CAS/cas-yaw-enable",1);

setprop("engines/engine[1]/cutoff",0);
setprop("engines/engine[0]/cutoff",0);

setprop("fdm/jsbsim/propulsion/starter_cmd",1);
setprop("fdm/jsbsim/propulsion/cutoff_cmd",1);
setprop("fdm/jsbsim/propulsion/set-running",1);
setprop("fdm/jsbsim/propulsion/set-running",0);

    setprop("sim/model/f15/controls/engines/l-ramp-switch", 1);
    setprop("sim/model/f15/controls/engines/r-ramp-switch", 1);
    setprop("sim/model/f15/controls/fuel/dump-switch",0);
    setprop("sim/model/f15/controls/fuel/refuel-probe-switch",0);

    setprop("sim/model/f15/controls/engines/l-eec-switch",1);
    setprop("sim/model/f15/controls/engines/r-eec-switch",1);
    setprop("sim/model/f15/controls/electrics/emerg-gen-switch",1);
    setprop("sim/model/f15/controls/engs/l-eng-master-guard",0);
    setprop("sim/model/f15/controls/engs/r-eng-master-guard",0);
 }, 0.2);
}

var cold_and_dark = func()
{
	setprop("sim/model/f15/controls/electrics/emerg-gen-switch",9);
	setprop("sim/model/f15/controls/electrics/r-gen-switch",0);

    setprop("controls/engines/engine[0]/cutoff",1-getprop("controls/engines/engine[0]/cutoff"));
    setprop("controls/engines/engine[1]/cutoff",1-getprop("controls/engines/engine[1]/cutoff"));

    setprop("controls/lighting/aux-inst", 0);
    setprop("controls/lighting/eng-inst", 0);
    setprop("controls/lighting/flt-inst", 0);
    setprop("controls/lighting/instruments-norm",0);
    setprop("controls/lighting/l-console", 0);
    setprop("controls/lighting/panel-norm", 0);
    setprop("controls/lighting/panel-norm",0);
    setprop("controls/lighting/r-console", 0);
    setprop("controls/lighting/stby-inst", 0);
    setprop("controls/lighting/warn-caution", 0);

    setprop("sim/model/f15/controls/CAS/cas-pitch-enable",0);
    setprop("sim/model/f15/controls/CAS/cas-roll-enable",0);
    setprop("sim/model/f15/controls/CAS/cas-yaw-enable",0);

    setprop("sim/model/f15/controls/HUD/brightness",0);
    setprop("sim/model/f15/controls/HUD/on-off",0);
    setprop("sim/model/f15/controls/MPCD/brightness",0);
    setprop("sim/model/f15/controls/MPCD/on-off",0);
    setprop("sim/model/f15/controls/TEWS/brightness",0);
    setprop("sim/model/f15/controls/VSD/on-off",0);
    setprop("sim/model/f15/controls/VSD/brightness",0);

    setprop("sim/model/f15/controls/electrics/emerg-flt-hyd-switch",0);
    setprop("sim/model/f15/controls/electrics/emerg-gen-guard-lever",0);
    setprop("sim/model/f15/controls/electrics/l-gen-switch",0);
    setprop("sim/model/f15/controls/electrics/master-test-switch",0);

    setprop("sim/model/f15/lights/master-test-lights", 0);
    setprop("sim/model/f15/lights/radio2-brightness",0);

    setprop("sim/multiplay/generic/int[1]", 0);
    setprop("sim/multiplay/generic/int[3]", 0);
    setprop("sim/model/f15/controls/lighting/position-switch", 0);
    setprop("sim/multiplay/generic/int[5]", 0);
    setprop("sim/multiplay/generic/int[6]", 0);
    setprop("sim/model/f15/controls/windshield-heat",0);

    setprop("sim/model/f15/controls/engines/l-ramp-switch", 0);
    setprop("sim/model/f15/controls/engines/r-ramp-switch", 0);
    setprop("sim/model/f15/controls/fuel/dump-switch",0);
    setprop("sim/model/f15/controls/fuel/refuel-probe-switch",0);

    setprop("sim/model/f15/controls/engines/l-eec-switch",0);
    setprop("sim/model/f15/controls/engines/r-eec-switch",0);
    setprop("sim/model/f15/controls/electrics/emerg-gen-switch",0);
    setprop("sim/model/f15/controls/engs/l-eng-master-guard",1);
    setprop("sim/model/f15/controls/engs/r-eng-master-guard",1);
    setprop("sim/model/f15/controls/electrics/jfs-starter",0);

    setprop("fdm/jsbsim/systems/electrics/ground-power",0);

}

# Ejection
var eject_f15 = func{
    if (getprop("sim/model/f15/ejected")) {
        return;
    }
    # ACES II activation
    #view.setViewByIndex(1);
    setprop("sim/model/f15/ejected", 1);
    #settimer(eject2, 1.5);# this is to give the sim time to load the exterior view, so there is no stutter while seat fires and it gets stuck.
    eject2();
    damage.damageLog.push("Pilot ejected");
}

var eject2 = func{
    setprop("canopy/not-serviceable", 1);
    var es = armament.AIM.new(10, "es","gamma", nil ,[-1.85,0,0.7]);
    var es2 = armament.AIM.new(20, "es","gamma", nil ,[0.65,0,0.7]);
    #setprop("fdm/jsbsim/fcs/canopy/hinges/serviceable",0);
    es.releaseAtNothing();
    viewMissile.view_firing_missile(es);
    settimer(func {es2.releaseAtNothing();},0.5);
    #setprop("sim/view[0]/enabled",0); #disabled since it might get saved so user gets no pilotview in next aircraft he flies in.
    settimer(func {aircraft.eject();},3.5);  # apply 100% damage everywhere
}

# Dragchute

var chute = func() {
    if (getprop("sim/model/f15/chute/done")) {
        screen.log.write("Drag chute was released. Repack it once on ground.");
        return;
    }
    chuteLoop.start();
}

var chuteLoopFunc = func() {
    if (getprop("sim/model/f15/chute/repack")) {
        setprop("sim/model/f15/chute/repack", 0);
        return;
    }
    if (!getprop("sim/model/f15/dragchute") or (!getprop("sim/model/f15/chute/enable") and getprop("sim/model/f15/chute/done"))) {
        chuteLoop.stop();
        return;
    } elsif (!getprop("sim/model/f15/chute/enable")) {
        setprop("sim/model/f15/chute/done", 1);
        setprop("sim/model/f15/chute/enable", 1);
        setprop("sim/model/f15/chute/force", 2);
        setprop("sim/model/f15/chute/fold", 0);
    } else {
        if (getprop("/velocities/airspeed-kt") > (185 * 1.05)) { # 10% overspeed safety
            setprop("sim/model/f15/chute/fold", 1);
            setprop("fdm/jsbsim/external_reactions/chute/magnitude", 0);
            settimer(chute_release, 2.0);
            chuteLoop.stop();
            screen.log.write("Drag chute lost: airpseed over 185kts.");
            return;
        } elsif (getprop("/velocities/groundspeed-kt") <= 25) {
            setprop("sim/model/f15/chute/fold",1-getprop("/velocities/groundspeed-kt") / 25);
        }
        var pressure = getprop("fdm/jsbsim/aero/qbar-psf"); # dynamic pressure
        var chuteArea = 200; # squarefeet of chute canopy
        var dragCoeff = 0.50;
        var force     = pressure * chuteArea * dragCoeff;
        setprop("fdm/jsbsim/external_reactions/chute/magnitude", force);
        setprop("sim/model/f15/chute/force", 0, force * 0.000154);
    }
}

var chute_release = func() {
    setprop("sim/model/f15/chute/enable", 0);
    setprop("fdm/jsbsim/external_reactions/chute/magnitude", 0);
}

var chuteLoop = maketimer(0.05, chuteLoopFunc);

var checkNumber = func {
    # Check if number is nil or NaN and print to console if it is.
    # Can take any number of arguments.
    foreach(var test ; arg) {
        if (test[0] == nil or debug.isnan(test[0])) {
            print("ERROR: Variable ",test[1]," is not valid number NaN=",debug.isnan(test[0])," nil=",test[0]==nil);
            return 0;
        }
    }
    return 1;
}

var resetView = func () {
    var hd = getprop("sim/current-view/heading-offset-deg");
    var hd_t = getprop("sim/current-view/config/heading-offset-deg");
    var field = getprop("sim/current-view/config/default-field-of-view-deg");
    var raw = getprop("sim/current-view/view-number-raw");
    var pos = getprop("sim/current-view/config/pitch-offset-deg");
    var ros = getprop("sim/current-view/config/roll-offset-deg");
    if (!checkNumber([hd,"hd"],[hd_t,"hd_t"],[field,"field"],[raw,"raw"],[pos,"pos"],[ros,"ros"])) {
        print("Problem was in view ", raw);
        return;
    }
    if (hd > 180) {
        hd_t = hd_t + 360;
    }
    interpolate("sim/current-view/field-of-view", field, 0.66);
    interpolate("sim/current-view/heading-offset-deg", hd_t,0.66);
    interpolate("sim/current-view/pitch-offset-deg", pos,0.66);
    interpolate("sim/current-view/roll-offset-deg", ros,0.66);

    #if (getprop("sim/current-view/view-number") == 0) {

    var x = getprop("sim/view["~raw~"]/config/x-offset-m");
    var y = getprop("sim/view["~raw~"]/config/y-offset-m");
    var z = getprop("sim/view["~raw~"]/config/z-offset-m");
    if (!checkNumber([x,"x"],[y,"y"],[z,"z"])) {
        print("Problem was in view ", raw);
        return;
    }
    interpolate("sim/current-view/x-offset-m", x, 1);
    interpolate("sim/current-view/y-offset-m", y, 1);
    interpolate("sim/current-view/z-offset-m", z, 1);
    #} else {
    #  interpolate("sim/current-view/x-offset-m", 0, 1);
    #}
}

dynamic_view.register(func {
              me.default_plane();
   });

var ElevatorTrim  = props.globals.getNode("controls/flight/elevator-trim", 1);
var t_increment     = 0.0075;
var trimUp = func {
    e_trim       = ElevatorTrim.getValue();
    e_trim += (CurrentIAS < 120.0) ? t_increment : t_increment * 14400 / (CurrentIAS*CurrentIAS);
    if (e_trim > 1) e_trim = 1;
    ElevatorTrim.setValue(e_trim);
}
var trimDown = func {
    e_trim       = ElevatorTrim.getValue();
    e_trim -= (CurrentIAS < 120.0) ? t_increment : t_increment * 14400 / (CurrentIAS*CurrentIAS);
    if (e_trim < -1) e_trim = -1;
    ElevatorTrim.setValue(e_trim);
}
var last_weapon_selected = getprop("sim/model/f15/controls/armament/weapon-selector");
setlistener("/controls/armament/weapon-selected", func(_wv){
    var v = getprop("sim/model/f15/controls/armament/weapon-selector");
    var delta = _wv.getValue() - last_weapon_selected;
    v = v + delta;
    if (v >= 3) v = 0;
    if (v < 0) v = 3;
    setprop("sim/model/f15/controls/armament/weapon-selector",v);
    _wv.setValue(v);
    last_weapon_selected = v;
},0,0);

setlistener("/controls/armament/target-selected", func(v){
    setprop("sim/model/f15/instrumentation/radar-awg-9/select-target",v.getValue());
},0,0);

#  PropertyAdjustButton.new("Pickle", "/controls/armament/pickle-target", "1"),
#  PropertyAdjustButton.new("Target next", "/controls/armament/target-selected", "1"),
#  PropertyAdjustButton.new("Target previous", "/controls/armament/target-selected", "-1"),
#  PropertyAdjustButton.new("Weapon next", "/controls/armament/weapon-selected", "1"),
#  PropertyAdjustButton.new("Weapon previous", "/controls/armament/weapon-selected", "-1"),
#  PropertyAdjustButton.new("Azimuth left", "/controls/radar/azimuth-deg", "-5"),
#  PropertyAdjustButton.new("Azimuth right", "/controls/radar/azimuth-deg", "5"),
#  PropertyAdjustButton.new("Elevation up", "/controls/radar/elevation-deg", "5"),
#  PropertyAdjustButton.new("Elevation down", "/controls/radar/elevation-deg", "-5"),
#  PropertyAdjustButton.new("Missile Reject", "/controls/armament/missile-reject", "1"),

setlistener("/controls/flight/elevator-trim", func {
	if (getprop("/controls/flight/elevator-trim") > 0.51724) {
		setprop("/controls/flight/elevator-trim", 0.51724);
	}
});

last_position = nil;
distanceNode = props.globals.getNode("/position/distance-flown-nm",1);
distanceNode.setValue(0);

var threat_circles = [  # vector containing the data for all threat circles
    {"lat": 0, "lon": 0, "radius": 0, "enabled": 0, "color": "red", "label": ""},
    {"lat": 0, "lon": 0, "radius": 0, "enabled": 0, "color": "red", "label": ""},
    {"lat": 0, "lon": 0, "radius": 0, "enabled": 0, "color": "red", "label": ""},
    {"lat": 0, "lon": 0, "radius": 0, "enabled": 0, "color": "red", "label": ""},
    {"lat": 0, "lon": 0, "radius": 0, "enabled": 0, "color": "red", "label": ""},
    {"lat": 0, "lon": 0, "radius": 0, "enabled": 0, "color": "red", "label": ""},
    {"lat": 0, "lon": 0, "radius": 0, "enabled": 0, "color": "red", "label": ""},
    {"lat": 0, "lon": 0, "radius": 0, "enabled": 0, "color": "red", "label": ""},
    {"lat": 0, "lon": 0, "radius": 0, "enabled": 0, "color": "red", "label": ""},
    {"lat": 0, "lon": 0, "radius": 0, "enabled": 0, "color": "red", "label": ""},
    {"lat": 0, "lon": 0, "radius": 0, "enabled": 0, "color": "red", "label": ""},
    {"lat": 0, "lon": 0, "radius": 0, "enabled": 0, "color": "red", "label": ""},
    {"lat": 0, "lon": 0, "radius": 0, "enabled": 0, "color": "red", "label": ""},
    {"lat": 0, "lon": 0, "radius": 0, "enabled": 0, "color": "red", "label": ""},
    {"lat": 0, "lon": 0, "radius": 0, "enabled": 0, "color": "red", "label": ""},
    {"lat": 0, "lon": 0, "radius": 0, "enabled": 0, "color": "red", "label": ""},
    {"lat": 0, "lon": 0, "radius": 0, "enabled": 0, "color": "red", "label": ""},
    {"lat": 0, "lon": 0, "radius": 0, "enabled": 0, "color": "red", "label": ""},
    {"lat": 0, "lon": 0, "radius": 0, "enabled": 0, "color": "red", "label": ""},
    {"lat": 0, "lon": 0, "radius": 0, "enabled": 0, "color": "red", "label": ""},
    {"lat": 0, "lon": 0, "radius": 0, "enabled": 0, "color": "red", "label": ""},
];

var push_threat_circle_data_from_dialog = func () {  # used to push data from the mission planning dialog to the actual threat circles
    circle_idx = getprop("/controls/mission-planning/selected-threat-circle");
    circle_radius = getprop("/controls/mission-planning/selected-threat-circle-radius-nm");
    circle_lat = getprop("/controls/mission-planning/selected-threat-circle-lat");
    circle_lon = getprop("/controls/mission-planning/selected-threat-circle-lon");
    circle_on = getprop("/controls/mission-planning/selected-threat-circle-enabled");
    circle_color = getprop("/controls/mission-planning/selected-threat-circle-color");
    circle_label = getprop("/controls/mission-planning/selected-threat-circle-label");
    threat_circles[circle_idx].lat = circle_lat;
    threat_circles[circle_idx].lon = circle_lon;
    threat_circles[circle_idx].radius = circle_radius;
    threat_circles[circle_idx].enabled = circle_on;
    threat_circles[circle_idx].color = circle_color;
    threat_circles[circle_idx].label = circle_label;
    setprop("sim/model/f15/preplanning-status", sprintf("Updated DTC GPS-Spot %02d", circle_idx));
}

var push_threat_circle_data_from_dtc = func (circle_idx, circle_lat, circle_lon, circle_radius, circle_label, circle_color, circle_on) {  # used to push data from the mission planning dialog to the actual threat circles
    threat_circles[circle_idx].lat = circle_lat;
    threat_circles[circle_idx].lon = circle_lon;
    threat_circles[circle_idx].radius = circle_radius;
    threat_circles[circle_idx].enabled = circle_on;
    threat_circles[circle_idx].color = circle_color;
    threat_circles[circle_idx].label = circle_label;
    setprop("sim/model/f15/preplanning-status", sprintf("Updated DTC GPS-Spot %02d", circle_idx));
}

var F15MainModule =
{
    update: func(notification){
        # total distance flown calculations.
        currentDistance = distanceNode.getValue();
        if ( last_position != nil) {
            # total distance
            currentPosition = geo.aircraft_position();
            distanceNode.setValue(currentDistance + (last_position.distance_to(currentPosition)*M2NM));
        }
        last_position = currentPosition = geo.aircraft_position();

        var frame_count = math.mod(notification.FrameCount,8);

        # Check for GPU is external electrical power switch is online
        if (getprop("fdm/jsbsim/systems/electrics/ground-power") and !getprop("fdm/jsbsim/systems/electrics/ground-power-gpu")) {
            setprop("fdm/jsbsim/systems/electrics/ground-power", 0);
            screen.log.write("Demand a Ground Power Unit in the F-15EX Eagle II config panel to connect external power!");
        }

        # Make sure ripple number is at least 1 and not higher than 4
        if (getprop("controls/armament/dual") < 1) {
            setprop("controls/armament/dual", 1);
        }
        if (getprop("controls/armament/dual") > 4) {
            setprop("controls/armament/dual", 4);
        }

        # Compute the trust/weight ratio and set it to an avionics property
        gross_weight = getprop("fdm/jsbsim/inertia/weight-lbs");
        thrust = 29500.0 * 2;  # for twin F100-GE-129s
        thrust_weight_ratio = thrust / gross_weight;
        setprop("sim/model/f15/avionics/thrust-weight-ratio", thrust_weight_ratio);

        # Make sure that if CFTs are not installed, non-CFT-compatible stations are empty
        if (getprop("fdm/jsbsim/propulsion/cft") != 1 or !getprop("fdm/jsbsim/propulsion/cft")) {
            setprop("payload/weight[18]/selected", "Empty");
            setprop("payload/weight[19]/selected", "Empty");
            setprop("payload/weight[20]/selected", "Empty");
            setprop("payload/weight[21]/selected", "Empty");
            setprop("payload/weight[22]/selected", "Empty");
            setprop("payload/weight[23]/selected", "Empty");
            setprop("payload/weight[24]/selected", "Empty");
            setprop("payload/weight[25]/selected", "Empty");
        }

        # Make sure the radar is set to standby when the gear's down
        if (getprop("controls/gear/gear-down") == 1) {
            setprop("instrumentation/radar/radar-mode", 2);
        }

        # Taken from the F-16
        if (getprop("payload/armament/es/flags/deploy-id-10") != nil) {
            # ejection chute force
            setprop("sim/model/f15/force", 7-5*getprop("payload/armament/es/flags/deploy-id-10"));
        } else {
            setprop("sim/model/f15/force", 7);
        }

        # Force target pod view
        if (getprop("sim/model/f15/force-tgp") == 1) {
            CurrentView_Num.setValue(tgp_view_num);
        }

        # Quick patch for pylons weight not computing, no clue why ...
        all_pylons = [12,1,5,9,15];
        foreach (cur_pyl; all_pylons) {
            if (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "2 x AIM-9X Block I Sidewinder") {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 186*getprop("payload/armament/station/id-"~cur_pyl~"-count") + 15);
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "2 x AIM-120D AMRAAM") {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 291*getprop("payload/armament/station/id-"~cur_pyl~"-count") + 25);
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "1 x MK-84") {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 2000);
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "3 x MK-83") {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 1000*getprop("payload/armament/station/id-"~cur_pyl~"-count") + 25);
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "3 x CBU-87") {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 950*getprop("payload/armament/station/id-"~cur_pyl~"-count") + 25);
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "2 x CBU-105") {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 934*getprop("payload/armament/station/id-"~cur_pyl~"-count") + 25);
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "2 x GBU-12") {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 610*getprop("payload/armament/station/id-"~cur_pyl~"-count") + 30);
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "1 x AGM-84D" or getprop("payload/armament/station/id-"~cur_pyl~"-set") == "1 x AGM-84E") {  # D and C variant both got the same weight
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 1190.0*getprop("payload/armament/station/id-"~cur_pyl~"-count"));
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "1 x AGM-88E") {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 800*getprop("payload/armament/station/id-"~cur_pyl~"-count"));
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "1 x AGM-154A") {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 1065*getprop("payload/armament/station/id-"~cur_pyl~"-count"));
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "1 x AGM-158A" or getprop("payload/armament/station/id-"~cur_pyl~"-set") == "1 x AGM-158C") {  # A and C variants both got the same weight
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 2150*getprop("payload/armament/station/id-"~cur_pyl~"-count"));
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "1 x AGM-88E") {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 800*getprop("payload/armament/station/id-"~cur_pyl~"-count"));
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "2 x CATM-9X Sidewinder Dummy") {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 387*getprop("payload/armament/station/id-"~cur_pyl~"-count"));
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "2 x CATM-120D AMRAAM Dummy") {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 291*getprop("payload/armament/station/id-"~cur_pyl~"-count") + 25);
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "AN/ALQ-184(V) ECM Pod") {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 705*getprop("payload/armament/station/id-"~cur_pyl~"-count"));
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "1 x GBU-31") {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 2039*getprop("payload/armament/station/id-"~cur_pyl~"-count"));
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "2 x GBU-54") {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 558*getprop("payload/armament/station/id-"~cur_pyl~"-count") + 20);
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "1 x AGM-119A") {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 820*getprop("payload/armament/station/id-"~cur_pyl~"-count"));
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "1 x AGM-119A") {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 820*getprop("payload/armament/station/id-"~cur_pyl~"-count"));
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "1 x GBU-32") {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 1105*getprop("payload/armament/station/id-"~cur_pyl~"-count"));
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "2 x GBU-32") {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 1105*getprop("payload/armament/station/id-"~cur_pyl~"-count") + 20);
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "4 x GBU-39") {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 285*getprop("payload/armament/station/id-"~cur_pyl~"-count") + 50);
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "3 x M151") {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 935);
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "2 x AGM-65B") {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 462.5*getprop("payload/armament/station/id-"~cur_pyl~"-count") + 25);
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "2 x AGM-65D") {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 462.5*getprop("payload/armament/station/id-"~cur_pyl~"-count") + 25);
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "3 x AGM-65B") {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 462.5*getprop("payload/armament/station/id-"~cur_pyl~"-count") + 30);
            } elsif (getprop("payload/armament/station/id-"~cur_pyl~"-set") == "3 x AGM-65D") {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 462.5*getprop("payload/armament/station/id-"~cur_pyl~"-count") + 30);
            } else {
                setprop("payload/weight["~cur_pyl~"]/weight-lb", 0);
            }
        }

        if (getprop("consumables/fuel/tank[7]/selected")) {
            setprop("payload/weight[5]/weight-lb", 271);
        }
        if (getprop("consumables/fuel/tank[5]/selected")) {
            setprop("payload/weight[1]/weight-lb", 271);
        }
        if (getprop("consumables/fuel/tank[6]/selected")) {
            setprop("payload/weight[9]/weight-lb", 271);
        }

        # Gear overspeed damage
        if (getprop("controls/gear/gear-down") == 1 and getprop("/velocities/airspeed-kt") > (300 * 1.1) and (getprop("controls/gear/brakes-blownout") == nil or getprop("controls/gear/brakes-blownout") == 0)) { # 10% overspeed safety
            screen.log.write("Wheel brakes are now unusable.");
            setprop("controls/gear/brakes-blownout", 1);
        }

        # Flaps overspeed damage
        if (getprop("controls/flight/flaps") == 1 and (getprop("/velocities/airspeed-kt") > 250 * 1.1) and (getprop("controls/flaps-overspeed") == nil or getprop("controls/flaps-overspeed") == 0)) {  # 10% overspeed safety
            screen.log.write("Flap damage: airpseed over 250kts.");
            screen.log.write("Flap are now unusable.");
            setprop("controls/flaps-overspeed", 1);
        }
        if (getprop("controls/flaps-overspeed") == 1) {
            controls.flapsDown(-1);
        }

        # Wheel brake overspeed damage
        if ((((getprop("/controls/gear/brake-left") == 1 or getprop("/controls/gear/brake-right") == 1) and getprop("/velocities/airspeed-kt") > (130 * 1.15) and getprop("controls/gear/gear-down") == 1) or (getprop("/velocities/airspeed-kt") > (50 * 1.2) and getprop("/controls/gear/brake-parking") == 1)) and getprop("controls/gear/brakes-blownout") == 0) {
            # Brakes are now blown out, disable them
            screen.log.write("Brakes blownout: used while going too fast.");
            screen.log.write("Wheel brakes are now unusable.");
            setprop("controls/gear/brakes-blownout", 1);
        }
        if (getprop("controls/gear/brakes-blownout") == 1) {
            setprop("/controls/gear/brake-left", 0);
            setprop("/controls/gear/brake-right", 0);
            setprop("/controls/gear/brake-parking", 0);
        }

        # Calculate time till crash for flyup display
        # Same method here as in the F-16 (copy-and-paste)
        if ((getprop("velocities/speed-east-fps") != 0 or getprop("velocities/speed-north-fps") != 0) and getprop("fdm/jsbsim/gear/unit[0]/WOW") != 1 and
              getprop("fdm/jsbsim/gear/unit[1]/WOW") != 1 and (
             (getprop("fdm/jsbsim/gear/gear-pos-norm")<1)
            or (getprop("fdm/jsbsim/gear/gear-pos-norm")>0.99 and getprop("/position/altitude-agl-ft") > 164)
            )) {
            me.start = geo.aircraft_position();

            me.speed_down_fps  = getprop("velocities/speed-down-fps");
            me.speed_east_fps  = getprop("velocities/speed-east-fps");
            me.speed_north_fps = getprop("velocities/speed-north-fps");
            me.speed_horz_fps  = math.sqrt((me.speed_east_fps*me.speed_east_fps)+(me.speed_north_fps*me.speed_north_fps));
            me.speed_fps       = math.sqrt((me.speed_horz_fps*me.speed_horz_fps)+(me.speed_down_fps*me.speed_down_fps));
            me.heading = 0;
            if (me.speed_north_fps >= 0) {
                me.heading -= math.acos(me.speed_east_fps/me.speed_horz_fps)*R2D - 90;
            } else {
                me.heading -= -math.acos(me.speed_east_fps/me.speed_horz_fps)*R2D - 90;
            }
            me.heading = geo.normdeg(me.heading);
            #cos(90-heading)*horz = east
            #acos(east/horz) - 90 = -head

            me.end = geo.Coord.new(me.start);
            me.end.apply_course_distance(me.heading, me.speed_horz_fps*FT2M);
            me.end.set_alt(me.end.alt()-me.speed_down_fps*FT2M);

            me.dir_x = me.end.x()-me.start.x();
            me.dir_y = me.end.y()-me.start.y();
            me.dir_z = me.end.z()-me.start.z();
            me.xyz = {"x":me.start.x(),  "y":me.start.y(),  "z":me.start.z()};
            me.dir = {"x":me.dir_x,      "y":me.dir_y,      "z":me.dir_z};

            me.geod = get_cart_ground_intersection(me.xyz, me.dir);
            if (me.geod != nil) {
                me.end.set_latlon(me.geod.lat, me.geod.lon, me.geod.elevation);
                me.dist = me.start.direct_distance_to(me.end)*M2FT;
                me.time = me.dist / me.speed_fps;
                setprop("instrumentation/radar/time-till-crash", me.time);
            } else {
                setprop("instrumentation/radar/time-till-crash", 15);
            }
        } else {
            setprop("instrumentation/radar/time-till-crash", 15);
        }

        # legacy logic for subscheduling.
        if (frame_count == 0){
            aircraft.electricsFrame();
            aircraft.rain.update();
            aircraft.computeEngines ();
            acFrost.setValue(sysFrost.getValue());
        } elsif (frame_count == 3)
            updateVolume();
        elsif (frame_count == 4)
            radarStandbyNode.setValue((radarMPnode.getValue() or 0)>= 2);
        elsif (frame_count == 5) {
            aircraft.routeManagerUpdate();
            aircraft.TerFolRadUpdate();
        } elsif (frame_count == 6) {
            if (getprop("fdm/jsbsim/propulsion/ground-refuel") and (!wow or getprop("fdm/jsbsim/gear/unit[2]/wheel-speed-fps") > 1)) {
                setprop("fdm/jsbsim/propulsion/refuel",0);
                setprop("fdm/jsbsim/propulsion/ground-refuel",0);
            }
            wow = notification.wowLnode or notification.wowRnode;
        }
    },
};
var input = {
    CurrentIASnode      : "velocities/airspeed-kt",
    CurrentMachnode     : "velocities/mach",
    altitude_ft         : "position/altitude-ft",
    wowLnode            : "gear/gear[1]/wow",
    wowRnode            : "gear/gear[2]/wow",
    Alphanode           : "orientation/alpha-indicated-deg",
    Throttlenode        : "controls/engines/engine/throttle",
    e_trimnode          : "controls/flight/elevator-trim",
    deltaTnode          : "sim/time/delta-sec",
    currentGnode        : "accelerations/pilot-gdamped",
};
emexec.ExecModule.register("F-15 Main", input, F15MainModule);
if (emexec.ExecModule.transmitter["OverrunDetection"] != nil)
    emexec.ExecModule.transmitter.OverrunDetection(16);
