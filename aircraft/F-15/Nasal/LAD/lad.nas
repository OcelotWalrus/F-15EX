# F-15EX Canvas LAD (Large Area Display)
# ---------------------------
# The LAD is a 10" (height) by 19" (width) colored touchscreen display,
# With 3 main displays (each allowing to display the target pod's view,
# the FLIR's view (if a LANTIRN Nav Pod is loaded and armed), a HSD and a VSD,
# and 5 MPCDs below that, aligned in a single line, allowing full control
# over the avionics and the whole aircraft.
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

# Preset Colors
var prst_black = {"r": 0, "g": 0, "b": .015};
var prst_white = {"r": .98, "g": .98, "b": .98};
var prst_green = {"r": 0, "g": 255 / 255, "b": 58 / 255};
var prst_yellow = {"r": 234 / 255, "g": 255 / 255, "b": 0 / 255};
var prst_yellow_dark = {"r": 94 / 255, "g": 105 / 255, "b": 0 / 255};  # 2.5 times darker than regular yellow

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



        # The upper panel, it's static and displays basic useful information
        m.upper_panel = m.svg.createGroup();

        # Are in order from left to right
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

        return m;
    },
};

var LADCanvas = nil;
var update_loop = nil;

update = func() {
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
}

LADCanvas = LAD_Device.new({"node": "LADImage"});
update_loop = maketimer(.1, update);
update_loop.start();
