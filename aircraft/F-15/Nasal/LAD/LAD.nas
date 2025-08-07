# F-15EX Canvas LAD (Large Area Display)
# ---------------------------
# The LAD is a 10" (height) by 19" (width) colored touchscreen display,
# With 3 main displays (each allowing to display the target pod's view,
# the FLIR's view (if a LANTIRN Nav Pod is loaded and armed), a HSD and a VSD,
# and 5 MPCDs below that, aligned in a single line, allowing full control
# over the avionics, the weaponry and the whole aircraft pretty much.
# ---------------------------
# Available Displays :
# - VSD (Vertical Situation Display)  - covers radar, navigation, datalink and pretty much everything
# - HSD (Horizontal Situation Display)  - covers radar, navigation, datalink, EPAWSS, radio and pretty much everything
# - PACS (Programmable Armament Control Set)  - allows to see different stats about current pylons and loadout, and setup jettison
# Upcoming Displays :
# - ADI (Attitude Director Indicator)
# - JTIDS (Datalink Sharing & Receiving Control Set)  - People on datalink, number of hostiles, friendlies and unknowns, number of locally shared radar and EPAWSS contacts, and a panel to check received GPS-Spots and send GPS-Spots + basic map just giving pos of datalink contacts, with a tactile button allowing to go through contacts like in radar and get info about them
# - ETSD (EPAWSS Threat Summary Display)  - Number of contacts, number of threats, jamming on/off, datalink sharing on/off, active threat yes/no + type(MLW, MAW, spike) + basic HSD with info toward EPAWSS
# - TSD (Tactical Situation Display)  - Actually, merge that with the HSD (just an imagery map beneath every symbology)
# - TPOD (Targeting Pod)  - Allows to configure the targeting pod and actively control it
# - NFLIR (Navigation Forward-Looking Infrared)  - Allows to configure the FLIR pod and actively look through it
# - IRST (Infrared Search & Track)  - Allows to configure the Legion IRST pod and actively look through it and control it and track heat signatures. (Implement Legion IRST Pod functionalities first)
# - FCTRLS (Flight Controls)  - A display like in the EX interiors photo where you can see the state of every flight controls (elevators, flaps, rudders, etc.), as well as if they're damaged or not
# ---------------------------
# Notes:
# - When displaying contacts, there are 3 types of 'em: radar contacts, datalink contacts and
# EPAWSS contacts. Radar contacts override both datalink and EPAWSS contacts, and datalink
# contacts override EPAWSS contacts. Meaning that if we got a datalink contact, that we already
# got on our radar, it's the radar's info that we're gonna use. And if we got an EPAWSS contact
# that's already on our datalink, or radar, then we don't display it.
# - Due a stupid act o' mine, the height on the canvas is distorted, due to the 3d model on which
# it's projected on being 19" x 10" but the canvas being 8,192px x 8,192px. That makes so that for
# circles to look like circles, they must be ellipses where the horizontal radius is given a scale
# of 10/19 compared to the vertical radius. It also makes so that when converting pixels to nautical
# miles - like in the HSD where range is displayed (not in the VSD for example because in a vertical
# view there's no range [horizontal range to be exact]) - different coefficients must be given, in which
# the coefficient for x coordinates must be given a scale of 10/19 compared to the vertical coefficient.
# That also unfortunately can cause problems with rotations being geometrically correct, but visually
# incorrect, when used alongside translations (when applying a translation AND a rotation to an object).
# ---------------------------
# Future features (TODO's) :
# //VSD Display// :
# - For RWS radar mode, give bleps lil' tails, that are down when closing in and up when evading
# - Display the steering dot, ASE circle.
# - Display the DLZ and the Missile Time Of Launch
# - Use different symbols for SAMs, AAAs and ships contacts
# - Have some text in the upper part, separated by rulers telling distance, bearing and ETA from bullseye (not sure if there's enough room left)
# - For steerpoints that are clamped, use a different symbol to acknowledge that
# - For datalink contacts that are clamped, use a different symbol to acknowledge that
# - Use better symbology for datalink contacts so they're more visible
# //HSD Display// :
# - Display our datalink-compatible ordnance live with their target connected with a dashed line
# - Display threat circles so that they can display on a certain part (if visually there's parts outside and some ain't) Note: (maybe use something like the sit-mask.png)
# - Show true headings around the great circle and make them move to be at the correct position
# - Use different symbols for SAM and AAA contacts
# - Display contacts heading by rotating 'em. FUCK I SPENT 1 DAY TRYNA FIGURE OUT WHY THAT THING IS FUCKED UP AND DONT WORK FOR NO GODDAMN REASON SON OF A
# symbology, without the need of locking it and looking at its closing speed
# - Display the A/P's heading using a pointer
# - Display the TACAN station's pos (useful for tanker or carrier ops), with also bearing (with numbers and a pointer), dist and ETA (TACAN marker symbol F-15E DCS Manual)
# - Display the ILS station's pos (useful for tanker or carrier ops), with also bearing (with numbers and a pointer), dist and ETA
# - Display the bullseye's relative bearing using a pointer around the HSD great circle
# - Display target pod's looking position with a unique symbol
# //PACS Display// :
# - Allow weapons to be programmed when you click on 'em.
# - Add the Jettison page (waiting for the interiors to finish because there are switches that configure jettison in there.
# ---------------------------
# Author: Jimmy L. Miles
# ---------------------------

## Constant Variables

var typeLookup = { # database of known radar signatures
    # Aicraft
    "f-14b":                    "F",     #fighter
    "F-14D":                    "F",
    "F-15C":                    "F",
    "F-15D":                    "F",
    "F-16":                     "F/B",#fighter bomber
    "F-15EX":                   "F/B",#fighter bomber
    "F-35":                     "F/B",#fighter bomber
    "YF-16":                    "F",
    "JA37-Viggen":              "F",
    "AJ37-Viggen":              "F/B",
    "AJS37-Viggen":             "F/B",
    "JA37Di-Viggen":            "F",
    "m2000-5":                  "F/B",
    "m2000-5B":                 "F/B",
    "MiG-21bis":                "F/B",
    "KC-137R":                  "TNKR",
    "KC-137R-RT":               "TNKR",
    "707-TT":                   "TNKR",
    "KC-30A":                   "TNKR",
    "Voyager-KC":               "TNKR",
    "KC-10A":                   "TNKR",
    "KC-10A-GE":                "TNKR",
    "MD-11F-GE":                "TNKR",
    "MD-11F-PW":                "TNKR",
    "MD-11-GE":                 "TNKR",
    "MD-11-PW":                 "TNKR",
    "KMD-11":                   "TNKR",
    "EC-137R":                  "AEW&C",#awacs airborne and groundborne
    "RC-137R":                  "AEW&C",
    "E-3R":                     "AEW&C",
    "E-173R":                   "AEW&C",
    "E-8R":                     "AEW&C",
    "EC-137D":                  "AEW&C",
    "gci":                      "AEW&C",
    "MiG-29":                   "F",
    "SU-27":                    "F",
    "ch53e":                    "HELI",#heli
    "Mil-Mi-8":                 "HELI",#heli
    "ka50":                     "HELI",#heli
    "mi24":                     "HELI",#heli
    "MQ-9":                     "MC",#missile carrier
    "QF-4E":                    "F",
    "B1-B":                     "B",#bomber
    "A-10":                     "F/B",
    "A-10-model":               "F/B",
    "Typhoon":                  "F/B",
    "f16":                      "F/B",
    "Tu-95MR":                  "B",
    "Tu-160-Blackjack":         "B",
    "AN-225-Mrija":             "C",#transport
    "Su-15":                    "F",
    # SAMs
    "buk-m2":                   "SAM",
    "S-75":                     "SAM",
    "S-200":                    "SAM",
    "S-300":                    "SAM",
    "MIM104D":                  "SAM",
    "s300":                     "SAM",
    "SA-6":                     "SAM",
    "SA-3":                     "SAM",
    "MIM-104D":                 "SAM",
    "zsu-23":                   "AAA",
    "ZSU-IR":                   "AAA",
    "truck":                  "TRUCK",
    # Ships
    "missile_frigate":          "SHIP",
    "frigate":                  "SHIP",
    "fleet":                    "SHIP",
    "USS-LakeChamplain":        "SHIP",
    "USS-NORMANDY":             "SHIP",
    "USS-OliverPerry":          "SHIP",
    "USS-SanAntonio":           "SHIP",
    "hunter":                   "BOAT",
};

chaff_lasts = {};  # Vector containing data about each radar contact's unique and their
                   # chaff node. This is used to draw the chaffs on the VSD
chaffs_pos = [];  # Vector containing data about chaffs (their geographic position
                  # and the time at which they were released. If they're expired, they're removed)

# Preset Colors
var prst_black = {"r": 0, "g": 0, "b": 0};
var prst_white = {"r": 1, "g": 1, "b": 1};
var prst_green = {"r": 0, "g": 255 / 255, "b": 58 / 255};
var prst_green_dark = {"r": 6 / 255, "g": 172 / 255, "b": 44 / 255};
var prst_yellow = {"r": 234 / 255, "g": 255 / 255, "b": 0 / 255};
var prst_yellow_dark = {"r": 94 / 255, "g": 105 / 255, "b": 0 / 255};  # 2.5 times darker than regular yellow
var prst_purple = {"r": .7, "g": 0, "b": 1};
var prst_purple_dark = {"r": .28, "g": 0, "b": 0.4};  # 2.5 times darker than regular purple
var prst_rose = {"r": 1, "g": .21, "b": .635};
var prst_rose_dark = {"r": .4, "g": .084, "b": .254};  # 2.5 times darker than regular rose
var prst_cyan = {"r": 0, "g": 1, "b": .917};
var prst_cyan_dark = {"r": 0, "g": .4, "b": .382};  # 2.5 times darker than regular cyan
var prst_blue = {"r": 0, "g": 0, "b": 1};
var prst_blue_dark = {"r": .04, "g": .12, "b": .921};
var prst_marron = {"r": .85, "g": .035, "b": .066};
var prst_marron_dark = {"r": .34, "g": .01912, "b": .14736};  # 2.5 times darker than regular marron
var prst_orange = {"r": 1, "g": .482, "b": 0};
var prst_orange_dark = {"r": .4, "g": .1928, "b": 0};  # 2.5 times darker than regular orange (basically brown)
var prst_red = {"r": .941, "g": .019, "b": .019};
var prst_red_dark = {"r": .3764, "g": .0076, "b": .0076};  # 2.5 times darker than regular orange (basically brown)

# Settings
var main_screens = {
    "left": "VSD",
    "center": "PACS",
    "right": "HSD",
};
var VSD_ON = 0;
var PACS_ON = 0;
var HSD_ON = 0;

var elapsed = getprop("sim/time/elapsed-sec");

var LAD_Device = {

    canvas_settings: {
        "name": "F15-LAD",
        "size": [8192, 8192],
        "view": [8192, 8192],
        "mipmapping": 1
    },



    new: func(placement) {
        var m = {parents: [LAD_Device]};
        m.svg = canvas.new(LAD_Device.canvas_settings);
        m.svg.addPlacement(placement);

        m.svg.setColorBackground(prst_black.r,prst_black.g,prst_black.b, 1);  # dark-dark gray



        ## The upper panel, it's static and displays basic useful information
        ## Are in order from left to right
        m.upper_panel = m.svg.createGroup();

        # Time box
        m.time_text_hrs = m.upper_panel.createChild("text")
            .setFontSize(120, 1.4)
            .setText("23")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(190,115)
            .setFont(aircraft.HUDFont);
        m.time_text_mins = m.upper_panel.createChild("text")
            .setFontSize(120, 1.4)
            .setText("35")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(190,230)
            .setFont(aircraft.HUDFont);
        m.time_text_secs = m.upper_panel.createChild("text")
            .setFontSize(120, 1.4)
            .setText("20")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(190,345)
            .setFont(aircraft.HUDFont);
        m.time_box = m.upper_panel.createChild("path")
            .vert(230*2)
            .horiz(190*2)
            .vert(-230*2)
            .horiz(-190*2)
            .setTranslation(0,20)
            .setStrokeLineWidth(20)
            .setColor(prst_white.r,prst_white.g,prst_white.b);

        # Caution ("Warning") box
        m.caution_text = m.upper_panel.createChild("text")
            .setFontSize(165, 1.4)
            .setText("CAUTION")
            .setAlignment("center-center")
            .setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b)
            .setTranslation(740,230)
            .setFont(aircraft.HUDFont);
        m.caution_box = m.upper_panel.createChild("path")
            .vert(230*2)
            .horiz(330*2)
            .vert(-230*2)
            .horiz(-330*2)
            .setTranslation(400,20)
            .setStrokeLineWidth(20)
            .setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b);

        m.autopilot_text = m.upper_panel.createChild("text")
            .setFontSize(165, 1.4)
            .setText("A/P")
            .setAlignment("center-center")
            .setColor(prst_purple.r,prst_purple.g,prst_purple.b)
            .setTranslation(670+460*1.5-20,230)
            .setFont(aircraft.HUDFont);
        m.autopilot_box = m.upper_panel.createChild("path")
            .vert(230*2)
            .horiz(270*2)
            .vert(-230*2)
            .horiz(-270*2)
            .setTranslation(400+460*1.5-20,20)
            .setStrokeLineWidth(20)
            .setColor(prst_purple.r,prst_purple.g,prst_purple.b);

        # Radio 1 (Comm 1) box
        m.radio1_text_up = m.upper_panel.createChild("text")
            .setFontSize(135, 1.4)
            .setText("R1")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(1280+460*1.5-20,115)
            .setFont(aircraft.HUDFont);
        m.radio1_text_center = m.upper_panel.createChild("text")
            .setFontSize(120, 1.4)
            .setText("OFF")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(1280+460*1.5-20,230)
            .setFont(aircraft.HUDFont);
        m.radio1_text_down = m.upper_panel.createChild("text")
            .setFontSize(100, 1.4)
            .setText("113.76 MHz")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(1280+460*1.5-20,345)
            .setFont(aircraft.HUDFont);
        m.radio1_box = m.upper_panel.createChild("path")
            .vert(230*2)
            .horiz(320*2)
            .vert(-230*2)
            .horiz(-320*2)
            .setTranslation(960+460*1.5-20,20)
            .setStrokeLineWidth(20)
            .setColor(prst_white.r,prst_white.g,prst_white.b);

        # Radio 2 (Comm 2) box
        m.radio2_text_up = m.upper_panel.createChild("text")
            .setFontSize(135, 1.4)
            .setText("R2")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(1940+460*1.5-20,115)
            .setFont(aircraft.HUDFont);
        m.radio2_text_center = m.upper_panel.createChild("text")
            .setFontSize(120, 1.4)
            .setText("OFF")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(1940+460*1.5-20,230)
            .setFont(aircraft.HUDFont);
        m.radio2_text_down = m.upper_panel.createChild("text")
            .setFontSize(100, 1.4)
            .setText("113.76 MHz")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(1940+460*1.5-20,345)
            .setFont(aircraft.HUDFont);
        m.radio2_box = m.upper_panel.createChild("path")
            .vert(230*2)
            .horiz(320*2)
            .vert(-230*2)
            .horiz(-320*2)
            .setTranslation(1620+460*1.5-20,20)
            .setStrokeLineWidth(20)
            .setColor(prst_white.r,prst_white.g,prst_white.b);

        # IFF Box
        m.iff_text_up = m.upper_panel.createChild("text")
            .setFontSize(135, 1.4)
            .setText("IFF - OFF")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(3295,115)
            .setFont(aircraft.HUDFont);
        m.iff_text_center = m.upper_panel.createChild("text")
            .setFontSize(100, 1.4)
            .setText("M1/2-0000")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(3295,230)
            .setFont(aircraft.HUDFont);
        m.iff_text_mode3 = m.upper_panel.createChild("text")
            .setFontSize(100, 1.4)
            .setText("M3/A-0301")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(3295,325)
            .setFont(aircraft.HUDFont);
        m.iff_text_mode5 = m.upper_panel.createChild("text")
            .setFontSize(100, 1.4)
            .setText("M4/5-4217")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(3295,420)
            .setFont(aircraft.HUDFont);
        m.iff_box = m.upper_panel.createChild("path")
            .vert(230*2)
            .horiz(335*2)
            .vert(-230*2)
            .horiz(-335*2)
            .setTranslation(2940,20)
            .setStrokeLineWidth(20)
            .setColor(prst_white.r,prst_white.g,prst_white.b);

        # Datalink box
        m.dtl_text_up = m.upper_panel.createChild("text")
            .setFontSize(135, 1.4)
            .setText("DTLNK - OFF")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(4035,115)
            .setFont(aircraft.HUDFont);
        m.dtl_text_center = m.upper_panel.createChild("text")
            .setFontSize(100, 1.4)
            .setText("hash 7538")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(4035,230)
            .setFont(aircraft.HUDFont);
        m.dtl_text_down = m.upper_panel.createChild("text")
            .setFontSize(120, 1.4)
            .setText("ON LINK : 0")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(4035,345)
            .setFont(aircraft.HUDFont);
        m.dtl_box = m.upper_panel.createChild("path")
            .vert(230*2)
            .horiz(385*2)
            .vert(-230*2)
            .horiz(-385*2)
            .setTranslation(3630,20)
            .setStrokeLineWidth(20)
            .setColor(prst_white.r,prst_white.g,prst_white.b);

        # TACAN box
        m.tacan_text_up = m.upper_panel.createChild("text")
            .setFontSize(135, 1.4)
            .setText("TACAN")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(4610,160)
            .setFont(aircraft.HUDFont);
        m.tacan_text_down = m.upper_panel.createChild("text")
            .setFontSize(120, 1.4)
            .setText("073Y")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(4610,320)
            .setFont(aircraft.HUDFont);
        m.tacan_box = m.upper_panel.createChild("path")
            .vert(230*2)
            .horiz(190*2)
            .vert(-230*2)
            .horiz(-190*2)
            .setTranslation(4420,20)
            .setStrokeLineWidth(20)
            .setColor(prst_white.r,prst_white.g,prst_white.b);

        # ILS box
        m.ils_text_up = m.upper_panel.createChild("text")
            .setFontSize(135, 1.4)
            .setText("ILS")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(5050,160)
            .setFont(aircraft.HUDFont);
        m.ils_text_down = m.upper_panel.createChild("text")
            .setFontSize(100, 1.4)
            .setText("119.35 MHz")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(5050,320)
            .setFont(aircraft.HUDFont);
        m.ils_box = m.upper_panel.createChild("path")
            .vert(230*2)
            .horiz(230*2)
            .vert(-230*2)
            .horiz(-230*2)
            .setTranslation(4820,20)
            .setStrokeLineWidth(20)
            .setColor(prst_white.r,prst_white.g,prst_white.b);

        m.upper_panel.setVisible(1);
        m.caution_text.setVisible(1);
        m.caution_box.setVisible(1);
        m.autopilot_text.setVisible(1);
        m.autopilot_box.setVisible(1);
        m.time_text_hrs.setVisible(1);
        m.time_text_mins.setVisible(1);
        m.time_text_secs.setVisible(1);
        m.time_box.setVisible(1);
        m.radio1_text_up.setVisible(1);
        m.radio1_text_center.setVisible(1);
        m.radio1_text_down.setVisible(1);
        m.radio1_box.setVisible(1);
        m.radio2_text_up.setVisible(1);
        m.radio2_text_center.setVisible(1);
        m.radio2_text_down.setVisible(1);
        m.radio2_box.setVisible(1);
        m.iff_text_up.setVisible(1);
        m.iff_text_center.setVisible(1);
        m.iff_text_mode3.setVisible(1);
        m.iff_text_mode5.setVisible(1);
        m.iff_box.setVisible(1);
        m.dtl_text_up.setVisible(1);
        m.dtl_text_center.setVisible(1);
        m.dtl_text_down.setVisible(1);
        m.dtl_box.setVisible(1);
        m.tacan_text_up.setVisible(1);
        m.tacan_text_down.setVisible(1);
        m.tacan_box.setVisible(1);
        m.ils_text_up.setVisible(1);
        m.ils_text_down.setVisible(1);
        m.ils_box.setVisible(1);

        ## Main screens.
        ## The objects are actually all placed on the left screen,
        ## and are translated on different locations, depending on
        ## which screen they need to be displayed on, as you can't
        ## have two screens both having the VSD for example.

        # These objects are not usually displayed, but are when developing, to see limits
        m.main_screen_box_1 = m.upper_panel.createChild("path")
            .vert(2300*2)
            .horiz(1355*2)
            .vert(-2300*2)
            .horiz(-1355*2)
            .setTranslation(0,500)
            .setStrokeLineWidth(20)
            .setColor(prst_red.r,prst_red.g,prst_red.b);
        m.main_screen_box_2 = m.upper_panel.createChild("path")
            .vert(2300*2)
            .horiz(1355*2)
            .vert(-2300*2)
            .horiz(-1355*2)
            .setTranslation(1355+1355+20,500)
            .setStrokeLineWidth(20)
            .setColor(prst_red.r,prst_red.g,prst_red.b);
        m.main_screen_box_3 = m.upper_panel.createChild("path")
            .vert(2300*2)
            .horiz(1355*2)
            .vert(-2300*2)
            .horiz(-1355*2)
            .setTranslation(1355+1355+20+1355+1355+20,500)
            .setStrokeLineWidth(20)
            .setColor(prst_red.r,prst_red.g,prst_red.b);

        m.main_screen_box_1.setVisible(0);
        m.main_screen_box_2.setVisible(0);
        m.main_screen_box_3.setVisible(0);

        ## VSD Display
        m.VSDScreen = m.svg.createGroup();
        # VSD Grid - 4x4 equal
        m.vsd_box = m.VSDScreen.createChild("path")
            .vert(2225*2)
            .horiz(1280*2)
            .vert(-2225*2)
            .horiz(-1280*2)
            .setTranslation(75,575)
            .setStrokeLineWidth(20)
            .setColor(prst_white.r,prst_white.g,prst_white.b);
        m.line_0_1 = m.VSDScreen.createChild("path")
            .moveTo(75-30,1150+500+75)
            .lineTo(1355+1355-75+30,1150+500+75)
            .setStrokeLineWidth(10)
            .setColor(prst_white.r,prst_white.g,prst_white.b);
        m.line_0_2 = m.VSDScreen.createChild("path")
            .moveTo(75-30,1150*2+500+75)
            .lineTo(1355+1355-75+30,1150*2+500+75)
            .setStrokeLineWidth(10)
            .setColor(prst_white.r,prst_white.g,prst_white.b);
        m.line_0_3 = m.VSDScreen.createChild("path")
            .moveTo(75-30,1150*3+500+75)
            .lineTo(1355+1355-75+30,1150*3+500+75)
            .setStrokeLineWidth(10)
            .setColor(prst_white.r,prst_white.g,prst_white.b);
        m.line_1_0 = m.VSDScreen.createChild("path")
            .moveTo(677,500+75)
            .lineTo(677,2300*2+500-75)
            .setStrokeLineWidth(10)
            .setColor(prst_white.r,prst_white.g,prst_white.b);
        m.line_2_0 = m.VSDScreen.createChild("path")
            .moveTo(677*2,500+75)
            .lineTo(677*2,2300*2+500-75)
            .setStrokeLineWidth(10)
            .setColor(prst_white.r,prst_white.g,prst_white.b);
        m.line_3_0 = m.VSDScreen.createChild("path")
            .moveTo(677*3,500+75)
            .lineTo(677*3,2300*2+500-75)
            .setStrokeLineWidth(10)
            .setColor(prst_white.r,prst_white.g,prst_white.b);

        # VSD Symbologies
        # Standard symbology (speed, alt, horizon etc.)
        m.vsd_horizon_line = m.VSDScreen.createChild("path")
            .setCenter(1355,1150*2+500+75)
            .moveTo(1355-40,1150*2+500+75)
            .lineTo(677-75,1150*2+500+75) # Left horizontal line
            .vert(85) # Left vertical line
            .moveTo(1355+40,1150*2+500+75)
            .lineTo(1355+40+713,1150*2+500+75) # Left horizontal line
            .vert(85) # Left vertical line
            .setStrokeLineWidth(14)
            .set("z-index",10)
            .setColor(prst_green.r,prst_green.g,prst_green.b);
        m.vsd_ground_speed = m.VSDScreen.createChild("text")
            .setFontSize(100, 1.4)
            .setText("G 455")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(155,2300*2+500+10)
            .setFont(aircraft.HUDFont);
        m.vsd_airspeed = m.VSDScreen.createChild("text")
            .setFontSize(100, 1.4)
            .setText("T 327")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(1282*2,2300*2+500+10)
            .setFont(aircraft.HUDFont);
        m.vsd_route_manager_ruler_1 = m.VSDScreen.createChild("path")
            .moveTo(425-130,2300*2+500-50)
            .lineTo(425-130,2300*2+500+50)
            .setStrokeLineWidth(10)
            .setColor(prst_white.r,prst_white.g,prst_white.b);
        m.vsd_route_manager_ruler_2 = m.VSDScreen.createChild("path")
            .moveTo(970+130+300,2300*2+500-50)
            .lineTo(970+130+300,2300*2+500+50)
            .setStrokeLineWidth(10)
            .setColor(prst_white.r,prst_white.g,prst_white.b);
        m.vsd_stpt_eta = m.VSDScreen.createChild("text")
            .setFontSize(100, 1.4)
            .setText("XX:XX")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(425,2300*2+500+10)
            .setFont(aircraft.HUDFont);
        m.vsd_stpt_dist = m.VSDScreen.createChild("text")
            .setFontSize(100, 1.4)
            .setText("N 9999")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(690,2300*2+500+10)
            .setFont(aircraft.HUDFont);
        m.vsd_stpt_bearing = m.VSDScreen.createChild("text")
            .setFontSize(100, 1.4)
            .setText("B 999")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(980,2300*2+500+10)
            .setFont(aircraft.HUDFont);
        m.vsd_stpt_index = m.VSDScreen.createChild("text")
            .setFontSize(100, 1.4)
            .setText("No.00")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(1250,2300*2+500+10)
            .setFont(aircraft.HUDFont);
        m.vsd_altitude = m.VSDScreen.createChild("text")
            .setFontSize(100, 1.4)
            .setText("ALT 18000")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(1282*2-330,2300*2+500+10)
            .setFont(aircraft.HUDFont);
        m.vsd_fps = m.VSDScreen.createChild("text")
            .setFontSize(100, 1.4)
            .setText("FPS 0018")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(1282*2-720,2300*2+500+10)
            .setFont(aircraft.HUDFont);
        m.vsd_heading_true = m.VSDScreen.createChild("text")
            .setFontSize(100, 1.4)
            .setText("H 000")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(1282*2-720-300,2300*2+500+10)
            .setFont(aircraft.HUDFont);
        # Radar
        m.vsd_rdr_range_txt = m.VSDScreen.createChild("text")
            .setFontSize(80, 1.4)
            .setText("050 NM")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(2555,535)
            .setFont(aircraft.HUDFont);
        m.vsd_rdr_filter_1 = m.VSDScreen.createChild("text")
            .setFontSize(100, 1.4)
            .setText("A")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(2645+35,980)
            .setFont(aircraft.HUDFont);
        m.vsd_rdr_filter_2 = m.VSDScreen.createChild("text")
            .setFontSize(100, 1.4)
            .setText("/")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(2645+35,1060)
            .setFont(aircraft.HUDFont);
        m.vsd_rdr_filter_3 = m.VSDScreen.createChild("text")
            .setFontSize(100, 1.4)
            .setText("A")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(2645+35,1140)
            .setFont(aircraft.HUDFont);
        m.vsd_azimuth_center = m.VSDScreen.createChild("text")  # far down, right of the center column
            .setFontSize(100, 1.4)
            .setText("0°")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(677*2+60,2300*2+500-70-75)
            .setFont(aircraft.HUDFont);
        m.vsd_azimuth_left = m.VSDScreen.createChild("text")  # far down, bottom right
            .setFontSize(100, 1.4)
            .setText("60°")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(80+75,2300*2+500-80-75)
            .setFont(aircraft.HUDFont);
        m.vsd_azimuth_right = m.VSDScreen.createChild("text")  # far down, bottom left
            .setFontSize(100, 1.4)
            .setText("60°")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(677*4-80-75,2300*2+500-75-75)
            .setFont(aircraft.HUDFont);
        m.vsd_azimuth_carat = m.VSDScreen.createChild("path")
            .moveTo(677*2,2300*2+500-75)
            .lineTo(677*2-25,2300*2+500-75-75)  # left "wing"
            .moveTo(677*2,2300*2+500-75)
            .lineTo(677*2+25,2300*2+500-75-75)  # right "wing"
            .setStrokeLineWidth(10)
            .set("z-index",10)
            .setColor(prst_marron.r,prst_marron.g,prst_marron.b);
        m.vsd_elevation_carat = m.VSDScreen.createChild("path")
            .moveTo(75,2260+500)
            .lineTo(75+75,2260+500-25)
            .moveTo(75,2260+500)
            .lineTo(75+75,2260+500+25)
            .setStrokeLineWidth(10)
            .set("z-index",10)
            .setColor(prst_marron.r,prst_marron.g,prst_marron.b);
        m.vsd_azimuth_limit_circle_right_60 = m.VSDScreen.createChild("path")
            .moveTo(1282*2+75-25,2300*2+500-75)
            .arcSmallCW(25,25, 0, 25*2, 0)
            .arcSmallCW(25,25, 0, -25*2, 0)
            .setStrokeLineWidth(15)
            .set("z-index",10)
            .setColor(prst_marron_dark.r,prst_marron_dark.g,prst_marron_dark.b);
        m.vsd_azimuth_limit_circle_left_60 = m.VSDScreen.createChild("path")
            .moveTo(75-25,2300*2+500-75)
            .arcSmallCW(25,25, 0, 25*2, 0)
            .arcSmallCW(25,25, 0, -25*2, 0)
            .setStrokeLineWidth(15)
            .set("z-index",10)
            .setColor(prst_marron_dark.r,prst_marron_dark.g,prst_marron_dark.b);
        m.vsd_azimuth_limit_circle_right_30 = m.VSDScreen.createChild("path")
            .moveTo(677*3-50,2300*2+500-75)
            .arcSmallCW(25,25, 0, 25*2, 0)
            .arcSmallCW(25,25, 0, -25*2, 0)
            .setStrokeLineWidth(15)
            .set("z-index",10)
            .setColor(prst_marron_dark.r,prst_marron_dark.g,prst_marron_dark.b);
        m.vsd_azimuth_limit_circle_left_30 = m.VSDScreen.createChild("path")
            .moveTo(677,2300*2+500-75)
            .arcSmallCW(25,25, 0, 25*2, 0)
            .arcSmallCW(25,25, 0, -25*2, 0)
            .setStrokeLineWidth(15)
            .set("z-index",10)
            .setColor(prst_marron_dark.r,prst_marron_dark.g,prst_marron_dark.b);
        m.vsd_vert_coverage_circle_down = m.VSDScreen.createChild("path")
            .moveTo(75-65,2262+500)
            .arcSmallCW(25,25, 0, 25*2, 0)
            .arcSmallCW(25,25, 0, -25*2, 0)
            .setStrokeLineWidth(15)
            .set("z-index",10)
            .setColor(prst_marron_dark.r,prst_marron_dark.g,prst_marron_dark.b);
        m.vsd_vert_coverage_circle_up = m.VSDScreen.createChild("path")
            .moveTo(75-65,2262+500)
            .arcSmallCW(25,25, 0, 25*2, 0)
            .arcSmallCW(25,25, 0, -25*2, 0)
            .setStrokeLineWidth(15)
            .set("z-index",10)
            .setColor(prst_marron_dark.r,prst_marron_dark.g,prst_marron_dark.b);
        m.vsd_vert_coverage_text_down = m.VSDScreen.createChild("text")  # far down, bottom right
            .setFontSize(80, 1.4)
            .setText("10-5")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(75+75,2262+500)
            .setFont(aircraft.HUDFont);
        m.vsd_vert_coverage_text_up = m.VSDScreen.createChild("text")  # far down, bottom right
            .setFontSize(80, 1.4)
            .setText("50-3")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(75+75,2262+500)
            .setFont(aircraft.HUDFont);
        
        m.vsd_radar_mode_text = m.VSDScreen.createChild("text")
            .setFontSize(150, 1.4)
            .setText("1 TWSM")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(155+210,2300*2+500+10-210)
            .setFont(aircraft.HUDFont);

        # Create the steerpoints symbols
        m.stpt_symbols_max = 21; # random number, can always be increased or decreased if we ever need to
        m.stpt_symbols = setsize([], m.stpt_symbols_max);
        for (var i = 0; i < m.stpt_symbols_max; i += 1){
            m.stpt = m.VSDScreen.createChild("path")
                .moveTo(677*2,2262+500)
                .lineTo(677*2-22,2262+500)
                .lineTo(677*2,2262+500+112)
                .lineTo(677*2+22,2262+500)
                .lineTo(677*2,2262+500)
                .setStrokeLineWidth(6)
                .setVisible(0)
                .set("z-index",15)
                .setColor(prst_purple.r,prst_purple.g,prst_purple.b);
            m.stpt_symbols[i] = m.stpt;
        }
        m.stpt_texts = setsize([], m.stpt_symbols_max);
        for (var i = 0; i < m.stpt_symbols_max; i += 1){
            m.stpt_txt = m.VSDScreen.createChild("text")  # far down, bottom left
                .setFontSize(95, 1.4)
                .setText("STPT 1")
                .setAlignment("center-center")
                .setColor(prst_purple_dark.r,prst_purple_dark.g,prst_purple_dark.b)
                .setTranslation(677*2,2262+500+145)
                .setVisible(0)
                .set("z-index",15)
                .setFont(aircraft.HUDFont);
            m.stpt_texts[i] = m.stpt_txt;
        }

        # Create the radar target symbols
        m.tgt_symbols_max = 21; # random number, can always be increased or decreased if we ever need to
        m.tgt_symbols = setsize([], m.tgt_symbols_max);
        for (var i = 0; i < m.tgt_symbols_max; i += 1){
            m.tgt = m.VSDScreen.createChild("path")
                .moveTo(677*2,2262+500+50*.5)
	            .vert(50)
	            .setStrokeLineWidth(25)
	            .setStrokeLineCap("butt")
                .setVisible(0)
                .set("z-index",15)
                .setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b);
            m.tgt_symbols[i] = m.tgt;
        }
        m.tgt_texts = setsize([], m.tgt_symbols_max);
        for (var i = 0; i < m.tgt_symbols_max; i += 1){
            m.tgt_txt = m.VSDScreen.createChild("text")  # far down, bottom left
                .setFontSize(85, 1.4)
                .setText("F/B 18")
                .setAlignment("center-center")
                .setColor(prst_yellow_dark.r,prst_yellow_dark.g,prst_yellow_dark.b)
                .setTranslation(677*2,2262+500+145)
                .setVisible(0)
                .set("z-index",15)
                .setFont(aircraft.HUDFont);
            m.tgt_texts[i] = m.tgt_txt;
        }
        
        # Chaff bleps symbols
        m.chaff_symbols_max = 35; # random number, can always be increased or decreased if we ever need to
        m.chaff_symbols = setsize([], m.chaff_symbols_max);
        for (var i = 0; i < m.chaff_symbols_max; i += 1){
            m.chaff = m.VSDScreen.createChild("path")
                .moveTo(677*2,2262+500-44*0.5)
	            .vert(44)
	            .setStrokeLineWidth(88)
	            .setStrokeLineCap("butt")
                .set("z-index",10)
                .setVisible(0)
                .setColor(prst_cyan_dark.r,prst_cyan_dark.g,prst_cyan_dark.b);
            m.chaff_symbols[i] = m.chaff;
        }

        m.vsd_cursor = m.VSDScreen.createChild("path")
            .moveTo(677*2-38,2262+500-10)
            .lineTo(677*2-38,2262+500+122)
            .moveTo(677*2+38,2262+500-10)
            .lineTo(677*2+38,2262+500+122)
            .moveTo(677*2,2262+500)
            .setStrokeLineWidth(9)
            .setVisible(0)
            .set("z-index",20)
            .setColor(prst_cyan.r,prst_cyan.g,prst_cyan.b);

        # Create the datalink contacts symbols
        m.dlnk_symbols_max = 21; # random number, can always be increased or decreased if we ever need to
        m.dlnk_symbols = setsize([], m.dlnk_symbols_max);
        for (var i = 0; i < m.dlnk_symbols_max; i += 1){
            m.dlnk = m.VSDScreen.createChild("path")
                .moveTo(677*2-24,2262+500)
                .arcSmallCW(24,24,0,0,48)
                .arcSmallCW(24,24,0,0,-48)
                .setStrokeLineWidth(7)
                .setVisible(0)
                .set("z-index",15)
                .setColor(prst_blue.r,prst_blue.g,prst_blue.b);
            m.dlnk_symbols[i] = m.dlnk;
        }
        m.dlnk_texts = setsize([], m.dlnk_symbols_max);
        for (var i = 0; i < m.dlnk_symbols_max; i += 1){
            m.dlnk_txt = m.VSDScreen.createChild("text")  # far down, bottom left
                .setFontSize(85, 1.4)
                .setText("AEW&C 50")
                .setAlignment("center-center")
                .setColor(prst_blue_dark.r,prst_blue_dark.g,prst_blue_dark.b)
                .setTranslation(677*2,2262+500+145)
                .setVisible(0)
                .set("z-index",15)
                .setFont(aircraft.HUDFont);
            m.dlnk_texts[i] = m.dlnk_txt;
        }

        # Texts giving info about the current radar target
        m.vsd_tgt_true_speed = m.VSDScreen.createChild("text")
            .setFontSize(85, 1.4)
            .setText("T 000")
            .setAlignment("center-center")
            .setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b)
            .setTranslation(155,500+35)
            .setFont(aircraft.HUDFont);
        m.vsd_tgt_bearing = m.VSDScreen.createChild("text")
            .setFontSize(85, 1.4)
            .setText("B 000")
            .setAlignment("center-center")
            .setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b)
            .setTranslation(380,500+35)
            .setFont(aircraft.HUDFont);
        m.vsd_tgt_heading = m.VSDScreen.createChild("text")
            .setFontSize(85, 1.4)
            .setText("H 000")
            .setAlignment("center-center")
            .setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b)
            .setTranslation(605,500+35)
            .setFont(aircraft.HUDFont);
        m.vsd_tgt_aspect = m.VSDScreen.createChild("text")
            .setFontSize(85, 1.4)
            .setText("T")
            .setAlignment("center-center")
            .setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b)
            .setTranslation(775,500+35)
            .setFont(aircraft.HUDFont);
        m.vsd_tgt_altitude = m.VSDScreen.createChild("text")
            .setFontSize(85, 1.4)
            .setText("17,000")
            .setAlignment("center-center")
            .setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b)
            .setTranslation(965,500+35)
            .setFont(aircraft.HUDFont);
        m.vsd_tgt_range = m.VSDScreen.createChild("text")
            .setFontSize(85, 1.4)
            .setText("083.5 NM")
            .setAlignment("center-center")
            .setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b)
            .setTranslation(1235,500+35)
            .setFont(aircraft.HUDFont);
        m.vsd_tgt_fps = m.VSDScreen.createChild("text")
            .setFontSize(85, 1.4)
            .setText("FPS 0125")
            .setAlignment("center-center")
            .setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b)
            .setTranslation(1235+300,500+35)
            .setFont(aircraft.HUDFont);
        m.vsd_tgt_model = m.VSDScreen.createChild("text")
            .setFontSize(85, 1.4)
            .setText("MIG23")
            .setAlignment("center-center")
            .setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b)
            .setTranslation(1235+300+500,500+35)
            .setFont(aircraft.HUDFont);
        m.vsd_tgt_closure_pin = m.VSDScreen.createChild("path")
            .moveTo(677*4-75,1150*4+500+75)
            .lineTo(677*4-75-75,1150*4+500+75+65)
            .moveTo(677*4-75,1150*4+500+75)
            .lineTo(677*4-75-75,1150*4+500+75-65)
            .setStrokeLineWidth(6)
            .set("z-index",15)
            .setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b);
        m.vsd_tgt_closure_text = m.VSDScreen.createChild("text")
            .setFontSize(85, 1.4)
            .setText("0637")
            .setAlignment("center-center")
            .setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b)
            .setTranslation(677*4-75-140,1150*4+500+75)
            .setFont(aircraft.HUDFont);

        m.VSDScreen.setVisible(1);
        m.vsd_box.setVisible(1);
        m.line_0_1.setVisible(1);
        m.line_0_2.setVisible(1);
        m.line_0_3.setVisible(1);
        m.line_1_0.setVisible(1);
        m.line_2_0.setVisible(1);
        m.line_3_0.setVisible(1);
        m.vsd_horizon_line.setVisible(1);
        m.vsd_ground_speed.setVisible(1);
        m.vsd_airspeed.setVisible(1);
        m.vsd_altitude.setVisible(1);
        m.vsd_fps.setVisible(1);
        m.vsd_heading_true.setVisible(1);
        m.vsd_stpt_eta.setVisible(1);
        m.vsd_stpt_dist.setVisible(1);
        m.vsd_stpt_bearing.setVisible(1);
        m.vsd_stpt_index.setVisible(1);
        m.vsd_route_manager_ruler_1.setVisible(1);
        m.vsd_route_manager_ruler_2.setVisible(1);
        m.vsd_azimuth_carat.setVisible(1);
        m.vsd_elevation_carat.setVisible(1);
        m.vsd_cursor.setVisible(1);
        m.vsd_rdr_range_txt.setVisible(1);
        m.vsd_rdr_filter_1.setVisible(1);
        m.vsd_rdr_filter_2.setVisible(1);
        m.vsd_rdr_filter_3.setVisible(1);
        m.vsd_azimuth_center.setVisible(0);  # not used anymore
        m.vsd_azimuth_right.setVisible(0);  # not used anymore
        m.vsd_azimuth_left.setVisible(0);  # not used anymore
        m.vsd_azimuth_limit_circle_right_60.setVisible(1);
        m.vsd_azimuth_limit_circle_left_60.setVisible(1);
        m.vsd_azimuth_limit_circle_right_30.setVisible(0);
        m.vsd_azimuth_limit_circle_left_30.setVisible(0);
        m.vsd_vert_coverage_circle_down.setVisible(1);
        m.vsd_vert_coverage_circle_up.setVisible(1);
        m.vsd_vert_coverage_text_down.setVisible(1);
        m.vsd_vert_coverage_text_up.setVisible(1);
        m.vsd_radar_mode_text.setVisible(1);
        m.vsd_tgt_true_speed.setVisible(0);
        m.vsd_tgt_bearing.setVisible(0);
        m.vsd_tgt_heading.setVisible(0);
        m.vsd_tgt_aspect.setVisible(0);
        m.vsd_tgt_altitude.setVisible(0);
        m.vsd_tgt_range.setVisible(0);
        m.vsd_tgt_fps.setVisible(0);
        m.vsd_tgt_model.setVisible(0);
        m.vsd_tgt_closure_pin.setVisible(0);
        m.vsd_tgt_closure_text.setVisible(0);

        ## HSD Display
        m.hsd_great_circle_radius = 1150;
        m.hsd_nm_to_px_x = (m.hsd_great_circle_radius*2*(10/19)) / ((getprop("instrumentation/radar/radar2-range") * 1.25));
        m.hsd_nm_to_px_y = (m.hsd_great_circle_radius*2) / ((getprop("instrumentation/radar/radar2-range") * 1.25));
        m.hsd_radar_range_px_x = getprop("instrumentation/radar/radar2-range") * m.hsd_nm_to_px_x;
        m.hsd_radar_range_px_y = getprop("instrumentation/radar/radar2-range") * m.hsd_nm_to_px_y;
        m.HSDScreen = m.svg.createGroup();
        # Basic symbology
        m.hsd_cross = m.HSDScreen.createChild("path")
            .moveTo(1355,1150*2+500+75)
            .lineTo(1355-50,1150*2+500+75)  # left wing
            .moveTo(1355,1150*2+500+75)
            .lineTo(1355+50,1150*2+500+75)  # right wing
            .moveTo(1355,1150*2+500+75)
            .lineTo(1355,1150*2+500+75-50)  # up wing
            .moveTo(1355,1150*2+500+75)
            .lineTo(1355,1150*2+500+75+50)  # down wing
            .moveTo(1355,1150*2+500+75)
            .set("z-index",100)
            .setStrokeLineWidth(20)
            .setColor(prst_green.r,prst_green.g,prst_green.b);
        m.hsd_great_circle = m.HSDScreen.createChild("path")
            .moveTo(1355-m.hsd_great_circle_radius,1150*2+500)
            .setCenter(1355,1150*2+500+75)
            .arcSmallCW(m.hsd_great_circle_radius*10/19,m.hsd_great_circle_radius, 0, m.hsd_great_circle_radius*2, 0)
            .arcSmallCW(m.hsd_great_circle_radius*10/19,m.hsd_great_circle_radius, 0, -m.hsd_great_circle_radius*2, 0)
            .moveTo(1355-m.hsd_great_circle_radius,1150*2+500+75)
            .setStrokeLineWidth(40)
            .setStrokeDashArray([20,40])
            .set("z-index",10)
            .setColor(prst_white.r,prst_white.g,prst_white.b);

        m.hsd_circle_2_3 = m.HSDScreen.createChild("path")
            .moveTo(1355-m.hsd_great_circle_radius*(2/3),1150*2+500)
            .setCenter(1355,1150*2+500)
            .arcSmallCW((m.hsd_great_circle_radius*10/19)*(2/3),m.hsd_great_circle_radius*(2/3), 0, (m.hsd_great_circle_radius)*(2/3)*2, 0)
            .arcSmallCW((m.hsd_great_circle_radius*10/19)*(2/3),m.hsd_great_circle_radius*(2/3), 0, -(m.hsd_great_circle_radius*(2/3))*2, 0)
            .moveTo(1355-m.hsd_great_circle_radius,1150*2+500+75)
            .setStrokeLineWidth(7)
            .set("z-index",0)
            .setColor(prst_white.r,prst_white.g,prst_white.b);
        m.hsd_circle_1_3 = m.HSDScreen.createChild("path")
            .moveTo(1355-m.hsd_great_circle_radius*(1/3),1150*2+500)
            .setCenter(1355,1150*2+500)
            .arcSmallCW((m.hsd_great_circle_radius*10/19)*(1/3),m.hsd_great_circle_radius*(1/3), 0, (m.hsd_great_circle_radius)*(1/3)*2, 0)
            .arcSmallCW((m.hsd_great_circle_radius*10/19)*(1/3),m.hsd_great_circle_radius*(1/3), 0, -(m.hsd_great_circle_radius*(1/3))*2, 0)
            .moveTo(1355-m.hsd_great_circle_radius,1150*2+500+75)
            .setStrokeLineWidth(7)
            .set("z-index",0)
            .setColor(prst_white.r,prst_white.g,prst_white.b);

        m.hsd_line_h = m.HSDScreen.createChild("path")
            .moveTo(1355-(m.hsd_great_circle_radius*(10/19))*2+75,1150*2+500+75)
            .lineTo(1355+(m.hsd_great_circle_radius*(10/19))*2-75,1150*2+500+75)
            .setStrokeLineWidth(7)
            .set("z-index",0)
            .setColor(prst_white.r,prst_white.g,prst_white.b);
        m.hsd_line_p = m.HSDScreen.createChild("path")
            .moveTo(1355,1150*2+500+75+m.hsd_great_circle_radius*2-75-75)
            .lineTo(1355,1150*2+500+75-m.hsd_great_circle_radius*2+75+75)
            .setStrokeLineWidth(7)
            .set("z-index",0)
            .setColor(prst_white.r,prst_white.g,prst_white.b);

        m.hsd_distance_indicator_1_3 = m.HSDScreen.createChild("text")  # far down, right of the center column
            .setFontSize(50, 1.4)
            .setText("20.8NM")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(1355+85,1150*2+500+75)
            .set("z-index",0)
            .setFont(aircraft.HUDFont);
        m.hsd_distance_indicator_2_3 = m.HSDScreen.createChild("text")  # far down, right of the center column
            .setFontSize(50, 1.4)
            .setText("41.7NM")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(1355+85,1150*2+500+75)
            .set("z-index",0)
            .setFont(aircraft.HUDFont);


        m.heading_pin = m.HSDScreen.createChild("path")
            .moveTo(1355,1150*2+500+75-m.hsd_great_circle_radius*2)
            .lineTo(1355-50,1150*2+500+75-m.hsd_great_circle_radius*2+90)
            .moveTo(1355,1150*2+500+75-m.hsd_great_circle_radius*2)
            .lineTo(1355+50,1150*2+500+75-m.hsd_great_circle_radius*2+90)
            .lineTo(1355-50,1150*2+500+75-m.hsd_great_circle_radius*2+90)
            .moveTo(1355,1150*2+500+75-m.hsd_great_circle_radius*2)
            .setTranslation(0,30)
            .setStrokeLineWidth(20)
            #.setStrokeDashArray([50,35])
            .set("z-index",10)
            .setColor(prst_green.r,prst_green.g,prst_green.b);
        m.heading_pin_autopilot = m.HSDScreen.createChild("path")
            .moveTo(1355,1150*2+500+75-m.hsd_great_circle_radius*2+30)
            .lineTo(1355-50,1150*2+500+75-m.hsd_great_circle_radius*2+90+30)
            .moveTo(1355,1150*2+500+75-m.hsd_great_circle_radius*2+30)
            .lineTo(1355+50,1150*2+500+75-m.hsd_great_circle_radius*2+90+30)
            .lineTo(1355-50,1150*2+500+75-m.hsd_great_circle_radius*2+90+30)
            .moveTo(1355,1150*2+500+75-m.hsd_great_circle_radius*2+30)
            .setCenter(1355,1150*2+500+75-m.hsd_great_circle_radius*2+30)
            .setStrokeLineWidth(20)
            #.setStrokeDashArray([50,35])
            .set("z-index",10)
            .setColor(prst_rose.r,prst_rose.g,prst_rose.b);

        # Information texts (ground speed, true speed etc.)
        m.hsd_ground_speed = m.HSDScreen.createChild("text")
            .setFontSize(100, 1.4)
            .setText("G 455")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(110,500+45)
            .setFont(aircraft.HUDFont);
        m.hsd_airspeed = m.HSDScreen.createChild("text")
            .setFontSize(100, 1.4)
            .setText("T 327")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(350,500+45)
            .setFont(aircraft.HUDFont);
        m.hsd_heading_true = m.HSDScreen.createChild("text")
            .setFontSize(100, 1.4)
            .setText("H 000")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(1355,1150*2+500+75-m.hsd_great_circle_radius*2+90+100)
            .setFont(aircraft.HUDFont);
        m.hsd_altitude = m.HSDScreen.createChild("text")
            .setFontSize(100, 1.4)
            .setText("ALT 18000")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(195,500+45+95)
            .setFont(aircraft.HUDFont);
        m.hsd_fps = m.HSDScreen.createChild("text")
            .setFontSize(100, 1.4)
            .setText("FPS 0018")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(180,500+45+95+95)
            .setFont(aircraft.HUDFont);
        m.hsd_stpt_eta = m.HSDScreen.createChild("text")
            .setFontSize(120, 1.4)
            .setText("XX:XX")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(130,2300*2+500-70)
            .setFont(aircraft.HUDFont);
        m.hsd_stpt_dist = m.HSDScreen.createChild("text")
            .setFontSize(120, 1.4)
            .setText("N 9999")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(155,2300*2+500-70-120)
            .setFont(aircraft.HUDFont);
        m.hsd_stpt_bearing = m.HSDScreen.createChild("text")
            .setFontSize(120, 1.4)
            .setText("B 999")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(130,2300*2+500-70-120-120)
            .setFont(aircraft.HUDFont);
        m.hsd_stpt_current = m.HSDScreen.createChild("text")
            .setFontSize(120, 1.4)
            .setText("No.00")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(130,2300*2+500-70-120-120-120)
            .setFont(aircraft.HUDFont);

        m.hsd_bullseye_eta = m.HSDScreen.createChild("text")
            .setFontSize(120, 1.4)
            .setText("XX:XX")
            .setAlignment("center-center")
            .setColor(prst_blue.r,prst_blue.g,prst_blue.b)
            .setTranslation(677*4-130,2300*2+500-70)
            .setFont(aircraft.HUDFont);
        m.hsd_bullseye_dist = m.HSDScreen.createChild("text")
            .setFontSize(120, 1.4)
            .setText("N 9999")
            .setAlignment("center-center")
            .setColor(prst_blue.r,prst_blue.g,prst_blue.b)
            .setTranslation(677*4-225,2300*2+500-70-120)
            .setFont(aircraft.HUDFont);
        m.hsd_bullseye_bearing = m.HSDScreen.createChild("text")
            .setFontSize(120, 1.4)
            .setText("B 999")
            .setAlignment("center-center")
            .setColor(prst_blue.r,prst_blue.g,prst_blue.b)
            .setTranslation(677*4-130,2300*2+500-70-120-120)
            .setFont(aircraft.HUDFont);
        m.hsd_bullseye_title = m.HSDScreen.createChild("text")
            .setFontSize(120, 1.4)
            .setText("BULLS")
            .setAlignment("center-center")
            .setColor(prst_blue.r,prst_blue.g,prst_blue.b)
            .setTranslation(677*4-130,2300*2+500-70-120-120-120)
            .setFont(aircraft.HUDFont);

        # Create the steerpoints symbols
        m.stpt_symbols_hsd = setsize([], m.stpt_symbols_max);
        for (var i = 0; i < m.stpt_symbols_max; i += 1){
            m.stpt = m.HSDScreen.createChild("path")
                .moveTo(677*2,2262+500)
                .lineTo(677*2-22,2262+500)
                .lineTo(677*2,2262+500+112)
                .lineTo(677*2+22,2262+500)
                .lineTo(677*2,2262+500)
                .setStrokeLineWidth(6)
                .setVisible(0)
                .set("z-index",15)
                .setColor(prst_purple.r,prst_purple.g,prst_purple.b);
            m.stpt_symbols_hsd[i] = m.stpt;
        }
        m.stpt_texts_hsd = setsize([], m.stpt_symbols_max);
        for (var i = 0; i < m.stpt_symbols_max; i += 1){
            m.stpt_txt = m.HSDScreen.createChild("text")  # far down, bottom left
                .setFontSize(95, 1.4)
                .setText("STPT 1")
                .setAlignment("center-center")
                .setColor(prst_purple_dark.r,prst_purple_dark.g,prst_purple_dark.b)
                .setTranslation(677*2,2262+500+145)
                .setVisible(0)
                .set("z-index",15)
                .setFont(aircraft.HUDFont);
            m.stpt_texts_hsd[i] = m.stpt_txt;
        }

        # Radar symbology
        m.hsd_radar_x = (m.hsd_radar_range_px_x) * math.cos((90 - 60) * D2R);
        m.hsd_radar_y = -(m.hsd_radar_range_px_y) * math.sin((90 - 30) * D2R);
        m.hsd_cone_60 = m.HSDScreen.createChild("path")
            .moveTo(1355,1150*2+500+75)
            .lineTo(1355+m.hsd_radar_x,1150*2+500+75+m.hsd_radar_y)
            .moveTo(1355,1150*2+500+75)
            .lineTo(1355-m.hsd_radar_x,1150*2+500+75+m.hsd_radar_y)
            .arcSmallCW(m.hsd_radar_range_px_x,m.hsd_radar_range_px_y / 1.65, 0, m.hsd_radar_x*2, 0)
            .setStrokeLineWidth(20)
            .set("z-index",10)
            .setColor(prst_green.r,prst_green.g,prst_green.b);
        m.hsd_radar_x = (m.hsd_radar_range_px_x) * math.cos((90 - 30) * D2R);
        m.hsd_radar_y = -(m.hsd_radar_range_px_y) * math.sin((90 - 30) * D2R);
        m.hsd_cone_30 = m.HSDScreen.createChild("path")
            .moveTo(1355,1150*2+500+75)
            .lineTo(1355+m.hsd_radar_x,1150*2+500+75+m.hsd_radar_y)
            .moveTo(1355,1150*2+500+75)
            .lineTo(1355-m.hsd_radar_x,1150*2+500+75+m.hsd_radar_y)
            .arcSmallCW(m.hsd_radar_range_px_x,m.hsd_radar_range_px_y / 1.65, 0, m.hsd_radar_x*2, 0)
            .setStrokeLineWidth(20)
            .set("z-index",10)
            .setColor(prst_green.r,prst_green.g,prst_green.b);

        m.hsd_radar_range_text = m.HSDScreen.createChild("text")
            .setFontSize(150, 1.4)
            .setText("050 NM")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(2555-60,535+25)
            .setFont(aircraft.HUDFont);
        m.hsd_radar_mode = m.HSDScreen.createChild("text")
            .setFontSize(120, 1.4)
            .setText("TWS AUTO")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(2555-75,535+160+25)
            .setFont(aircraft.HUDFont);
        m.hsd_radar_filter = m.HSDScreen.createChild("text")
            .setFontSize(120, 1.4)
            .setText("A/SEA")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(2555+10,535+160+130+25)
            .setFont(aircraft.HUDFont);

        # Create the EPAWSS symbols
        m.epawss_symbols_hsd_hat = setsize([], m.stpt_symbols_max);  # hats are for airborne radars
        for (var i = 0; i < m.stpt_symbols_max; i += 1){
            m.epawss = m.HSDScreen.createChild("path")
                .moveTo(677*2,2262+500-60-65+25+10+15)
                .lineTo(677*2-40,2262+500-60-65+25+20+10+15)
                .moveTo(677*2,2262+500-60-65+25+10+15)
                .lineTo(677*2+40,2262+500-60-65+25+20+10+15)
                .setStrokeLineWidth(10)
                .setVisible(0)
                .set("z-index",20)
                .setColor(prst_orange_dark.r,prst_orange_dark.g,prst_orange_dark.b);
            m.epawss_symbols_hsd_hat[i] = m.epawss;
        }
        m.epawss_symbols_hsd_missile_launch = setsize([], m.stpt_symbols_max+1);  # used for missile launches
        for (var i = 0; i < m.stpt_symbols_max+1; i += 1){  # +1 for MAW
            m.epawss_launch = m.HSDScreen.createChild("path")
                .moveTo(677*2-70,2262+500)
                .arcSmallCW(70*(10/19),60, 0, 70*2, 0)
                .arcSmallCW(70*(10/19),60, 0, -70*2, 0)
                .setStrokeLineWidth(15)
                .setStrokeDashArray([5,10])
                .setVisible(0)
                .set("z-index",22)
                .setColor(prst_orange.r,prst_orange.g,prst_orange.b);
            m.epawss_symbols_hsd_missile_launch[i] = m.epawss_launch;
        }
        m.epawss_symbols_hsd_primary_threat = setsize([], m.stpt_symbols_max+1);  # used for missile launches
        for (var i = 0; i < m.stpt_symbols_max+1; i += 1){  # +1 for MAW
            m.epawss_threat = m.HSDScreen.createChild("path")
                .moveTo(677*2,2262+500+70*2)
                .lineTo(677*2+70,2262+500)
                .moveTo(677*2+70,2262+500)
                .lineTo(677*2,2262+500-70*2)
                .moveTo(677*2,2262+500-70*2)
                .lineTo(677*2-70,2262+500)
                .moveTo(677*2,2262+500+70*2)
                .lineTo(677*2-70,2262+500)
                .moveTo(677*2,2262+500+70*2)
                .setStrokeLineWidth(15)
                .setVisible(0)
                .set("z-index",21)
                .setColor(prst_red.r,prst_red.g,prst_red.b);
            m.epawss_symbols_hsd_primary_threat[i] = m.epawss_threat;
        }
        m.epawss_symbols_hsd_new_contact = setsize([], m.stpt_symbols_max);  # used for new contacts
        for (var i = 0; i < m.stpt_symbols_max; i += 1){
            m.epawss_new = m.HSDScreen.createChild("path")
                .moveTo(677*2-70,2262+500-15)
                .arcSmallCW(70*(10/19),60, 0, 70*2, 0)
                .setStrokeLineWidth(15)
                .setVisible(0)
                .set("z-index",23)
                .setColor(prst_orange.r,prst_orange.g,prst_orange.b);
            m.epawss_symbols_hsd_new_contact[i] = m.epawss_new;
        }
        m.epawss_texts_hsd = setsize([], m.stpt_symbols_max+1);
        for (var i = 0; i < m.stpt_symbols_max+1; i += 1){  # +1 for MAW
            m.epawss_txt = m.HSDScreen.createChild("text")  # far down, bottom left
                .setFontSize(110, 1.4)
                .setText("F/B")
                .setAlignment("center-center")
                .setColor(prst_orange.r,prst_orange.g,prst_orange.b)
                .setTranslation(677*2,2262+500)
                .setVisible(0)
                .set("z-index",24)
                .setFont(aircraft.HUDFont);
            m.epawss_texts_hsd[i] = m.epawss_txt;
        }

        # Create the radar target symbols
        m.tgt_symbols_hsd = setsize([], m.tgt_symbols_max);
        for (var i = 0; i < m.tgt_symbols_max; i += 1){
            m.tgt = m.HSDScreen.createChild("path")
                .moveTo(677*2,2262+500)
                .lineTo(677*2-22,2262+500)
                .lineTo(677*2,2262+500+112)
                .lineTo(677*2,2262+500+143)
                .lineTo(677*2,2262+500+112)
                .lineTo(677*2+22,2262+500)
                .lineTo(677*2,2262+500)
                .setStrokeLineWidth(7)
                .setVisible(0)
                .set("z-index",15)
                .setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b);
            m.tgt_symbols_hsd[i] = m.tgt;
        }
        m.tgt_symbols_hsd_ships = setsize([], m.tgt_symbols_max);
        for (var i = 0; i < m.tgt_symbols_max; i += 1){
            m.tgt = m.HSDScreen.createChild("path")
                .moveTo(677*2-40,2262+500+40)
                .horiz(80)
                .lineTo(677*2+56,2262+500)
                .horiz(-132)
                .lineTo(677*2-40,2262+500+40)
                .moveTo(677*2-32,2262+500)
                .vert(-32)
                .horiz(64)
                .vert(32)
                .setTranslation(0,40)
                .setStrokeLineWidth(7)
                .setVisible(0)
                .set("z-index",15)
                .setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b);
            m.tgt_symbols_hsd_ships[i] = m.tgt;
        }
        m.tgt_texts_hsd = setsize([], m.tgt_symbols_max);
        for (var i = 0; i < m.tgt_symbols_max; i += 1){
            m.tgt_txt = m.HSDScreen.createChild("text")  # far down, bottom left
                .setFontSize(85, 1.4)
                .setText("F/B 18")
                .setAlignment("center-center")
                .setColor(prst_yellow_dark.r,prst_yellow_dark.g,prst_yellow_dark.b)
                .setTranslation(677*2,2262+500+145)
                .setVisible(0)
                .set("z-index",15)
                .setFont(aircraft.HUDFont);
            m.tgt_texts_hsd[i] = m.tgt_txt;
        }

        m.locked_box_hsd = m.HSDScreen.createChild("path")
            .moveTo(677*2-38,2262+500-10)
            .lineTo(677*2-38,2262+500+122)
            .moveTo(677*2+38,2262+500-10)
            .lineTo(677*2+38,2262+500+122)
            .moveTo(677*2,2262+500)
            .setStrokeLineWidth(9)
            .setVisible(0)
            .set("z-index",15)
            .setColor(prst_white.r,prst_white.g,prst_white.b);

        # Create the datalink contacts symbols
        m.dlnk_symbols_max = 21; # random number, can always be increased or decreased if we ever need to
        m.dlnk_symbols_hsd = setsize([], m.dlnk_symbols_max);
        for (var i = 0; i < m.dlnk_symbols_max; i += 1){
            m.dlnk = m.HSDScreen.createChild("path")
                .moveTo(677*2-24,2262+500)
                .arcSmallCW(24,24,0,0,48)
                .arcSmallCW(24,24,0,0,-48)
                .setStrokeLineWidth(7)
                .setVisible(0)
                .set("z-index",15)
                .setColor(prst_blue.r,prst_blue.g,prst_blue.b);
            m.dlnk_symbols_hsd[i] = m.dlnk;
        }
        m.dlnk_texts_hsd = setsize([], m.dlnk_symbols_max);
        for (var i = 0; i < m.dlnk_symbols_max; i += 1){
            m.dlnk_txt = m.HSDScreen.createChild("text")  # far down, bottom left
                .setFontSize(85, 1.4)
                .setText("AEW&C 50")
                .setAlignment("center-center")
                .setColor(prst_blue_dark.r,prst_blue_dark.g,prst_blue_dark.b)
                .setTranslation(677*2,2262+500+145)
                .setVisible(0)
                .set("z-index",15)
                .setFont(aircraft.HUDFont);
            m.dlnk_texts_hsd[i] = m.dlnk_txt;
        }

        # Data cartridge loaded data symbology
        m.HSDScreenCircles = m.svg.createGroup();  # used only for HSD circled areas , which need to be all deleted if they're updated

        var bullseye_radius = 1.5;
        m.hsd_bullseye_aim = m.HSDScreen.createChild("path")
            .moveTo(1355-bullseye_radius*m.hsd_nm_to_px_x,1150*2+500)
            .arcSmallCW(bullseye_radius*m.hsd_nm_to_px_x,bullseye_radius*m.hsd_nm_to_px_y, 0, bullseye_radius*m.hsd_nm_to_px_y*2, 0)  # Full circle
            .arcSmallCW(bullseye_radius*m.hsd_nm_to_px_x,bullseye_radius*m.hsd_nm_to_px_y, 0, -bullseye_radius*m.hsd_nm_to_px_y*2, 0)
            .moveTo(1355-bullseye_radius*m.hsd_nm_to_px_x,1150*2+500+75)
            .set("z-index",0)
            .setVisible(0)
            .setStrokeLineWidth(10)
            .setColor(prst_blue.r,prst_blue.g,prst_blue.b);

        #m.hsd_tacan_symbol = m.TACANsvg.getElementById("TACANSymbol");

        m.HSDScreenLines = m.svg.createGroup();  # used only for steerpoint-connecting lines, which need to be all deleted if steerpoints are updated (it also now contains the range texts)

        m.hsd_cross.setVisible(1);
        m.hsd_great_circle.setVisible(1);
        m.hsd_circle_2_3.setVisible(1);
        m.hsd_circle_1_3.setVisible(1);
        m.hsd_line_h.setVisible(1);
        m.hsd_line_p.setVisible(1);
        m.hsd_ground_speed.setVisible(1);
        m.hsd_airspeed.setVisible(1);
        m.hsd_heading_true.setVisible(1);
        m.hsd_altitude.setVisible(1);
        m.hsd_fps.setVisible(1);
        m.hsd_stpt_eta.setVisible(1);
        m.hsd_stpt_bearing.setVisible(1);
        m.hsd_stpt_dist.setVisible(1);
        m.hsd_stpt_current.setVisible(1);
        m.hsd_cone_60.setVisible(1);
        m.hsd_cone_30.setVisible(0);
        m.heading_pin.setVisible(1);
        m.heading_pin_autopilot.setVisible(0);
        m.hsd_radar_range_text.setVisible(1);
        m.hsd_radar_mode.setVisible(1);
        m.hsd_radar_filter.setVisible(1);
        m.hsd_bullseye_eta.setVisible(1);
        m.hsd_bullseye_dist.setVisible(1);
        m.hsd_bullseye_bearing.setVisible(1);
        m.hsd_bullseye_title.setVisible(1);
        m.hsd_distance_indicator_1_3.setVisible(1);
        m.hsd_distance_indicator_2_3.setVisible(1);

        ## PACS Display
        m.PACSmode = 0;  # 0 A/A ; 1 A/G ; 2 JETTISON

        # Parse the PACS.svg file
        m.PACSScreen = m.svg.createGroup();
        m.pacs_pres = canvas.parsesvg(m.PACSScreen, "Nasal/LAD/PACS.svg", {'font-mapper': aircraft.hud_font_mapper});
        m.PACSScreen.setScale(1,.9);

        # Import what needs to be imported

        # Shared objects
        m.pacs_mode_text = m.PACSScreen.getElementById("view_mode_text");
        m.pacs_arming_time = m.PACSScreen.getElementById("arm_time_counter");
        m.pacs_chaff = m.PACSScreen.getElementById("chaff_count");
        m.pacs_flare = m.PACSScreen.getElementById("flare_count");
        m.pacs_rounds = m.PACSScreen.getElementById("rounds_count");
        m.pacs_arm_1 = m.PACSScreen.getElementById("arm_count_0");
        m.pacs_arm_2 = m.PACSScreen.getElementById("arm_count_1");
        m.pacs_arm_3 = m.PACSScreen.getElementById("arm_count_2");
        m.pacs_fuel_amount_left = m.PACSScreen.getElementById("left_tank");
        m.pacs_fuel_amount_center = m.PACSScreen.getElementById("center_tank");
        m.pacs_fuel_amount_right = m.PACSScreen.getElementById("right_tank");
        m.aim9_cool_box = m.PACSScreen.getElementById("AIM9_COOL_BOX");
        m.aim9_cool_text = m.PACSScreen.getElementById("AIM9_COOL_TEXT");
        m.navpod_mounted_text = m.PACSScreen.getElementById("nav-mounted-text");
        m.tpod_mounted_text = m.PACSScreen.getElementById("tpod-mounted-text");
        m.irst_pod_mounted_text = m.PACSScreen.getElementById("legion-pod-mounted-text");
        m.ecm_pod_mounted_text = m.PACSScreen.getElementById("ecm-pod-mounted-text");

        # Load all stations' symbology

        m.pacs_stations_idx = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,20,21,22,23,24,25];


        m.pacs_station_boxes_up = setsize([], 26);  # there are stations from 0 to 25
        m.pacs_station_boxes_down = setsize([], 26);
        m.pacs_station_boxes_up_text = setsize([], 26);
        m.pacs_station_boxes_down_text = setsize([], 26);
        foreach(idx; m.pacs_stations_idx) {
            m.pacs_station_boxes_up[idx] = m.PACSScreen.getElementById("BOX_UP_S"~idx~"");
            m.pacs_station_boxes_down[idx] = m.PACSScreen.getElementById("BOX_DOWN_S"~idx~"");
            m.pacs_station_boxes_up_text[idx] = m.PACSScreen.getElementById("BOX_UP_TEXT_S"~idx~"");
            m.pacs_station_boxes_down_text[idx] = m.PACSScreen.getElementById("BOX_DOWN_TEXT_S"~idx~"");
        }

        m.pacs_mode_text.setVisible(1);
        m.pacs_arming_time.setVisible(0);
        m.pacs_chaff.setVisible(1);
        m.pacs_flare.setVisible(1);
        m.pacs_rounds.setVisible(1);
        m.pacs_arm_1.setVisible(1);
        m.pacs_arm_2.setVisible(1);
        m.pacs_arm_3.setVisible(1);
        m.pacs_fuel_amount_left.setVisible(1);
        m.pacs_fuel_amount_center.setVisible(1);
        m.pacs_fuel_amount_right.setVisible(1);
        m.aim9_cool_box.setVisible(0);
        m.aim9_cool_text.setVisible(0);
        m.navpod_mounted_text.setVisible(0);
        m.tpod_mounted_text.setVisible(0);
        m.irst_pod_mounted_text.setVisible(0);
        m.ecm_pod_mounted_text.setVisible(0);

        return m;
    },
};

var LADCanvas = nil;
var update_loop_lad = nil;

# Utilities
var deviation_normdeg = func(our_heading, target_bearing) {
    var dev_norm = target_bearing-our_heading;
    dev_norm=geo.normdeg180(dev_norm);
    return dev_norm;
}

var ellipse_clamp = func(x_move, y_move, mode=0) {  # Used to clamp an object if it's outside the HSD great circle's ellipse
    ellipse_value = ((x_move*x_move) / ((LADCanvas.hsd_great_circle_radius * 10/19) * (LADCanvas.hsd_great_circle_radius * 10/19)) + (y_move*y_move) / (LADCanvas.hsd_great_circle_radius*LADCanvas.hsd_great_circle_radius)) * .35;
    if (ellipse_value > 1 and mode == 0) {  # < 1: inside ; == 1: on the edge; > 1: outside
        scale = 1 / math.sqrt(ellipse_value);
        x_move = x_move * scale;
        y_move = y_move * scale;

    } elsif (mode == 1) {  # use to move the object to the closest point of the ellipse
        scale = 1 / math.sqrt(ellipse_value);
        x_move = x_move * scale;
        y_move = y_move * scale;
    }
    return [x_move, y_move];
}

# Note: doesn't work lol
var ellipse_position_and_angle = func(degrees, horiz_radius, verti_radius, center_x=0, center_y=0) {  # Used to determine x and y coordinates, as well as rotation angle for an object to stay along the edge of an ellipse, always facing forward
    var theta = D2R * (90 - degrees);  # Compass-style: 0° = top, CW

    # Position
    x = center_x + horiz_radius * math.cos(theta);
    y = center_y + verti_radius * math.sin(theta);

    # Tangent vector
    dx = horiz_radius * -math.sin(theta);
    dy = verti_radius * math.cos(theta);

    # Angle to face (in radians)
    angle_rad = math.atan2(dy, dx);

    return [x, y, angle_rad];
}

var path_text_perpendicular_vector_computing = func(coord_1, coord_2, offset=40) {  # used to place texts giving range between two steerpoints on their connecting path.
    # Note:
    # - coord_1 is a vector containing the x and y position of the start of the path in that order
    # - coord_2 is a vector containing the x and y position of the end of the path in that order
    # - offset is an optional parameter, determining how many pixels the returned position should be offset'd from
    #
    # - The function returns a vector with computed x position, computed y position, and rotation angle, all in that order

    # Midpoint along the path
    midpoint = [(coord_1[0]+coord_2[0])/2, (coord_1[1]+coord_2[1])/2];
    # Angles in radians
    rotation = math.atan2(coord_2[1]-coord_1[1], coord_2[0]-coord_1[0]);

    # Perpendicular unit vector
    direction = [-(coord_2[1]-coord_1[1]), coord_2[0]-coord_1[0]];
    length = math.sqrt(direction[0]*direction[0] + direction[1]*direction[1]);
    unit_normal = [direction[0] / length, direction[1] / length];

    # Offset position above the line
    return [midpoint[0] + offset * unit_normal[0], midpoint[1] + offset * unit_normal[1], rotation];
}

# Don't work GODDAMN
var is_inside_static = func(x, y, center_static, radiuses_static, static_rotation) {
    var dx = x - center_static[0];
    var dy = y - center_static[1];

    # Apply rotation (if needed)
    var x_rot = dx * math.cos(-static_rotation*D2R) - dy * math.sin(-static_rotation*D2R);
    var y_rot = dx * math.sin(-static_rotation*D2R) + dy * math.cos(-static_rotation*D2R);

    #print((x_rot*x_rot)/(radiuses_static[0]*radiuses_static[0]) + (y_rot*y_rot)/(radiuses_static[1]*radiuses_static[1]));
    return (x_rot*x_rot)/(radiuses_static[0]*radiuses_static[0]) + (y_rot*y_rot)/(radiuses_static[1]*radiuses_static[1]) <= 1;
}

# Don't work GODDAMN
var get_points_inside_for_ellipse = func(ellipse_horizon_radius, ellipse_vertic_radius, center_x, center_y, center_x_static, center_y_static, ellipse2_horizon_radius, ellipse2_vertic_radius, step=2.5, ellipse_rot=0, static_rotation=0) {

    intersect_points = [];
    for (var t = 0; t < 360; t += step) {
        var rad = t * math.pi / 180;
        var x = ellipse_horizon_radius * math.cos(rad);
        var y = ellipse_vertic_radius * math.sin(rad);

        # Rotate by theta
        theta = ellipse_rot*D2R;  # if it's rotated
        var xr = x * math.cos(theta) - y * math.sin(theta);
        var yr = x * math.sin(theta) + y * math.cos(theta);

        # Translate to ellipse center
        var px = center_x + xr;
        var py = center_y + yr;

        # Check if this point lies within the static ellipse
        var inside = is_inside_static(px, py, [center_x_static, center_y_static], [ellipse2_horizon_radius, ellipse2_vertic_radius], static_rotation);

        # If inside, store point for drawing
        if (inside) {
            append(intersect_points, [px, py]);
        }
    }
    return intersect_points;
}

update_lad = func() {

    elapsed = getprop("sim/time/elapsed-sec");

    # We make sure we don't run none of that if the LAD screen's offline
    if (getprop("sim/model/f15/controls/LAD/mode") > 0 and getprop("fdm/jsbsim/systems/electrics/ac-left-main-bus") > 0) {
        ## Upper panel updates
        # Update the Caution light, depending on if there's a caution or not (also change its size)
        caution = getprop("sim/model/f15/instrumentation/warnings/master-caution");
        if (caution) {
            LADCanvas.caution_text.setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b).setFontSize(165, 1.4);
            LADCanvas.caution_box.setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b);
        } else {
            LADCanvas.caution_text.setColor(prst_yellow_dark.r,prst_yellow_dark.g,prst_yellow_dark.b).setFontSize(120, 1.4);
            LADCanvas.caution_box.setColor(prst_yellow_dark.r,prst_yellow_dark.g,prst_yellow_dark.b);
        }

        # Update the A/P light, depending if autopilot's on or not, we change the text's size and the colors
        autopilot_on = getprop("autopilot/internal/pitch-active") and getprop("autopilot/internal/roll-active");
        if (autopilot_on) {
            LADCanvas.autopilot_text.setColor(prst_green.r,prst_green.g,prst_green.b).setFontSize(165, 1.4);
            LADCanvas.autopilot_box.setColor(prst_green.r,prst_green.g,prst_green.b);
        } else {
            LADCanvas.autopilot_text.setColor(prst_white.r,prst_white.g,prst_white.b).setFontSize(120, 1.4);
            LADCanvas.autopilot_box.setColor(prst_white.r,prst_white.g,prst_white.b);
        }

        # Update the time's box
        time_secs = getprop("sim/time/local-day-seconds");
        if (time_secs != nil) {  # God knows why, at startup this property ain't defined yet
            curr_hr = int(time_secs / 3600);
            curr_min = int((time_secs - ( curr_hr * 3600 ) ) / 60);
            curr_secs = int(time_secs - ( curr_hr * 3600 + curr_min * 60 ));

            LADCanvas.time_text_hrs.setText(sprintf("%02d", curr_hr));
            LADCanvas.time_text_mins.setText(sprintf("%02d", curr_min));
            LADCanvas.time_text_secs.setText(sprintf("%02d", curr_secs));
        }

        # Update the radios' boxes
        comm1_off = getprop("instrumentation/comm[0]/volume") == 0;
        LADCanvas.radio1_text_down.setText(sprintf("%.02f MHz", getprop("instrumentation/comm[0]/frequencies/selected-mhz")));
        if (comm1_off) {
            LADCanvas.radio1_text_center.setText("OFF");
            LADCanvas.radio1_text_up.setColor(prst_white.r,prst_white.g,prst_white.b);
            LADCanvas.radio1_text_center.setColor(prst_white.r,prst_white.g,prst_white.b);
            LADCanvas.radio1_text_down.setColor(prst_white.r,prst_white.g,prst_white.b);
            LADCanvas.radio1_box.setColor(prst_white.r,prst_white.g,prst_white.b);
        } else {
            LADCanvas.radio1_text_center.setText("ON");
            LADCanvas.radio1_text_up.setColor(prst_green.r,prst_green.g,prst_green.b);
            LADCanvas.radio1_text_center.setColor(prst_green.r,prst_green.g,prst_green.b);
            LADCanvas.radio1_text_down.setColor(prst_green.r,prst_green.g,prst_green.b);
            LADCanvas.radio1_box.setColor(prst_green.r,prst_green.g,prst_green.b);
        }
        comm2_off = getprop("instrumentation/comm[1]/volume") == 0;
        LADCanvas.radio2_text_down.setText(sprintf("%.02f MHz", getprop("instrumentation/comm[1]/frequencies/selected-mhz")));
        if (comm2_off) {
            LADCanvas.radio2_text_center.setText("OFF");
            LADCanvas.radio2_text_up.setColor(prst_white.r,prst_white.b,prst_white.b);
            LADCanvas.radio2_text_center.setColor(prst_white.r,prst_white.b,prst_white.b);
            LADCanvas.radio2_text_down.setColor(prst_white.r,prst_white.b,prst_white.b);
            LADCanvas.radio2_box.setColor(prst_white.r,prst_white.b,prst_white.b);
        } else {
            LADCanvas.radio2_text_center.setText("ON");
            LADCanvas.radio2_text_up.setColor(prst_green.r,prst_green.g,prst_green.b);
            LADCanvas.radio2_text_center.setColor(prst_green.r,prst_green.g,prst_green.b);
            LADCanvas.radio2_text_down.setColor(prst_green.r,prst_green.g,prst_green.b);
            LADCanvas.radio2_box.setColor(prst_green.r,prst_green.g,prst_green.b);
        }

        # Update the IFF's box
        iff_channel = getprop("instrumentation/transponder/id-code");
        mode5_channel = getprop("instrumentation/iff/channel_prop");
        iff_power = getprop("instrumentation/transponder/inputs/knob-mode") == 4;
        mode5_power = getprop("instrumentation/iff/power_prop");
        iff_response = getprop("instrumentation/iff/response");

        LADCanvas.iff_text_center.setText(sprintf("M1/2-%04d", iff_channel));
        LADCanvas.iff_text_mode3.setText(sprintf("M3/A-%04d", iff_channel));
        LADCanvas.iff_text_mode5.setText(sprintf("M4/5-%04d", mode5_channel));

        if (iff_power) {
            LADCanvas.iff_text_up.setText("IFF - ON");
            LADCanvas.iff_text_up.setColor(prst_green.r,prst_green.g,prst_green.b);
            LADCanvas.iff_text_center.setColor(prst_green.r,prst_green.g,prst_green.b);
            LADCanvas.iff_text_mode3.setColor(prst_green.r,prst_green.g,prst_green.b);
            if (iff_response) {
                LADCanvas.iff_box.setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b);
            } else {
                LADCanvas.iff_box.setColor(prst_green.r,prst_green.g,prst_green.b);
            }
        } else {
            LADCanvas.iff_text_up.setText("IFF - OFF");
            LADCanvas.iff_text_up.setColor(prst_white.r,prst_white.g,prst_white.b);
            LADCanvas.iff_text_center.setColor(prst_white.r,prst_white.g,prst_white.b);
            LADCanvas.iff_text_mode3.setColor(prst_white.r,prst_white.g,prst_white.b);
            LADCanvas.iff_box.setColor(prst_white.r,prst_white.g,prst_white.b);
        }
        
        if (mode5_power) {
            LADCanvas.iff_text_mode5.setColor(prst_green.r,prst_green.g,prst_green.b);
        } else {
            LADCanvas.iff_text_mode5.setColor(prst_white.r,prst_white.g,prst_white.b);
        }

        # Update the Datalink's box
        datalink_channel = getprop("instrumentation/datalink/channel_prop");
        datalink_power = getprop("instrumentation/datalink/power_prop");
        datalink_connections = datalink.get_connected_callsigns();
        on_link_count = 0;
        if (datalink_connections != nil) {
            foreach(connection ; datalink_connections) {
                data = datalink.get_data(connection);
                if (data != nil and data.on_link()) {
                    on_link_count += 1;
                }
            }
        }

        LADCanvas.dtl_text_center.setText(sprintf("Link16-%04d", datalink_channel));
        LADCanvas.dtl_text_down.setText(sprintf("ON LINK : %02d", on_link_count));
        if (datalink_power) {
            if (getprop("sim/model/f15/avionics/jtids-selected-mode-knob") == 3) {  # If we're in silent mode
                LADCanvas.dtl_text_up.setText("JTIDS - SIL");
            } else {
                LADCanvas.dtl_text_up.setText("JTIDS - ON");
            }
            LADCanvas.dtl_text_up.setColor(prst_green.r,prst_green.g,prst_green.b);
            LADCanvas.dtl_text_center.setColor(prst_green.r,prst_green.g,prst_green.b);
            LADCanvas.dtl_text_down.setColor(prst_green.r,prst_green.g,prst_green.b);
            LADCanvas.dtl_box.setColor(prst_green.r,prst_green.g,prst_green.b);
        } else {
            LADCanvas.dtl_text_up.setText("JTIDS - OFF");
            LADCanvas.dtl_text_up.setColor(prst_white.r,prst_white.g,prst_white.b);
            LADCanvas.dtl_text_center.setColor(prst_white.r,prst_white.g,prst_white.b);
            LADCanvas.dtl_text_down.setColor(prst_white.r,prst_white.g,prst_white.b);
            LADCanvas.dtl_box.setColor(prst_white.r,prst_white.g,prst_white.b);
        }

        # Update the Tacan's box
        tacan_channel = getprop("instrumentation/tacan/display/channel");
        tacan_in_range = getprop("instrumentation/tacan/in-range");
        LADCanvas.tacan_text_down.setText(tacan_channel);
        if (tacan_in_range) {
            LADCanvas.tacan_text_up.setColor(prst_green.r,prst_green.g,prst_green.b);
            LADCanvas.tacan_text_down.setColor(prst_green.r,prst_green.g,prst_green.b);
            LADCanvas.tacan_box.setColor(prst_green.r,prst_green.g,prst_green.b);
        } else {
            LADCanvas.tacan_text_up.setColor(prst_white.r,prst_white.g,prst_white.b);
            LADCanvas.tacan_text_down.setColor(prst_white.r,prst_white.g,prst_white.b);
            LADCanvas.tacan_box.setColor(prst_white.r,prst_white.g,prst_white.b);
        }

        # Update the ILS's box
        ils_channel = getprop("instrumentation/nav/frequencies/selected-mhz");
        ils_in_range = getprop("instrumentation/nav/in-range");
        LADCanvas.ils_text_down.setText(sprintf("%0.2f MHz", ils_channel));
        if (ils_in_range) {
            LADCanvas.ils_text_up.setColor(prst_green.r,prst_green.g,prst_green.b);
            LADCanvas.ils_text_down.setColor(prst_green.r,prst_green.g,prst_green.b);
            LADCanvas.ils_box.setColor(prst_green.r,prst_green.g,prst_green.b);
        } else {
            LADCanvas.ils_text_up.setColor(prst_white.r,prst_white.g,prst_white.b);
            LADCanvas.ils_text_down.setColor(prst_white.r,prst_white.g,prst_white.b);
            LADCanvas.ils_box.setColor(prst_white.r,prst_white.g,prst_white.b);
        }

        # Utilities
        var valid_radar_targets = [];  # used to check if we ain't displaying a EPAWSS or Datalink contact, that we already got on radar
        foreach (contact ; awg_9.tgts_list) {
                if (contact.get_display() == 1) {
                    append(valid_radar_targets, contact.get_Callsign());
                }
        }

        # Main center screens updates
        # We determine which "displays" are online (VSD, HSD, PACS etc...)
        # Allowing us to update only needed displays.
        # We also shift (translate) online displays to the correct position,
        # whether they're on the left, center or right main screens.

        if (main_screens.left == "VSD") {
            VSD_ON = 1;
            LADCanvas.VSDScreen.setTranslation(0,0);  # Default position's position for the left main screen
        } elsif (main_screens.center == "VSD") {
            VSD_ON = 1;
            LADCanvas.VSDScreen.setTranslation(8192/3,0);
        } elsif (main_screens.right == "VSD") {
            VSD_ON = 1;
            LADCanvas.VSDScreen.setTranslation((8192/3)*2,0);
        } else {
            VSD_ON = 0;
        }

        if (main_screens.left == "HSD") {
            HSD_ON = 1;
            LADCanvas.HSDScreen.setTranslation(0,0);  # Default position's position for the left main screen
            LADCanvas.HSDScreenLines.setTranslation(0,0);
            LADCanvas.HSDScreenCircles.setTranslation(0,0);
        } elsif (main_screens.center == "HSD") {
            HSD_ON = 1;
            LADCanvas.HSDScreen.setTranslation(8192/3,0);
            LADCanvas.HSDScreenLines.setTranslation(8192/3,0);
            LADCanvas.HSDScreenCircles.setTranslation(8192/3,0);
        } elsif (main_screens.right == "HSD") {
            HSD_ON = 1;
            LADCanvas.HSDScreen.setTranslation((8192/3)*2,0);
            LADCanvas.HSDScreenLines.setTranslation((8192/3)*2,0);
            LADCanvas.HSDScreenCircles.setTranslation((8192/3)*2,0);
        } else {
            HSD_ON = 0;
        }

        if (main_screens.left == "PACS") {
            PACS_ON = 1;
            LADCanvas.PACSScreen.setTranslation(0,620);  # Default position's position for the left main screen
        } elsif (main_screens.center == "PACS") {
            PACS_ON = 1;
            LADCanvas.PACSScreen.setTranslation(8192/3,620);
        } elsif (main_screens.right == "PACS") {
            PACS_ON = 1;
            LADCanvas.PACSScreen.setTranslation((8192/3)*2,620);
        } else {
            PACS_ON = 0;
        }

        ## VSD Updates
        if (VSD_ON) {  # Optimization, we only wanna update the VSD display if it's online
            LADCanvas.VSDScreen.setVisible(1);
            # Update the texts
            LADCanvas.vsd_rdr_range_txt.setText(sprintf("%03d NM", getprop("instrumentation/radar/radar2-range")));
            if (getprop("instrumentation/radar/radar-filter-mode") == 0) {  # if radar's A/A
                LADCanvas.vsd_rdr_filter_1.setText("A");
                LADCanvas.vsd_rdr_filter_3.setText("A");
            } elsif (getprop("instrumentation/radar/radar-filter-mode") == 1) {  # if radar's A/G
                LADCanvas.vsd_rdr_filter_1.setText("A");
                LADCanvas.vsd_rdr_filter_3.setText("G");
            } elsif (getprop("instrumentation/radar/radar-filter-mode") == 2) {  # if radar's A/SEA
                LADCanvas.vsd_rdr_filter_1.setText("A");
                LADCanvas.vsd_rdr_filter_3.setText("S");
            }
            # Update the horizon line's placement
            var pitch_offset = 15; # makes the thing 15 pixels below the middle, so it ain't hidden by the grid
            var DTOR = math.pi / 180.0;
            new_y_pos_hori = (2300 * getprop("orientation/pitch-deg")) / 60;
            # clamp the values of the y pos of the horizon line, so it don't get outta the grid
            if (new_y_pos_hori > 2210) {
                new_y_pos_hori = 2210;
            } elsif (new_y_pos_hori < -1960) {
                new_y_pos_hori = -1960;
            }
            LADCanvas.vsd_horizon_line.setTranslation(0.0, -new_y_pos_hori-pitch_offset);
            LADCanvas.vsd_horizon_line.setRotation(-getprop("orientation/roll-deg") * DTOR);

            # Update the radar bars / mode text
            radar_mode_str = "";
            if (getprop("instrumentation/radar/radar-standby")) {
                radar_mode_str = "STBY";
            } elsif (awg_9.wcs_current_mode == awg_9.wcs_mode_pulse_srch) {
                radar_mode_str = "RWS";
            } elsif (awg_9.wcs_current_mode == awg_9.wcs_mode_tws_auto) {
                radar_mode_str = "TWSA";
            } elsif (awg_9.wcs_current_mode == awg_9.wcs_mode_tws_man) {
                radar_mode_str = "TWSM";
            }
            LADCanvas.vsd_radar_mode_text.setText(sprintf("%d %s", awg_9.HoFieldBars.getValue(), radar_mode_str));

            # Update the cursor's placement, given input degrees
            if (awg_9.wcs_current_mode != awg_9.wcs_mode_tws_auto) {  # The cursor moves on its own in TWS AUTO and cannot be controlled
                var cursor_az_deg = getprop("sim/model/f15/controls/LAD/cursor-deg-az");
                var cursor_el_deg = getprop("sim/model/f15/controls/LAD/cursor-deg-el");
                var cursor_x_move = cursor_az_deg * 1354 / 60;
                var cursor_y_move = cursor_el_deg * (1131*2) / 60;
                var cursor_hit_boundaries_el = cursor_y_move > 1110*2 or cursor_y_move < -1110*2;

                if (cursor_x_move > 1354-38*3) {  # We clamp the values of azimuth of the cursor
                    cursor_x_move = 1354-38*3;
                } elsif (cursor_x_move < -1354+38*3) {
                    cursor_x_move = -1354+38*3;
                }

                if (cursor_hit_boundaries_el) {
                    # If the elevation boundary is hit upward (and the elevation bars value can still go up), we reset the cursor position and increase the elevation bars value
                    # Same thing for downward
                    if (cursor_y_move > 0 and awg_9.HoFieldBars.getValue() != 2) {  # Is positive, so downward; 2 is min
                        cursor_x_move = 0;
                        cursor_y_move = 0;
                        setprop("sim/model/f15/controls/LAD/cursor-deg-az", 0);
                        setprop("sim/model/f15/controls/LAD/cursor-deg-el", 0);
                        awg_9.HoFieldBars.setValue(awg_9.HoFieldBars.getValue() - 2);
                    } elsif (cursor_y_move < 0 and awg_9.HoFieldBars.getValue() != 8) {  # Is negative, so upward; 8 is max
                        cursor_x_move = 0;
                        cursor_y_move = 0;
                        setprop("sim/model/f15/controls/LAD/cursor-deg-az", 0);
                        setprop("sim/model/f15/controls/LAD/cursor-deg-el", 0);
                        awg_9.HoFieldBars.setValue(awg_9.HoFieldBars.getValue() + 2);
                    }
                }

                var cursor_pos = [677*2+cursor_x_move, 2262+500+cursor_y_move];
                LADCanvas.vsd_cursor.setTranslation(cursor_x_move, cursor_y_move);
                LADCanvas.vsd_cursor.setVisible(1);
            } else {
                LADCanvas.vsd_cursor.setVisible(1);
            }

            # Update some texts giving info about ourselves
            LADCanvas.vsd_ground_speed.setText(sprintf("G %03d", getprop("velocities/groundspeed-kt")));
            LADCanvas.vsd_airspeed.setText(sprintf("T %03d", getprop("velocities/airspeed-kt")));
            LADCanvas.vsd_altitude.setText(sprintf("ALT %05d", getprop("instrumentation/altimeter/indicated-altitude-ft")));
            LADCanvas.vsd_fps.setText(sprintf("FPS %04d", getprop("velocities/down-relground-fps")));
            LADCanvas.vsd_heading_true.setText(sprintf("H %03d", getprop("orientation/heading-deg")));

            if (getprop("autopilot/route-manager/current-wp") == -1) {
                LADCanvas.vsd_stpt_index.setText("No.00");
            } else {
                LADCanvas.vsd_stpt_index.setText(sprintf("No.%02d", getprop("autopilot/route-manager/current-wp")));
            }

            # Move the azimuth and elevation carats around
            var azimuth_sweep = getprop("sim/model/f15/instrumentation/awg-9/sweep-factor");
            var carat_sweep = 0;
            if (azimuth_sweep != nil) {  # this property is created in awg_9.nas, so at startup it's null
                carat_sweep = azimuth_sweep * 1280;
            }
            LADCanvas.vsd_azimuth_carat.setTranslation(carat_sweep, 0.0);
            
            carat_elev_pxs = awg_9.HoFieldOffset.getValue() * (1110*2) / 60;
            LADCanvas.vsd_elevation_carat.setTranslation(0, carat_elev_pxs);

            # Update the azimuth circles'
            if (getprop("instrumentation/radar/az-field") == 120) {
                LADCanvas.vsd_azimuth_limit_circle_right_60.setVisible(1);
                LADCanvas.vsd_azimuth_limit_circle_left_60.setVisible(1);
                LADCanvas.vsd_azimuth_limit_circle_right_30.setVisible(0);
                LADCanvas.vsd_azimuth_limit_circle_left_30.setVisible(0);
            } elsif (getprop("instrumentation/radar/az-field") == 60) {
                LADCanvas.vsd_azimuth_limit_circle_right_60.setVisible(0);
                LADCanvas.vsd_azimuth_limit_circle_left_60.setVisible(0);
                LADCanvas.vsd_azimuth_limit_circle_right_30.setVisible(1);
                LADCanvas.vsd_azimuth_limit_circle_left_30.setVisible(1);
            }

            max_alt = (getprop("instrumentation/altimeter/indicated-altitude-ft") + awg_9.coverage_up) * .001;  # in thousands of feet
            min_alt = (getprop("instrumentation/altimeter/indicated-altitude-ft") - awg_9.coverage_down) * .001;
            
            y_move_max = max_alt * -2220 / 60;
            y_move_min = min_alt * -2220 / 60;
            
            if (y_move_max > 2200) {  # We clamp the values of elevation of the carat
                y_move_max = 2200;
            } elsif (y_move_max < -2200) {
                y_move_max = -2200;
            }
            if (y_move_min > 2200) {
                y_move_min = 2200;
            } elsif (y_move_min < -2200) {
                y_move_min = -2200;
            }
            
            LADCanvas.vsd_vert_coverage_circle_up.setTranslation(0, y_move_max);
            LADCanvas.vsd_vert_coverage_circle_down.setTranslation(0, y_move_min);
            LADCanvas.vsd_vert_coverage_text_up.setTranslation(75+75,2262+500+y_move_max);
            LADCanvas.vsd_vert_coverage_text_down.setTranslation(75+75,2262+500+y_move_min);
            LADCanvas.vsd_vert_coverage_text_up.setText(sprintf("%d", max_alt));
            LADCanvas.vsd_vert_coverage_text_down.setText(sprintf("%d", min_alt));

            # Update the steerpoint symbols
            var stpt_idx = 0;
            if (getprop("sim/model/instrumentation/vhf/mode") == 0) {  # if we're in normal nav mode (not TACAN or ILS)

                # Update the wp dist/ETA texts
                if (getprop("autopilot/route-manager/active")) {  # if route-manager's active
                    LADCanvas.vsd_stpt_eta.setText("XX:XX");
                    if (getprop("autopilot/route-manager/wp/dist") != nil) {
                        LADCanvas.vsd_stpt_dist.setText(sprintf("N %4.1f", getprop("autopilot/route-manager/wp/dist")));
                    } else {
                        LADCanvas.vsd_stpt_dist.setText("N 9999");
                    }

                    if (getprop("autopilot/route-manager/wp/eta-seconds") != nil) {
                        nav_mins = sprintf("%.0f", getprop("autopilot/route-manager/wp/eta-seconds") / 60);
                        nav_secs = (getprop("autopilot/route-manager/wp/eta-seconds") / 60 - nav_mins) * 60;  # remove whole minutes for seconds
                        if (nav_secs < 0) {  # tiny fix
                            nav_mins = nav_mins - 1;
                            nav_secs = 60 + nav_secs;
                        }
                        LADCanvas.vsd_stpt_eta.setText(sprintf("%02d:%02d", nav_mins, nav_secs));
                    } else {
                        LADCanvas.vsd_stpt_eta.setText("XX:XX");
                    }

                    if (getprop("autopilot/route-manager/wp/true-bearing-deg") != nil) {
                        LADCanvas.vsd_stpt_bearing.setText(sprintf("B %03d", getprop("autopilot/route-manager/wp/true-bearing-deg")));
                    } else {
                        LADCanvas.vsd_stpt_bearing.setText("B 999");
                    }
                } else {
                    LADCanvas.vsd_stpt_eta.setText("XX:XX");
                    LADCanvas.vsd_stpt_dist.setText("N 9999");
                    LADCanvas.vsd_stpt_bearing.setText("B 999");
                }


                var plan = flightplan();
                var planSize = plan.getPlanSize();
                for (stpt_idx = 0; stpt_idx < planSize; stpt_idx+=1) {
                    if (stpt_idx < LADCanvas.stpt_symbols_max) {
                        var wp = plan.getWP(stpt_idx);
                        var wpC = geo.Coord.new();
                        if (wp.alt_cstr != nil) {  # steerpoints don't necessarily got an altitude
                            wpC.set_latlon(wp.lat,wp.lon,wp.alt_cstr);
                        } else {
                            wpC.set_latlon(wp.lat,wp.lon,0);
                        }
                        steerDir = [geo.aircraft_position().course_to(wpC), vector.Math.getPitch(geo.aircraft_position(), wpC)];  # id 0 is bearing, id 1 is elevation
                        wpbear = geo.normdeg180(steerDir[0] - getprop("orientation/heading-deg"));  # relative bearing to the steerpoint (20 means 20* right)
                        wpelev = -steerDir[1];  # elevation to the steerpoint (20* means 20* down)
                        if (steerDir[1] != nil) {  # that's a safety, why not after all?
                            LADCanvas.stpt_symbols[stpt_idx].setVisible(1);
                            LADCanvas.stpt_texts[stpt_idx].setVisible(1);
                            LADCanvas.stpt_texts[stpt_idx].setText(sprintf("%d", stpt_idx));
                            x_move = wpbear * 1354 / 60;
                            y_move = wpelev * (1131 * 2) / 60;

                            if (x_move > 1300) {  # clamp the translation's values so it don't get outta the screen
                                x_move = 1300;
                            } elsif (x_move < -1300) {
                                x_move = -1300;
                            }
                            if (y_move > 1072) {
                                y_move = 1072
                            } elsif (y_move < -1072) {
                                y_move = -1072
                            }

                            LADCanvas.stpt_symbols[stpt_idx].setTranslation(x_move, y_move);
                            LADCanvas.stpt_texts[stpt_idx].setTranslation(677*2+x_move, 2262+500+145+y_move);
                            if (stpt_idx == getprop("autopilot/route-manager/current-wp")) {  # if this is the current steerpoint, make it bigger/brighter/bolder, plus change color
                                LADCanvas.stpt_symbols[stpt_idx].setStrokeLineWidth(7);
                                LADCanvas.stpt_symbols[stpt_idx].setColor(prst_rose.r,prst_rose.g,prst_rose.b);
                                LADCanvas.stpt_texts[stpt_idx].setColor(prst_rose_dark.r,prst_rose_dark.g,prst_rose_dark.b);
                            } else {
                                LADCanvas.stpt_symbols[stpt_idx].setStrokeLineWidth(4);
                                LADCanvas.stpt_symbols[stpt_idx].setColor(prst_purple.r,prst_purple.g,prst_purple.b);
                                LADCanvas.stpt_texts[stpt_idx].setColor(prst_purple_dark.r,prst_purple_dark.g,prst_purple_dark.b);
                            }
                        }
                    }
                }
            } else {
                LADCanvas.vsd_stpt_eta.setText("XX:XX");
                LADCanvas.vsd_stpt_dist.setText("N 9999");
                LADCanvas.vsd_stpt_bearing.setText("B 999");
            }

            # Do not display any unused steerpoint boxes
            for (var nv = stpt_idx; nv < LADCanvas.stpt_symbols_max;nv += 1) {
                LADCanvas.stpt_symbols[nv].setVisible(0);
                LADCanvas.stpt_texts[nv].setVisible(0);
            }

            # Update the target symbols
            var target_idx = 0;
            var found_lock = 0;
            var lock_assigned = 0;
            foreach (contact ; awg_9.tgts_list) {
            
                # Check for chaffs. We don't need the target to be visible for that, visible checks are ran on the chaffs themselves
                if (contact.getChaffNode() != nil and contact.getChaffNode().getValue() != nil and contact.getChaffNode().getValue() != 0) {
                    if (contact.getChaffNode().getValue() != chaff_lasts[contact.getUnique()]) {
                        chaff_lasts[contact.getUnique()] = contact.getChaffNode().getValue();  # released a new flare
                        append(chaffs_pos, {"gps": contact.get_Coord(), "release_time": elapsed});
                    }
                }
            
                if (contact.get_display() == 1) {
                    if (awg_9.active_u == contact) { # If it's the active radar lock we got
                        found_lock = 1;
                    }
                    if (target_idx < LADCanvas.tgt_symbols_max) {

                        contact_data = datalink.get_data(contact.get_Callsign());
                        if (contact_data == nil or !contact_data.is_known()) {
                            unknown = 1;
                        } else {
                            unknown = 0;
                        }

                        if (unknown == 0) {
                            friendly = contact_data.is_friendly() or contact.getIffResponse();
                            hostile = contact_data.is_hostile();
                            on_link = contact_data.on_link();
                        } else {
                            friendly = contact.getIffResponse();
                            hostile = 0;
                            on_link = 0;
                        }

                        if (on_link) {
                            LADCanvas.tgt_symbols[target_idx].setColor(prst_blue.r,prst_blue.g,prst_blue.b, contact.get_fading());
                            LADCanvas.tgt_texts[target_idx].setColor(prst_blue_dark.r,prst_blue_dark.g,prst_blue_dark.b, contact.get_fading());
                        } elsif (friendly) {
                            LADCanvas.tgt_symbols[target_idx].setColor(prst_green.r,prst_green.g,prst_green.b, contact.get_fading());
                            LADCanvas.tgt_texts[target_idx].setColor(prst_green_dark.r,prst_green_dark.g,prst_green_dark.b, contact.get_fading());
                        } elsif (hostile) {
                            LADCanvas.tgt_symbols[target_idx].setColor(prst_red.r,prst_red.g,prst_red.b, contact.get_fading());
                            LADCanvas.tgt_texts[target_idx].setColor(prst_red_dark.r,prst_red_dark.g,prst_red_dark.b, contact.get_fading());
                        } else {
                            LADCanvas.tgt_symbols[target_idx].setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b, contact.get_fading());
                            LADCanvas.tgt_texts[target_idx].setColor(prst_yellow_dark.r,prst_yellow_dark.g,prst_yellow_dark.b, contact.get_fading());
                        }

                        LADCanvas.tgt_symbols[target_idx].setVisible(1);
                        LADCanvas.tgt_texts[target_idx].setVisible(1);
                        xc = contact.get_deviation(getprop("orientation/heading-deg")) or 0;
                        yc = -contact.get_total_elevation(getprop("orientation/pitch-deg")) or 0;

                        x_move = xc*1354/60;
                        y_move = yc*(1131*2)/60;

                        if (x_move > 1300) {  # clamp the translation's values so it don't get outta the screen
                                x_move = 1300;  # don't know why I did this there ain't no way a radar contact is outta the VSD screen ???!
                        } elsif (x_move < -1300) {
                            x_move = -1300;
                        }
                        if (y_move > 1072) {
                            y_move = 1072
                        } elsif (y_move < -1072) {
                            y_move = -1072
                        }

                        LADCanvas.tgt_symbols[target_idx].setTranslation(x_move, y_move); # the factors is to let display correspond to 120 degrees wide and height.
                        LADCanvas.tgt_texts[target_idx].setTranslation(677*2+x_move, 2262+500+145+y_move); # the factors is to let display correspond to 120 degrees wide and height.
                        if (found_lock == 1 and lock_assigned == 0) {
                            if (awg_9.wcs_current_mode == awg_9.wcs_mode_tws_auto) {  # in TWS AUTO, the cursor's automatic
                                LADCanvas.vsd_cursor.setTranslation(x_move, y_move);
                            }
                            lock_assigned = 1;  # so others don't take the lock symbology from it
                        }
                        if (contact.get_model() != nil and typeLookup[contact.get_model()] != nil) {
                            contact_type = typeLookup[contact.get_model()];
                            contact_alt = contact.get_altitude() * 0.001;  # So it's in thousands of feet
                            LADCanvas.tgt_texts[target_idx].setText(sprintf("%s %02d", contact_type, contact_alt));
                        } else {  # Model's unknown to our radar
                            contact_alt = contact.get_altitude() * 0.001;  # So it's in thousands of feet
                            LADCanvas.tgt_texts[target_idx].setText(sprintf("UNK %02d", contact_alt));
                        }
                        target_idx += 1;
                    }
                }
            }

            if (found_lock == 1) {
                
                LADCanvas.vsd_tgt_true_speed.setVisible(1);
                LADCanvas.vsd_tgt_bearing.setVisible(1);
                LADCanvas.vsd_tgt_heading.setVisible(1);
                LADCanvas.vsd_tgt_aspect.setVisible(1);
                LADCanvas.vsd_tgt_altitude.setVisible(1);
                LADCanvas.vsd_tgt_range.setVisible(1);
                LADCanvas.vsd_tgt_fps.setVisible(1);
                LADCanvas.vsd_tgt_model.setVisible(1);
                LADCanvas.vsd_tgt_closure_pin.setVisible(1);
                LADCanvas.vsd_tgt_closure_text.setVisible(1);

                if (awg_9.wcs_current_mode == awg_9.wcs_mode_pulse_srch) {  # In RWS mode, we don't get as much and precise info as in TWS
                    LADCanvas.vsd_tgt_true_speed.setVisible(0);
                    LADCanvas.vsd_tgt_heading.setVisible(0);
                    LADCanvas.vsd_tgt_aspect.setVisible(0);
                    LADCanvas.vsd_tgt_fps.setVisible(0);
                    LADCanvas.vsd_tgt_model.setVisible(0);
                }

                if (awg_9.active_u != nil) { # safety
                    # Update current target's info texts across the VSD
                    LADCanvas.vsd_tgt_true_speed.setText(sprintf("T %03d", awg_9.active_u.get_Speed()));
                    LADCanvas.vsd_tgt_bearing.setText(sprintf("B %03d", awg_9.active_u.get_bearing()));
                    LADCanvas.vsd_tgt_heading.setText(sprintf("H %03d", awg_9.active_u.get_heading()));

                    tgt_aspect = math.round(awg_9.active_u.get_aspect()/10.0);

                    if (math.abs(tgt_aspect) > 17) {
                        tgt_aspect = "H";
                    } elsif (math.abs(tgt_aspect) < 1) {
                        tgt_aspect = "T";
                    } else {
                        tgt_aspect = sprintf("%2d%s", math.abs(tgt_aspect), tgt_aspect > 0 ? "R" : "L");
                    }

                    LADCanvas.vsd_tgt_aspect.setText(tgt_aspect);
                    LADCanvas.vsd_tgt_altitude.setText(sprintf("%05d", awg_9.active_u.get_altitude()));
                    LADCanvas.vsd_tgt_range.setText(sprintf("%03.1f NM", awg_9.active_u.get_range()));
                    LADCanvas.vsd_tgt_fps.setText(sprintf("FPS %04d", awg_9.active_u.get_Vertical_Speed()));
                    LADCanvas.vsd_tgt_closure_text.setText(sprintf("%d", awg_9.active_u.get_closure_rate()));


                    model = "UNKNOWN";
                    if (awg_9.active_u.ModelType != "")
                        model = awg_9.active_u.ModelType;
                    LADCanvas.vsd_tgt_model.setText(model);

                    # Scale:
                    # To be at max (moving 4,600px up), target range must be max radar range
                    range_y = 4600 * awg_9.active_u.get_range() / getprop("instrumentation/radar/radar2-range");
                    range_y += 75;  # Fix because the shit starts at outside of the grid, but still inside of the VSD outline

                    LADCanvas.vsd_tgt_closure_pin.setTranslation(0.0,-range_y);
                    LADCanvas.vsd_tgt_closure_text.setTranslation(677*4-75-140,5175-range_y);
                }
            } else {
                LADCanvas.vsd_tgt_true_speed.setVisible(0);
                LADCanvas.vsd_tgt_bearing.setVisible(0);
                LADCanvas.vsd_tgt_heading.setVisible(0);
                LADCanvas.vsd_tgt_aspect.setVisible(0);
                LADCanvas.vsd_tgt_altitude.setVisible(0);
                LADCanvas.vsd_tgt_range.setVisible(0);
                LADCanvas.vsd_tgt_fps.setVisible(0);
                LADCanvas.vsd_tgt_model.setVisible(0);
                LADCanvas.vsd_tgt_closure_pin.setVisible(0);
                LADCanvas.vsd_tgt_closure_text.setVisible(0);
            }

            # Do not display any unused target boxes
            for (var nv = target_idx; nv < LADCanvas.tgt_symbols_max;nv += 1) {
                LADCanvas.tgt_symbols[nv].setVisible(0);
                LADCanvas.tgt_texts[nv].setVisible(0);
            }
            
            # Draw the chaff bleps
            
            var chaff_idx = 0;
            foreach (chaff ; chaffs_pos) {
                #print(chaff_idx);
                if (elapsed - chaff.release_time > (27 * rand() / 1.5)) {  # if the chaff is too old
                    remove(chaffs_pos, chaff);  # remove it from the list
                    #print("CHAFF TOO OLD");
                } else {
                    steerDir = [geo.aircraft_position().course_to(chaff.gps), vector.Math.getPitch(geo.aircraft_position(), chaff.gps)];  # id 0 is bearing, id 1 is elevation
                    wpbear = geo.normdeg180(steerDir[0] - getprop("orientation/heading-deg"));  # relative bearing to the steerpoint (20 means 20* right)
                    wpelev = -steerDir[1];  # elevation to the steerpoint (20* means 20* down)
                    hidden_by_terrain = !awg_9.TerrainManager.IsVisible(nil, nil, SelectCoordForce=chaff.gps);
                    if (!hidden_by_terrain and wpbear < getprop("instrumentation/radar/az-field")/2 and wpbear > -getprop("instrumentation/radar/az-field")/2 and wpbear < getprop("instrumentation/radar/ho-field")/2 and wpbear > -getprop("instrumentation/radar/ho-field")/2) {  # we're making sure that the chaff ain't outta our radar's cone!
                        LADCanvas.chaff_symbols[chaff_idx].setVisible(1);
                        x_move = wpbear * 1354 / 60;
                        y_move = wpelev * (1131 * 2) / 60;
                        
                        LADCanvas.chaff_symbols[chaff_idx].setTranslation(x_move, y_move);
                        print("CHAFF DRAWN");
                        chaff_idx += 1;
                    } else {
                        #print("CHAFF AIN'T VISIBLE");
                    }
                }
            }
            
            # Do not display any unused chaff bleps
            for (var nv = chaff_idx; nv < LADCanvas.chaff_symbols_max;nv += 1) {
                LADCanvas.chaff_symbols[nv].setVisible(0);
            }

            # Update the datalink symbols
            var dlnk_idx = 0;
            var datalink_connections = datalink.get_all_callsigns();
            foreach (contact ; datalink_connections) {
                already_on_rdr = 0;  # if its' on our radar, we don't display it.
                foreach(rdrcontact ; valid_radar_targets) {
                    if (rdrcontact == contact) {
                        already_on_rdr = 1;
                    }
                }
                if (already_on_rdr == 0) {
                    if (dlnk_idx < LADCanvas.dlnk_symbols_max) {

                        contact_data = datalink.get_data(contact);
                        contact_idx = contact_data.index();
                        if (contact_idx != nil) {  # can make things bug sometimes
                            contact_model = getprop("/ai/models/multiplayer["~contact_idx~"]/model-short");
                            contact_lat = getprop("/ai/models/multiplayer["~contact_idx~"]/position/latitude-deg");
                            contact_lon = getprop("/ai/models/multiplayer["~contact_idx~"]/position/longitude-deg");
                            contact_alt = getprop("/ai/models/multiplayer["~contact_idx~"]/position/altitude-ft");
                            contact_coord = geo.Coord.new().set_latlon(contact_lat,contact_lon,contact_alt*FT2M);
                            contact_bearing = geo.aircraft_position().course_to(contact_coord);
                            contact_elevation = vector.Math.getPitch(geo.aircraft_position(), contact_coord);
                            if (contact_data == nil or !contact_data.is_known()) {
                                unknown = 1;
                            } else {
                                unknown = 0;
                            }

                            if (unknown == 0) {
                                friendly = contact_data.is_friendly();
                                hostile = contact_data.is_hostile();
                                on_link = contact_data.on_link();
                            } else {
                                friendly = 0;
                                hostile = 0;
                                on_link = 0;
                            }

                            if (on_link) {
                                LADCanvas.dlnk_symbols[dlnk_idx].setColor(prst_blue.r,prst_blue.g,prst_blue.b);
                                LADCanvas.dlnk_texts[dlnk_idx].setColor(prst_blue_dark.r,prst_blue_dark.g,prst_blue_dark.b);
                            } elsif (friendly) {
                                LADCanvas.dlnk_symbols[dlnk_idx].setColor(prst_green.r,prst_green.g,prst_green.b);
                                LADCanvas.dlnk_texts[dlnk_idx].setColor(prst_green_dark.r,prst_green_dark.g,prst_green_dark.b);
                            } elsif (hostile) {
                                LADCanvas.dlnk_symbols[dlnk_idx].setColor(prst_red.r,prst_red.g,prst_red.b);
                                LADCanvas.dlnk_texts[dlnk_idx].setColor(prst_red_dark.r,prst_red_dark.g,prst_red_dark.b);
                            } else {
                                LADCanvas.dlnk_symbols[dlnk_idx].setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b);
                                LADCanvas.dlnk_texts[dlnk_idx].setColor(prst_yellow_dark.r,prst_yellow_dark.g,prst_yellow_dark.b);
                            }

                            LADCanvas.dlnk_symbols[dlnk_idx].setVisible(1);
                            LADCanvas.dlnk_texts[dlnk_idx].setVisible(1);

                            xc = deviation_normdeg(getprop("orientation/heading-deg"), contact_bearing);
                            yc = -deviation_normdeg(getprop("orientation/pitch-deg"), contact_elevation);

                            x_move = xc*1354/60;
                            y_move = yc*(1131*2)/60;

                            if (x_move > 1300) {  # clamp the translation's values so it don't get outta the screen
                                    x_move = 1300;
                            } elsif (x_move < -1300) {
                                x_move = -1300;
                            }
                            if (y_move > 1072) {
                                y_move = 1072
                            } elsif (y_move < -1072) {
                                y_move = -1072
                            }

                            LADCanvas.dlnk_symbols[dlnk_idx].setTranslation(x_move, y_move); # the factors is to let display correspond to 120 degrees wide and height.
                            LADCanvas.dlnk_texts[dlnk_idx].setTranslation(677*2+x_move, 2262+500+145+y_move); # the factors is to let display correspond to 120 degrees wide and height.
                            contact_alt = contact_alt * 0.001;  # So it's in thousands of feet
                            LADCanvas.dlnk_texts[dlnk_idx].setText(sprintf("%s %02d", contact, contact_alt));
                            dlnk_idx += 1;
                        }
                    }
                }
            }

            # Do not display any unused target boxes
            for (var nv = dlnk_idx; nv < LADCanvas.dlnk_symbols_max;nv += 1) {
                LADCanvas.dlnk_symbols[nv].setVisible(0);
                LADCanvas.dlnk_texts[nv].setVisible(0);
            }
        } else {
            LADCanvas.VSDScreen.setVisible(0);
        }


        ## HSD Updates
        if (HSD_ON) {
            LADCanvas.HSDScreen.setVisible(1);
            LADCanvas.HSDScreenLines.setVisible(1);
            LADCanvas.HSDScreenCircles.setVisible(1);

            # Update measures
            LADCanvas.hsd_nm_to_px_x = (LADCanvas.hsd_great_circle_radius*2*(10/19)) / ((getprop("instrumentation/radar/radar2-range") * 1.25));
            LADCanvas.hsd_nm_to_px_y = (LADCanvas.hsd_great_circle_radius*2) / ((getprop("instrumentation/radar/radar2-range") * 1.25));

            # Update informational texts
            LADCanvas.hsd_ground_speed.setText(sprintf("G %03d", getprop("velocities/groundspeed-kt")));
            LADCanvas.hsd_airspeed.setText(sprintf("T %03d", getprop("velocities/airspeed-kt")));
            LADCanvas.hsd_heading_true.setText(sprintf("H %03d", getprop("orientation/heading-deg")));
            LADCanvas.hsd_altitude.setText(sprintf("ALT %05d", getprop("instrumentation/altimeter/indicated-altitude-ft")));
            LADCanvas.hsd_fps.setText(sprintf("FPS %04d", getprop("velocities/down-relground-fps")));

            LADCanvas.hsd_radar_range_text.setText(sprintf("%02d NM", getprop("instrumentation/radar/radar2-range")));
            if (getprop("instrumentation/radar/radar-filter-mode") == 0) {  # A / A
                LADCanvas.hsd_radar_filter.setText("  A/A");
            } elsif (getprop("instrumentation/radar/radar-filter-mode") == 1) {  # A / G
                LADCanvas.hsd_radar_filter.setText("  A/G");
            } elsif (getprop("instrumentation/radar/radar-filter-mode") == 2) {  # A / SEA
                LADCanvas.hsd_radar_filter.setText("A/SEA");
            }

            if (getprop("instrumentation/radar/radar-standby")) {  # If radar's standby, we don't display none of that
                LADCanvas.hsd_radar_mode.setText(" STANDBY");
            } elsif (awg_9.wcs_current_mode == awg_9.wcs_mode_tws_auto) {  # If we're in TWS AUTO mode
                LADCanvas.hsd_radar_mode.setText("TWS AUTO");
            } elsif (awg_9.wcs_current_mode == awg_9.wcs_mode_pulse_srch) {  # If we're in RWS mode
                LADCanvas.hsd_radar_mode.setText("     RWS");
            } elsif (awg_9.wcs_current_mode == awg_9.wcs_mode_tws_man) {  # If we're in TWS MAN mode
                LADCanvas.hsd_radar_mode.setText(" TWS MAN");
            }


            # Make different heading pins spin around the circle (TACAN, ILS, A/P, bullseye etc.) for bearing info

            # A/P
            # We determine which mode is actively used (Heading bug or True heading, not NAV1, there's a specific pin for NAV1, a.k.a. ILS)
            heading_mode = 0;  # 0 = offline, 1 = heading bug, 2 = true heading
            if (getprop("sim/gui/dialogs/autopilot/dg-heading-hold")) {
                heading_mode = 1;
            } elsif (getprop("sim/gui/dialogs/autopilot/true-heading-hold")) {
                heading_mode = 2;
            }

            if (heading_mode == 1) {
                #bearing_to_heading = geo.normdeg180(getprop("autopilot/settings/heading-bug-deg") - getprop("orientation/heading-deg"));  # relative bearing to the steerpoint (20 means 20* right)
                #heading_pin_ap_dir = ellipse_position_and_angle(bearing_to_heading, (LADCanvas.hsd_great_circle_radius * 10/19), LADCanvas.hsd_great_circle_radius, center_x=1355, center_y=1150*2+500+75);
                #LADCanvas.heading_pin_autopilot.moveTo(heading_pin_ap_dir[0]-1355, heading_pin_ap_dir[1]-(1150*2+500+75-m.hsd_great_circle_radius*2+30));
                #LADCanvas.heading_pin_autopilot.setRotation(heading_pin_ap_dir[2]);
                #LADCanvas.heading_pin_autopilot.setVisible(0);
            } elsif (heading_mode == 2) {
                #bearing_to_heading = geo.normdeg180(getprop("autopilot/settings/true-heading-deg") - getprop("orientation/heading-deg"));  # relative bearing to the steerpoint (20 means 20* right)
                #print(bearing_to_heading);
                #heading_pin_ap_dir = ellipse_position_and_angle(bearing_to_heading, (LADCanvas.hsd_great_circle_radius)*2, (LADCanvas.hsd_great_circle_radius / (10/19))*2, center_x=1355, center_y=1150*2+500+75);
                #print("HOWDY");
                #print(heading_pin_ap_dir[0]);
                #print(heading_pin_ap_dir[1]);
                #print(heading_pin_ap_dir[2] * R2D);
                #move_dir = ellipse_clamp(heading_pin_ap_dir[0], heading_pin_ap_dir[1]);
                #LADCanvas.heading_pin_autopilot.setTranslation((move_dir[0]-1355), (move_dir[1]));
                #LADCanvas.heading_pin_autopilot.setCenter(move_dir[0], move_dir[1]);
                #LADCanvas.heading_pin_autopilot.setRotation(-15*D2R);
                #LADCanvas.heading_pin_autopilot.setVisible(1);
            } else {
                LADCanvas.heading_pin_autopilot.setVisible(0);
            }


            # Bullseye info text update
            var bullseye_coord = geo.Coord.new().set_latlon(getprop("sim/model/f15/fcs/bullseye-lat"),getprop("sim/model/f15/fcs/bullseye-lon"),getprop("sim/model/f15/fcs/bullseye-alt")*FT2M);
            var bullseye_bearing = geo.normdeg180(geo.aircraft_position().course_to(bullseye_coord) - getprop("orientation/heading-deg"));  # relative bearing
            var bullseye_bearing_nonrel = geo.aircraft_position().course_to(bullseye_coord);
            var bullseye_range = geo.aircraft_position().distance_to(bullseye_coord)*M2NM;
            if (getprop("velocities/groundspeed-kt") < 150) {  # If we're on ground. 150kts in threshold for take off speed, ish
                var bullseye_eta = nil;
                var bullseye_eta_secs = nil;
            } else {
                var bullseye_eta = bullseye_range / getprop("velocities/groundspeed-kt");
                var bullseye_eta_secs = bullseye_eta * 3600;
            }

            if (getprop("sim/model/f15/fcs/bullseye-lat") == 0 and getprop("sim/model/f15/fcs/bullseye-lon") == 0 and getprop("sim/model/f15/fcs/bullseye-alt") == 0) {  # default bullseye values. We know if it ain't defined that way
                LADCanvas.hsd_bullseye_dist.setText("N 9999.9");
                LADCanvas.hsd_bullseye_bearing.setText("B 999");
                LADCanvas.hsd_bullseye_eta.setText("XX:XX");
            } else {
                LADCanvas.hsd_bullseye_dist.setText(sprintf("N %4.1f", bullseye_range));
                LADCanvas.hsd_bullseye_bearing.setText(sprintf("B %03d", bullseye_bearing_nonrel));

                if (bullseye_eta != nil) {
                    nav_mins = sprintf("%.0f", bullseye_eta_secs / 60);
                    nav_secs = (bullseye_eta_secs / 60 - nav_mins) * 60;  # remove whole minutes for seconds
                    if (nav_secs < 0) {  # tiny fix
                        nav_mins = nav_mins - 1;
                        nav_secs = 60 + nav_secs;
                    }
                    LADCanvas.hsd_bullseye_eta.setText(sprintf("%02d:%02d", nav_mins, nav_secs));
                } else {
                    LADCanvas.hsd_bullseye_eta.setText("XX:XX");
                }
            }


            # Steerpoints / Flight plan updates

            if (getprop("autopilot/route-manager/current-wp") == -1) {
                LADCanvas.hsd_stpt_current.setText("No.00");
            } else {
                LADCanvas.hsd_stpt_current.setText(sprintf("No.%02d", getprop("autopilot/route-manager/current-wp")));
            }

            if (getprop("sim/model/instrumentation/vhf/mode") == 0) {  # if we're in normal nav mode (not TACAN or ILS)

                # Remove all former steerpoint-connecting lines
                LADCanvas.HSDScreenLines.removeAllChildren();

                # Update the wp dist/ETA texts
                if (getprop("autopilot/route-manager/active")) {  # if route-manager's active
                    LADCanvas.hsd_stpt_eta.setText("XX:XX");
                    if (getprop("autopilot/route-manager/wp/dist") != nil) {
                        LADCanvas.hsd_stpt_dist.setText(sprintf("N %4.1f", getprop("autopilot/route-manager/wp/dist")));
                    } else {
                        LADCanvas.hsd_stpt_dist.setText("N 9999");
                    }

                    if (getprop("autopilot/route-manager/wp/eta-seconds") != nil) {
                        nav_mins = sprintf("%.0f", getprop("autopilot/route-manager/wp/eta-seconds") / 60);
                        nav_secs = (getprop("autopilot/route-manager/wp/eta-seconds") / 60 - nav_mins) * 60;  # remove whole minutes for seconds
                        if (nav_secs < 0) {  # tiny fix
                            nav_mins = nav_mins - 1;
                            nav_secs = 60 + nav_secs;
                        }
                        LADCanvas.hsd_stpt_eta.setText(sprintf("%02d:%02d", nav_mins, nav_secs));
                    } else {
                        LADCanvas.hsd_stpt_eta.setText("XX:XX");
                    }

                    if (getprop("autopilot/route-manager/wp/true-bearing-deg") != nil) {
                        LADCanvas.hsd_stpt_bearing.setText(sprintf("B %03d", getprop("autopilot/route-manager/wp/true-bearing-deg")));
                    } else {
                        LADCanvas.hsd_stpt_bearing.setText("B 999");
                    }
                } else {
                    LADCanvas.hsd_stpt_eta.setText("XX:XX");
                    LADCanvas.hsd_stpt_dist.setText("N 9999");
                    LADCanvas.hsd_stpt_bearing.setText("B 999");
                }

                var plan = flightplan();
                var planSize = plan.getPlanSize();
                for (stpt_idx = 0; stpt_idx < planSize; stpt_idx+=1) {
                    if (stpt_idx < LADCanvas.stpt_symbols_max) {

                        draw_line = 0;
                        if (stpt_idx != 0) {  # If we got a former steerpoint (only stpt 0 don't got none)
                            var former_x_move = x_move;
                            var former_y_move = y_move;
                            var former_wpC = wpC;
                            draw_line = 1;
                        }

                        var wp = plan.getWP(stpt_idx);
                        var wpC = geo.Coord.new();
                        wpC.set_latlon(wp.lat,wp.lon,0);  # we don't care about the altitude here, we're in a HSD, not a VSD

                        steerDir = [geo.aircraft_position().course_to(wpC), geo.aircraft_position().distance_to(wpC)*M2NM];  # id 0 is bearing, id 1 is range
                        wpbear = geo.normdeg180(steerDir[0] - getprop("orientation/heading-deg"));  # relative bearing to the steerpoint (20 means 20* right)
                        wprng = -steerDir[1];  # direct distance from the steerpoint
                        if (steerDir[1] != nil) {  # that's a safety, why not after all?
                            LADCanvas.stpt_symbols_hsd[stpt_idx].setVisible(1);
                            LADCanvas.stpt_texts_hsd[stpt_idx].setVisible(1);
                            LADCanvas.stpt_texts_hsd[stpt_idx].setText(sprintf("%d", stpt_idx));

                            var x_move = -(wprng*LADCanvas.hsd_nm_to_px_x)*math.sin(wpbear*D2R);
                            var y_move = (wprng*LADCanvas.hsd_nm_to_px_y)*math.cos(wpbear*D2R);

                            # If the point is outside of the circle, we don't let it get away of it and we place it at the very edge of the HSD circle
                            # The circle is actually an ellipse, in a way that it appears as a circle on the LAD
                            move_dir = ellipse_clamp(x_move, y_move);
                            clamped = x_move =! move_dir[0] or y_move != move_dir[1];;
                            x_move = move_dir[0];
                            y_move = move_dir[1];

                            if (clamped) {  # Don't display the steerpoint if it's outta the screen, though we still display the connecting lines
                                LADCanvas.stpt_symbols_hsd[stpt_idx].setVisible(0);
                                LADCanvas.stpt_texts_hsd[stpt_idx].setVisible(0);
                            }

                            LADCanvas.stpt_symbols_hsd[stpt_idx].setTranslation(x_move, y_move);
                            LADCanvas.stpt_texts_hsd[stpt_idx].setTranslation(677*2+x_move, 2262+500+145+y_move);
                            if (stpt_idx == getprop("autopilot/route-manager/current-wp")) {  # if this is the current steerpoint, make it bigger/brighter/bolder, plus change color
                                LADCanvas.stpt_symbols_hsd[stpt_idx].setStrokeLineWidth(7);
                                LADCanvas.stpt_symbols_hsd[stpt_idx].setColor(prst_rose.r,prst_rose.g,prst_rose.b);
                                LADCanvas.stpt_texts_hsd[stpt_idx].setColor(prst_rose_dark.r,prst_rose_dark.g,prst_rose_dark.b);
                                if (draw_line == 1) {  # if we got a former steerpoint, we connect 'em
                                    LADCanvas.HSDScreenLines.createChild("path")
                                        .moveTo(677*2+x_move,2262+500+y_move)
                                        .lineTo(677*2+former_x_move,2262+500+former_y_move)
                                        .setStrokeLineWidth(8)
                                        .setColor(prst_rose_dark.r,prst_rose_dark.g,prst_rose_dark.b)
                                        .update();

                                    # Computing for the text giving range between those two steerpoints
                                    text_dir = path_text_perpendicular_vector_computing([677*2+x_move, 2262+500+y_move], [677*2+former_x_move, 2262+500+former_y_move], offset=30);
                                    LADCanvas.HSDScreenLines.createChild("text")
                                        .setFontSize(60, 1.4)
                                        .setText(sprintf("N %02.1f", former_wpC.distance_to(wpC)*M2NM))
                                        .setAlignment("center-center")
                                        .setColor(prst_rose_dark.r,prst_rose_dark.g,prst_rose_dark.b)
                                        .setTranslation(text_dir[0],text_dir[1])
                                        #.setCenter(text_dir[0],text_dir[1])
                                        .setRotation(text_dir[2])
                                        .set("z-index",0)
                                        .setFont(aircraft.HUDFont)
                                        .update();
                                }
                            } else {
                                LADCanvas.stpt_symbols_hsd[stpt_idx].setStrokeLineWidth(4);
                                LADCanvas.stpt_symbols_hsd[stpt_idx].setColor(prst_purple.r,prst_purple.g,prst_purple.b);
                                LADCanvas.stpt_texts_hsd[stpt_idx].setColor(prst_purple_dark.r,prst_purple_dark.g,prst_purple_dark.b);
                                if (draw_line == 1) {  # if we got a former steerpoint, we connect 'em
                                    LADCanvas.HSDScreenLines.createChild("path")
                                        .moveTo(677*2+x_move,2262+500+y_move)
                                        .lineTo(677*2+former_x_move,2262+500+former_y_move)
                                        .setStrokeLineWidth(6)
                                        .setColor(prst_purple_dark.r,prst_purple_dark.g,prst_purple_dark.b)
                                        .update();

                                    # Computing for the text giving range between those two steerpoints
                                    text_dir = path_text_perpendicular_vector_computing([677*2+x_move, 2262+500+y_move], [677*2+former_x_move, 2262+500+former_y_move], offset=30);
                                    LADCanvas.HSDScreenLines.createChild("text")
                                        .setFontSize(55, 1.4)
                                        .setText(sprintf("N %02.1f", former_wpC.distance_to(wpC)*M2NM))  # distance from former steerpoint to current steerpoint.
                                        .setAlignment("center-center")
                                        .setColor(prst_purple_dark.r,prst_purple_dark.g,prst_purple_dark.b)
                                        .setTranslation(text_dir[0],text_dir[1])
                                        #.setCenter(text_dir[0],text_dir[1])
                                        .setRotation(text_dir[2])
                                        .set("z-index",0)
                                        .setFont(aircraft.HUDFont)
                                        .update();
                                }
                            }
                        }
                    }
                }
            } else {
                LADCanvas.hsd_stpt_eta.setText("XX:XX");
                LADCanvas.hsd_stpt_dist.setText("N 9999");
                LADCanvas.hsd_stpt_bearing.setText("B 999");
            }

            # Do not display any unused steerpoint boxes
            for (var nv = stpt_idx; nv < LADCanvas.stpt_symbols_max;nv += 1) {
                LADCanvas.stpt_symbols_hsd[nv].setVisible(0);
                LADCanvas.stpt_texts_hsd[nv].setVisible(0);
            }

            # Update the radar target symbols
            var target_idx = 0;
            var found_lock = 0;
            var lock_assigned = 0;
            foreach (contact ; awg_9.tgts_list) {
                if (contact.get_display() == 1 and !getprop("instrumentation/radar/radar-standby")) {
                    if (awg_9.active_u == contact) { # If it's the active radar lock we got
                        found_lock = 1;
                    }
                    if (target_idx < LADCanvas.tgt_symbols_max) {

                        contact_data = datalink.get_data(contact.get_Callsign());
                        if (contact_data == nil or !contact_data.is_known()) {
                            unknown = 1;
                        } else {
                            unknown = 0;
                        }

                        if (unknown == 0) {
                            friendly = contact_data.is_friendly() or contact.getIffResponse();
                            hostile = contact_data.is_hostile();
                            on_link = contact_data.on_link();
                        } else {
                            friendly = contact.getIffResponse();
                            hostile = 0;
                            on_link = 0;
                        }

                        if (on_link) {
                            LADCanvas.tgt_symbols_hsd[target_idx].setColor(prst_blue.r,prst_blue.g,prst_blue.b);
                            LADCanvas.tgt_symbols_hsd_ships[target_idx].setColor(prst_blue.r,prst_blue.g,prst_blue.b);
                            LADCanvas.tgt_texts_hsd[target_idx].setColor(prst_blue_dark.r,prst_blue_dark.g,prst_blue_dark.b);
                        } elsif (friendly) {
                            LADCanvas.tgt_symbols_hsd[target_idx].setColor(prst_green.r,prst_green.g,prst_green.b);
                            LADCanvas.tgt_symbols_hsd_ships[target_idx].setColor(prst_green.r,prst_green.g,prst_green.b);
                            LADCanvas.tgt_texts_hsd[target_idx].setColor(prst_green_dark.r,prst_green_dark.g,prst_green_dark.b);
                        } elsif (hostile) {
                            LADCanvas.tgt_symbols_hsd[target_idx].setColor(prst_red.r,prst_red.g,prst_red.b);
                            LADCanvas.tgt_symbols_hsd_ships[target_idx].setColor(prst_red.r,prst_red.g,prst_red.b);
                            LADCanvas.tgt_texts_hsd[target_idx].setColor(prst_red_dark.r,prst_red_dark.g,prst_red_dark.b);
                        } else {
                            LADCanvas.tgt_symbols_hsd[target_idx].setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b);
                            LADCanvas.tgt_symbols_hsd_ships[target_idx].setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b);
                            LADCanvas.tgt_texts_hsd[target_idx].setColor(prst_yellow_dark.r,prst_yellow_dark.g,prst_yellow_dark.b);
                        }

                        LADCanvas.tgt_symbols_hsd[target_idx].setVisible(1);
                        LADCanvas.tgt_texts_hsd[target_idx].setVisible(1);
                        tgt_bear = contact.get_deviation(getprop("orientation/heading-deg")) or 0;  # relative bearing to the contact
                        tgt_rng = contact.get_range();  # direct distance to target

                        var x_move = (tgt_rng*LADCanvas.hsd_nm_to_px_x)*math.sin(tgt_bear*D2R);
                        var y_move = -(tgt_rng*LADCanvas.hsd_nm_to_px_y)*math.cos(tgt_bear*D2R);
                        var rotation = geo.normdeg(contact.get_heading()-getprop("orientation/heading-deg")+180)*D2R;

                        LADCanvas.tgt_symbols_hsd[target_idx].setTranslation(x_move,y_move); # the factors is to let display correspond to 120 degrees wide and height.
                        LADCanvas.tgt_symbols_hsd_ships[target_idx].setTranslation(x_move,y_move); # the factors is to let display correspond to 120 degrees wide and height.
                        LADCanvas.tgt_texts_hsd[target_idx].setTranslation(677*2+x_move, 2262+500+145+y_move); # the factors is to let display correspond to 120 degrees wide and height.
                        if (found_lock == 1 and lock_assigned == 0) {
                            LADCanvas.locked_box_hsd.setTranslation(x_move, y_move); # the factors is to let display correspond to 120 degrees wide and height.
                            lock_assigned = 1;  # so others don't take the lock symbology from it
                        }
                        if (contact.get_model() != nil and typeLookup[contact.get_model()] != nil) {
                            contact_type = typeLookup[contact.get_model()];
                            contact_alt = contact.get_altitude() * 0.001;  # So it's in thousands of feet
                            LADCanvas.tgt_texts_hsd[target_idx].setText(sprintf("%s %02d", contact_type, contact_alt));
                            if (contact_type == "SHIP" or contact_type == "BOAT") {
                                LADCanvas.tgt_symbols_hsd_ships[target_idx].setVisible(1);
                                LADCanvas.tgt_symbols_hsd[target_idx].setVisible(0);
                            } else {
                                LADCanvas.tgt_symbols_hsd_ships[target_idx].setVisible(0);
                            }
                        } else {  # Model's unknown to our radar
                            contact_alt = contact.get_altitude() * 0.001;  # So it's in thousands of feet
                            LADCanvas.tgt_texts_hsd[target_idx].setText(sprintf("UNK %02d", contact_alt));
                            LADCanvas.tgt_symbols_hsd_ships[target_idx].setVisible(0);
                        }
                        target_idx += 1;
                    }
                }
            }

            if (found_lock == 1) {
                LADCanvas.locked_box_hsd.setVisible(1);
                #LADCanvas.vsd_tgt_true_speed.setVisible(1);
                #LADCanvas.vsd_tgt_bearing.setVisible(1);
                #LADCanvas.vsd_tgt_heading.setVisible(1);
                #LADCanvas.vsd_tgt_aspect.setVisible(1);
                #LADCanvas.vsd_tgt_altitude.setVisible(1);
                #LADCanvas.vsd_tgt_range.setVisible(1);
                #LADCanvas.vsd_tgt_fps.setVisible(1);

                if (awg_9.active_u != nil) { # safety
                    # Update current target's info texts across the HSD

                    # Scale:
                    # To be at 600 (moving 4,600px up), target's range must be at radar max range
                    range_y = awg_9.active_u.get_range() * getprop("instrumentation/radar/radar2-range") / 4600;
                    if (range_y > 4560) {  # clamp the values
                        range_y = 4560; # max down px value
                    } elsif (range_y < -4560) {
                        range_y = -4560; # max up px value
                    }
                }
            } else {
                LADCanvas.locked_box_hsd.setVisible(0);
                #LADCanvas.vsd_tgt_true_speed.setVisible(0);
                #LADCanvas.vsd_tgt_bearing.setVisible(0);
                #LADCanvas.vsd_tgt_heading.setVisible(0);
                #LADCanvas.vsd_tgt_aspect.setVisible(0);
                #LADCanvas.vsd_tgt_altitude.setVisible(0);
                #LADCanvas.vsd_tgt_range.setVisible(0);
                #LADCanvas.vsd_tgt_fps.setVisible(0);
            }

            # Do not display any unused target boxes
            for (var nv = target_idx; nv < LADCanvas.tgt_symbols_max;nv += 1) {
                LADCanvas.tgt_symbols_hsd[nv].setVisible(0);
                LADCanvas.tgt_texts_hsd[nv].setVisible(0);
                LADCanvas.tgt_symbols_hsd_ships[nv].setVisible(0);
            }

            # Update the datalink symbols
            var dlnk_idx = 0;
            var datalink_connections = datalink.get_all_callsigns();
            foreach (contact ; datalink_connections) {
                already_on_rdr = 0;  # if its' on our radar, we don't display it.
                foreach(rdrcontact ; valid_radar_targets) {
                    if (rdrcontact == contact) {
                        already_on_rdr = 1;
                    }
                }
                if (already_on_rdr == 0) {
                    if (dlnk_idx < LADCanvas.dlnk_symbols_max) {

                        contact_data = datalink.get_data(contact);
                        contact_idx = contact_data.index();
                        if (contact_idx != nil) {  # can make things bug sometimes
                            contact_model = getprop("/ai/models/multiplayer["~contact_idx~"]/model-short");
                            contact_lat = getprop("/ai/models/multiplayer["~contact_idx~"]/position/latitude-deg");
                            contact_lon = getprop("/ai/models/multiplayer["~contact_idx~"]/position/longitude-deg");
                            contact_alt = getprop("/ai/models/multiplayer["~contact_idx~"]/position/altitude-ft");
                            contact_coord = geo.Coord.new().set_latlon(contact_lat,contact_lon,contact_alt*FT2M);
                            contact_bearing = geo.aircraft_position().course_to(contact_coord);
                            contact_bearing_rel = deviation_normdeg(getprop("orientation/heading-deg"), contact_bearing);
                            contact_elevation = vector.Math.getPitch(geo.aircraft_position(), contact_coord);
                            contact_heading = getprop("/ai/models/multiplayer["~contact_idx~"]/orientation/true-heading-deg");
                            contact_coord = geo.Coord.new().set_latlon(contact_lat,contact_lon,contact_alt*FT2M);
                            contact_range = contact_coord.direct_distance_to(geo.aircraft_position()) * M2NM;
                            if (contact_data == nil or !contact_data.is_known()) {
                                unknown = 1;
                            } else {
                                unknown = 0;
                            }

                            if (unknown == 0) {
                                friendly = contact_data.is_friendly();
                                hostile = contact_data.is_hostile();
                                on_link = contact_data.on_link();
                            } else {
                                friendly = 0;
                                hostile = 0;
                                on_link = 0;
                            }

                            if (on_link) {
                                LADCanvas.dlnk_symbols_hsd[dlnk_idx].setColor(prst_blue.r,prst_blue.g,prst_blue.b);
                                LADCanvas.dlnk_texts_hsd[dlnk_idx].setColor(prst_blue_dark.r,prst_blue_dark.g,prst_blue_dark.b);
                            } elsif (friendly) {
                                LADCanvas.dlnk_symbols_hsd[dlnk_idx].setColor(prst_green.r,prst_green.g,prst_green.b);
                                LADCanvas.dlnk_texts_hsd[dlnk_idx].setColor(prst_green_dark.r,prst_green_dark.g,prst_green_dark.b);
                            } elsif (hostile) {
                                LADCanvas.dlnk_symbols_hsd[dlnk_idx].setColor(prst_red.r,prst_red.g,prst_red.b);
                                LADCanvas.dlnk_texts_hsd[dlnk_idx].setColor(prst_red_dark.r,prst_red_dark.g,prst_red_dark.b);
                            } else {
                                LADCanvas.dlnk_symbols_hsd[dlnk_idx].setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b);
                                LADCanvas.dlnk_texts_hsd[dlnk_idx].setColor(prst_yellow_dark.r,prst_yellow_dark.g,prst_yellow_dark.b);
                            }

                            LADCanvas.dlnk_symbols_hsd[dlnk_idx].setVisible(1);
                            LADCanvas.dlnk_texts_hsd[dlnk_idx].setVisible(1);

                            var x_move = (contact_range*LADCanvas.hsd_nm_to_px_x)*math.sin(contact_bearing_rel*D2R);
                            var y_move = -(contact_range*LADCanvas.hsd_nm_to_px_y)*math.cos(contact_bearing_rel*D2R);

                            # If the point is outside of the circle, we don't let it get away of it and we place it at the very edge of the HSD circle
                            # The circle is actually an ellipse, in a way that it appears as a circle on the LAD
                            move_dir = ellipse_clamp(x_move, y_move);
                            x_move = move_dir[0];
                            y_move = move_dir[1];

                            LADCanvas.dlnk_symbols_hsd[dlnk_idx].setTranslation(x_move, y_move); # the factors is to let display correspond to 120 degrees wide and height.
                            LADCanvas.dlnk_texts_hsd[dlnk_idx].setTranslation(677*2+x_move, 2262+500+145+y_move); # the factors is to let display correspond to 120 degrees wide and height.
                            contact_alt = contact_alt * 0.001;  # So it's in thousands of feet
                            LADCanvas.dlnk_texts_hsd[dlnk_idx].setText(sprintf("%s %02d", contact, contact_alt));
                            dlnk_idx += 1;
                        }
                    }
                }
            }

            # Do not display any unused target boxes
            for (var nv = dlnk_idx; nv < LADCanvas.dlnk_symbols_max;nv += 1) {
                LADCanvas.dlnk_symbols_hsd[nv].setVisible(0);
                LADCanvas.dlnk_texts_hsd[nv].setVisible(0);
            }

            # Process the EPAWSS contacts
            var epawss_idx = 0;
            foreach (contact ; epawss.contacts_list) {
                if (contact.get_visible() and contact.get_range() < getprop("instrumentation/radar/radar2-range") * 1.25) {  # If it's all good
                    already_on_rdr = 0;  # if its' on our radar, we don't display it.
                    foreach(rdrcontact ; valid_radar_targets) {
                        if (rdrcontact == contact.get_Callsign()) {
                            already_on_rdr = 1;
                        }
                    }
                    if (epawss_idx < LADCanvas.tgt_symbols_max and already_on_rdr == 0) {

                        contact_data = datalink.get_data(contact.get_Callsign());
                        if (contact_data == nil) {
                            unknown = 1;
                        } else {
                            unknown = 0;
                        }

                        if (unknown == 1) {  # We don't display it if we already got it on datalink, we don't need an EPAWSS contact

                            # Basic position and changing text
                            LADCanvas.epawss_texts_hsd[epawss_idx].setVisible(1);

                            tgt_bear = contact.get_deviation(getprop("orientation/heading-deg")) or 0;  # relative bearing to the contact
                            tgt_rng = contact.get_range();  # direct distance to target

                            var x_move = (tgt_rng*LADCanvas.hsd_nm_to_px_x)*math.sin(tgt_bear*D2R);
                            var y_move = -(tgt_rng*LADCanvas.hsd_nm_to_px_y)*math.cos(tgt_bear*D2R);

                            LADCanvas.epawss_texts_hsd[epawss_idx].setTranslation(677*2+x_move, 2262+500+y_move);

                            # Display contact's indentified type (F, F/B, B, AEW&C, TNKR etc.)
                            if (contact.get_model() != nil and typeLookup[contact.get_model()] != nil) {
                                contact_type = typeLookup[contact.get_model()];
                                LADCanvas.epawss_texts_hsd[epawss_idx].setText(contact_type);
                            } elsif (contact.get_type() == awg_9.ORDNANCE) {  # if it's a missile (generally, just ordnance
                                LADCanvas.epawss_texts_hsd[epawss_idx].setText("M");
                            } else {  # Model's unknown to our radar
                                LADCanvas.epawss_texts_hsd[epawss_idx].setText("UNK");
                            }

                            # Display the hat if it's an airborne radar
                            if (contact.get_type() == awg_9.AIR) {
                                LADCanvas.epawss_symbols_hsd_hat[epawss_idx].setTranslation(x_move, y_move);
                                LADCanvas.epawss_symbols_hsd_hat[epawss_idx].setVisible(1);
                            } else {
                                LADCanvas.epawss_symbols_hsd_hat[epawss_idx].setVisible(0);
                            }

                            # Display the new threat upper circle if it's one
                            found = 0;
                            foreach(new_threat; epawss.new_threats) {
                                if (contact.get_Callsign() == new_threat) {
                                    found = 1;
                                }
                            }
                            if (found == 1) {
                                LADCanvas.epawss_symbols_hsd_new_contact[epawss_idx].setVisible(1);
                                LADCanvas.epawss_symbols_hsd_new_contact[epawss_idx].setTranslation(x_move, y_move);
                            } else {
                                LADCanvas.epawss_symbols_hsd_new_contact[epawss_idx].setVisible(0);
                            }

                            # Display the primary threat double triangle if that's the one
                            if (contact.get_Callsign()~contact.getUnique() == epawss.primary_threat_callsign) {
                                LADCanvas.epawss_symbols_hsd_primary_threat[epawss_idx].setVisible(1);
                                LADCanvas.epawss_symbols_hsd_primary_threat[epawss_idx].setTranslation(x_move, y_move);
                            } else {
                                LADCanvas.epawss_symbols_hsd_primary_threat[epawss_idx].setVisible(0);
                            }

                            # Display the blinking circle if it's a missile launcher, or if it's an approaching missile
                            if ((epawss.is_missile_launcher(contact) or contact.get_type() == awg_9.ORDNANCE) and 5*(elapsed-int(elapsed))>2.5) {  # 4Hz blink
                                LADCanvas.epawss_symbols_hsd_missile_launch[epawss_idx].setVisible(1);
                                LADCanvas.epawss_symbols_hsd_missile_launch[epawss_idx].setTranslation(x_move, y_move);
                            } else {
                                LADCanvas.epawss_symbols_hsd_missile_launch[epawss_idx].setVisible(0);
                            }

                            epawss_idx += 1;
                        }
                    }
                }
            }

            # Do not display any unused EPAWSS symbology
            for (var nv = epawss_idx; nv < LADCanvas.stpt_symbols_max;nv += 1) {
                LADCanvas.epawss_symbols_hsd_hat[nv].setVisible(0);
                LADCanvas.epawss_texts_hsd[nv].setVisible(0);
                LADCanvas.epawss_symbols_hsd_missile_launch[nv].setVisible(0);
                LADCanvas.epawss_symbols_hsd_primary_threat[nv].setVisible(0);
                LADCanvas.epawss_symbols_hsd_new_contact[nv].setVisible(0);
            }

            # If there's a Missile Approach Warning, display it (MAW)
            var maw_epawss_idx = 21;  # id of the object specifically made for the Missile Approach Warning
            if (getprop("payload/armament/MAW-active") or getprop("payload/armament/MAW-semiactive")) {  # Note: EWWS must be on
                maw_bearing = getprop("payload/armament/MAW-bearing");
                deviation = -geo.normdeg180(maw_bearing - getprop("orientation/heading-deg")) + 90;
                x_move = math.cos(deviation * D2R)*(LADCanvas.hsd_great_circle_radius*10/19)*(1/3);
                y_move = -math.sin(deviation * D2R)*(LADCanvas.hsd_great_circle_radius)*(1/3);

                #LADCanvas.epawss_texts_hsd[maw_epawss_idx].setRotation(-(deviation+90)*D2R);
                #LADCanvas.epawss_symbols_hsd_missile_launch[maw_epawss_idx].setRotation(-(deviation+90)*D2R);
                #LADCanvas.epawss_symbols_hsd_primary_threat[maw_epawss_idx].setRotation(-(deviation+90)*D2R);

                LADCanvas.epawss_texts_hsd[maw_epawss_idx].setText("M");

                LADCanvas.epawss_texts_hsd[maw_epawss_idx].setTranslation(677*2+x_move, 2262+500+y_move);
                LADCanvas.epawss_symbols_hsd_missile_launch[maw_epawss_idx].setTranslation(x_move, y_move);
                LADCanvas.epawss_symbols_hsd_primary_threat[maw_epawss_idx].setTranslation(x_move, y_move);

                LADCanvas.epawss_texts_hsd[maw_epawss_idx].setVisible(1);
                LADCanvas.epawss_symbols_hsd_missile_launch[maw_epawss_idx].setVisible(1);
                LADCanvas.epawss_symbols_hsd_primary_threat[maw_epawss_idx].setVisible(1);
            } else {
                LADCanvas.epawss_texts_hsd[maw_epawss_idx].setVisible(0);
                LADCanvas.epawss_symbols_hsd_missile_launch[maw_epawss_idx].setVisible(0);
                LADCanvas.epawss_symbols_hsd_primary_threat[maw_epawss_idx].setVisible(0);
            }

            # Update the radar cone
            if (!getprop("instrumentation/radar/radar-standby")) {  # if radar's standby, we don't display the cone
                if (awg_9.wcs_current_mode == awg_9.wcs_mode_tws_auto or awg_9.wcs_current_mode == awg_9.wcs_mode_tws_man) {  # If radar's in TWS AUTO/MAN
                    LADCanvas.hsd_cone_60.setVisible(0);
                    LADCanvas.hsd_cone_30.setVisible(1);
                } else {
                    LADCanvas.hsd_cone_60.setVisible(1);
                    LADCanvas.hsd_cone_30.setVisible(0);
                }
            } else {
                LADCanvas.hsd_cone_60.setVisible(0);
                LADCanvas.hsd_cone_30.setVisible(0);
            }

            # Update circles' horizontal range scales
            LADCanvas.hsd_distance_indicator_1_3.setTranslation(1355+85,1150*2+500+75-(getprop("instrumentation/radar/radar2-range")*1.25*LADCanvas.hsd_nm_to_px_y)/3+125);
            LADCanvas.hsd_distance_indicator_2_3.setTranslation(1355+85,1150*2+500+75-(getprop("instrumentation/radar/radar2-range")*1.25*LADCanvas.hsd_nm_to_px_y)/3*2+125);
            LADCanvas.hsd_distance_indicator_1_3.setText(sprintf("N%3.1f", (getprop("instrumentation/radar/radar2-range")*1.25)/3));
            LADCanvas.hsd_distance_indicator_2_3.setText(sprintf("N%3.1f", (getprop("instrumentation/radar/radar2-range")*1.25)/3*2));

            # Update the TACAN's station position
            #LADCanvas.hsd_tacan_symbol.setVisible(1);
            #LADCanvas.hsd_tacan_symbol.setTranslation(1355+85,1150*2+500+7);

            # Draw the HSD circled areas
            LADCanvas.HSDScreenCircles.removeAllChildren();
            foreach(threat_circle; aircraft.threat_circles) {
                if (threat_circle.enabled) {
                    circle_radius = threat_circle.radius;
                    circle_coord = geo.Coord.new().set_latlon(threat_circle.lat,threat_circle.lon);
                    circle_bearing = geo.normdeg180(geo.aircraft_position().course_to(circle_coord) - getprop("orientation/heading-deg"));  # relative bearing
                    circle_range = geo.aircraft_position().distance_to(circle_coord)*M2NM;
                    var x_move = -(circle_range*LADCanvas.hsd_nm_to_px_x)*math.sin(circle_bearing*D2R);
                    var y_move = (circle_range*LADCanvas.hsd_nm_to_px_y)*math.cos(circle_bearing*D2R);
                    if (threat_circle.color == "red") {
                        circle_color = prst_red;
                    } elsif (threat_circle.color == "yellow") {
                        circle_color = prst_yellow;
                    } elsif (threat_circle.color == "blue") {
                        circle_color = prst_blue;
                    } elsif (threat_circle.color == "rose") {
                        circle_color = prst_rose;
                    } elsif (threat_circle.color == "purple") {
                        circle_color = prst_purple;
                    } elsif (threat_circle.color == "orange") {
                        circle_color = prst_orange;
                    } elsif (threat_circle.color == "green") {
                        circle_color = prst_green;
                    } elsif (threat_circle.color == "cyan") {
                        circle_color = prst_cyan;
                    } elsif (threat_circle.color == "marron") {
                        circle_color = prst_marron;
                    }

                    if (circle_range+circle_radius*1.5 < getprop("instrumentation/radar/radar2-range") * 1.25) {  # If it perfectly fits into the HSD great circle

                        LADCanvas.HSDScreenCircles.createChild("path")
                            .moveTo(1355-circle_radius*LADCanvas.hsd_nm_to_px_x,1150*2+500)
                            .arcSmallCW(circle_radius*LADCanvas.hsd_nm_to_px_x,circle_radius*LADCanvas.hsd_nm_to_px_y, 0, circle_radius*LADCanvas.hsd_nm_to_px_y*2, 0)
                            .arcSmallCW(circle_radius*LADCanvas.hsd_nm_to_px_x,circle_radius*LADCanvas.hsd_nm_to_px_y, 0, -circle_radius*LADCanvas.hsd_nm_to_px_y*2, 0)
                            .moveTo(1355-circle_radius*LADCanvas.hsd_nm_to_px_x,1150*2+500+75)
                            .setCenter(1355-circle_radius*LADCanvas.hsd_nm_to_px_x,1150*2+500)
                            .set("z-index",0)
                            .setVisible(1)
                            .setStrokeLineWidth(10)
                            .setColor(circle_color.r,circle_color.g,circle_color.b)
                            .setTranslation(-x_move-circle_radius*LADCanvas.hsd_nm_to_px_x/2,-y_move)
                            .update();
                        LADCanvas.HSDScreenLines.createChild("text")
                            .setFontSize((circle_radius*LADCanvas.hsd_nm_to_px_x)/1.5, 1.4)
                            .setText(threat_circle.label)
                            .setAlignment("center-center")
                            .setColor(circle_color.r,circle_color.g,circle_color.b)
                            .setTranslation(1355-x_move, 1150*2+500-y_move)
                            .set("z-index",0)
                            .setFont(aircraft.HUDFont)
                            .setVisible(1)
                            .update();
                    } else {
                        inside_points = get_points_inside_for_ellipse(circle_radius*LADCanvas.hsd_nm_to_px_x, circle_radius*LADCanvas.hsd_nm_to_px_y, 1355-circle_radius*LADCanvas.hsd_nm_to_px_x-x_move-circle_radius*LADCanvas.hsd_nm_to_px_x/2, 1150*2+500-y_move, 1355-LADCanvas.hsd_great_circle_radius, 1150*2+500, LADCanvas.hsd_great_circle_radius*10/19, LADCanvas.hsd_great_circle_radius, step=2.5);

                        #LADCanvas.HSDScreenLines.createChild("text")  # TODO: Find a way to do the same with the ellipse but with the text
                            #.setFontSize((circle_radius*LADCanvas.hsd_nm_to_px_x)/1.5, 1.4)
                            #.setText(threat_circle.label)
                            #.setAlignment("center-center")
                            #.setColor(circle_color.r,circle_color.g,circle_color.b)
                            #.setTranslation(1355-x_move/1.5, 1150*2+500-y_move-100)
                            #.set("z-index",0)
                            #.setFont(aircraft.HUDFont)
                            #.setVisible(1)
                            #.update();

                        #var curve = LADCanvas.HSDScreenCircles.createChild("path")
                        #        .set("z-index",0)
                        #        .setStrokeLineWidth(10)
                        #        .setColor(circle_color.r,circle_color.g,circle_color.b);
                        #if (size(inside_points) > 0) {
                        #    var first = inside_points[0];
                        #    curve.moveTo(first[0], first[1]);

                        #    for (var i = 1; i < size(inside_points); i += 1) {
                        #        var p = inside_points[i];
                        #        curve.lineTo(p[0], p[1]);  # could also use curveTo(), but that'd take more resources, unless step was reduced, but that'd reduce accuracy
                        #    }
                        #    curve.setVisible(1);
                        #} else {
                        #    curve.setVisible(0);
                        #}
                        #curve.update();
                    }
                }
            }

            # Draw the bullseye's aim
            var bullseye_radius = 1.5;  # It's always 1.5 NM and it can't be changed
            # The three following values are now defined on top when updating the bullseye info texts
            #var bullseye_coord = geo.Coord.new().set_latlon(getprop("sim/model/f15/fcs/bullseye-lat"),getprop("sim/model/f15/fcs/bullseye-lon"),getprop("sim/model/f15/fcs/bullseye-alt")*FT2M);
            #var bullseye_bearing = geo.normdeg180(geo.aircraft_position().course_to(bullseye_coord) - getprop("orientation/heading-deg"));
            #var bullseye_range = geo.aircraft_position().distance_to(bullseye_coord)*M2NM;
            if (bullseye_range > getprop("instrumentation/radar/radar2-range") * 1.25) {
                LADCanvas.hsd_bullseye_aim.setVisible(0);
            } else {
                LADCanvas.hsd_bullseye_aim.setVisible(1);
                var x_move = -(bullseye_range*LADCanvas.hsd_nm_to_px_x)*math.sin(bullseye_bearing*D2R);
                var y_move = (bullseye_range*LADCanvas.hsd_nm_to_px_y)*math.cos(bullseye_bearing*D2R);
                LADCanvas.hsd_bullseye_aim.setTranslation(-x_move,-y_move);
            }

        } else {
            LADCanvas.HSDScreen.setVisible(0);
            LADCanvas.HSDScreenLines.setVisible(0);
            LADCanvas.HSDScreenCircles.setVisible(0);
        }


        # PACS Updates
        if (PACS_ON == 1) {
            LADCanvas.PACSScreen.setVisible(1);

            # Shared updates:
            pacs_mode_str = "";

            if (getprop("sim/model/f15/controls/armament/weapon-selector") == 5) {  # Automatically switch to A/G when weapon selected is A/G
                LADCanvas.PACSmode = 1;
            } else {  # otherwise, switch back to A/A
                LADCanvas.PACSmode = 0;
            }

            if (LADCanvas.PACSmode == 0) {
                pacs_mode_str = "A/A";
            } elsif (LADCanvas.PACSmode == 1) {
                pacs_mode_str = "A/G";
            } elsif (LADCanvas.PACSmode == 2) {
                pacs_mode_str = "JETT";
            }
            LADCanvas.pacs_mode_text.setText(pacs_mode_str);

            LADCanvas.pacs_chaff.setText(sprintf("CHF %03d",getprop("ai/submodels/submodel[13]/count")));
            LADCanvas.pacs_flare.setText(sprintf("FLA %03d",getprop("ai/submodels/submodel[5]/count")));

            LADCanvas.pacs_rounds.setText(sprintf("ROUNDS %03d", getprop("sim/model/f15/systems/gun/rounds")));

            tank_center_text = "OUT";
            tank_right_text = "OUT";
            tank_left_text = "OUT";

            tank_mounted_center = getprop("consumables/fuel/tank[7]/capacity-gal_us") != 0;
            tank_mounted_right = getprop("consumables/fuel/tank[6]/capacity-gal_us") != 0;
            tank_mounted_left = getprop("consumables/fuel/tank[5]/capacity-gal_us") != 0;

            if (tank_mounted_center) {
                tank_center_text = sprintf("%05d lbs", getprop("consumables/fuel/tank[7]/level-lbs"));
            }
            if (tank_mounted_right) {
                tank_right_text = sprintf("%05d lbs", getprop("consumables/fuel/tank[6]/level-lbs"));
            }
            if (tank_mounted_left) {
                tank_left_text = sprintf("%05d lbs", getprop("consumables/fuel/tank[5]/level-lbs"));
            }

            LADCanvas.pacs_fuel_amount_left.setText(sprintf("L %s", tank_left_text));
            LADCanvas.pacs_fuel_amount_center.setText(sprintf("C %s", tank_center_text));
            LADCanvas.pacs_fuel_amount_right.setText(sprintf("R %s", tank_right_text));

            LADCanvas.navpod_mounted_text.setVisible(getprop("/sim/model/f15/stores/nav-mounted"));
            LADCanvas.tpod_mounted_text.setVisible(getprop("sim/model/f15/stores/tgp-mounted"));
            LADCanvas.irst_pod_mounted_text.setVisible(getprop("sim/model/f15/stores/irst-mounted"));
            LADCanvas.ecm_pod_mounted_text.setVisible(getprop("sim/model/f15/stores/ecm-mounted"));

            # A/A mode updates

            if (LADCanvas.PACSmode == 0) {  # A/A

                LADCanvas.pacs_arm_1.setVisible(1);
                LADCanvas.pacs_arm_2.setVisible(1);
                LADCanvas.pacs_arm_3.setVisible(1);
                LADCanvas.pacs_arm_1.setText(sprintf("SRM %02d", getprop("sim/model/f15/systems/armament/aim9/count")));
                LADCanvas.pacs_arm_2.setText(sprintf("AAM %02d", getprop("sim/model/f15/systems/armament/aim120/count")));
                LADCanvas.pacs_arm_3.setText(sprintf("GRND %02d", getprop("sim/model/f15/systems/armament/agm/count")));
                LADCanvas.pacs_arming_time.setVisible(0);

                weapon_selector = getprop("sim/model/f15/controls/armament/weapon-selector");  # 0-guns,1-srm,2-amraam,5-ground
                master_arm = getprop("sim/model/f15/controls/armament/master-arm-switch");
                if (weapon_selector == 1) {
                    if (pylons.fcs.getSelectedWeapon() != nil and (pylons.fcs.getSelectedWeapon() == "AIM-9X" or pylons.fcs.getSelectedWeapon() == "CATM-9X")) {
                        LADCanvas.aim9_cool_box.setVisible(pylons.fcs.getSelectedWeapon().isCooling);
                    } else {
                        LADCanvas.aim9_cool_box.setVisible(0);
                    }
                    LADCanvas.aim9_cool_text.setVisible(1);
                } else {
                    LADCanvas.aim9_cool_box.setVisible(0);
                    LADCanvas.aim9_cool_text.setVisible(0);
                }

                foreach(pylon_idx; LADCanvas.pacs_stations_idx) {
                    loaded_type = getprop("payload/armament/station/id-"~pylon_idx~"-type");

                    if (loaded_type == "AIM-9X") {
                        LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                        LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                        if (getprop("payload/armament/station/id-"~pylon_idx~"-set") != "2 x AIM-9X Block I Sidewinder") {
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("AIM9X");
                        } else {
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("2AIM9X");
                        }
                        if (weapon_selector == 1) {
                            if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                        } else {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("SRM");
                            LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                            LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                        }
                    } elsif (loaded_type == "AIM-120D") {
                        LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                        LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                        if (getprop("payload/armament/station/id-"~pylon_idx~"-set") != "2 x AIM-120D AMRAAM") {
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("A120D");
                        } else {
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("2A120D");
                        }
                        if (weapon_selector == 2) {
                            if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                        } else {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("AAM");
                            LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                            LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                        }
                    } elsif (loaded_type == "CATM-120D") {
                        LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                        LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                        if (getprop("payload/armament/station/id-"~pylon_idx~"-set") != "2 x CATM-120D AMRAAM Dummy") {
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("C120D");
                        } else {
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("2C120D");
                        }
                        if (weapon_selector == 2) {
                            if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                        } else {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("CATM2");
                            LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                            LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                        }
                    } elsif (loaded_type == "CATM-9X") {
                        LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                        LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                        LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("CTM9X");
                        if (weapon_selector == 2) {
                            if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                        } else {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("CATM9");
                            LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                            LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                        }
                    } else {
                        LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(0);
                        LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(0);
                        LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                        LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                    }
                }
            } elsif (LADCanvas.PACSmode == 1) {  # A/G mode updates

                LADCanvas.aim9_cool_box.setVisible(0);
                LADCanvas.aim9_cool_text.setVisible(0);
                LADCanvas.pacs_arm_1.setVisible(1);
                LADCanvas.pacs_arm_2.setVisible(1);
                LADCanvas.pacs_arm_3.setVisible(1);
                LADCanvas.pacs_arm_1.setText(sprintf("SRM %02d", getprop("sim/model/f15/systems/armament/aim9/count")));
                LADCanvas.pacs_arm_2.setText(sprintf("AAM %02d", getprop("sim/model/f15/systems/armament/aim120/count")));

                # Timer for the time till armed
                LADCanvas.pacs_arming_time.setVisible(1);
                weap = pylons.fcs.getSelectedWeapon(); # get selected weapon data
                if (weap != nil) {
                    if (weap.ready_time != 0) { # Only if the weapon has a ready timer
                        curr_time = getprop("sim/time/elapsed-sec");
                        standby_time = weap.ready_standby_time;  # time at which the weapon started readyin process
                        if (curr_time > (standby_time + weap.ready_time)) {  # weapon's ready
                            LADCanvas.pacs_arming_time.setText("ARMED");
                        } else {
                            timer = math.round((standby_time + weap.ready_time) - curr_time);
                            timer_sec = timer;
                            timer_min = math.floor(timer / 60);
                            if (timer_min > 0) {
                                timer_sec = timer_sec - timer_min * 60;
                            }
                            LADCanvas.pacs_arming_time.setText(sprintf("STBY %02d:%02d", timer_min, timer_sec));
                        }
                    } else {
                        LADCanvas.pacs_arming_time.setText("ARMED");
                    }
                } else {
                    LADCanvas.pacs_arming_time.setText("STANDBY");
                }

                weapon_type = getprop("sim/model/f15/systems/armament/selected-arm");
                if (weapon_type != nil and weapon_type != "") {  # additonnaly display the current ground weapon's count along the total ground ordnance count
                    LADCanvas.pacs_arm_3.setText(sprintf("%2d/%2d GRND", pylons.fcs.getAmmoOfType(weapon_type), getprop("sim/model/f15/systems/armament/agm/count")));
                } else {
                    LADCanvas.pacs_arm_3.setText(sprintf("%2d GRND", getprop("sim/model/f15/systems/armament/agm/count")));
                }

                weapon_selector = getprop("sim/model/f15/controls/armament/weapon-selector");  # 0-guns,1-srm,2-amraam,5-ground
                master_arm = getprop("sim/model/f15/controls/armament/master-arm-switch");

                foreach(pylon_idx; LADCanvas.pacs_stations_idx) {
                    loaded_type = getprop("payload/armament/station/id-"~pylon_idx~"-type");

                    if (loaded_type == "AGM-65B") {
                        LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                        LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                        if (getprop("payload/armament/station/id-"~pylon_idx~"-set") == "2 x AGM-65B") {
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("2AG65B");
                        } elsif (getprop("payload/armament/station/id-"~pylon_idx~"-set") == "3 x AGM-65B") {
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("3AG65B");
                        } else {
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("AG65B");
                        }
                        if (weapon_selector == 5) {
                            if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                        } else {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("MAV");
                            LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                            LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                        }
                    } elsif (loaded_type == "AGM-65D") {
                        LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                        LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                        if (getprop("payload/armament/station/id-"~pylon_idx~"-set") == "2 x AGM-65D") {
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("2AG65D");
                        } elsif (getprop("payload/armament/station/id-"~pylon_idx~"-set") == "3 x AGM-65D") {
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("3AG65D");
                        } else {
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("AG65D");
                        }
                        if (weapon_selector == 5) {
                            if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                        } else {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("MAV");
                            LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                            LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                        }
                    } elsif (loaded_type == "AGM-84D") {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("AG84D");
                            if (weapon_selector == 5) {
                                if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                                } else {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                                }
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("HARP");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                    } elsif (loaded_type == "AGM-84E") {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("AG84E");
                            if (weapon_selector == 5) {
                                if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                                } else {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                                }
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("SLAM");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                    } elsif (loaded_type == "AGM-88E") {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("AG88E");
                            if (weapon_selector == 5) {
                                if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                                } else {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                                }
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("HARM");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                    } elsif (loaded_type == "AGM-119A") {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("AG119A");
                            if (weapon_selector == 5) {
                                if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                                } else {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                                }
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("PENG");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                    } elsif (loaded_type == "AGM-154A") {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("AG154A");
                            if (weapon_selector == 5) {
                                if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                                } else {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                                }
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("JSOW");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                    } elsif (loaded_type == "AGM-158A") {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("AG158A");
                            if (weapon_selector == 5) {
                                if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                                } else {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                                }
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("JASSM");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                    } elsif (loaded_type == "AGM-158C") {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("AG158C");
                            if (weapon_selector == 5) {
                                if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                                } else {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                                }
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("LRSAM");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                    } elsif (loaded_type == "AGM-158C") {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("AG158C");
                            if (weapon_selector == 5) {
                                if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                                } else {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                                }
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("LRASM");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                    } elsif (loaded_type == "AN/ALQ-184(V) ECM Pod") {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("ECM184");
                            if (weapon_selector == 5) {
                                if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                                } else {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                                }
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("ECM184");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                    } elsif (loaded_type == "CBU-87") {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                            if (getprop("payload/armament/station/id-"~pylon_idx~"-set") == "3 x CBU-87") {
                                LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("3CBU87");
                            } else {
                                LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("CBU87");
                            }
                            if (weapon_selector == 5) {
                                if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                                } else {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                                }
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("CEM");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                    } elsif (loaded_type == "CBU-105") {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                            if (getprop("payload/armament/station/id-"~pylon_idx~"-set") == "2 x CBU-105") {
                                LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("2CBU105");
                            } else {
                                LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("CBU105");
                            }
                            if (weapon_selector == 5) {
                                if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                                } else {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                                }
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("SFW");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                    } elsif (loaded_type == "GBU-12") {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                            if (getprop("payload/armament/station/id-"~pylon_idx~"-set") == "3 x GBU-12") {
                                LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("3GBU12");
                            } else {
                                LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("GBU12");
                            }
                            if (weapon_selector == 5) {
                                if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                                } else {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                                }
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("PAVWY");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                    } elsif (loaded_type == "GBU-31") {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("GBU31");
                            if (weapon_selector == 5) {
                                if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                                } else {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                                }
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("JDAM");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                    } elsif (loaded_type == "GBU-32") {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                            if (getprop("payload/armament/station/id-"~pylon_idx~"-set") == "2 x GBU-32") {
                                LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("2GBU32");
                            } else {
                                LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("GBU32");
                            }
                            if (weapon_selector == 5) {
                                if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                                } else {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                                }
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("JDAM");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                    } elsif (loaded_type == "GBU-39") {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                            if (getprop("payload/armament/station/id-"~pylon_idx~"-set") == "4 x GBU-39") {
                                LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("4GBU39");
                            } else {
                                LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("GBU39");
                            }
                            if (weapon_selector == 5) {
                                if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                                } else {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                                }
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("SDB");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                    } elsif (loaded_type == "GBU-54") {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                            if (getprop("payload/armament/station/id-"~pylon_idx~"-set") == "2 x GBU-54") {
                                LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("2GBU54");
                            } else {
                                LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("GBU54");
                            }
                            if (weapon_selector == 5) {
                                if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                                } else {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                                }
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("LZJADM");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                    } elsif (loaded_type == "GBU-54") {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                            if (getprop("payload/armament/station/id-"~pylon_idx~"-set") == "2 x GBU-54") {
                                LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("2GBU54");
                            } else {
                                LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("GBU54");
                            }
                            if (weapon_selector == 5) {
                                if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                                } else {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                                }
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("LZJADM");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                    } elsif (loaded_type == "M151" or loaded_type == "LAU-68C") {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                            if (getprop("payload/armament/station/id-"~pylon_idx~"-set") == "3 x M151") {
                                LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("3M151");
                            } else {
                                LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("M151");
                            }
                            if (weapon_selector == 5) {
                                if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                                } else {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                                }
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("HYD");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                    } elsif (loaded_type == "MK-82") {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                            if (getprop("payload/armament/station/id-"~pylon_idx~"-set") == "3 x MK-82") {
                                LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("3MK82");
                            } else {
                                LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("MK82");
                            }
                            if (weapon_selector == 5) {
                                if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                                } else {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                                }
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("MK82");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                    } elsif (loaded_type == "MK-82AIR") {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                            if (getprop("payload/armament/station/id-"~pylon_idx~"-set") == "3 x MK-82AIR") {
                                LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("3MKAIR");
                            } else {
                                LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("MKAIR");
                            }
                            if (weapon_selector == 5) {
                                if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                                } else {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                                }
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("MKAIR");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                    } elsif (loaded_type == "MK-83") {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                            if (getprop("payload/armament/station/id-"~pylon_idx~"-set") == "3 x MK-83") {
                                LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("3MK83");
                            } else {
                                LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("MK83");
                            }
                            if (weapon_selector == 5) {
                                if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                                } else {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                                }
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("MK83");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                    } elsif (loaded_type == "MK-84") {
                            LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(1);
                            LADCanvas.pacs_station_boxes_down_text[pylon_idx].setText("MK84");
                            if (weapon_selector == 5) {
                                if (pylon_idx+1 == pylons.fcs.getSelectedPylonNumber() and master_arm) {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("RDY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(1);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(1);
                                } else {
                                    LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("STBY");
                                    LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                    LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                                }
                            } else {
                                LADCanvas.pacs_station_boxes_up_text[pylon_idx].setText("MK84");
                                LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                                LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                            }
                  } else {
                        LADCanvas.pacs_station_boxes_up_text[pylon_idx].setVisible(0);
                        LADCanvas.pacs_station_boxes_down_text[pylon_idx].setVisible(0);
                        LADCanvas.pacs_station_boxes_down[pylon_idx].setVisible(0);
                        LADCanvas.pacs_station_boxes_up[pylon_idx].setVisible(0);
                  }
                }
            }
        } else {
            LADCanvas.PACSScreen.setVisible(0);
        }
    }
}

LADCanvas = LAD_Device.new({"node": "LADImage"});
update_loop_lad = maketimer(.1, update_lad);
update_loop_lad.start();
