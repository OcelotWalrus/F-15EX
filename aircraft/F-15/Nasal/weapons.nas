# F-15 Weapons system
# ---------------------------
# Modified by Jimmy L. Miles to implement mission sets and programs for A/G operations in the
# F-15EX.
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
    if (weap != nil and weap.parents[0] == armament.AIM and (weap.type == "MK-84" or weap.type == "GBU-10" or weap.type == "MK-82AIR" or weap.type == "MK-82" or weap.type == "MK-83" or weap.type == "CBU-87" or weap.type == "CBU-105" or weap.type == "GBU-12" or weap.type == "GBU-31" or weap.type == "GBU-32" or weap.type == "GBU-54" or weap.type == "GBU-39")) {
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

## Initiate A/G PACS
## Note: There are 8 slots for A/G PACS programs

var pacs = [];
var pacs_program_slots = 8;  # 8 A/G PACS programs available
for (var i = 0; i < pacs_program_slots; i += 1) {
    data_block = {program: i+1, selected_pylons: {pylon_12: nil, pylon_1: nil, pylon_3: nil, pylon_4: nil, pylon_5: nil, pylon_6: nil, pylon_7: nil, pylon_9: nil, pylon_15: nil, pylon_20: nil, pylon_21: nil, pylon_22: nil, pylon_23: nil, pylon_24: nil, pylon_25: nil}, delivery_mode: 0, release_sequence: 1, ripple_dist: 150, fuzing: 0, cluster_spin: 0, cluster_time: 0, cluster_height: 0, ordnance_type: nil, tarm: nil};
    # NOTE: A single program can't mix up different ordnance types: if you got 2 AGM-84Es and 4 GBU-31s loaded, you'll need at least 1 program for the AGM-84Es and one for the GBU-31s
    # program: id of the program, from 1 to 32
    # selected_pylons: dict containing every A/G pylon. If nil, it's not selected, to select it, it's set to a vector containing sub ordnances idx ex. pylon_1: [0,1,2,3] to select a 4xGBU-39 rack on pylon 1.
    #                  (actually you can't select specific ordnances on a pylon, it's the whole station
    # delivery_mode: 0 means direct, 1 means auto (doesn't matter right now, auto would release bombs automatically when DLZ NEZ is reached), 2 means CCIP (pipper)
    # release_sequence:
    #  0: 1/STA - one ordnance per selected station will be dropped simultaneously with each
    #              press of the pickle button. So if two stations are programmed, one bomb will fall
    #              from each of them etc.
    #  1: Step - one ordnance will be dropped with each press of the pickle button, alternating
    #            between the stations to maintain best possible balance
    #  2: Ripple Single - will drop one ordnance at a time, alternating between stations, automatically every
    #             ripple_dist feet traveled by the F-15, until no programmed ordnance is left,
    #             as soon as a single press of the pickle button is done.
    #  3: Ripple Multiple - will drop one ordnance by selected station simultaneously, automatically every
    #             ripple_dist feet traveled by the F-15, until no programmed ordnance is left,
    #             as soon as a single press of the pickle button is done.
    # ripple_dist: how much feet in space we wait for a new ripple iteration (if release sequence is either ripple single or ripple multiple)
    # fuzing:
    #  0: Nose - Inhibits deployment of ballots/fins for MK82AIRs and MK82SEs  (both nose and center fuzing units energized)
    #  1: Tail - Allows deployment of ballots/fins for MK82AIRs and MK82SEs  (only tail fuzing units energized)
    #  2: Nose/Tail - Allows deployment of ballots/fins for MK82AIRs and MK82SEs  (nose, center and tail fuzing units energized)
    #  3: Time - (Cluster Bomb Units only) sets the time bomb drop in seconds after which the
    #             bomblets will be released. Uses cluster_time and cluster_spin.
    #  4: Height - (Cluster Bomb Units only) determines the altitude (in feet MSL) at which the
    #            bomblets will be released. Similarly to spin, the higher the altitude, the larger the
    #            bomblet coverage, but smaller the density. Uses cluster_height and cluster_spin.
    # cluster_spin: (Cluster Bomb Units only) chooses the speed (in RPM) with which the canister will rotate while
    #               releasing the bomblets. The higher the speed, the larger area will be covered, but at
    #               the expense of density. There are 6 different spin options
    #               Is available and selectable but doesn't function because cluster munitions aren't properly implemented.
    # 0 - 0 RPM
    # 1 - 500 RPM
    # 2 - 1,000 RPM
    # 3 - 1,500 RPM
    # 4 - 2,000 RPM
    # 5 - 2,500 RPM
    # cluster_time: (Cluster Bomb Units only) Is available and selectable but doesn't function because cluster munitions aren't properly implemented.
    # 0 - "N":   .95s
    # 1 - "O":  1.28s
    # 2 - "P":  1.60s
    # 3 - "R":  1.92s
    # 4 - "S":  2.23s
    # 5 - "T":  2.25s
    # 6 - "U":  2.87s
    # 7 - "V":  3.19s
    # 8 - "X":  3.51s
    # 9 - "Y":  3.83s
    # 10 - "Z": 4.15s
    # cluster_height: (Cluster Bomb Units only) Is available and selectable but doesn't function because cluster munitions aren't properly implemented.
    # 0 - "A":    300ft
    # 1 - "B":    500ft
    # 2 - "C":    700ft
    # 3 - "D":    900ft
    # 4 - "E":  1,200ft
    # 5 - "F":  1,500ft
    # 6 - "G":  1,800ft
    # 7 - "H":  2,200ft
    # 8 - "J":  2,600ft
    # 9 - "L":  3,000ft
    # tarm: Time to Arm - How much time in seconds the ordnances of the program will arm after drop
    
    append(pacs, data_block);
}
var pacs_current_program = 0;  # Program 1

var pylon_in_program = func(pylon_idx) {  # Check if the input'd pylon is in the current PACS program

    if (pylon_idx == 12) {
        return pacs[pacs_current_program].selected_pylons.pylon_12 != nil;
    } elsif (pylon_idx == 1) {
        return pacs[pacs_current_program].selected_pylons.pylon_1 != nil;
    } elsif (pylon_idx == 3) {
        return pacs[pacs_current_program].selected_pylons.pylon_3 != nil;
    } elsif (pylon_idx == 4) {
        return pacs[pacs_current_program].selected_pylons.pylon_4 != nil;
    } elsif (pylon_idx == 5) {
        return pacs[pacs_current_program].selected_pylons.pylon_5 != nil;
    } elsif (pylon_idx == 6) {
        return pacs[pacs_current_program].selected_pylons.pylon_6 != nil;
    } elsif (pylon_idx == 7) {
        return pacs[pacs_current_program].selected_pylons.pylon_7 != nil;
    } elsif (pylon_idx == 9) {
        return pacs[pacs_current_program].selected_pylons.pylon_9 != nil;
    } elsif (pylon_idx == 15) {
        return pacs[pacs_current_program].selected_pylons.pylon_15 != nil;
    } elsif (pylon_idx == 20) {
        return pacs[pacs_current_program].selected_pylons.pylon_20 != nil;
    } elsif (pylon_idx == 21) {
        return pacs[pacs_current_program].selected_pylons.pylon_21 != nil;
    } elsif (pylon_idx == 22) {
        return pacs[pacs_current_program].selected_pylons.pylon_22 != nil;
    } elsif (pylon_idx == 23) {
        return pacs[pacs_current_program].selected_pylons.pylon_23 != nil;
    } elsif (pylon_idx == 24) {
        return pacs[pacs_current_program].selected_pylons.pylon_24 != nil;
    } elsif (pylon_idx == 25) {
        return pacs[pacs_current_program].selected_pylons.pylon_25 != nil;
    }
    return 0;
}

var select_pylon_in_program = func(pylon_idx) {
    if (contains(displays.PACSWeaps, getprop("payload/armament/station/id-"~pylon_idx~"-set"))) {  # we're reusing LAD.nas's PACSWeaps variable (list of A/G PACS compatible ordnance)
        return 0;
    }

    if (pacs[pacs_current_program].ordnance_type == nil or pacs[pacs_current_program].tarm == nil) {  # First time a station gets selected, we set the ordnance type for the program
        pacs[pacs_current_program].ordnance_type = getprop("payload/armament/station/id-"~pylon_idx~"-type");
        type_lc = string.lc(getprop("payload/armament/station/id-"~pylon_idx~"-type"));
        pacs[pacs_current_program].tarm = getprop("payload/armament/" ~ type_lc ~ "/arming-time-sec");
    }

    if (pacs[pacs_current_program].ordnance_type == getprop("payload/armament/station/id-"~pylon_idx~"-type")) {  # Ordnance type matches
        if (pylon_idx == 12) {
            if (pacs[pacs_current_program].selected_pylons.pylon_12 == nil) {
                pacs[pacs_current_program].selected_pylons.pylon_12 = [0];
            }
        } elsif (pylon_idx == 1) {
            if (pacs[pacs_current_program].selected_pylons.pylon_1 == nil) {
                pacs[pacs_current_program].selected_pylons.pylon_1 = [0];
            }
        } elsif (pylon_idx == 3) {
            if (pacs[pacs_current_program].selected_pylons.pylon_3 == nil) {
                pacs[pacs_current_program].selected_pylons.pylon_3 = [0];
            }
        } elsif (pylon_idx == 4) {
            if (pacs[pacs_current_program].selected_pylons.pylon_4 == nil) {
                pacs[pacs_current_program].selected_pylons.pylon_4 = [0];
            }
        } elsif (pylon_idx == 5) {
            if (pacs[pacs_current_program].selected_pylons.pylon_5 == nil) {
                pacs[pacs_current_program].selected_pylons.pylon_5 = [0];
            }
        } elsif (pylon_idx == 6) {
            if (pacs[pacs_current_program].selected_pylons.pylon_6 == nil) {
                pacs[pacs_current_program].selected_pylons.pylon_6 = [0];
            }
        } elsif (pylon_idx == 7) {
            if (pacs[pacs_current_program].selected_pylons.pylon_7 == nil) {
                pacs[pacs_current_program].selected_pylons.pylon_7 = [0];
            }
        } elsif (pylon_idx == 9) {
            if (pacs[pacs_current_program].selected_pylons.pylon_9 == nil) {
                pacs[pacs_current_program].selected_pylons.pylon_9 = [0];
            }
        } elsif (pylon_idx == 15) {
            if (pacs[pacs_current_program].selected_pylons.pylon_15 == nil) {
                pacs[pacs_current_program].selected_pylons.pylon_15 = [0];
            }
        } elsif (pylon_idx == 20) {
            if (pacs[pacs_current_program].selected_pylons.pylon_20 == nil) {
                pacs[pacs_current_program].selected_pylons.pylon_20 = [0];
            }
        } elsif (pylon_idx == 21) {
            if (pacs[pacs_current_program].selected_pylons.pylon_21 == nil) {
                pacs[pacs_current_program].selected_pylons.pylon_21 = [0];
            }
        } elsif (pylon_idx == 22) {
            if (pacs[pacs_current_program].selected_pylons.pylon_22 == nil) {
                pacs[pacs_current_program].selected_pylons.pylon_22 = [0];
            }
        } elsif (pylon_idx == 23) {
            if (pacs[pacs_current_program].selected_pylons.pylon_23 == nil) {
                pacs[pacs_current_program].selected_pylons.pylon_23 = [0];
            }
        } elsif (pylon_idx == 24) {
            if (pacs[pacs_current_program].selected_pylons.pylon_24 == nil) {
                pacs[pacs_current_program].selected_pylons.pylon_24 = [0];
            }
        } elsif (pylon_idx == 25) {
            if (pacs[pacs_current_program].selected_pylons.pylon_25 == nil) {
                pacs[pacs_current_program].selected_pylons.pylon_25 = [0];
            }
        }
    }
    return 0;
}

var deselect_pylon_in_program = func(pylon_idx) {

    if (((pacs[pacs_current_program].selected_pylons.pylon_12 == nil) + (pacs[pacs_current_program].selected_pylons.pylon_1 == nil) + (pacs[pacs_current_program].selected_pylons.pylon_3 == nil) + (pacs[pacs_current_program].selected_pylons.pylon_4 == nil) + (pacs[pacs_current_program].selected_pylons.pylon_5 == nil) + (pacs[pacs_current_program].selected_pylons.pylon_6 == nil) + (pacs[pacs_current_program].selected_pylons.pylon_7 == nil) + (pacs[pacs_current_program].selected_pylons.pylon_9 == nil) + (pacs[pacs_current_program].selected_pylons.pylon_15 == nil) + (pacs[pacs_current_program].selected_pylons.pylon_20 == nil) + (pacs[pacs_current_program].selected_pylons.pylon_21 == nil) + (pacs[pacs_current_program].selected_pylons.pylon_22 == nil) + (pacs[pacs_current_program].selected_pylons.pylon_23 == nil) + (pacs[pacs_current_program].selected_pylons.pylon_24 == nil) + (pacs[pacs_current_program].selected_pylons.pylon_25 == nil)) == 14) {  # If we're deselecting the final station
        pacs[pacs_current_program].ordnance_type = nil;
        pacs[pacs_current_program].tarm = nil;
    }

    if (pylon_idx == 12) {
        pacs[pacs_current_program].selected_pylons.pylon_12 = nil;
    } elsif (pylon_idx == 1) {
        pacs[pacs_current_program].selected_pylons.pylon_1 = nil;
    } elsif (pylon_idx == 3) {
        pacs[pacs_current_program].selected_pylons.pylon_3 = nil;
    } elsif (pylon_idx == 4) {
        pacs[pacs_current_program].selected_pylons.pylon_4 = nil;
    } elsif (pylon_idx == 5) {
        pacs[pacs_current_program].selected_pylons.pylon_5 = nil;
    } elsif (pylon_idx == 6) {
        pacs[pacs_current_program].selected_pylons.pylon_6 = nil;
    } elsif (pylon_idx == 7) {
        pacs[pacs_current_program].selected_pylons.pylon_7 = nil;
    } elsif (pylon_idx == 9) {
        pacs[pacs_current_program].selected_pylons.pylon_9 = nil;
    } elsif (pylon_idx == 15) {
        pacs[pacs_current_program].selected_pylons.pylon_15 = nil;
    } elsif (pylon_idx == 20) {
        pacs[pacs_current_program].selected_pylons.pylon_20 = nil;
    } elsif (pylon_idx == 21) {
        pacs[pacs_current_program].selected_pylons.pylon_21 = nil;
    } elsif (pylon_idx == 22) {
        pacs[pacs_current_program].selected_pylons.pylon_22 = nil;
    } elsif (pylon_idx == 23) {
        pacs[pacs_current_program].selected_pylons.pylon_23 = nil;
    } elsif (pylon_idx == 24) {
        pacs[pacs_current_program].selected_pylons.pylon_24 = nil;
    } elsif (pylon_idx == 25) {
        pacs[pacs_current_program].selected_pylons.pylon_25 = nil;
    }
    return 0;
}

## Initiate A/G Smart Weapons data blocks
var pylons_a_g = [12,1,3,4,5,6,7,9,15,20,21,22,23,24,25];  # A/G Hardpoints
var smart_weapons_data_blocks = [];
for (var i = 0; i < size(pylons_a_g); i += 1) {
    data_block = {pylon_idx: pylons_a_g[i], data: [{gps: nil, terminal: {heading: nil, angle: nil, vel: nil}, type: 0, push_source: nil}], initiated: 0, telemetry: 0};
    append(smart_weapons_data_blocks, data_block);
}

var get_data_block_from_pylon_idx = func (pylon_idx) {
    foreach(curr_block; smart_weapons_data_blocks) {
        if (curr_block.pylon_idx == pylon_idx) {
            return curr_block;
        }
    }
    return 0;
}

var untarget_data_block = func(station, ordnance) {
    for (var i = 0; i < size(pylons_a_g); i += 1) {
        if (smart_weapons_data_blocks[i].pylon_idx == station) {
            smart_weapons_data_blocks[i].data[ordnance] = {gps: nil, terminal: {heading: nil, angle: nil, vel: nil}, type: 0, push_source: nil};
        }
    }
}

var rdr_tgt_to_station = func(rdr_tgt, station, ordnance, skim_ft=1000) {  # Used to push a radar target to a smart weapon (usually A/S weapons in RDR TGT mode)
    data_block = {radar_target: rdr_tgt};
    data_block.type = 1;
    data_block.skim_ft = skim_ft;
    for (var i = 0; i < size(pylons_a_g); i += 1) {
        if (smart_weapons_data_blocks[i].pylon_idx == station) {
            smart_weapons_data_blocks[i].data[ordnance] = data_block;
            smart_weapons_data_blocks[i].data[ordnance].push_source = "RDR";
        }
    }
}

var toggle_telemetry_var_to_station = func(station) {  # Use for smart weapons to toggle their link 16 or not (only Anti-Ships and SEADs, others are set depending on whether they got it or not)
    for (var i = 0; i < size(pylons_a_g); i += 1) {
        if (smart_weapons_data_blocks[i].pylon_idx == station) {
            smart_weapons_data_blocks[i].telemetry = !smart_weapons_data_blocks[i].telemetry;
        }
    }
}

## Initiate the A/G Mission Sets and Programs
# Note: there are 4 slots for sets, and inside each of 'em, 40 slots for programs
var mission_sets_max = 4;
var mission_programs_max = 40;
var mission_sets = [[], [], [], []];
for (var i = 0; i < mission_sets_max; i += 1) {
    for (var y = 0; y < mission_programs_max; y += 1) {
        var mission_program = {gps: geo.Coord.new().set_latlon(0, 0, 0), terminal: {heading: 0, angle: 0, vel: 0}, initialized: 0};
        append(mission_sets[i], mission_program);
    }
}

var push_mission_program_to_station = func(mission_set, mission_program, station, ordnance) {  # Used to push a Mission to a station's ordnance in the Smart Weapons Page using CC populate mode
    data_block = mission_sets[mission_set][mission_program];
    data_block.type = 0;
    for (var i = 0; i < size(pylons_a_g); i += 1) {
        if (smart_weapons_data_blocks[i].pylon_idx == station) {
            smart_weapons_data_blocks[i].data[ordnance] = data_block;
            smart_weapons_data_blocks[i].data[ordnance].push_source = "CC MEM";
        }
    }
}

var push_mission_program_from_dialog = func () {  # used to push data from the mission planning dialog to the actual mission programs
    mission_set_id = getprop("controls/mission-planning/selected-mission-set");
    mission_program_id = getprop("controls/mission-planning/selected-mission-program");
    mission_gps = geo.Coord.new().set_latlon(getprop("controls/mission-planning/selected-mission-program-lat"), getprop("controls/mission-planning/selected-mission-program-lon"), getprop("controls/mission-planning/selected-mission-program-alt")*FT2M);
    mission_terminal = {heading: getprop("controls/mission-planning/selected-mission-program-term-heading"), angle: getprop("controls/mission-planning/selected-mission-program-term-angle"), vel: getprop("controls/mission-planning/selected-mission-program-term-vel")};
    mission_initialized = getprop("controls/mission-planning/selected-mission-program-initialized");
    
    aircraft.mission_sets[mission_set_id][mission_program_id] = {gps: mission_gps, terminal: mission_terminal, initialized: mission_initialized};

    setprop("sim/model/f15/preplanning-status", sprintf("Updated DTC Mission %d/%02d", mission_set_id, mission_program_id));
}

var push_mission_program_from_dtc = func (mission_set_id, mission_program_id, mission_lat, mission_lon, mission_alt, mission_terminal_head, mission_terminal_angle, mission_terminal_vel, mission_initialized) {
    mission_gps = geo.Coord.new().set_latlon(mission_lat, mission_lon, mission_alt*FT2M);
    mission_terminal = {heading: mission_terminal_head, angle: mission_terminal_angle, vel: mission_terminal_vel};
    
    aircraft.mission_sets[mission_set_id][mission_program_id] = {gps: mission_gps, terminal: mission_terminal, initialized: mission_initialized};
    
    setprop("sim/model/f15/preplanning-status", sprintf("Updated DTC Mission %d/%02d", mission_set_id, mission_program_id));
}

var get_status_for_pylon = func(pylon_idx) {
    is_valid_pylon = 0;
    foreach(curr_pylon; pylons_a_g) {
        if (curr_pylon == pylon_idx) {
            is_valid_pylon = 1;
        }
    }
    
    if (is_valid_pylon) {
        var initiated = get_data_block_from_pylon_idx(pylon_idx).initiated;
        if (get_data_block_from_pylon_idx(pylon_idx).data[0].type == 0) {
            var no_data = get_data_block_from_pylon_idx(pylon_idx).data[0].gps == nil;
        } elsif (get_data_block_from_pylon_idx(pylon_idx).data[0].type == 1) {
            var no_data = get_data_block_from_pylon_idx(pylon_idx).data[0].radar_target == nil;
        }
        
        return [initiated, no_data];
    }
    return 0;
}

var determine_set_text = func(pylon_idx) {
    var loaded_type = getprop("payload/armament/station/id-"~pylon_idx~"-type");
    var loaded_count = getprop("payload/armament/station/id-"~pylon_idx~"-count");
    var type_lc = string.lc(loaded_type);
    
    if (loaded_count > 0 and loaded_type != "" and type_lc != nil) {
        short_name = getprop("payload/armament/" ~ type_lc ~ "/short-name");
        if (loaded_count > 1 and short_name != nil and short_name != "") {
            short_name = loaded_count~short_name;
        }
        return short_name;
    }
    
    return 0;
}

## All the following lines are taken from the A-10 model and adapted by Jimmy L. Miles
## These methods are used for compatible AGM missiles: AGM-65B, AGM-65D, AGM-84D, AGM-88E and AGM-119A (not AGM-154A and AGM-158s since GPS guided)
## It ranomly moves the caged seeker cursor until it finds a target. When a target's found,
## the seeker goes uncaged and tracks the target. If the target is lock, searchin mode turns back online

var defaultX = 0;
var defaultY = 0;
#Seeker Loop for cursor control
var seekerLoop = func {
    selectedWeap = pylons.fcs.getSelectedWeapon();
    var cursorX = getprop("sim/model/f15/cursor-slew/x");
    var cursorY = getprop("sim/model/f15/cursor-slew/y");
    if (selectedWeap == nil or getprop("sim/model/f15/avionics/hmd-slaving")) {
        seekerTimer.stop();
    } elsif ((selectedWeap.type == "AGM-65B" or selectedWeap.type == "AGM-65D" or selectedWeap.type == "AGM-84D" or selectedWeap.type == "AGM-119A" or selectedWeap.type == "AGM-88E") and (awg_9.active_u == nil or !awg_9.active_u.get_display())) {
        selectedWeap.commandDir(cursorX,cursorY);
    } elsif (awg_9.active_u != nil and awg_9.active_u.get_display() and (selectedWeap.type == "AGM-65B" or selectedWeap.type == "AGM-65D" or selectedWeap.type == "AGM-84D" or selectedWeap.type == "AGM-119A" or selectedWeap.type == "AGM-88E")) {  # If we have a valid radar target, slave the AGM's seeker to that
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
    if (selectedWeap == nil or (selectedWeap.type != "AGM-65B" and selectedWeap.type != "AGM-65D" and selectedWeap.type != "AGM-84D" and selectedWeap.type != "AGM-119A" and selectedWeap.type != "AGM-88E")) {
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
setlistener("controls/armament/selected-armament-offset", mavUpdate, nil, 0);
setlistener("controls/armament/trigger", mavUpdate, nil, 0);
setlistener("controls/armament/selected-armament-offset", mavUpdate, nil, 0);

#Maverick seeker control
var rate = .0025;
var maxDegMove = 7.5;

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

    # older method, less effective
    #if (rand() > .5) {
    #    xRight();
    #} else {
    #    xLeft();
    #}
    #if (rand() > .5) {
    #    yUp();
    #} else {
    #    yDown();
    #}

    # new method, more effective
    odds = rand();
    # Each move got a 25% chance of happenin
    # 0-25 % up
    # 25-50 % down
    # 50-75 % left
    # 75-100 % right

    #if (odds < .25) {
    #    yUp();
    #} elsif (odds < .5 and odds > .25) {
    #    yDown();
    #} elsif (odds < .75 and odds > .5) {
    #    xLeft();
    #} elsif (odds < 1 and odds > .75) {
    #    xRight();
    #}

    # actually, this is disabled for now.
    setprop("sim/model/f15/cursor-slew/x", 0);
    setprop("sim/model/f15/cursor-slew/y", 0);
}

var lock = func {
    selectedWeap = pylons.fcs.getSelectedWeapon();
    if (selectedWeap != nil and ArmSwitch.getValue() > 0 and (selectedWeap.type == "AGM-65B" or selectedWeap.type == "AGM-65D" or selectedWeap.type == "AGM-84D" or selectedWeap.type == "AGM-119A" or selectedWeap.type == "AGM-88E")) {
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

## All the following lines have been written by Jimmy L. Miles. This code allows the salving of the current radar target's GPS to GPS guided weapons: AGM-154A, AGM-158A, GBU-31, GBU-32, GBU-39, GBU-54, CBU-105, B61-12, AGM-158C and AGM-84E
## The following code has a loop checking if the radar's got an active and valid target to lock on, and if the correct GPS weapon's selected, and armed and ready, the target's
## gps coordinates computed by the radar are "slaved" to the current weapon. Depending on the weapon (if it's got datalink or not), they individually receive mid-flight updates of the GPS coordinates of the target (only AGM-158C)
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
    if (selectedWeap == nil or (selectedWeap.type != "AGM-154A" and selectedWeap.type != "AGM-158A" and selectedWeap.type != "AGM-158C" and selectedWeap.type != "AGM-84E" and selectedWeap.type != "GBU-31" and selectedWeap.type != "GBU-32" and selectedWeap.type != "GBU-54" and selectedWeap.type != "GBU-39" and selectedWeap.type != "CBU-105")) {
        #print("Weapon is not compatible with GPS feeder - Skipping sequence");
        gpsFeeder.stop();
    } elsif (getprop("instrumentation/radar/radar-mode") == 2) {
        #print("Radar is on standby.");
    } else {
        if (ArmSwitch.getValue() == 0) {
            #print("Master Arm safe - Skipping");
        } else{
            #print("All good. Initiating GPS feeder");
            gpsInit();
        }
    }
};

var updateGPSTarget = func {
    selectedWeap = pylons.fcs.getSelectedWeapon();
    if (selectedWeap != nil and ArmSwitch.getValue() > 0 and (selectedWeap.type == "AGM-84E" or selectedWeap.type == "AGM-154A" or selectedWeap.type == "AGM-158A" or selectedWeap.type == "AGM-158C" or selectedWeap.type == "GBU-31" or selectedWeap.type == "GBU-32" or selectedWeap.type == "GBU-54" or selectedWeap.type == "GBU-39" or selectedWeap.type == "CBU-105")) {
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
            if (selectedWeap.type != "AGM-158C") {  # Since AGM-158C needs mid-flight updates, we don't use a GPS Spot but a radar target callsign
                var spot = awg_9.ContactTGP.new("GPS-Spot",gpsCoordsTgt,0);
            } else {
                var spot = awg_9.ContactTGP.new(awg_9.active_u.get_Callsign(),gpsCoordsTgt,0);
            }
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
        #print(selectedWeap == nil);
        setprop("sim/model/f15/fcs/target-lock", 0);
    }
};

gpsFeeder = maketimer(.1,updateGPSTarget);

#setlistener(WeaponSelector, gpsUpdate, nil, 0);
#setlistener("controls/armament/selected-armament-offset", gpsUpdate, nil, 0);
#setlistener("controls/armament/trigger", gpsUpdate, nil, 0);
#setlistener("controls/armament/selected-armament-offset", gpsUpdate, nil, 0);
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
    
    # Updates drop mode depending on the current PACS Program delivery mode
    if (aircraft.pacs[aircraft.pacs_current_program].delivery_mode == 2) {  # CCIP mode for dumb bombs
        pylons.fcs.setDropMode(1);
    } else {  # Either direct or auto, both CCRP
        pylons.fcs.setDropMode(0);
    }

    # Update selected weapon on the HUD
    if (WeaponSelector.getValue() == 0) {
        if (pylons.fcs.getSelectedWeapon() != nil and pylons.fcs.getSelectedWeapon().type != "LAU-68C") {
            setprop("sim/model/f15/systems/armament/selected-arm", "M61A1");
        } elsif (pylons.fcs.getSelectedWeapon() != nil and pylons.fcs.getSelectedWeapon().type == "LAU-68C") {
            setprop("sim/model/f15/systems/armament/selected-arm", "M151");
        }
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
    
    # Actually turn the cooling on or off
    if (pylons.fcs.getSelectedWeapon() != nil and (pylons.fcs.getSelectedWeapon().type == "AIM-9X" or pylons.fcs.getSelectedWeapon().type == "CATM-9X")) {
        pylons.fcs.getSelectedWeapon().setCooling(SWCoolOn.getValue());
    }

    SwCount.setValue(aim9_count);
    Count9.setValue(aim9_count);
    Count7.setValue(pylons.fcs.getAmmoOfType("AIM-7"));
    Count120.setValue(pylons.fcs.getAmmoOfType("AIM-120") + pylons.fcs.getAmmoOfType("AIM-120D") + pylons.fcs.getAmmoOfType("CATM-120D"));
    Count84.setValue(pylons.fcs.getAmmoOfType("MK-84")+pylons.fcs.getAmmoOfType("GBU-10")+pylons.fcs.getAmmoOfType("MK-82AIR")+pylons.fcs.getAmmoOfType("MK-82")+pylons.fcs.getAmmoOfType("MK-83")+pylons.fcs.getAmmoOfType("CBU-87")+pylons.fcs.getAmmoOfType("CBU-105")+pylons.fcs.getAmmoOfType("AGM-65B")+pylons.fcs.getAmmoOfType("GBU-12")+pylons.fcs.getAmmoOfType("AGM-65D")+pylons.fcs.getAmmoOfType("AGM-84D")+pylons.fcs.getAmmoOfType("AGM-84E")+pylons.fcs.getAmmoOfType("AGM-119A")+pylons.fcs.getAmmoOfType("AGM-88E")+pylons.fcs.getAmmoOfType("AGM-154A")+pylons.fcs.getAmmoOfType("AGM-158A")+pylons.fcs.getAmmoOfType("GBU-31")+pylons.fcs.getAmmoOfType("GBU-32")+pylons.fcs.getAmmoOfType("GBU-54")+pylons.fcs.getAmmoOfType("AGM-158C")+pylons.fcs.getAmmoOfType("GBU-39"));

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
        else if (mty == "AGM-84E")
            return "agm84e";
        else if (mty == "AGM-119A")
            return "agm119a";
        else if (mty == "AGM-154A")
            return "agm154a";
        else if (mty == "GBU-31")
            return "gbu31";
        else if (mty == "GBU-32")
            return "gbu32";
        else if (mty == "GBU-54")
            return "gbu54";
        else if (mty == "GBU-39")
            return "gbu39";
        else if (mty == "AGM-158A")
            return "agm158a";
        else if (mty == "AGM-158C")
            return "agm158c";
        else if (mty == "AGM-88E")
            return "agm88e";
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
        return pylons.fcs.getAmmoOfType("MK-84")+pylons.fcs.getAmmoOfType("GBU-10")+pylons.fcs.getAmmoOfType("MK-82AIR")+pylons.fcs.getAmmoOfType("MK-82")+pylons.fcs.getAmmoOfType("MK-83")+pylons.fcs.getAmmoOfType("CBU-87")+pylons.fcs.getAmmoOfType("CBU-105")+pylons.fcs.getAmmoOfType("AGM-65B")+pylons.fcs.getAmmoOfType("GBU-12")+pylons.fcs.getAmmoOfType("AGM-65D")+pylons.fcs.getAmmoOfType("AGM-84D")+pylons.fcs.getAmmoOfType("AGM-84E")+pylons.fcs.getAmmoOfType("AGM-119A")+pylons.fcs.getAmmoOfType("AGM-88E")+pylons.fcs.getAmmoOfType("AGM-154A")+pylons.fcs.getAmmoOfType("AGM-158A")+pylons.fcs.getAmmoOfType("GBU-31")+pylons.fcs.getAmmoOfType("GBU-32")+pylons.fcs.getAmmoOfType("GBU-54")+pylons.fcs.getAmmoOfType("AGM-158C")+pylons.fcs.getAmmoOfType("GBU-39");
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
        var wps = ["LAU-68C", "20mm Cannon"];
        var count = 1 - selector_offset;  # length of the list (id 1 is 0 here)
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
        if (aircraft.pacs[aircraft.pacs_current_program].ordnance_type != nil) {  # At least one station is selected on the current PACS Program
        
            # We determine which stations are chosen in the PACS
            var curr_pacs_stations = [];
            if (aircraft.pacs[aircraft.pacs_current_program].selected_pylons.pylon_12 != nil) {
                append(curr_pacs_stations, 12);
            }
            if (aircraft.pacs[aircraft.pacs_current_program].selected_pylons.pylon_1 != nil) {
                append(curr_pacs_stations, 1);
            }
            if (aircraft.pacs[aircraft.pacs_current_program].selected_pylons.pylon_3 != nil) {
                append(curr_pacs_stations, 3);
            }
            if (aircraft.pacs[aircraft.pacs_current_program].selected_pylons.pylon_4 != nil) {
                append(curr_pacs_stations, 4);
            }
            if (aircraft.pacs[aircraft.pacs_current_program].selected_pylons.pylon_5 != nil) {
                append(curr_pacs_stations, 5);
            }
            if (aircraft.pacs[aircraft.pacs_current_program].selected_pylons.pylon_6 != nil) {
                append(curr_pacs_stations, 6);
            }
            if (aircraft.pacs[aircraft.pacs_current_program].selected_pylons.pylon_7 != nil) {
                append(curr_pacs_stations, 7);
            }
            if (aircraft.pacs[aircraft.pacs_current_program].selected_pylons.pylon_9 != nil) {
                append(curr_pacs_stations, 9);
            }
            if (aircraft.pacs[aircraft.pacs_current_program].selected_pylons.pylon_15 != nil) {
                append(curr_pacs_stations, 15);
            }
            if (aircraft.pacs[aircraft.pacs_current_program].selected_pylons.pylon_20 != nil) {
                append(curr_pacs_stations, 20);
            }
            if (aircraft.pacs[aircraft.pacs_current_program].selected_pylons.pylon_21 != nil) {
                append(curr_pacs_stations, 21);
            }
            if (aircraft.pacs[aircraft.pacs_current_program].selected_pylons.pylon_22 != nil) {
                append(curr_pacs_stations, 22);
            }
            if (aircraft.pacs[aircraft.pacs_current_program].selected_pylons.pylon_23 != nil) {
                append(curr_pacs_stations, 23);
            }
            if (aircraft.pacs[aircraft.pacs_current_program].selected_pylons.pylon_24 != nil) {
                append(curr_pacs_stations, 24);
            }
            if (aircraft.pacs[aircraft.pacs_current_program].selected_pylons.pylon_25 != nil) {
                append(curr_pacs_stations, 25);
            }
            
            var i = 0;
            var current_station_vec_idx = nil;
            var current_station_rel_idx = nil;
            foreach(curr_station; pylons.pylons) {
                if (contains(curr_pacs_stations, curr_station.id) and current_station_vec_idx == nil) {
                    var current_station_vec_idx = i;
                    var current_station_rel_idx = curr_station.id;
                }
                var i += 1;
            }
            if (current_station_vec_idx != nil) {
                # release_sequence:
                #  0: 1/STA - one ordnance per selected station will be dropped simultaneously with each
                #              press of the pickle button. So if two stations are programmed, one bomb will fall
                #              from each of them etc.
                #  1: Step - one ordnance will be dropped with each press of the pickle button, alternating
                #            between the stations to maintain best possible balance
                #  2: Ripple Single - will drop one ordnance at a time, alternating between stations, automatically every
                #             ripple_dist feet traveled by the F-15, until no programmed ordnance is left,
                #             as soon as a single press of the pickle button is done.
                #  3: Ripple Multiple - will drop one ordnance by selected station simultaneously, automatically every
                #             ripple_dist feet traveled by the F-15, until no programmed ordnance is left,
                #             as soon as a single press of the pickle button is done.
                # ripple_dist: how much feet in space we wait for a new ripple iteration (if release sequence is either ripple single or ripple multiple)
                if (pacs[pacs_current_program].release_sequence == 1) {  # STEP mode (one ordnance for one station per pickle trigger)
                    pylons.fcs.selectPylon(current_station_vec_idx);  # Select first available pylon
                    pylons.fcs.setRippleMode(1);  # No ripple, default
                    pylons.fcs.setRippleDist(150*FT2M);  # Default value, not used cause ripple is set to 1 above
                } elsif (pacs[pacs_current_program].release_sequence == 2) {  # RPL SGL (one ordnance every ripple_dist ft till none left)
                    #pylons.fcs.selectDualWeapons(pacs[pacs_current_program].ordnance_type, pylons.fcs.getAmmoOfType(pacs[pacs_current_program].ordnance_type));  # Select as much as ordnance of that type we got
                    # Problem is that it won't check if any of the selected pylons are in the program
                    pylons.fcs.selectPylon(current_station_vec_idx);  # Select first available pylon
                    pylons.fcs.setRippleMode(pylons.fcs.getAmmoOfType(pacs[pacs_current_program].ordnance_type));  # We tell the fire control how much of the current ordnance we got, so it knows how many it needs to release (all of 'em)
                    pylons.fcs.setRippleDist(aircraft.pacs[aircraft.pacs_current_program].ripple_dist*FT2M);  # PACS Program's ripple dist parameter
                }
                setprop("sim/model/f15/systems/armament/selected-arm", aircraft.pacs[aircraft.pacs_current_program].ordnance_type);
                # Apply Smart Weapon's data if valid
                if (get_status_for_pylon(current_station_rel_idx)[0] == 1 and get_status_for_pylon(current_station_rel_idx)[1] == 0 and pylons.fcs.selected != nil) {  # Smart Weapon initiated and populated
                    var current_station_ordnance_idx = pylons.fcs.selected[1];
                    var current_station_tgt_mode = 0;  # 0 GPS/INS, 1 RDR TGT
                    
                    if (current_station_ordnance_idx < size(get_data_block_from_pylon_idx(current_station_rel_idx).data)) {  # Make sure the data for the sub-ordnance is initialized
                        var current_station_tgt_mode = get_data_block_from_pylon_idx(current_station_rel_idx).data[current_station_ordnance_idx].type;
                    } else {
                        var current_station_gps_data = nil;
                    }
                    
                    var current_station_gps_data = nil;
                    var current_station_rdr_data = nil;
                    if (current_station_tgt_mode == 0) {
                        current_station_gps_data = get_data_block_from_pylon_idx(current_station_rel_idx).data[current_station_ordnance_idx].gps;
                    } elsif (current_station_tgt_mode == 1) {
                        current_station_rdr_data = get_data_block_from_pylon_idx(current_station_rel_idx).data[current_station_ordnance_idx].radar_target;
                    }
                    
                    if (current_station_gps_data != nil) {
                        current_station_gps_data = get_data_block_from_pylon_idx(current_station_rel_idx).data[current_station_ordnance_idx].gps;
				        if (current_station_gps_data.lat() < 90 and current_station_gps_data.lat() > -90 and current_station_gps_data.lon() < 180 and current_station_gps_data.lon() > -180 and pylons.fcs != nil) {
					        var wp = pylons.fcs.getSelectedWeapon();
					        if (wp != nil and wp.parents[0] == armament.AIM and wp.target_pnt == 1 and (wp.guidance=="gps" or wp.guidance=="gps-altitude")) {
						        var spot = awg_9.ContactTGP.new("Station" ~ current_station_rel_idx ~ "." ~ current_station_ordnance_idx ~ "-TGT",current_station_gps_data,0);
						        armament.contactPoint = spot;
						        tgp.gps = 1;
						        if (getprop("sim/model/f15/stores/tgp-mounted") and 0) {
							        tgp.flir_updater.click_coord_cam = armament.contactPoint.get_Coord();
							        callsign = armament.contactPoint.getUnique();
			                        setprop("/sim/model/f15/flir/target/auto-track", 1);
			                        flir_updater.offsetP = 0;
			                        flir_updater.offsetH = 0;
							        setprop("sim/model/f15/avionics/tgp-lock", 1);
						        }
						        wp.setContacts([spot]);
						        wp.arming_time = pacs[pacs_current_program].tarm;
						        wp.data = get_data_block_from_pylon_idx(current_station_rel_idx).telemetry;  # Datalink telemetry
					        }
				        }
                    } elsif (current_station_rdr_data != nil) {
                        current_station_rdr_data = get_data_block_from_pylon_idx(current_station_rel_idx).data[current_station_ordnance_idx].radar_target;
                        var wp = pylons.fcs.getSelectedWeapon();
                        if (wp != nil and wp.parents[0] == armament.AIM and (wp.type == "AGM-84D" or wp.type == "AGM-158C")) {
                            current_station_rdr_data = get_data_block_from_pylon_idx(current_station_rel_idx).data[current_station_ordnance_idx].radar_target;
                            wp.guidance = "inertial";

                            wp.setContacts([current_station_rdr_data]);
                            wp.Tgt = current_station_rdr_data;
                            
                            wp.loft_alt = get_data_block_from_pylon_idx(current_station_rel_idx).data[current_station_ordnance_idx].skim_ft;
                            wp.arming_time = pacs[pacs_current_program].tarm;
                            wp.data = get_data_block_from_pylon_idx(current_station_rel_idx).telemetry;  # Datalink telemetry
                        } elsif (wp != nil and wp.parents[0] == armament.AIM and (wp.type == "AGM-88E")) {
                            current_station_rdr_data = get_data_block_from_pylon_idx(current_station_rel_idx).data[current_station_ordnance_idx].radar_target;
                            wp.guidance = "radiation";

                            wp.setContacts([current_station_rdr_data]);
                            wp.Tgt = current_station_rdr_data;
                            
                            wp.loft_alt = math.clamp(getprop("instrumentation/altimeter/indicated-altitude-ft") + 10000, 10000, 40000);
                            wp.arming_time = pacs[pacs_current_program].tarm;
                            wp.data = get_data_block_from_pylon_idx(current_station_rel_idx).telemetry;  # Datalink telemetry
                        }
                    }
                }
            } else {
                pylons.fcs.selectNothing();
                setprop("sim/model/f15/systems/armament/selected-arm", "");
            }
            
            setprop("sim/model/f15/systems/armament/selected-arm", aircraft.pacs[aircraft.pacs_current_program].ordnance_type);
        } else {
            pylons.fcs.selectNothing();
            setprop("sim/model/f15/systems/armament/selected-arm", "");
        }
    } else {
        pylons.fcs.selectNothing();
        setprop("sim/model/f15/systems/armament/selected-arm", "");
    }
    setCockpitLights();
    if (get_sel_missile_count() == 0) {
        setprop("sim/model/f15/systems/armament/selected-arm", "");
    }
}
setlistener(ArmSwitch, arm_selector, nil, 0);
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
		
		# All smart weapons are automatically initialized
		for (var i = 0; i < size(smart_weapons_data_blocks); i += 1) {
            if (contains(displays.SmartWeaps, getprop("payload/armament/station/id-"~smart_weapons_data_blocks[i].pylon_idx~"-type"))) {  # We're reusing the LAD's SmartWeaps variable here
		        smart_weapons_data_blocks[i].initiated = 1;
		    }
        }
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

var flareCount = -1;
var chaffCount = -1;
var flareStart = -1;
var sendChaff = 0;
var sendFlare = 0;

var flareLoop = func {
  # Flare release
  if (getprop("ai/submodels/submodel[5]/flare-release-snd") == nil) {
    setprop("ai/submodels/submodel[5]/flare-release-snd", 0);
    setprop("ai/submodels/submodel[5]/flare-release-out-snd", 0);
  }
  if (getprop("ai/submodels/submodel[5]/chaff-release-snd") == nil) {
    setprop("ai/submodels/submodel[5]/chaff-release-snd", 0);
    setprop("ai/submodels/submodel[5]/chaff-release-out-snd", 0);
  }
  var flareOn = getprop("ai/submodels/submodel[5]/flare-release-cmd");  # generic, same for flares and chaffs
  if (flareOn == 1 and getprop("ai/submodels/submodel[5]/flare-release") == 0
      and getprop("ai/submodels/submodel[5]/flare-release-out-snd") == 0
      and getprop("ai/submodels/submodel[5]/flare-release-snd") == 0
      and getprop("ai/submodels/submodel[5]/chaff-release") == 0
      and getprop("ai/submodels/submodel[5]/chaff-release-out-snd") == 0
      and getprop("ai/submodels/submodel[5]/chaff-release-snd") == 0) {
    flareCount = getprop("ai/submodels/submodel[5]/count");
    chaffCount = getprop("ai/submodels/submodel[13]/count");
    flareStart = getprop("sim/time/elapsed-sec");
    if (getprop("fdm/jsbsim/systems/electrics/ac-essential-bus1") > 0 and getprop("sim/model/f15/epawss/expendables-master")) {
    
      # depending on the expendables sel switch, we release flares, chaffs, or boths
      if (getprop("sim/model/f15/epawss/expendables-sel") == 0) {  # "both" mode
        sendFlare = 1;
        sendChaff = 1;
      } elsif (getprop("sim/model/f15/epawss/expendables-sel") == 1) {  # "flare" mode
        sendFlare = 1;
        sendChaff = 0;
      } elsif (getprop("sim/model/f15/epawss/expendables-sel") == 2) {  # "chaff" mode
        sendFlare = 0;
        sendChaff = 1;
      } elsif (getprop("sim/model/f15/epawss/expendables-sel") == 3) {  # "auto" mode  (TODO make it)
        # The logic behind it:
        # When a level is true, it's its parameter that are chosen, and other levels ain't ran
        # 1st level # If we got a MLW or a MAW # chaff
        # 2nd level # If we're getting spiked (by any type) # chaff+flare
        # if they're all false, we choose only flare
        if (getprop("payload/armament/MAW-active") or getprop("payload/armament/MAW-semiactive") or (getprop("sound/rwr-launch") != "" and getprop("sound/rwr-launch") != nil)) {
            sendChaff = 1;
            sendFlare = 0;
        } elsif (getprop("payload/armament/spike-air") or getprop("payload/armament/spike-gnd-02") or getprop("payload/armament/spike-gnd-11") or getprop("payload/armament/spike-gnd-20") or getprop("payload/armament/spike-gnd-23") or getprop("payload/armament/spike-gnd-p2") or getprop("payload/armament/spike-gnd-nk")) {
            sendChaff = 1;
            sendFlare = 1;
        } else {
            sendFlare = 1;
            sendChaff = 0;
        }
      }
      
      # make sure we still got flares and chaffs to spare
      if (flareCount <= 0) {
        sendFlare = 0;
      }
      if (chaffCount <= 0) {
        sendChaff = 0;
      }
      
      if (sendFlare) {
        setprop("ai/submodels/submodel[5]/flare-release-snd", 1);
        setprop("ai/submodels/submodel[5]/flare-release", 1);
        setprop("rotors/main/blade[3]/flap-deg", flareStart);  # release a flare
      }
      if (sendChaff) {
        setprop("ai/submodels/submodel[5]/chaff-release-snd", 1);
        setprop("ai/submodels/submodel[5]/chaff-release", 1);
        setprop("rotors/main/blade[3]/position-deg", flareStart);  # release a chaff
      }
    } else {
      # play the sound for outta flares
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
  }
  if (getprop("ai/submodels/submodel[5]/chaff-release-snd") == 1 and (flareStart + delay) < getprop("sim/time/elapsed-sec")) {
    setprop("ai/submodels/submodel[5]/chaff-release-snd", 0);
    setprop("rotors/main/blade[3]/position-deg", 0);
  }
  
  if (getprop("ai/submodels/submodel[5]/flare-release-out-snd") == 1 and (flareStart + delay) < getprop("sim/time/elapsed-sec")) {
    setprop("ai/submodels/submodel[5]/flare-release-out-snd", 0);
  }
  if (getprop("ai/submodels/submodel[5]/chaff-release-out-snd") == 1 and (flareStart + delay) < getprop("sim/time/elapsed-sec")) {
    setprop("ai/submodels/submodel[5]/chaff-release-out-snd", 0);
  }
  
  if (flareCount > getprop("ai/submodels/submodel[5]/count")) {
    # A flare was released in last loop, we stop releasing flares, so user have to press button again to release new.
    setprop("ai/submodels/submodel[5]/flare-release", 0);
    flareCount = -1;
  }
  if (chaffCount > getprop("ai/submodels/submodel[13]/count")) {
    # A flare was released in last loop, we stop releasing flares, so user have to press button again to release new.
    setprop("ai/submodels/submodel[5]/chaff-release", 0);
    chaffCount = -1;
  }
  settimer(flareLoop, 0.1);
};

flareLoop();

# damage already listens to this, but wont work since its aliased, so we gotta listen to what its aliased to also:
setlistener("sim/model/f15/systems/armament/mp-messaging", func {damage.damageLog.push("Damage is now "~(getprop("sim/model/f15/systems/armament/mp-messaging")?"ON.":"OFF."));}, 1, 0);
