# F-15 Weapons system
# ---------------------------
# ---------------------------
# Richard Harrison (rjh@zaretto.com) Feb  2015 - based on F-14B version by Alexis Bory
# ---------------------------

var AcModel = props.globals.getNode("sim/model/f15");
var SwCoolOffLight   = AcModel.getNode("controls/armament/acm-panel-lights/sw-cool-off-light");
var MslPrepOffLight  = AcModel.getNode("controls/armament/acm-panel-lights/msl-prep-off-light");
var WeaponSelector    = AcModel.getNode("controls/armament/weapon-selector");# 0: gun 1:aim9 2:aim7/aim120 5:mk84
var ArmSwitch        = AcModel.getNode("controls/armament/master-arm-switch");# 0:off 1:armed
var GrSwitch         = AcModel.getNode("controls/armament/gun-rate-switch");
var SysRunning       = AcModel.getNode("systems/armament/system-running");
var GunRunning       = AcModel.getNode("systems/gun/running");
var GunCountAi       = props.globals.getNode("ai/submodels/submodel[4]/count");
var GunCount         = AcModel.getNode("systems/gun/rounds");
var GunReady         = AcModel.getNode("systems/gun/ready");
#var GunStop          = AcModel.getNode("systems/gun/stop", 1);
var GunRateHighLight = AcModel.getNode("controls/armament/acm-panel-lights/gun-rate-high-light");
var WeaponsWeight = props.globals.getNode("sim/model/f15/systems/external-loads/weapons-weight", 1);
var PylonsWeight = props.globals.getNode("sim/model/f15/systems/external-loads/pylons-weight", 1);
var TankssWeight = props.globals.getNode("sim/model/f15/systems/external-loads/tankss-weight", 1);

# smoke stuff:
var Smoke = props.globals.getNode("sim/model/f15/fx/smoke", 1);#double
var SmokeCmd = props.globals.initNode("sim/model/f15/fx/smoke-cmd", 0,"BOOL");
var SmokeMountedL = props.globals.initNode("sim/model/f15/fx/smoke-mnt-left", 0,"BOOL");
var SmokeMountedR = props.globals.initNode("sim/model/f15/fx/smoke-mnt-right", 0,"BOOL");

var Count9 = props.globals.initNode("sim/model/f15/systems/armament/aim9/count", 0,"INT");
var Count7 = props.globals.initNode("sim/model/f15/systems/armament/aim7/count", 0,"INT");
var Count120 = props.globals.initNode("sim/model/f15/systems/armament/aim120/count", 0,"INT");
var Count84 = props.globals.initNode("sim/model/f15/systems/armament/agm/count", 0,"INT");
var CountG = props.globals.initNode("sim/model/f15/systems/gun/rounds", 0,"INT");

# AIM-9 stuff:
var SwCount    = AcModel.getNode("systems/armament/aim9/count");
var SWCoolOn   = AcModel.getNode("controls/armament/acm-panel-lights/sw-cool-on-light");
var SWCoolOff  = AcModel.getNode("controls/armament/acm-panel-lights/sw-cool-off-light");

var Current_srm   = nil;
var Current_agm   = nil;
var Current_mrm   = nil;
var Current_missile   = nil;
var sel_missile_count = 0;

aircraft.data.add( WeaponSelector, ArmSwitch );

var FALSE = 0;
var TRUE  = 1;

setlistener("sim/model/f15/controls/armament/weapon-selector", func(v)
{
    aircraft.arm_selector();
});

var getDLZ = func {
    return pylons.getDLZ();
}

var ccrp = func {
    var weap = pylons.fcs.getSelectedWeapon();
    if (weap != nil and weap.parents[0] == armament.AIM and (weap.type == "MK-84" or weap.type == "GBU-10" or weap.type == "MK-82AIR" or weap.type == "MK-82" or weap.type == "MK-83" or weap.type == "CBU-87" or weap.type == "CBU-105" or weap.type == "GBU-12" or weap.type == "GBU-31")) {
        var ccrp_meters = weap.getCCRP(20,0.25);#meters left to release point
        if (ccrp_meters != nil) {
            # this should make the ccrp bomb steering line and the bomb release cue.
            #
            # the vertical steering line should have same heading deviation as the target and span entirety of HUD
            # the small horizontal cue should have same heading deviation but its vertical position should be middle of HUD when ccrp_meter is 0 and top of HUD when ccrp_meters is 1000 or larger.
            # another fixed small horizontal lines should be in middle of HUD vertical. Horizontal it should follow steering line.
            setprop("sim/model/f15/systems/armament/aim9/ccrp",1);#if ccrp should be displayed in HUD.
            setprop("sim/model/f15/systems/armament/aim9/ccrp-hud-vert", ccrp_meters);# haven't linked this to anything yet.
            return;
        }
    }
}

# Init
var weapons_init = func() {
    print("Initializing F-15 weapons system");

    masw(ArmSwitch);
    update_gun_ready();
    arm_selector();
}


## All the following lines are taken from the A-10 model and adapted by Jimmy L. Miles
## These methods are used for compatible AGM missiles: AGM-65B, AGM-65D and AGM-84D, AGM-88B (not AGM-154A and AGM-158A since no seeker and GPS guided)
## It ranomly moves the caged seeker cursor until it finds a target. When a target's found,
## the seeker goes uncaged and tracks the target. If the target is lock, searchin mode turns back online

var defaultX = 0;
var defaultY = 0;
#Seeker Loop for cursor control
var seekerLoop = func {
    selectedWeap = pylons.fcs.getSelectedWeapon();
    var cursorX = getprop("sim/model/f15/cursor-slew/x");
    var cursorY = getprop("sim/model/f15/cursor-slew/y");
    if (selectedWeap == nil) {
        seekerTimer.stop();
    } elsif ((selectedWeap.type == "AGM-65B" or selectedWeap.type == "AGM-65D" or selectedWeap.type == "AGM-84D" or selectedWeap.type == "AGM-88B") and (awg_9.active_u == nil or !awg_9.active_u.get_display())) {
        selectedWeap.commandDir(cursorX,cursorY);
    } elsif (awg_9.active_u != nil and awg_9.active_u.get_display() and (selectedWeap.type == "AGM-65B" or selectedWeap.type == "AGM-65D" or selectedWeap.type == "AGM-84D" or selectedWeap.type == "AGM-88B")) {  # If we have a valid radar target, slave the AGM's seeker to that
        # Code taken from the HUD, used to transform the target's position into the target rectangle designator's position into the HUD
        var u_dev_rad = (90-awg_9.active_u.get_deviation(getprop("orientation/heading-deg")))  * D2R;
        var u_elev_rad = (90-awg_9.active_u.get_total_elevation(getprop("orientation/heading-deg")))  * D2R;
        var devs = aircraft.develev_to_devroll(u_dev_rad, u_elev_rad);
        var combined_dev_deg = devs[0];
        var combined_dev_length =  devs[1];
        var clamped = devs[2];
        var ht_yco = 0;  # all 4 variables here are from the HUD!
        var ht_xco = 0;
        var ht_ycf = -1024;
        var ht_xcf = 1024;
        var yc  = ht_yco + (ht_ycf * combined_dev_length * math.cos(combined_dev_deg*D2R));
        var xc = ht_xco + (ht_xcf * combined_dev_length * math.sin(combined_dev_deg*D2R));
        selectedWeap.commandRadar(xc, yc);
    }
};
seekerTimer = maketimer(0.1, seekerLoop);  # orginially timer was .025 but it seemed a bit to much to me so reduced it to .1

#Maverick Init:
var mavInit = func {
    selectedWeap = pylons.fcs.getSelectedWeapon();
    selectedWeap.setContacts(awg_9.getCompleteList());
    selectedWeap.commandDir(defaultX,defaultY);
    selectedWeap.setAutoUncage(0);
    selectedWeap.setCaged(1);
    armament.contact = nil;
    cursorMove.start();
    seekerTimer.start();
};

var mavUpdate = func {
    selectedWeap = pylons.fcs.getSelectedWeapon();
    if (selectedWeap == nil or (selectedWeap.type != "AGM-65B" and selectedWeap.type != "AGM-65D" and selectedWeap.type != "AGM-84D" and selectedWeap.type != "AGM-88B")) {
        #print ("Weapon is not of type AGM - Skipping sequence");
        cursorMove.stop();
        seekerTimer.stop();
    }else{
        if (ArmSwitch.getValue() == 0) {
            #print("Master Arm safe - Skipping");
        }else{
            setprop("sim/model/f15/cursor-slew/x",defaultX);
            setprop("sim/model/f15/cursor-slew/y",defaultY);
            mavInit();
        }
    }

};

setlistener(WeaponSelector, mavUpdate, nil, 0);
setlistener("controls/armament/trigger", mavUpdate, nil, 0);
setlistener("controls/armament/selected-armament-offset", mavUpdate, nil, 0);

#Maverick seeker control
var rate = .0025;
var maxDegMove = 11;

var xRight = func {
    var current = math.clamp(getprop("sim/model/f15/cursor-slew/x"),-maxDegMove,maxDegMove);
    setprop("sim/model/f15/cursor-slew/x", current + rand()/3);

};

var xLeft = func {
    var current = math.clamp(getprop("sim/model/f15/cursor-slew/x"),-maxDegMove,maxDegMove);
    setprop("sim/model/f15/cursor-slew/x", current - rand()/3);

};

var yUp = func {
    var current = math.clamp(getprop("sim/model/f15/cursor-slew/y"),-maxDegMove,maxDegMove);
    setprop("sim/model/f15/cursor-slew/y", current + rand()/3);

};

var yDown = func {
    var current = math.clamp(getprop("sim/model/f15/cursor-slew/y"),-maxDegMove,maxDegMove);
    setprop("sim/model/f15/cursor-slew/y", current - rand()/3);
};

var seekerMove = func {

    if (rand() > .5) {
        xRight();
    } else {
        xLeft();
    }
    if (rand() > .5) {
        yUp();
    } else {
        yDown();
    }
}

var lock = func {
    selectedWeap = pylons.fcs.getSelectedWeapon();
    if (selectedWeap != nil and ArmSwitch.getValue() > 0 and (selectedWeap.type == "AGM-65B" or selectedWeap.type == "AGM-65D" or selectedWeap.type == "AGM-84D" or selectedWeap.type == "AGM-88B")) {
        if (armament.MISSILE_LOCK == selectedWeap.status) {
            selectedWeap.setCaged(0);
            #print("Valid tgt - Uncaging");
        } else {
            selectedWeap.setCaged(1);
            #print("Not uncaging - no valid tgt to lock");
        }
    } else {
        #print("Selected Weapon is not an AGM-65 or Master Arm safe. Not locking target");
    }

};


cursorMove = maketimer(rate,seekerMove);

# -- End of AGMs seeker code

## All the following lines have been by Jimmy L. Miles. This code allows the salving of the current radar target's GPS to GPS guided weapons: AGM-154A, AGM-158A, GBU-31 and CBU-105
## The following code has a loop checking if the radar's got an active and valid target to lock on, and if the AGM-154A or AGM-158A is selected, and armed and ready, the target's
## gps coordinates computed by the radar are "slaved" to the AGM-154A or AGM-158A. Doesn't support mid-flight updates yet, so not very effective against moving targets.
var gpsInit = func {
    selectedWeap = pylons.fcs.getSelectedWeapon();
    selectedWeap.setContacts(awg_9.getCompleteList());
    armament.contact = nil;
    gpsFeeder.start();
    setprop("sim/model/f15/fcs/target-lat", 0);
    setprop("sim/model/f15/fcs/target-lon", 0);
    setprop("sim/model/f15/fcs/target-alt", 0);
    setprop("sim/model/f15/fcs/target-lock", 0);
};

var gpsUpdate = func {
    selectedWeap = pylons.fcs.getSelectedWeapon();
    if (selectedWeap == nil or (selectedWeap.type != "AGM-154A" and selectedWeap.type != "AGM-158A" and selectedWeap.type != "GBU-31" and selectedWeap.type != "CBU-105")) {
        #print("Weapon is not of type AGM154A or AGM158A or GBU31 - Skipping sequence");
        gpsFeeder.stop();
    } else {
        if (ArmSwitch.getValue() == 0) {
            #print("Master Arm safe - Skipping");
        }else{
            gpsInit();
        }
    }
};

var updateGPSTarget = func {
    selectedWeap = pylons.fcs.getSelectedWeapon();
    if (selectedWeap != nil and ArmSwitch.getValue() > 0 and (selectedWeap.type == "AGM-154A" or selectedWeap.type == "AGM-158A" or selectedWeap.type == "GBU-31" or selectedWeap.type == "CBU-105")) {
        if (awg_9.active_u != nil and awg_9.active_u.get_display()) {  # We have a valid radar target
            gpsCoordsTgt = awg_9.active_u.get_Coord();
            var tgt_lat = gpsCoordsTgt.lat();
            var tgt_lon = gpsCoordsTgt.lon();
            var tgt_alt = gpsCoordsTgt.alt();  # WARNING: default is meters, god knows why
            #print("target "~tgt_lat~", "~tgt_lon~" at "~(tgt_alt*M2FT)~" ft");
            setprop("sim/model/f15/fcs/target-lat", tgt_lat);
            setprop("sim/model/f15/fcs/target-lon", tgt_lon);
            setprop("sim/model/f15/fcs/target-alt", tgt_alt*M2FT);
            setprop("sim/model/f15/fcs/target-lock", 1);
            var spot = awg_9.ContactTGP.new("GPS-Spot",gpsCoordsTgt,0);
    		armament.contactPoint = spot;  # should be already done in awg_9.nas, but still lettin that here as a safety
            tgp.gps = 1;
            if (getprop("sim/model/f15/stores/tgp-mounted") and 0) {
    			tgp.flir_updater.click_coord_cam = armament.contactPoint.get_Coord();
    			callsign = armament.contactPoint.getUnique();
                setprop("sim/model/f15/flir/target/auto-track", 1);
                flir_updater.offsetP = 0;
                flir_updater.offsetH = 0;
    			setprop("sim/model/f15/avionics/tgp-lock", 1);
    		}
    		selectedWeap.setContacts([spot]);
        } else {
            #print("No valid radar target");
            setprop("sim/model/f15/fcs/target-lock", 0);
        }
    } else {  # invalid inputs
        #print("Invalid inputs");
        setprop("sim/model/f15/fcs/target-lock", 0);
    }
};

gpsFeeder = maketimer(.1,updateGPSTarget);

setlistener(WeaponSelector, gpsUpdate, nil, 0);
setlistener("controls/armament/trigger", gpsUpdate, nil, 0);
setlistener("controls/armament/selected-armament-offset", gpsUpdate, nil, 0);
# -- end of GPS guided weapons code

# Main loop
var armament_update = func {
    # Trigered each 0.1 sec by instruments.nas main_loop() if Master Arm Engaged.

    lock();

    var stick_s = WeaponSelector.getValue();

    for (var i = 0;i<10;i+=1) {
        # Pylon lights and count of ready weapons:
        var p = pylons.pylons[i+1];
        var weaps = p.getWeapons();
        if (size(weaps) and weaps[0] != nil) {
            setprop("sim/model/f15/systems/external-loads/station["~p.guiID ~"]/display",1);
        } else {
            setprop("sim/model/f15/systems/external-loads/station["~p.guiID~"]/display",0);
        }
        #populate the payload dialog:
        setprop("sim/model/f15/systems/external-loads/station["~p.guiID~"]/type", getprop("payload/weight["~p.guiID~"]/selected"));
    }

    # Update selected weapon on the HUD
    if (WeaponSelector.getValue() == 0) {
        setprop("sim/model/f15/systems/armament/selected-arm", "M61A1");
    }

    # Turn sidewinder cooling lights On/Off.
    var aim9_count = pylons.fcs.getAmmoOfType("AIM-9") + pylons.fcs.getAmmoOfType("AIM-9X") + pylons.fcs.getAmmoOfType("CATM-9X");
    if (stick_s == 1) {
        if (aim9_count > 0) {
            SWCoolOn.setBoolValue(1);
            SWCoolOff.setBoolValue(0);
        } else {
            SWCoolOn.setBoolValue(0);
            SWCoolOff.setBoolValue(1);
        }
    } else {
        SWCoolOn.setBoolValue(0);
        SWCoolOff.setBoolValue(0);
    }

    SwCount.setValue(aim9_count);
    Count9.setValue(aim9_count);
    Count7.setValue(pylons.fcs.getAmmoOfType("AIM-7"));
    Count120.setValue(pylons.fcs.getAmmoOfType("AIM-120") + pylons.fcs.getAmmoOfType("AIM-120D") + pylons.fcs.getAmmoOfType("CATM-120D"));
    Count84.setValue(pylons.fcs.getAmmoOfType("MK-84")+pylons.fcs.getAmmoOfType("GBU-10")+pylons.fcs.getAmmoOfType("MK-82AIR")+pylons.fcs.getAmmoOfType("MK-82")+pylons.fcs.getAmmoOfType("MK-83")+pylons.fcs.getAmmoOfType("CBU-87")+pylons.fcs.getAmmoOfType("CBU-105")+pylons.fcs.getAmmoOfType("AGM-65B")+pylons.fcs.getAmmoOfType("GBU-12")+pylons.fcs.getAmmoOfType("AGM-65D")+pylons.fcs.getAmmoOfType("AGM-84D")+pylons.fcs.getAmmoOfType("AGM-88B")+pylons.fcs.getAmmoOfType("AGM-154A")+pylons.fcs.getAmmoOfType("AGM-158A")+pylons.fcs.getAmmoOfType("GBU-31"));

    update_gun_ready();
    setCockpitLights();
    # Calculate ccrp
    #ccrp();
}

# Main loop 2
var armament_update2 = func {
    # Trigered each 0.1 sec by instruments.nas main_loop()

    # calculate pylon and weapon total mass:
    var pw = getprop("fdm/jsbsim/inertia/pointmass-weight-lbs[13]") + getprop("fdm/jsbsim/inertia/pointmass-weight-lbs[14]");
    var wWeight = 0;
    var pWeight = pw;
    var tWeight = 0;
    var updatePayload = 0;
    for (var i = 0;i<11;i+=1) {
        var ws = pylons.pylons[i+1].getWeapons();
        # Unecessary ?
        #if ((i == 1 or i==5 or i==9) and (getprop("payload/weight["~i~"]/selected") == "MK-84" or getprop("payload/weight["~i~"]/selected") == "GBU-10" or getprop("payload/weight["~i~"]/selected") == "MK-82AIR" or getprop("payload/weight["~i~"]/selected") == "MK-82" or getprop("payload/weight["~i~"]/selected") == "MK-83" or getprop("payload/weight["~i~"]/selected") == "CBU-87" or getprop("payload/weight["~i~"]/selected") == "CBU-105" or getprop("payload/weight["~i~"]/selected") == "GBU-12") and size(ws) > 0 and ws[0] == nil) {
        #    # the MK-84 on this station has been released
        #    setprop("payload/weight["~i~"]/selected","Empty");
        #    updatePayload = 1;
        #}
        setprop("sim/model/f15/systems/external-loads/station["~i~"]/type", getprop("payload/weight["~i~"]/selected"));
        var mass = pylons.pylons[i+1].getMass();
        wWeight += mass[0];
        pWeight += mass[1];
    }
    if (updatePayload) {
        payload_dialog_reload("update_stores_bombs "~i);
        arm_selector();# because the fire-control.nas will deselect all weapons when the GUI is set to "none" or "Droptank".
    }
    if (aircraft.Centre_External.is_fitted()) {
        tWeight += getprop("payload/weight[5]/weight-lb");
    }
    if (aircraft.WingExternal_L.is_fitted()) {
        tWeight += getprop("payload/weight[1]/weight-lb");
    }
    if (aircraft.WingExternal_R.is_fitted()) {
        tWeight += getprop("payload/weight[9]/weight-lb");
    }

    WeaponsWeight.setDoubleValue(wWeight);
    PylonsWeight.setDoubleValue(pWeight);
    TankssWeight.setDoubleValue(tWeight);

    # set internal master-arm.
    setprop("controls/armament/master-arm", ArmSwitch.getValue()>0);

    # manage smoke
    if (SmokeCmd.getValue() and (SmokeMountedR.getValue() or SmokeMountedL.getValue())) {
        Smoke.setDoubleValue(1);
    } else {
        Smoke.setDoubleValue(0);
    }
}

var setCockpitLights = func {
    if (ArmSwitch.getValue() > 0 and pylons.fcs.isLock()) {
        setprop("sim/model/f15/systems/armament/lock-light", 1);
    } else {
        setprop("sim/model/f15/systems/armament/lock-light", 0);
    }

    var dlzArray = getDLZ();
    if (dlzArray == nil or size(dlzArray) == 0) {
        setprop("sim/model/f15/systems/armament/launch-light", 0);
    } else {
        if (dlzArray[4] < dlzArray[1]) {
            setprop("sim/model/f15/systems/armament/launch-light", 1);
        } else {
            setprop("sim/model/f15/systems/armament/launch-light", 0);
        }
    }
}


var update_gun_ready = func() {
    var ready = 0;
    if ( ArmSwitch.getValue() and GunCount.getValue() > 0 and getprop("payload/armament/fire-control/serviceable")) {#todo: add elec/hydr requirements here too
        ready = 1;
    }
    GunReady.setBoolValue(ready);
    var real_gcount = GunCountAi.getValue();
    GunCount.setIntValue(real_gcount*5);
    CountG.setIntValue(real_gcount*5);
}

var missile_code_from_ident= func(mty)  # not used anymore I think but still keppin this up to date
{
        if (mty == "AIM-9")
            return "aim9";
        elsif (mty == "AIM-9X")
            return "aim9x";
        elsif (mty == "CATM-9X")
            return "catm9x";
        else if (mty == "AIM-7")
            return "aim7";
        else if (mty == "MK-82")
            return "mk82";
        else if (mty == "MK-83")
            return "mk83";
        else if (mty == "MK-84")
            return "mk84";
        else if (mty == "MK-82AIR")
            return "mk82air";
        else if (mty == "GBU-12")
            return "gbu12";
        else if (mty == "AGM-65B")
            return "agm65b";
        else if (mty == "AGM-65D")
            return "agm65d";
        else if (mty == "AGM-84D")
            return "agm84d";
        else if (mty == "AGM-154A")
            return "agm154a";
        else if (mty == "GBU-31")
            return "gbu31";
        else if (mty == "AGM-158A")
            return "agm158a";
        else if (mty == "AGM-88B")
            return "agm88b";
        else if (mty == "CBU-87")
            return "cbu87";
        else if (mty == "CBU-105")
            return "cbu105";
        else if (mty == "MK-83")
            return "mk83";
        else if (mty == "MK-82")
            return "mk82";
        else if (mty == "GBU-10")
            return "gbu10";
        else if (mty == "AIM-120")
            return "aim120";
        else if (mty == "AIM-120D")
            return "aim120d";
        else if (mty == "CATM-120D")
            return "catm120d";
}
var get_sel_missile_count = func()
{
    if (WeaponSelector.getValue() == 5)
    {
        return pylons.fcs.getAmmoOfType("MK-84")+pylons.fcs.getAmmoOfType("GBU-10")+pylons.fcs.getAmmoOfType("MK-82AIR")+pylons.fcs.getAmmoOfType("MK-82")+pylons.fcs.getAmmoOfType("MK-83")+pylons.fcs.getAmmoOfType("CBU-87")+pylons.fcs.getAmmoOfType("CBU-105")+pylons.fcs.getAmmoOfType("AGM-65B")+pylons.fcs.getAmmoOfType("GBU-12")+pylons.fcs.getAmmoOfType("AGM-65D")+pylons.fcs.getAmmoOfType("AGM-84D")+pylons.fcs.getAmmoOfType("AGM-88B")+pylons.fcs.getAmmoOfType("AGM-154A")+pylons.fcs.getAmmoOfType("AGM-158A")+pylons.fcs.getAmmoOfType("GBU-31");
    }
    else if (WeaponSelector.getValue() == 1)
    {
        return pylons.fcs.getAmmoOfType("AIM-9") + pylons.fcs.getAmmoOfType("AIM-9X") + pylons.fcs.getAmmoOfType("CATM-9X");
    }
    else if (WeaponSelector.getValue() == 2)
    {
        return pylons.fcs.getAmmoOfType("AIM-7")+pylons.fcs.getAmmoOfType("AIM-120")+pylons.fcs.getAmmoOfType("AIM-120D")+pylons.fcs.getAmmoOfType("CATM-120D");
    }
    return 0;
}



#
#
# F-15 throttle has weapons selector switch with
# (AFT)
# GUN
# SRM = AIM-9 (Sidewinder)
# MRM = AIM-120, AIM-7
# (FWD)

var arm_selector = func() {
    # Checks to do when changing weapons selector
    update_gun_ready();

    var stick_s = WeaponSelector.getValue();
    var selector_offset = getprop("controls/armament/selected-armament-offset");
    if ( stick_s == 0 ) {
        var p = pylons.fcs.selectWeapon("20mm Cannon");
    } elsif ( stick_s == 1 ) {
        var wps = ["AIM-9", "AIM-9X", "CATM-9X"];
        var count = 2 - selector_offset;  # length of the list (id 1 is 0 here)
        if (count < 0) {
            var selector_offset = 0;
            setprop("controls/armament/selected-armament-offset", 0);
        }
        var p = pylons.fcs.selectWeapon("");
        while (p == nil and count >= 0) {
            cur_wpn = wps[count];
            var p = pylons.fcs.selectWeapon(cur_wpn);
            setprop("sim/model/f15/systems/armament/selected-arm", cur_wpn);
            count = count -1;
        }
        if (p == nil) {
            setprop("sim/model/f15/systems/armament/selected-arm", "");
        }
    } elsif ( stick_s == 2 ) {
        var wps = ["AIM-7", "AIM-120", "AIM-120D", "CATM-120D"];
        var count = 3 - selector_offset;  # length of the list (id 1 is 0 here)
        if (count < 0) {
            var selector_offset = 0;
            setprop("controls/armament/selected-armament-offset", 0);
        }
        var p = pylons.fcs.selectWeapon("");
        while (p == nil and count >= 0) {
            cur_wpn = wps[count];
            var p = pylons.fcs.selectWeapon(cur_wpn);
            setprop("sim/model/f15/systems/armament/selected-arm", cur_wpn);
            count = count -1;
        }
        if (p == nil) {
            setprop("sim/model/f15/systems/armament/selected-arm", "");
        }
    } elsif ( stick_s == 5 ) {
        var ground_wps = ["CBU-87", "CBU-105", "MK-82AIR", "MK-82", "MK-83", "MK-84", "GBU-10", "GBU-12", "GBU-31", "AGM-158A", "AGM-154A", "AGM-88B", "AGM-84D", "AGM-65B", "AGM-65D"];
        var count = 14 - selector_offset;  # length of the list (id 1 is 0 here)
        if (count < 0) {
            var selector_offset = 0;
            setprop("controls/armament/selected-armament-offset", 0);
        }
        var p = pylons.fcs.selectWeapon("");
        while (p == nil and count >= 0) {
            cur_wpn = ground_wps[count];
            var p = pylons.fcs.selectWeapon(cur_wpn);
            setprop("sim/model/f15/systems/armament/selected-arm", cur_wpn);
            count = count -1;
        }
        if (p == nil) {
            setprop("sim/model/f15/systems/armament/selected-arm", "");
        } else {
            #print(pylons.fcs.selectWeapon(cur_wpn).type);
        }
    } else {
        pylons.fcs.selectNothing();
    }
    setCockpitLights();
    if (get_sel_missile_count() == 0) {
        setprop("sim/model/f15/systems/armament/selected-arm", "");
    }
}
setlistener(WeaponSelector, arm_selector, nil, 0);
setlistener("controls/armament/trigger", arm_selector, nil, 0);
setlistener("controls/armament/selected-armament-offset", arm_selector, nil, 0);

# System start and stop.
# Timers for weapons system status lights.
var system_start = func
{
    print("Weapons System start");
	settimer (func { GunRateHighLight.setBoolValue(1); }, 0.3);
	update_gun_ready();
	SysRunning.setBoolValue(1);
	settimer (func { SwCoolOffLight.setBoolValue(1); }, 0.6);
	settimer (func { MslPrepOffLight.setBoolValue(1); }, 2);
}

var system_stop = func
{
    print("Weapons System stop");
	GunRateHighLight.setBoolValue(0);
	SysRunning.setBoolValue(0);
    setprop("sim/model/f15/systems/armament/launch-light",0);

	settimer (func { SwCoolOffLight.setBoolValue(0);SWCoolOn.setBoolValue(0); }, 0.6);
	settimer (func { MslPrepOffLight.setBoolValue(0); }, 1.2);
}


# Controls
var masw = func(v)
{
    logprint(2,"Master arm ",v.getValue());

    if (v.getValue())
    {
        system_start();
    }
    else
    {
        system_stop();
    }
};
setlistener("sim/model/f15/controls/armament/master-arm-switch", masw);

var master_arm_cycle = func()
{
	var master_arm_switch = ArmSwitch.getValue();
    print("arm_cycle: master_arm_switch",master_arm_switch);
	if (master_arm_switch == 0)
    {
		ArmSwitch.setValue(1);
	}
    else
    {
		ArmSwitch.setValue(0);
	}
}



  ############ Cannon impact messages #####################

var hits_count = 0;
var hit_timer = nil;
var hit_callsign = "";

var Mp = props.globals.getNode("ai/models");
var valid_mp_types = {
  multiplayer: 1, tanker: 1, aircraft: 1, ship: 1, groundvehicle: 1,
};

# Find a MP aircraft close to a given point (code from the Mirage 2000)
var findmultiplayer = func(targetCoord, dist) {
  if(targetCoord == nil) return nil;

  var raw_list = Mp.getChildren();
  var SelectedMP = nil;
  foreach(var c ; raw_list)
  {
    var is_valid = c.getNode("valid");
    if(is_valid == nil or !is_valid.getBoolValue()) continue;

    var type = c.getName();

    var position = c.getNode("position");
    var name = c.getValue("callsign");
    if(name == nil or name == "") {
      # fallback, for some AI objects
      var name = c.getValue("name");
    }
    if(position == nil or name == nil or name == "" or !contains(valid_mp_types, type)) continue;

    var lat = position.getValue("latitude-deg");
    var lon = position.getValue("longitude-deg");
    var elev = position.getValue("altitude-ft") * FT2M;

    if(lat == nil or lon == nil or elev == nil) continue;

    var MpCoord = geo.Coord.new().set_latlon(lat, lon, elev);
    var tempoDist = MpCoord.direct_distance_to(targetCoord);
    if(dist > tempoDist) {
      dist = tempoDist;
      SelectedMP = name;
    }
  }
  return SelectedMP;
}

var impact_listener = func {
  var ballistic_name = getprop("/ai/models/model-impact3");
  var ballistic = props.globals.getNode(ballistic_name, 0);
  if (ballistic != nil and ballistic.getName() != "munition") {
    var typeNode = ballistic.getNode("impact/type");
    if (typeNode != nil and typeNode.getValue() != "terrain") {
      var lat = ballistic.getNode("impact/latitude-deg").getValue();
      var lon = ballistic.getNode("impact/longitude-deg").getValue();
      var elev = ballistic.getNode("impact/elevation-m").getValue();
      var impactPos = geo.Coord.new().set_latlon(lat, lon, elev);
      var target = findmultiplayer(impactPos, 80);

      if (target != nil) {
        var typeOrd = ballistic.getNode("name").getValue();

        if(target == hit_callsign) {
          # Previous impacts on same target
          hits_count += 1;
        } else {
          if(hit_timer != nil) {
            # Previous impacts on different target, flush them first
            hit_timer.stop();
            hitmessage(typeOrd);
          }
          hits_count = 1;
          hit_callsign = target;
          hit_timer = maketimer(1, func{hitmessage(typeOrd);});
          hit_timer.singleShot = 1;
          hit_timer.start();
        }
      }
    }
  }
}

var hitmessage = func(typeOrd) {
  #print("inside hitmessage");
  var phrase = typeOrd ~ " hit: " ~ hit_callsign ~ ": " ~ (hits_count*5) ~ " hits";
  if (getprop("payload/armament/msg") == TRUE) {
    print(phrase);
    #print("Second id: "~(151+armament.shells[typeOrd][0]));
    var msg = notifications.ArmamentNotification.new("mhit", 4, -1*(damage.shells[typeOrd][0]+1));
                msg.RelativeAltitude = 0;
                msg.Bearing = 0;
                msg.Distance = hits_count*5;
                msg.RemoteCallsign = hit_callsign; # RJHTODO: maybe handle flares / chaff
                notifications.hitBridgedTransmitter.NotifyAll(msg);
    damage.damageLog.push("You hit "~hit_callsign~" with "~typeOrd~", "~(hits_count*5)~" times.");
  } else {
    setprop("/sim/messages/atc", phrase);
  }
  hit_callsign = "";
  hit_timer = nil;
  hits_count = 0;
}

# setup impact listener
setlistener("/ai/models/model-impact3", impact_listener, 0, 0);

# tiny fix
setlistener("ai/submodels/submodel[5]/count", func {
    setprop("ai/submodels/submodel[6]/count", getprop("ai/submodels/submodel[5]/count"));
});

var flareCount = -1;
var flareStart = -1;

var flareLoop = func {
  # Flare release
  if (getprop("ai/submodels/submodel[5]/flare-release-snd") == nil) {
    setprop("ai/submodels/submodel[5]/flare-release-snd", 0);
    setprop("ai/submodels/submodel[5]/flare-release-out-snd", 0);
  }
  var flareOn = getprop("ai/submodels/submodel[5]/flare-release-cmd");
  if (flareOn == 1 and getprop("ai/submodels/submodel[5]/flare-release") == 0
      and getprop("ai/submodels/submodel[5]/flare-release-out-snd") == 0
      and getprop("ai/submodels/submodel[5]/flare-release-snd") == 0) {
    flareCount = getprop("ai/submodels/submodel[5]/count");
    flareStart = getprop("sim/time/elapsed-sec");
    if (flareCount > 0 and getprop("fdm/jsbsim/systems/electrics/ac-essential-bus1") > 0) {
      # release a flare
      setprop("ai/submodels/submodel[5]/flare-release-snd", 1);
      setprop("ai/submodels/submodel[5]/flare-release", 1);
      setprop("rotors/main/blade[3]/flap-deg", flareStart);
      setprop("rotors/main/blade[3]/position-deg", flareStart);
    } else {
      # play the sound for out of flares
      setprop("ai/submodels/submodel[5]/flare-release-out-snd", 1);
    }
  }
  delay = .5;
  if (getprop("ai/submodels/submodel[5]/burst")) {
    delay = .1;
  }
  if (getprop("ai/submodels/submodel[5]/flare-release-snd") == 1 and (flareStart + delay) < getprop("sim/time/elapsed-sec")) {
    setprop("ai/submodels/submodel[5]/flare-release-snd", 0);
    setprop("rotors/main/blade[3]/flap-deg", 0);
    setprop("rotors/main/blade[3]/position-deg", 0);
  }
  if (getprop("ai/submodels/submodel[5]/flare-release-out-snd") == 1 and (flareStart + delay) < getprop("sim/time/elapsed-sec")) {
    setprop("ai/submodels/submodel[5]/flare-release-out-snd", 0);
  }
  if (flareCount > getprop("ai/submodels/submodel[5]/count")) {
    # A flare was released in last loop, we stop releasing flares, so user have to press button again to release new.
    setprop("ai/submodels/submodel[5]/flare-release", 0);
    flareCount = -1;
  }
  settimer(flareLoop, 0.1);
};

flareLoop();

# damage already listens to this, but wont work since its aliased, so we gotta listen to what its aliased to also:
setlistener("sim/model/f15/systems/armament/mp-messaging", func {damage.damageLog.push("Damage is now "~(getprop("sim/model/f15/systems/armament/mp-messaging")?"ON.":"OFF."));}, 1, 0);
