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
#  - Standalone menus:  # these menus are obtained either by triggering a function on the LAD, or the EFHD, or by selecting them using the keypad
#
#  - Triggered menus:  # these menus are only obtained by triggered a function on the LAD, or the EFHD
# ---------------------------
# Some Notes :
# - Current proportions in the model are 2.849173228" (width) by .455" (height), making it a 6 1/4 ratio (width/height)
# ---------------------------
# Planned Features :
# - 
# ---------------------------
# Author: Jimmy L. Miles
# ---------------------------

## Variables
var stored_input = "";  # Variable in which we store the pilot's input'd info (ex. "129.5" if we're entering a radio's frequency in MHz)
                        # It's always a string even if it's numeric data, it gets translated if needed.

# Menus
# Each specific menu/sub-menu got a specific integer ID for 'em.
# It's depending on the curr_menu ID that we know what button does what
# and what's to be displayed.
var dft_menu = 0;
var curr_menu = dft_menu;  # Default menu

# Autopilot
var autopilot_main_menu = 1;  # Displays different options (INFO, HDG MD, PTCH MD, THROT)
var autopilot_info_menu = 2;  # Displays info about current autopilot nav
var autopilot_heading_menu = 3;  # TODO

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

update = func() {
    
    # We make sure we don't run none of that if the UFC screen's offline
    if (getprop("fdm/jsbsim/systems/electrics/ac-left-main-bus") > 5) {
    
        # Display what we gotta display depending on the current menu
        if (curr_menu == dft_menu) {
            UFCCanvas.UFCText.setText("                              ");
        } elsif (curr_menu == autopilot_main_menu) {
            UFCCanvas.UFCText.setText("1.INFO 2.HDG M 3.PTCH M 4.THRT");
            
            # Handle autopilot main menu buttons
            if (displays.a_1_pres == 1) {  # Take us to INFO autopilot menu
                curr_menu = autopilot_info_menu;
                displays.a_1_pres = 0;
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
            }
        
            throttle_text = sprintf("Ma %1.2f", getprop("autopilot/settings/target-speed-mach"));
            auto_throttle_on = getprop("sim/gui/dialogs/autopilot/speed-active");
            if (!auto_throttle_on) {
                throttle_text = "Ma OFF";
            }
            #UFCCanvas.UFCText.setText(" True H XXX Alt H XXXXX Ma XXXX");
            UFCCanvas.UFCText.setText(sprintf("%s %s %s", heading_text, altitude_text, throttle_text));
        }
        
        # Handle standalone button triggers
        if (displays.ap_pres == 1) {  # Toggle AFCS Attitude mode (autopilot) and force-display the autopilot menu if autopilot has been set on
            stored_input = "";  # Since we force-display, we reset the pilot's input
            setprop("sim/model/f15/controls/AFCS/att-hold", !getprop("sim/model/f15/controls/AFCS/att-hold"));
            if (getprop("sim/model/f15/controls/AFCS/att-hold") == 1) {
                curr_menu = autopilot_main_menu;
            }
            displays.ap_pres = 0;
        }
        if (displays.menu_pres == 1) {  # Takes us back to the last menu
            stored_input = "";  # Since we force-display, we reset the pilot's input
            if (curr_menu == autopilot_main_menu) {
                curr_menu = dft_menu;
            } elsif (curr_menu == autopilot_info_menu or curr_menu == autopilot_heading_menu) {
                curr_menu = autopilot_main_menu;
            }
            
            displays.menu_pres = 0;
        }
        
    }
}

UFCCanvas = UFC_Device.new({"node": "UFCImage"});
update_loop_ufc = maketimer(.25, update);  # We don't need to make it run that often, it's just a text display at the end of the day
update_loop_ufc.start();
