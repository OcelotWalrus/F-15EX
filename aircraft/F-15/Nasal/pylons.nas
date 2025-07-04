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
var pylontgp = nil;
var pyloncft1 = nil;
var pyloncft2 = nil;
var pyloncft3 = nil;
var pyloncft4 = nil;
var pyloncft5 = nil;
var pyloncft6 = nil;

var nav = stations.Submodel.new("AN/AAQ-13 LANTIRN Nav Pod", "AAQ-13", "/sim/model/f15/stores/nav-mounted");
var tgp = stations.Submodel.new("AN/AAQ-14 LANTIRN Target Pod", "AAQ-14", "sim/model/f15/stores/tgp-mounted");
var atp = stations.Submodel.new("AN/AAQ-33 Sniper XR", "AAQ-33", "sim/model/f15/stores/tgp-mounted");
var irst = stations.Submodel.new("Legion Pod (IRST)", "IRST", "sim/model/f15/stores/irst-mounted");

var ecm184 = stations.Submodel.new("AN/ALQ-184(V) ECM Pod", "AL184", "sim/model/f15/stores/ecm-mounted");

var msgA = "If you need to repair now, then use Menu-Location-SelectAirport instead.";
var msgB = "Please land before changing payload.";
var msgC = "Please land before refueling.";

var cannon = stations.SubModelWeapon.new("20mm Cannon", 0.254, 185, [4], [3], props.globals.getNode("sim/model/f15/systems/gun/running",1), 0, func{return getprop("sim/model/f15/systems/gun/ready") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},0);
cannon.typeShort = "GUN";
cannon.brevity = "Guns guns";

var hyd70lh1 = stations.SubModelWeapon.new("LAU-68C", 23.6, 7, [7], [], props.globals.getNode("fdm/jsbsim/fcs/hydra1ltrigger",1), 1, func{return getprop("payload/armament/fire-control/serviceable") and getprop("controls/armament/master-arm") == 1;},1);
hyd70lh1.typeShort = "M151";
hyd70lh1.brevity = "Rockets away";
var hyd70ch1 = stations.SubModelWeapon.new("LAU-68C", 23.6, 7, [8], [], props.globals.getNode("fdm/jsbsim/fcs/hydra1ctrigger",1), 1, func{return getprop("payload/armament/fire-control/serviceable") and getprop("controls/armament/master-arm") == 1;},1);
hyd70ch1.typeShort = "M151";
hyd70ch1.brevity = "Rockets away";
var hyd70rh1 = stations.SubModelWeapon.new("LAU-68C", 23.6, 7, [9], [], props.globals.getNode("fdm/jsbsim/fcs/hydra1rtrigger",1), 1, func{return getprop("payload/armament/fire-control/serviceable") and getprop("controls/armament/master-arm") == 1;},1);
hyd70rh1.typeShort = "M151";
hyd70rh1.brevity = "Rockets away";
var hyd70lh9 = stations.SubModelWeapon.new("LAU-68C", 23.6, 7, [10], [], props.globals.getNode("fdm/jsbsim/fcs/hydra9ltrigger",1), 1, func{return getprop("payload/armament/fire-control/serviceable") and getprop("controls/armament/master-arm") == 1;},1);
hyd70lh9.typeShort = "M151";
hyd70lh9.brevity = "Rockets away";
var hyd70ch9 = stations.SubModelWeapon.new("LAU-68C", 23.6, 7, [11], [], props.globals.getNode("fdm/jsbsim/fcs/hydra9ctrigger",1), 1, func{return getprop("payload/armament/fire-control/serviceable") and getprop("controls/armament/master-arm") == 1;},1);
hyd70ch9.typeShort = "M151";
hyd70ch9.brevity = "Rockets away";
var hyd70rh9 = stations.SubModelWeapon.new("LAU-68C", 23.6, 7, [12], [], props.globals.getNode("fdm/jsbsim/fcs/hydra9rtrigger",1), 1, func{return getprop("payload/armament/fire-control/serviceable") and getprop("controls/armament/master-arm") == 1;},1);
hyd70rh9.typeShort = "M151";
hyd70rh9.brevity = "Rockets away";

#var fuelTank600Left   = stations.FuelTank.new("L External", "TK600", 5, 600, "sim/model/f15/wingtankL");
#var fuelTank600Center = stations.FuelTank.new("C External", "TK600", 7, 600, "sim/model/f15/wingtankC");
#var fuelTank600Right  = stations.FuelTank.new("R External", "TK600", 6, 600, "sim/model/f15/wingtankR");

var smokewinderWhite2a = stations.Submodel.new("AN-T-17 Smokewinder", "SmokeW", "sim/model/f15/fx/smoke-mnt-left");
var smokewinderWhite8c = stations.Submodel.new("AN-T-17 Smokewinder", "SmokeW", "sim/model/f15/fx/smoke-mnt-right");

var pylonSets = {
	empty: {name: "Empty", content: [], fireOrder: [], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 1},
	mm20:  {name: "20mm Cannon", content: [cannon], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},

    g10:  {name: "GBU-10", content: ["GBU-10"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 2},
    m84:  {name: "MK-84", content: ["MK-84"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	singlem84:  {name: "1 x MK-84", content: ["MK-84"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	doublem84:  {name: "2 x MK-84", content: ["MK-84", "MK-84"], fireOrder: [0,1], launcherDragArea: 0.0, launcherMass: 30, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	triplem84:  {name: "3 x MK-84", content: ["MK-84", "MK-84", "MK-84"], fireOrder: [0,1,2], launcherDragArea: 0.0, launcherMass: 30, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	mk82air:  {name: "3 x MK-82 AIR", content: ["MK-82AIR", "MK-82AIR", "MK-82AIR"], fireOrder: [0,1,2], launcherDragArea: 0.0, launcherMass: 20, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	mk82:  {name: "3 x MK-82", content: ["MK-82", "MK-82", "MK-82"], fireOrder: [0,1,2], launcherDragArea: 0.0, launcherMass: 20, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	mk83:  {name: "1 x MK-83", content: ["MK-83"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	triplemk83:  {name: "3 x MK-83", content: ["MK-83", "MK-83", "MK-83"], fireOrder: [0,1,2], launcherDragArea: 0.0, launcherMass: 25, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	triplecbu87:  {name: "3 x CBU-87", content: ["CBU-87", "CBU-87", "CBU-87"], fireOrder: [0,1,2], launcherDragArea: 0.0, launcherMass: 25, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	doublecbu105:  {name: "2 x CBU-105", content: ["CBU-105", "CBU-105"], fireOrder: [0,1], launcherDragArea: 0.0, launcherMass: 25, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	doublegbu12: {name: "2 x GBU-12", content: ["GBU-12", "GBU-12"], fireOrder: [0, 1], launcherDragArea: 0.0, launcherMass: 30, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	singlegbu12: {name: "1 x GBU-12", content: ["GBU-12"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	singlegbu31: {name: "1 x GBU-31", content: ["GBU-31"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	singlegbu32: {name: "1 x GBU-32", content: ["GBU-32"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	doublegbu32: {name: "2 x GBU-32", content: ["GBU-32", "GBU-32"], fireOrder: [0, 1], launcherDragArea: 0.0, launcherMass: 20, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	singlecbu87:  {name: "1 x CBU-87", content: ["CBU-87"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	singlecbu105:  {name: "1 x CBU-105", content: ["CBU-105"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	singlegbu54: {name: "1 x GBU-54", content: ["GBU-54"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	doublegbu54: {name: "2 x GBU-54", content: ["GBU-54", "GBU-54"], fireOrder: [0, 1], launcherDragArea: 0.0, launcherMass: 20, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	singlegbu39: {name: "1 x GBU-39", content: ["GBU-39"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	quadgbu39: {name: "4 x GBU-39", content: ["GBU-39", "GBU-39", "GBU-39", "GBU-39"], fireOrder: [0, 1, 2, 3], launcherDragArea: 0.0, launcherMass: 50, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},

	hyd70h1:   {name: "3 x M151", pylon: "1 MAU", rack: "3 L68", content: [hyd70lh1,hyd70ch1,hyd70rh1], fireOrder: [0,1,2], launcherDragArea: 0.14, launcherMass: 625.0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
    hyd70h9:   {name: "3 x M151", pylon: "1 MAU", rack: "3 L68", content: [hyd70lh9,hyd70ch9,hyd70rh9], fireOrder: [0,1,2], launcherDragArea: 0.14, launcherMass: 625.0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},

	dummyaim9x:   {name: "CATM-9X Sidewinder Dummy", content: ["CATM-9X"], fireOrder: [0], launcherDragArea: 0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},
	doubledummyaim9x:   {name: "2 x CATM-9X Sidewinder Dummy", content: ["CATM-9X", "CATM-9X"], fireOrder: [0,1], launcherDragArea: 0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 1},
	dummyaim120d:   {name: "CATM-120D AMRAAM Dummy", content: ["CATM-120D"], fireOrder: [0], launcherDragArea: 0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},
	doubledummyaim120d:   {name: "2 x CATM-120D AMRAAM Dummy", content: ["CATM-120D", "CATM-120D"], fireOrder: [0,1], launcherDragArea: 0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 1},

	cftmk82: {name: "1 x MK-82", content: ["MK-82"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	cftmk82air: {name: "1 x MK-82AIR", content: ["MK-82AIR"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},

	doubleagm65b: {name: "2 x AGM-65B", content: ["AGM-65B", "AGM-65B"], fireOrder: [0, 1], launcherDragArea: 0.0, launcherMass: 15, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	tripleagm65b: {name: "3 x AGM-65B", content: ["AGM-65B", "AGM-65B", "AGM-65B"], fireOrder: [0,1,2], launcherDragArea: 0.0, launcherMass: 25, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	doubleagm65d: {name: "2 x AGM-65D", content: ["AGM-65D", "AGM-65D"], fireOrder: [0,1], launcherDragArea: 0, launcherMass: 16, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	tripleagm65d: {name: "3 x AGM-65D", content: ["AGM-65D", "AGM-65D", "AGM-65D"], fireOrder: [0,1,2], launcherDragArea: 0.0, launcherMass: 25, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	singleagm84d: {name: "1 x AGM-84D", content: ["AGM-84D"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	singleagm84e: {name: "1 x AGM-84E", content: ["AGM-84E"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	singleagm88e: {name: "1 x AGM-88E", content: ["AGM-88E"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	singleagm154a: {name: "1 x AGM-154A", content: ["AGM-154A"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	singleagm158a: {name: "1 x AGM-158A", content: ["AGM-158A"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	singleagm158c: {name: "1 x AGM-158C", content: ["AGM-158C"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
	singleagm119a: {name: "1 x AGM-119A", content: ["AGM-119A"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},

    # 340 = outer pylon
	smokeWL: {name: "AN-T-17 Smokewinder", content: [smokewinderWhite2a], fireOrder: [0], launcherDragArea: -0.05, launcherMass: 53+340, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},
	smokeWR: {name: "AN-T-17 Smokewinder", content: [smokewinderWhite8c], fireOrder: [0], launcherDragArea: -0.05, launcherMass: 53+340, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},

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
	lantirntgp:   {name: "AN/AAQ-14 LANTIRN Target Pod", content: [tgp], fireOrder: [0], launcherDragArea: 0.07, launcherMass: 530, launcherJettisonable: 0, weaponJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},
	atpsniper:   {name: "AN/AAQ-33 Sniper XR", content: [atp], fireOrder: [0], launcherDragArea: 0.06, launcherMass: 446, launcherJettisonable: 0, weaponJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},
	podIrst:   {name: "Legion Pod (IRST)", content: [irst], fireOrder: [0], launcherDragArea: 0.08, launcherMass: 500, launcherJettisonable: 0, weaponJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1}, #mass guess based on available data

	podEcm184: {name: "AN/ALQ-184(V) ECM Pod", content: [ecm184], fireOrder: [0], launcherDragArea: 0.1, launcherMass: 705, launcherJettisonable: 0, weaponJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 2},
};

# sets. The first in the list is the default. Earlier in the list means higher up in dropdown menu.
# These are not strictly needed in F-15 beside from the Empty, since it uses a custom payload dialog, but there for good measure.
if (getprop("sim/model/f15/variant") == "EX") { # EX variant has different pylons and configuration than C and D variants
	#var pylon1set = [pylonSets.empty];

	var pylonex1aset = [pylonSets.empty, pylonSets.dummyaim9x, pylonSets.dummyaim120d, pylonSets.aim9xw, pylonSets.aim120dw];
	var pylonex1bset = [pylonSets.empty, pylonSets.doubledummyaim9x, pylonSets.doubledummyaim120d, pylonSets.doubleaim9xw, pylonSets.doubleaim120d, pylonSets.doubleagm65b, pylonSets.doubleagm65d, pylonSets.singleagm84d, pylonSets.singleagm84e, pylonSets.singleagm88e, pylonSets.singleagm119a];
	var pylonex1cset = [pylonSets.empty, pylonSets.dummyaim9x, pylonSets.dummyaim120d, pylonSets.aim9xw, pylonSets.aim120dw];

	var pylon2aset = [pylonSets.empty, pylonSets.dummyaim9x, pylonSets.dummyaim120d, pylonSets.aim9w, pylonSets.aim9xw, pylonSets.aim120dw];
	var pylon2bset = [pylonSets.empty, pylonSets.podEcm184, pylonSets.hyd70h1, pylonSets.doubledummyaim9x, pylonSets.doubledummyaim120d, pylonSets.triplemk83, pylonSets.singlem84, pylonSets.triplecbu87, pylonSets.doublecbu105, pylonSets.doublegbu12, pylonSets.singlegbu31, pylonSets.doublegbu32, pylonSets.quadgbu39, pylonSets.doublegbu54, pylonSets.doubleagm65b, pylonSets.tripleagm65b, pylonSets.doubleagm65d, pylonSets.tripleagm65d, pylonSets.singleagm84d, pylonSets.singleagm84e, pylonSets.singleagm88e, pylonSets.singleagm119a, pylonSets.singleagm154a, pylonSets.singleagm158a, pylonSets.singleagm158c, pylonSets.doubleaim9xw, pylonSets.doubleaim120d];
	var pylon2cset = [pylonSets.empty, pylonSets.smokeWL, pylonSets.dummyaim9x, pylonSets.dummyaim120d, pylonSets.aim9w, pylonSets.aim9xw, pylonSets.aim120dw];

	var pylon3set = [pylonSets.empty, pylonSets.dummyaim120d, pylonSets.doubledummyaim120d, pylonSets.aim7, pylonSets.aim120d, pylonSets.doubleaim120d, pylonSets.mk82, pylonSets.mk82air, pylonSets.mk83, pylonSets.singlem84, pylonSets.singlecbu87, pylonSets.singlecbu105, pylonSets.singlegbu12, pylonSets.singlegbu31, pylonSets.singlegbu32, pylonSets.quadgbu39, pylonSets.singlegbu54, pylonSets.singleagm154a, pylonSets.singleagm158a, pylonSets.singleagm158c];
	var pylon4set = [pylonSets.empty, pylonSets.dummyaim120d, pylonSets.doubledummyaim120d, pylonSets.aim7, pylonSets.aim120d, pylonSets.doubleaim120d, pylonSets.mk82, pylonSets.mk82air, pylonSets.mk83, pylonSets.singlem84, pylonSets.singlecbu87, pylonSets.singlecbu105, pylonSets.singlegbu12, pylonSets.singlegbu31, pylonSets.singlegbu32, pylonSets.quadgbu39, pylonSets.singlegbu54, pylonSets.singleagm154a, pylonSets.singleagm158a, pylonSets.singleagm158c];

	var pylon5set = [pylonSets.empty, pylonSets.podIrst, pylonSets.podEcm184, pylonSets.triplemk83, pylonSets.singlem84, pylonSets.triplecbu87, pylonSets.singlegbu31, pylonSets.singlegbu32, pylonSets.singleagm84d, pylonSets.singleagm84e, pylonSets.singleagm154a, pylonSets.singleagm158a, pylonSets.singleagm158c];

	var pylon6set = [pylonSets.empty, pylonSets.dummyaim120d, pylonSets.doubledummyaim120d, pylonSets.aim7, pylonSets.aim120d, pylonSets.doubleaim120d, pylonSets.mk82, pylonSets.mk82air, pylonSets.mk83, pylonSets.singlem84, pylonSets.singlecbu87, pylonSets.singlecbu105, pylonSets.singlegbu12, pylonSets.singlegbu31, pylonSets.singlegbu32, pylonSets.quadgbu39, pylonSets.singlegbu54, pylonSets.singleagm154a, pylonSets.singleagm158a, pylonSets.singleagm158c];
	var pylon7set = [pylonSets.empty, pylonSets.dummyaim120d, pylonSets.doubledummyaim120d, pylonSets.aim7, pylonSets.aim120d, pylonSets.doubleaim120d, pylonSets.mk82, pylonSets.mk82air, pylonSets.mk83, pylonSets.singlem84, pylonSets.singlecbu87, pylonSets.singlecbu105, pylonSets.singlegbu12, pylonSets.singlegbu31, pylonSets.singlegbu32, pylonSets.quadgbu39, pylonSets.singlegbu54, pylonSets.singleagm154a, pylonSets.singleagm158a, pylonSets.singleagm158c];

	var pylon8aset = [pylonSets.empty, pylonSets.smokeWR, pylonSets.dummyaim9x, pylonSets.dummyaim120d, pylonSets.aim9w, pylonSets.aim9xw, pylonSets.aim120dw];
	var pylon8bset = [pylonSets.empty, pylonSets.podEcm184, pylonSets.hyd70h9, pylonSets.doubledummyaim9x, pylonSets.doubledummyaim120d, pylonSets.triplemk83, pylonSets.singlem84, pylonSets.triplecbu87, pylonSets.doublecbu105, pylonSets.doublegbu12, pylonSets.singlegbu31, pylonSets.doublegbu32, pylonSets.quadgbu39, pylonSets.doublegbu54, pylonSets.doubleagm65b, pylonSets.tripleagm65b, pylonSets.doubleagm65d, pylonSets.tripleagm65d, pylonSets.singleagm84d, pylonSets.singleagm84e, pylonSets.singleagm88e, pylonSets.singleagm119a, pylonSets.singleagm154a, pylonSets.singleagm158a, pylonSets.singleagm158c, pylonSets.doubleaim9xw, pylonSets.doubleaim120d];
	var pylon8cset = [pylonSets.empty, pylonSets.dummyaim9x, pylonSets.dummyaim120d, pylonSets.aim9w, pylonSets.aim9xw, pylonSets.aim120dw];

	var pylonex2aset = [pylonSets.empty, pylonSets.dummyaim9x, pylonSets.dummyaim120d, pylonSets.aim9xw, pylonSets.aim120dw];
	var pylonex2bset = [pylonSets.empty, pylonSets.doubledummyaim9x, pylonSets.doubledummyaim120d, pylonSets.doubleaim9xw, pylonSets.doubleaim120d, pylonSets.doubleagm65b, pylonSets.doubleagm65d, pylonSets.singleagm84d, pylonSets.singleagm84e, pylonSets.singleagm88e, pylonSets.singleagm119a];
	var pylonex2cset = [pylonSets.empty, pylonSets.dummyaim9x, pylonSets.dummyaim120d, pylonSets.aim9xw, pylonSets.aim120dw];

	var pylonnavset = [pylonSets.empty, pylonSets.lantirnnav];
	var pylontgpset = [pylonSets.empty, pylonSets.lantirntgp, pylonSets.atpsniper];
	var pyloncftset = [pylonSets.empty, pylonSets.dummyaim120d, pylonSets.aim120d, pylonSets.cftmk82, pylonSets.cftmk82air, pylonSets.singlegbu12, pylonSets.singlegbu39, pylonSets.singlegbu54];
	var pyloncftsetcenter = [pylonSets.empty, pylonSets.cftmk82, pylonSets.cftmk82air, pylonSets.singlegbu39, pylonSets.singlegbu54];

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
if (getprop("sim/model/f15/variant") == "EX") {
	pylonex1a= stations.Pylon.new("Left Wing Station 11",       11, [2.4044, -3.4575, 0.288],  pylonex1aset,  11, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[19]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[19]",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
	pylonex1b= stations.WPylon.new("Left Wing Station 12",      12, [2.0277, -2.9284, 1.4077], pylonex1bset,  12, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs-sta-1bx-weaps",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft-sta-1bx-weaps",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
	pylonex1c= stations.Pylon.new("Left Wing Station 13",       13, [2.4044, -3.4575, 0.288],  pylonex1cset,  13, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[20]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[20]",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
	pylonex2a= stations.Pylon.new("Left Wing Station 14",       14, [2.4044, 3.4575, 0.288],  pylonex2aset,  14, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[21]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[21]",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
	pylonex2b= stations.WPylon.new("Left Wing Station 15",      15, [2.0277, 2.9284, 1.4077], pylonex2bset,  15, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs-sta-2bx-weaps",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft-sta-2bx-weaps",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
	pylonex2c= stations.Pylon.new("Left Wing Station 16",       16, [2.4044, 3.4575, 0.288],  pylonex2cset,  16, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[22]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[22]",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
	pylonnav = stations.Pylon.new("Right Fuselage Station",      18, [3.5918, 1.611, 0.567],   pylonnavset,  18, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[23]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[23]",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
	pylontgp = stations.Pylon.new("Left Fuselage Station",      19, [3.5918, -1.611, 0.567],   pylontgpset,  19, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[24]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[24]",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
	pyloncft1 = stations.Pylon.new("CFT1 Station",      20, [-0.0760, -2.0865, -0.59576],   pyloncftset,  20, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[25]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[25]",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
	pyloncft2 = stations.Pylon.new("CFT2 Station",      21, [2.4774, -2.0865, -0.59576],   pyloncftsetcenter,  21, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[26]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[26]",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
	pyloncft3 = stations.Pylon.new("CFT3 Station",      22, [5.1044, -2.0352, -0.5638],   pyloncftset,  22, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[27]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[27]",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
	pyloncft4 = stations.Pylon.new("CFT4 Station",      23, [-0.0760, 2.0865, -0.59576],   pyloncftset,  23, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[28]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[28]",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
	pyloncft5 = stations.Pylon.new("CFT5 Station",      24, [2.4774, 2.0865, -0.59576],   pyloncftsetcenter,  24, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[29]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[29]",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
	pyloncft6 = stations.Pylon.new("CFT6 Station",      25, [5.1044, 2.0865, -0.56368],   pyloncftset,  25, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[30]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[30]",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("fdm/jsbsim/systems/electrics/dc-main-bus")>20;},func{return 1;});
}

pylon2a.forceRail = 1;# set the missiles mounted on these pylon always on a rail.
pylon2c.forceRail = 1;
pylon8a.forceRail = 1;
pylon8c.forceRail = 1;
if (getprop("sim/model/f15/variant") == "EX") { # EX variant
	pylonex1a.forceRail = 1;
	pylonex1c.forceRail = 1;
	pylonex2a.forceRail = 1;
	pylonex2c.forceRail = 1;
}

# EX variant
if (getprop("sim/model/f15/variant") == "EX") {
	var pylons = [pylonI,pylon2a,pylon2b,pylon2c,pylon3,pylon4,pylon5,pylon6,pylon7,pylon8a,pylon8b,pylon8c, pylonex1a, pylonex1b, pylonex1c, pylonex2a, pylonex2b, pylonex2c, pylonnav, pylontgp, pyloncft1, pyloncft2, pyloncft3, pyloncft4, pyloncft5, pyloncft6];
} else {
	var pylons = [pylonI,pylon2a,pylon2b,pylon2c,pylon3,pylon4,pylon5,pylon6,pylon7,pylon8a,pylon8b,pylon8c];
}

# The order of first vector in this line is the default pylon order weapons is released in.
# The order of second vector in this line is the order cycle key would cycle through the weapons (since F15 doesn't use the cycle option that order is not important):
fcs = fc.FireControl.new(pylons, [11,16,13,14,12,15,0,10,2,8,1,5,9,20,23,21,24,22,25,3,7,4,6], ["20mm Cannon","LAU-68","AIM-9","AIM-9X","AIM-7","AIM-120","AIM-120D","MK-84", "GBU-10", "MK-82AIR", "MK-82", "MK-83", "CBU-87", "CBU-105", "AGM-65B", "GBU-12", "AGM-65D", "AGM-84D", "AGM-88E", "AGM-154A", "AGM-158A", "CATM-9X", "CATM-120D", "GBU-31", "GBU-32", "GBU-54", "AGM-158C", "GBU-39", "AGM-119A", "AGM-84E"]);

if (getprop("sim/model/f15/variant") == "EX") { # EX variant only
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

	pyloncft1.setAIMListener(aimListener);
	pyloncft2.setAIMListener(aimListener);
	pyloncft3.setAIMListener(aimListener);
	pyloncft4.setAIMListener(aimListener);
	pyloncft5.setAIMListener(aimListener);
	pyloncft6.setAIMListener(aimListener);
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
			} elsif (w.type=="CBU-87") {
			    # 30s fall time limit and calculate fall trajectory at every .20s on the way to ground.
				return w.getCCIPadv(30, .20);
            } elsif (w.type=="CBU-105") {
			    # 30s fall time limit and calculate fall trajectory at every .20s on the way to ground.
				return w.getCCIPadv(30, .20);
            } elsif (w.type=="MK-82") {
                # 25s fall time limit and calculate fall trajectory at every .20s on the way to ground.
                return w.getCCIPadv(25, .20);
            } elsif (w.type=="MK-83") {
                # 25s fall time limit and calculate fall trajectory at every .20s on the way to ground.
                return w.getCCIPadv(20, .20);
            } elsif (w.type=="GBU-12") {
                # 35s fall time limit and calculate fall trajectory at every 0.30s on the way to ground.
                return w.getCCIPadv(35, 0.30);
            } elsif (w.type=="GBU-31") {
                # 35s fall time limit and calculate fall trajectory at every 0.30s on the way to ground.
                return w.getCCIPadv(35, 0.30);
            } elsif (w.type=="GBU-32") {
                # 35s fall time limit and calculate fall trajectory at every 0.30s on the way to ground.
                return w.getCCIPadv(35, 0.30);
            } elsif (w.type=="GBU-54") {
                # 35s fall time limit and calculate fall trajectory at every 0.30s on the way to ground.
                return w.getCCIPadv(35, 0.30);
            } elsif (w.type=="GBU-39") {
                # 35s fall time limit and calculate fall trajectory at every 0.30s on the way to ground.
                return w.getCCIPadv(35, 0.30);
            }
        }
    }
    return nil;
}

var reloadCannon = func {
	if (getprop("sim/model/f15/variant") == "EX") {  # EX variant's got more capacity
	    setprop("ai/submodels/submodel[5]/count", 220);
	    setprop("ai/submodels/submodel[6]/count", 220);#flares
	    cannon.reloadAmmo();
	    setprop("/systems/gun/rounds",925);
        setprop("/ai/submodels/submodel[4]/count",185);
	} else {
		setprop("ai/submodels/submodel[5]/count", 100);
		setprop("ai/submodels/submodel[6]/count", 100);#flares
		cannon.reloadAmmo();
		setprop("/systems/gun/rounds",675);
	}
}

var unloadCannon = func {
	setprop("ai/submodels/submodel[5]/count", 0);
	setprop("ai/submodels/submodel[6]/count", 0);#flares
	setprop("/systems/gun/rounds",0);
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

# F-15EX Payload configuratins are different from the F-15C. All EX payload configurations have been designed by Cromha, and are not real-life configurations for the most part
var clean_ex = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.empty);

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

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.empty);
		pylontgp.loadSet(pylonSets.empty);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","Empty");
        setprop("payload/weight[5]/selected","Empty");
        setprop("payload/weight[9]/selected","Empty");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",0);
		setprop("fdm/jsbsim/propulsion/cft", 0);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        setprop("consumables/fuel/tank[7]/level-lbs",0);
        setprop("consumables/fuel/tank[8]/level-lbs",0);
        setprop("consumables/fuel/tank[9]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var clean_cft_ex = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.empty);

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

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.empty);
		pylontgp.loadSet(pylonSets.empty);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","Empty");
        setprop("payload/weight[5]/selected","Empty");
        setprop("payload/weight[9]/selected","Empty");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",0);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        setprop("consumables/fuel/tank[7]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var a_a_training_ex = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.dummyaim9x);
        pylon2b.loadSet(pylonSets.empty);
        pylon2c.loadSet(pylonSets.dummyaim9x);

        pylon3.loadSet(pylonSets.dummyaim120d);
        pylon4.loadSet(pylonSets.dummyaim120d);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.dummyaim120d);
        pylon7.loadSet(pylonSets.dummyaim120d);

        pylon8a.loadSet(pylonSets.dummyaim9x);
        pylon8b.loadSet(pylonSets.empty);
        pylon8c.loadSet(pylonSets.dummyaim9x);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.empty);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        unloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","Empty");
        setprop("payload/weight[5]/selected","Empty");
        setprop("payload/weight[9]/selected","Empty");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",0);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        setprop("consumables/fuel/tank[7]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var combat_air_patrol = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.aim120dw);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.aim120dw);

		pylon2a.loadSet(pylonSets.aim9xw);
		pylon2b.loadSet(pylonSets.empty);
		pylon2c.loadSet(pylonSets.aim9xw);

		pylon3.loadSet(pylonSets.aim120d);
		pylon4.loadSet(pylonSets.aim120d);

		pylon5.loadSet(pylonSets.empty);

		pylon6.loadSet(pylonSets.aim120d);
		pylon7.loadSet(pylonSets.aim120d);

		pylon8a.loadSet(pylonSets.aim9xw);
		pylon8b.loadSet(pylonSets.empty);
		pylon8c.loadSet(pylonSets.aim9xw);

		pylonex2a.loadSet(pylonSets.aim120dw);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.aim120dw);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","Empty");
        setprop("payload/weight[5]/selected","Empty");
        setprop("payload/weight[9]/selected","Empty");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",0);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        setprop("consumables/fuel/tank[7]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var combat_air_patrol_1bag = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.aim120dw);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.aim120dw);

		pylon2a.loadSet(pylonSets.aim9xw);
		pylon2b.loadSet(pylonSets.empty);
		pylon2c.loadSet(pylonSets.aim9xw);

		pylon3.loadSet(pylonSets.aim120d);
		pylon4.loadSet(pylonSets.aim120d);

		pylon5.loadSet(pylonSets.empty);

		pylon6.loadSet(pylonSets.aim120d);
		pylon7.loadSet(pylonSets.aim120d);

		pylon8a.loadSet(pylonSets.aim9xw);
		pylon8b.loadSet(pylonSets.empty);
		pylon8c.loadSet(pylonSets.aim9xw);

		pylonex2a.loadSet(pylonSets.aim120dw);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.aim120dw);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","Empty");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","Empty");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);  # centerline tank
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var air_sup = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.aim120dw);
		pylonex1b.loadSet(pylonSets.doubleaim120d);
		pylonex1c.loadSet(pylonSets.aim120dw);

		pylon2a.loadSet(pylonSets.aim120dw);
		pylon2b.loadSet(pylonSets.doubleaim120d);
		pylon2c.loadSet(pylonSets.aim120dw);

		pylon3.loadSet(pylonSets.doubleaim120d);
		pylon4.loadSet(pylonSets.doubleaim120d);

		pylon5.loadSet(pylonSets.empty);

		pylon6.loadSet(pylonSets.doubleaim120d);
		pylon7.loadSet(pylonSets.doubleaim120d);

		pylon8a.loadSet(pylonSets.aim120dw);
		pylon8b.loadSet(pylonSets.doubleaim120d);
		pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.aim120dw);
		pylonex2b.loadSet(pylonSets.doubleaim120d);
		pylonex2c.loadSet(pylonSets.aim120dw);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.aim120d);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.aim120d);
		pyloncft4.loadSet(pylonSets.aim120d);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.aim120d);

        reloadCannon();

		setprop("payload/weight[12]/selected","2 x AIM-120D AMRAAM");
		setprop("payload/weight[1]/selected","2 x AIM-120D AMRAAM");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","2 x AIM-120D AMRAAM");
		setprop("payload/weight[15]/selected","2 x AIM-120D AMRAAM");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);  # centerline tank
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var defensive_counter = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.empty);

		pylon2a.loadSet(pylonSets.aim9xw);
		pylon2b.loadSet(pylonSets.doubleaim9xw);
		pylon2c.loadSet(pylonSets.aim9xw);

		pylon3.loadSet(pylonSets.doubleaim120d);
		pylon4.loadSet(pylonSets.doubleaim120d);

		pylon5.loadSet(pylonSets.empty);

		pylon6.loadSet(pylonSets.doubleaim120d);
		pylon7.loadSet(pylonSets.doubleaim120d);

		pylon8a.loadSet(pylonSets.aim9xw);
		pylon8b.loadSet(pylonSets.doubleaim9xw);
		pylon8c.loadSet(pylonSets.aim9xw);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.empty);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","2 x AIM-9X Block I Sidewinder");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","2 x AIM-9X Block I Sidewinder");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);  # centerline tank
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var defensive_counter_str = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.aim120dw);
		pylonex1b.loadSet(pylonSets.doubleaim120d);
		pylonex1c.loadSet(pylonSets.aim120dw);

		pylon2a.loadSet(pylonSets.aim9xw);
		pylon2b.loadSet(pylonSets.doubleaim9xw);
		pylon2c.loadSet(pylonSets.aim9xw);

		pylon3.loadSet(pylonSets.doubleaim120d);
		pylon4.loadSet(pylonSets.doubleaim120d);

		pylon5.loadSet(pylonSets.empty);

		pylon6.loadSet(pylonSets.doubleaim120d);
		pylon7.loadSet(pylonSets.doubleaim120d);

		pylon8a.loadSet(pylonSets.aim9xw);
		pylon8b.loadSet(pylonSets.doubleaim9xw);
		pylon8c.loadSet(pylonSets.aim9xw);

		pylonex2a.loadSet(pylonSets.aim120dw);
		pylonex2b.loadSet(pylonSets.doubleaim120d);
		pylonex2c.loadSet(pylonSets.aim120dw);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.empty);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","2 x AIM-120D AMRAAM");
		setprop("payload/weight[1]/selected","2 x AIM-9X Block I Sidewinder");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","2 x AIM-9X Block I Sidewinder");
		setprop("payload/weight[15]/selected","2 x AIM-120D AMRAAM");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);  # centerline tank
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var ferry_2 = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.empty);

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

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.empty);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","Droptank");
        setprop("payload/weight[5]/selected","Empty");
        setprop("payload/weight[9]/selected","Droptank");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",1);
        setprop("consumables/fuel/tank[6]/selected",1);
        setprop("consumables/fuel/tank[7]/selected",0);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[7]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var ferry_3 = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.empty);

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

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.empty);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","Droptank");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","Droptank");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",1);
        setprop("consumables/fuel/tank[6]/selected",1);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var unguided_light = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.doubleaim120d);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.mk82);
        pylon4.loadSet(pylonSets.mk82);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.mk82);
        pylon7.loadSet(pylonSets.mk82);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.doubleaim120d);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","2 x AIM-120D AMRAAM");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","2 x AIM-120D AMRAAM");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var unguided_light_cfts = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.doubleaim120d);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.mk82);
        pylon4.loadSet(pylonSets.mk82);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.mk82);
        pylon7.loadSet(pylonSets.mk82);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.doubleaim120d);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.cftmk82);
		pyloncft2.loadSet(pylonSets.cftmk82);
		pyloncft3.loadSet(pylonSets.cftmk82);
		pyloncft4.loadSet(pylonSets.cftmk82);
		pyloncft5.loadSet(pylonSets.cftmk82);
		pyloncft6.loadSet(pylonSets.cftmk82);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","2 x AIM-120D AMRAAM");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","2 x AIM-120D AMRAAM");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var retarded = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.doubleaim120d);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.mk82air);
        pylon4.loadSet(pylonSets.mk82air);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.mk82air);
        pylon7.loadSet(pylonSets.mk82air);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.doubleaim120d);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","2 x AIM-120D AMRAAM");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","2 x AIM-120D AMRAAM");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var retarded_cfts = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.doubleaim120d);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.mk82air);
        pylon4.loadSet(pylonSets.mk82air);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.mk82air);
        pylon7.loadSet(pylonSets.mk82air);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.doubleaim120d);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.cftmk82air);
		pyloncft2.loadSet(pylonSets.cftmk82air);
		pyloncft3.loadSet(pylonSets.cftmk82air);
		pyloncft4.loadSet(pylonSets.cftmk82air);
		pyloncft5.loadSet(pylonSets.cftmk82air);
		pyloncft6.loadSet(pylonSets.cftmk82air);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","2 x AIM-120D AMRAAM");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","2 x AIM-120D AMRAAM");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var unguided_medium = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.triplemk83);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.mk83);
        pylon4.loadSet(pylonSets.mk83);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.mk83);
        pylon7.loadSet(pylonSets.mk83);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.triplemk83);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.aim120d);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.aim120d);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","3 x MK-83");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","3 x MK-83");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var unguided_heavy = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.singlem84);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.singlem84);
        pylon4.loadSet(pylonSets.singlem84);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.singlem84);
        pylon7.loadSet(pylonSets.singlem84);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.singlem84);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.aim120d);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.aim120d);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","1 x MK-84");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","1 x MK-84");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var unguided_diverse = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.triplemk83);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.mk82);
        pylon4.loadSet(pylonSets.mk82);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.mk82);
        pylon7.loadSet(pylonSets.mk82);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.singlem84);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.cftmk82air);
		pyloncft2.loadSet(pylonSets.cftmk82air);
		pyloncft3.loadSet(pylonSets.cftmk82air);
		pyloncft4.loadSet(pylonSets.cftmk82air);
		pyloncft5.loadSet(pylonSets.cftmk82air);
		pyloncft6.loadSet(pylonSets.cftmk82air);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","3 x MK-83");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","1 x MK-84");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var cluster_ecm = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.triplecbu87);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.aim120d);
        pylon4.loadSet(pylonSets.aim120d);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.aim120d);
        pylon7.loadSet(pylonSets.aim120d);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.triplecbu87);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","3 x CBU-87");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","3 x CBU-87");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var cluster_sfw = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.doublecbu105);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.aim120d);
        pylon4.loadSet(pylonSets.aim120d);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.aim120d);
        pylon7.loadSet(pylonSets.aim120d);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.doublecbu105);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","2 x CBU-105");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","2 x CBU-105");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var cluster_diverse = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.triplecbu87);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.singlecbu87);
        pylon4.loadSet(pylonSets.singlecbu105);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.singlecbu105);
        pylon7.loadSet(pylonSets.singlecbu87);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.doublecbu105);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.aim120d);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.aim120d);
		pyloncft4.loadSet(pylonSets.aim120d);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.aim120d);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","3 x CBU-87");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","2 x CBU-105");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var ag_sead = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.singleagm88e);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.podEcm184);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.empty);
        pylon4.loadSet(pylonSets.empty);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.empty);
        pylon7.loadSet(pylonSets.empty);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.singleagm88e);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.singleagm88e);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.aim120d);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.aim120d);
		pyloncft4.loadSet(pylonSets.aim120d);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.aim120d);

        reloadCannon();

		setprop("payload/weight[12]/selected","1 x AGM-88E");
		setprop("payload/weight[1]/selected","AN/ALQ-184(V) ECM Pod");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","1 x AGM-88E");
		setprop("payload/weight[15]/selected","1 x AGM-88E");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var ag_sead_diverse = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.singleagm88e);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.podEcm184);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.aim120d);
        pylon4.loadSet(pylonSets.aim120d);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.aim120d);
        pylon7.loadSet(pylonSets.aim120d);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.tripleagm65d);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.singleagm88e);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.aim120d);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.aim120d);
		pyloncft4.loadSet(pylonSets.aim120d);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.aim120d);

        reloadCannon();

		setprop("payload/weight[12]/selected","1 x AGM-88E");
		setprop("payload/weight[1]/selected","AN/ALQ-184(V) ECM Pod");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","3 x AGM-65D");
		setprop("payload/weight[15]/selected","1 x AGM-88E");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var ag_dead = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.doubleagm65d);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.podEcm184);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.aim120d);
        pylon4.loadSet(pylonSets.aim120d);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.aim120d);
        pylon7.loadSet(pylonSets.aim120d);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.singleagm88e);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.doubleagm65d);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.singlegbu54);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.singlegbu54);
		pyloncft4.loadSet(pylonSets.singlegbu54);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.singlegbu54);

        reloadCannon();

		setprop("payload/weight[12]/selected","2 x AGM-65D");
		setprop("payload/weight[1]/selected","AN/ALQ-184(V) ECM Pod");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","1 x AGM-88E");
		setprop("payload/weight[15]/selected","2 x AGM-65D");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var ag_anti_ship = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.singleagm84d);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.singleagm84d);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.aim120d);
        pylon4.loadSet(pylonSets.aim120d);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.aim120d);
        pylon7.loadSet(pylonSets.aim120d);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.singleagm84d);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.singleagm84d);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","1 x AGM-84D");
		setprop("payload/weight[1]/selected","1 x AGM-84D");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","1 x AGM-84D");
		setprop("payload/weight[15]/selected","1 x AGM-84D");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var anti_ship_penguin = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.singleagm119a);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.singleagm119a);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.aim120d);
        pylon4.loadSet(pylonSets.aim120d);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.aim120d);
        pylon7.loadSet(pylonSets.aim120d);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.singleagm119a);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.singleagm119a);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","1 x AGM-119A");
		setprop("payload/weight[1]/selected","1 x AGM-119A");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","1 x AGM-119A");
		setprop("payload/weight[15]/selected","1 x AGM-119A");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var ag_standoff_jsow = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.aim9xw);
        pylon2b.loadSet(pylonSets.singleagm154a);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.aim120d);
        pylon4.loadSet(pylonSets.aim120d);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.aim120d);
        pylon7.loadSet(pylonSets.aim120d);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.singleagm154a);
        pylon8c.loadSet(pylonSets.aim9xw);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","1 x AGM-154A");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","1 x AGM-154A");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var sdb_light = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.aim9xw);
        pylon2b.loadSet(pylonSets.quadgbu39);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.aim120d);
        pylon4.loadSet(pylonSets.aim120d);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.aim120d);
        pylon7.loadSet(pylonSets.aim120d);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.quadgbu39);
        pylon8c.loadSet(pylonSets.aim9xw);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","4 x GBU-39");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","4 x GBU-39");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var sdb_medium = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.aim120dw);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.aim120dw);

        pylon2a.loadSet(pylonSets.aim9xw);
        pylon2b.loadSet(pylonSets.empty);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.quadgbu39);
        pylon4.loadSet(pylonSets.quadgbu39);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.quadgbu39);
        pylon7.loadSet(pylonSets.quadgbu39);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.empty);
        pylon8c.loadSet(pylonSets.aim9xw);

		pylonex2a.loadSet(pylonSets.aim120dw);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.aim120dw);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","Empty");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","Empty");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var sdb_heavy = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.aim120dw);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.aim120dw);

        pylon2a.loadSet(pylonSets.aim9xw);
        pylon2b.loadSet(pylonSets.empty);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.quadgbu39);
        pylon4.loadSet(pylonSets.quadgbu39);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.quadgbu39);
        pylon7.loadSet(pylonSets.quadgbu39);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.empty);
        pylon8c.loadSet(pylonSets.aim9xw);

		pylonex2a.loadSet(pylonSets.aim120dw);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.aim120dw);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.singlegbu39);
		pyloncft2.loadSet(pylonSets.singlegbu39);
		pyloncft3.loadSet(pylonSets.singlegbu39);
		pyloncft4.loadSet(pylonSets.singlegbu39);
		pyloncft5.loadSet(pylonSets.singlegbu39);
		pyloncft6.loadSet(pylonSets.singlegbu39);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","Droptank");
        setprop("payload/weight[5]/selected","Empty");
        setprop("payload/weight[9]/selected","Droptank");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",1);
        setprop("consumables/fuel/tank[6]/selected",1);
        setprop("consumables/fuel/tank[7]/selected",0);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[7]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var ag_standoff_jsow_heavy = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.empty);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.singleagm154a);
        pylon4.loadSet(pylonSets.singleagm154a);

        pylon5.loadSet(pylonSets.singleagm154a);

        pylon6.loadSet(pylonSets.singleagm154a);
        pylon7.loadSet(pylonSets.singleagm154a);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.empty);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","Droptank");
        setprop("payload/weight[5]/selected","1 x AGM-154A");
        setprop("payload/weight[9]/selected","Droptank");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",1);
        setprop("consumables/fuel/tank[6]/selected",1);
        setprop("consumables/fuel/tank[7]/selected",0);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[7]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var anti_ship_diverse = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.singleagm119a);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.empty);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.singleagm158c);
        pylon4.loadSet(pylonSets.singleagm158c);

        pylon5.loadSet(pylonSets.singleagm84d);

        pylon6.loadSet(pylonSets.singleagm158c);
        pylon7.loadSet(pylonSets.singleagm158c);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.empty);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.singleagm119a);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","1 x AGM-119A");
		setprop("payload/weight[1]/selected","Droptank");
        setprop("payload/weight[5]/selected","1 x AGM-84D");
        setprop("payload/weight[9]/selected","Droptank");
		setprop("payload/weight[15]/selected","1 x AGM-119A");

        setprop("consumables/fuel/tank[5]/selected",1);
        setprop("consumables/fuel/tank[6]/selected",1);
        setprop("consumables/fuel/tank[7]/selected",0);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[7]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var stdoff_slam = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.aim9xw);
        pylon2b.loadSet(pylonSets.singleagm84e);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.aim120d);
        pylon4.loadSet(pylonSets.aim120d);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.aim120d);
        pylon7.loadSet(pylonSets.aim120d);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.singleagm84e);
        pylon8c.loadSet(pylonSets.aim9xw);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","1 x AGM-84E");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","1 x AGM-84E");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
        setprop("consumables/fuel/tank[6]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var stdoff_slam_heavy = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.singleagm84e);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.empty);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.aim120d);
        pylon4.loadSet(pylonSets.aim120d);

        pylon5.loadSet(pylonSets.singleagm84e);

        pylon6.loadSet(pylonSets.aim120d);
        pylon7.loadSet(pylonSets.aim120d);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.empty);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.singleagm84e);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","1 x AGM-84E");
		setprop("payload/weight[1]/selected","Droptank");
        setprop("payload/weight[5]/selected","1 x AGM-84E");
        setprop("payload/weight[9]/selected","Droptank");
		setprop("payload/weight[15]/selected","1 x AGM-84E");

        setprop("consumables/fuel/tank[5]/selected",1);
        setprop("consumables/fuel/tank[6]/selected",1);
        setprop("consumables/fuel/tank[7]/selected",0);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[7]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var ag_standoff_jassm = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.aim9xw);
        pylon2b.loadSet(pylonSets.singleagm158a);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.aim120d);
        pylon4.loadSet(pylonSets.aim120d);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.aim120d);
        pylon7.loadSet(pylonSets.aim120d);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.singleagm158a);
        pylon8c.loadSet(pylonSets.aim9xw);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","1 x AGM-158A");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","1 x AGM-158A");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
		setprop("consumables/fuel/tank[6]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var jassm_heavy = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.empty);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.singleagm158a);
        pylon4.loadSet(pylonSets.singleagm158a);

        pylon5.loadSet(pylonSets.singleagm158a);

        pylon6.loadSet(pylonSets.singleagm158a);
        pylon7.loadSet(pylonSets.singleagm158a);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.empty);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","Droptank");
        setprop("payload/weight[5]/selected","1 x AGM-158A");
        setprop("payload/weight[9]/selected","Droptank");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",1);
        setprop("consumables/fuel/tank[6]/selected",1);
        setprop("consumables/fuel/tank[7]/selected",0);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[7]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var lrsam = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.aim9xw);
        pylon2b.loadSet(pylonSets.singleagm158c);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.aim120d);
        pylon4.loadSet(pylonSets.aim120d);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.aim120d);
        pylon7.loadSet(pylonSets.aim120d);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.singleagm158c);
        pylon8c.loadSet(pylonSets.aim9xw);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","1 x AGM-158C");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","1 x AGM-158C");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[5]/level-lbs",0);
		setprop("consumables/fuel/tank[6]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var lrsam_heavy = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.aim120dw);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.aim120dw);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.empty);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.singleagm158c);
        pylon4.loadSet(pylonSets.singleagm158c);

        pylon5.loadSet(pylonSets.singleagm158c);

        pylon6.loadSet(pylonSets.singleagm158c);
        pylon7.loadSet(pylonSets.singleagm158c);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.empty);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.aim120dw);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.aim120dw);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","Droptank");
        setprop("payload/weight[5]/selected","1 x AGM-158C");
        setprop("payload/weight[9]/selected","Droptank");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",1);
        setprop("consumables/fuel/tank[6]/selected",1);
        setprop("consumables/fuel/tank[7]/selected",0);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[7]/level-lbs",0);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var ag_standoff_diverse = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.singleagm84e);
		pylonex1c.loadSet(pylonSets.aim120dw);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.empty);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.singleagm154a);
        pylon4.loadSet(pylonSets.aim120d);

        pylon5.loadSet(pylonSets.singleagm158a);

        pylon6.loadSet(pylonSets.singleagm154a);
        pylon7.loadSet(pylonSets.aim120d);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.empty);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.aim120dw);
		pylonex2b.loadSet(pylonSets.singleagm84e);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","1 x AGM-84E");
		setprop("payload/weight[1]/selected","Droptank");
        setprop("payload/weight[5]/selected","1 x AGM-158A");
        setprop("payload/weight[9]/selected","Droptank");
		setprop("payload/weight[15]/selected","1 x AGM-84E");

        setprop("consumables/fuel/tank[5]/selected",1);
        setprop("consumables/fuel/tank[6]/selected",1);
        setprop("consumables/fuel/tank[7]/selected",0);
		setprop("fdm/jsbsim/propulsion/cft", 1);

        setprop("consumables/fuel/tank[7]/level-lbs",1);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var airshow_ex = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.empty);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.empty);

        pylon2a.loadSet(pylonSets.empty);
        pylon2b.loadSet(pylonSets.empty);
        pylon2c.loadSet(pylonSets.smokeWL);

        pylon3.loadSet(pylonSets.empty);
        pylon4.loadSet(pylonSets.empty);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.empty);
        pylon7.loadSet(pylonSets.empty);

        pylon8a.loadSet(pylonSets.smokeWR);
        pylon8b.loadSet(pylonSets.empty);
        pylon8c.loadSet(pylonSets.empty);

		pylonex2a.loadSet(pylonSets.empty);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.empty);

		pylonnav.loadSet(pylonSets.empty);
		pylontgp.loadSet(pylonSets.empty);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","Empty");
        setprop("payload/weight[5]/selected","Empty");
        setprop("payload/weight[9]/selected","Empty");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",0);
		setprop("fdm/jsbsim/propulsion/cft", 0);

        setprop("consumables/fuel/tank[7]/level-lbs",1);
		setprop("consumables/fuel/tank[6]/level-lbs",1);
		setprop("consumables/fuel/tank[5]/level-lbs",1);
		aircraft.set_fuel(4420); # Airshow fuel amount (full Tank 1)
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var gps_light = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.aim120dw);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.aim120dw);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.doublegbu54);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.singlegbu54);
        pylon4.loadSet(pylonSets.singlegbu54);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.singlegbu54);
        pylon7.loadSet(pylonSets.singlegbu54);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.doublegbu54);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.aim120dw);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.aim120dw);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","2 x GBU-54");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","2 x GBU-54");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

		setprop("consumables/fuel/tank[6]/level-lbs",1);
		setprop("consumables/fuel/tank[5]/level-lbs",1);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var gps_light_cfts = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.aim120dw);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.aim120dw);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.doublegbu54);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.singlegbu54);
        pylon4.loadSet(pylonSets.singlegbu54);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.singlegbu54);
        pylon7.loadSet(pylonSets.singlegbu54);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.doublegbu54);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.aim120dw);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.aim120dw);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.singlegbu54);
		pyloncft2.loadSet(pylonSets.singlegbu54);
		pyloncft3.loadSet(pylonSets.singlegbu54);
		pyloncft4.loadSet(pylonSets.singlegbu54);
		pyloncft5.loadSet(pylonSets.singlegbu54);
		pyloncft6.loadSet(pylonSets.singlegbu54);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","2 x GBU-54");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","2 x GBU-54");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

		setprop("consumables/fuel/tank[6]/level-lbs",1);
		setprop("consumables/fuel/tank[5]/level-lbs",1);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var gps_medium = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.aim120dw);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.aim120dw);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.doublegbu32);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.singlegbu32);
        pylon4.loadSet(pylonSets.empty);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.empty);
        pylon7.loadSet(pylonSets.singlegbu32);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.doublegbu32);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.aim120dw);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.aim120dw);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","1 x GBU-32");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","1 x GBU-32");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

		setprop("consumables/fuel/tank[6]/level-lbs",1);
		setprop("consumables/fuel/tank[5]/level-lbs",1);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var gps_heavy = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.aim120dw);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.aim120dw);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.singlegbu31);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.singlegbu31);
        pylon4.loadSet(pylonSets.empty);

        pylon5.loadSet(pylonSets.empty);

        pylon6.loadSet(pylonSets.empty);
        pylon7.loadSet(pylonSets.singlegbu31);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.singlegbu31);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.aim120dw);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.aim120dw);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.empty);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.empty);
		pyloncft4.loadSet(pylonSets.empty);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.empty);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","1 x GBU-31");
        setprop("payload/weight[5]/selected","Droptank");
        setprop("payload/weight[9]/selected","1 x GBU-31");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",0);
        setprop("consumables/fuel/tank[6]/selected",0);
        setprop("consumables/fuel/tank[7]/selected",1);
		setprop("fdm/jsbsim/propulsion/cft", 1);

		setprop("consumables/fuel/tank[6]/level-lbs",1);
		setprop("consumables/fuel/tank[5]/level-lbs",1);
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}

var gps_diverse = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {

		pylonex1a.loadSet(pylonSets.aim120dw);
		pylonex1b.loadSet(pylonSets.empty);
		pylonex1c.loadSet(pylonSets.aim120dw);

        pylon2a.loadSet(pylonSets.aim120dw);
        pylon2b.loadSet(pylonSets.empty);
        pylon2c.loadSet(pylonSets.aim9xw);

        pylon3.loadSet(pylonSets.singlegbu31);
        pylon4.loadSet(pylonSets.singlegbu54);

        pylon5.loadSet(pylonSets.singlegbu32);

        pylon6.loadSet(pylonSets.singlegbu54);
        pylon7.loadSet(pylonSets.singlegbu31);

        pylon8a.loadSet(pylonSets.aim9xw);
        pylon8b.loadSet(pylonSets.empty);
        pylon8c.loadSet(pylonSets.aim120dw);

		pylonex2a.loadSet(pylonSets.aim120dw);
		pylonex2b.loadSet(pylonSets.empty);
		pylonex2c.loadSet(pylonSets.aim120dw);

		pylonnav.loadSet(pylonSets.lantirnnav);
		pylontgp.loadSet(pylonSets.atpsniper);

		pyloncft1.loadSet(pylonSets.singlegbu54);
		pyloncft2.loadSet(pylonSets.empty);
		pyloncft3.loadSet(pylonSets.singlegbu54);
		pyloncft4.loadSet(pylonSets.singlegbu54);
		pyloncft5.loadSet(pylonSets.empty);
		pyloncft6.loadSet(pylonSets.singlegbu54);

        reloadCannon();

		setprop("payload/weight[12]/selected","Empty");
		setprop("payload/weight[1]/selected","Droptank");
        setprop("payload/weight[5]/selected","1 x GBU-32");
        setprop("payload/weight[9]/selected","Droptank");
		setprop("payload/weight[15]/selected","Empty");

        setprop("consumables/fuel/tank[5]/selected",1);
        setprop("consumables/fuel/tank[6]/selected",1);
        setprop("consumables/fuel/tank[7]/selected",0);
		setprop("fdm/jsbsim/propulsion/cft", 1);

		setprop("consumables/fuel/tank[7]/level-lbs",1);
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
        if (aim != nil and (aim.type == "AIM-9" or aim.type == "AIM-9X" or aim.type == "CATM-9X")) {
			var hmd_active = getprop("payload/armament/hmd-active");

        	if (hmd_active and aim.status < 1 and awg_9.getPriorityTarget() == nil) {
        		aim.setContacts(awg_9.completeList);
        		var h = -geo.normdeg180(getprop("sim/current-view/heading-offset-deg"));
                var p = getprop("sim/current-view/pitch-offset-deg");
        		if (math.sqrt(h*h+p*p) < aim.fcs_fov) {
                	aim.commandDir(h,p);
                	bore = 2;
            	} else {
            		if (standby != 1) {
		                aim.commandRadar(0,-4);
		                aim.setContacts([]);
		            } else {
		            	aim.setContacts(awg_9.completeList);
		                aim.commandDir(0,-4);# the real is bored to -6 deg below real bore
		                bore = 1;
		            }
            	}
            } elsif (standby == 1) {
                #aim.setBore(1);
                aim.setContacts(awg_9.completeList);
                aim.commandDir(0,-3.5);# the real is bored to -6 deg below real bore
                bore = 1;
            } else {
				# stop tracking target with IR and start try to lock up radar target
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
