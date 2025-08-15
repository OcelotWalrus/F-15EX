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

        obj.window1 = obj.get_text("window1", aircraft.HUDFont,10,1.4);
        obj.window1_big = obj.get_text("W1B", aircraft.HUDFont,12,1.4);
        obj.window2 = obj.get_text("window2", aircraft.HUDFont,9,1.4);
        obj.window3 = obj.get_text("window3", aircraft.HUDFont,9,1.4);
        obj.window4 = obj.get_text("window4", aircraft.HUDFont,9,1.4);
        obj.window5 = obj.get_text("window5", aircraft.HUDFont,9,1.4);
        obj.window6 = obj.get_text("window6", aircraft.HUDFont,9,1.4);
        obj.window7 = obj.get_text("window7", aircraft.HUDFont,9,1.4);
        obj.window8 = obj.get_text("window8", aircraft.HUDFont,9,1.4);
        obj.window9 = obj.get_text("window9", aircraft.HUDFont,11,1.4);
        obj.window10 = obj.get_text("window10", aircraft.HUDFont,9,1.4);
        obj.window11 = obj.get_text("window11", aircraft.HUDFont,9,1.4);
        obj.window13 = obj.get_text("window13", aircraft.HUDFont,11,1.4);
        obj.window14 = obj.get_text("window14", aircraft.HUDFont,9,1.4);
        obj.window15 = obj.get_text("window15", aircraft.HUDFont,8,1.4);
        obj.window16 = obj.get_text("window16", aircraft.HUDFont,8,1.4);
        obj.window17 = obj.get_text("window17", aircraft.HUDFont,8,1.4);
        obj.window18 = obj.get_text("window18", aircraft.HUDFont,8,1.4);
        obj.window19 = obj.get_text("window19", aircraft.HUDFont,6,1.4);
        obj.window20 = obj.get_text("window20", aircraft.HUDFont,6,1.4);
        obj.window21 = obj.get_text("window21", aircraft.HUDFont,6,1.4);

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
			obj.GUNSAspect = obj.ASECircle.createChild("path")
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
			obj.aaTargetDesignationGrp = obj.canvas.createGroup();
			obj.aaTargetDesignationGrp.setTranslation(obj.centerOrigin);  # children are created later in the EEGS loop
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

			# CCRP Symbology
			obj.ccrpSymbology = obj.canvas.createGroup();
			obj.ccrpSymbology.setTranslation(obj.centerOrigin);
			obj.timeToRelease = nil;
			obj.CCRP_active = nil;
			obj.bombFallLine = obj.ccrpSymbology.createChild("path")
                .moveTo(sx*0.5*uv_used,0)
                #.horiz(10)
                .vert(400)
                .setStrokeLineWidth(1)
                .setColor(0,1,0).hide();
        	obj.solutionCue = obj.ccrpSymbology.createChild("path")#the moving line
                .moveTo(sx*0.5*uv_used-5,0)
                .horiz(10)
                .setStrokeLineWidth(2)
                .set("z-index",10005)
                .setColor(0,1,0);
        	obj.ccrpMarker = obj.ccrpSymbology.createChild("path")
                .moveTo(sx*0.5*uv_used-10,sy*0.5)
                .horiz(20)
                .setStrokeLineWidth(1)
                .setColor(0,1,0);

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
			obj.flyupTime = obj.WarningTexts.createChild("text")
		        .setText("00.000")
		        .setTranslation(0,-65)
		        .setAlignment("center-center")
		        .setColor(0,1,0,1)
		        .setFont(aircraft.HUDFont)
		        .setFontSize(9, 1.4);
			obj.stby = obj.WarningTexts.createChild("text")
	            .setText("NO RAD")
	            .setTranslation(0,-165)
	            .setAlignment("center-top")
	            .setColor(0,1,0,1)
	            .setFont(aircraft.HUDFont)
	            .setFontSize(11, 1.1);

	        # Texts when refueling bay's open, or when fuel's gettin dumped
	        obj.fuel_amount = obj.WarningTexts.createChild("text")
	            .setText("Total x")
	            .setTranslation(0,20)
	            .setAlignment("center-top")
	            .setColor(0,1,0,1)
	            .setFont(aircraft.HUDFont)
	            .setFontSize(8, 1.1);
	        obj.fuel_now = obj.WarningTexts.createChild("text")
	            .setText("Curr y")
	            .setTranslation(0,30)
	            .setAlignment("center-top")
	            .setColor(0,1,0,1)
	            .setFont(aircraft.HUDFont)
	            .setFontSize(8, 1.1);
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
											  obj.stby.setVisible(0);
                                          } else {
                                              obj.svg.setVisible(1);
											  obj.color = [0.3,1,0.3,1];
											  obj.ASEC120Aspect.setColorFill(obj.color);
                                              obj.ASEC65Aspect.setColorFill(obj.color);
											  obj.GUNSAspect.setColorFill(obj.color);
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
            props.UpdateManager.FromHashList(["OrientationRollDeg","OrientationPitchDeg", "IsRefueling", "IsRefueling2", "IsDumpingFuel", "FuelPercentage", "CurrentFuelLb"], 0.025, func(val)
                                    {
                                        if (val.IsRefueling == 1 or val.IsRefueling2 == 1) {
                                            obj.fuel_amount.setText(sprintf("REFUELING - %s/100", math.floor(val.FuelPercentage * 100)));
                                            obj.fuel_now.setText(sprintf("%s LBS", math.floor(val.CurrentFuelLb)));
                                            obj.fuel_amount.setVisible(1);
                                            obj.fuel_now.setVisible(1);
                                        } elsif (val.IsDumpingFuel == 1) {
                                            obj.fuel_amount.setText(sprintf("DUMPING - %s/100", math.floor(val.FuelPercentage * 100)));
                                            obj.fuel_now.setText(sprintf("%s LBS", math.floor(val.CurrentFuelLb)));
                                            obj.fuel_amount.setVisible(1);
                                            obj.fuel_now.setVisible(1);
                                        } else {
                                            obj.fuel_amount.setVisible(0);
                                            obj.fuel_now.setVisible(0);
                                        }

                                        obj.roll_deg = val.OrientationRollDeg;
                                        obj.roll_rad = -obj.roll_deg*3.14159/180.0;
                                        obj.roll_pointer.setRotation (obj.roll_rad);
                                        var ptx = 0;
                                        obj.pitch_deg = val.OrientationPitchDeg;
                                        var pty = 392+ obj.pitch_deg * pitch_factor;

                                        obj.ladder.setRotation(obj.roll_rad);
                                        obj.ladder.setTranslation(ptx,pty);

                                        if (obj.pitch_deg > 0) {
                                            obj.ladder.setCenter (110,900-obj.pitch_deg*(1815/90));
                                        } else {
                                            obj.ladder.setCenter (110,900+obj.pitch_deg*-(1772/90));
                                        }
                                    }),
            props.UpdateManager.FromHashList(["Alpha", "OrientationSideSlipDeg"], 0.001, func(val)
                                                        {
                                                            if (val.OrientationSideSlipDeg == nil or val.Alpha == nil)
                                                            return;
                                                            obj.VV_x = (val.OrientationSideSlipDeg or 0)*10; # adjust for view
                                                            obj.VV_y = (val.Alpha or 0)*10; # adjust for view
                                                            obj.VV.setTranslation (obj.VV_x, obj.VV_y);
                                                        }),
            props.UpdateManager.FromHashList(["InstrumentedG", "CadcOwsMaximumG", "ThrustToWeightRatio"], 0.05, func(val)
                                                        {
                                                            obj.window8.setText(sprintf("%02d %02d G",
                                                                                        math.round(val.InstrumentedG*10.0),
                                                                                        math.round(val.CadcOwsMaximumG*10.0)));

															obj.window21.setText(sprintf("%1.2f T/W", val.ThrustToWeightRatio));
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
            props.UpdateManager.FromHashList(["VelocitiesAirspeedKt", "VelocitiesGroundspeedKt", "AltimeterIndicatedAltitudeFt", "Alpha", "ControlsGearGearDown", "FeetPerSecond", "AltitudeAGL"], nil, func(val)
                                                        {
                                                            obj.window9.setText(sprintf("%03d", math.round(val.VelocitiesAirspeedKt)));
                                                            obj.window13.setText(sprintf("G %03d", math.round(val.VelocitiesGroundspeedKt)));

                                                            # Separate thousands from the altitude to put em in evidence in the HUD
                                                            altitude = math.round(val.AltimeterIndicatedAltitudeFt);
                                                            big_altitude = 00;
                                                            if (altitude < 1000) {  # If no thousands, just keep it normal
                                                                small_altitude = altitude;
                                                            } elsif (altitude < 10000) {  # If thousands have only 1 number
                                                                big_altitude = math.floor(altitude / 1000);
                                                                small_altitude = altitude - big_altitude * 1000;
                                                            } elsif (altitude >= 10000) {  # If thousands have more than 1 number
                                                                big_altitude = math.floor(altitude / 1000);
                                                                small_altitude = altitude - big_altitude * 1000;
                                                            }

                                                            if (getprop("gear/gear[0]/wow") == 1) {
                                                                obj.window1_big.setText("GROUND");
                                                                obj.window1_big.setVisible(1);
                                                                obj.window1.setText("");
                                                            } else {
                                                                obj.window1.setText(sprintf(" %03d", small_altitude));
                                                                obj.window1_big.setText(sprintf("%02d", big_altitude));
                                                                obj.window1_big.setVisible(1);
                                                            }
                                                            obj.window1.setVisible(1);

                                                            obj.window14.setText(sprintf(" %04d fps", math.round(val.FeetPerSecond)));
                                                            obj.window14.setVisible(1);

															if (getprop("sim/model/f15/avionics/radar-altimeter-online")) {
																obj.window19.setText(sprintf("%04d ftAGL", math.round(val.AltitudeAGL)));
																obj.window19.setVisible(1);
															} else {
																obj.window19.setVisible(0);
															}
                                                        }),
            props.UpdateManager.FromHashList([
				"OrientationHeadingDeg", "OrientationPitchDeg", "OrientationRollDeg", "NavigationMode", "TacanStationInRange", "TacanXShift", "TacanYShift"
			], nil, func(val)
                                                        {
														# Taken from the F-16's model and adapted by Jimmy L. Miles
														# get all the active steerpoints
														if (val.NavigationMode == 0) {  # if we're in normal nav mode
															me.plan = flightplan();
											                me.planSize = me.plan.getPlanSize();
															for (me.j = 0; me.j < me.planSize;me.j+=1) {
																me.wp = me.plan.getWP(me.j);
																me.wpC = geo.Coord.new();
																me.wpC.set_latlon(me.wp.lat,me.wp.lon);
															}
														}
														# the Y position is still not accurate due to HUD being at an angle, but will have to do.
													    if (steerpoints.getCurrentNumber() != 0 and getprop("autopilot/route-manager/active") and val.NavigationMode != 1) {  # and !hdp.getproper("dgft")
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
														 } elsif (val.NavigationMode == 1 and val.TacanStationInRange) {  # if we're in TACAN navigation mode NOTE: this ain't very accurate
														 	 obj.aircraft_x = geo.aircraft_position().lat();
														 	 obj.aircraft_y = geo.aircraft_position().lon();
														 	 obj.cc = geo.Coord.new();
															 obj.cc.set_latlon(obj.aircraft_x + val.TacanXShift, obj.aircraft_y + val.TacanYShift);
															 obj.steerDir = [geo.aircraft_position().course_to(obj.cc), vector.Math.getPitch(geo.aircraft_position(), obj.cc)];
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
            props.UpdateManager.FromHashList(["OrientationHeadingDeg", "OrientationPitchDeg", "OrientationRollDeg", "VelocitiesAirspeedKt", "RadarStandby"], nil, func(val)
                                                        {
															# All by Jimmy L. Miles
															# Determine the hypothical estimated time for missile to intercept target (if any) (missile not launched yet)
															# Constant variables :
															var mean_120_d_speed = 1850; # in mph - mean speed during whole course is about Ma 2.5 - 3
															var mean_9_x_speed = 1450; # in mph - mean speed during whole course is about Ma 1.8 - 2.2
															var agm65_speed = 805; # in mph - mean speed during whole course is about Ma 1.22
															var agm84_speed = 645; # in mph - mean speed during whole course is about Ma .85
															var agm88_speed = 2000; # in mph
															var agm158c_speed = 550; # in mph - about Ma .8
															var mean_speed = 1; # placeholder
															weap = pylons.fcs.getSelectedWeapon(); # get selected weapon data
															if (weap != nil and weap.parents[0] == armament.AIM) {
																if (weap.type != "AIM-9X" and weap.type != "CATM-9X" and weap.type != "AIM-120D" and weap.type != "CATM-120D" and weap.type != "AGM-65B" and weap.type != "AGM-65D" and weap.type != "AGM-84D" and weap.type != "AGM-84E" and weap.type != "AGM-88E" and weap.type != "AGM-119A" and weap.type != "AGM-154A" and weap.type != "AGM-158A" and weap.type != "AGM-158C" and getprop("sim/model/f15/armament/ccip-off") == 0 and pylons.fcs.getDropMode() == 1) {
																	# Time to hit ground already computed, just gotta display it there
																	fall_time_mins = getprop("sim/model/f15/armament/fall-time-mins");
																	fall_time_secs = getprop("sim/model/f15/armament/fall-time-secs");
																	obj.window17.setText(sprintf("CCIP %02d:%02d", fall_time_mins, fall_time_secs));
																	obj.window17.setVisible(1);
																} elsif ((weap.type == "GBU-12" or weap.type == "GBU-31" or weap.type == "GBU-32" or weap.type == "GBU-39" or weap.type == "GBU-54" or weap.type == "MK-84" or weap.type == "MK-83" or weap.type == "MK-82" or weap.type == "MK-82AIR" or weap.type == "CBU-87" or weap.type == "CBU-105") and pylons.fcs.getDropMode() == 0 and obj.timeToRelease != nil and obj.CCRP_active != nil and obj.CCRP_active > 0) {
																	obj.timeToReleaseH = int(obj.timeToRelease/3600);
																	obj.timeToRelease = obj.timeToRelease-obj.timeToReleaseH*3600;
																	obj.timeToReleaseM = int(obj.timeToRelease/60);
																	obj.timeToRelease = obj.timeToRelease-obj.timeToReleaseM*60;
																	if (obj.timeToReleaseH < 1) {
																		obj.window17.setText(sprintf("CCRP %02d:%02d",obj.timeToReleaseM,obj.timeToRelease));
																	} else {
																		obj.window17.setText("CCRP XX:XX");
																	}
																	obj.window17.setVisible(1);
																} elsif (weap.type == "AGM-65B" or weap.type == "AGM-65D" or weap.type == "AGM-84D" or weap.type == "AGM-84E" or weap.type == "AGM-119A" or weap.type == "AGM-154A" or weap.type == "AGM-158A" or weap.type == "GBU-31" or weap.type == "GBU-32" or weap.type == "CBU-105" or weap.type == "GBU-54" or weap.type == "GBU-39") {  # For AGMs, we display the time till weapon's ready (TODO: display time till no power left when power system is implemented)
																	if (!(weap.ready_time == 0)) { # Only if the weapon has a ready timer
																		curr_time = getprop("sim/time/elapsed-sec");
																		standby_time = weap.ready_standby_time;  # time at which the weapon started readyin process
																		if (curr_time > (standby_time + weap.ready_time)) {  # weapon's ready
																			obj.window17.setText("RDY");
																		} else {
																			timer = math.round((standby_time + weap.ready_time) - curr_time);
																			timer_sec = timer;
																			timer_min = math.floor(timer / 60);
																			if (timer_min > 0) {
																				timer_sec = timer_sec - timer_min * 60;
																			}
																			obj.window17.setText(sprintf("STBY %02d:%02d", timer_min, timer_sec));
																		}
																	} else {
																		obj.window17.setText("RDY");
																	}
																	obj.window17.setVisible(1);
																} elsif ((weap.type == "AIM-120D" or weap.type == "CATM-120D" or weap.type == "AIM-9X" or weap.type == "CATM-9X" or weap.type == "AGM-88E" or weap.type == "AGM-158C") and getprop("instrumentation/datalink/power")) {  # needs datalink to be ON to work
																	if (weap.type == "AIM-9X" or weap.type == "CATM-9X") {
																		mean_speed = mean_9_x_speed;
																	} elsif (weap.type == "AIM-120D" or weap.type == "CATM-120D") {
																		mean_speed = mean_120_d_speed;
																	} elsif (weap.type == "AGM-65B" or weap.type == "AGM-65D") { # not used anymore, we display time till ready instead for AGMs
																		mean_speed = agm65_speed;  # all AGM variants got the same mean course speed
																	} elsif (weap.type == "AGM-84D" or weap.type == "AGM-84E") { # not used anymore, we display time till ready instead for AGMs
																		mean_speed = agm84_speed;  # all AGM variants got the same mean course speed
																	} elsif (weap.type == "AGM-88E") {
																		mean_speed = agm88_speed;
																	} elsif (weap.type == "AGM-158C") {
																		mean_speed = agm158c_speed;
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
																		hit_chance = getprop(data_root ~ "/hit");
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
																		obj.window17.setText(sprintf("%02d:%02d", tti_mins, tti_secs));
																	} else {  # if missile is active
																		obj.window17.setText(sprintf("L %02d:%02d %1.1f n", tti_mins, tti_secs, distance_to_target / 1.15));  #  if missile's live, indicate it is an aditionally display its distance to the target
																	}
																	obj.window17.setVisible(1);
																} else {
																	obj.window17.setText("XX:XX");
																	obj.window17.setVisible(1);
																}
															} else {
																obj.window17.setVisible(0);
															}
                                                        }),
            props.UpdateManager.FromHashList(["AutopilotRouteManagerActive",
                                                        "AutopilotRouteManagerWpDist",
                                                        "AutopilotRouteManagerWpEtaSeconds",
                                                        "ControlsGearGearDown",
														"NavigationMode",
														"TacanStationInRange",
														"TacanBearingRelDeg",
														"HeadingMag",
														"TacanStationDistance"], 0.1, func(val)
                                                        {
															if (val.NavigationMode == 1) { # TACAN nav mode overrides waypoint nav mode if the switch for it i ON
																if (val.TacanStationInRange) {
																	TacanDistance = val.TacanStationDistance;
																	obj.HudNavRangeDisplay = sprintf("N %.1f", TacanDistance);
																	# In TACAN mode, stead of time for intercept, we display the relative aspect of the station
																	deg_rel = math.round(val.HeadingMag-val.TacanBearingRelDeg);
																	sign = "";
																	if (deg_rel > 0) {
																		sign = "L";
																	} elsif (deg_rel < 0) {
																		deg_rel = -deg_rel;
																		sign = "R";
																	} elsif (deg_rel == 0) {
																		deg_rel = "";
																		sign = "T";
																	} elsif (deg_rel == 360) {
																		deg_rel = "";
																		sign = "H";
																	}
																	obj.HudNavRangeETA = sprintf("%s%s *", sign, deg_rel);
																} else {
																	obj.HudNavRangeDisplay = "N XX";
																	obj.HudNavRangeETA = "XX";
																}
															} elsif (val.AutopilotRouteManagerActive) {
                                                                obj.rng = val.AutopilotRouteManagerWpDist;
                                                                obj.eta_s = val.AutopilotRouteManagerWpEtaSeconds;
                                                                if (obj.rng != nil) {
                                                                    obj.HudNavRangeDisplay = sprintf("N %4.1f", obj.rng);
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
	                                                                obj.HudNavRangeETA = sprintf("%02d:%02d", nav_mins, nav_secs);
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
														"FuelLow",
														"VelocitiesAirspeedKt",
														"RadarStandby",
														"RadarFilterMode"], 0.1, func(val)
														{
															if (val.AltitudeDeckMinEnabled and (val.AltimeterIndicatedAltitudeFt < val.AltitudeDeckMin) and !val.ControlsGearGearDown) {
																obj.altitudeDeck.show();
																setprop("sim/model/f15/avionics/altitude-deck-hit", 1);
															} elsif (val.AltitudeDeckMaxEnabled and (val.AltimeterIndicatedAltitudeFt > val.AltitudeDeckMax) and !val.ControlsGearGearDown) {
																obj.altitudeDeck.show();
																setprop("sim/model/f15/avionics/altitude-deck-hit", 1);
															} else {
																obj.altitudeDeck.hide();
																setprop("sim/model/f15/avionics/altitude-deck-hit", 0);
															}
															if (val.TimeTilCrash != nil and val.TimeTilCrash > 0 and val.TimeTilCrash < 8) {
		                                                     	obj.flyup.setText("FLYUP");
		                                                     	obj.flyup.show();
															} elsif (getprop("sim/time/elapsed-sec") > 2 and val.FuelLow > 0 and getprop("fdm/jsbsim/systems/electrics/ac-essential-bus1") > 0) {
		                                                     	obj.flyup.setText("FUEL");
		                                                     	obj.flyup.show();
															} elsif (getprop("sim/time/elapsed-sec") > 2 and val.BingoFuel > 0 and getprop("fdm/jsbsim/systems/electrics/ac-essential-bus1") > 0) {
		                                                     	obj.flyup.setText("BINGO");
		                                                     	obj.flyup.show();
															} elsif (val.VNE < val.VelocitiesAirspeedKt) {
															    obj.flyup.setText("LIMIT");
		                                                     	obj.flyup.show();
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
																time_till_crash_sec = sprintf("%.0f", val.TimeTilCrash);
																time_till_crash_mil_sec = (val.TimeTilCrash - time_till_crash_sec) * 1000;
																if (time_till_crash_mil_sec < 0) {
																	time_till_crash_mil_sec = 1000 + time_till_crash_mil_sec;
																	time_till_crash_sec = time_till_crash_sec - 1;
																}
																if (time_till_crash_mil_sec == nil) {
																	time_till_crash_mil_sec = 000;
																}
																time_till_crash_mil_sec = sprintf("%3d", time_till_crash_mil_sec);
			                                                    obj.flyupTime.setText(sprintf("%s:%3d", time_till_crash_sec, time_till_crash_mil_sec));
			                                                    obj.flyupTime.show();
																setprop("sim/model/f15/avionics/pullup", 1);
			                                                } else {
			                                                    obj.flyupLeft.hide();
			                                                    obj.flyupRight.hide();
			                                                    obj.flyupTime.hide();
																setprop("sim/model/f15/avionics/pullup", 0);
			                                                }

															# NO RAD label if radar's either in standby or offline
															if (val.RadarStandby) {
																obj.stby.show();
															} else {
																obj.stby.hide();
															}

															obj.radar_filter_mode = "A/A";  # default mode
															if (val.RadarFilterMode == 1) {
															    obj.radar_filter_mode = "A/G";
															} elsif (val.RadarFilterMode == 2) {
															    obj.radar_filter_mode = "A/SEA";
															}

															obj.window20.setVisible(!val.RadarStandby);
															obj.window20.setText(obj.radar_filter_mode);
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
														"NavigationMode",
														"OrientationHeadingDeg",
														"ArmamentRippleCount",
														"TacanChannel",
														"GunsMode"], nil, func(val)
                                                        {
                                                            if (val.ControlsArmamentMasterArmSwitch) {
                                                                obj.window11.setVisible(1);
                                                                obj.window15.setVisible(1);
                                                                obj.window16.setVisible(1);
                                                                obj.window15.setText(sprintf("CHF %03d",getprop("ai/submodels/submodel[13]/count")));
                                                                obj.window16.setText(sprintf("FLA %03d",getprop("ai/submodels/submodel[5]/count")));
																obj.boreSymbol.hide();
                                                                weapon_type = getprop("sim/model/f15/systems/armament/selected-arm");
                                                                obj.window11.setText(weapon_type);
                                                                var w_s = val.ControlsArmamentWeaponSelector;
                                                                obj.window2.setVisible(1);
																eegsShow = 0;
																obj.window18.setVisible(0);

                                                                if (w_s == 0) {
																	eegsShow = 1;
																	obj.boreSymbol.show();
																	if (pylons.fcs.getSelectedWeapon() != nil and pylons.fcs.getSelectedWeapon().type != "LAU-68C") {
	                                                                    obj.window2.setText(sprintf("%3d",val.ArmamentRounds));
																		# Show GUNS mode
																		if (val.GunsMode == 0) {
																			obj.window17.setText("FUNNEL");
																		} elsif (val.GunsMode == 1) {
																			obj.window17.setText("STRF");
																		} elsif (val.GunsMode == 2) {
																			obj.window17.setText("SNAP");
																		} else {
																			obj.window17.setText("SIGHT");
																		}
																	} else {
																		obj.window2.setText(sprintf("%3d",pylons.fcs.getAmmo()));
																		# Show GUNS mode
																		obj.window17.setText("STRF");
																	}
																	obj.window17.setVisible(1);
                                                                } else if (w_s == 1) {
                                                                    obj.window2.setText(sprintf("%2d SRM", val.ArmamentAim9Count));
																	if (pylons.fcs.getSelectedWeapon() != nil) {
																		obj.window18.setVisible(1);
																		caged = pylons.fcs.getSelectedWeapon().isCaged();
																		auto = pylons.fcs.getSelectedWeapon().isAutoUncage();
																		if (caged == 1) {
																			caged = "Caged";
																		} else {
																			caged = "Uncaged";
																		}
																		if (auto == 1) {
																			auto = "A";
																		} else {
																			auto = "M";
																		}
																		obj.window18.setText(sprintf("%s %s", auto, caged));
																	}
                                                                } else if (w_s == 2){
                                                                    obj.window2.setText(sprintf("%2d AAM", val.ArmamentAim120Count
                                                                                                + val.ArmamentAim7Count));
																	if (!pylons.fcs.isLock()) {  # If there's no lock, inform it's in MADDOG mode
																		obj.window18.setVisible(1);
																		obj.window18.setText("MADDOG");
																	}
                                                                } else if (w_s == 5) {
																	if (weapon_type != nil and weapon_type != "") {  # additonaly display the current ground weapon's count along the total ground ordonnance count
																		obj.window2.setText(sprintf("%2d/%2d GND", pylons.fcs.getAmmoOfType(weapon_type), val.ArmamentAgmCount));
																	} else {
                                                                    	obj.window2.setText(sprintf("%2d GND", val.ArmamentAgmCount));
																	}
																	if (pylons.fcs.getSelectedWeapon() != nil and pylons.fcs.getSelectedWeapon().type != "AGM-65B" and pylons.fcs.getSelectedWeapon().type != "AGM-65D" and pylons.fcs.getSelectedWeapon().type != "AGM-84D" and pylons.fcs.getSelectedWeapon().type != "AGM-84E" and pylons.fcs.getSelectedWeapon().type != "AGM-119A" and pylons.fcs.getSelectedWeapon().type != "AGM-88E") {
																		obj.window18.setVisible(1);
																		obj.window18.setText(sprintf("RIPL %2d", val.ArmamentRippleCount));
																	} elsif (pylons.fcs.getSelectedWeapon() != nil) {  # For the AGMs, instead of ripple count, we display the status of the seeker
																		obj.window18.setVisible(1);
																		if (pylons.fcs.getSelectedWeapon() != nil) {
																			caged = pylons.fcs.getSelectedWeapon().isCaged();  # AGM-65B caging is all automatic and hard-coded in the weapons.nas
																			if (caged == 1) {
																				caged = "Caged -NO LOCK";
																			} else {
																				caged = "Uncaged -LOCK";
																			}
																			obj.window18.setText(sprintf("%s", caged));
																		}
																	}
																	#if (pylons.fcs.getSelectedWeapon() != nil and (pylons.fcs.getSelectedWeapon().type == "AGM-154A" or pylons.fcs.getSelectedWeapon().type == "AGM-158A" or pylons.fcs.getSelectedWeapon().type == "AGM-158C" or pylons.fcs.getSelectedWeapon().type == "GBU-31" or pylons.fcs.getSelectedWeapon().type == "GBU-32")) {  # For GPS guided ordonnance, display target's GPS coordinates
																	#	tgt_lat = getprop("sim/model/f15/fcs/target-lat");
																	#	tgt_lon = getprop("sim/model/f15/fcs/target-lon");
																	#	tgt_alt = getprop("sim/model/f15/fcs/target-alt");
																	#	obj.window18.setText(sprintf("%03d lat %03d lon - %03d ft", tgt_lat, tgt_lon, tgt_alt));
																	#	obj.window18.setVisible(1);
																	#}
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
                                                                if (val.HudNavRangeDisplay != "" and val.NavigationMode == 0) {  # NavigationMode: 0 = waypoint, 1= TACAN, 2=ILS Nav (not implemented), 3=ILS TACAN (not implemented)
                                                                	obj.window3.setText("NAV");
																} elsif (val.HudNavRangeDisplay != "" and val.NavigationMode == 1) {
                                                                	obj.window3.setText(sprintf("TACAN %s", val.TacanChannel));
                                                                } else {
	                                                                obj.window3.setText("");
																}
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

		# CCRP shit
		me.CCRP_active = me.CCRP();

		# EEGS mode's status update
		me.eegsGroup.setVisible(eegsShow);
        if (eegsShow and !me.eegsLoop.isRunning) {
            me.eegsLoop.start();
        } elsif (!eegsShow and me.eegsLoop.isRunning) {
            me.eegsLoop.stop();
			me.aaTargetDesignationGrp.setVisible(0);
        }

		# GUNS Mode target aspect
		asp = awg_9.getPriorityTarget();  # simply return the active target if any
		if (asp != nil) {
			lastH = asp.get_heading();  # should be last known heading, but we don't have that function in the F-15's radar
		} else {
			lastH = nil;
		}
		if (lastH != nil and getprop("sim/model/f15/controls/armament/weapon-selector") == 0 and getprop("sim/model/f15/controls/armament/master-arm-switch")) {
			var mr = 0.4 * 1.5;
			var radius = 20 * mr;
			me.GUNSAspect.setRotation(D2R*(lastH-getprop("orientation/heading-deg")+180));
			me.GUNSAspect.setTranslation(sx*0.5,sy*0.25);#0.4=mr
			me.GUNSAspect.setCenter(0,-radius);
			me.GUNSAspect.setVisible(1);
		} else {
			me.GUNSAspect.setVisible(0);
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
		if (me.brt > 0 and getprop("sim/model/f15/stores/nav-mounted") == 1 and me.color[3] != 0 and getprop("sim/model/f15/avionics/hud-flir-on")) {
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
				if (me.weapon_selected == "AIM-9X" or me.weapon_selected == "CATM-9X") {
					if (me.weapn != nil) {
						if (me.weapn.status == armament.MISSILE_LOCK and !getprop("instrumentation/radar/radar-standby")) {
							me.asec65 = 1;
							currASEC = nil;#[sx*0.5,sy*0.25];
						} elsif (!getprop("instrumentation/radar/radar-standby")) {
							me.asec100 = 1;
							currASEC = nil;#[sx*0.5,sy*0.25];
						}
					}
				} elsif (me.weapon_selected == "AIM-120D" or me.weapon_selected == "CATM-120D") {
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
            if (me.weapon_selected == "AIM-120D" or me.weapon_selected == "AIM-9X" or me.weapon_selected == "CATM-9X" or me.weapon_selected == "CATM-120D") {
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
            if (me.lastH != nil and (me.weapon_selected == "AIM-120D" or me.weapon_selected == "CATM-120D")) {
                me.ASEC120Aspect.setRotation(D2R*(me.lastH-getprop("orientation/heading-deg")+180));
                me.rdL = 1;
                me.rdT = 1;
            } elsif (me.lastH != nil and (me.weapon_selected == "AIM-9X" or me.weapon_selected == "CATM-9X")) {
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
            if (me.weapon_selected == "AIM-120D" or me.weapon_selected == "CATM-120D") {
                if (!pylons.fcs.isLock()) {
                    me.radarLock.setTranslation(0, -sy*0.25+262*0.3*0.5);
                    me.rdL = 1;
                }
            } elsif (me.weapon_selected == "AIM-9X" or me.weapon_selected == "CATM-9X") {
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
            } elsif (me.weapon_selected == "AGM-65B" or me.weapon_selected == "AGM-65D" or me.weapon_selected == "AGM-119A" or me.weapon_selected == "AGM-88E") {  # We wanna display the AGMs' seeker pos on the HUD
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
        if (me.ccipInfo == nil or notification.ControlsArmamentWeaponSelector != 5 or pylons.fcs.getDropMode() == 0) {
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
	interpolateCoords: func (start, end, fraction) {
        me.xx = math.clamp((start.x()*(1-fraction)+end.x()*fraction),math.min(start.x(),end.x()),math.max(start.x(),end.x()));
        me.yy = math.clamp((start.y()*(1-fraction)+end.y()*fraction),math.min(start.y(),end.y()),math.max(start.y(),end.y()));
        me.zz = math.clamp((start.z()*(1-fraction)+end.z()*fraction),math.min(start.z(),end.z()),math.max(start.z(),end.z()));

        me.cc = geo.Coord.new();
        me.cc.set_xyz(me.xx,me.yy,me.zz);
        return me.cc;
    },

	# CCRP Loop
	CCRP: func() {
        if (getprop("sim/model/f15/controls/armament/master-arm-switch") != 0 and pylons.fcs.getDropMode() == fc.DROP_CCRP) {
            var selW = pylons.fcs.getSelectedWeapon();
            if (selW == nil) {
                me.solutionCue.hide();
                me.ccrpMarker.hide();
                me.bombFallLine.hide();
                return 0;
            }
            var trgt = fc.getCCRPTarget();

            if (trgt == nil) {
                # We must return 1 if it's a bomb and we're in CCRP drop mode
                me.solutionCue.hide();
                me.ccrpMarker.hide();
                me.bombFallLine.hide();
                return fc.containsVector(fc.CCIP_CCRP, selW.type);
            }

			#print("SUP");
			#print(selW.status);
			#print(me.CCRP_active);
			#print(fc.containsVector(fc.CCIP_CCRP, selW.type));
            if (me.CCRP_active > 0 and fc.containsVector(fc.CCIP_CCRP, selW.type) and selW.status == armament.MISSILE_LOCK) {
                me.distCCRP = getprop("sim/model/f15/armament/distCCRP");
                if (me.distCCRP == -1 or (me.distCCRP*M2NM > 13.2 and selW.guidance == "laser")) {#1F-F16CJ-34-1: max laser dist is 13.2nm
                    me.solutionCue.hide();
                    me.ccrpMarker.hide();
                    me.bombFallLine.hide();
                    return 1;
                }
                if (getprop("velocities/groundspeed-kt") > 0) {
                    me.timeToRelease = me.distCCRP/getprop("velocities/groundspeed-kt");
                }
                me.distCCRP/=4000;
                if (me.distCCRP > 0.75) {
                    me.distCCRP = 0.75;
                }
                me.ldr = nil;#trgt.getLastAZDeviation();
                if (me.ldr == nil) {
                    me.blepCoord = trgt.get_Coord();
                    if (me.blepCoord != nil) {  # trgt == armament.contactPoint and
                        me.blepHeading = geo.aircraft_position().course_to(me.blepCoord);
                        me.ldr = geo.normdeg180(me.blepHeading-getprop("orientation/heading-deg"));
                    } else {
                        me.solutionCue.hide();
                        me.ccrpMarker.hide();
                        me.bombFallLine.hide();
                        return 1;
                    }
                }
                me.bombFallLine.setTranslation(me.ldr*me.texelPerDegreeX,0);
                me.ccrpMarker.setTranslation(me.ldr*me.texelPerDegreeX,0);
                me.solutionCue.setTranslation(me.ldr*me.texelPerDegreeX,sy*0.5-sy*0.5*me.distCCRP);
                me.bombFallLine.show();
                me.ccrpMarker.show();
                me.solutionCue.show();
                return math.abs(me.ldr)<20?2:1;
            } else {
                me.solutionCue.hide();
                me.ccrpMarker.hide();
                me.bombFallLine.hide();
                return 1;
            }
        } else {
            me.solutionCue.hide();
            me.ccrpMarker.hide();
            me.bombFallLine.hide();
            return 0;
        }
    },

	# EEGS Disply loop
	# Taken from F-16's model, and adapted to the F-15 by Jimmy L. Miles
	# Only modes adapted and tested for now: SNAP, FUNNEL
    # Should match gun submodel parameters
    gunEda: 0.00338158219,
    gunWeight: 0.226,
    gunSpeed: 3450.0,
    gunCd: 0.09,
    gunLoc: [0.29069, 1.512999768, 0.558520092],  # converted from ft in the submodels, as it needs to be in meters

    displayEEGS: func() {
	   #note: this stuff is expensive like hell to compute, but..lets do it anyway.
	   var gunSight = getprop("sim/model/f15/armament/gun-sight");
	   var st = systime();
	   me.hydra = 0;
	   if (pylons.fcs.getSelectedWeapon() != nil and pylons.fcs.getSelectedWeapon().type == "LAU-68C") {
	   		me.hydra = 1;
	   }
	   if (awg_9.active_u != nil and awg_9.active_u.get_display()) {
		   me.designatedDistanceFT = awg_9.active_u.get_range() * 6000;  # conversion from nm to ft
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
		   if (gunSight == 1 or me.hydra) {
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
				   var halfspan = math.atan2(getprop("sim/model/f15/armament/gun-eegs-wingspan-ft")*0.5,me.eegsMe.shellPosDist[k])*R2D*me.texelPerDegreeX;
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
					   me.vari = getprop("sim/variant-id");  # always returns none
					   me.oldStrf = me.vari == 0 or me.vari == 1 or me.vari == 3;
					   var mr = 0.4 * 1.5;
					   if (me.oldStrf) {
							   # draw the old STRF pipper (T.O. GR1F-16CJ-34-1-1 page 1-442 and MLU Tape 1 page 185)
							   var pipperRadius = 15 * mr;
							   if (me.strfRange <= (me.hydra?4000:getprop("sim/model/f15/armament/gun-strf-max-range-ft"))) {
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
											   .lineTo(-5,-5)  # where the bore symbol is
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
											   .lineTo(-5,-5)  # where the bore symbol is
											   .setColor(me.color);
							   }
					   } else {
							   # draw the new STRF pipper (T.O. GR1F-16CJ-34-1-1(new) page 2-299 and MLU Tape 2 page 79)
							   me.pipperOuterRadius = 25 * mr;
							   me.pipperInnerRadius = 20 * mr;
							   me.pipperRangeTick   =  5 * mr;
							   me.pipperRangeMode = me.strfRange <= getprop("sim/model/f15/armament/gun-strf-max-range-ft") and me.strfRange <= 12000?0:(me.strfRange <= 12000?1:(me.strfRange <= getprop("sim/model/f15/armament/gun-strf-max-range-ft") and me.strfRange <= 24000?2:(me.strfRange <= 24000?3:4)));

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

									   if (getprop("sim/model/f15/armament/gun-strf-max-range-ft") <= 12000) {
											   me.td_rads = me.interpolate(getprop("sim/model/f15/armament/gun-strf-max-range-ft"), 0, 12000, 0, 2*math.pi);
									   } else {
											   me.td_rads = me.interpolate(getprop("sim/model/f15/armament/gun-strf-max-range-ft"), 12000, 24000, 0, 2*math.pi);
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

		   me.eegsMe.geodPos = aircraftToCart({x:-me.gunLoc[0], y:-me.gunLoc[1], z: -me.gunLoc[2]});#position of gun in aircraft (x and z inverted)
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
		   me.aaTargetDesignationGrp.setVisible(1);
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
		   if (me.designatedDistanceFT > getprop("sim/model/f15/armament/gun-aa-max-range-ft")) {
			   me.td_rads = me.interpolate(getprop("sim/model/f15/armament/gun-aa-max-range-ft"), 0, 12000, 0, 2*math.pi);
			   me.td_x3 = (1.20*radius)*math.sin(me.td_rads);
			   me.td_y3 = -(1.20*radius)*math.cos(me.td_rads);
			   me.aaTargetDesignator.moveTo(-mr+me.td_x3,me.td_y3);
			   me.aaTargetDesignator.arcSmallCW(mr,mr, 0, mr*2, 0);
			   me.aaTargetDesignator.arcSmallCW(mr,mr, 0, -mr*2, 0);
		   }
	   } else {
	   		me.aaTargetDesignationGrp.setVisible(0);
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
		FuelLow                                 : "sim/model/f15/lights/ca-fuel-low",
		RadarStandby                            : "instrumentation/radar/radar-standby",
		ArmamentRippleCount                     : "controls/armament/dual",
		NavigationMode                          : "sim/model/instrumentation/vhf/mode",
		TacanStationInRange                     : "instrumentation/tacan/in-range",
		TacanBearingRelDeg                      : "instrumentation/tacan/indicated-bearing-true-deg",
		HeadingMag                              : "orientation/true-heading-deg",
		TacanStationDistance                    : "instrumentation/tacan/indicated-distance-nm",
		TacanChannel                            : "instrumentation/tacan/display/channel",
		TacanXShift                             : "instrumentation/tacan/display/x-shift",
		TacanYShift                             : "instrumentation/tacan/display/y-shift",
		GunsMode                                : "sim/model/f15/armament/gun-sight",
		GroundAlt                               : "instrumentation/tfs/ground-altitude-ft-now",
		RadarFilterMode                         : "instrumentation/radar/radar-filter-mode",
		IsRefueling                             : "fdm/jsbsim/propulsion/refuel",
		IsRefueling2                            : "systems/refuel/contact",
		IsDumpingFuel                           : "fdm/jsbsim/propulsion/fuel_dump",
		CurrentFuelLb                           : "sim/model/f15/instrumentation/fuel-gauges/total-display",
		FuelPercentage                          : "consumables/fuel/total-fuel-norm",
		ThrustToWeightRatio                     : "sim/model/f15/avionics/thrust-weight-ratio",
		AltitudeAGL                             : "position/altitude-agl-ft",
};

emexec.ExecModule.register("F15-HUD",input, F15HUD.new("Nasal/HUD/HUD_ex.svg", "HUDImage1"), 2);
