# F-15 Canvas HUD
# ---------------------------
#
# The F-15C HUD is provided by 2 combiners.
# We model this accurately in the geometry by having the two glass panes
# which are texture mapped onto a single canvas texture.two instances of the HUD
# 2016-01-06: The HUD appears slightly trapezoidal (better than previous version
#             however still could be improved possibly with a transformation matrix.
# ---------------------------
# Richard Harrison (rjh@zaretto.com) 2015-01-27  - based on F-20 HUD main module Enrique Laso (Flying toaster)
# ---------------------------

var ht_xcf = 1024;
var ht_ycf = -1024;
var ht_xco = 0;
var ht_yco = 0;
var uv_x1 = 0;
var uv_x2 = 0;
var uv_used = uv_x2-uv_x1;
var ht_debug = 0;

var flirImageReso = 16;

var sx = 276*uv_used;
var sy = -106*3;

var eegsShow = 0;

#angular definitions
#up angle 1.73 deg
#left/right angle 5.5 deg
#down angle 10.2 deg
#total size 11x11.93 deg
#texture square 256x256
#bottom left 0,0
#viewport size  236x256
#center at 118,219
#pixels per deg = 21.458507963

# paste into nasal console for debugging
#aircraft.MainHUD.canvas._node.setValues({
#                           "name": "F-15 HUD",
#                           "size": [1024,1024],
#                           "view": [276,106],
#                           "mipmapping": 0
#  });
#aircraft.MainHUD.svg.setTranslation (0, 20.0);
#aircraft.MainHUD.svg.set("clip", "rect(2,256,276,0)");
#aircraft.MainHUD.svg.setTranslation (-21.0, 37.0);
#aircraft.MainHUD.svg.set("clip", "rect(1,256,276,0)");
#aircraft.MainHUD.svg.set("clip", "rect(10,256,276,0)");
#aircraft.MainHUD.svg.set("clip-frame", canvas.Element.PARENT);

var pitch_factor=11.18;

# the coordinates (e.g. 9317) are the Y coordinates from the SVG for the
# horizontal bar for each tapes.
var alt_range_factor = (9317-191) / 100000; # alt tape size and max value.

#IAS tape starts at 0 and goes up; so these coordinates result in an overall size
#of -501; if the tape moved downards it would be 501.
var ias_range_factor = (-310.034 - 191.841) / 1100;

#Pinto: if you know starting x (left/right) and z (up/down), then i just do
#
#var changeViewX = -1 * (startViewX-getprop(viewX))*getprop(ghosting_x);
#var changeViewY = (startViewY-getprop(viewY))*getprop(ghosting_y);
#
#where ghosting_x and ghosting_y are parallax adjusting. about 7000
# trial and error can quickly give you the right values. Then I move the canvas elements by however much changeViewX and changeViewY are.
# calc of pitch_offset (compensates for AC3D model translated and rotated when loaded. Also semi compensates for HUD being at an angle.)
#        var Hz_b =    0.80643; # HUD position inside ac model after it is loaded translated and rotated.
#        var Hz_t =    0.96749;
#        var Vz   =    getprop("sim/current-view/y-offset-m"); # view Z position (0.94 meter per default)
#
#        var bore_over_bottom = Vz - Hz_b;
#        var Hz_height        = Hz_t-Hz_b;
#        var hozizon_line_offset_from_middle_in_svg = 0.137; #fraction up from middle
#        var frac_up_the_hud = bore_over_bottom / Hz_height - hozizon_line_offset_from_middle_in_svg;
#       var texels_up_into_hud = frac_up_the_hud * me.sy;#sy default is 260
#       var texels_over_middle = texels_up_into_hud - me.sy/2;
#
#
#        pitch_offset = -texels_over_middle;

#var changeViewX = -1 * (startViewX-getprop(viewX))*getprop(ghosting_x);
#var changeViewY = (startViewY-getprop(viewY))*getprop(ghosting_y);

var F15HUD = {
	new : func (svgname){
		var obj = {parents : [F15HUD] };

        obj.process_targets = frame_utils.PartitionProcessor.new("HUD-radar", 20, nil);
        if (defined("obj.process_targets.set_max_time_usec"))
            obj.process_targets.set_max_time_usec(500);

        obj.canvas= canvas.new({
                "name": "F-15 HUD",
                    "size": [1024,1024],
                    "view": [256,296],
                    "mipmapping": 0,
                    });
        obj.view = [0, 1.4000051983, -5];
        obj.canvas.addPlacement({"node": "HUDImage1"});
        obj.canvas.addPlacement({"node": "HUDImage2"});
        obj.canvas.setColorBackground(0.36, 1, 0.3, 0.00);
        obj.FocusAtInfinity = 0;
# Create a group for the parsed elements
        obj.svg = obj.canvas.createGroup();

# Parse an SVG file and add the parsed elements to the given group
        logprint(3, "HUD Parse SVG ",canvas.parsesvg(obj.svg, svgname),  {'font-mapper': aircraft.hud_font_mapper});

        obj.canvas._node.setValues({
                                    "name": "F-15 HUD",
                                    "size": [1024,1024],
                                    "view": [256,296],
                                    "mipmapping": 0
                    });
        obj.baseTranslation = [30,30];
        obj.svg.setTranslation (obj.baseTranslation[0], obj.baseTranslation[1]);
        obj.svg.set("clip", "rect(11,256,296,0)");
        obj.svg.set("clip-frame", canvas.Element.PARENT);
        obj.svg.setScale(0.8,1.18);

        obj.ladder = obj.get_element("ladder");
        obj.ladder.setScale(1,0.558);

        obj.VV = obj.get_element("VelocityVector");
        obj.heading_tape = obj.get_element("heading-scale");
        obj.roll_pointer = obj.get_element("roll-pointer");
        obj.alt_range = obj.get_element("alt_range");
        obj.ias_range = obj.get_element("ias_range");
        obj.window9_rect = obj.get_element("window9_rect");
        obj.window1_rect = obj.get_element("window1_rect");

        obj.target_locked = obj.get_element("target_locked");
        obj.target_locked.setVisible(0);

        obj.window1 = obj.get_text("window1", aircraft.HUDFont,9,1.4);
        obj.window2 = obj.get_text("window2", aircraft.HUDFont,9,1.4);
        obj.window3 = obj.get_text("window3", aircraft.HUDFont,9,1.4);
        obj.window4 = obj.get_text("window4", aircraft.HUDFont,9,1.4);
        obj.window5 = obj.get_text("window5", aircraft.HUDFont,9,1.4);
        obj.window6 = obj.get_text("window6", aircraft.HUDFont,9,1.4);
        obj.window7 = obj.get_text("window7", aircraft.HUDFont,9,1.4);
        obj.window8 = obj.get_text("window8", aircraft.HUDFont,9,1.4);
        obj.window9 = obj.get_text("window9", aircraft.HUDFont,9,1.4);
        obj.window10 = obj.get_text("window10", aircraft.HUDFont,9,1.4);
        obj.window11 = obj.get_text("window11", aircraft.HUDFont,9,1.4);
        obj.window13 = obj.get_text("window13", aircraft.HUDFont,9,1.4);
        obj.window14 = obj.get_text("window14", aircraft.HUDFont,9,1.4);
        obj.window15 = obj.get_text("window15", aircraft.HUDFont,9,1.4);
        obj.window16 = obj.get_text("window16", aircraft.HUDFont,9,1.4);
        obj.window17 = obj.get_text("window17", aircraft.HUDFont,9,1.4);
        obj.window18 = obj.get_text("window18", aircraft.HUDFont,9,1.4);

		obj.color = [0.3,1,0.3,.5]; # last one should be brightness parameter TODO: apply it to all elements

        obj.window1.setVisible(0);

        obj.HudNavRangeDisplay = "";
        obj.HudNavRangeETA = "";
        obj.currentViewX = props.globals.getNode("/sim/current-view/x-offset-m");
        obj.currentViewY = props.globals.getNode("/sim/current-view/y-offset-m");

        obj.symbol_reject = 0;
        obj.heading_deg=0;
        obj.roll_deg=0;
        obj.roll_rad=0;
        obj.pitch_deg=0;
        obj.VV_x=0;
        obj.VV_y=0;
        obj.mach=0;
        obj.rng=0;
        obj.eta_s=0;
#
#
# Load the target symbosl.
        obj.max_symbols = 10;
        obj.tgt_symbols =  setsize([],obj.max_symbols);

        for (var i = 0; i < obj.max_symbols; i += 1)
        {
            var name = "target_"~i;
            var tgt = obj.svg.getElementById(name);
            if (tgt != nil)
            {
                obj.tgt_symbols[i] = tgt;
                tgt.setVisible(0);
#                logprint(3, "HUD: loaded ",name);
            }
            else
                logprint(3, "HUD: could not locate ",name);
        }

            obj.dlzX      =170;
            obj.dlzY      =100;
            obj.dlzWidth  = 10;
            obj.dlzHeight = 90;
            obj.dlzHeight=60;
            obj.dlzY = 70;
            obj.dlzLW     =  1;
            obj.dlz      = obj.svg.createChild("group");
            obj.dlz2     = obj.dlz.createChild("group");
            obj.dlzArrow = obj.dlz.createChild("path")
                           .moveTo(0, 0)
                           .lineTo( -5, 4)
                           .moveTo(0, 0)
                           .lineTo( -5, -4)
                           .setColor(0,1,0)
                           .setStrokeLineWidth(obj.dlzLW);

            hudmath.HudMath.init([-5.63907,-0.08217,1.41853], [-5.7967,0.10206,1.2481], [256,296], [0.124048, 0.586015], [0.879649,0.045312], 0);
            obj.ccipGrp = obj.canvas.createGroup();
            obj.centerOrigin = hudmath.HudMath.getCenterOrigin();
            obj.ccipGrp.setTranslation(obj.centerOrigin);
            obj.pipperRadius = 10;
            obj.ccipPipper = obj.ccipGrp.createChild("path")
                          .moveTo(-obj.pipperRadius,0)
                          .arcSmallCW(obj.pipperRadius,obj.pipperRadius, 0, obj.pipperRadius*2, 0)
                          .arcSmallCW(obj.pipperRadius,obj.pipperRadius, 0, -obj.pipperRadius*2, 0)
                          .moveTo(-1,0)
                          .arcSmallCW(1,1, 0, 1*2, 0)
                          .arcSmallCW(1,1, 0, -1*2, 0)
                          .setStrokeLineWidth(1)
                          .setColor(0,1,0);
            obj.ccipCross = obj.ccipGrp.createChild("path")
                          .moveTo(-obj.pipperRadius, -obj.pipperRadius)
                           .lineTo(obj.pipperRadius, obj.pipperRadius)
                           .moveTo(-obj.pipperRadius, obj.pipperRadius)
                           .lineTo( obj.pipperRadius, -obj.pipperRadius)
                          .setStrokeLineWidth(1)
                          .hide()
                          .setColor(0,1,0);
            obj.ccipLine = obj.ccipGrp.createChild("group");

			# FLIR image
			obj.flirPicHD = obj.svg.createChild("image")
	                .set("src", "Aircraft/F-15/Nasal/HUD/flir"~flirImageReso~".png")
	                .setScale(256/flirImageReso,256/flirImageReso)#340,260
	                .set("z-index",10001);
	        obj.scanY = 0;
	        obj.scans = flirImageReso/(getprop("sim/model/f15/avionics/hud-flir-optimum")?4:2);

			# Loads the ASE circle objects
			var mr = 0.4*1.5;#milliradians
			obj.ASECircle = obj.canvas.createGroup();
			obj.ASECircle.setTranslation(obj.centerOrigin);
			obj.ASEC262 = obj.ASECircle.createChild("path")#rdsearch (Allowable Steering Error Circle (ASEC))
	            .moveTo(-262*mr,0)
	            .arcSmallCW(262*mr,262*mr, 0, 262*mr*2, 0)
	            .arcSmallCW(262*mr,262*mr, 0, -262*mr*2, 0)
	            .setStrokeLineWidth(1)
	            .setColor(0,1,0).hide()
	            .setTranslation(sx*0.5*uv_used,sy*0.25+262*mr*0.5);
	        obj.ASC = obj.ASECircle.createChild("path")# (Attack Steering Cue (ASC))
	            .moveTo(-8*mr,0)
	            .arcSmallCW(8*mr,8*mr, 0, 8*mr*2, 0)
	            .arcSmallCW(8*mr,8*mr, 0, -8*mr*2, 0)
	            .setStrokeLineWidth(1)
	            .setColor(0,1,0).hide();

	        obj.ASEC100 = obj.ASECircle.createChild("path")#irsearch
	            .moveTo(-100*mr,0)
	            .arcSmallCW(100*mr,100*mr, 0, 100*mr*2, 0)
	            .arcSmallCW(100*mr,100*mr, 0, -100*mr*2, 0)
	            .setStrokeLineWidth(1)
	            .setColor(0,1,0).hide()
	            .setTranslation(sx*0.5*uv_used,sy*0.25);
	        obj.ASEC120 = obj.ASECircle.createChild("path")#rdlock
	            .moveTo(-120*mr,0)
	            .arcSmallCW(120*mr,120*mr, 0, 120*mr*2, 0)
	            .arcSmallCW(120*mr,120*mr, 0, -120*mr*2, 0)
	            .setStrokeLineWidth(1)
	            .setColor(0,1,0).hide()
	            .setTranslation(sx*0.5*uv_used,sy*0.25);
	        obj.ASEC65 = obj.ASECircle.createChild("path")#irlock
	            .moveTo(-65*mr,0)
	            .arcSmallCW(65*mr,65*mr, 0, 65*mr*2, 0)
	            .arcSmallCW(65*mr,65*mr, 0, -65*mr*2, 0)
	            .setStrokeLineWidth(1)
	            .setColor(0,1,0).hide()
	            .setTranslation(sx*0.5*uv_used,sy*0.25);
	        obj.ASEC65Aspect  = obj.ASECircle.createChild("path")#small triangle on ASEC that denotes aspect of target
	            .moveTo(0,-65*mr)
	            .lineTo(-5*mr,-75*mr)
	            .lineTo(5*mr,-75*mr)
	            .lineTo(0,-65*mr)
	            .setStrokeLineWidth(1)
	            .setColorFill(0,1,0)
	            .setColor(0,1,0).hide()
	            #.set("z-index",10500)
	            .setTranslation(sx*0.5*uv_used,sy*0.25);
	        obj.ASEC120Aspect = obj.ASECircle.createChild("path")
	            .setCenter(0,0)
	            .moveTo(0,-0*mr)
	            .lineTo(-5*mr,-10*mr)
	            .lineTo(5*mr,-10*mr)
	            .lineTo(0,-0*mr)
	            .setColorFill(0,1,0)
	            .setStrokeLineWidth(1)
	            .setColor(0,1,0).hide()
	            #.set("z-index",10500)
	            .setTranslation(sx*0.5*uv_used,sy*0.25);

			var boxRadius = 10;
	        var boxRadiusHalf = boxRadius*0.5;
			var hairFactor = 0.8;
			obj.SeekerSymbols = obj.canvas.createGroup();
			obj.SeekerSymbols.setTranslation(obj.centerOrigin);
			obj.radarLock = obj.SeekerSymbols.createChild("path")
	            .moveTo(-boxRadius*hairFactor,0)
	            .horiz(boxRadiusHalf*hairFactor)
	            .lineTo(0,boxRadiusHalf*hairFactor)
	            .moveTo(boxRadius*hairFactor,0)
	            .horiz(-boxRadiusHalf*hairFactor)
	            .lineTo(0,-boxRadiusHalf*hairFactor)
	            .moveTo(0,boxRadius*hairFactor)
	            .vert(-boxRadiusHalf*hairFactor)
	            .lineTo(boxRadiusHalf*hairFactor,0)
	            .moveTo(0,-boxRadius*hairFactor)
	            .vert(boxRadiusHalf*hairFactor)
	            .lineTo(-boxRadiusHalf*hairFactor,0)
	            .setStrokeLineWidth(1)
	            .setColor(0,1,0).hide();
	        obj.irDiamond = obj.SeekerSymbols.createChild("path")
	            .moveTo(-boxRadius,0)
	            .lineTo(0,-boxRadius)
	            .lineTo(boxRadius,0)
	            .lineTo(0,boxRadius)
	            .lineTo(-boxRadius,0)
	            .setStrokeLineWidth(1)
	            .setColor(0,1,0).hide();
	        obj.irDiamondSmall = obj.SeekerSymbols.createChild("path")
	            .moveTo(-boxRadiusHalf*0.75,0)
	            .lineTo(0,-boxRadiusHalf*0.75)
	            .lineTo(boxRadiusHalf*0.75,0)
	            .lineTo(0,boxRadiusHalf*0.75)
	            .lineTo(-boxRadiusHalf*0.75,0)
	            .setStrokeLineWidth(1)
	            .setColor(0,1,0).hide();
	        obj.irCross = obj.SeekerSymbols.createChild("path")
	            .moveTo(-boxRadiusHalf*4,0)
	            .horiz(boxRadius*4)
	            .moveTo(0,-boxRadiusHalf*6)
	            .vert(boxRadius*6)
	            .setStrokeLineWidth(1)
	            .setColor(0,1,0).hide();

			# Steering cue & steer point
			obj.NavigationSymbols = obj.canvas.createGroup();
			obj.NavigationSymbols.setTranslation(obj.centerOrigin);
			obj.greatCircleSteeringCue = obj.NavigationSymbols.createChild("path")# nickname: tadpole
		        .moveTo(-2.5,0)
		        .arcSmallCW(2.5,2.5, 0, 2.5*2, 0)
		        .arcSmallCW(2.5,2.5, 0, -2.5*2, 0)
		        .moveTo(0,-2.5)
		        .vert(-10)
		        .setStrokeLineWidth(1)
		        .setColor(0,1,0);

			obj.steerPT = obj.NavigationSymbols.createChild("path")
		        .moveTo(-boxRadius*0.3, 0)
		        .lineTo(0, boxRadiusHalf*0.85)
		        .lineTo(boxRadius*0.3, 0)
		        .lineTo(0, -boxRadiusHalf*0.85)
		        .lineTo(-boxRadius*0.3, 0)
		        .setStrokeLineWidth(1)
		        .hide()
		        .setColor(0,1,0);

			# EEGS Gun mode
			obj.Bore = obj.canvas.createGroup();
			obj.Bore.setTranslation(obj.centerOrigin);
			obj.boreSymbol = obj.Bore.createChild("path")
                .moveTo(-5,0)
                .horiz(10)
                .moveTo(0,-5)
                .vert(10)
                .setStrokeLineWidth(1)
                .setColor(0,1,0);

			#EEGS: (other gun sights not made: lcos sslc)
	        obj.eegsGroup = obj.canvas.createGroup();
			obj.eegsGroup.setTranslation(obj.centerOrigin);
	        obj.funnelPartsMax = 51;#strf (hydra is 34)
	        obj.funnelParts = 17;#eegs (number of segments in funnel sides. If increase, remember to increase all relevant vectors also.)
	        obj.eegsRightX = obj.makeVector(obj.funnelParts,0);
	        obj.eegsRightY = obj.makeVector(obj.funnelParts,0);
	        obj.eegsLeftX  = obj.makeVector(obj.funnelParts,0);
	        obj.eegsLeftY  = obj.makeVector(obj.funnelParts,0);
	        obj.gunPos   = nil;#[[nil,nil],[nil,nil,nil],[nil,nil,nil,nil],[nil,nil,nil,nil,nil],[nil,nil,nil,nil,nil,nil],[nil,nil,nil,nil,nil,nil,nil],[nil,nil,nil,nil,nil,nil,nil,nil],[nil,nil,nil,nil,nil,nil,nil,nil,nil],[nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],[nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil]];
	        obj.eegsMe = {ac: geo.Coord.new(), eegsPos: geo.Coord.new(),shellPosX: obj.makeVector(obj.funnelPartsMax,0),shellPosY: obj.makeVector(obj.funnelPartsMax,0),shellPosDist: obj.makeVector(obj.funnelPartsMax,0)};
	        obj.lastTime = systime();
	        obj.averageDt = 0.100;
	        obj.eegsLoop = maketimer(obj.averageDt, obj, obj.displayEEGS);
	        obj.eegsLoop.simulatedTime = 1;
	        obj.resetGunPos();

			# Warning texts
			obj.WarningTexts = obj.canvas.createGroup();
			obj.WarningTexts.setTranslation(obj.centerOrigin);
			obj.altitudeDeck = obj.WarningTexts.createChild("text")
	            .setText("ALTITUDE")
	            .setTranslation(0,-75)
	            .setAlignment("center-center")
	            .setColor(0,1,0,1)
	            .setFont(aircraft.HUDFont)
	            .setFontSize(13, 1.4);
			obj.flyupLeft    = obj.WarningTexts.createChild("path")
	            .lineTo(-50,-50)
	            .moveTo(0,0)
	            .lineTo(-50,50)
	            .setStrokeLineWidth(1)
	            .setColor(0,1,0)
	            .hide();
	        obj.flyupRight  = obj.WarningTexts.createChild("path")
	            .lineTo(50,-50)
	            .moveTo(0,0)
	            .lineTo(50,50)
	            .setStrokeLineWidth(1)
	            .setColor(0,1,0)
	            .hide();
	        obj.flyup = obj.WarningTexts.createChild("text")
	            .setText("FLYUP")
	            .setTranslation(0,-75)
	            .setAlignment("center-center")
	            .setColor(0,1,0,1)
	            .setFont(aircraft.HUDFont)
	            .setFontSize(13, 1.4);
			obj.stby = obj.WarningTexts.createChild("text")
	            .setText("NO RAD")
	            .setTranslation(0,-165)
	            .setAlignment("center-top")
	            .setColor(0,1,0,1)
	            .setFont(aircraft.HUDFont)
	            .setFontSize(11, 1.1);
        #
        #
        # using the new property manager to update items on the HUD.
        # this is more efficient as the update methods are only called whenever the property (or properties) change by more than a specified amount
        obj.update_items = [
            props.UpdateManager.FromHashList(["ElectricsAcLeftMainBus","ControlsHudBrightness"] , 0.01, func(val)
                                      {
                                          if (val.ElectricsAcLeftMainBus <= 0
                                              or val.ControlsHudBrightness <= 0) {
                                              obj.svg.setVisible(0);
                                          } else {
                                              obj.svg.setVisible(1);
											  obj.color = [0.3,1,0.3,1];
											  obj.ASEC120Aspect.setColorFill(obj.color);
                                              obj.ASEC65Aspect.setColorFill(obj.color);
                                          }
                                      }),
            props.UpdateManager.FromHashValue("AltimeterIndicatedAltitudeFt", 1, func(val)
                                             {
                                                 obj.alt_range.setTranslation(0, val * alt_range_factor);
                                             }),

            props.UpdateManager.FromHashValue("VelocitiesAirspeedKt", 0.1, func(val)
                                      {
                                          obj.ias_range.setTranslation(0, val * ias_range_factor);
                                      }),
            props.UpdateManager.FromHashValue("ControlsHudSymRej", 0.1, func(val)
                                             {
                                                 obj.symbol_reject = val;
                                             }),
            props.UpdateManager.FromHashValue("OrientationHeadingDeg", 0.025, func(val)
                                      {
                                          obj.heading_deg = val;
                                          #heading tape
                                          if (val < 180)
                                            obj.heading_tape_position = -val*54/10;
                                          else
                                            obj.heading_tape_position = (360-val)*54/10;

                                          obj.heading_tape.setTranslation (obj.heading_tape_position,0);
                                      }),
            props.UpdateManager.FromHashList(["OrientationRollDeg","OrientationPitchDeg"], 0.025, func(val)
                                    {
                                        obj.roll_deg = val.OrientationRollDeg;
                                        obj.roll_rad = -obj.roll_deg*3.14159/180.0;
                                        obj.roll_pointer.setRotation (obj.roll_rad);
                                        var ptx = 0;
                                        obj.pitch_deg = val.OrientationPitchDeg;
                                        var pty = 392+ obj.pitch_deg * pitch_factor;

                                        obj.ladder.setRotation(obj.roll_rad);
                                        obj.ladder.setTranslation(ptx,pty);

                                        if (obj.pitch_deg>0)
                                          obj.ladder.setCenter (110,900-obj.pitch_deg*(1815/90));
                                        else
                                          obj.ladder.setCenter (110,900+obj.pitch_deg*-(1772/90));
                                    }),
            props.UpdateManager.FromHashList(["Alpha", "OrientationSideSlipDeg"], 0.001, func(val)
                                                        {
                                                            if (val.OrientationSideSlipDeg == nil or val.Alpha == nil)
                                                            return;
                                                            obj.VV_x = (val.OrientationSideSlipDeg or 0)*10; # adjust for view
                                                            obj.VV_y = (val.Alpha or 0)*10; # adjust for view
                                                            obj.VV.setTranslation (obj.VV_x, obj.VV_y);
                                                        }),
            props.UpdateManager.FromHashList(["InstrumentedG", "CadcOwsMaximumG"], 0.05, func(val)
                                                        {
                                                            obj.window8.setText(sprintf("%02d %02d G",
                                                                                        math.round(val.InstrumentedG*10.0),
                                                                                        math.round(val.CadcOwsMaximumG*10.0)));
                                                        }),
            props.UpdateManager.FromHashList(["Alpha",
                                                        "ControlsGearBrakeParking",
                                                        "AirspeedIndicatorIndicatedMach",
                                                        "ControlsGearGearDown"], 0.01, func(val)
                                                        {
                                                            obj.alpha = val.Alpha or 0;
                                                            obj.mach = val.AirspeedIndicatorIndicatedMach or 0;
                                                            if(val.ControlsGearBrakeParking) {
	                                                            obj.window7.setText("BRAKES");
                                                            } else {
	                                                            obj.window7.setText(sprintf("%1.3f Ma",obj.mach));
															}
	                                                        obj.window10.setText(sprintf("a  %d", obj.alpha));
                                                        }),
            props.UpdateManager.FromHashList(["VelocitiesAirspeedKt", "VelocitiesGroundspeedKt", "AltimeterIndicatedAltitudeFt", "Alpha", "ControlsGearGearDown", "FeetPerSecond"], nil, func(val)
                                                        {
                                                            obj.window9.setText(sprintf("%03d", math.round(val.VelocitiesAirspeedKt)));
                                                            obj.window13.setText(sprintf("G %03d", math.round(val.VelocitiesGroundspeedKt)));
                                                            if (getprop("gear/gear[0]/wow") == 1) {
                                                                obj.window1.setText("GROUND");
                                                            } else {
                                                                obj.window1.setText(sprintf(" %05d", math.round(val.AltimeterIndicatedAltitudeFt)));
                                                            }
                                                            obj.window1.setVisible(1);

                                                            obj.window14.setText(sprintf(" %04d fps", math.round(val.FeetPerSecond)));
                                                            obj.window14.setVisible(1);
                                                        }),
            props.UpdateManager.FromHashList(["OrientationHeadingDeg", "OrientationPitchDeg", "OrientationRollDeg"], nil, func(val)
                                                        {
														# get all the active steerpoints
														me.plan = flightplan();
										                me.planSize = me.plan.getPlanSize();
														for (me.j = 0; me.j < me.planSize;me.j+=1) {
															me.wp = me.plan.getWP(me.j);
															me.wpC = geo.Coord.new();
															me.wpC.set_latlon(me.wp.lat,me.wp.lon);
														}
														# the Y position is still not accurate due to HUD being at an angle, but will have to do.
														 if (steerpoints.getCurrentNumber() != 0 and getprop("autopilot/route-manager/active")) {  # and !hdp.getproper("dgft")
															 obj.steerDir = steerpoints.getCurrentDirectionForHUD();
															 obj.wpbear = obj.steerDir[0];
															 if (obj.wpbear != nil) {
																 obj.wpbear = geo.normdeg180(obj.wpbear-val.OrientationHeadingDeg);
																 obj.tadpoleX = hudmath.HudMath.getCenterPosFromDegs(obj.wpbear,0)[0];

																 if (obj.tadpoleX > sx * 0.20) {
																	 obj.tadpoleX = sx * 0.20;
																 } elsif (obj.tadpoleX < -sx * 0.20) {
																	 obj.tadpoleX = -sx * 0.20;
																 }
																 obj.greatCircleSteeringCue.setTranslation(obj.tadpoleX, obj.VV_y);
																 obj.greatCircleSteeringCue.setRotation(obj.wpbear*D2R);
																 obj.greatCircleSteeringCue.show();
																 if (obj.steerDir[1] != nil) {
																	obj.steerCart = vector.Math.eulerToCartesian2(-obj.steerDir[0], obj.steerDir[1]);
																	obj.steerLocal = vector.Math.yawPitchRollVector(val.OrientationHeadingDeg, -val.OrientationPitchDeg, -val.OrientationRollDeg, obj.steerCart);
																	obj.steerLocalEuler = vector.Math.cartesianToEuler(obj.steerLocal);
																	obj.steerHUD = hudmath.HudMath.getCenterPosFromDegs(obj.steerLocalEuler[0]==nil?0:geo.normdeg180(obj.steerLocalEuler[0]),obj.steerLocalEuler[1]);
																	obj.steerPT.setTranslation(obj.steerHUD);
																	obj.steerPT.show();
																 } else {
																	obj.steerPT.hide();
																 }
															 } else {
																 obj.greatCircleSteeringCue.hide();
																 obj.steerPT.hide();
															 }
														 } else {
															 obj.greatCircleSteeringCue.hide();
															 obj.steerPT.hide();
														 }
                                                        }),
            props.UpdateManager.FromHashList(["OrientationHeadingDeg", "OrientationPitchDeg", "OrientationRollDeg", "VelocitiesAirspeedKt"], nil, func(val)
                                                        {
															# Determine the hypothical estimated time for missile to intercept target (if any) (missile not launched yet)
															# Constant variables :
															var mean_120_d_speed = 1850; # in mph - mean speed during whole course is about Ma 2.5 - 3
															var mean_9_x_speed = 1450; # in mph - mean speed during whole course is about Ma 1.8 - 2.2
															var mean_speed = 1; # placeholder
															weap = pylons.fcs.getSelectedWeapon(); # get selected weapon data
															if (weap != nil and weap.parents[0] == armament.AIM) {
																if (weap.type != "AIM-9X" and weap.type != "AIM-120D" and getprop("sim/model/f15/armament/ccip-off") == 0) {
																	# Time to hit ground already computed, just gotta display it there
																	fall_time_mins = getprop("sim/model/f15/armament/fall-time-mins");
																	fall_time_secs = getprop("sim/model/f15/armament/fall-time-secs");
																	obj.window17.setText(sprintf("%02d m %02d s", fall_time_mins, fall_time_secs));
																	obj.window17.setVisible(1);
																} elsif ((weap.type == "AIM-120D" or weap.type == "AIM-9X") and pylons.fcs.isLock()) { # only works if we have a radar lock; meaning AIM-9X won't have TTI if not slaved to radar
																	if (weap.type == "AIM-9X") {
																		mean_speed = mean_9_x_speed;
																	} elsif (weap.type == "AIM-120D") {
																		mean_speed = mean_120_d_speed;
																	}
																	var dlzArray = pylons.getDLZ();
																	if (dlzArray == nil or size(dlzArray) == 0) {
																		return;
																	}

																	if (getprop("sim/model/f15/armament/missile-fired-path") == nil or getprop(getprop("sim/model/f15/armament/missile-fired-path") ~ "/position/latitude-deg") == nil) {  # if no recent missile has been fired, calculate TTI from the aircraft
																		distance_to_target = dlzArray[4] * 1.15;  # in nmi then to mi
																		var live = 0;
																	} else {
																		data_root = getprop("sim/model/f15/armament/missile-fired-path");
																		missile_lat = getprop(data_root ~ "/position/latitude-deg");
																		missile_lon = getprop(data_root ~ "/position/longitude-deg");
																		missile_alt = getprop(data_root ~ "/position/altitude-ft");
																		missileCoord = geo.Coord.new().set_latlon(missile_lat, missile_lon, missile_alt);
																		distance_to_target = dlzArray[6].direct_distance_to(missileCoord)*M2NM*1.15;
																		#mean_speed = getprop(data_root ~ "/velocities/true-airspeed-kt");  # it's actually inaccurate as it's got different speed phases
																		var live = 1;
																	}
																	target_speed = dlzArray[5] * 1.15;  # in kts then to mph

																	# More complicated formula taking angles in account. This is too overcomplicated and
																	# a simple 9th grade v = d/t => t = d/v works just fine
																	#
																	#o_angle = dlzArray[7];  # angle between aircraft's vector and target's vector
																	#print(o_angle);
																	#
																	#calculus = ((mean_speed ^ 2) + (target_speed ^ 2) - (2 * mean_speed * target_speed * math.cos(o_angle)));
																	#if (calculus < 0) {  # make sure the calculus is positive
																	#	obj.window17.setText("XX m XX s");
																	#	obj.window17.setVisible(1);
																	#	return;
																	#}
																	#V_rel = math.sqrt(calculus);  # relative velocity (in mph)
																	V_rel = mean_speed - target_speed;
																	tti = distance_to_target / V_rel;  # here in hours
																	tti_rel = tti * 60;  # convert tti from hrs to mins

																	tti_mins = sprintf("%.0f", tti_rel);
																	tti_secs = (tti_rel - tti_mins) * 60;  # remove whole minutes for seconds
																	if (tti_secs < 0) {  # tiny fix
																		tti_mins = tti_mins - 1;
																		tti_secs = 60 + tti_secs;
																	}
																	if (live == 0) {  # if missile ain't active
																		obj.window17.setText(sprintf("%02d m %02d s", tti_mins, tti_secs));
																	} else {  # if missile is active
																		obj.window17.setText(sprintf("L %02d m %02d %1.1f n", tti_mins, tti_secs, distance_to_target / 1.15));  #  if missile's live, indicate it is an aditionally display its distance to the target
																	}
																	obj.window17.setVisible(1);
																} else {
																	obj.window17.setText("XX m XX s");
																	obj.window17.setVisible(1);
																}
															} else {
																obj.window17.setVisible(0);
															}
                                                        }),
            props.UpdateManager.FromHashList(["AutopilotRouteManagerActive",
                                                        "AutopilotRouteManagerWpDist",
                                                        "AutopilotRouteManagerWpEtaSeconds",
                                                        "ControlsGearGearDown"], 0.1, func(val)
                                                        {
                                                            if (val.AutopilotRouteManagerActive) {
                                                                obj.rng = val.AutopilotRouteManagerWpDist;
                                                                obj.eta_s = val.AutopilotRouteManagerWpEtaSeconds;
                                                                if (obj.rng != nil) {
                                                                    obj.HudNavRangeDisplay =sprintf("N %4.1f", obj.rng);
                                                                } else {
                                                                    obj.HudNavRangeDisplay = "N XXX";
                                                                }

                                                                if (obj.eta_s != nil) {
																	nav_mins = sprintf("%.0f", obj.eta_s / 60);
																	nav_secs = (obj.eta_s / 60 - nav_mins) * 60;  # remove whole minutes for seconds
																	if (nav_secs < 0) {  # tiny fix
																		nav_mins = nav_mins - 1;
																		nav_secs = 60 + nav_secs;
																	}
	                                                                obj.HudNavRangeETA = sprintf("%02d m %02d s", nav_mins, nav_secs);
                                                                } else {
                                                                	obj.HudNavRangeETA = "XX MIN";
																}
                                                            } else {
                                                                obj.HudNavRangeDisplay = "";
                                                                obj.HudNavRangeETA = "";
                                                            }
                                                        }),
			props.UpdateManager.FromHashList(["AltitudeDeckMax",
														"AltitudeDeckMin",
														"AltitudeDeckMinEnabled",
														"AltitudeDeckMaxEnabled",
														"AltimeterIndicatedAltitudeFt",
														"VNE",
														"TimeTilCrash",
														"BingoFuel",
														"VelocitiesAirspeedKt",
														"RadarStandby"], 0.1, func(val)
														{
															if (val.AltitudeDeckMinEnabled and (val.AltimeterIndicatedAltitudeFt < val.AltitudeDeckMin)) {
																obj.altitudeDeck.show();
																setprop("sim/model/f15/avionics/altitude-deck-hit", 1);
															} elsif (val.AltitudeDeckMaxEnabled and (val.AltimeterIndicatedAltitudeFt > val.AltitudeDeckMax)) {
																obj.altitudeDeck.show();
																setprop("sim/model/f15/avionics/altitude-deck-hit", 1);
															} else {
																obj.altitudeDeck.hide();
																setprop("sim/model/f15/avionics/altitude-deck-hit", 0);
															}
															if (val.TimeTilCrash != nil and val.TimeTilCrash > 0 and val.TimeTilCrash < 8) {
		                                                     	obj.flyup.setText("FLYUP");
		                                                     	obj.flyup.show();
															} elsif (getprop("sim/time/elapsed-sec") > 2 and val.BingoFuel > 0 and getprop("fdm/jsbsim/systems/electrics/ac-essential-bus1") > 0) {
		                                                     	obj.flyup.setText("FUEL");
		                                                     	obj.flyup.show();
															} elsif (val.VNE < val.VelocitiesAirspeedKt) {
															} else {
																obj.flyup.hide();
															}
															obj.flyup.update();
			                                                 if (val.TimeTilCrash != nil and val.TimeTilCrash>0 and val.TimeTilCrash<10.5) {
			                                                    flyupAmount = math.max(0,obj.extrapolate(val.TimeTilCrash,8,9.5,0,1));
			                                                    obj.flyupLeft.setTranslation(-flyupAmount*150,0);
			                                                    obj.flyupRight.setTranslation(flyupAmount*150,0);
			                                                    obj.flyupLeft.show().update();
			                                                    obj.flyupRight.show().update();
																setprop("sim/model/f15/avionics/pullup", 1);
			                                                } else {
			                                                    obj.flyupLeft.hide();
			                                                    obj.flyupRight.hide();
																setprop("sim/model/f15/avionics/pullup", 0);
			                                                }

															# NO RAD label if radar's either in standby or offline
															if (val.RadarStandby) {
																obj.stby.show();
															} else {
																obj.stby.hide();
															}
											            }),
            props.UpdateManager.FromHashList(["ControlsArmamentMasterArmSwitch",
                                                        "ControlsArmamentWeaponSelector",
                                                        "ArmamentRounds",
                                                        "ArmamentAim9Count",
                                                        "ArmamentAim120Count",
                                                        "ArmamentAim7Count",
                                                        "ArmamentAgmCount",
                                                        "RadarActiveTargetAvailable",
                                                        "RadarActiveTargetDisplay",
                                                        "RadarActiveTargetCallsign",
                                                        "RadarActiveTargetType",
                                                        "RadarActiveTargetRange",
                                                        "RadarActiveTargetClosure",
                                                        "HudNavRangeDisplay",
                                                        "HudNavRangeETA",
														"OrientationHeadingDeg",
														"ArmamentRippleCount"], nil, func(val)
                                                        {
                                                            if (val.ControlsArmamentMasterArmSwitch) {
                                                                obj.window11.setVisible(1);
                                                                obj.window15.setVisible(1);
                                                                obj.window16.setVisible(1);
                                                                obj.window15.setText(sprintf("CHF %03d",getprop("ai/submodels/submodel[5]/count")));
                                                                obj.window16.setText(sprintf("FLR %03d",getprop("ai/submodels/submodel[6]/count")));
																obj.boreSymbol.hide();
                                                                weapon_type = getprop("sim/model/f15/systems/armament/selected-arm");
                                                                obj.window11.setText(weapon_type);
                                                                var w_s = val.ControlsArmamentWeaponSelector;
                                                                obj.window2.setVisible(1);
																eegsShow = 0;
																obj.window18.setVisible(0);

                                                                if (w_s == 0) {
                                                                    obj.window2.setText(sprintf("%3d",val.ArmamentRounds));
																	eegsShow = 1;
																	obj.boreSymbol.show();
                                                                } else if (w_s == 1) {
                                                                    obj.window2.setText(sprintf("%2d SRM", val.ArmamentAim9Count));
	                                                                obj.window18.setVisible(1);
																	if (pylons.fcs.getSelectedWeapon() != nil and pylons.fcs.getSelectedWeapon().isCaged()) {
																		obj.window18.setText("Caged");
																	} else {
																		obj.window18.setText("Uncaged");
																	}
                                                                } else if (w_s == 2){
                                                                    obj.window2.setText(sprintf("%2d AAM", val.ArmamentAim120Count
                                                                                                + val.ArmamentAim7Count));
                                                                } else if (w_s == 5){
                                                                    obj.window2.setText(sprintf("%2d GND", val.ArmamentAgmCount));
																	obj.window18.setVisible(1);
																	obj.window18.setText(sprintf("%2d RIPL", val.ArmamentRippleCount));
                                                                }
                                                                if (val.RadarActiveTargetAvailable or 0) {
                                                                    obj.window3.setText(val.RadarActiveTargetCallsign);
                                                                    var model = "XX";
                                                                    if (val.RadarActiveTargetType != "")
                                                                    model = val.RadarActiveTargetType;

                                                                    # these labels aren't correct - but we don't have a full simulation of the targetting and missiles so
                                                                    # have no real idea on the details of how this works.
                                                                    if (val.RadarActiveTargetDisplay){
                                                                        obj.window4.setText(sprintf("RNG %3.1f", val.RadarActiveTargetRange));
                                                                        obj.window5.setText(sprintf("CLO %-3d", val.RadarActiveTargetClosure));
																		obj.window6.setVisible(1);
                                                                    } else{
                                                                        obj.window4.setText("");
                                                                        obj.window5.setText("");
																		obj.window6.setVisible(0);
                                                                    }

																	# Determine the target's aspect
																	var aspect = math.round(awg_9.active_u.get_aspect()/10.0);
																	if (math.abs(aspect) > 17) {
						                                                var rel_aspect = "H  ";
						                                            } elsif (math.abs(aspect) < 1) {
						                                                var rel_aspect = "T  ";
																	} else {
																		var rel_aspect = sprintf("%2d%s", aspect, aspect > 0 ? "R" : "L");
																	}
                                                                    obj.window6.setText(rel_aspect);  # SRM UNCAGE / TARGET ASPECT
                                                                } else {
                                                                    # this else added by Leto
                                                                    obj.window3.setText("");
                                                                    obj.window4.setText("");
                                                                    obj.window5.setText("");
                                                                    obj.window6.setText("");
                                                                    obj.window6.setVisible(0); # SRM UNCAGE / TARGET ASPECT
                                                                }
                                                            } else {
																eegsShow = 0;
																obj.boreSymbol.hide();
                                                                obj.window2.setVisible(0);
                                                                obj.window11.setVisible(0);
                                                                obj.window15.setVisible(0);
                                                                obj.window16.setVisible(0);
																obj.window17.setVisible(0);
																obj.window18.setVisible(0);
                                                                if (val.HudNavRangeDisplay != "")
                                                                obj.window3.setText("NAV");
                                                                else
                                                                obj.window3.setText("");
                                                                obj.window4.setText(val.HudNavRangeDisplay);
                                                                obj.window5.setText(val.HudNavRangeETA);
                                                                obj.window6.setVisible(0); # SRM UNCAGE / TARGET ASPECT
                                                            }
                                                        }
                                                    ),
                           ];
return obj;
},
#
#
# get a text element from the SVG and set the font / sizing
    get_text : func(id, font, size, ratio)
    {
        var el = me.svg.getElementById(id);
        el.setFont(font).setFontSize(size,ratio);
        return el;
    },

#
#
# Get an element from the SVG; handle errors; and apply clip rectangle
# if found (by naming convention : addition of _clip to object name).
    get_element : func(id) {
        var el = me.svg.getElementById(id);
        if (el == nil)
        {
            logprint(3, "Failed to locate ",id," in SVG");
            return el;
        }
        var clip_el = me.svg.getElementById(id ~ "_clip");
        if (clip_el != nil)
        {
            clip_el.setVisible(0);
            var tran_rect = clip_el.getTransformedBounds();

            var clip_rect = sprintf("rect(%d,%d, %d,%d)",
                                   tran_rect[1], # 0 ys
                                   tran_rect[2],  # 1 xe
                                   tran_rect[3], # 2 ye
                                   tran_rect[0]); #3 xs
#            logprint(3, id," using clip element ",clip_rect, " trans(",tran_rect[0],",",tran_rect[1],"  ",tran_rect[2],",",tran_rect[3],")");
#   see line 621 of simgear/canvas/CanvasElement.cxx
#   not sure why the coordinates are in this order but are top,right,bottom,left (ys, xe, ye, xs)
            el.set("clip", clip_rect);
            el.set("clip-frame", canvas.Element.PARENT);
        }
        return el;
    },

#
#
#
	extrapolate: func (x, x1, x2, y1, y2) {
		return y1 + ((x - x1) / (x2 - x1)) * (y2 - y1);
	},
	interpolate: func (x, x1, x2, y1, y2) {
		return math.clamp(me.extrapolate(x, x1, x2, y1, y2),math.min(y1,y2),math.max(y1,y2));
	},
	clamp: func(v, min, max) { v < min ? min : v > max ? max : v },

	resetGunPos: func {
	   me.gunPos   = [];
	   for(i = 0;i < me.funnelPartsMax;i+=1){
		 var tmp = [];
		 for(var myloopy = 0;myloopy <= i+1;myloopy+=1){
		   append(tmp,nil);
		 }
		 append(me.gunPos, tmp);
	   }
    },

    makeVector: func (siz,content) {
	   var vec = setsize([],siz*2);
	   var k = 0;
	   while(k<siz*2) {
		   vec[k] = content;
		   k += 1;
	   }
	   return vec;
    },

    update : func(notification) {

		# Update the bore's cross
		me.boreSymbol.setTranslation(hudmath.HudMath.getBorePos());

		# EEGS mode's status update
		me.eegsGroup.setVisible(eegsShow);
        if (eegsShow and !me.eegsLoop.isRunning) {
            me.eegsLoop.start();
        } elsif (!eegsShow and me.eegsLoop.isRunning) {
            me.eegsLoop.stop();
        }

		# FLIR
		me.texelPerDegreeX = hudmath.HudMath.getPixelPerDegreeXAvg(5);
        me.texelPerDegreeY = hudmath.HudMath.getPixelPerDegreeYAvg(5);

		me.xBore = int(276*0.5/(256/flirImageReso));
		me.yBore = flirImageReso-1-int((hudmath.HudMath.getCenterOrigin()[1]+hudmath.HudMath.getBorePos()[1])/(256/flirImageReso));
		me.distMin = getprop("velocities/groundspeed-kt")*getprop("sim/model/f15/avionics/hud-flir-distance-min");
		me.distMax = getprop("velocities/groundspeed-kt")*getprop("sim/model/f15/avionics/hud-flir-distance-max");
		me.cont = getprop("sim/model/f15/avionics/hud-flir-cont");
		me.brt = getprop("sim/model/f15/avionics/hud-flir-brt");
		if (me.brt > 0 and getprop("sim/model/f15/payload/selected/lantirn-nav-pod") == 1 and me.color[3] != 0 and getprop("sim/model/f15/avionics/hud-flir-on")) {
			for(me.x = 0; me.x < flirImageReso; me.x += 1) {
				me.xDevi = (me.x-me.xBore)*(256/flirImageReso);
				me.xDevi /= me.texelPerDegreeX;
				for(me.y = me.scanY; me.y < me.scanY+me.scans; me.y += 1) {
					me.yDevi = (me.y-me.yBore)*(256/flirImageReso);
					me.yDevi /= me.texelPerDegreeY;
					me.value = 0;
					me.start = geo.viewer_position();
					me.vecto = [math.cos(me.xDevi*D2R)*math.cos(me.yDevi*D2R),math.sin(-me.xDevi*D2R)*math.cos(me.yDevi*D2R),math.sin(me.yDevi*D2R)];

					me.direction = vector.Math.vectorToGeoVector(vector.Math.rollPitchYawVector(getprop("orientation/roll-deg"),getprop("orientation/pitch-deg"),-getprop("orientation/heading-deg"), me.vecto),me.start);
					me.intercept = get_cart_ground_intersection({x:me.start.x(),y:me.start.y(),z:me.start.z()}, me.direction);
					if (me.intercept == nil) {
						me.value = 0;
					} else {
						me.terrain = geo.Coord.new();
						me.terrain.set_latlon(me.intercept.lat, me.intercept.lon ,me.intercept.elevation);
						me.value = math.min(1,((math.max(me.distMin-me.distMax, me.distMin-me.start.direct_distance_to(me.terrain))+(me.distMax-me.distMin))/me.distMax));
					}
					me.gain = math.min(1,1+2*me.cont*(1-2*me.value));
					me.flirPicHD.setPixel(me.x, me.y, [me.color[0],me.color[1],me.color[2],me.brt*math.pow(me.value, me.gain)]);
				}
			}
			me.scanY+=me.scans;if (me.scanY>flirImageReso-me.scans) me.scanY=0;
			#me.flirPicHD.setPixel(me.xBore, me.yBore, [0,0,1,1]); # blue dot at bore
			me.flirPicHD.dirtyPixels();
			me.flirPicHD.show();
		} else {
			me.flirPicHD.hide();
		}

        me.dlzArray = aircraft.getDLZ();
#me.dlzArray =[10,8,6,2,9];#test
        if (me.dlzArray == nil or size(me.dlzArray) == 0) {
                me.dlz.hide();
        } else {
            me.dlz.setTranslation(me.dlzX,me.dlzY);
            me.dlz2.removeAllChildren();
            me.dlzArrow.setTranslation(0,-me.dlzArray[4]/me.dlzArray[0]*me.dlzHeight);
            me.dlzGeom = me.dlz2.createChild("path")
                    .moveTo(0, -me.dlzArray[3]/me.dlzArray[0]*me.dlzHeight)
                    .lineTo(0, -me.dlzArray[2]/me.dlzArray[0]*me.dlzHeight)
                    .lineTo(me.dlzWidth, -me.dlzArray[2]/me.dlzArray[0]*me.dlzHeight)
                    .lineTo(me.dlzWidth, -me.dlzArray[3]/me.dlzArray[0]*me.dlzHeight)
                    .lineTo(0, -me.dlzArray[3]/me.dlzArray[0]*me.dlzHeight)
                    .lineTo(0, -me.dlzArray[1]/me.dlzArray[0]*me.dlzHeight)
                    .lineTo(me.dlzWidth, -me.dlzArray[1]/me.dlzArray[0]*me.dlzHeight)
                    .moveTo(0, -me.dlzHeight)
                    .lineTo(me.dlzWidth, -me.dlzHeight-3)
                    .lineTo(me.dlzWidth, -me.dlzHeight+3)
                    .lineTo(0, -me.dlzHeight)
                    .setStrokeLineWidth(me.dlzLW)
                    .setColor(0,1,0);
            me.dlz.show();
        }



        if(me.FocusAtInfinity)
          {
              # parallax correction
              var current_x = me.currentViewX.getValue();
              var current_y = me.currentViewY.getValue();
              #        var current_z = getprop("/sim/current-view/z-offset-m");

              var dx = me.view[0] - current_x;
              var dy = me.view[1] - current_y;

              me.svg.setTranslation(me.baseTranslation[0]-dx*1024, me.baseTranslation[1]+dy*1024);
          }

        if (awg_9.active_u == nil) {
            notification.RadarActiveTargetAvailable = 0;
            notification.RadarActiveTargetCallsign = "";
            notification.RadarActiveTargetType = "";
            notification.RadarActiveTargetRange = 0;
            notification.RadarActiveTargetClosure = 0;
        } else {
            notification.RadarActiveTargetAvailable = 1;
#logprint(3, "active callsign ",awg_9.active_u.Callsign,":");
            if (awg_9.active_u.Callsign != nil)
              notification.RadarActiveTargetCallsign = awg_9.active_u.Callsign.getValue();
            else
              notification.RadarActiveTargetCallsign = "XXX";

            notification.RadarActiveTargetType = awg_9.active_u.ModelType;
            notification.RadarActiveTargetDisplay = awg_9.active_u.get_display();
            notification.RadarActiveTargetRange = awg_9.active_u.get_range();
            notification.RadarActiveTargetClosure = awg_9.active_u.get_closure_rate();
        }
        notification.HudNavRangeDisplay = me.HudNavRangeDisplay;
        notification.HudNavRangeETA = me.HudNavRangeETA;

        foreach(var update_item; me.update_items)
        {
            update_item.update(notification);
        }

		# ASE Circle
		# Taken and adapted from the F-16 by Jimmy L. Miles
		me.asec262 = 0;
		me.asec120 = 0;
		me.asec100 = 0;
		me.asec65  = 0;
		var currASEC = nil;
		me.showFov = 0;

		me.weapon_selected = pylons.fcs.selectedType;
		me.weapn = pylons.fcs.getSelectedWeapon();

		if (getprop("sim/model/f15/controls/armament/master-arm-switch") != 0 and pylons.fcs != nil) {

			if (me.weapon_selected != nil) {
				var mr = 0.4;
				if (me.weapon_selected == "AIM-9X") {
					if (me.weapn != nil) {
						if (me.weapn.status == armament.MISSILE_LOCK and !getprop("instrumentation/radar/radar-standby")) {
							me.asec65 = 1;
							currASEC = nil;#[sx*0.5,sy*0.25];
						} elsif (!getprop("instrumentation/radar/radar-standby")) {
							me.asec100 = 1;
							currASEC = nil;#[sx*0.5,sy*0.25];
						}
					}
				} elsif (me.weapon_selected == "AIM-120D") {
					if (me.weapn != nil) {
                        if (me.weapn.status == armament.MISSILE_LOCK and !getprop("instrumentation/radar/radar-standby")) {
                            me.asec120 = 1;
                            currASEC = [sx*0.5,sy*0.25];
                        } elsif (!getprop("instrumentation/radar/radar-standby")) {
                            me.asec262 = 1;
                            currASEC = [sx*0.5,sy*0.25+262*mr*0.5];
                        }
                    }
				}
			}
		}

		me.ASEC262.setVisible(me.asec262);
        me.ASEC100.setVisible(me.asec100);
        me.ASEC120.setVisible(me.asec120);
        me.ASEC65.setVisible(me.asec65);

		me.irL = 0;
        me.irS = 0;
        me.rdL = 0;
        me.irT = 0;
        me.rdT = 0;
        me.irB = 0;
		if (pylons.fcs != nil and pylons.fcs.isLock()) {
            if (me.weapon_selected == "AIM-120D" or me.weapon_selected == "AIM-9X") {
                var aim = pylons.fcs.getSelectedWeapon();
                if (aim != nil) {
                    var coords = aim.getSeekerInfo();
                    if (coords != nil) {
                        me.seekPos = hudmath.HudMath.getCenterPosFromDegs(coords[0],coords[1]);
                        me.irDiamond.setTranslation(me.seekPos);
                        me.radarLock.setTranslation(me.seekPos);
                    }
                }
            }
            me.asp = awg_9.getPriorityTarget();  # simply return the active target if any
            if (me.asp != nil) {
                me.lastH = me.asp.get_heading();  # should be last heading, but we don't have that function in the F-15's radar
            } else {
                me.lastH = nil;
            }
            if (me.lastH != nil and (me.weapon_selected == "AIM-120D")) {
                me.ASEC120Aspect.setRotation(D2R*(me.lastH-getprop("orientation/heading-deg")+180));
                me.rdL = 1;
                me.rdT = 1;
            } elsif (me.lastH != nil and (me.weapon_selected == "AIM-9X")) {
                me.ASEC65Aspect.setRotation(D2R*(me.lastH-getprop("orientation/heading-deg")+180));
                me.irT = 1;
            }
        } else {
            #me.target_locked.setRotation(0);
        }

		me.loft_cue = 0;
		if (currASEC != nil) {
            # disabled for now as it has issues
            me.cue = nil;
            call(func {me.cue = me.weapn.getIdealFireSolution();},[], nil, nil, var err = []);
            if(size(err)) {
                print(err[0]);
                print(err[1]);
            }
            if (me.cue != nil) {
                me.cueXDeg1 = geo.normdeg180(me.cue[0]-hdp.getproper("heading"));
                me.cueYDeg1 = me.cue[1]-hdp.getproper("pitch");

                #printf("%02d, %02d", me.cueXDeg1, me.cueYDeg1);

                # account for aircraft roll:
                me.cueXDeg = me.cueXDeg1*math.cos(-getprop("orientation/roll-deg")*D2R)+me.cueYDeg1*math.sin(-getprop("orientation/roll-deg")*D2R);
                me.cueYDeg = -me.cueXDeg1*math.sin(-getprop("orientation/roll-deg")*D2R)+me.cueYDeg1*math.cos(-getprop("orientation/roll-deg")*D2R);

                me.ascPos = hudmath.HudMath.getPosFromDegs(me.cueXDeg, me.cueYDeg);
                me.ascpixel = math.sqrt(me.ascPos[0]*me.ascPos[0]+me.ascPos[1]*me.ascPos[1]);

                if (me.ascpixel > 48) {
                    me.ascReduce = 48/me.ascpixel;# hard clamp
                } elsif (me.ascpixel > 0) {
                    me.ascReduce = 1;#math.pow(me.ascpixel/48,0.65) * 48/me.ascpixel;# soft clamp. ASEC120 is 48 pixel radius.
                } else {
                    me.ascReduce = 1;
                }

                me.ASC.setTranslation(currASEC[0]+me.ascReduce*me.ascPos[0], currASEC[1]+me.ascReduce*me.ascPos[1]);#currASEC = center of ASEC
                #me.ASC2.setTranslation(hudmath.HudMath.getCenterPosFromDegs(me.cueXDeg1, me.cueYDeg1));#currASEC = center of ASEC

                me.loft_cue = me.cue[1];# set loft cue for DLZ
                showASC = 1;
            } else {
                #print("me.cue is nil");
            }
        } else {
            #print("currASEC is nil");
        }

		if(getprop("sim/model/f15/controls/armament/master-arm-switch") != 0 and pylons.fcs != nil and pylons.fcs.getAmmo() > 0) {
            var aim = pylons.fcs.getSelectedWeapon();
            if (me.weapon_selected == "AIM-120D") {
                if (!pylons.fcs.isLock()) {
                    me.radarLock.setTranslation(0, -sy*0.25+262*0.3*0.5);
                    me.rdL = 1;
                }
            } elsif (me.weapon_selected == "AIM-9X") {
                if (aim != nil and aim.isCaged()) {
                    var coords = aim.getSeekerInfo();
                    if (coords != nil) {
                        me.irDiamondSmall.setTranslation(hudmath.HudMath.getCenterPosFromDegs(coords[0],coords[1]));
                        me.irS = 1;
                    }
                } elsif (aim != nil) {
                    var coords = aim.getSeekerInfo();
                    if (coords != nil) {
                        me.irDiamond.setTranslation(hudmath.HudMath.getCenterPosFromDegs(coords[0],coords[1]));
                        me.irL = 1;
                    }
                }
                if (pylons.bore == 1) {
                    if (aim != nil) {
                        me.submode = 1;
                        me.irCross.setTranslation(hudmath.HudMath.getCenterPosFromDegs(0,-4));
                        me.irB = 1;

                    }
                }
            }
        }

		if (pylons.fcs.isLock() and me.dlzArray != nil and size(me.dlzArray) != 0) {
            me.scale120 = me.extrapolate(me.dlzArray[4],me.dlzArray[2],me.dlzArray[3],1,30/120);
            me.scale120 = me.clamp(me.scale120,30/120,1);
            me.ASEC120.setScale(me.scale120,me.scale120);#todo error
            me.ASEC120.setStrokeLineWidth(1/me.scale120);
            #me.ASEC120Aspect.setScale(me.scale120,me.scale120);
            #me.ASEC120Aspect.setStrokeLineWidth(1/me.scale120);
            me.ASEC120Aspect.setTranslation(sx*0.5,sy*0.25-me.scale120*0.4*120);#0.4=mr
            #me.ASEC120Aspect.setCenter(0,me.scale120*0.4*120);
            me.ASEC120Aspect.setCenter(0,me.scale120*0.4*120);
        }
		me.radarLock.setVisible(me.rdL);
        me.irDiamondSmall.setVisible(me.irS);
        me.irDiamond.setVisible(me.irL);
        me.irCross.setVisible(me.irB);
        me.ASEC120Aspect.setVisible(me.rdT);
        me.ASEC65Aspect.setVisible(me.irT);
        me.radarLock.update();
        me.irDiamond.update();
        me.irDiamondSmall.update();

        # CCIP is after update_item so it can get VV up-to-date location
        me.ccipInfo = pylons.getCCIP();
        if (me.ccipInfo == nil or notification.ControlsArmamentWeaponSelector != 5) {
            me.ccipGrp.hide();
			setprop("sim/model/f15/armament/ccip-off", 1);
        } else {
			setprop("sim/model/f15/armament/ccip-off", 0);
            hudmath.HudMath.reCalc();
            var poscc = hudmath.HudMath.getPosFromCoord(me.ccipInfo[0]);
            me.ccipPipper.setTranslation(poscc[0],poscc[1]);
            if (me.ccipInfo[1] == 0) {
                me.ccipCross.show();
                me.ccipCross.setTranslation(poscc[0],poscc[1]);
            } else {
                me.ccipCross.hide();
            }
            me.ccipPipper.update();
            me.ccipLine.removeAllChildren();
            # 117.817 is VV location in SVG, 0.8 is x scale of SVG. 92.593 is VV location in SVG and 1.18 is y scale of SVG
            me.ccipVVPos = [0.8*me.VV_x-me.centerOrigin[0]+117.817*0.8+me.baseTranslation[0], 1.18*me.VV_y-me.centerOrigin[1]+92.593*1.18+me.baseTranslation[1]];
            me.ccipLineDist = math.sqrt(math.pow(me.ccipVVPos[0]-poscc[0],2)+math.pow(me.ccipVVPos[1]-poscc[1],2));
            me.ccipLine.createChild("path")
                .moveTo(poscc[0],poscc[1])
                .lineTo(me.ccipVVPos)
                .setStrokeDashArray([0,me.pipperRadius,me.ccipLineDist-3.5-me.pipperRadius,3.5*10])#3.5 is radius of VV.
                .setStrokeLineWidth(1)
                .setColor(0,1,0);
            me.ccipGrp.show();

			# Fall time in seconds
			fall_time = me.ccipInfo[2] / 60; # return it in minutes
			fall_time_mins = sprintf("%.0f", fall_time);
			fall_time_secs = me.ccipInfo[2] - fall_time_mins * 60;  # remove whole minutes for seconds
			setprop("sim/model/f15/armament/fall-time-secs", math.round(fall_time_secs));
			setprop("sim/model/f15/armament/fall-time-mins", math.round(fall_time_mins));
        }

        if (me.svg.getVisible() == 0)
          return;


#        if (hdp.range_rate != nil)
#        {
#            me.window1.setVisible(1);
#            me.window1.setText("");
#        }
#        else
#            me.window1.setVisible(0);


     if (notification["Timestamp"] != nil)
         me.process_targets.set_timestamp(notification.Timestamp);

     me.process_targets.process(me, awg_9.tgts_list,
                                func(pp, obj, data){
                                    obj.target_idx=1;
                                    obj.designated = 0;
                                    obj.target_locked.setVisible(0);
                                }
                                ,
                                func(pp, obj, u){
                                    var callsign = "XX";
                                    if(u.get_display() == 1){
                                        if (u.Callsign != nil)
                                          callsign = u.Callsign.getValue();
                                        var model = "XX";

                                        if (u.ModelType != "")
                                          model = u.ModelType;

                                        if (obj.target_idx < obj.max_symbols)
                                          {
                                              tgt = obj.tgt_symbols[obj.target_idx];
                                              if (tgt != nil)
                                                {
                                                    tgt.setVisible(u.get_display());
                                                    var u_dev_rad = (90-u.get_deviation(obj.heading_deg))  * D2R;
                                                    var u_elev_rad = (90-u.get_total_elevation( obj.pitch_deg))  * D2R;
                                                    var devs = aircraft.develev_to_devroll(u_dev_rad, u_elev_rad);
                                                    var combined_dev_deg = devs[0];
                                                    var combined_dev_length =  devs[1];
                                                    var clamped = devs[2];
                                                    var yc  = ht_yco + (ht_ycf * combined_dev_length * math.cos(combined_dev_deg*D2R));
                                                    var xc = ht_xco + (ht_xcf * combined_dev_length * math.sin(combined_dev_deg*D2R));
                                                    if(devs[2])
                                                      tgt.setVisible(getprop("sim/model/f15/lighting/hud-diamond-switch/state"));
                                                    else
                                                      tgt.setVisible(u.get_display());

                                                    if (awg_9.active_u != nil and awg_9.active_u.Callsign != nil and u.Callsign != nil and u.Callsign.getValue() == awg_9.active_u.Callsign.getValue())
                                                      {
                                                          obj.target_locked.setVisible(u.get_display());
                                                          obj.target_locked.setTranslation (xc, yc);
                                                      }
                                                    else
                                                      {
                                                          #
                                                          # if in symbol reject mode then only show the active target.
                                                          if(obj.symbol_reject)
                                                            tgt.setVisible(0);
                                                      }
                                                    tgt.setTranslation (xc, yc);

                                                    if (ht_debug)
                                                      printf("%-10s %f,%f [%f,%f,%f] :: %f,%f",callsign,xc,yc, devs[0], devs[1], devs[2], u_dev_rad*D2R, u_elev_rad*D2R);
                                                }
                                          }
                                        obj.target_idx = obj.target_idx+1;
                                    }
                                    return 1;
                                },
                                func(pp, obj, data)
                                {
                                    for(var nv = obj.target_idx; nv < obj.max_symbols;nv += 1)
                                      {
                                          tgt = obj.tgt_symbols[nv];
                                          if (tgt != nil)
                                            {
                                                tgt.setVisible(0);
                                            }
                                      }
                                });


    },

	drag: func (Mach, _cd) {
	    if (Mach < 0.7) {
	        return 0.0125 * Mach + _cd;
	    } elsif (Mach < 1.2) {
	        return 0.3742 * math.pow(Mach, 2) - 0.252 * Mach + 0.0021 + _cd;
	    } else {
	        return 0.2965 * math.pow(Mach, -1.1506) + _cd;
		}
	},

	# EEGS Disply loop
	# Taken from F-16's model, and adapted to the F-15 by Jimmy L. Miles
	# Only modes adapted and tested for now: SNAP, EEGS
	# + Only non-radar mode for now
    # Should match gun submodel parameters
    gunEda: 0.00338158219,
    gunWeight: 0.226,
    gunSpeed: 3450.0,
    gunCd: 0.09,
    gunLoc: [0.29069, -1.512999768, 0.558520092],  # converted from ft in the submodels, as it needs to be in meters  previous x:1.512999768

    displayEEGS: func() {
	   #note: this stuff is expensive like hell to compute, but..lets do it anyway.
	   var gunSight = getprop("sim/model/f15/armament/gun-sight");
	   var st = systime();
	   me.hydra = 0;  # F-15EX doesn't use LAU-68C, so hydra alaways off
	   if (getprop("sim/model/f15/instrumentation/radar-awg-9/active-target-available")) {
		   me.designatedDistanceFT = getprop("sim/model/f15/instrumentation/radar-awg-9/active-target-range")*6000;  # conversion from nm to ft
	   } else {
	   	   me.designatedDistanceFT = nil;
	   }
	   me.eegsMe.dt = st-me.lastTime;
	   if (me.eegsMe.dt > me.averageDt*3) {
		   me.lastTime = st;
		   me.resetGunPos();
		   me.eegsGroup.removeAllChildren();
	   } else {
		   #printf("dt %05.3f",me.eegsMe.dt);
		   me.lastTime = st;

		   me.eegsMe.hdg   = getprop("orientation/heading-deg");
		   me.eegsMe.pitch = getprop("orientation/pitch-deg");
		   me.eegsMe.roll  = getprop("orientation/roll-deg");

		   me.eegsMe.hdg_ac   = me.eegsMe.hdg;
		   me.eegsMe.pitch_ac = me.eegsMe.pitch;
		   me.eegsMe.roll_ac  = me.eegsMe.roll;

		   var hdp = {roll:me.eegsMe.roll,current_view_z_offset_m: getprop("sim/current-view/z-offset-m")};

		   me.eegsMe.ac = geo.aircraft_position();
		   me.eegsMe.eye = geo.viewer_position();
		   me.eegsMe.allow = 1;
		   me.drawSTRFPipper = 0;
		   me.drawGunAim = 0;
		   me.strfRange = 24000;
		   if(gunSight == 1 or me.hydra) {  # STFR not adapted yet (to the F-15 model)
			   me.groundAltDiffLastPointFT = nil;
			   var currSegmentPt = 0;
			   for (currSegmentPt = 0;currSegmentPt < me.funnelPartsMax;currSegmentPt+=1) {
				   # compute terrain impact position of trajectory
				   var pos = me.gunPos[currSegmentPt][0];
				   if (pos == nil) {
					   me.eegsMe.allow = 0;
				   } else {
					   var ptc = me.gunPos[currSegmentPt][0][2];
					   var ac  = me.gunPos[currSegmentPt][0][1];
					   pos     = me.gunPos[currSegmentPt][0][0];
					   var el = geo.elevation(pos.lat(),pos.lon());
					   if (el == nil) {
						   el = 0;
					   }

					   if (currSegmentPt != 0 and el > pos.alt()) {
						   var hitPos = geo.Coord.new(pos);
						   hitPos.set_alt(el);
						   me.groundAltDiffLastPointFT = (el-pos.alt())*M2FT;
						   me.strfRange = hitPos.direct_distance_to(me.eegsMe.ac)*M2FT;
						   me.elevationToEnd = vector.Math.getPitch(me.eegsMe.ac, pos);
						   if (me.groundAltDiffLastPointFT > 0 and me.elevationToEnd < 0 and math.sin(-me.elevationToEnd*D2R) != 0) {
							   # We assume the ground is level and flat at impact position
							   me.strfRange -= me.groundAltDiffLastPointFT/math.sin(-me.elevationToEnd*D2R);
						   }
						   break;# this gunpos is below terrain, break the loop.
					   }
				   }
			   }

			   if (me.eegsMe.allow and me.groundAltDiffLastPointFT != nil) {
				   # compute display positions of STRF pipper on hud
				   for (var ll = currSegmentPt-1;ll <= currSegmentPt;ll+=1) {
					   var pos   = me.gunPos[ll][0][0];
					   var ac    = me.gunPos[ll][0][1];
					   var pitch = me.gunPos[ll][0][2];

					   me.eegsMe.posTemp = hudmath.HudMath.getPosFromCoord(pos,me.eegsMe.eye);
					   #me.eegsMe.shellPosDist[ll] = ac.direct_distance_to(pos)*M2FT;
					   me.eegsMe.shellPosX[ll] = me.eegsMe.posTemp[0];
					   me.eegsMe.shellPosY[ll] = me.eegsMe.posTemp[1];

					   if (currSegmentPt == ll and me.strfRange < 24000) {
						   #var highdist = me.eegsMe.shellPosDist[ll];
						   #var lowdist = me.eegsMe.shellPosDist[ll-1];
						   if (pitch >= 0) {
							   #me.eegsPipperX = me.interpolate(highdist-me.groundAltDiffLastPointFT,lowdist,highdist,me.eegsMe.shellPosX[ll-1],me.eegsMe.shellPosX[ll]);
							   #me.eegsPipperY = me.interpolate(highdist-me.groundAltDiffLastPointFT,lowdist,highdist,me.eegsMe.shellPosY[ll-1],me.eegsMe.shellPosY[ll]);
							   me.eegsPipperX = 0.5*me.eegsMe.shellPosX[ll-1]+0.5*me.eegsMe.shellPosX[ll];
							   me.eegsPipperY = 0.5*me.eegsMe.shellPosY[ll-1]+0.5*me.eegsMe.shellPosY[ll];
						   } else {
							   # increasing accuracy me.strfRange and pipper HUD position
							   me.groundDistDiffLastPointFT = me.groundAltDiffLastPointFT/math.sin(-pitch*D2R);# We assume the ground is level and flat at impact position

							   me.posLow = me.gunPos[ll-1][0][0];
							   me.posHigh = me.gunPos[ll][0][0];
							   me.posDist = me.posHigh.direct_distance_to(me.posLow)*M2FT;
							   me.impactPos = me.interpolateCoords(me.posLow, me.posHigh, 1-me.groundDistDiffLastPointFT/me.posDist);
							   me.strfRange = me.impactPos.direct_distance_to(me.eegsMe.ac)*M2FT;
							   me.tmpImpact = hudmath.HudMath.getPosFromCoord(me.impactPos,me.eegsMe.eye);
							   me.eegsPipperX = me.tmpImpact[0];
							   me.eegsPipperY = me.tmpImpact[1];
						   }
						   me.drawSTRFPipper = 1;
					   }
				   }
			   }
		   } else {
			   for (var currSegmentPt = 0;currSegmentPt < me.funnelParts;currSegmentPt+=1) {
				   # compute display positions of gun path on hud
				   var pos = me.gunPos[currSegmentPt][currSegmentPt+1];
				   if (pos == nil) {
					   me.eegsMe.allow = 0;
				   } else {
					   var ac  = me.gunPos[currSegmentPt][currSegmentPt][1];
					   pos     = me.gunPos[currSegmentPt][currSegmentPt][0];
					   me.eegsMe.posTemp = hudmath.HudMath.getPosFromCoord(pos,me.eegsMe.eye);
					   me.eegsMe.shellPosX[currSegmentPt] = me.eegsMe.posTemp[0];
					   me.eegsMe.shellPosY[currSegmentPt] = me.eegsMe.posTemp[1];
					   me.eegsMe.shellPosDist[currSegmentPt] = ac.direct_distance_to(pos)*M2FT;

					   if (me.designatedDistanceFT != nil and !me.drawGunAim and gunSight != 2) {
						 #eegs pipper
						 if (currSegmentPt != 0 and me.eegsMe.shellPosDist[currSegmentPt] >= me.designatedDistanceFT and me.eegsMe.shellPosDist[currSegmentPt]>me.eegsMe.shellPosDist[currSegmentPt-1]) {
						   var highdist = me.eegsMe.shellPosDist[currSegmentPt];
						   var lowdist = me.eegsMe.shellPosDist[currSegmentPt-1];
						   me.eegsPipperX = hudmath.HudMath.extrapolate(me.designatedDistanceFT,lowdist,highdist,me.eegsMe.shellPosX[currSegmentPt-1],me.eegsMe.shellPosX[currSegmentPt]);
						   me.eegsPipperY = hudmath.HudMath.extrapolate(me.designatedDistanceFT,lowdist,highdist,me.eegsMe.shellPosY[currSegmentPt-1],me.eegsMe.shellPosY[currSegmentPt]);
						   me.drawGunAim = 1;
						 }
					   }
				   }
			   }
			   if (me.designatedDistanceFT != nil and gunSight == 2) {
				   #snap pipper
				   for (var currSegmentPt = 6;currSegmentPt < me.funnelParts;currSegmentPt+=5) {
					   if (!me.drawGunAim and (me.eegsMe.shellPosDist[currSegmentPt] >= me.designatedDistanceFT or currSegmentPt==16) and me.eegsMe.shellPosDist[currSegmentPt]>me.eegsMe.shellPosDist[currSegmentPt-5]) {
						   # The check for 16 is to draw the aim extending from last segment if range is larger than last.
						   var highdist = me.eegsMe.shellPosDist[currSegmentPt];
						   var lowdist = me.eegsMe.shellPosDist[currSegmentPt-5];
						   me.eegsPipperX = hudmath.HudMath.extrapolate(me.designatedDistanceFT,lowdist,highdist,me.eegsMe.shellPosX[currSegmentPt-5],me.eegsMe.shellPosX[currSegmentPt]);
						   me.eegsPipperY = hudmath.HudMath.extrapolate(me.designatedDistanceFT,lowdist,highdist,me.eegsMe.shellPosY[currSegmentPt-5],me.eegsMe.shellPosY[currSegmentPt]);
						   me.drawGunAim = 1;
					   }
				   }
			   }
		   }
		   if (me.eegsMe.allow and gunSight == 0 and !me.hydra) {
			   # draw the funnel
			   for (var k = 0;k<me.funnelParts;k+=1) {
				   var halfspan = math.atan2(getprop("sim/model/f15/armament/gun-eegs-wingspan-ft")*0.5,me.eegsMe.shellPosDist[k])*R2D*me.texelPerDegreeX;#35ft average fighter wingspan
				   me.eegsRightX[k] = me.eegsMe.shellPosX[k]-halfspan;
				   me.eegsRightY[k] = me.eegsMe.shellPosY[k];
				   me.eegsLeftX[k]  = me.eegsMe.shellPosX[k]+halfspan;
				   me.eegsLeftY[k]  = me.eegsMe.shellPosY[k];
			   }
			   me.eegsGroup.removeAllChildren();
			   for (var i = 1; i < me.funnelParts-1; i+=1) {#changed to i=1 as we dont need funnel to start so close
				   me.eegsGroup.createChild("path")
					   .moveTo(me.eegsRightX[i], me.eegsRightY[i])
					   .lineTo(me.eegsRightX[i+1], me.eegsRightY[i+1])
					   .moveTo(me.eegsLeftX[i], me.eegsLeftY[i])
					   .lineTo(me.eegsLeftX[i+1], me.eegsLeftY[i+1])
					   .setStrokeLineWidth(1)
					   .setColor(me.color);
			   }
			   # Test snake:
			   #for (var i = 0; i < me.funnelParts-1; i+=1) {
			   #     me.tmpSegment = me.eegsGroup.createChild("path")
			   #        .moveTo(me.eegsMe.shellPosX[i], me.eegsMe.shellPosY[i])
			   #        .lineTo(me.eegsMe.shellPosX[i+1], me.eegsMe.shellPosY[i+1])
			   #        .setStrokeLineWidth(1)
			   #        .setColor(me.color);
			   #}
			   if (me.drawGunAim) {
				   var radius = 2;
				   me.eegsGroup.createChild("path")
						 .moveTo(me.eegsPipperX, me.eegsPipperY-radius)
						 .arcSmallCW(radius,radius,0,0,radius*2)
						 .arcSmallCW(radius,radius,0,0,-radius*2)
						 .setStrokeLineWidth(1)
						 .setColor(me.color);
			   }
			   me.eegsGroup.update();
		   } elsif (me.eegsMe.allow and gunSight == 2 and !me.hydra) {
			   # draw snap
			   me.eegsGroup.removeAllChildren();
			   for (var i = 1; i < me.funnelParts-5; i+=5) {#changed to i=1 as we dont need lines to start so close
				   me.tmpSegment = me.eegsGroup.createChild("path")
					   .moveTo(me.eegsMe.shellPosX[i], me.eegsMe.shellPosY[i])
					   .lineTo(me.eegsMe.shellPosX[i+5], me.eegsMe.shellPosY[i+5])
					   .setStrokeLineWidth(1)
					   .setColor(me.color);
				   if (i > 5) {
					   me.dx = me.eegsMe.shellPosX[i] - me.eegsMe.shellPosX[i+5];
					   me.dy = me.eegsMe.shellPosY[i] - me.eegsMe.shellPosY[i+5];
					   me.dl = math.sqrt(me.dx*me.dx+me.dy*me.dy);
					   if (me.dl != 0) {
						   me.angle1 = math.acos(math.clamp(me.dx/me.dl,-1,1));
						   me.angle2 = math.asin(math.clamp(me.dy/me.dl,-1,1));
						   me.angle  = me.angle2<0?-me.angle1:me.angle1;
						   me.angle += 90 * D2R;
						   me.segmentRel = [3*math.cos(me.angle),3*math.sin(me.angle)];
						   me.tmpSegment
								   .moveTo(me.eegsMe.shellPosX[i+5]+me.segmentRel[0], me.eegsMe.shellPosY[i+5]+me.segmentRel[1])
								   .lineTo(me.eegsMe.shellPosX[i+5]-me.segmentRel[0], me.eegsMe.shellPosY[i+5]-me.segmentRel[1]);
					   }
				   }
			   }
			   if (me.drawGunAim) {
				   var radius = 2;
				   me.eegsGroup.createChild("path")
						 .moveTo(me.eegsPipperX, me.eegsPipperY-radius)
						 .arcSmallCW(radius,radius,0,0,radius*2)
						 .arcSmallCW(radius,radius,0,0,-radius*2)
						 .setStrokeLineWidth(1)
						 .setColor(me.color);
			   }
			   me.eegsGroup.update();
		   } elsif (me.eegsMe.allow and (gunSight == 1 or me.hydra)) {
			   # draw STRF
			   me.eegsGroup.removeAllChildren();
			   if (me.drawSTRFPipper) {
					   me.vari = getprop("sim/variant-id");
					   me.oldStrf = me.vari == 0 or me.vari == 1 or me.vari == 3;
					   var mr = 0.4 * 1.5;
					   if (me.oldStrf) {
							   # draw the old STRF pipper (T.O. GR1F-16CJ-34-1-1 page 1-442 and MLU Tape 1 page 185)
							   var pipperRadius = 15 * mr;
							   if (me.strfRange <= (me.hydra?4000:getprop("f16/avionics/gun-strf-max-range-ft"))) {
									   me.eegsGroup.createChild("path")
											   .moveTo(me.eegsPipperX-pipperRadius, me.eegsPipperY-pipperRadius-2)
											   .horiz(pipperRadius*2)
											   .moveTo(me.eegsPipperX-pipperRadius, me.eegsPipperY)
											   .arcSmallCW(pipperRadius, pipperRadius, 0, pipperRadius*2, 0)
											   .arcSmallCW(pipperRadius, pipperRadius, 0, -pipperRadius*2, 0)
											   .moveTo(me.eegsPipperX-2*mr,me.eegsPipperY)
											   .arcSmallCW(2*mr,2*mr, 0, 2*mr*2, 0)
											   .arcSmallCW(2*mr,2*mr, 0, -2*mr*2, 0)
											   .setStrokeLineWidth(1)
											   .setColor(me.color);
							   } else {
									   me.eegsGroup.createChild("path")
											   .moveTo(me.eegsPipperX-pipperRadius, me.eegsPipperY)
											   .arcSmallCW(pipperRadius, pipperRadius, 0, pipperRadius*2, 0)
											   .arcSmallCW(pipperRadius, pipperRadius, 0, -pipperRadius*2, 0)
											   .moveTo(me.eegsPipperX-2*mr,me.eegsPipperY)
											   .arcSmallCW(2*mr,2*mr, 0, 2*mr*2, 0)
											   .arcSmallCW(2*mr,2*mr, 0, -2*mr*2, 0)
											   .setStrokeLineWidth(1)
											   .setColor(me.color);
							   }
					   } else {
							   # draw the new STRF pipper (T.O. GR1F-16CJ-34-1-1(new) page 2-299 and MLU Tape 2 page 79)
							   me.pipperOuterRadius = 25 * mr;
							   me.pipperInnerRadius = 20 * mr;
							   me.pipperRangeTick   =  5 * mr;
							   me.pipperRangeMode = me.strfRange <= getprop("f16/avionics/gun-strf-max-range-ft") and me.strfRange <= 12000?0:(me.strfRange <= 12000?1:(me.strfRange <= getprop("f16/avionics/gun-strf-max-range-ft") and me.strfRange <= 24000?2:(me.strfRange <= 24000?3:4)));

							   if (me.pipperRangeMode < 4) {

									   if (me.pipperRangeMode < 2) {
											   me.td_rads = me.interpolate(me.strfRange, 0, 12000, 0, 2*math.pi);
									   } else {
											   me.td_rads = me.interpolate(me.strfRange, 12000, 24000, 0, 2*math.pi);
									   }
									   me.td_x = me.pipperInnerRadius*math.sin(me.td_rads);
									   me.td_y = -me.pipperInnerRadius*math.cos(me.td_rads);
									   me.td_x2 = me.pipperOuterRadius*math.sin(me.td_rads);
									   me.td_y2 = -me.pipperOuterRadius*math.cos(me.td_rads);

									   if (getprop("f16/avionics/gun-strf-max-range-ft") <= 12000) {
											   me.td_rads = me.interpolate(getprop("f16/avionics/gun-strf-max-range-ft"), 0, 12000, 0, 2*math.pi);
									   } else {
											   me.td_rads = me.interpolate(getprop("f16/avionics/gun-strf-max-range-ft"), 12000, 24000, 0, 2*math.pi);
									   }
									   me.td_x3 = (me.pipperOuterRadius+me.pipperRangeTick)*math.sin(me.td_rads);
									   me.td_y3 = -(me.pipperOuterRadius+me.pipperRangeTick)*math.cos(me.td_rads);

									   # Draw inner arc and range tick
									   if (me.pipperRangeMode == 3) {
											   # Out of range (between 12000 and 24000 ft)
											   me.newPipper = me.eegsGroup.createChild("path")
													   .moveTo(me.td_x, me.td_y)
													   .lineTo(me.td_x2, me.td_y2);
									   } elsif (me.pipperRangeMode == 2) {
											   # In range (between 12000 and 24000 ft)
											   me.newPipper = me.eegsGroup.createChild("path")
													   .moveTo(-me.pipperInnerRadius, 0)
													   .arcSmallCW(me.pipperInnerRadius, me.pipperInnerRadius, 0, 2*me.pipperInnerRadius, 0)
													   .arcSmallCW(me.pipperInnerRadius, me.pipperInnerRadius, 0, -2*me.pipperInnerRadius, 0)
													   .moveTo(me.td_x, me.td_y)
													   .lineTo(me.td_x2, me.td_y2);
									   } elsif (me.pipperRangeMode == 1) {
											   # Out of range (less than 12000 ft)
											   me.newPipper = me.eegsGroup.createChild("path")
															   .moveTo(me.td_x, me.td_y)
															   .lineTo(me.td_x2, me.td_y2);
									   } elsif (me.pipperRangeMode == 0) {
											   # in range (less than 12000 ft)
											   if (me.td_x >= 0) {
													   me.newPipper = me.eegsGroup.createChild("path")
															   .moveTo(0, -me.pipperInnerRadius)
															   .arcSmallCW(me.pipperInnerRadius, me.pipperInnerRadius, 0, me.td_x, me.td_y+me.pipperInnerRadius)
															   .lineTo(me.td_x2, me.td_y2)
															   .moveTo(0, -me.pipperInnerRadius)
															   .vert(-me.pipperRangeTick);
											   } else {
													   me.newPipper = me.eegsGroup.createChild("path")
															   .moveTo(0, -me.pipperInnerRadius)
															   .arcLargeCW(me.pipperInnerRadius, me.pipperInnerRadius, 0, me.td_x, me.td_y+me.pipperInnerRadius)
															   .lineTo(me.td_x2, me.td_y2)
															   .moveTo(0, -me.pipperInnerRadius)
															   .vert(-me.pipperRangeTick);
											   }
									   }

									   # Draw outer arc and outer ticks
									   me.newPipper
											   .moveTo(-me.pipperOuterRadius, 0)
											   .arcSmallCW(me.pipperOuterRadius, me.pipperOuterRadius, 0, 2*me.pipperOuterRadius, 0)
											   .arcSmallCW(me.pipperOuterRadius, me.pipperOuterRadius, 0, -2*me.pipperOuterRadius, 0)
											   .moveTo(me.pipperOuterRadius, 0)
											   .horiz(me.pipperRangeTick)
											   .moveTo(-me.pipperOuterRadius, 0)
											   .horiz(-me.pipperRangeTick)
											   .moveTo(0, me.pipperOuterRadius)
											   .vert(me.pipperRangeTick)
											   .moveTo(0, -me.pipperOuterRadius)
											   .vert(-me.pipperRangeTick);

									   # Draw center dot
									   me.newPipper.moveTo(-mr,0);
									   me.newPipper.arcSmallCW(mr,mr, 0, mr*2, 0);
									   me.newPipper.arcSmallCW(mr,mr, 0, -mr*2, 0);

									   # Draw in-range dot
									   me.newPipper.moveTo(-mr+me.td_x3,me.td_y3);
									   me.newPipper.arcSmallCW(mr,mr, 0, mr*2, 0);
									   me.newPipper.arcSmallCW(mr,mr, 0, -mr*2, 0);

									   # Place the pipper on impact point
									   me.newPipper.setTranslation(me.eegsPipperX, me.eegsPipperY)
											   .setStrokeLineWidth(1)
											   .setColor(me.color)
											   .update();
							   }
					   }
			   }
			   me.eegsGroup.update();
		   }




		   #calc shell positions

		   # speed = aircraft groundspeed vector + aircraft attitude vector with shell speed for magnitude
		   #

		   me.eegs_ac_north_fps = getprop("velocities/speed-north-fps");
		   me.eegs_ac_east_fps  = getprop("velocities/speed-east-fps");
		   me.eegs_ac_down_fps  = getprop("velocities/speed-down-fps");

		   me.eegs_sm_down_fps       = -math.sin(me.eegsMe.pitch_ac * D2R) * (me.hydra?2000:me.gunSpeed);
		   me.eegs_sm_horizontal_fps = math.cos(me.eegsMe.pitch_ac * D2R) * (me.hydra?2000:me.gunSpeed);
		   me.eegs_sm_north_fps      = math.cos(me.eegsMe.hdg_ac * D2R) * me.eegs_sm_horizontal_fps;
		   me.eegs_sm_east_fps       = math.sin(me.eegsMe.hdg_ac * D2R) * me.eegs_sm_horizontal_fps;

		   me.eegs_north_fps = me.eegs_ac_north_fps + me.eegs_sm_north_fps;
		   me.eegs_east_fps  = me.eegs_ac_east_fps  + me.eegs_sm_east_fps;
		   me.eegs_down_fps  = me.eegs_ac_down_fps  + me.eegs_sm_down_fps;

		   me.eegs_horiz_fps = math.sqrt(me.eegs_north_fps*me.eegs_north_fps+me.eegs_east_fps*me.eegs_east_fps);
		   me.eegs_total_fps = math.sqrt(me.eegs_down_fps*me.eegs_down_fps+me.eegs_horiz_fps*me.eegs_horiz_fps);

		   me.eegs_hdging = geo.normdeg(math.atan2(me.eegs_east_fps,me.eegs_north_fps)*R2D);
		   me.eegs_ptch   = math.atan2(-me.eegs_down_fps, me.eegs_horiz_fps)*R2D;

		   if (me.eegs_total_fps > 1) {
			   me.eegsMe.hdg = me.eegs_hdging;
			   me.eegsMe.pitch = me.eegs_ptch;
		   }

		   me.eegsMe.vel = me.eegs_total_fps;

		   me.eegsMe.geodPos = aircraftToCart({x:-me.gunLoc[0], y:me.gunLoc[1], z: -me.gunLoc[2]});#position of gun in aircraft (x and z inverted)
		   me.eegsMe.eegsPos.set_xyz(me.eegsMe.geodPos.x, me.eegsMe.geodPos.y, me.eegsMe.geodPos.z);
		   me.eegsMe.altC = me.eegsMe.eegsPos.alt();

		   me.eegsMe.rs = armament.AIM.rho_sndspeed(me.eegsMe.altC*M2FT);#simplified
		   me.eegsMe.rho = me.eegsMe.rs[0];
		   me.eegsMe.mass =  (me.hydra?23.6:me.gunWeight) * armament.LBM2SLUGS;

		   #print("x,y");
		   #printf("%d,%d",0,0);
		   #print("-----");

		   var multi = gunSight == 1?3:(me.hydra?2:1);# double the funnel segments for HYDRA (3.4 secs) and triple for STRF (5.1 secs)
		   for (var j = 0;j < me.funnelParts*multi;j+=1) {

			   # there is a unit bug in FG 2020.3.19 submodels which is applied every frame, which means we gotta compensate:
			   me.eegsMe.vel_kt = me.eegsMe.vel * FPS2KT;

			   #calc new speed incorrect (using wrong units like FG do)
			   me.eegsMe.Cd = me.drag(me.eegsMe.vel/ me.eegsMe.rs[1],me.hydra?0:me.gunCd);
			   me.eegsMe.q = 0.5 * me.eegsMe.rho * me.eegsMe.vel_kt * me.eegsMe.vel_kt;
			   me.eegsMe.deacc = (me.eegsMe.Cd * me.eegsMe.q * (me.hydra?0.00136354:me.gunEda)) / me.eegsMe.mass;#0.00136354=eda
			   me.eegsMe.vel -= me.eegsMe.deacc * KT2FPS * me.averageDt;

			   me.eegsMe.speed_down_fps       = -math.sin(me.eegsMe.pitch * D2R) * (me.eegsMe.vel);
			   me.eegsMe.speed_horizontal_fps = math.cos(me.eegsMe.pitch * D2R) * (me.eegsMe.vel);

			   me.eegsMe.speed_down_fps += getprop("environment/gravitational-acceleration-mps2") * M2FT * me.averageDt;



			   me.eegsMe.altC -= (me.eegsMe.speed_down_fps*me.averageDt)*FT2M;


			   #printf("altC %d   vel_z %d   acc_z=%d",me.eegsMe.altC,me.eegsMe.vel_z,me.eegsMe.acc * averageDt);


			   me.eegsMe.dist = (me.eegsMe.speed_horizontal_fps*me.averageDt)*FT2M;

			   #printf("vel_x %d  acc_x %d", me.eegsMe.vel_x,me.eegsMe.acc);
			   #printf("pitch=%.1f  vel=%d  vdown=%.1f",me.eegsMe.pitch, me.eegsMe.vel, me.eegsMe.speed_down_fps, );
			   #me.eegsMe.eegsPos.apply_course_distance(me.eegsMe.hdg, me.eegsMe.dist);
			   me.great = greatCircleMove(me.eegsMe.eegsPos, me.eegsMe.hdg, me.eegsMe.dist*M2NM);
			   me.eegsMe.eegsPos.set_latlon(me.great.lat, me.great.lon, me.eegsMe.altC);

			   var old = me.gunPos[j];
			   me.gunPos[j] = [[geo.Coord.new(me.eegsMe.eegsPos),me.eegsMe.ac, me.eegsMe.pitch]];
			   for (var m = 0;m<j+1;m+=1) {
				   append(me.gunPos[j], old[m]);
			   }

			   #print(me.eegsMe.speed_down_fps*me.eegsMe.speed_down_fps+me.eegsMe.speed_horizontal_fps*me.eegsMe.speed_horizontal_fps);
			   #print(me.eegsMe.speed_down_fps*me.eegsMe.speed_down_fps);
			   #print(me.eegsMe.speed_horizontal_fps*me.eegsMe.speed_horizontal_fps);

			   #if (j==0) {
			   #    var p = math.atan2(me.eegsMe.altC-me.eegsMe.ac.alt(),me.eegsMe.eegsPos.distance_to(me.eegsMe.ac))*R2D;
				   #printf("next %.2f alt %.2f our-pitch %.2f our-alt %.2f",p-getprop("orientation/pitch-deg"),me.eegsMe.altC,getprop("orientation/pitch-deg"),me.eegsMe.ac.alt());
			   #    printf("shot heading %.2f bearing %.2f", me.eegsMe.hdg, me.eegsMe.ac.course_to(me.eegsMe.eegsPos));
			   #    printf("dist=%d vel=%d realdist=%d",me.eegsMe.dist,me.eegsMe.vel,me.eegsMe.eegsPos.distance_to(me.eegsMe.ac));
				   #me.eegsMe.eegsPos.dump();
			   #}
			   me.eegsMe.vel = math.sqrt(me.eegsMe.speed_down_fps*me.eegsMe.speed_down_fps+me.eegsMe.speed_horizontal_fps*me.eegsMe.speed_horizontal_fps);
			   me.eegsMe.pitch = math.atan2(-me.eegsMe.speed_down_fps,me.eegsMe.speed_horizontal_fps)*R2D;
		   }
	   }
	   if (gunSight != 1 and !me.hydra and me.designatedDistanceFT != nil) {
		   # Draw A-A gun reticle
		   me.aaTargetDesignationGrp.removeAllChildren();
		   var mr = 0.4 * 1.5;
		   var radius = 20 * mr;
		   me.td_rads = me.interpolate(me.designatedDistanceFT, 0, 12000, 0, 2*math.pi);
		   me.td_x = radius*math.sin(me.td_rads);
		   me.td_y = -radius*math.cos(me.td_rads);
		   me.td_factor = me.designatedDistanceFT >= 12000?1:0.75;
		   me.td_x2 = me.td_factor*radius*math.sin(me.td_rads);
		   me.td_y2 = -me.td_factor*radius*math.cos(me.td_rads);
		   # The open part of the circle is not segmented as per manuals and YT (1FJF5PD1uqM)
		   # More modern MLU (or some export models) do have it segmented though.
		   if (me.td_x >= 0) {
			   me.aaTargetDesignator = me.aaTargetDesignationGrp.createChild("path")
				   .moveTo(0, -radius)
				   .arcSmallCW(radius, radius, 0, me.td_x, me.td_y+radius)
				   .lineTo(me.td_x2, me.td_y2)
				   .setStrokeLineWidth(1)
				   .setColor(me.color)
				   .update();
		   } else {
			   me.aaTargetDesignator = me.aaTargetDesignationGrp.createChild("path")
				   .moveTo(0, -radius)
				   .arcLargeCW(radius, radius, 0, me.td_x, me.td_y+radius)
				   .lineTo(me.td_x2, me.td_y2)
				   .setStrokeLineWidth(1)
				   .setColor(me.color)
				   .update();
		   }
		   # Draw in-range dot
		   if (me.designatedDistanceFT > getprop("f16/avionics/gun-aa-max-range-ft")) {
			   me.td_rads = me.interpolate(getprop("f16/avionics/gun-aa-max-range-ft"), 0, 12000, 0, 2*math.pi);
			   me.td_x3 = (1.20*radius)*math.sin(me.td_rads);
			   me.td_y3 = -(1.20*radius)*math.cos(me.td_rads);
			   me.aaTargetDesignator.moveTo(-mr+me.td_x3,me.td_y3);
			   me.aaTargetDesignator.arcSmallCW(mr,mr, 0, mr*2, 0);
			   me.aaTargetDesignator.arcSmallCW(mr,mr, 0, -mr*2, 0);
		   }
	   }
   },

    list: [],
};


input = {
        AirspeedIndicatorIndicatedMach          : "instrumentation/airspeed-indicator/indicated-mach",
        Alpha                                   : "orientation/alpha-indicated-deg",
        AltimeterIndicatedAltitudeFt            : "instrumentation/altimeter/indicated-altitude-ft",
        ArmamentAgmCount                        : "sim/model/f15/systems/armament/agm/count",
        ArmamentAim120Count                     : "sim/model/f15/systems/armament/aim120/count",
        ArmamentAim7Count                       : "sim/model/f15/systems/armament/aim7/count",
        ArmamentAim9Count                       : "sim/model/f15/systems/armament/aim9/count",
        ArmamentRounds                          : "sim/model/f15/systems/gun/rounds",
        AutopilotRouteManagerActive             : "autopilot/route-manager/active",
        AutopilotRouteManagerWpDist             : "autopilot/route-manager/wp/dist",
        AutopilotRouteManagerWpEtaSeconds       : "autopilot/route-manager/wp/eta-seconds",
        CadcOwsMaximumG                         : "fdm/jsbsim/systems/cadc/ows-maximum-g",
        ControlsArmamentMasterArmSwitch         : "sim/model/f15/controls/armament/master-arm-switch",
        ControlsArmamentWeaponSelector          : "sim/model/f15/controls/armament/weapon-selector",
        ControlsGearBrakeParking                : "controls/gear/brake-parking",
        ControlsGearGearDown                    : "controls/gear/gear-down",
        ControlsHudBrightness                   : "sim/model/f15/controls/HUD/brightness",
        ControlsHudSymRej                       : "sim/model/f15/controls/HUD/sym-rej",
        ElectricsAcLeftMainBus                  : "fdm/jsbsim/systems/electrics/ac-left-main-bus",
        HudNavRangeDisplay                      : "sim/model/f15/instrumentation/hud/nav-range-display",
        HudNavRangeETA                          : "sim/model/f15/instrumentation/hud/nav-range-eta",
        OrientationHeadingDeg                   : "orientation/heading-deg",
        OrientationPitchDeg                     : "orientation/pitch-deg",
        OrientationRollDeg                      : "orientation/roll-deg",
        OrientationSideSlipDeg                  : "orientation/side-slip-deg",
        RadarActiveTargetAvailable              : "sim/model/f15/instrumentation/radar-awg-9/active-target-available",
        RadarActiveTargetCallsign               : "sim/model/f15/instrumentation/radar-awg-9/active-target-callsign",
        RadarActiveTargetClosure                : "sim/model/f15/instrumentation/radar-awg-9/active-target-closure",
        RadarActiveTargetDisplay                : "sim/model/f15/instrumentation/radar-awg-9/active-target-display",
        RadarActiveTargetRange                  : "sim/model/f15/instrumentation/radar-awg-9/active-target-range",
        RadarActiveTargetType                   : "sim/model/f15/instrumentation/radar-awg-9/active-target-type",
        InstrumentedG                           : "instrumentation/g-meter/instrumented-g",
        VelocitiesAirspeedKt                    : "velocities/airspeed-kt",
        VelocitiesGroundspeedKt                 : "velocities/groundspeed-kt",
        FeetPerSecond                           : "velocities/down-relground-fps",
		AltitudeDeckMax                         : "sim/model/f15/avionics/altitude-deck-max",
		AltitudeDeckMin                         : "sim/model/f15/avionics/altitude-deck-min",
		AltitudeDeckMaxEnabled                  : "sim/model/f15/avionics/altitude-deck-max-enabled",
		AltitudeDeckMinEnabled                  : "sim/model/f15/avionics/altitude-deck-min-enabled",
		VNE                                     : "limits/vne",
        TimeTilCrash                            : "instrumentation/radar/time-till-crash",
		BingoFuel                               : "sim/model/f15/lights/ca-bingo-fuel",
		RadarStandby                            : "instrumentation/radar/radar-standby",
		ArmamentRippleCount                     : "controls/armament/dual",
};

emexec.ExecModule.register("F15-HUD",input, F15HUD.new("Nasal/HUD/HUD_ex.svg", "HUDImage1"), 2);
