# F-15EX Canvas UFC (Upper Front Controls)
# ---------------------------
# The UFC, Upper Front Controls, is a console at the very bottom of the HUD,
# Including a 4" by 8" screen to display text (only) and a keypad at its
# bottom, containing the exact same buttons as the previous F-15 Strike Eagle's UFC.
# No information is known on the F-15EX's UFC, so this is only MY take on its UFC.
# From real-life photographs, it looks like the UFC's screen can only contain one single
# string of text, of a maximum length that I estimated to be about 30 characters. Unlike
# in the Strike Eagle, the Eagle II's UFC will be much more compact and will only contain a
# few menus, which are described in the following heading, as most of the configuration will
# be done in the LAD, so the main purpose of the UFC will be to serve as a "screened-keypad"
# for the LAD.
# ---------------------------
# UFC Menus/Submenus :
# // A/P (Autopilot) //
# This menu can be obtained by selecting it through the main menu, or by entering A/P on the keypad.
# The press of A/P on the keypad will turn on autopilot, and a second will turn it off.
# // COMMS (Radio 1 & 2)//
# This menu is obtained by touching the LAD inside either the Radio 1 or Radio 2 boxes. It allows
# to set active, standby and preset frequencies for the selected radio and see whether a station
# is connected to us or not with the active frequency.
# // ILS / NAV1-2 //
# This menu is obtained by touching the LAD inside the Upper Panel's ILS box. It allows to see
# status info about the NAV1 radio, set the active/standby and preset channels, and push them to
# active channel, set the radial/CDI course.
# ---------------------------
# Future Features:
# - Allow the selection of NAV1 Glideslope for A/P Pitch mode
# ---------------------------
# Some Notes :
# - Current proportions in the model are 2.849173228" (width) by .455" (height), making it a 6 1/4 ratio (width/height)
# ---------------------------
# Author: Jimmy L. Miles
# ---------------------------

## Variables
var stored_input = "";  # Variable in which we store the pilot's input'd info (ex. "129.5" if we're entering a radio's frequency in MHz)
                        # It's always a string even if it's numeric data, it gets translated if needed.
var inputting = 0;  # Used to determine whether the pilot is expected to input data or not
var bad_data = 0;  # Used to determine whether the "BAD DATA" label should be displayed or not. This is triggered when an inputted stored_input ain't no valid one
var bad_data_clear_called = 0;  # Used to determined if we've already started 3-second countdown till BAD DATA disappears

# Menus
# Each specific menu/sub-menu got a specific integer ID for 'em.
# It's depending on the curr_menu ID that we know what button does what
# and what's to be displayed.
var dft_menu = 0;
var curr_menu = dft_menu;  # Default menu

# Autopilot
var autopilot_main_menu = 1;  # Displays different options (INFO, HDG MD, PTCH MD, THROT)
var autopilot_info_menu = 2;  # Displays info about current autopilot nav
var autopilot_heading_menu = 3;  # Allows to configure autopilot heading controls
var autopilot_altitude_menu = 4;  # Allows to configure autopilot altitude controls
var autopilot_altitude_menu_sec = 5;
var autopilot_auto_throttle_menu = 6;

# COMMS
var comm_main_menu = 11;  # Displays different options (INFO, CHANS, COMM1/2)
var comm_info_menu = 12;  # Displays info about the current Comm radio status/settings
var comm_chans_menu = 13;  # Allows to set active and standby channels into the selected Comm radio and select through them
var comm_chans_index = 0;  # So we know which frequency data block we're checking out in the Comm channels menu
var current_comm = 0;  # 0 comm1, 1 comm2

# NAV1/ILS
var nav1_main_menu = 7;  # Displays different options (INFO, CHANS, RAD, TCN/STPT)
var nav1_menu_info = 8;  # Displays info about the current ILS/NAV1 status/settings
var nav_1_chans_menu = 9;  # Allows to set active and standby channels presets into NAV1 and select through them
var nav_1_chans_index = 0;  # So we know which frequency data block we're checking out in the NAV1 channels menu
var nav_1_mode_menu = 10;

# Measures
var screen_ratio = 6.25;
var screen_width = 512;  # pixels resolution
var screen_height = 512 / screen_ratio;

# Preset Colors. These values are the same across all of the EX's displays, so make sure to update the others if you update that one
var prst_black = {"r": 0, "g": 0, "b": 0};
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

## Button listeners
var crec_l_pres = 0;
var a_1_pres = 0;
var n_2_pres = 0;
var b_3_pres = 0;
var crec_r_pres = 0;
var mrk_pres = 0;
var w_4_pres = 0;
var m_5_pres = 0;
var e_6_pres = 0;
var ip_pres = 0;
var decimal_pres = 0;
var i_7_pres = 0;
var s_8_pres = 0;
var c_9_pres = 0;
var shf_pres = 0;
var ap_pres = 0;
var clr_pres = 0;
var hyphen_0_pres = 0;
var data_pres = 0;
var menu_pres = 0;

setlistener("sim/model/f15/controls/UFC/buttons-pressed/UFCButton00", func(v) {
    if (getprop("sim/model/f15/controls/UFC/buttons-pressed/UFCButton00") == 1) {
        displays.crec_l_pres = 1;
    }
});
setlistener("sim/model/f15/controls/UFC/buttons-pressed/UFCButton01", func(v) {
    if (getprop("sim/model/f15/controls/UFC/buttons-pressed/UFCButton01") == 1) {
        displays.a_1_pres = 1;
    }
});
setlistener("sim/model/f15/controls/UFC/buttons-pressed/UFCButton02", func(v) {
    if (getprop("sim/model/f15/controls/UFC/buttons-pressed/UFCButton02") == 1) {
        displays.n_2_pres = 1;
    }
});
setlistener("sim/model/f15/controls/UFC/buttons-pressed/UFCButton03", func(v) {
    if (getprop("sim/model/f15/controls/UFC/buttons-pressed/UFCButton03") == 1) {
        displays.b_3_pres = 1;
    }
});
setlistener("sim/model/f15/controls/UFC/buttons-pressed/UFCButton04", func(v) {
    if (getprop("sim/model/f15/controls/UFC/buttons-pressed/UFCButton04") == 1) {
        displays.crec_r_pres = 1;
    }
});
setlistener("sim/model/f15/controls/UFC/buttons-pressed/UFCButton05", func(v) {
    if (getprop("sim/model/f15/controls/UFC/buttons-pressed/UFCButton05") == 1) {
        displays.mrk_pres = 1;
    }
});
setlistener("sim/model/f15/controls/UFC/buttons-pressed/UFCButton06", func(v) {
    if (getprop("sim/model/f15/controls/UFC/buttons-pressed/UFCButton06") == 1) {
        displays.w_4_pres = 1;
    }
});
setlistener("sim/model/f15/controls/UFC/buttons-pressed/UFCButton07", func(v) {
    if (getprop("sim/model/f15/controls/UFC/buttons-pressed/UFCButton07") == 1) {
        displays.m_5_pres = 1;
    }
});
setlistener("sim/model/f15/controls/UFC/buttons-pressed/UFCButton08", func(v) {
    if (getprop("sim/model/f15/controls/UFC/buttons-pressed/UFCButton08") == 1) {
        displays.e_6_pres = 1;
    }
});
setlistener("sim/model/f15/controls/UFC/buttons-pressed/UFCButton09", func(v) {
    if (getprop("sim/model/f15/controls/UFC/buttons-pressed/UFCButton09") == 1) {
        displays.ip_pres = 1;
    }
});
setlistener("sim/model/f15/controls/UFC/buttons-pressed/UFCButton010", func(v) {
    if (getprop("sim/model/f15/controls/UFC/buttons-pressed/UFCButton010") == 1) {
        displays.decimal_pres = 1;
    }
});
setlistener("sim/model/f15/controls/UFC/buttons-pressed/UFCButton011", func(v) {
    if (getprop("sim/model/f15/controls/UFC/buttons-pressed/UFCButton011") == 1) {
        displays.i_7_pres = 1;
    }
});
setlistener("sim/model/f15/controls/UFC/buttons-pressed/UFCButton012", func(v) {
    if (getprop("sim/model/f15/controls/UFC/buttons-pressed/UFCButton012") == 1) {
        displays.s_8_pres = 1;
    }
});
setlistener("sim/model/f15/controls/UFC/buttons-pressed/UFCButton013", func(v) {
    if (getprop("sim/model/f15/controls/UFC/buttons-pressed/UFCButton013") == 1) {
        displays.c_9_pres = 1;
    }
});
setlistener("sim/model/f15/controls/UFC/buttons-pressed/UFCButton014", func(v) {
    if (getprop("sim/model/f15/controls/UFC/buttons-pressed/UFCButton014") == 1) {
        displays.shf_pres = 1;
    }
});
setlistener("sim/model/f15/controls/UFC/buttons-pressed/UFCButton015", func(v) {
    if (getprop("sim/model/f15/controls/UFC/buttons-pressed/UFCButton015") == 1) {
        displays.ap_pres = 1;
    }
});
setlistener("sim/model/f15/controls/UFC/buttons-pressed/UFCButton016", func(v) {
    if (getprop("sim/model/f15/controls/UFC/buttons-pressed/UFCButton016") == 1) {
        displays.clr_pres = 1;
    }
});
setlistener("sim/model/f15/controls/UFC/buttons-pressed/UFCButton017", func(v) {
    if (getprop("sim/model/f15/controls/UFC/buttons-pressed/UFCButton017") == 1) {
        displays.hyphen_0_pres = 1;
    }
});
setlistener("sim/model/f15/controls/UFC/buttons-pressed/UFCButton018", func(v) {
    if (getprop("sim/model/f15/controls/UFC/buttons-pressed/UFCButton018") == 1) {
        displays.data_pres = 1;
    }
});
setlistener("sim/model/f15/controls/UFC/buttons-pressed/UFCButton019", func(v) {
    if (getprop("sim/model/f15/controls/UFC/buttons-pressed/UFCButton019") == 1) {
        displays.menu_pres = 1;
    }
});



var UFC_Device = {

    canvas_settings: {
        "name": "F15-UFC",
        "size": [screen_width, screen_height],
        "view": [screen_width, screen_height],
        "mipmapping": 1
    },

    new: func(placement) {
        var m = {parents: [UFC_Device]};
        m.svg = canvas.new(UFC_Device.canvas_settings);
        m.svg.addPlacement(placement);

        m.svg.setColorBackground(0, 1, 145/255, .015);  # Almost transparent
        
        m.UFCScreen = m.svg.createGroup();
        m.UFCText = m.UFCScreen.createChild("text")
            .setFontSize(35, 1.4)
            .setText("YXXXXXXXXXXXXXXXXXXXXXXXXXXXXY")  # 30-character string
            .setAlignment("center-center")
            .setColor(0, 1, 145/255)  # blue-ish green, as appearing on photographs
            .setTranslation(screen_width/2,screen_height/2)
            .setFont(aircraft.HUDFont);
        
        m.UFCScreen.setVisible(1);
        m.UFCText.setVisible(1);

        return m;
    },
};

var UFCCanvas = nil;
var update_loop_ufc = nil;

# Setup the A/P properties, taken from gui/dialogs/autopilot.xml
var dlg = props.globals.getNode("/sim/gui/dialogs/autopilot", 1);

Group = {
    new : func(name, options) {
        var m = { parents: [Group] };
        m.name = name;
        m.enabled = 0;
        m.mode = options[0];
        m.options = [];

        var locks = props.globals.getNode("/autopilot/locks", 1);
        if (locks.getNode(name) == nil or locks.getNode(name, 1).getValue() == nil) {
            locks.getNode(name, 1).setValue("");
        }
        m.lock = locks.getNode(name);
        m.active = dlg.getNode(name ~ "-active", 1);

        foreach (var o; options) {
            var node = dlg.getNode(o);
            if (node == nil) {
                node = dlg.getNode(o, 1);
                node.setBoolValue(0);
            }
            append(m.options, node);
            if (m.lock.getValue() == o) {
                m.mode = o;
            }
        }
        m.listener = setlistener(m.lock, func(n) { m.update(n.getValue()) }, 1);
        return m;
    },
    del : func {
        removelistener(me.listener);
    },

    ## handle checkbox
    #
    enable : func {
        me.enabled = me.active.getBoolValue();
        me.lock.setValue(me.enabled ? me.mode : "");
    },

    ## handle radiobuttons
    #
    set : func(mode) {
        me.mode = mode;
        foreach (var o; me.options) {
            o.setBoolValue(o.getName() == mode);
        }
        if (me.enabled) {
            me.lock.setValue(mode);
        }
    },

    ## update checkboxes/radiobuttons state from the AP (listener callback)
    #
    update : func(mode) {
        me.enabled = (mode != "");
        me.active.setBoolValue(me.enabled);
        if (mode == "") {
            mode = me.mode;
        }
        foreach (var o; me.options) {
            o.setBoolValue(o.getName() == mode);
        }
    },
};


## create and initialize input field properties if necessary
#
var apset = props.globals.getNode("/autopilot/settings", 1);
foreach (var p; ["heading-bug-deg", "target-roll-deg", "true-heading-deg", "vertical-speed-fpm",
                 "target-pitch-deg", "target-fpa-deg", "target-altitude-ft",
                 "target-agl-ft", "target-speed-kt", "target-speed-mach"]) {

    if ((var n = apset.getNode(p)) == nil or n.getType() == "NONE") {
        apset.getNode(p, 1).setDoubleValue(0);
    }
}

# - first entry ("heading" etc.) is the target property in /autopilot/locks/ *and*
#   the checkbox state property name (with "-active" appended);
# - second entry is a list of available options for the /autopilot/locks/* property
#   and used as radio button state property; the first list entry is used as default
#
var hdg = Group.new("heading",  ["dg-heading-hold", "wing-leveler", "true-heading-hold", "nav1-hold"]);
var vel = Group.new("speed",    ["speed-with-throttle-mach"]);
var alt = Group.new("altitude", ["altitude-hold", "vertical-speed-hold", "pitch-hold",
                                 "fpa-hold", "agl-hold", "gs1-hold"]);

# Utilities

var is_numeric = func(str) {  # Returns if inputted string in numeric
    if (typeof(str) == "scalar") return 1;
    if (typeof(str) != "string") return 0;

    var num = str2num(str);

    return typeof(num) == "scalar" and num == num;
};

var remove_chr = func(chr, str) {  # Remove every "x" character from a string in python
    var result = "";
    for (var i = 0; i < size(str); i += 1) {
        var ch = substr(str, i, 1);
        if (ch != chr) {
            result = result~ch;  # Append character if it's not "<chr>"
        }
    }
    return result;
};


update_loop_func = func() {
    
    # We make sure we don't run none of that if the UFC screen's offline
    if (getprop("fdm/jsbsim/systems/electrics/ac-left-main-bus") > 5 and getprop("sim/model/f15/avionics/bit-done")) {
    
        # Display what we gotta display depending on the current menu
        if (curr_menu == dft_menu) {
            UFCCanvas.UFCText.setText("                              ");
        } elsif (curr_menu == autopilot_main_menu) {
            UFCCanvas.UFCText.setText("1.INFO 2.HDG M 3.PTCH M 4.THRT");
            
            # Handle autopilot main menu buttons
            if (displays.a_1_pres == 1) {  # Take us to INFO autopilot menu
                curr_menu = autopilot_info_menu;
                displays.a_1_pres = 0;
            } elsif (displays.n_2_pres == 1) {  # Take us to autopilot HEADING CONTROL menu
                curr_menu = autopilot_heading_menu;
                displays.n_2_pres = 0;
            } elsif (displays.b_3_pres == 1) {  # Take us to autopilot HEADING CONTROL menu
                curr_menu = autopilot_altitude_menu;
                displays.b_3_pres = 0;
            } elsif (displays.w_4_pres == 1) {  # Take us to autopilot HEADING CONTROL menu
                curr_menu = autopilot_auto_throttle_menu;
                displays.w_4_pres = 0;
            }
        } elsif (curr_menu == autopilot_info_menu) {
            heading_text = "True H XXX";
            if (!getprop("sim/gui/dialogs/autopilot/heading-active")) {
                heading_text = "Heading OFF";
            } elsif (getprop("sim/gui/dialogs/autopilot/wing-leveler")) {
                heading_text = "Wings Level";
            } elsif (getprop("sim/gui/dialogs/autopilot/dg-heading-hold")) {
                heading_text = sprintf("Bug Hdg %03d", getprop("autopilot/settings/heading-bug-deg"));
            } elsif (getprop("sim/gui/dialogs/autopilot/true-heading-hold")) {
                heading_text = sprintf("Tru Hdg %03d", getprop("autopilot/settings/true-heading-deg"));
            } elsif (getprop("sim/gui/dialogs/autopilot/nav1-hold")) {
                heading_text = " Nav1 CDI ";
            }
            
            altitude_text = "Alt H XXXXX";
            if (!getprop("sim/gui/dialogs/autopilot/altitude-active")) {
                altitude_text = " Alt Md OFF";
            } elsif (getprop("sim/gui/dialogs/autopilot/vertical-speed-hold")) {
                altitude_text = sprintf("FPM H %05d", getprop("autopilot/settings/vertical-speed-fpm"));
            } elsif (getprop("sim/gui/dialogs/autopilot/pitch-hold")) {
                altitude_text = sprintf("Ptch Hld %02d", getprop("autopilot/settings/target-pitch-deg"));
            } elsif (getprop("sim/gui/dialogs/autopilot/altitude-hold")) {
                altitude_text = sprintf("Alt H %05d", getprop("autopilot/settings/target-altitude-ft"));
            } elsif (getprop("sim/gui/dialogs/autopilot/gs1-hold")) {
                altitude_text = " Nav 1 Glide";
            } elsif (getprop("sim/gui/dialogs/autopilot/fpa-hold")) {
                altitude_text = sprintf(" FPA Hld %02d", getprop("autopilot/settings/target-fpa-deg"));
            }
        
            throttle_text = sprintf("Ma %1.2f", getprop("autopilot/settings/target-speed-mach"));
            auto_throttle_on = getprop("sim/gui/dialogs/autopilot/speed-active");
            if (!auto_throttle_on) {
                throttle_text = "Ma OFF";
            }
            UFCCanvas.UFCText.setText(sprintf("%s %s %s", heading_text, altitude_text, throttle_text));
        } elsif (curr_menu == autopilot_heading_menu) {
            heading_text = "True H XXX";
            if (!getprop("sim/gui/dialogs/autopilot/heading-active")) {
                heading_text = "Hdg Off 1.Lvl 2.Bug 3.Tru 4.Nav";
                if (displays.a_1_pres == 1 and !inputting) {  # Handle mode changes
                    hdg.set("wing-leveler");
                    displays.a_1_pres = 0;
                    setprop("sim/gui/dialogs/autopilot/heading-active", 1);
                    hdg.enable();  # Enable heading control
                } elsif (displays.n_2_pres == 1) {
                    hdg.set("dg-heading-hold");
                    displays.n_2_pres = 0;
                    setprop("sim/gui/dialogs/autopilot/heading-active", 1);
                    hdg.enable();  # Enable heading control
                } elsif (displays.b_3_pres == 1) {
                    hdg.set("true-heading-hold");
                    displays.b_3_pres = 0;
                    setprop("sim/gui/dialogs/autopilot/heading-active", 1);
                    hdg.enable();  # Enable heading control
                } elsif (displays.w_4_pres == 1) {
                    hdg.set("nav1-hold");
                    displays.w_4_pres = 0;
                    setprop("sim/gui/dialogs/autopilot/heading-active", 1);
                    hdg.enable();  # Enable heading control
                }
            } elsif (getprop("sim/gui/dialogs/autopilot/wing-leveler")) {
                heading_text = "Wings Level 1.Bug 2.True 3.Nav";
                if (displays.a_1_pres == 1) {  # Handle mode changes
                    hdg.set("dg-heading-hold");
                    displays.a_1_pres = 0;
                } elsif (displays.n_2_pres == 1) {
                    hdg.set("true-heading-hold");
                    displays.n_2_pres = 0;
                } elsif (displays.b_3_pres == 1) {
                    hdg.set("nav1-hold");
                    displays.b_3_pres = 0;
                }
            } elsif (getprop("sim/gui/dialogs/autopilot/dg-heading-hold")) {
                heading_text = sprintf("Bug H %03d 1.Level 2.True 3.Nav", getprop("autopilot/settings/heading-bug-deg"));

                if (displays.data_pres == 1) {  # Pilot's initiating data heading inputting
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 1;
                    displays.data_pres = 0;
                } elsif (displays.mrk_pres == 1) {  # Pilot's confirming data heading inputting
                
                    # We check if the stored input is correct
                    # - is a number
                    # - is between 0 and 360
                    
                    if (!is_numeric(stored_input) or !((stored_input + 0) >= 0 and (stored_input + 0) <= 360)) {  # (stored_input + 0) forces Nasal to treat stored_input as a float and not a string anymore
                        displays.bad_data = 1;  # Trigger the "BAD DATA" label display
                    } else {  # It's all good, we can apply the inputted data to the sim property
                        setprop("autopilot/settings/heading-bug-deg", stored_input + 0);
                    }
                
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 0;
                    displays.mrk_pres = 0;
                } elsif (displays.a_1_pres == 1 and !inputting) {  # Handle mode changes
                    hdg.set("wing-leveler");
                    displays.a_1_pres = 0;
                } elsif (displays.n_2_pres == 1 and !inputting) {
                    hdg.set("true-heading-hold");
                    displays.n_2_pres = 0;
                } elsif (displays.b_3_pres == 1 and !inputting) {
                    hdg.set("nav1-hold");
                    displays.b_3_pres = 0;
                }
                
                
                if (inputting and size(stored_input) < 3) {  # Max amount of data that can be inputted
                    if (displays.a_1_pres == 1) {
                        stored_input = stored_input~"1";
                        displays.a_1_pres = 0;
                    } elsif (displays.n_2_pres == 1) {
                        stored_input = stored_input~"2";
                        displays.n_2_pres = 0;
                    } elsif (displays.b_3_pres == 1) {
                        stored_input = stored_input~"3";
                        displays.b_3_pres = 0;
                    } elsif (displays.w_4_pres == 1) {
                        stored_input = stored_input~"4";
                        displays.w_4_pres = 0;
                    } elsif (displays.m_5_pres == 1) {
                        stored_input = stored_input~"5";
                        displays.m_5_pres = 0;
                    } elsif (displays.e_6_pres == 1) {
                        stored_input = stored_input~"6";
                        displays.e_6_pres = 0;
                    } elsif (displays.i_7_pres == 1) {
                        stored_input = stored_input~"7";
                        displays.i_7_pres = 0;
                    } elsif (displays.s_8_pres == 1) {
                        stored_input = stored_input~"8";
                        displays.s_8_pres = 0;
                    } elsif (displays.c_9_pres == 1) {
                        stored_input = stored_input~"9";
                        displays.c_9_pres = 0;
                    } elsif (displays.hyphen_0_pres == 1) {
                        stored_input = stored_input~"0";
                        displays.hyphen_0_pres = 0;
                    }
                }
                
            } elsif (getprop("sim/gui/dialogs/autopilot/true-heading-hold")) {
                heading_text = sprintf("True H %03d 1.Level 2.Bug 3.Nav", getprop("autopilot/settings/true-heading-deg"));
                if (displays.data_pres == 1) {  # Pilot's initiating data heading inputting
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 1;
                    displays.data_pres = 0;
                } elsif (displays.mrk_pres == 1) {  # Pilot's confirming data heading inputting
                
                    # We check if the stored input is correct
                    # - is a number
                    # - is between 0 and 360
                    
                    if (!is_numeric(stored_input) or !((stored_input + 0) >= 0 and (stored_input + 0) <= 360)) {  # (stored_input + 0) forces Nasal to treat stored_input as a float and not a string anymore
                        displays.bad_data = 1;  # Trigger the "BAD DATA" label display
                    } else {  # It's all good, we can apply the inputted data to the sim property
                        setprop("autopilot/settings/true-heading-deg", stored_input + 0);
                    }
                
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 0;
                    displays.mrk_pres = 0;
                } elsif (displays.a_1_pres == 1 and !inputting) {  # Handle mode changes
                    hdg.set("wing-leveler");
                    displays.a_1_pres = 0;
                } elsif (displays.n_2_pres == 1 and !inputting) {
                    hdg.set("dg-heading-hold");
                    displays.n_2_pres = 0;
                } elsif (displays.b_3_pres == 1 and !inputting) {
                    hdg.set("nav1-hold");
                    displays.b_3_pres = 0;
                }
                
                
                if (inputting and size(stored_input) < 3) {  # Max amount of data that can be inputted
                    if (displays.a_1_pres == 1) {
                        stored_input = stored_input~"1";
                        displays.a_1_pres = 0;
                    } elsif (displays.n_2_pres == 1) {
                        stored_input = stored_input~"2";
                        displays.n_2_pres = 0;
                    } elsif (displays.b_3_pres == 1) {
                        stored_input = stored_input~"3";
                        displays.b_3_pres = 0;
                    } elsif (displays.w_4_pres == 1) {
                        stored_input = stored_input~"4";
                        displays.w_4_pres = 0;
                    } elsif (displays.m_5_pres == 1) {
                        stored_input = stored_input~"5";
                        displays.m_5_pres = 0;
                    } elsif (displays.e_6_pres == 1) {
                        stored_input = stored_input~"6";
                        displays.e_6_pres = 0;
                    } elsif (displays.i_7_pres == 1) {
                        stored_input = stored_input~"7";
                        displays.i_7_pres = 0;
                    } elsif (displays.s_8_pres == 1) {
                        stored_input = stored_input~"8";
                        displays.s_8_pres = 0;
                    } elsif (displays.c_9_pres == 1) {
                        stored_input = stored_input~"9";
                        displays.c_9_pres = 0;
                    } elsif (displays.hyphen_0_pres == 1) {
                        stored_input = stored_input~"0";
                        displays.hyphen_0_pres = 0;
                    }
                }
            } elsif (getprop("sim/gui/dialogs/autopilot/nav1-hold")) {
                heading_text = " Nav1 CDI 1.Level 2.Bug 3.True";
                
                if (displays.a_1_pres == 1) {  # Handle mode changes
                    hdg.set("wing-leveler");
                    displays.a_1_pres = 0;
                } elsif (displays.n_2_pres == 1) {
                    hdg.set("dg-heading-hold");
                    displays.n_2_pres = 0;
                } elsif (displays.b_3_pres == 1) {
                    hdg.set("true-heading-hold");
                    displays.b_3_pres = 0;
                }
            }
            UFCCanvas.UFCText.setText(heading_text);
        } elsif (curr_menu == autopilot_altitude_menu) {
            altitude_text = "";
            if (!getprop("sim/gui/dialogs/autopilot/altitude-active")) {
                altitude_text = "Alt OFF 1.Alt H 2.Ptch H 3.Nxt";
                
                if (displays.a_1_pres == 1 and !inputting) {  # Handle mode changes
                    setprop("sim/gui/dialogs/autopilot/heading-active", 1);
                    alt.enable();  # Turn on altitude mode
                    alt.set("altitude-hold");
                    displays.a_1_pres = 0;
                } elsif (displays.n_2_pres == 1 and !inputting) {
                    setprop("sim/gui/dialogs/autopilot/heading-active", 1);
                    alt.enable();  # Turn on altitude mode
                    alt.set("pitch-hold");
                    displays.n_2_pres = 0;
                } elsif (displays.b_3_pres == 1 and !inputting) {
                    setprop("sim/gui/dialogs/autopilot/heading-active", 1);
                    alt.enable();  # Turn on altitude mode
                    curr_menu = autopilot_altitude_menu_sec;
                    displays.b_3_pres = 0;
                }
            } elsif (getprop("sim/gui/dialogs/autopilot/altitude-hold")) {
                altitude_text = sprintf("Alt %05d 1.Ptch H 2.FPA 3.Nxt", getprop("autopilot/settings/target-altitude-ft"));
                
                if (displays.data_pres == 1) {  # Pilot's initiating data heading inputting
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 1;
                    displays.data_pres = 0;
                } elsif (displays.mrk_pres == 1) {  # Pilot's confirming data heading inputting
                
                    # We check if the stored input is correct
                    # - is a number
                    
                    if (!is_numeric(stored_input)) {  # (stored_input + 0) forces Nasal to treat stored_input as a float and not a string anymore
                        displays.bad_data = 1;  # Trigger the "BAD DATA" label display
                    } else {  # It's all good, we can apply the inputted data to the sim property
                        setprop("autopilot/settings/target-altitude-ft", stored_input + 0);
                    }
                
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 0;
                    displays.mrk_pres = 0;
                } elsif (displays.a_1_pres == 1 and !inputting) {  # Handle mode changes
                    alt.set("pitch-hold");
                    displays.a_1_pres = 0;
                } elsif (displays.n_2_pres == 1 and !inputting) {
                    alt.set("fpa-hold");
                    displays.n_2_pres = 0;
                } elsif (displays.b_3_pres == 1 and !inputting) {
                    curr_menu = autopilot_altitude_menu_sec;
                    displays.b_3_pres = 0;
                }
                
                if (inputting and size(stored_input) < 5) {  # Max amount of data that can be inputted
                    if (displays.a_1_pres == 1) {
                        stored_input = stored_input~"1";
                        displays.a_1_pres = 0;
                    } elsif (displays.n_2_pres == 1) {
                        stored_input = stored_input~"2";
                        displays.n_2_pres = 0;
                    } elsif (displays.b_3_pres == 1) {
                        stored_input = stored_input~"3";
                        displays.b_3_pres = 0;
                    } elsif (displays.w_4_pres == 1) {
                        stored_input = stored_input~"4";
                        displays.w_4_pres = 0;
                    } elsif (displays.m_5_pres == 1) {
                        stored_input = stored_input~"5";
                        displays.m_5_pres = 0;
                    } elsif (displays.e_6_pres == 1) {
                        stored_input = stored_input~"6";
                        displays.e_6_pres = 0;
                    } elsif (displays.i_7_pres == 1) {
                        stored_input = stored_input~"7";
                        displays.i_7_pres = 0;
                    } elsif (displays.s_8_pres == 1) {
                        stored_input = stored_input~"8";
                        displays.s_8_pres = 0;
                    } elsif (displays.c_9_pres == 1) {
                        stored_input = stored_input~"9";
                        displays.c_9_pres = 0;
                    } elsif (displays.hyphen_0_pres == 1) {
                        stored_input = stored_input~"0";
                        displays.hyphen_0_pres = 0;
                    }
                }
            } elsif (getprop("sim/gui/dialogs/autopilot/pitch-hold")) {
                altitude_text = sprintf(" Ptch %02d 1.Alt H 2.FPA H 3.Nxt", getprop("autopilot/settings/target-pitch-deg"));
                
                if (displays.data_pres == 1) {  # Pilot's initiating data heading inputting
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 1;
                    displays.data_pres = 0;
                } elsif (displays.mrk_pres == 1) {  # Pilot's confirming data heading inputting
                
                    # We check if the stored input is correct
                    # - is a number
                    # - between -90 and 90
                    
                    if (!is_numeric(stored_input) or !(stored_input >= -90 and stored_input <= 90)) {  # (stored_input + 0) forces Nasal to treat stored_input as a float and not a string anymore
                        displays.bad_data = 1;  # Trigger the "BAD DATA" label display
                    } else {  # It's all good, we can apply the inputted data to the sim property
                        setprop("autopilot/settings/target-pitch-deg", stored_input + 0);
                    }
                
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 0;
                    displays.mrk_pres = 0;
                } elsif (displays.a_1_pres == 1 and !inputting) {  # Handle mode changes
                    alt.set("altitude-hold");
                    displays.a_1_pres = 0;
                } elsif (displays.n_2_pres == 1 and !inputting) {
                    alt.set("fpa-hold");
                    displays.n_2_pres = 0;
                } elsif (displays.b_3_pres == 1 and !inputting) {
                    curr_menu = autopilot_altitude_menu_sec;
                    displays.b_3_pres = 0;
                }
                
                if (size(remove_chr("-", stored_input)) < 2 and inputting) {  # Max amount of data that can be inputted. math.abs cause the negative don't count
                    if (displays.a_1_pres == 1) {
                        stored_input = stored_input~"1";
                        displays.a_1_pres = 0;
                    } elsif (displays.n_2_pres == 1) {
                        stored_input = stored_input~"2";
                        displays.n_2_pres = 0;
                    } elsif (displays.b_3_pres == 1) {
                        stored_input = stored_input~"3";
                        displays.b_3_pres = 0;
                    } elsif (displays.w_4_pres == 1) {
                        stored_input = stored_input~"4";
                        displays.w_4_pres = 0;
                    } elsif (displays.m_5_pres == 1) {
                        stored_input = stored_input~"5";
                        displays.m_5_pres = 0;
                    } elsif (displays.e_6_pres == 1) {
                        stored_input = stored_input~"6";
                        displays.e_6_pres = 0;
                    } elsif (displays.i_7_pres == 1) {
                        stored_input = stored_input~"7";
                        displays.i_7_pres = 0;
                    } elsif (displays.s_8_pres == 1) {
                        stored_input = stored_input~"8";
                        displays.s_8_pres = 0;
                    } elsif (displays.c_9_pres == 1) {
                        stored_input = stored_input~"9";
                        displays.c_9_pres = 0;
                    } elsif (displays.hyphen_0_pres == 1 and displays.shf_pres and size(stored_input) < 1) {
                        stored_input = stored_input~"-";
                        displays.hyphen_0_pres = 0;
                        displays.shf_pres = 0;
                    } elsif (displays.hyphen_0_pres == 1 and !displays.shf_pres) {
                        stored_input = stored_input~"0";
                        displays.hyphen_0_pres = 0;
                    }
                }
            } elsif (getprop("sim/gui/dialogs/autopilot/fpa-hold")) {
                altitude_text = sprintf("FPA %02d 1.Alt H 2.Ptch H 3.Nxt", getprop("autopilot/settings/target-fpa-deg"));
                
                if (displays.data_pres == 1) {  # Pilot's initiating data heading inputting
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 1;
                    displays.data_pres = 0;
                } elsif (displays.mrk_pres == 1) {  # Pilot's confirming data heading inputting
                
                    # We check if the stored input is correct
                    # - is a number
                    # - between -90 and 90
                    
                    if (!is_numeric(stored_input) or !(stored_input <= 90 and stored_input >= -90)) {  # (stored_input + 0) forces Nasal to treat stored_input as a float and not a string anymore
                        displays.bad_data = 1;  # Trigger the "BAD DATA" label display
                    } else {  # It's all good, we can apply the inputted data to the sim property
                        setprop("autopilot/settings/target-fpa-deg", stored_input + 0);
                    }
                
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 0;
                    displays.mrk_pres = 0;
                } elsif (displays.a_1_pres == 1 and !inputting) {  # Handle mode changes
                    alt.set("altitude-hold");
                    displays.a_1_pres = 0;
                } elsif (displays.n_2_pres == 1 and !inputting) {
                    alt.set("pitch-hold");
                    displays.n_2_pres = 0;
                } elsif (displays.b_3_pres == 1 and !inputting) {
                    curr_menu = autopilot_altitude_menu_sec;
                    displays.b_3_pres = 0;
                }
                
                if (size(remove_chr("-", stored_input)) < 2 and inputting) {  # Max amount of data that can be inputted. math.abs cause the negative don't count
                    if (displays.a_1_pres == 1) {
                        stored_input = stored_input~"1";
                        displays.a_1_pres = 0;
                    } elsif (displays.n_2_pres == 1) {
                        stored_input = stored_input~"2";
                        displays.n_2_pres = 0;
                    } elsif (displays.b_3_pres == 1) {
                        stored_input = stored_input~"3";
                        displays.b_3_pres = 0;
                    } elsif (displays.w_4_pres == 1) {
                        stored_input = stored_input~"4";
                        displays.w_4_pres = 0;
                    } elsif (displays.m_5_pres == 1) {
                        stored_input = stored_input~"5";
                        displays.m_5_pres = 0;
                    } elsif (displays.e_6_pres == 1) {
                        stored_input = stored_input~"6";
                        displays.e_6_pres = 0;
                    } elsif (displays.i_7_pres == 1) {
                        stored_input = stored_input~"7";
                        displays.i_7_pres = 0;
                    } elsif (displays.s_8_pres == 1) {
                        stored_input = stored_input~"8";
                        displays.s_8_pres = 0;
                    } elsif (displays.c_9_pres == 1) {
                        stored_input = stored_input~"9";
                        displays.c_9_pres = 0;
                    } elsif (displays.hyphen_0_pres == 1 and displays.shf_pres and size(stored_input) < 1) {
                        stored_input = stored_input~"-";
                        displays.hyphen_0_pres = 0;
                        displays.shf_pres = 0;
                    } elsif (displays.hyphen_0_pres == 1 and !displays.shf_pres) {
                        stored_input = stored_input~"0";
                        displays.hyphen_0_pres = 0;
                    }
                }
            } elsif (getprop("sim/gui/dialogs/autopilot/vertical-speed-hold")) {
                altitude_text = sprintf("FPM %05d 1.Alt H 2.Ptch 3.Nxt", getprop("autopilot/settings/vertical-speed-fpm"));
                
                if (displays.data_pres == 1) {  # Pilot's initiating data heading inputting
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 1;
                    displays.data_pres = 0;
                } elsif (displays.mrk_pres == 1) {  # Pilot's confirming data heading inputting
                
                    # We check if the stored input is correct
                    # - is a number
                    
                    if (!is_numeric(stored_input)) {  # (stored_input + 0) forces Nasal to treat stored_input as a float and not a string anymore
                        displays.bad_data = 1;  # Trigger the "BAD DATA" label display
                    } else {  # It's all good, we can apply the inputted data to the sim property
                        setprop("autopilot/settings/vertical-speed-fpm", stored_input + 0);
                    }
                
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 0;
                    displays.mrk_pres = 0;
                } elsif (displays.a_1_pres == 1 and !inputting) {  # Handle mode changes
                    alt.set("altitude-hold");
                    displays.a_1_pres = 0;
                } elsif (displays.n_2_pres == 1 and !inputting) {
                    alt.set("pitch-hold");
                    displays.n_2_pres = 0;
                } elsif (displays.b_3_pres == 1 and !inputting) {
                    curr_menu = autopilot_altitude_menu_sec;
                    displays.b_3_pres = 0;
                }
                
                if (size(remove_chr("-", stored_input)) < 5 and inputting) {  # Max amount of data that can be inputted. math.abs cause the negative don't count
                    if (displays.a_1_pres == 1) {
                        stored_input = stored_input~"1";
                        displays.a_1_pres = 0;
                    } elsif (displays.n_2_pres == 1) {
                        stored_input = stored_input~"2";
                        displays.n_2_pres = 0;
                    } elsif (displays.b_3_pres == 1) {
                        stored_input = stored_input~"3";
                        displays.b_3_pres = 0;
                    } elsif (displays.w_4_pres == 1) {
                        stored_input = stored_input~"4";
                        displays.w_4_pres = 0;
                    } elsif (displays.m_5_pres == 1) {
                        stored_input = stored_input~"5";
                        displays.m_5_pres = 0;
                    } elsif (displays.e_6_pres == 1) {
                        stored_input = stored_input~"6";
                        displays.e_6_pres = 0;
                    } elsif (displays.i_7_pres == 1) {
                        stored_input = stored_input~"7";
                        displays.i_7_pres = 0;
                    } elsif (displays.s_8_pres == 1) {
                        stored_input = stored_input~"8";
                        displays.s_8_pres = 0;
                    } elsif (displays.c_9_pres == 1) {
                        stored_input = stored_input~"9";
                        displays.c_9_pres = 0;
                    } elsif (displays.hyphen_0_pres == 1 and displays.shf_pres and size(stored_input) < 1) {
                        stored_input = stored_input~"-";
                        displays.hyphen_0_pres = 0;
                        displays.shf_pres = 0;
                    } elsif (displays.hyphen_0_pres == 1 and !displays.shf_pres) {
                        stored_input = stored_input~"0";
                        displays.hyphen_0_pres = 0;
                    }
                }
            }

            UFCCanvas.UFCText.setText(altitude_text);
        } elsif (curr_menu == autopilot_altitude_menu_sec) {
            altitude_text = "";
            if (!getprop("sim/gui/dialogs/autopilot/altitude-active")) {
                altitude_text = "   Alt OFF 1.FPA Hld 2.FPM Hld";
                
                if (displays.a_1_pres == 1 and !inputting) {  # Handle mode changes
                    alt.set("fpa-hold");
                    setprop("sim/gui/dialogs/autopilot/heading-active", 1);
                    alt.enable();  # Turn on altitude mode
                    curr_menu = autopilot_altitude_menu;
                    displays.a_1_pres = 0;
                } elsif (displays.n_2_pres == 1 and !inputting) {
                    setprop("sim/gui/dialogs/autopilot/heading-active", 1);
                    alt.enable();  # Turn on altitude mode
                    alt.set("vertical-speed-hold");
                    curr_menu = autopilot_altitude_menu;
                    displays.n_2_pres = 0;
                }
            } elsif (getprop("sim/gui/dialogs/autopilot/altitude-hold")) {
                altitude_text = sprintf("           Alt %05d 1.FPM Hld", getprop("autopilot/settings/target-altitude-ft"));
                
                if (displays.data_pres == 1) {  # Pilot's initiating data heading inputting
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 1;
                    displays.data_pres = 0;
                } elsif (displays.mrk_pres == 1) {  # Pilot's confirming data heading inputting
                
                    # We check if the stored input is correct
                    # - is a number
                    
                    if (!is_numeric(stored_input)) {  # (stored_input + 0) forces Nasal to treat stored_input as a float and not a string anymore
                        displays.bad_data = 1;  # Trigger the "BAD DATA" label display
                    } else {  # It's all good, we can apply the inputted data to the sim property
                        setprop("autopilot/settings/target-altitude-ft", stored_input + 0);
                    }
                
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 0;
                    displays.mrk_pres = 0;
                } elsif (displays.a_1_pres == 1 and !inputting) {  # Handle mode changes
                    alt.set("vertical-speed-hold");
                    curr_menu = autopilot_altitude_menu;
                    displays.a_1_pres = 0;
                }
                
                if (inputting and size(stored_input) < 5) {  # Max amount of data that can be inputted
                    if (displays.a_1_pres == 1) {
                        stored_input = stored_input~"1";
                        displays.a_1_pres = 0;
                    } elsif (displays.n_2_pres == 1) {
                        stored_input = stored_input~"2";
                        displays.n_2_pres = 0;
                    } elsif (displays.b_3_pres == 1) {
                        stored_input = stored_input~"3";
                        displays.b_3_pres = 0;
                    } elsif (displays.w_4_pres == 1) {
                        stored_input = stored_input~"4";
                        displays.w_4_pres = 0;
                    } elsif (displays.m_5_pres == 1) {
                        stored_input = stored_input~"5";
                        displays.m_5_pres = 0;
                    } elsif (displays.e_6_pres == 1) {
                        stored_input = stored_input~"6";
                        displays.e_6_pres = 0;
                    } elsif (displays.i_7_pres == 1) {
                        stored_input = stored_input~"7";
                        displays.i_7_pres = 0;
                    } elsif (displays.s_8_pres == 1) {
                        stored_input = stored_input~"8";
                        displays.s_8_pres = 0;
                    } elsif (displays.c_9_pres == 1) {
                        stored_input = stored_input~"9";
                        displays.c_9_pres = 0;
                    } elsif (displays.hyphen_0_pres == 1) {
                        stored_input = stored_input~"0";
                        displays.hyphen_0_pres = 0;
                    }
                }
            } elsif (getprop("sim/gui/dialogs/autopilot/pitch-hold")) {
                altitude_text = sprintf("             Ptch %02d 1.FPM Hld", getprop("autopilot/settings/target-pitch-deg"));
                
                if (displays.data_pres == 1) {  # Pilot's initiating data heading inputting
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 1;
                    displays.data_pres = 0;
                } elsif (displays.mrk_pres == 1) {  # Pilot's confirming data heading inputting
                
                    # We check if the stored input is correct
                    # - is a number
                    # - between -90 and 90
                    
                    if (!is_numeric(stored_input) or !(stored_input >= 90 and stored_input <= 90)) {  # (stored_input + 0) forces Nasal to treat stored_input as a float and not a string anymore
                        displays.bad_data = 1;  # Trigger the "BAD DATA" label display
                    } else {  # It's all good, we can apply the inputted data to the sim property
                        setprop("autopilot/settings/target-pitch-deg", stored_input + 0);
                    }
                
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 0;
                    displays.mrk_pres = 0;
                } elsif (displays.a_1_pres == 1 and !inputting) {  # Handle mode changes
                    alt.set("vertical-speed-hold");
                    curr_menu = autopilot_altitude_menu;
                    displays.a_1_pres = 0;
                }
                
                if (size(remove_chr("-", stored_input)) < 2 and inputting) {  # Max amount of data that can be inputted. math.abs cause the negative don't count
                    if (displays.a_1_pres == 1) {
                        stored_input = stored_input~"1";
                        displays.a_1_pres = 0;
                    } elsif (displays.n_2_pres == 1) {
                        stored_input = stored_input~"2";
                        displays.n_2_pres = 0;
                    } elsif (displays.b_3_pres == 1) {
                        stored_input = stored_input~"3";
                        displays.b_3_pres = 0;
                    } elsif (displays.w_4_pres == 1) {
                        stored_input = stored_input~"4";
                        displays.w_4_pres = 0;
                    } elsif (displays.m_5_pres == 1) {
                        stored_input = stored_input~"5";
                        displays.m_5_pres = 0;
                    } elsif (displays.e_6_pres == 1) {
                        stored_input = stored_input~"6";
                        displays.e_6_pres = 0;
                    } elsif (displays.i_7_pres == 1) {
                        stored_input = stored_input~"7";
                        displays.i_7_pres = 0;
                    } elsif (displays.s_8_pres == 1) {
                        stored_input = stored_input~"8";
                        displays.s_8_pres = 0;
                    } elsif (displays.c_9_pres == 1) {
                        stored_input = stored_input~"9";
                        displays.c_9_pres = 0;
                    } elsif (displays.hyphen_0_pres == 1 and displays.shf_pres and size(stored_input) < 1) {
                        stored_input = stored_input~"-";
                        displays.hyphen_0_pres = 0;
                        displays.shf_pres = 0;
                    } elsif (displays.hyphen_0_pres == 1 and !displays.shf_pres) {
                        stored_input = stored_input~"0";
                        displays.hyphen_0_pres = 0;
                    }
                }
            } elsif (getprop("sim/gui/dialogs/autopilot/fpa-hold")) {
                altitude_text = sprintf("             FPA %02d 1.FPM Hld", getprop("autopilot/settings/target-fpa-deg"));
                
                if (displays.data_pres == 1) {  # Pilot's initiating data heading inputting
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 1;
                    displays.data_pres = 0;
                } elsif (displays.mrk_pres == 1) {  # Pilot's confirming data heading inputting
                
                    # We check if the stored input is correct
                    # - is a number
                    # - between -90 and 90
                    
                    if (!is_numeric(stored_input) or !(stored_input <= 90 and stored_input >= -90)) {  # (stored_input + 0) forces Nasal to treat stored_input as a float and not a string anymore
                        displays.bad_data = 1;  # Trigger the "BAD DATA" label display
                    } else {  # It's all good, we can apply the inputted data to the sim property
                        setprop("autopilot/settings/target-fpa-deg", stored_input + 0);
                    }
                
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 0;
                    displays.mrk_pres = 0;
                } elsif (displays.a_1_pres == 1 and !inputting) {  # Handle mode changes
                    alt.set("fpa-hold");
                    curr_menu = autopilot_altitude_menu;
                    displays.a_1_pres = 0;
                }
                
                if (size(remove_chr("-", stored_input)) < 2 and inputting) {  # Max amount of data that can be inputted. math.abs cause the negative don't count
                    if (displays.a_1_pres == 1) {
                        stored_input = stored_input~"1";
                        displays.a_1_pres = 0;
                    } elsif (displays.n_2_pres == 1) {
                        stored_input = stored_input~"2";
                        displays.n_2_pres = 0;
                    } elsif (displays.b_3_pres == 1) {
                        stored_input = stored_input~"3";
                        displays.b_3_pres = 0;
                    } elsif (displays.w_4_pres == 1) {
                        stored_input = stored_input~"4";
                        displays.w_4_pres = 0;
                    } elsif (displays.m_5_pres == 1) {
                        stored_input = stored_input~"5";
                        displays.m_5_pres = 0;
                    } elsif (displays.e_6_pres == 1) {
                        stored_input = stored_input~"6";
                        displays.e_6_pres = 0;
                    } elsif (displays.i_7_pres == 1) {
                        stored_input = stored_input~"7";
                        displays.i_7_pres = 0;
                    } elsif (displays.s_8_pres == 1) {
                        stored_input = stored_input~"8";
                        displays.s_8_pres = 0;
                    } elsif (displays.c_9_pres == 1) {
                        stored_input = stored_input~"9";
                        displays.c_9_pres = 0;
                    } elsif (displays.hyphen_0_pres == 1 and displays.shf_pres and size(stored_input) < 1) {
                        stored_input = stored_input~"-";
                        displays.hyphen_0_pres = 0;
                        displays.shf_pres = 0;
                    } elsif (displays.hyphen_0_pres == 1 and !displays.shf_pres) {
                        stored_input = stored_input~"0";
                        displays.hyphen_0_pres = 0;
                    }
                }
            } elsif (getprop("sim/gui/dialogs/autopilot/vertical-speed-hold")) {
                altitude_text = sprintf("           FPM %05d 1.FPA Hld", getprop("autopilot/settings/vertical-speed-fpm"));
                
                if (displays.data_pres == 1) {  # Pilot's initiating data heading inputting
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 1;
                    displays.data_pres = 0;
                } elsif (displays.mrk_pres == 1) {  # Pilot's confirming data heading inputting
                
                    # We check if the stored input is correct
                    # - is a number
                    
                    if (!is_numeric(stored_input)) {  # (stored_input + 0) forces Nasal to treat stored_input as a float and not a string anymore
                        displays.bad_data = 1;  # Trigger the "BAD DATA" label display
                    } else {  # It's all good, we can apply the inputted data to the sim property
                        setprop("autopilot/settings/vertical-speed-fpm", stored_input + 0);
                    }
                
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 0;
                    displays.mrk_pres = 0;
                } elsif (displays.a_1_pres == 1 and !inputting) {  # Handle mode changes
                    alt.set("vertical-speed-hold");
                    curr_menu = autopilot_altitude_menu;
                    displays.a_1_pres = 0;
                }
                
                if (size(remove_chr("-", stored_input)) < 5 and inputting) {  # Max amount of data that can be inputted. math.abs cause the negative don't count
                    if (displays.a_1_pres == 1) {
                        stored_input = stored_input~"1";
                        displays.a_1_pres = 0;
                    } elsif (displays.n_2_pres == 1) {
                        stored_input = stored_input~"2";
                        displays.n_2_pres = 0;
                    } elsif (displays.b_3_pres == 1) {
                        stored_input = stored_input~"3";
                        displays.b_3_pres = 0;
                    } elsif (displays.w_4_pres == 1) {
                        stored_input = stored_input~"4";
                        displays.w_4_pres = 0;
                    } elsif (displays.m_5_pres == 1) {
                        stored_input = stored_input~"5";
                        displays.m_5_pres = 0;
                    } elsif (displays.e_6_pres == 1) {
                        stored_input = stored_input~"6";
                        displays.e_6_pres = 0;
                    } elsif (displays.i_7_pres == 1) {
                        stored_input = stored_input~"7";
                        displays.i_7_pres = 0;
                    } elsif (displays.s_8_pres == 1) {
                        stored_input = stored_input~"8";
                        displays.s_8_pres = 0;
                    } elsif (displays.c_9_pres == 1) {
                        stored_input = stored_input~"9";
                        displays.c_9_pres = 0;
                    } elsif (displays.hyphen_0_pres == 1 and displays.shf_pres and size(stored_input) < 1) {
                        stored_input = stored_input~"-";
                        displays.hyphen_0_pres = 0;
                        displays.shf_pres = 0;
                    } elsif (displays.hyphen_0_pres == 1 and !displays.shf_pres) {
                        stored_input = stored_input~"0";
                        displays.hyphen_0_pres = 0;
                    }
                }
            }
            
            UFCCanvas.UFCText.setText(altitude_text);
        } elsif (curr_menu == autopilot_auto_throttle_menu) {
            throttle_text = "";
            throttle_text = "                              ";
            
            if (!getprop("sim/gui/dialogs/autopilot/speed-active")) {
                throttle_text = "    Auto Throt. OFF 1.Activate";
                
                if (displays.a_1_pres == 1) {  # Turn ON auto throttle
                    setprop("sim/gui/dialogs/autopilot/speed-active", 1);
                    vel.enable();
                    vel.set("speed-with-throttle-mach");
                    displays.a_1_pres = 0;
                }
            } elsif (getprop("sim/gui/dialogs/autopilot/speed-active")) {
                aug_on_off_text = "";
                if (getprop("autopilot/locks/autothrottle-permit-augmentation")) {
                    aug_on_off_text = " ON";
                } else {
                    aug_on_off_text = "OFF";
                }
                
                if (displays.data_pres == 1) {  # Pilot's initiating data Mach inputting
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 1;
                    displays.data_pres = 0;
                } elsif (displays.mrk_pres == 1) {  # Pilot's confirming data Mach inputting
                
                    # We check if the stored input is correct
                    # - is a number
                    # - is positive  (not needed cause we don't allow the hyphen press here)
                    
                    if (!is_numeric(stored_input) or !(stored_input + 0) > 0) {  # (stored_input + 0) forces Nasal to treat stored_input as a float and not a string anymore
                        displays.bad_data = 1;  # Trigger the "BAD DATA" label display
                    } else {  # It's all good, we can apply the inputted data to the sim property
                        setprop("autopilot/settings/target-speed-mach", stored_input + 0);
                    }
                
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 0;
                    displays.mrk_pres = 0;
                } elsif (displays.a_1_pres == 1 and !inputting) {  # Toggle Augmentation use (afterburner)
                    setprop("autopilot/locks/autothrottle-permit-augmentation", !getprop("autopilot/locks/autothrottle-permit-augmentation"));
                    displays.a_1_pres = 0;
                }
                
                if (inputting and size(stored_input) < 4) {  # Max amount of data that can be inputted (one for unit, one for decimal dot, two for decimal values)
                    if (displays.a_1_pres == 1) {
                        stored_input = stored_input~"1";
                        displays.a_1_pres = 0;
                    } elsif (displays.n_2_pres == 1) {
                        stored_input = stored_input~"2";
                        displays.n_2_pres = 0;
                    } elsif (displays.b_3_pres == 1) {
                        stored_input = stored_input~"3";
                        displays.b_3_pres = 0;
                    } elsif (displays.w_4_pres == 1) {
                        stored_input = stored_input~"4";
                        displays.w_4_pres = 0;
                    } elsif (displays.m_5_pres == 1) {
                        stored_input = stored_input~"5";
                        displays.m_5_pres = 0;
                    } elsif (displays.e_6_pres == 1) {
                        stored_input = stored_input~"6";
                        displays.e_6_pres = 0;
                    } elsif (displays.i_7_pres == 1) {
                        stored_input = stored_input~"7";
                        displays.i_7_pres = 0;
                    } elsif (displays.s_8_pres == 1) {
                        stored_input = stored_input~"8";
                        displays.s_8_pres = 0;
                    } elsif (displays.c_9_pres == 1) {
                        stored_input = stored_input~"9";
                        displays.c_9_pres = 0;
                    } elsif (displays.hyphen_0_pres == 1) {
                        stored_input = stored_input~"0";
                        displays.hyphen_0_pres = 0;
                    } elsif (displays.decimal_pres == 1) {
                        stored_input = stored_input~".";
                        displays.decimal_pres = 0;
                    }
                }
                
                throttle_text = sprintf("Ma. %1.2f, Aug %s 1.Toggle Aug", getprop("autopilot/settings/target-speed-mach"), aug_on_off_text);
            }
        
            UFCCanvas.UFCText.setText(throttle_text);
        } elsif (curr_menu == nav1_main_menu) {
            ils_text = "1.INFO 2.CHANS 3.RADIA 4.MODE";
            
            # Handle inputs
            if (displays.a_1_pres == 1 and !inputting) {
                curr_menu = nav1_menu_info;
                displays.a_1_pres = 0;
            } elsif (displays.n_2_pres == 1 and !inputting) {
                curr_menu = nav_1_chans_menu;
                nav_1_chans_index = 0;
                displays.n_2_pres = 0;
            } elsif (displays.b_3_pres == 1 and !inputting) {  # Radial input
                stored_input = "";  # We reset the stored input just in case
                inputting = 1;
                displays.b_3_pres = 0;
            } elsif (displays.w_4_pres == 1 and !inputting) {  # Radial input
                curr_menu = nav_1_mode_menu;
                displays.w_4_pres = 0;
            } elsif (displays.mrk_pres == 1 and inputting) {  # Pilot's confirming data Mach inputting
                
                # We check if the stored input is correct
                # - is a number
                # - is between 0 and 360
                    
                if (!is_numeric(stored_input) or !(stored_input >= 0 and stored_input <= 360)) {  # (stored_input + 0) forces Nasal to treat stored_input as a float and not a string anymore
                    displays.bad_data = 1;  # Trigger the "BAD DATA" label display
                } else {  # It's all good, we can apply the inputted data to the sim property
                    setprop("instrumentation/nav[0]/radials/selected-deg", stored_input + 0);
                }
                
                stored_input = "";  # We reset the stored input just in case
                inputting = 0;
                displays.mrk_pres = 0;
            }
            if (size(stored_input) < 3 and inputting) {  # Max amount of data that can be inputted
                if (displays.a_1_pres == 1) {
                    stored_input = stored_input~"1";
                    displays.a_1_pres = 0;
                } elsif (displays.n_2_pres == 1) {
                    stored_input = stored_input~"2";
                    displays.n_2_pres = 0;
                } elsif (displays.b_3_pres == 1) {
                    stored_input = stored_input~"3";
                    displays.b_3_pres = 0;
                } elsif (displays.w_4_pres == 1) {
                    stored_input = stored_input~"4";
                    displays.w_4_pres = 0;
                } elsif (displays.m_5_pres == 1) {
                    stored_input = stored_input~"5";
                    displays.m_5_pres = 0;
                } elsif (displays.e_6_pres == 1) {
                    stored_input = stored_input~"6";
                    displays.e_6_pres = 0;
                } elsif (displays.i_7_pres == 1) {
                    stored_input = stored_input~"7";
                    displays.i_7_pres = 0;
                } elsif (displays.s_8_pres == 1) {
                    stored_input = stored_input~"8";
                    displays.s_8_pres = 0;
                } elsif (displays.c_9_pres == 1) {
                    stored_input = stored_input~"9";
                    displays.c_9_pres = 0;
                } elsif (displays.hyphen_0_pres == 1) {
                    stored_input = stored_input~"0";
                    displays.hyphen_0_pres = 0;
                }
            }
        
            UFCCanvas.UFCText.setText(ils_text);
        } elsif (curr_menu == nav1_menu_info) {
            final_text = "";
            if (!getprop("instrumentation/nav[0]/in-range")) {
                final_text = "OUT RNG";
            } else {
                final_text = sprintf("%s %02d", getprop("instrumentation/nav[0]/nav-id"), getprop("instrumentation/nav[0]/nav-distance") * M2NM);
            }
            
            ils_text = sprintf("FREQ %3.2f RADIAL %03d %s", getprop("instrumentation/nav[0]/frequencies/selected-mhz"), getprop("instrumentation/nav[0]/radials/selected-deg"), final_text);
        
            UFCCanvas.UFCText.setText(ils_text);
        } elsif (curr_menu == nav_1_chans_menu) {
            
            if (nav_1_chans_index == 0) {  # Active frequency
                ils_text = sprintf("ACTIVE %3.2f MHz 1.Stby 2.Next", getprop("instrumentation/nav[0]/frequencies/selected-mhz"));
                if (displays.a_1_pres == 1 and !inputting) {  # Switch between active and standby
                    active_freq = getprop("instrumentation/nav[0]/frequencies/selected-mhz");
                    standby_freq = getprop("instrumentation/nav[0]/frequencies/standby-mhz");
                    setprop("instrumentation/nav[0]/frequencies/selected-mhz", standby_freq);
                    setprop("instrumentation/nav[0]/frequencies/standby-mhz", active_freq);
                    displays.a_1_pres = 0;
                } elsif (displays.n_2_pres == 1 and ! inputting) {  # Go to the next stored frequency
                    nav_1_chans_index += 1;
                    displays.n_2_pres = 0;
                } elsif (displays.data_pres == 1 and !inputting) {  # Frequency input
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 1;
                    displays.data_pres = 0;
                } elsif (displays.mrk_pres == 1 and inputting) {  # Pilot's confirming data Mach inputting
                    
                    # We check if the stored input is correct
                    # - is a number
                        
                    if (!is_numeric(stored_input)) {  # (stored_input + 0) forces Nasal to treat stored_input as a float and not a string anymore
                        displays.bad_data = 1;  # Trigger the "BAD DATA" label display
                    } else {  # It's all good, we can apply the inputted data to the sim property
                        setprop("instrumentation/nav[0]/frequencies/selected-mhz", stored_input + 0);
                    }
                    
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 0;
                    displays.mrk_pres = 0;
                }
                if (size(stored_input) < 6 and inputting) {  # Max amount of data that can be inputted (3 units 2 decimals and the decimal dot)
                    if (displays.a_1_pres == 1) {
                        stored_input = stored_input~"1";
                        displays.a_1_pres = 0;
                    } elsif (displays.n_2_pres == 1) {
                        stored_input = stored_input~"2";
                        displays.n_2_pres = 0;
                    } elsif (displays.b_3_pres == 1) {
                        stored_input = stored_input~"3";
                        displays.b_3_pres = 0;
                    } elsif (displays.w_4_pres == 1) {
                        stored_input = stored_input~"4";
                        displays.w_4_pres = 0;
                    } elsif (displays.m_5_pres == 1) {
                        stored_input = stored_input~"5";
                        displays.m_5_pres = 0;
                    } elsif (displays.e_6_pres == 1) {
                        stored_input = stored_input~"6";
                        displays.e_6_pres = 0;
                    } elsif (displays.i_7_pres == 1) {
                        stored_input = stored_input~"7";
                        displays.i_7_pres = 0;
                    } elsif (displays.s_8_pres == 1) {
                        stored_input = stored_input~"8";
                        displays.s_8_pres = 0;
                    } elsif (displays.c_9_pres == 1) {
                        stored_input = stored_input~"9";
                        displays.c_9_pres = 0;
                    } elsif (displays.hyphen_0_pres == 1) {
                        stored_input = stored_input~"0";
                        displays.hyphen_0_pres = 0;
                    } elsif (displays.decimal_pres == 1) {
                        stored_input = stored_input~".";
                        displays.decimal_pres = 0;
                    }
                }
            } elsif (nav_1_chans_index == 1) {  # Standby frequency
                ils_text = sprintf("STBY %3.2f MHz 1.Active 2.Next", getprop("instrumentation/nav[0]/frequencies/standby-mhz"));
                if (displays.a_1_pres == 1 and !inputting) {  # Switch between active and standby
                    active_freq = getprop("instrumentation/nav[0]/frequencies/selected-mhz");
                    standby_freq = getprop("instrumentation/nav[0]/frequencies/standby-mhz");
                    setprop("instrumentation/nav[0]/frequencies/selected-mhz", standby_freq);
                    setprop("instrumentation/nav[0]/frequencies/standby-mhz", active_freq);
                    displays.a_1_pres = 0;
                } elsif (displays.n_2_pres == 1 and ! inputting) {  # Go to the next stored frequency
                    nav_1_chans_index += 1;
                    displays.n_2_pres = 0;
                } elsif (displays.data_pres == 1 and !inputting) {  # Frequency input
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 1;
                    displays.data_pres = 0;
                } elsif (displays.mrk_pres == 1 and inputting) {  # Pilot's confirming data Mach inputting
                    
                    # We check if the stored input is correct
                    # - is a number
                        
                    if (!is_numeric(stored_input)) {  # (stored_input + 0) forces Nasal to treat stored_input as a float and not a string anymore
                        displays.bad_data = 1;  # Trigger the "BAD DATA" label display
                    } else {  # It's all good, we can apply the inputted data to the sim property
                        setprop("instrumentation/nav[0]/frequencies/standby-mhz", stored_input + 0);
                    }
                    
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 0;
                    displays.mrk_pres = 0;
                }
                if (size(stored_input) < 6 and inputting) {  # Max amount of data that can be inputted (3 units 2 decimals and the decimal dot)
                    if (displays.a_1_pres == 1) {
                        stored_input = stored_input~"1";
                        displays.a_1_pres = 0;
                    } elsif (displays.n_2_pres == 1) {
                        stored_input = stored_input~"2";
                        displays.n_2_pres = 0;
                    } elsif (displays.b_3_pres == 1) {
                        stored_input = stored_input~"3";
                        displays.b_3_pres = 0;
                    } elsif (displays.w_4_pres == 1) {
                        stored_input = stored_input~"4";
                        displays.w_4_pres = 0;
                    } elsif (displays.m_5_pres == 1) {
                        stored_input = stored_input~"5";
                        displays.m_5_pres = 0;
                    } elsif (displays.e_6_pres == 1) {
                        stored_input = stored_input~"6";
                        displays.e_6_pres = 0;
                    } elsif (displays.i_7_pres == 1) {
                        stored_input = stored_input~"7";
                        displays.i_7_pres = 0;
                    } elsif (displays.s_8_pres == 1) {
                        stored_input = stored_input~"8";
                        displays.s_8_pres = 0;
                    } elsif (displays.c_9_pres == 1) {
                        stored_input = stored_input~"9";
                        displays.c_9_pres = 0;
                    } elsif (displays.hyphen_0_pres == 1) {
                        stored_input = stored_input~"0";
                        displays.hyphen_0_pres = 0;
                    } elsif (displays.decimal_pres == 1) {
                        stored_input = stored_input~".";
                        displays.decimal_pres = 0;
                    }
                }
            } elsif (nav_1_chans_index > 1) {  # Stored channel data blocks
                data_idx = nav_1_chans_index - 1;
                ils_text = sprintf("DATA%02d %3.2f MHz 1.Push 2.Next", data_idx, getprop("instrumentation/nav[0]/frequencies/data-"~data_idx~"-freq"));
                if (displays.a_1_pres == 1 and !inputting) {  # Push data block to active freq
                    setprop("instrumentation/nav[0]/frequencies/selected-mhz", getprop("instrumentation/nav[0]/frequencies/data-"~data_idx~"-freq"));
                    displays.a_1_pres = 0;
                } elsif (displays.n_2_pres == 1 and !inputting and data_idx < 16) {  # Go to the next stored frequency
                    nav_1_chans_index += 1;
                    displays.n_2_pres = 0;
                } elsif (displays.data_pres == 1 and !inputting) {  # Frequency input
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 1;
                    displays.data_pres = 0;
                } elsif (displays.mrk_pres == 1 and inputting) {  # Pilot's confirming data Mach inputting
                    
                    # We check if the stored input is correct
                    # - is a number
                        
                    if (!is_numeric(stored_input)) {  # (stored_input + 0) forces Nasal to treat stored_input as a float and not a string anymore
                        displays.bad_data = 1;  # Trigger the "BAD DATA" label display
                    } else {  # It's all good, we can apply the inputted data to the sim property
                        setprop("instrumentation/nav[0]/frequencies/data-"~data_idx~"-freq", stored_input + 0);
                    }

                    stored_input = "";  # We reset the stored input just in case
                    inputting = 0;
                    displays.mrk_pres = 0;
                }
                if (size(stored_input) < 6 and inputting) {  # Max amount of data that can be inputted (3 units 2 decimals and the decimal dot)
                    if (displays.a_1_pres == 1) {
                        stored_input = stored_input~"1";
                        displays.a_1_pres = 0;
                    } elsif (displays.n_2_pres == 1) {
                        stored_input = stored_input~"2";
                        displays.n_2_pres = 0;
                    } elsif (displays.b_3_pres == 1) {
                        stored_input = stored_input~"3";
                        displays.b_3_pres = 0;
                    } elsif (displays.w_4_pres == 1) {
                        stored_input = stored_input~"4";
                        displays.w_4_pres = 0;
                    } elsif (displays.m_5_pres == 1) {
                        stored_input = stored_input~"5";
                        displays.m_5_pres = 0;
                    } elsif (displays.e_6_pres == 1) {
                        stored_input = stored_input~"6";
                        displays.e_6_pres = 0;
                    } elsif (displays.i_7_pres == 1) {
                        stored_input = stored_input~"7";
                        displays.i_7_pres = 0;
                    } elsif (displays.s_8_pres == 1) {
                        stored_input = stored_input~"8";
                        displays.s_8_pres = 0;
                    } elsif (displays.c_9_pres == 1) {
                        stored_input = stored_input~"9";
                        displays.c_9_pres = 0;
                    } elsif (displays.hyphen_0_pres == 1) {
                        stored_input = stored_input~"0";
                        displays.hyphen_0_pres = 0;
                    } elsif (displays.decimal_pres == 1) {
                        stored_input = stored_input~".";
                        displays.decimal_pres = 0;
                    }
                }
            }
            
            UFCCanvas.UFCText.setText(ils_text);
        } elsif (curr_menu == nav_1_mode_menu) {
            if (getprop("sim/model/f15/instrumentation/ils/mode") == 0) {
                ils_text = "ILS:Off. 1.NAV1 2.NAV2 3.STPTS";
                if (displays.a_1_pres == 1) {
                    setprop("sim/model/f15/instrumentation/ils/mode", 1);
                    displays.a_1_pres = 0;
                } elsif (displays.n_2_pres == 1) {
                    setprop("sim/model/f15/instrumentation/ils/mode", 2);
                    displays.n_2_pres = 0;
                } elsif (displays.b_3_pres == 1) {
                    setprop("sim/model/f15/instrumentation/ils/mode", 2);
                    displays.b_3_pres = 0;
                }
            } elsif (getprop("sim/model/f15/instrumentation/ils/mode") == 1) {
                ils_text = "ILS:NAV1 1.NAV2 2.STPTS 3.Off.";
                if (displays.a_1_pres == 1) {
                    setprop("sim/model/f15/instrumentation/ils/mode", 2);
                    displays.a_1_pres = 0;
                } elsif (displays.n_2_pres == 1) {
                    setprop("sim/model/f15/instrumentation/ils/mode", 3);
                    displays.n_2_pres = 0;
                } elsif (displays.b_3_pres == 1) {
                    setprop("sim/model/f15/instrumentation/ils/mode", 0);
                    displays.b_3_pres = 0;
                }
            } elsif (getprop("sim/model/f15/instrumentation/ils/mode") == 2) {
                ils_text = "ILS:NAV2 1.STPTS 2.NAV1 3.Off.";
                if (displays.a_1_pres == 1) {
                    setprop("sim/model/f15/instrumentation/ils/mode", 3);
                    displays.a_1_pres = 0;
                } elsif (displays.n_2_pres == 1) {
                    setprop("sim/model/f15/instrumentation/ils/mode", 1);
                    displays.n_2_pres = 0;
                } elsif (displays.b_3_pres == 1) {
                    setprop("sim/model/f15/instrumentation/ils/mode", 0);
                    displays.b_3_pres = 0;
                }
            } elsif (getprop("sim/model/f15/instrumentation/ils/mode") == 3) {
                ils_text = "ILS:STPTS 1.NAV1 2.NAV2 3.Off.";
                if (displays.a_1_pres == 1) {
                    setprop("sim/model/f15/instrumentation/ils/mode", 1);
                    displays.a_1_pres = 0;
                } elsif (displays.n_2_pres == 1) {
                    setprop("sim/model/f15/instrumentation/ils/mode", 2);
                    displays.n_2_pres = 0;
                } elsif (displays.b_3_pres == 1) {
                    setprop("sim/model/f15/instrumentation/ils/mode", 0);
                    displays.b_3_pres = 0;
                }
            }
        
            UFCCanvas.UFCText.setText(ils_text);
        } elsif (curr_menu == comm_main_menu) {
            comm_text2 = 1;
            if (current_comm == 0) {
                comm_text2 = 2;
            }
            comm_text = sprintf(" 1.INFO 2.CHANNELS 3.SEL COMM%d", comm_text2);

            if (displays.a_1_pres == 1) {  # Handle inputs
                curr_menu = comm_info_menu;
                displays.a_1_pres = 0;
            } elsif (displays.n_2_pres == 1) {
                curr_menu = comm_chans_menu;
                displays.n_2_pres = 0;
            } elsif (displays.b_3_pres == 1) {
                if (current_comm == 0) {
                    current_comm = 1;
                } else {
                    current_comm = 0
                }
                displays.b_3_pres = 0;
            }

            UFCCanvas.UFCText.setText(comm_text);
        } elsif (curr_menu == comm_info_menu) {
            final_text = sprintf("%s %02d", getprop("instrumentation/comm["~current_comm~"]/airport-id"), getprop("instrumentation/comm["~current_comm~"]/track-distance-m") * M2NM);

            comm_text = sprintf("FREQ %3.2f Volume %03d %s", getprop("instrumentation/comm["~current_comm~"]/frequencies/selected-mhz"), getprop("instrumentation/comm["~current_comm~"]/volume") * 100, final_text);

            UFCCanvas.UFCText.setText(comm_text);
        } elsif (curr_menu == comm_chans_menu) {
            
            var curr_radio = "";
            if (current_comm == 0) {
                var curr_radio = "an-arc-182v";
            } else {
                var curr_radio = "an-arc-159v1";
            }
            
            if (comm_chans_index == 0) {  # Active frequency
                comm_text = sprintf("ACTIVE %3.2f MHz 1.Stby 2.Next", getprop("instrumentation/comm["~current_comm~"]/frequencies/selected-mhz"));
                if (displays.a_1_pres == 1 and !inputting) {  # Switch between active and standby
                    active_freq = getprop("instrumentation/comm["~current_comm~"]/frequencies/selected-mhz");
                    standby_freq = getprop("instrumentation/comm["~current_comm~"]/frequencies/standby-mhz");
                    setprop("instrumentation/comm["~current_comm~"]/frequencies/selected-mhz", standby_freq);
                    setprop("instrumentation/comm["~current_comm~"]/frequencies/standby-mhz", active_freq);
                    displays.a_1_pres = 0;
                } elsif (displays.n_2_pres == 1 and ! inputting) {  # Go to the next stored frequency
                    comm_chans_index += 1;
                    displays.n_2_pres = 0;
                } elsif (displays.data_pres == 1 and !inputting) {  # Frequency input
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 1;
                    displays.data_pres = 0;
                } elsif (displays.mrk_pres == 1 and inputting) {  # Pilot's confirming data Mach inputting
                    
                    # We check if the stored input is correct
                    # - is a number
                        
                    if (!is_numeric(stored_input)) {  # (stored_input + 0) forces Nasal to treat stored_input as a float and not a string anymore
                        displays.bad_data = 1;  # Trigger the "BAD DATA" label display
                    } else {  # It's all good, we can apply the inputted data to the sim property
                        setprop("instrumentation/comm["~current_comm~"]/frequencies/selected-mhz", stored_input + 0);
                    }
                    
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 0;
                    displays.mrk_pres = 0;
                }
                if (size(stored_input) < 6 and inputting) {  # Max amount of data that can be inputted (3 units 2 decimals and the decimal dot)
                    if (displays.a_1_pres == 1) {
                        stored_input = stored_input~"1";
                        displays.a_1_pres = 0;
                    } elsif (displays.n_2_pres == 1) {
                        stored_input = stored_input~"2";
                        displays.n_2_pres = 0;
                    } elsif (displays.b_3_pres == 1) {
                        stored_input = stored_input~"3";
                        displays.b_3_pres = 0;
                    } elsif (displays.w_4_pres == 1) {
                        stored_input = stored_input~"4";
                        displays.w_4_pres = 0;
                    } elsif (displays.m_5_pres == 1) {
                        stored_input = stored_input~"5";
                        displays.m_5_pres = 0;
                    } elsif (displays.e_6_pres == 1) {
                        stored_input = stored_input~"6";
                        displays.e_6_pres = 0;
                    } elsif (displays.i_7_pres == 1) {
                        stored_input = stored_input~"7";
                        displays.i_7_pres = 0;
                    } elsif (displays.s_8_pres == 1) {
                        stored_input = stored_input~"8";
                        displays.s_8_pres = 0;
                    } elsif (displays.c_9_pres == 1) {
                        stored_input = stored_input~"9";
                        displays.c_9_pres = 0;
                    } elsif (displays.hyphen_0_pres == 1) {
                        stored_input = stored_input~"0";
                        displays.hyphen_0_pres = 0;
                    } elsif (displays.decimal_pres == 1) {
                        stored_input = stored_input~".";
                        displays.decimal_pres = 0;
                    }
                }
            } elsif (comm_chans_index == 1) {  # Standby frequency
                comm_text = sprintf("STBY %3.2f MHz 1.Active 2.Next", getprop("instrumentation/comm["~current_comm~"]/frequencies/standby-mhz"));
                if (displays.a_1_pres == 1 and !inputting) {  # Switch between active and standby
                    active_freq = getprop("instrumentation/comm["~current_comm~"]/frequencies/selected-mhz");
                    standby_freq = getprop("instrumentation/comm["~current_comm~"]/frequencies/standby-mhz");
                    setprop("instrumentation/comm["~current_comm~"]/frequencies/selected-mhz", standby_freq);
                    setprop("instrumentation/comm["~current_comm~"]/frequencies/standby-mhz", active_freq);
                    displays.a_1_pres = 0;
                } elsif (displays.n_2_pres == 1 and ! inputting) {  # Go to the next stored frequency
                    comm_chans_index += 1;
                    displays.n_2_pres = 0;
                } elsif (displays.data_pres == 1 and !inputting) {  # Frequency input
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 1;
                    displays.data_pres = 0;
                } elsif (displays.mrk_pres == 1 and inputting) {  # Pilot's confirming data Mach inputting
                    
                    # We check if the stored input is correct
                    # - is a number
                        
                    if (!is_numeric(stored_input)) {  # (stored_input + 0) forces Nasal to treat stored_input as a float and not a string anymore
                        displays.bad_data = 1;  # Trigger the "BAD DATA" label display
                    } else {  # It's all good, we can apply the inputted data to the sim property
                        setprop("instrumentation/comm["~current_comm~"]/frequencies/standby-mhz", stored_input + 0);
                    }
                    
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 0;
                    displays.mrk_pres = 0;
                }
                if (size(stored_input) < 6 and inputting) {  # Max amount of data that can be inputted (3 units 2 decimals and the decimal dot)
                    if (displays.a_1_pres == 1) {
                        stored_input = stored_input~"1";
                        displays.a_1_pres = 0;
                    } elsif (displays.n_2_pres == 1) {
                        stored_input = stored_input~"2";
                        displays.n_2_pres = 0;
                    } elsif (displays.b_3_pres == 1) {
                        stored_input = stored_input~"3";
                        displays.b_3_pres = 0;
                    } elsif (displays.w_4_pres == 1) {
                        stored_input = stored_input~"4";
                        displays.w_4_pres = 0;
                    } elsif (displays.m_5_pres == 1) {
                        stored_input = stored_input~"5";
                        displays.m_5_pres = 0;
                    } elsif (displays.e_6_pres == 1) {
                        stored_input = stored_input~"6";
                        displays.e_6_pres = 0;
                    } elsif (displays.i_7_pres == 1) {
                        stored_input = stored_input~"7";
                        displays.i_7_pres = 0;
                    } elsif (displays.s_8_pres == 1) {
                        stored_input = stored_input~"8";
                        displays.s_8_pres = 0;
                    } elsif (displays.c_9_pres == 1) {
                        stored_input = stored_input~"9";
                        displays.c_9_pres = 0;
                    } elsif (displays.hyphen_0_pres == 1) {
                        stored_input = stored_input~"0";
                        displays.hyphen_0_pres = 0;
                    } elsif (displays.decimal_pres == 1) {
                        stored_input = stored_input~".";
                        displays.decimal_pres = 0;
                    }
                }
            } elsif (comm_chans_index > 1) {  # Stored channel data blocks
                data_idx = comm_chans_index - 2;
                comm_text = sprintf("DATA%02d %3.2f MHz 1.Push 2.Next", data_idx, getprop("sim/model/f15/instrumentation/"~curr_radio~"/presets/frequency["~data_idx~"]"));
                if (displays.a_1_pres == 1 and !inputting) {  # Push data block to active freq
                    setprop("instrumentation/comm["~current_comm~"]/frequencies/selected-mhz", getprop("sim/model/f15/instrumentation/"~curr_radio~"/presets/frequency["~data_idx~"]"));
                    displays.a_1_pres = 0;
                } elsif (displays.n_2_pres == 1 and !inputting and data_idx < 20) {  # Go to the next stored frequency
                    comm_chans_index += 1;
                    displays.n_2_pres = 0;
                } elsif (displays.data_pres == 1 and !inputting) {  # Frequency input
                    stored_input = "";  # We reset the stored input just in case
                    inputting = 1;
                    displays.data_pres = 0;
                } elsif (displays.mrk_pres == 1 and inputting) {  # Pilot's confirming data Mach inputting
                    
                    # We check if the stored input is correct
                    # - is a number
                        
                    if (!is_numeric(stored_input)) {  # (stored_input + 0) forces Nasal to treat stored_input as a float and not a string anymore
                        displays.bad_data = 1;  # Trigger the "BAD DATA" label display
                    } else {  # It's all good, we can apply the inputted data to the sim property
                        setprop("sim/model/f15/instrumentation/"~curr_radio~"/presets/frequency["~data_idx~"]", stored_input + 0);
                    }

                    stored_input = "";  # We reset the stored input just in case
                    inputting = 0;
                    displays.mrk_pres = 0;
                }
                if (size(stored_input) < 6 and inputting) {  # Max amount of data that can be inputted (3 units 2 decimals and the decimal dot)
                    if (displays.a_1_pres == 1) {
                        stored_input = stored_input~"1";
                        displays.a_1_pres = 0;
                    } elsif (displays.n_2_pres == 1) {
                        stored_input = stored_input~"2";
                        displays.n_2_pres = 0;
                    } elsif (displays.b_3_pres == 1) {
                        stored_input = stored_input~"3";
                        displays.b_3_pres = 0;
                    } elsif (displays.w_4_pres == 1) {
                        stored_input = stored_input~"4";
                        displays.w_4_pres = 0;
                    } elsif (displays.m_5_pres == 1) {
                        stored_input = stored_input~"5";
                        displays.m_5_pres = 0;
                    } elsif (displays.e_6_pres == 1) {
                        stored_input = stored_input~"6";
                        displays.e_6_pres = 0;
                    } elsif (displays.i_7_pres == 1) {
                        stored_input = stored_input~"7";
                        displays.i_7_pres = 0;
                    } elsif (displays.s_8_pres == 1) {
                        stored_input = stored_input~"8";
                        displays.s_8_pres = 0;
                    } elsif (displays.c_9_pres == 1) {
                        stored_input = stored_input~"9";
                        displays.c_9_pres = 0;
                    } elsif (displays.hyphen_0_pres == 1) {
                        stored_input = stored_input~"0";
                        displays.hyphen_0_pres = 0;
                    } elsif (displays.decimal_pres == 1) {
                        stored_input = stored_input~".";
                        displays.decimal_pres = 0;
                    }
                }
            }
            
            UFCCanvas.UFCText.setText(comm_text);
        }
        
        # If there's a bad data warning, we display it no matter what, for 3 whole seconds
        # Else-If we're inputting, we display the inputted data no matter what
        if (displays.bad_data == 1) {
            UFCCanvas.UFCText.setText("                      BAD DATA");
            if (displays.bad_data_clear_called == 0) {  # If bad data ain't been called yet - first time displaying it since last bad_data trigger
                settimer(func {displays.bad_data = 0; displays.bad_data_clear_called = 0;},3);
                displays.bad_data_clear_called = 1;
            }
        } elsif (displays.inputting == 1) {
            stored_input_size = size(stored_input);
            if (stored_input_size == 0) {
                stored_input_size = 1;
            }  # Fix
            spaces_count = 30 - stored_input_size - size("ENTER DATA:");  # We make sure the inputted data is always aligned right
            inputting_to_display = "ENTER DATA:";
            for (var i = 0; i < spaces_count; i += 1) {
                inputting_to_display ~= " ";
            }
            inputting_to_display ~= stored_input;
            UFCCanvas.UFCText.setText(inputting_to_display);
        }
        
        # Handle standalone button triggers
        if (displays.ap_pres == 1) {  # Toggle both heading and altitude autopilot modes and force-display the autopilot menu if autopilot has been set on
            stored_input = "";  # Since we force-display, we reset the pilot's input
            if (getprop("sim/gui/dialogs/autopilot/heading-active") or getprop("sim/gui/dialogs/autopilot/altitude-active") or getprop("sim/gui/dialogs/autopilot/speed-active")) {
                setprop("sim/gui/dialogs/autopilot/heading-active", 0);
                setprop("sim/gui/dialogs/autopilot/altitude-active", 0);
                setprop("sim/gui/dialogs/autopilot/speed-active", 0);
            } else {
                setprop("sim/gui/dialogs/autopilot/heading-active", 1);
                setprop("sim/gui/dialogs/autopilot/altitude-active", 1);
                setprop("sim/gui/dialogs/autopilot/speed-active", 0);
            }
            hdg.enable();
            alt.enable();
            vel.enable();
            if (getprop("sim/gui/dialogs/autopilot/heading-active") == 1) {  # If this press turned the A/P ON, we go to the A/P menu
                curr_menu = autopilot_main_menu;
            }
            displays.ap_pres = 0;
        } elsif (displays.menu_pres == 1) {  # Takes us back to the last menu
            stored_input = "";  # Since we force-display, we reset the pilot's input
            if (displays.inputting) {
                displays.inputting = 0;
            } elsif (curr_menu == autopilot_main_menu or curr_menu == nav1_main_menu or curr_menu == comm_main_menu) {
                curr_menu = dft_menu;
            } elsif (curr_menu == autopilot_info_menu or curr_menu == autopilot_heading_menu or curr_menu == autopilot_altitude_menu or curr_menu == autopilot_auto_throttle_menu) {
                curr_menu = autopilot_main_menu;
            } elsif (curr_menu == autopilot_altitude_menu_sec) {
                curr_menu = autopilot_altitude_menu;
            } elsif (curr_menu == nav1_menu_info or (curr_menu == nav_1_chans_menu and nav_1_chans_index == 0) or curr_menu == nav_1_mode_menu) {
                curr_menu = nav1_main_menu;
            } elsif (curr_menu == nav_1_chans_menu and nav_1_chans_index != 0) {
                nav_1_chans_index = 0;
            } elsif (curr_menu == comm_info_menu or (curr_menu == comm_chans_menu and comm_chans_index == 0)) {
                curr_menu = comm_main_menu;
            } elsif (curr_menu == comm_chans_menu and comm_chans_index != 0) {
                comm_chans_index = 0;
            }
            
            displays.menu_pres = 0;
        } elsif (displays.clr_pres == 1) {  # Clear currently inputted data
            stored_input = "";
            displays.clr_pres = 0;
        }
        
        # The following lines prevent a case of scenario:
        # You press 1, nothing happens, you press data and you start with 1 already entered ...
        displays.crec_l_pres = 0;
        displays.a_1_pres = 0;
        displays.n_2_pres = 0;
        displays.b_3_pres = 0;
        displays.crec_r_pres = 0;
        displays.mrk_pres = 0;
        displays.w_4_pres = 0;
        displays.m_5_pres = 0;
        displays.e_6_pres = 0;
        displays.ip_pres = 0;
        displays.decimal_pres = 0;
        displays.i_7_pres = 0;
        displays.s_8_pres = 0;
        displays.c_9_pres = 0;
        #displays.shf_pres = 0;  # Actually not the SHF press because it requires a second bind to make an action
        displays.ap_pres = 0;
        displays.clr_pres = 0;
        displays.hyphen_0_pres = 0;
        displays.data_pres = 0;
        displays.menu_pres = 0;
    } elsif (!getprop("sim/model/f15/avionics/bit-done")) {
        bit_text = sprintf("     B.I.T. %03.2f percent     ", getprop("sim/model/f15/avionics/bit-norm") * 100);
        UFCCanvas.UFCText.setText(bit_text);
    }
}

UFCCanvas = UFC_Device.new({"node": "UFCImage"});
update_loop_ufc = maketimer(.25, update_loop_func);  # We don't need to make it run that often, it's just a text display at the end of the day
update_loop_ufc.start();
