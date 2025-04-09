#
#
# TODO:
#

var fcs = nil;
var pylonI  = nil;
#var pylon1  = nil;
var pylon2a = nil;
var pylon2b = nil;
var pylon2c = nil;
var pylon3  = nil;
var pylon4  = nil;
var pylon5  = nil;
var pylon6  = nil;
var pylon7  = nil;
var pylon8a = nil;
var pylon8b = nil;
var pylon8c = nil;
#var pylon9  = nil;
var pylonex1a = nil;
var pylonex1b = nil;
var pylonex1c = nil;
var pylonex2a = nil;
var pylonex2b = nil;
var pylonex2c = nil;
var pylonnav = nil;

var nav = stations.Submodel.new("AN/AAQ-13 LANTIRN Nav Pod", "AAQ-13", "/sim/model/f15/stores/nav-mounted");

var msgA = "If you need to repair now, then use Menu-Location-SelectAirport instead.";
var msgB = "Please land before changing payload.";
var msgC = "Please land before refueling.";

var cannon = stations.SubModelWeapon.new("20mm Cannon", 0.254, 135, [4], [3], props.globals.getNode("sim/model/f15/systems/gun/running",1), 0, func{return getprop("sim/model/f15/systems/gun/ready") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},0);
cannon.typeShort = "GUN";
cannon.brevity = "Guns guns";

#var fuelTank600Left   = stations.FuelTank.new("L External", "TK600", 5, 600, "sim/model/f15/wingtankL");
#var fuelTank600Center = stations.FuelTank.new("C External", "TK600", 7, 600, "sim/model/f15/wingtankC");
#var fuelTank600Right  = stations.FuelTank.new("R External", "TK600", 6, 600, "sim/model/f15/wingtankR");

var smokewinderWhite2a = stations.Submodel.new("Smokewinder White", "SmokeW", "sim/model/f15/fx/smoke-mnt-left");
var smokewinderWhite8c = stations.Submodel.new("Smokewinder White", "SmokeW", "sim/model/f15/fx/smoke-mnt-right");

var pylonSets = {
	empty: {name: "Empty", content: [], fireOrder: [], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 1},
	mm20:  {name: "20mm Cannon", content: [cannon], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},

    g10:  {name: "GBU-10", content: ["GBU-10"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 2},
    m84:  {name: "MK-84", content: ["MK-84"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	doublem84:  {name: "2 x MK-84", content: ["MK-84", "MK-84"], fireOrder: [0,1], launcherDragArea: 0.0, launcherMass: 30, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	triplem84:  {name: "3 x MK-84", content: ["MK-84", "MK-84", "MK-84"], fireOrder: [0,1,2], launcherDragArea: 0.0, launcherMass: 30, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	mk82air:  {name: "3 x MK-82 AIR", content: ["MK-82AIR", "MK-82AIR", "MK-82AIR"], fireOrder: [0,1,2], launcherDragArea: 0.0, launcherMass: 20, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	mk82:  {name: "3 x MK-82", content: ["MK-82", "MK-82", "MK-82"], fireOrder: [0,1,2], launcherDragArea: 0.0, launcherMass: 20, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},

    # 340 = outer pylon
	smokeWL: {name: "Smokewinder White", content: [smokewinderWhite2a], fireOrder: [0], launcherDragArea: -0.05, launcherMass: 53+340, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},
	smokeWR: {name: "Smokewinder White", content: [smokewinderWhite8c], fireOrder: [0], launcherDragArea: -0.05, launcherMass: 53+340, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},

#	fuel600L: {name: "Droptank", content: [fuelTank600Left], fireOrder: [0], launcherDragArea: 0.35, launcherMass: 271, launcherJettisonable: 1, showLongTypeInsteadOfCount: 1, category: 2},
#   fuel600C: {name: "Droptank", content: [fuelTank600Center], fireOrder: [0], launcherDragArea: 0.35, launcherMass: 271, launcherJettisonable: 1, showLongTypeInsteadOfCount: 1, category: 2},
#	fuel600R: {name: "Droptank", content: [fuelTank600Right], fireOrder: [0], launcherDragArea: 0.35, launcherMass: 271, launcherJettisonable: 1, showLongTypeInsteadOfCount: 1, category: 2},

    # A/A weapons for fuselage pylons:
	aim9:    {name: "AIM-9L Sidewinder",   content: ["AIM-9"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 10, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},
	aim9x:   {name: "AIM-9X Block I Sidewinder",   content: ["AIM-9X"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 10, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},
	aim7:    {name: "AIM-7F Sparrow",   content: ["AIM-7"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 30, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},
	aim120:  {name: "AIM-120B AMRAAM", content: ["AIM-120"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 30, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},
	aim120d:  {name: "AIM-120D AMRAAM", content: ["AIM-120D"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 30, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},
	doubleaim120d:   {name: "2 x AIM-120D AMRAAM", content: ["AIM-120D", "AIM-120D"], fireOrder: [0, 1], launcherDragArea: 0.0, launcherMass: 25, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 1},

    # A/A weapons for wing pylons: (launchermass is calculated in jsbsim pointmass weight 13 & 14)
    aim9w:    {name: "AIM-9L Sidewinder",   content: ["AIM-9"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},
    aim9xw:   {name: "AIM-9X Block I Sidewinder",   content: ["AIM-9X"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},
	doubleaim9xw:   {name: "2 x AIM-9X Block I Sidewinder", content: ["AIM-9X", "AIM-9X"], fireOrder: [0, 1], launcherDragArea: 0.0, launcherMass: 15, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 1},
    aim7w:    {name: "AIM-7F Sparrow",   content: ["AIM-7"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},
    aim120w:  {name: "AIM-120B AMRAAM", content: ["AIM-120"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},
    aim120dw:  {name: "AIM-120D AMRAAM", content: ["AIM-120D"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},

    # Navigation and targeting fuselage-mounted pods
    lantirnnav:   {name: "AN/AAQ-13 LANTIRN Nav Pod", content: [nav], fireOrder: [0], launcherDragArea: 0.1, launcherMass: 451.1, launcherJettisonable: 0, weaponJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},
};

# sets. The first in the list is the default. Earlier in the list means higher up in dropdown menu.
# These are not strictly needed in F-15 beside from the Empty, since it uses a custom payload dialog, but there for good measure.
if (getprop("sim/model/f15/variant") == "E") { # EX variant has different pylons and configuration than C and D variants
	#var pylon1set = [pylonSets.empty];

	var pylonex1aset = [pylonSets.empty, pylonSets.aim9xw, pylonSets.aim120dw];
	var pylonex1bset = [pylonSets.empty, pylonSets.doubleaim9xw, pylonSets.doubleaim120d];
	var pylonex1cset = [pylonSets.empty, pylonSets.aim9xw, pylonSets.aim120dw];

	var pylon2aset = [pylonSets.empty, pylonSets.aim9w, pylonSets.aim9xw, pylonSets.aim120dw];
	var pylon2bset = [pylonSets.empty, pylonSets.doublem84, pylonSets.doubleaim9xw, pylonSets.doubleaim120d];
	var pylon2cset = [pylonSets.empty, pylonSets.aim9w, pylonSets.aim9xw, pylonSets.aim120dw];

	var pylon3set = [pylonSets.empty, pylonSets.aim7, pylonSets.aim120d, pylonSets.doubleaim120d, pylonSets.mk82, pylonSets.mk82air];
	var pylon4set = [pylonSets.empty, pylonSets.aim7, pylonSets.aim120d, pylonSets.doubleaim120d, pylonSets.mk82, pylonSets.mk82air];

	var pylon5set = [pylonSets.empty, pylonSets.triplem84];

	var pylon6set = [pylonSets.empty, pylonSets.aim7, pylonSets.aim120d, pylonSets.doubleaim120d, pylonSets.mk82, pylonSets.mk82air];
	var pylon7set = [pylonSets.empty, pylonSets.aim7, pylonSets.aim120d, pylonSets.doubleaim120d, pylonSets.mk82, pylonSets.mk82air];

	var pylon8aset = [pylonSets.empty, pylonSets.aim9w, pylonSets.aim9xw, pylonSets.aim120dw];
	var pylon8bset = [pylonSets.empty, pylonSets.doublem84, pylonSets.doubleaim9xw, pylonSets.doubleaim120d];
	var pylon8cset = [pylonSets.empty, pylonSets.aim9w, pylonSets.aim9xw, pylonSets.aim120dw];

	var pylonex2aset = [pylonSets.empty, pylonSets.aim9xw, pylonSets.aim120dw];
	var pylonex2bset = [pylonSets.empty, pylonSets.doubleaim9xw, pylonSets.doubleaim120d];
	var pylonex2cset = [pylonSets.empty, pylonSets.aim9xw, pylonSets.aim120dw];

	var pylonnavset = [pylonSets.empty, pylonSets.lantirnnav];

	#var pylon9set = [pylonSets.empty];
} else {
	#var pylon1set = [pylonSets.empty];
	var pylon2aset = [pylonSets.empty, pylonSets.aim9w, pylonSets.aim120w];
	var pylon2bset = [pylonSets.empty, pylonSets.m84, pylonSets.g10];
	var pylon2cset = [pylonSets.empty, pylonSets.aim9w, pylonSets.aim120w];
	var pylon3set = [pylonSets.empty, pylonSets.m84, pylonSets.aim7, pylonSets.aim120];
	var pylon4set = [pylonSets.empty, pylonSets.m84, pylonSets.aim7, pylonSets.aim120];
	var pylon5set = [pylonSets.empty, pylonSets.m84, pylonSets.g10];
	var pylon6set = [pylonSets.empty, pylonSets.m84, pylonSets.aim7, pylonSets.aim120];
	var pylon7set = [pylonSets.empty, pylonSets.m84, pylonSets.aim7, pylonSets.aim120];
	var pylon8aset = [pylonSets.empty, pylonSets.aim9w, pylonSets.aim120w];
	var pylon8bset = [pylonSets.empty, pylonSets.m84, pylonSets.g10,];
	var pylon8cset = [pylonSets.empty, pylonSets.aim9w, pylonSets.aim120w];
	#var pylon9set = [pylonSets.empty];
}

# pylons
pylonI = stations.InternalStation.new("Internal Gun Station", 17, [pylonSets.mm20], props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[18]",1));
pylon2a= stations.Pylon.new("Left Wing Station 2",       0, [1.7844, -3.3325, 0.288],  pylon2aset,  0, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[0]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[0]",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
pylon2b= stations.WPylon.new("Left Wing Station 2",      1, [1.4077, -2.8034, 1.4077], pylon2bset,  1, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs-sta-2b-weaps",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft-sta-2b-weaps",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
pylon2c= stations.Pylon.new("Left Wing Station 2",       2, [1.7844, -3.3325, 0.288],  pylon2cset,  2, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[2]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[2]",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
pylon3 = stations.Pylon.new("Left Body Station 3",       3, [-0.3003, 1.611, 0.567],   pylon3set,  3, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[3]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[3]",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
pylon4 = stations.Pylon.new("Left Body Station 4",       4, [3.5918, 1.611, 0.567],    pylon4set,  4, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[4]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[4]",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
pylon5 = stations.WPylon.new("Center Station 5",         5, [0, 0, 0.33],              pylon5set,  5, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs-sta-5-weaps",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft-sta-5-weaps",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
pylon6 = stations.Pylon.new("Right Body Station 6",      6, [-0.3003, 1.611, 0.567],   pylon6set,  6, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[6]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[6]",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
pylon7 = stations.Pylon.new("Right Body Station 7",      7, [3.5918, 1.611, 0.567],    pylon7set,  7, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[7]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[7]",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
pylon8a= stations.Pylon.new("Right Wing Station 8",      8, [1.7844, 3.3325, 0.288],   pylon8aset, 8, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[8]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[8]",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
pylon8b= stations.WPylon.new("Right Wing Station 8",     9, [1.4077, 2.8034, 1.407],   pylon8bset, 9, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs-sta-8b-weaps",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft-sta-8b-weaps",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
pylon8c= stations.Pylon.new("Right Wing Station 8",     10, [1.7844, 3.3325, 0.288],   pylon8cset, 10, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[10]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[10]",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});

# EX supplementary pylons
if (getprop("sim/model/f15/variant") == "E") {
	pylonex1a= stations.Pylon.new("Left Wing Station 11",       11, [2.4044, -3.4575, 0.288],  pylonex1aset,  11, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[19]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[19]",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
	pylonex1b= stations.WPylon.new("Left Wing Station 12",      12, [2.0277, -2.9284, 1.4077], pylonex1bset,  12, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs-sta-1bx-weaps",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft-sta-1bx-weaps",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
	pylonex1c= stations.Pylon.new("Left Wing Station 13",       13, [2.4044, -3.4575, 0.288],  pylonex1cset,  13, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[20]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[20]",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
	pylonex2a= stations.Pylon.new("Left Wing Station 14",       14, [2.4044, 3.4575, 0.288],  pylonex2aset,  14, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[21]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[21]",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
	pylonex2b= stations.WPylon.new("Left Wing Station 15",      15, [2.0277, 2.9284, 1.4077], pylonex2bset,  15, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs-sta-2bx-weaps",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft-sta-2bx-weaps",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
	pylonex2c= stations.Pylon.new("Left Wing Station 16",       16, [2.4044, 3.4575, 0.288],  pylonex2cset,  16, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[22]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[22]",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
	pylonnav = stations.Pylon.new("Right Fuselage Station",      18, [3.5918, 1.611, 0.567],   pylonnavset,  18, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[23]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[23]",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
}

pylon2a.forceRail = 1;# set the missiles mounted on these pylon always on a rail.
pylon2c.forceRail = 1;
pylon8a.forceRail = 1;
pylon8c.forceRail = 1;
if (getprop("sim/model/f15/variant") == "E") { # EX variant
	pylonex1a.forceRail = 1;
	pylonex1c.forceRail = 1;
	pylonex2a.forceRail = 1;
	pylonex2c.forceRail = 1;
}

# EX variant
if (getprop("sim/model/f15/variant") == "E") {
	var pylons = [pylonI,pylon2a,pylon2b,pylon2c,pylon3,pylon4,pylon5,pylon6,pylon7,pylon8a,pylon8b,pylon8c, pylonex1a, pylonex1b, pylonex1c, pylonex2a, pylonex2b, pylonex2c, pylonnav];
} else {
	var pylons = [pylonI,pylon2a,pylon2b,pylon2c,pylon3,pylon4,pylon5,pylon6,pylon7,pylon8a,pylon8b,pylon8c];
}

# The order of first vector in this line is the default pylon order weapons is released in.
# The order of second vector in this line is the order cycle key would cycle through the weapons (since F15 doesn't use the cycle option that order is not important):
fcs = fc.FireControl.new(pylons, [0,6,1,11,3,9,2,10,4,7,5,8,12,13,14,15,16,17, 18], ["20mm Cannon","AIM-9","AIM-9X","AIM-7","AIM-120","AIM-120D","MK-84", "GBU-10", "MK-82AIR", "MK-82"]);

if (getprop("sim/model/f15/variant") == "E") { # EX variant only
	var aimListener = func (obj) {
		# If auto focus on missile is activated the we call the function
		if(getprop("/controls/armament/automissileview"))
		{
		    viewMissile.view_firing_missile(obj);
			print("Missile view engaged!");
		}

		# Allow TTI to be updated if the fired ordonance has 2-way data link (AIM-120D)
		viewMissile.missile_coords_feeder(obj);
	};

	pylonex1a.setAIMListener(aimListener);
	pylonex1b.setAIMListener(aimListener);
	pylonex1c.setAIMListener(aimListener);

	pylon2a.setAIMListener(aimListener);
	pylon2b.setAIMListener(aimListener);
	pylon2c.setAIMListener(aimListener);

	pylon3.setAIMListener(aimListener);
	pylon4.setAIMListener(aimListener);

	pylon5.setAIMListener(aimListener);

	pylon6.setAIMListener(aimListener);
	pylon7.setAIMListener(aimListener);

	pylon8a.setAIMListener(aimListener);
	pylon8b.setAIMListener(aimListener);
	pylon8c.setAIMListener(aimListener);

	pylonex2a.setAIMListener(aimListener);
	pylonex2b.setAIMListener(aimListener);
	pylonex2c.setAIMListener(aimListener);
}

var callback = func (aim = nil) {
    # after something has changed in pylon system, this will make MPCD update its A/A and A/G pages:
    setprop("sim/model/f15/controls/armament/weapons-updated", getprop("sim/model/f15/controls/armament/weapons-updated")+1);
}
var callbackClass = func (aim = nil) {
    if (aim != nil and aim.type == "AIM-120") {
        settimer(func selectNextOfSameClass("AIM-7"), 0.5);
    } elsif (aim != nil and aim.type == "AIM-7") {
        settimer(func selectNextOfSameClass("AIM-120"), 0.5);
    }
}
var callbackClassG = func (aim = nil) {
    if (aim != nil and aim.type == "GBU-10") {
        settimer(func selectNextOfSameClass("MK-84"), 0.5);
    } elsif (aim != nil and aim.type == "MK-84") {
        settimer(func selectNextOfSameClass("GBU-10"), 0.5);
    }
}

var selectNextOfSameClass = func (type) {
    # to avoid cyclic callstack this method is called delayed. Also due to callbackClass can be called before next has been selected.
    if (fcs.getSelectedWeapon() == nil) {
        fcs.selectWeapon(type);
    }
}

#for (var j = 1;j<12;j+=1) {
#    if (j==2 or j==6 or j==10) {
#        pylons[j].setAIMListener(callbackClassG);
#    } else {
#        pylons[j].setAIMListener(callbackClass);
#    }
#    pylons[j].guiChanged();# update the pylons to whatever startup stores should be loaded.
#}
#fcs.setChangeListener(callback);

#print("** Pylon & fire control system started. **");
var getDLZ = func {
    if (fcs != nil and getprop("controls/armament/master-arm")) {
        var w = fcs.getSelectedWeapon();
        if (w!=nil and w.parents[0] == armament.AIM) {
            var result = w.getDLZ(1);
            if (result != nil and size(result) == 8 and result[4]<result[0]*1.5 and armament.contact != nil and armament.contact.get_display()) {
                #target is within 150% of max weapon fire range.
        	    return result;
            }
        }
    }
    return nil;
}

var getCCIP = func {
    if (fcs != nil and getprop("controls/armament/master-arm")) {
        var w = fcs.getSelectedWeapon();
        if (w!=nil and w.parents[0] == armament.AIM) {
            if (w.type=="MK-84") {
                # 20s fall time limit and calculate fall trajectory at every 0.20s on the way to ground.
                return w.getCCIPadv(20, 0.20);
            } elsif (w.type=="GBU-10") {
                # 35s fall time limit and calculate fall trajectory at every 0.30s on the way to ground.
                return w.getCCIPadv(35, 0.30);
            } elsif (w.type=="MK-82AIR") {
                # 45s fall time limit and calculate fall trajectory at every .15s on the way to ground.
                return w.getCCIPadv(45, .15);
            } elsif (w.type=="MK-82") {
                # 25s fall time limit and calculate fall trajectory at every .20s on the way to ground.
                return w.getCCIPadv(25, .20);
            }
        }
    }
    return nil;
}

var reloadCannon = func {
    setprop("ai/submodels/submodel[5]/count", 100);
    setprop("ai/submodels/submodel[6]/count", 100);#flares
    cannon.reloadAmmo();
    setprop("/systems/gun/rounds",675);
}

# reload cannon only
var cannon_load = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {
        reloadCannon();
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

# Clean configuration
var clean = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

        pylon2a.loadSet(pylonSets.empty);
        pylon2b.loadSet(pylonSets.empty);
        pylon2c.loadSet(pylonSets.empty);
        pylon3.loadSet(pylonSets.empty);
        pylon4.loadSet(pylonSets.empty);
        pylon5.loadSet(pylonSets.empty);
        pylon6.loadSet(pylonSets.empty);
        pylon7.loadSet(pylonSets.empty);
        pylon8a.loadSet(pylonSets.empty);
        pylon8b.loadSet(pylonSets.empty);
        pylon8c.loadSet(pylonSets.empty);
        reloadCannon();
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

# Standard combat configuration
var standard = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

        pylon2a.loadSet(pylonSets.aim120w);
        pylon2b.loadSet(pylonSets.empty);
        pylon2c.loadSet(pylonSets.aim9w);
        pylon3.loadSet(pylonSets.aim7);
        pylon4.loadSet(pylonSets.aim120);
        pylon5.loadSet(pylonSets.empty);
        pylon6.loadSet(pylonSets.aim120);
        pylon7.loadSet(pylonSets.aim7);
        pylon8a.loadSet(pylonSets.aim9w);
        pylon8b.loadSet(pylonSets.empty);
        pylon8c.loadSet(pylonSets.aim120w);
        reloadCannon();
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var counter = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

        pylon2a.loadSet(pylonSets.aim9w);
        pylon2b.loadSet(pylonSets.empty);
        pylon2c.loadSet(pylonSets.aim9w);
        pylon3.loadSet(pylonSets.aim120);
        pylon4.loadSet(pylonSets.aim120);
        pylon5.loadSet(pylonSets.empty);
        pylon6.loadSet(pylonSets.aim120);
        pylon7.loadSet(pylonSets.aim120);
        pylon8a.loadSet(pylonSets.aim9w);
        pylon8b.loadSet(pylonSets.empty);
        pylon8c.loadSet(pylonSets.aim9w);
        reloadCannon();
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var nofly = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

        pylon2a.loadSet(pylonSets.aim120w);
        pylon2b.loadSet(pylonSets.empty);
        pylon2c.loadSet(pylonSets.aim9w);
        pylon3.loadSet(pylonSets.aim7);
        pylon4.loadSet(pylonSets.aim7);
        pylon5.loadSet(pylonSets.empty);
        pylon6.loadSet(pylonSets.aim7);
        pylon7.loadSet(pylonSets.aim7);
        pylon8a.loadSet(pylonSets.aim9w);
        pylon8b.loadSet(pylonSets.empty);
        pylon8c.loadSet(pylonSets.aim120w);
        reloadCannon();
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var ferry = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

        pylon2a.loadSet(pylonSets.empty);
        pylon2b.loadSet(pylonSets.empty);
        pylon2c.loadSet(pylonSets.empty);
        pylon3.loadSet(pylonSets.empty);
        pylon4.loadSet(pylonSets.empty);
        pylon5.loadSet(pylonSets.empty);
        pylon6.loadSet(pylonSets.empty);
        pylon7.loadSet(pylonSets.empty);
        pylon8a.loadSet(pylonSets.empty);
        pylon8b.loadSet(pylonSets.empty);
        pylon8c.loadSet(pylonSets.empty);
        reloadCannon();
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var super = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

        pylon2a.loadSet(pylonSets.aim120w);
        pylon2b.loadSet(pylonSets.empty);
        pylon2c.loadSet(pylonSets.aim120w);
        pylon3.loadSet(pylonSets.aim120);
        pylon4.loadSet(pylonSets.aim120);
        pylon5.loadSet(pylonSets.empty);
        pylon6.loadSet(pylonSets.aim120);
        pylon7.loadSet(pylonSets.aim120);
        pylon8a.loadSet(pylonSets.aim120w);
        pylon8b.loadSet(pylonSets.empty);
        pylon8c.loadSet(pylonSets.aim120w);
        reloadCannon();
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var ground = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

        pylon2a.loadSet(pylonSets.aim120w);
        pylon2b.loadSet(pylonSets.m84);
        pylon2c.loadSet(pylonSets.aim120w);
        pylon3.loadSet(pylonSets.empty);
        pylon4.loadSet(pylonSets.empty);
        pylon5.loadSet(pylonSets.m84);
        pylon6.loadSet(pylonSets.empty);
        pylon7.loadSet(pylonSets.empty);
        pylon8a.loadSet(pylonSets.aim120w);
        pylon8b.loadSet(pylonSets.m84);
        pylon8c.loadSet(pylonSets.aim120w);
        reloadCannon();
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var patrol = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

        pylon2a.loadSet(pylonSets.aim9w);
        pylon2b.loadSet(pylonSets.empty);
        pylon2c.loadSet(pylonSets.aim120w);
        pylon3.loadSet(pylonSets.aim120);
        pylon4.loadSet(pylonSets.aim120);
        pylon5.loadSet(pylonSets.empty);
        pylon6.loadSet(pylonSets.aim120);
        pylon7.loadSet(pylonSets.aim120);
        pylon8a.loadSet(pylonSets.aim120w);
        pylon8b.loadSet(pylonSets.empty);
        pylon8c.loadSet(pylonSets.aim9w);
        reloadCannon();
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var train = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

        pylon2a.loadSet(pylonSets.aim120w);
        pylon2b.loadSet(pylonSets.empty);
        pylon2c.loadSet(pylonSets.aim9w);
        pylon3.loadSet(pylonSets.empty);
        pylon4.loadSet(pylonSets.empty);
        pylon5.loadSet(pylonSets.empty);
        pylon6.loadSet(pylonSets.empty);
        pylon7.loadSet(pylonSets.empty);
        pylon8a.loadSet(pylonSets.aim9w);
        pylon8b.loadSet(pylonSets.empty);
        pylon8c.loadSet(pylonSets.aim120w);
        reloadCannon();
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var bore_loop = func {
    #enables firing of aim9 without radar. The aim-9 seeker will be fixed 3.5 degs below bore and any aircraft the gets near that will result in lock.
    bore = 0;
    if (fcs != nil) {
        var standby = getprop("instrumentation/radar/radar-standby");
        var aim = fcs.getSelectedWeapon();
        if (aim != nil and (aim.type == "AIM-9" or aim.type == "AIM-9X")) {
            if (standby == 1) {
                #aim.setBore(1);
                aim.setContacts(awg_9.completeList);
                aim.commandDir(0,-3.5);# the real is bored to -6 deg below real bore
                bore = 1;
            } else {
                aim.commandRadar();
                aim.setContacts([]);
            }
        }
    }
    settimer(bore_loop, 0.5);
};
var bore = 0;
if (fcs!=nil) {
    bore_loop();
}
