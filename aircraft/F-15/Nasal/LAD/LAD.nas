# F-15EX Canvas LAD (Large Area Display)
# ---------------------------
# The LAD is a 10" (height) by 19" (width) colored touchscreen display,
# With 3 main displays (each allowing to display the target pod's view,
# the FLIR's view (if a LANTIRN Nav Pod is loaded and armed), a HSD and a VSD,
# and 5 MPCDs below that, aligned in a single line, allowing full control
# over the avionics, the weaponry and the whole aircraft pretty much.
# ---------------------------
# Future features (TODO's) :
# - Differentiate evading, "neutral" and incoming contacts using different
# symbology, without the need of locking it and looking at its closing speed
# - Add the DLZ (Dynamic Launch Zone), to complement the closing speed
# - Add the ASEs (Allowable Steering Error) when having a target locked and
# having a Sidewinder or AMRAAM armed
# - Display the TACAN station's pos (useful for tanker or carrier ops)
# ---------------------------
# Author: Jimmy L. Miles
# ---------------------------

## Constant Variables

# Measures
var ratio = 431.157; # 8192px = 19"
var height = 10;
var width = 19;
var height_px = math.floor(10 * ratio);
var width_px = math.floor(19 * ratio);

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
    "KC-137R-RT":               "TNKR",#TNKR = Boom TDRG=drouge
    "707-TT":                   "TNKR",
    "KC-30A":                   "TNKR",
    "Voyager-KC":               "TNKR",
    "KC-10A":                   "TNKR",
    "KC-10A-GE":                "TNKR",
    "EC-137R":                  "AEW&C",#awacs airborne and groundborne
    "RC-137R":                  "AEW&C",
    "E-3R":                     "AEW&C",
    "E-173R":                   "AEW&C",
    "E-8R":                     "AEW&C",
    "EC-137D":                  "AEW&C",
    "gci":                      "AEW&C",
    "MiG-29":                   "F",
    "SU-27":                    "F",
    "ch53e":                    "HEL",#heli
    "Mil-Mi-8":                 "HEL",#heli
    "ka50":                     "HEL",#heli
    "mi24":                     "HEL",#heli
    "MQ-9":                     "MC",#missile carrier
    "QF-4E":                    "F",
    "B1-B":                     "B",#bomber
    "A-10":                     "F/B",
    "A-10-model":               "F/B",
    "Typhoon":                  "F/B",
    "f16":                      "F",
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
    "zsu-23":                "SHILKA",
    "ZSU-IR":             "SHILKA-IR",
    "truck":                  "TRUCK",
    # Ships
    "missile_frigate":          "SHP",
    "frigate":                  "SHP",
    "fleet":                    "SHP",
    "USS-LakeChamplain":        "SHP",
    "USS-NORMANDY":             "SHP",
    "USS-OliverPerry":          "SHP",
    "USS-SanAntonio":           "SHP",
    "hunter":                   "BOT",
};

# Preset Colors
var prst_black = {"r": 0, "g": 0, "b": .015};
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

# Settings
var main_screens = {
    "left": "VSD",
    "center": "PACS",
    "right": "HSD",
};
var VSD_ON = 0;
var PACS_ON = 0;
var HSD_ON = 0;

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
            .setTranslation(670,230)
            .setFont(aircraft.HUDFont);
        m.caution_box = m.upper_panel.createChild("path")
            .vert(230*2)
            .horiz(270*2)
            .vert(-230*2)
            .horiz(-270*2)
            .setTranslation(400,20)
            .setStrokeLineWidth(20)
            .setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b);

        # Radio 1 (Comm 1) box
        m.radio1_text_up = m.upper_panel.createChild("text")
            .setFontSize(135, 1.4)
            .setText("R1")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(1280,115)
            .setFont(aircraft.HUDFont);
        m.radio1_text_center = m.upper_panel.createChild("text")
            .setFontSize(120, 1.4)
            .setText("OFF")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(1280,230)
            .setFont(aircraft.HUDFont);
        m.radio1_text_down = m.upper_panel.createChild("text")
            .setFontSize(100, 1.4)
            .setText("113.76 MHz")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(1280,345)
            .setFont(aircraft.HUDFont);
        m.radio1_box = m.upper_panel.createChild("path")
            .vert(230*2)
            .horiz(320*2)
            .vert(-230*2)
            .horiz(-320*2)
            .setTranslation(960,20)
            .setStrokeLineWidth(20)
            .setColor(prst_white.r,prst_white.g,prst_white.b);

        # Radio 2 (Comm 2) box
        m.radio2_text_up = m.upper_panel.createChild("text")
            .setFontSize(135, 1.4)
            .setText("R2")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(1940,115)
            .setFont(aircraft.HUDFont);
        m.radio2_text_center = m.upper_panel.createChild("text")
            .setFontSize(120, 1.4)
            .setText("OFF")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(1940,230)
            .setFont(aircraft.HUDFont);
        m.radio2_text_down = m.upper_panel.createChild("text")
            .setFontSize(100, 1.4)
            .setText("113.76 MHz")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(1940,345)
            .setFont(aircraft.HUDFont);
        m.radio2_box = m.upper_panel.createChild("path")
            .vert(230*2)
            .horiz(320*2)
            .vert(-230*2)
            .horiz(-320*2)
            .setTranslation(1620,20)
            .setStrokeLineWidth(20)
            .setColor(prst_white.r,prst_white.g,prst_white.b);

        # Transponder box
        m.transponder_text_up = m.upper_panel.createChild("text")
            .setFontSize(135, 1.4)
            .setText("MODE 3/A")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(2620,115)
            .setFont(aircraft.HUDFont);
        m.transponder_text_center = m.upper_panel.createChild("text")
            .setFontSize(100, 1.4)
            .setText("1763")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(2620,230)
            .setFont(aircraft.HUDFont);
        m.transponder_text_down = m.upper_panel.createChild("text")
            .setFontSize(120, 1.4)
            .setText("STBY")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(2620,345)
            .setFont(aircraft.HUDFont);
        m.transponder_box = m.upper_panel.createChild("path")
            .vert(230*2)
            .horiz(320*2)
            .vert(-230*2)
            .horiz(-320*2)
            .setTranslation(2280,20)
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
            .setText("hash 4217")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(3295,230)
            .setFont(aircraft.HUDFont);
        m.iff_text_down = m.upper_panel.createChild("text")
            .setFontSize(120, 1.4)
            .setText("NO RESP")
            .setAlignment("center-center")
            .setColor(prst_white.r,prst_white.g,prst_white.b)
            .setTranslation(3295,345)
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
        m.transponder_text_up.setVisible(1);
        m.transponder_text_center.setVisible(1);
        m.transponder_text_down.setVisible(1);
        m.transponder_box.setVisible(1);
        m.iff_text_up.setVisible(1);
        m.iff_text_center.setVisible(1);
        m.iff_text_down.setVisible(1);
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
            .setTranslation(970,2300*2+500+10)
            .setFont(aircraft.HUDFont);
        # Radar
        m.vsd_rdr_range_txt = m.VSDScreen.createChild("text")    
            .setFontSize(80, 1.4)
            .setText("050 NM")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(2555,535)
            .setFont(aircraft.HUDFont);
        m.vsd_rdr_mode_1 = m.VSDScreen.createChild("text")    
            .setFontSize(100, 1.4)
            .setText("T")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(2645+35,700)
            .setFont(aircraft.HUDFont);
        m.vsd_rdr_mode_2 = m.VSDScreen.createChild("text")    
            .setFontSize(100, 1.4)
            .setText("W")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(2645+35,780)
            .setFont(aircraft.HUDFont);
        m.vsd_rdr_mode_3 = m.VSDScreen.createChild("text")    
            .setFontSize(100, 1.4)
            .setText("S")
            .setAlignment("center-center")
            .setColor(prst_green.r,prst_green.g,prst_green.b)
            .setTranslation(2645+35,860)
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
                .setStrokeLineWidth(4)
                .setVisible(0)
                .set("z-index",15)
                .setColor(prst_purple.r,prst_purple.g,prst_purple.b);
            m.stpt_symbols[i] = m.stpt;
        }
        m.stpt_texts = setsize([], m.stpt_symbols_max);
        for (var i = 0; i < m.stpt_symbols_max; i += 1){
            m.stpt_txt = m.VSDScreen.createChild("text")  # far down, bottom left
                .setFontSize(85, 1.4)
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
                .moveTo(677*2,2262+500)
                .lineTo(677*2-22,2262+500)
                .lineTo(677*2,2262+500+112)
                .lineTo(677*2+22,2262+500)
                .lineTo(677*2,2262+500)
                .setStrokeLineWidth(7)
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
        
        m.locked_box = m.VSDScreen.createChild("path")
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
        m.dlnk_symbols = setsize([], m.dlnk_symbols_max);
        for (var i = 0; i < m.dlnk_symbols_max; i += 1){
            m.dlnk = m.VSDScreen.createChild("path")
                .moveTo(677*2,2262+500)
                .arcSmallCW(6,6,0,0,12)
                .arcSmallCW(6,6,0,0,-12)
                .setStrokeLineWidth(3)
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
        m.vsd_tgt_closure_pin = m.VSDScreen.createChild("path")
            .moveTo(677*4-75,1150*2+500+75)
            .lineTo(677*4-75-75,1150*2+500+75+65)
            .moveTo(677*4-75,1150*2+500+75)
            .lineTo(677*4-75-75,1150*2+500+75-65)
            .setStrokeLineWidth(6)
            .set("z-index",15)
            .setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b);
        m.vsd_tgt_closure_text = m.VSDScreen.createChild("text")
            .setFontSize(85, 1.4)
            .setText("0637")
            .setAlignment("center-center")
            .setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b)
            .setTranslation(677*4-75-140,1150*2+500+75)
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
        m.vsd_stpt_eta.setVisible(1);
        m.vsd_stpt_dist.setVisible(1);
        m.vsd_stpt_bearing.setVisible(1);
        m.vsd_azimuth_carat.setVisible(1);
        m.vsd_rdr_range_txt.setVisible(1);
        m.vsd_rdr_mode_1.setVisible(1);
        m.vsd_rdr_mode_2.setVisible(1);
        m.vsd_rdr_mode_3.setVisible(1);
        m.vsd_rdr_filter_1.setVisible(1);
        m.vsd_rdr_filter_2.setVisible(1);
        m.vsd_rdr_filter_3.setVisible(1);
        m.vsd_azimuth_center.setVisible(1);
        m.vsd_azimuth_right.setVisible(1);
        m.vsd_azimuth_left.setVisible(1);
        m.vsd_azimuth_limit_circle_right_60.setVisible(1);
        m.vsd_azimuth_limit_circle_left_60.setVisible(1);
        m.vsd_azimuth_limit_circle_right_30.setVisible(0);
        m.vsd_azimuth_limit_circle_left_30.setVisible(0);
        m.vsd_tgt_true_speed.setVisible(0);
        m.vsd_tgt_bearing.setVisible(0);
        m.vsd_tgt_heading.setVisible(0);
        m.vsd_tgt_aspect.setVisible(0);
        m.vsd_tgt_altitude.setVisible(0);
        m.vsd_tgt_range.setVisible(0);
        m.vsd_tgt_closure_pin.setVisible(0);
        m.vsd_tgt_closure_text.setVisible(0);

        return m;
    },
};

var LADCanvas = nil;
var update_loop_lad = nil;

update = func() {

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

    # Update the transponder's box
    transponder_code = getprop("instrumentation/transponder/id-code");
    transponder_mode = getprop("instrumentation/transponder/inputs/knob-mode");
    if (transponder_mode == 0) {
        transponder_mode = "OFF";
    } elsif (transponder_mode == 1) {
        transponder_mode = "STBY";
    } elsif (transponder_mode == 2) {
        transponder_mode = "TEST";
    } elsif (transponder_mode == 3) {
        transponder_mode = "GROUND";
    } elsif (transponder_mode == 4) {
        transponder_mode = "ON";
    } elsif (transponder_mode == 5) {
        transponder_mode = "ALTI";
    }

    if (transponder_mode == "ON" or transponder_mode == "ALTI") {
        LADCanvas.transponder_text_up.setColor(prst_green.r,prst_green.g,prst_green.b);
        LADCanvas.transponder_text_center.setColor(prst_green.r,prst_green.g,prst_green.b);
        LADCanvas.transponder_text_down.setColor(prst_green.r,prst_green.g,prst_green.b);
        LADCanvas.transponder_box.setColor(prst_green.r,prst_green.g,prst_green.b);
    } else {
        LADCanvas.transponder_text_up.setColor(prst_white.r,prst_white.g,prst_white.b);
        LADCanvas.transponder_text_center.setColor(prst_white.r,prst_white.g,prst_white.b);
        LADCanvas.transponder_text_down.setColor(prst_white.r,prst_white.g,prst_white.b);
        LADCanvas.transponder_box.setColor(prst_white.r,prst_white.g,prst_white.b);
    }

    LADCanvas.transponder_text_center.setText(sprintf("%04d", transponder_code));
    LADCanvas.transponder_text_down.setText(transponder_mode);

    # Update the IFF's box
    iff_channel = getprop("instrumentation/iff/channel_prop");
    iff_power = getprop("instrumentation/iff/power_prop");
    iff_response = getprop("instrumentation/iff/response");

    LADCanvas.iff_text_center.setText(sprintf("hash %04d", iff_channel));

    if (iff_power) {
        LADCanvas.iff_text_up.setText("IFF - ON");
        LADCanvas.iff_text_up.setColor(prst_green.r,prst_green.g,prst_green.b);
        LADCanvas.iff_text_center.setColor(prst_green.r,prst_green.g,prst_green.b);
        LADCanvas.iff_text_down.setColor(prst_green.r,prst_green.g,prst_green.b);
        LADCanvas.iff_box.setColor(prst_green.r,prst_green.g,prst_green.b);
    } else {
        LADCanvas.iff_text_up.setText("IFF - OFF");
        LADCanvas.iff_text_up.setColor(prst_white.r,prst_white.g,prst_white.b);
        LADCanvas.iff_text_center.setColor(prst_white.r,prst_white.g,prst_white.b);
        LADCanvas.iff_text_down.setColor(prst_white.r,prst_white.g,prst_white.b);
        LADCanvas.iff_box.setColor(prst_white.r,prst_white.g,prst_white.b);
    }
    if (iff_response) {
        LADCanvas.iff_text_down.setText("RESPONSE");
        LADCanvas.iff_text_up.setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b);
        LADCanvas.iff_text_center.setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b);
        LADCanvas.iff_text_down.setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b);
        LADCanvas.iff_box.setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b);
    } else {
        LADCanvas.iff_text_down.setText("NO RESP");
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

    LADCanvas.dtl_text_center.setText(sprintf("hash %04d", datalink_channel));
    LADCanvas.dtl_text_down.setText(sprintf("ON LINK : %02d", on_link_count));
    if (datalink_power) {
        LADCanvas.dtl_text_up.setText("DTLNK - ON");
        LADCanvas.dtl_text_up.setColor(prst_green.r,prst_green.g,prst_green.b);
        LADCanvas.dtl_text_center.setColor(prst_green.r,prst_green.g,prst_green.b);
        LADCanvas.dtl_text_down.setColor(prst_green.r,prst_green.g,prst_green.b);
        LADCanvas.dtl_box.setColor(prst_green.r,prst_green.g,prst_green.b);
    } else {
        LADCanvas.dtl_text_up.setText("DTLNK - OFF");
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
        LADCanvas.VSDScreen.setTranslation(8192/3,0);  # Default position's position for the left main screen
    } elsif (main_screens.right == "VSD") {
        VSD_ON = 1;
        LADCanvas.VSDScreen.setTranslation((8192/3)*2,0);  # Default position's position for the left main screen
    } else {
        VSD_ON = 0;
    }
    
    ## VSD Updates
    if (VSD_ON) {  # Optimization, we only wanna update the VSD display if it's online
        LADCanvas.VSDScreen.setVisible(1);
        # Update the texts
        LADCanvas.vsd_rdr_range_txt.setText(sprintf("%03d NM", getprop("instrumentation/radar/radar2-range")));
        if (getprop("instrumentation/radar/radar-standby")) {  # if radar's standby
            LADCanvas.vsd_rdr_mode_1.setText("S");
            LADCanvas.vsd_rdr_mode_2.setText("T");
            LADCanvas.vsd_rdr_mode_3.setText("Y");
        } elsif (getprop("sim/model/f15/instrumentation/radar-awg-9/wcs-mode") == 6) {  # if radar's in TWS mode
            LADCanvas.vsd_rdr_mode_1.setText("T");
            LADCanvas.vsd_rdr_mode_2.setText("W");
            LADCanvas.vsd_rdr_mode_3.setText("S");
        } elsif (getprop("sim/model/f15/instrumentation/radar-awg-9/wcs-mode") == 3) {  # if radar's in Pulse Search mode
            LADCanvas.vsd_rdr_mode_1.setText("P");
            LADCanvas.vsd_rdr_mode_2.setText("U");
            LADCanvas.vsd_rdr_mode_3.setText("L");
        }
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
        LADCanvas.vsd_horizon_line.setTranslation (0.0, -new_y_pos_hori-pitch_offset);
        #LADCanvas.vsd_horizon_line.setRotation (-getprop("orientation/roll-deg") * DTOR);
        
        # Update some texts giving info about ourselves
        LADCanvas.vsd_ground_speed.setText(sprintf("G %03d", getprop("velocities/groundspeed-kt")));
        LADCanvas.vsd_airspeed.setText(sprintf("T %03d", getprop("velocities/airspeed-kt")));
        
        # Move the azimuth carat around
        var azimuth_sweep = getprop("sim/model/f15/instrumentation/awg-9/sweep-factor");
        var carat_sweep = 0;
        if (azimuth_sweep != nil) {  # this property is created in awg_9.nas, so at startup it's null
            carat_sweep = azimuth_sweep * 1280;
        }
        LADCanvas.vsd_azimuth_carat.setTranslation(carat_sweep, 0.0);
        
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
                        y_move = wpelev * 1131 / 60;
                        
                        if (x_move > 677*2-85) {  # clamp the translation's values so it don't get outta the screen
                            x_move = 677*2-85;
                        } elsif (x_move < -(677*2-85)) {
                            x_move = -(677*2-85);
                        }
                        if (y_move > 1110) {
                            y_move = 1110
                        } elsif (y_move < -1110) {
                            y_move = -1110
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
                        friendly = contact_data.is_friendly();
                        hostile = contact_data.is_hostile();
                        on_link = contact_data.on_link();
                    } else {
                        friendly = 0;
                        hostile = 0;
                        on_link = 0;
                    }
                    
                    if (on_link) {
                        LADCanvas.tgt_symbols[target_idx].setColor(prst_blue.r,prst_blue.g,prst_blue.b);
                        LADCanvas.tgt_texts[target_idx].setColor(prst_blue_dark.r,prst_blue_dark.g,prst_blue_dark.b);
                    } elsif (friendly) {
                        LADCanvas.tgt_symbols[target_idx].setColor(prst_cyan.r,prst_cyan.g,prst_cyan.b);
                        LADCanvas.tgt_texts[target_idx].setColor(prst_cyan_dark.r,prst_cyan_dark.g,prst_cyan_dark.b);
                    } elsif (hostile) {
                        LADCanvas.tgt_symbols[target_idx].setColor(prst_red.r,prst_red.g,prst_red.b);
                        LADCanvas.tgt_texts[target_idx].setColor(prst_red_dark.r,prst_red_dark.g,prst_red_dark.b);
                    } else {
                        LADCanvas.tgt_symbols[target_idx].setColor(prst_yellow.r,prst_yellow.g,prst_yellow.b);
                        LADCanvas.tgt_texts[target_idx].setColor(prst_yellow_dark.r,prst_yellow_dark.g,prst_yellow_dark.b);
                    }
                    
                    LADCanvas.tgt_symbols[target_idx].setVisible(1);
                    LADCanvas.tgt_texts[target_idx].setVisible(1);
                    xc = contact.get_deviation(getprop("orientation/heading-deg")) or 0;
                    yc = -contact.get_total_elevation(getprop("orientation/pitch-deg")) or 0;
                    LADCanvas.tgt_symbols[target_idx].setTranslation(xc*1354/60, yc*1131/60); # the factors is to let display correspond to 120 degrees wide and height.
                    LADCanvas.tgt_texts[target_idx].setTranslation(677*2+(xc*1354/60), 2262+500+145+(yc*1131/60)); # the factors is to let display correspond to 120 degrees wide and height.
                    if (found_lock == 1 and lock_assigned == 0) {
                        LADCanvas.locked_box.setTranslation(xc*1354/60, yc*1131/60); # the factors is to let display correspond to 120 degrees wide and height.
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
            LADCanvas.locked_box.setVisible(1);
            LADCanvas.vsd_tgt_true_speed.setVisible(1);
            LADCanvas.vsd_tgt_bearing.setVisible(1);
            LADCanvas.vsd_tgt_heading.setVisible(1);
            LADCanvas.vsd_tgt_aspect.setVisible(1);
            LADCanvas.vsd_tgt_altitude.setVisible(1);
            LADCanvas.vsd_tgt_range.setVisible(1);
            LADCanvas.vsd_tgt_closure_pin.setVisible(1);
            LADCanvas.vsd_tgt_closure_text.setVisible(1);
            
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
                LADCanvas.vsd_tgt_closure_text.setText(sprintf("%d", awg_9.active_u.get_closure_rate()));
                
                # Scale:
                # To be at 600 (moving 2,275px up), closing speed must be 3,000 KTS
                closing_y = awg_9.active_u.get_closure_rate() * 3000 / 2275;
                if (closing_y > 2275) {  # clamp the values
                    closing_y = 2275; # max down px value
                } elsif (closing_y < -2275) {
                    closing_y = -2275; # max up px value
                }
                LADCanvas.vsd_tgt_closure_pin.setTranslation(0.0, -closing_y);
                LADCanvas.vsd_tgt_closure_text.setTranslation(677*4-75-140, 2875-closing_y);
            }
        } else {
            LADCanvas.locked_box.setVisible(0);
            LADCanvas.vsd_tgt_true_speed.setVisible(0);
            LADCanvas.vsd_tgt_bearing.setVisible(0);
            LADCanvas.vsd_tgt_heading.setVisible(0);
            LADCanvas.vsd_tgt_aspect.setVisible(0);
            LADCanvas.vsd_tgt_altitude.setVisible(0);
            LADCanvas.vsd_tgt_range.setVisible(0);
            LADCanvas.vsd_tgt_closure_pin.setVisible(0);
            LADCanvas.vsd_tgt_closure_text.setVisible(0);
        }
        
        # Do not display any unused target boxes
        for (var nv = target_idx; nv < LADCanvas.tgt_symbols_max;nv += 1) {
            LADCanvas.tgt_symbols[nv].setVisible(0);
            LADCanvas.tgt_texts[nv].setVisible(0);
        }
        
        # Update the datalink symbols
        var dlnk_idx = 0;
        var datalink_connections = datalink.get_all_callsigns();
        foreach (contact ; datalink_connections) {
            already_on_rdr = 0;  # if its' on our radar, we don't display it.
            foreach(rdrcontact ; awg_9.tgts_list) {
                if (rdrcontact.get_Callsign() == contact) {
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
                            LADCanvas.dlnk_symbols[dlnk_idx].setColor(prst_cyan.r,prst_cyan.g,prst_cyan.b);
                            LADCanvas.dlnk_texts[dlnk_idx].setColor(prst_cyan_dark.r,prst_cyan_dark.g,prst_cyan_dark.b);
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
                        LADCanvas.dlnk_symbols[dlnk_idx].setTranslation(xc*1354/60, yc*1131/60); # the factors is to let display correspond to 120 degrees wide and height.
                        LADCanvas.dlnk_texts[dlnk_idx].setTranslation(677*2+(xc*1354/60), 2262+500+145+(yc*1131/60)); # the factors is to let display correspond to 120 degrees wide and height.
                        if (contact_model != nil and typeLookup[contact_model] != nil) {
                            contact_type = typeLookup[contact_model];
                            contact_alt = contact_alt * 0.001;  # So it's in thousands of feet
                            LADCanvas.dlnk_texts[dlnk_idx].setText(sprintf("%s %02d", contact_type, contact_alt));
                        } else {  # Model's unknown to our radar
                            contact_alt = contact_alt * 0.001;  # So it's in thousands of feet
                            LADCanvas.dlnk_texts[dlnk_idx].setText(sprintf("UNK %02d", contact_alt));
                        }
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
}

LADCanvas = LAD_Device.new({"node": "LADImage"});
update_loop_lad = maketimer(.1, update);
update_loop_lad.start();
