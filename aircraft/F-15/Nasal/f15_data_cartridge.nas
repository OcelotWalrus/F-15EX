#
# F-15EX Eagle II Data Cartridges
# ---------------------------
# Allows the pilot to load mission data into the aircraft by loading a local file
# (datalink, iff, radio and tacan channels, threat circles, routes, steerpoints, bullseye, altitude decks etc.),
# but also to save it to a file for other pilots. Extension for F-15EX cartridges files is *.f15dtc. F-15EX cartridges
# files are not compatible with F-16 cartridges, as they contain more information and use different symbologies. Though,
# it isn't difficult to manually convert
# ---------------------------
# Explanation :
# In the .f15dtc file, you simply have one long life of text, with 'data blocks'. Each data block
# is a string of text separated by '|'. A data block has a 'callsign', defining its type, and
# then different numbers giving information about that data block, all separated by commas. Here
# are all the different data block types:
# - `RADIO1,<active_channel_mhz>,<standby_channel_mhz>` example: `RADIO1,114.5,135.55`.  - Active and standby MHz frequencies of Radio 1 (Comm 1)
# - `RADIO1Block,<block_id>,<channel_mhz>` example: `RADIO1Block,8,109.10`.   - Stored frequency presets for Radio 1 (Comm 1). There are 20 presets, from 0 to 19
# - `RADIO2,<active_channel_mhz>,<standby_channel_mhz>` example: `RADIO2,114.5,135.55`.  - Active and standby MHz frequencies of Radio 2 (Comm 2)
# - `RADIO2Block,<block_id>,<channel_mhz>` example: `RADIO2Block,8,109.10`.   - Stored frequency presets for Radio 2 (Comm 2). There are 20 presets, from 0 to 19
# - `ILS,<active_channel_mhz>,<standby_channel_mhz>,<radial_deg>` example: `ILS,114.5,135.55,284`.  - Active and standby MHz frequencies of ILS (Nav 1) and radial setting in degrees
# - `NAV1Block,<block_id>,<channel_mhz>` example: `NAV1Block,8,109.10`.   - Stored frequency presets for ILS (Nav 1). There are 16 presets, from 1 to 16
# - `NAV2,<active_channel_mhz>,<standby_channel_mhz>,<radial_deg>` example: `NAV2,114.5,135.55,284`.  - Active and standby MHz frequencies of Nav 2 radio and radial setting in degrees
# - `TACAN,<tacan_channel_mhz>` example: `TACAN,123.5`.  - TACAN channel, not in '029Y' format but MHz format
# - `GPSSpot,<index>,<latitude_decimal_deg>,<longitude_decimal_deg>,<radius_nm>,<label>,<color_code>,<displayed>` example: `GPSSpot,0,37.2,-115.6,25,SAM,red,1`.  - These are for the
# 'threat circles' displayed on the LAD's HSD and also displayed at some other places. Index can go from 0 to 21. If the radius is equal to 0, it won't be displayed.
# If no label is intended, set `XXX` as the label. <displayed> should be either 1 or 0, where 1 enables it and 0 disables it. Here are all the available color codes:
# - red - yellow - blue - rose - purple - orange - green - cyan - marron.
# - `IFF,<iff_hash>` example: `IFF,2547`  - IFF Mode 4/5 channel, must stay between 1 and 9999.
# - `DATALINK,<datalink_hash>` example: `DATALINK,2547`  - JTIDS Link 16 channel, must stay between 1 and 9999.
# - `DECKMin,<altitude>,<enabled>` example: `DECKMin,10000,1`  - Configures the minimum altitude deck. <altitude> is the altitude (in feet) at which if
# the pilot goes under, a `altitude` warning will set off. <enabled> should be either 1 or 0, where 1 enables it and 0 disables it.
# - `DECKMax,<altitude>,<enabled>` example: `DeckMax,42000,1`  - Configures the maximum altitude deck. <altitude> is the altitude (in feet) at which if
# the pilot goes over, a `altitude` warning will set off. <enabled> should be either 1 or 0, where 1 enables it and 0 disables it.
# - `BINGO,<fuel_lbs>` example: `BINGO,7500`  - Sets the amount of fuel (in lbs) at which the bingo warning sets off.
# - `SQUAWK,<4-digit-code>` example : `SQUAWK,1200`  - Sets the IFF Mode 3/A transponder's code
# - `STPT,<index>,<latitude_decimal_deg>,<longitude_decimal_deg>,<altitude-ft>` example: `STPT,0,37.2,-115.6,12000`  - Adds a steerpoint (waypoint on the route-manager).
# <index> is the index of the Steerpoint, defining its order (if it's 0, it'll be the first one on the route, 4 the fourth one.). If you don't want a specific
# altitude for the steerpoint, set the <altitude-ft> parameter to -9999.
# - `BULLSEYE,<latitude_decimal_deg>,<longitude_decimal_deg>,<altitude-feet>` example: `BULLSEYE,37.2,-115.6,0`  -  Coordinates for the bullseye. Set all values to 0 for no bullseye designation
# - `MISSION,<mission_set_id>,<mission_program_id>,<latitude_decimal_deg>,<longitude_decimal_deg>,<altitude-feet>,<terminal_heading_true_deg>,<terminal_angle_deg>,<terminal_velocity_fps>,<initialized/enabled>` example: `MISSION,1,21,37.2894,76.5432,3443,230,75,800,1` - Sets up a Mission Program. Mission Programs are stored into Mission Sets. You have 4 slot from 0 to 3 for Mission Sets, and 40 slots from 0 to 39 for Mission Programs. Terminal parameters are available but not functional yet. Initialized is a boolean, determining whether that program is enabled or not.
# ---------------------------
# Notes:
# - When loading a DTC, if data blocks such as DECKMin are missing, it won't cause a bug, though the minimum altitude
# deck won't be applied. That means that if you're writing the data cartridge by hand, even if some data blocks do not
# matter to you, set them at a 'standby' value so that you make sure they're disabled. You don't have to worry about
# that when saving it through the Eagle II pre-planning in-game GUI dialog.
# - When loading data cartridges, if unique data blocks - such as DATALINK - are set multiple times, it's the
# latest iteration that will actually matter.
# - All parameters inside a data block must be present for the program to function, or else, it won't load.
# - If a steerpoint is given an index of 0 and the following one, not 1 but 2, it'll still load correctly,
# the following one being acknowledged as index 1 even if 2 was stated
# ---------------------------
# Planned Features:
# - Allow to set flight callsigns, so they're in a different color and symbology in the LAD, and also set a
# flight lead callsign, so its bearing, ETA and distance gets displayed along Bullseye ETA etc. Flight
# callsigns and lead will need to be connected on datalink for that to work
# ---------------------------
# Author: Jimmy L. Miles
# ---------------------------

var dtcLast = nil;  # variable to store the latest touched data cartridge's data

# Takes in parameter the path to the cartridge file.
var load_cartridge = func(path) {
    path_value = path.getValue();

    var text = nil;
    call(func{text=io.readfile(path_value);},nil, var err = []);
    if (size(err)) {
      print("Loading DTC failed.");
      setprop("sim/model/f15/preplanning-status", err[0]);
    } elsif (text != nil) {

        # Here we actually parse the data in it
        var blocks = split("|", text);
        var planned = nil;  # If we got a flight plan


        foreach(item; blocks) {
            var items = split(",", item);
            var key = items[0];

            if (key == "DATALINK") {
                setprop("instrumentation/datalink/channel", num(items[1]));
            } elsif (key == "IFF") {
                setprop("instrumentation/iff/channel-selection", num(items[1]));
            } elsif (key == "BINGO") {
                setprop("sim/model/f15/controls/fuel/bingo", num(items[1]));
            } elsif (key == "SQUAWK") {
                setprop("instrumentation/transponder/id-code", num(items[1]));
            } elsif (key == "TACAN") {
                setprop("instrumentation/tacan/frequencies/selected-mhz", num(items[1]));
            } elsif (key == "DECKMin") {
                setprop("sim/model/f15/avionics/altitude-deck-min", num(items[1]));
                setprop("sim/model/f15/avionics/altitude-deck-min-enabled", num(items[2]));
            } elsif (key == "DECKMax") {
                setprop("sim/model/f15/avionics/altitude-deck-max", num(items[1]));
                setprop("sim/model/f15/avionics/altitude-deck-max-enabled", num(items[2]));
            } elsif (key == "ILS") {
                setprop("instrumentation/nav[0]/frequencies/selected-mhz", num(items[1]));
                setprop("instrumentation/nav[0]/frequencies/standby-mhz", num(items[2]));
                setprop("instrumentation/nav[0]/radials/selected-deg", num(items[3]));
            } elsif (key == "NAV1Block") {
                setprop("instrumentation/nav[0]/frequencies/data-"~num(items[1])~"-freq", num(items[2]));
            } elsif (key == "NAV2") {
                setprop("instrumentation/nav[1]/frequencies/selected-mhz", num(items[1]));
                setprop("instrumentation/nav[1]/frequencies/standby-mhz", num(items[2]));
                setprop("instrumentation/nav[1]/radials/selected-deg", num(items[3]));
            } elsif (key == "RADIO1") {
                setprop("instrumentation/comm[0]/frequencies/selected-mhz", num(items[1]));
                setprop("instrumentation/comm[0]/frequencies/standby-mhz", num(items[2]));
            } elsif (key == "RADIO2") {
                setprop("instrumentation/comm[1]/frequencies/selected-mhz", num(items[1]));
                setprop("instrumentation/comm[1]/frequencies/standby-mhz", num(items[2]));
            } elsif (key == "RADIO1Block") {
                setprop("sim/model/f15/instrumentation/an-arc-182v/presets/frequency["~num(items[1])~"]", num(items[2]));
            } elsif (key == "RADIO2Block") {
                setprop("sim/model/f15/instrumentation/an-arc-159v1/presets/frequency["~num(items[1])~"]", num(items[2]));
            } elsif (key == "BULLSEYE") {
                setprop("sim/model/f15/fcs/bullseye-lat", num(items[1]));
                setprop("sim/model/f15/fcs/bullseye-lon", num(items[2]));
                setprop("sim/model/f15/fcs/bullseye-alt", num(items[3]));
            } elsif (key == "GPSSpot") {
                spot_index = num(items[1]);
                spot_lat = num(items[2]);
                spot_lon = num(items[3]);
                spot_radius = num(items[4]);
                spot_label = items[5];
                if (spot_label == "XXX") {  # code for "no label"
                    spot_label = "";
                }
                spot_color = items[6];
                spot_enabled = num(items[7]);
                aircraft.push_threat_circle_data_from_dtc(spot_index, spot_lat, spot_lon, spot_radius, spot_label, spot_color, spot_enabled);  # push it to the GPSSpots data
            } elsif (key == "STPT") {
                spot_index = num(items[1]);
                spot_lat = num(items[2]);
                spot_lon = num(items[3]);
                spot_alt = num(items[4]);
                if (planned == nil) planned = createFlightplan();
                var plan = planned;
                var wp = createWP(spot_lat, spot_lon, sprintf("STPT-%02d",spot_index+1));
                plan.insertWP(wp, spot_index);
                if (spot_alt != -9999) {  # code for "no-altitude"
                    var leg = plan.getWP(plan.getPlanSize()-1);
                    leg.setAltitude(spot_alt, "at");
                }
            } elsif (key == "MISSION") {
                mission_set_id = num(items[1]);
                mission_program_id = num(items[2]);
                mission_lat = num(items[3]);
                mission_lon = num(items[4]);
                mission_alt = num(items[5]);
                mission_terminal_head = num(items[6]);
                mission_terminal_angle = num(items[7]);
                mission_terminal_vel = num(items[8]);
                mission_initialized = num(items[9]);
                aircraft.push_mission_program_from_dtc (mission_set_id, mission_program_id, mission_lat, mission_lon, mission_alt, mission_terminal_head, mission_terminal_angle, mission_terminal_vel, mission_initialized);
            }
        }
        if (planned != nil) {
            fgcommand("activate-flightplan", props.Node.new({"activate": 0}));
            planned.activate();
            fgcommand("activate-flightplan", props.Node.new({"activate": 1}));
        }
    }
    setprop("sim/model/f15/preplanning-status", "DTC data loaded");
    dtcLast = string.truncateAt(io.basename(path_value),".f15dtc");
}

var save_cartridge = func(path) {
    path_value = path.getValue();

    ret = "";
    ret = ret~sprintf("IFF,%d|", getprop("instrumentation/iff/channel-selection"));
    ret = ret~sprintf("DATALINK,%d|", getprop("instrumentation/datalink/channel"));
    ret = ret~sprintf("COM1,%.2f,%.2f|", getprop("instrumentation/comm[0]/frequencies/selected-mhz"), getprop("instrumentation/comm[0]/frequencies/standby-mhz"));
    ret = ret~sprintf("COM2,%.2f,%.2f|", getprop("instrumentation/comm[1]/frequencies/selected-mhz"), getprop("instrumentation/comm[1]/frequencies/standby-mhz"));
    ret = ret~sprintf("ILS,%.2f,%.2f,%03d|", getprop("instrumentation/nav[0]/frequencies/selected-mhz"), getprop("instrumentation/nav[0]/frequencies/standby-mhz"), getprop("instrumentation/nav[0]/radials/selected-deg"));
    ret = ret~sprintf("NAV2,%.2f,%.2f,%03d|", getprop("instrumentation/nav[1]/frequencies/selected-mhz"), getprop("instrumentation/nav[1]/frequencies/standby-mhz"), getprop("instrumentation/nav[1]/radials/selected-deg"));
    ret = ret~sprintf("BINGO,%d|", getprop("sim/model/f15/controls/fuel/bingo"));
    ret = ret~sprintf("SQUAWK,%d|", getprop("instrumentation/transponder/id-code"));
    ret = ret~sprintf("TACAN,%.2f|", getprop("instrumentation/tacan/frequencies/selected-mhz"));
    ret = ret~sprintf("DECKMin,%d,%d|", getprop("sim/model/f15/avionics/altitude-deck-min"), getprop("sim/model/f15/avionics/altitude-deck-min-enabled"));
    ret = ret~sprintf("DECKMax,%d,%d|", getprop("sim/model/f15/avionics/altitude-deck-max"), getprop("sim/model/f15/avionics/altitude-deck-max-enabled"));
    ret = ret~sprintf("BULLSEYE,%.4f,%.4f,%d|", getprop("sim/model/f15/fcs/bullseye-lat"), getprop("sim/model/f15/fcs/bullseye-lon"), getprop("sim/model/f15/fcs/bullseye-alt"));
    
    # Go through each Comm 1 frequency preset data blocks
    for (var idx = 0; idx < 20; idx += 1) {  # We got 20 data blocks, starting from id 0
        prop_path = "sim/model/f15/instrumentation/an-arc-182v/presets/frequency[" ~ idx ~ "]";
        ret = ret~sprintf("RADIO1Block,%d,%.2f|", idx, getprop(prop_path));
    }
    
    # Go through each Comm 2 frequency preset data blocks
    for (var idx = 0; idx < 20; idx += 1) {  # We got 20 data blocks, starting from id 0
        prop_path = "sim/model/f15/instrumentation/an-arc-159v1/presets/frequency[" ~ idx ~ "]";
        ret = ret~sprintf("RADIO2Block,%d,%.2f|", idx, getprop(prop_path));
    }
    
    # Go through each NAV1 frequency preset data blocks
    for (var idx = 1; idx < 17; idx += 1) {  # We got 16 data blocks, starting from id 1
        prop_path = "instrumentation/nav[0]/frequencies/data-" ~ idx ~ "-freq";
        ret = ret~sprintf("NAV1Block,%d,%.2f|", idx, getprop(prop_path));
    }

    var idx = 0;
    # Go through each DTC GPS Spots and push 'em
    foreach(gps_spot; aircraft.threat_circles) {
        spot_index = idx;
        spot_lat = gps_spot.lat;
        spot_lon = gps_spot.lon;
        spot_radius = gps_spot.radius;
        spot_label = gps_spot.label;
        if (spot_label == "") {
            spot_label = "XXX";  # code for "no label"
        }
        spot_color = gps_spot.color;
        spot_enabled = gps_spot.enabled;
        ret = ret~sprintf("GPSSpot,%d,%.5f,%.5f,%.2f,%s,%s,%d|", spot_index, spot_lat, spot_lon, spot_radius, spot_label, spot_color, spot_enabled);
        idx += 1;
    }
    
    # Go through each DTC Mission Sets/Programs an push 'em
    for (var i = 0; i < aircraft.mission_sets_max; i += 1) {
        for (var y = 0; y < aircraft.mission_programs_max; y += 1) {
            curr_mission = aircraft.mission_sets[i][y];
            mission_lat = curr_mission.gps.lat();
            mission_lon = curr_mission.gps.lon();
            mission_alt = curr_mission.gps.alt()*M2FT;
            mission_terminal_head = curr_mission.terminal.heading;
            mission_terminal_angle = curr_mission.terminal.angle;
            mission_terminal_vel = curr_mission.terminal.vel;
            mission_initialized = curr_mission.initialized;
            ret = ret~sprintf("MISSION,%d,%02d,%.5f,%.5f,%.2f,%03d,%03d,%04d,%d|", i, y, mission_lat, mission_lon, mission_alt, mission_terminal_head, mission_terminal_angle, mission_terminal_vel, mission_initialized);
        }
    }

    plan = flightplan();
    var planSize = plan.getPlanSize();
    # Go through each waypoint in the route manager and push 'em
    for (var idx = 0; idx < planSize; idx += 1) {
        var wp = plan.getWP(idx);
        wp_lat = wp.lat;
        wp_lon = wp.lon;
        wp_alt = -9999;  # code for "no altitude"
        if (wp.alt_cstr != nil) {  # steerpoints don't necessarily got an altitude
            wp_alt = wp.alt_cstr;
        }
        ret = ret~sprintf("STPT,%d,%.5f,%.5f,%d|", idx, wp_lat, wp_lon, wp_alt);
    }

    var text = ret;

    var opn = nil;
    call(func{opn = io.open(path_value,"w");},nil, var err = []);
    if (size(err) or opn == nil) {
        print("error open file for writing Data Cartridge data");
        return 0;
    }
    call(func{var text = io.write(opn,text);},nil, var err = []);
    if (size(err)) {
        print("error writing Data Cartridge File");
        setprop("sim/model/f15/preplanning-status", err[0]);
        io.close(opn);
        return 0;
    } else {
        io.close(opn);
        setprop("sim/model/f15/preplanning-status", "DTC data saved");
        dtcLast = string.truncateAt(io.basename(path_value),".f15dtc");
        return 1;
    }
}
