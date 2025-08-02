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
# - `RADIO2,<active_channel_mhz>,<standby_channel_mhz>` example: `RADIO2,114.5,135.55`.  - Active and standby MHz frequencies of Radio 2 (Comm 2)
# - `ILS,<active_channel_mhz>,<standby_channel_mhz>,<radial_deg>` example: `ILS,114.5,135.55,284`.  - Active and standby MHz frequencies of ILS (Nav 1) and radial in degrees
# - `TACAN,<tacan_channel_mhz>` example: `TACAN,123.5`.  - TACAN channel, not in '029Y' format but MHz format
# - `GPSSpot,<index>,<latitude_decimal_deg>,<longitude_decimal_deg>,<radius_nm>,<label>,<color_code>,<displayed>` example: `GPSSpot,0,37.2,-115.6,25,SAM,red,1`.  - These are for the
# 'threat circles' displayed on the LAD's HSD and also displayed at some other places. Index can go from 0 to 21. If the radius is equal to 0, it won't be displayed.
# If no label is intended, set `XXX` as the label. <displayed> should be either 1 or 0, where 1 enables it and 0 disables it. Here are all the available color codes:
# - red - yellow - blue - rose - purple - orange - green - cyan - marron.
# - `IFF,<iff_hash>` example: `IFF,2547`  - IFF channel, must stay between 1 and 9999.
# - `DATALINK,<datalink_hash>` example: `DATALINK,2547`  - JTIDS/DATALINK channel, must stay between 1 and 9999.
# - `DECKMin,<altitude>,<enabled>` example: `DECKMin,10000,1`  - Configures the minimum altitude deck. <altitude> is the altitude (in feet) at which if
# the pilot goes under, a `altitude` warning will set off. <enabled> should be either 1 or 0, where 1 enables it and 0 disables it.
# - `DECKMax,<altitude>,<enabled>` example: `DeckMax,42000,1`  - Configures the maximum altitude deck. <altitude> is the altitude (in feet) at which if
# the pilot goes over, a `altitude` warning will set off. <enabled> should be either 1 or 0, where 1 enables it and 0 disables it.
# - `BINGO,<fuel_lbs>` example: `BINGO,7500`  - Sets the amount of fuel (in lbs) at which the bingo warning sets off.
# - `SQUAWK,<4-digit-code>` example : `SQUAWK,1200`  - Sets the transponder's code
# - `STPT,<index>,<latitude_decimal_deg>,<longitude_decimal_deg>,<altitude-ft>` example: `STPT,0,37.2,-115.6,12000`  - Adds a steerpoint (waypoint on the route-manager).
# <index> is the index of the Steerpoint, defining its order (if it's 0, it'll be the first one on the route, 4 the fourth one.). If you don't want a specific
# altitude for the steerpoint, set the <altitude-ft> parameter to -9999.
# - `BULLSEYE,<latitude_decimal_deg>,<longitude_decimal_deg>,<altitude-feet>` example: `BULLSEYE,37.2,-115.6,0`  -  Coordinates for the bullseye
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
# Author: Jimmy L. Miles
# ---------------------------

var dtcLast = nil;  # variable to store the latest touched data cartridge's data

# Takes in parameter the path to the cartride file.
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
            } elsif (key == "RADIO1") {
                setprop("instrumentation/comm[0]/frequencies/selected-mhz", num(items[1]));
                setprop("instrumentation/comm[0]/frequencies/standby-mhz", num(items[2]));
            } elsif (key == "RADIO2") {
                setprop("instrumentation/comm[1]/frequencies/selected-mhz", num(items[1]));
                setprop("instrumentation/comm[1]/frequencies/standby-mhz", num(items[2]));
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
    ret = ret~sprintf("ILS,%.2f,%.2f,%3d|", getprop("instrumentation/nav[0]/frequencies/selected-mhz"), getprop("instrumentation/nav[0]/frequencies/standby-mhz"), getprop("instrumentation/nav[0]/radials/selected-deg"));
    ret = ret~sprintf("BINGO,%d|", getprop("sim/model/f15/controls/fuel/bingo"));
    ret = ret~sprintf("SQUAWK,%d|", getprop("instrumentation/transponder/id-code"));
    ret = ret~sprintf("TACAN,%.2f|", getprop("instrumentation/tacan/frequencies/selected-mhz"));
    ret = ret~sprintf("DECKMin,%d,%d|", getprop("sim/model/f15/avionics/altitude-deck-min"), getprop("sim/model/f15/avionics/altitude-deck-min-enabled"));
    ret = ret~sprintf("DECKMax,%d,%d|", getprop("sim/model/f15/avionics/altitude-deck-max"), getprop("sim/model/f15/avionics/altitude-deck-max-enabled"));
    ret = ret~sprintf("BULLSEYE,%.4f,%.4f,%d|", getprop("sim/model/f15/fcs/bullseye-lat"), getprop("sim/model/f15/fcs/bullseye-lon"), getprop("sim/model/f15/fcs/bullseye-alt"));

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
