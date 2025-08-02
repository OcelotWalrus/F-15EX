# F-15EX EPAWSS (Eagle Passive Active Warning Survivability System)
# ---------------------------
# The EPAWSS is the Eagle II's RWR that detects airborne, ground or ship-based
# radars, identifies them as threats or not, filter threats to give the pilot which threat
# is the primary at the situation, detects missile launches and airborne missile activities.
# ---------------------------
# Available Functions :
# ---------------------------
# Stats:
# - The EPAWSS' range is said to be 222 km, which is 120 NM. That includes detection of radars and missile launches.
# ---------------------------
# Notes :
# - For optimization concerns, we run the targets' update loop every .5 secondes, but it's actually
# ran only if a model was added or removed in the sim.
# - Aspects of the code such as the contacts list update is parts of the awg_9.nas's own update function.
# - The awg_9.nas's Target class is reused by the EPAWSS.
# - How the EPAWSS sorts threats is in the following way: different conditions add up points. The contact with the most points is defined as primary threat.
#  supreme level - an approaching missile - + 9999 (overrides anything else. if they're multiple, we take the one with the biggest closure rate / dist ratio)
#  1st level - a target that we've detected launching a missile less than 5 mins ago - +100
#  2nd level - if the threat's spiking us - +75
#  3rd level - if the threat's ECM signal is of the highest norm (ECM norm 1) + 50
#  4th level - if the threat's ECM signal is higher than 3 (ECM norm 2) + 25
#  5th level - if the threat's a SAM or an AAA (but not necessarily locking us) + 10
#  6th level - if the threat's heading toward us + 40 (-1 points per degree away from us in bearing)
#  7th level - if it's an AEW&C + 10
#  and also: -1/2 points per 1 NM of distance between the aircraft and the EPAWSS contact.
#  and also: +10 points per 25 kts of closure rate. (ratio so it's actually 2.5 points per 1 kt of closure rate, can remove points if closure rate is negative)
# ---------------------------
# Future features (TODO's) :
# - For the AI light and its sound, move it from the awg_9.nas to the epawss.nas file, and check if it's a friendly or not
# - Add the EPAWSS to the systems, so it can be damaged by missiles and etc.
# - Make the EPAWSS panel on the right panel of the interiors.
# ---------------------------
# Author: Jimmy L. Miles
# ---------------------------

# Constants
var epawss_range = 120;  # 120 NM
var scan_update_tgt_list = 1;  # boolean, gets set to 1 when a new model has been added the the world or when the radar filter mode (A/A, A/G, A/SEA) has been changed
var scan_update_visibility = 1;
var contacts_list_callsigns = [];  # list of callsigns of all EPAWSS contacts
var former_contacts_list_callsigns = [];  # list of callsigns of all EPAWSS contacts of the last scan
var contacts_list = [];  # list of all EPAWSS contacts, all children of the awg_9.Target class
var new_threats = [];  # Used when displaying EPAWSS contacts, allowing to highlight new threats from already-detected ones. List of callsigns
var EpawssOn = props.globals.getNode("sim/model/f15/epawss/epawss-on", 1);  # EPAWSS RWR master switch
var Mp = props.globals.getNode("ai/models");
var ElapsedSec = props.globals.getNode("sim/time/elapsed-sec");
var scan_next_tgt_check = ElapsedSec.getValue() + 2;
var ScanVisibilityCheckInterval = props.globals.getNode("instrumentation/radar/scan_visibility_check_interval", 1);
var primary_threat_callsign = "";

var AIR = 0;
var MARINE = 1;
var SURFACE = 2;
var ORDNANCE = 3;

var knownShips = {
    "missile_frigate":       nil,
    "frigate":       nil,
    "fleet":       nil,
    "USS-LakeChamplain":     nil,
    "USS-NORMANDY":     nil,
    "USS-OliverPerry":     nil,
    "USS-SanAntonio":     nil,
};

var knownSurface = {
    "buk-m2":       nil,
    "s-300":       nil,
    "gci":       nil,
    "depot":       nil,
    "truck":     nil,
    "tower":     nil,
    "S-75":     nil,
    "S-200":    nil,
    "S-300":     nil,
    "MIM104D":    nil,
    "s300":        nil,
    "SA-6":        nil,
    "SA-3":            nil,
    "MIM-104D":      nil,
    "zsu-23":      nil,
    "ZSU-IR":       nil,
};

# Listeners
setlistener("/ai/models/model-added", func(v){
    if (!scan_update_tgt_list) {
        scan_update_tgt_list = 1;
    }
});

setlistener("/ai/models/model-removed", func(v){
    if (!scan_update_tgt_list) {
        scan_update_tgt_list = 1;
    }
});

setlistener("instrumentation/radar/radar-filter-mode", func(v){
    if (!scan_update_tgt_list) {
        scan_update_tgt_list = 1;
    }
});

setlistener("sim/model/f15/epawss/epawss-on", func(v){
    contacts_list = [];
    scan_update_tgt_list = 1;
});

# API Functions

var update_epawss_contacts = func() {  # computes the list of contacts of the EPAWSS

    if (scan_update_tgt_list and EpawssOn.getValue())  # we only update if a listener has been set off and the Epawss is online
    {
		scan_update_tgt_list = 0;

        contacts_list = [];

        var raw_list = Mp.getChildren();

        foreach( var c; raw_list )
        {
            var type = c.getName();

            if (c.getNode("valid") == nil or !c.getNode("valid").getValue()) {
                continue;
            }
            var ordnance = 1;
            if (c.getNode("missile") == nil or !c.getNode("missile").getValue()) {
                # a little superflous atm. since the typecheck below will filter out ordnance. Their type look like: aim-9 or agm-88 etc etc.
                ordnance = 0;
            }
            if (type == "multiplayer" or type == "tanker" or type == "aircraft" or type == "carrier"
                or type == "ship" or type == "groundvehicle" or type=="daVinci_SU-34" or type=="F-15EX")   # daVinci_SU-34 and F-15EX are for the training scenario bot
            {
                var u = awg_9.Target.new(c);  # we reuse the radar's target class

                var u_rng = u.get_range();
                if (ordnance) {
                    u.setClass(ORDNANCE);
                } elsif (type == "tanker" or type == "aircraft") {
                    u.setClass(AIR);
                } elsif (type=="carrier") {
                    u.setClass(MARINE);
                } elsif (type=="groundvehicle") {
                    u.setClass(SURFACE);
                } else {
                    # multiplayer or ship:
                    var mdl = u.get_model();
                    if (contains(knownSurface,mdl)) {
                        u.setClass(SURFACE);
                    } elsif (contains(knownShips,mdl)) {
                        u.setClass(MARINE);
                    } elsif (u.get_altitude() < 1.5 and u.get_altitude() > -1.5) {
                        u.setClass(MARINE);
                    } elsif (u.get_Speed() < 60) {
                        u.setClass(SURFACE);
                    }
                    # notice the default class is set to AIR
                }
                append(contacts_list, u);
            }
        }
        scan_update_visibility = 1;
        contacts_list = sort (contacts_list, func (a,b) {a.get_range()-b.get_range()});
    }

    var idx = 0;

    former_contacts_list_callsigns = [];
    foreach(contact; contacts_list_callsigns) {
        append(former_contacts_list_callsigns, contact);
    }
    contacts_list_callsigns = [];
    for (var scan_tgt_idx = 0;scan_tgt_idx < size(contacts_list); scan_tgt_idx += 1) {

        u = contacts_list[scan_tgt_idx];

        var u_rng = u.get_range();



        if (scan_update_visibility) {
            scan_update_visibility = 0;
        } else if (ElapsedSec.getValue() > scan_next_tgt_check) {
            scan_next_tgt_check = ElapsedSec.getValue()  + ScanVisibilityCheckInterval.getValue();
            scan_update_visibility = 1;
        }

        if (scan_update_visibility) {
            # check for visible by EPAWSS taking into account if the contact is
            # emitting, radiating at our coords, or directly spiking us.
            u.set_behind_terrain(0);
            if (!u.get_EPAWSS_visible()) {
                #print("out of EPAWSS detection");
                u.set_visible(0);
            } else if (awg_9.TerrainManager.IsVisible(u.propNode, nil) == 0) {
                #print("behind terrain");
                u.set_behind_terrain(1);
                u.set_visible(0);
            } else {
                #print("visible");
                u.set_visible(1);
            }
            scan_update_visibility = 0;
        }

        var radar_mode = getprop("instrumentation/radar/radar-mode");
        if (radar_mode == nil) {
            radar_mode = 0;
        } if (radar_mode >= 3) {
            radar_active = 0;
        }

        if (u.get_visible()) {
            append(contacts_list_callsigns, u.get_Callsign());
        }

        # Test if target has a radar. Compute if we are illuminated. This propery used by ECM
        # over MP, should be standardized, like "ai/models/multiplayer[0]/radar/radar-standby".
        awg_9.compute_rwr(radar_mode, u, u_rng);
    }

    # We go through each current contacts list, and if there's one or multiple that ain't in the former contacts list, we play the new contact sound
    # Also share our EPAWSS contacts over datalink
    foreach(contact; contacts_list_callsigns) {
        var found = 0;
        foreach(former_contact; former_contacts_list_callsigns) {
            if (former_contact == contact) {
                found = 1;
            }
        }
        if (found == 0) {
            setprop("sim/model/f15/epawss/new-threat", 1);
            settimer(func {setprop("sim/model/f15/epawss/new-threat", 0); }, .4);
            append(new_threats, contact);
            settimer(func {remove(new_threats, contact); }, 45);  # remove it from new threats after 45 seconds (clear the new threat symbol of the LAD's HSD)
        }
        if (getprop("instrumentation/datalink/sending") == 0 and getprop("sim/model/f15/avionics/jtids-selected-mode-knob") != 3) {  # safety, so we ain't overwriting smth that's already being sent over datalink - JTIDS knob 3d position is silent/receive-only mode
            datalink.send_data({"contacts":[{"callsign": contact, "iff": 0}]});
        }
    }
}

var get_radar_type = func(contact) {  # returns either 0 (airborne radar), 1 (ground radar) or 2 (sea radar).
    raw_type = contact.get_type();
    if (raw_type == MARINE) {
        return 2;
    } elsif (raw_type == SURFACE) {
        return 1
    } else {
        return 0;
    }
}

var determine_primary_threat = func() {  # returns the primary threat's internal unique ID and how many points its got in a vector. Returns null if there ain't none
    points_list = [];
    foreach(u; contacts_list) {
        if (u.get_visible()) {  # If it's an actually valid EPAWSS contact
            points = 0;

            is_a_missile_approaching = u.getUnique() != nil and u.get_Callsign() != nil and damage.approached[u.get_Callsign()~u.getUnique()] != nil;
            points += (is_a_missile_approaching and u.get_visible() and damage.approached[u.get_Callsign()~u.getUnique()] < 300) * 9999 + (u.get_closure_rate()/u.get_range());  # if it's an approaching missile. We also add a ratio closure rate/dist to determine which approaching missile is more threatening if they're multiple detected
            if (is_a_missile_approaching) {
                continue;  # go to the next target, skip all below point computing
            }

            is_missile_launcher_points = u.getUnique() != nil and u.get_Callsign() != nil and damage.launched[u.get_Callsign()~u.getUnique()] != nil;
            points += (is_missile_launcher_points and u.get_visible() and damage.launched[u.get_Callsign()~u.getUnique()] < 300) * 100;  # if it's a missile launcher that we've detected (less than 5 mins ago) and it's not hidden by terrain or RCS, we add 100 pts

            points += u.isSpikingMe() * 75;  # 2nd level
            points += (u.get_Ecm_Signal_Norm() == 1) * 50;  # 3nd level
            points += (u.get_Ecm_Signal_Norm() == 2) * 25;  # 4th level

            is_a_sam_or_aaa = (u.get_model() != nil) and (displays.typeLookup[u.get_model()] != nil) and (displays.typeLookup[u.get_model()] == "SAM" or displays.typeLookup[u.get_model()] == "AAA");  # we're reusing the LAD.nas's typeLookup variable
            points += is_a_sam_or_aaa * 10;  # 5th level

            is_approaching = u.isApproaching(geo.aircraft_position());
            if (is_approaching != nil) {
                points += 40 - is_approaching;  # 6th level
            }

            is_an_awacs = (u.get_model() != nil) and (displays.typeLookup[u.get_model()] != nil) and (displays.typeLookup[u.get_model()] == "AEW&C");  # we're reusing the LAD.nas's typeLookup variable
            points += is_an_awacs * 10;  # 7th level

            points -= u.get_range() * .5;  # distance reduction
            points += u.get_closure_rate() * 2.5;  # closure rate increment

            data = {};
            data.unique = u.get_Callsign()~u.getUnique();
            data.points = points;

            append(points_list, data);
        }
    }

    # We go through each in the list, and update the "greatest points" variable if any higher than before
    max_points_num = 0;
    max_points = "";
    callsign = "";
    first = 1;
    foreach(u; points_list) {
        if (first) {
            max_points_num = u.points;
            max_points = u.unique;
        } else {
            if (u.points > max_points_num) {
                max_points_num = u.points;
                max_points = u.unique;
            }
        }
        first = 0;
    }

    primary_threat_callsign = max_points;  # in format `u.get_Callsign()~u.getUnique()`
    return [max_points, max_points_num];
}

var is_missile_launcher = func(contact) {  # simple function to determine if given contact is a missile launcher
    var launchCallsign = getprop("sound/rwr-launch");
    var semiCallsign = getprop("payload/armament/MAW-semiactive-callsign");

    if (contact.get_Callsign() == launchCallsign or contact.get_Callsign() == semiCallsign) {
        return 1;
    } else {
        return 0;
    }
}

# Loops
update_list_epawss = maketimer(.5, update_epawss_contacts);
update_primary_threat = maketimer(.5, determine_primary_threat);

update_list_epawss.start();
update_primary_threat.start();
