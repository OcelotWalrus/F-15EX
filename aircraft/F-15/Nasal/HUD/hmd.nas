# Canvas HMD
# ---------------------------
# HUD uses data in the frame notification
# HUD is in two parts so we have a single class that we can instantiate
# twice on for each combiner pane
# ---------------------------
# Richard Harrison (rjh@zaretto.com) 2016-07-01  - based on F-15 HUD
# ---------------------------

# Adapted to the F-15EX by Jimmy L. Miles

var stroke1 = 4;
var fontSize = 36;
var fontRatio = 1;

var ht_debug = 0;

var uv_x1 = 0;
var uv_x2 = 0;
var uv_used = uv_x2-uv_x1;
var tran_x = 0;
var tran_y = 0;

var eye_to_hmcs_distance_m = getprop("sim/rendering/camera-group/znear");#0.1385;#meters
var center_to_edge_distance_m = 0.025;#meters
var screen_w=getprop("sim/startup/xsize");
var screen_h=getprop("sim/startup/ysize");

var Mp = props.globals.getNode("ai/models");

var VISUAL = 47;
var SLAVE  = 76;

var F15_HMD = {
    map: func (value, leftMin, leftMax, rightMin, rightMax) {
        # Figure out how 'wide' each range is
        var leftSpan = leftMax - leftMin;
        var rightSpan = rightMax - rightMin;

        # Convert the left range into a 0-1 range (float)
        var valueScaled = (value - leftMin) / leftSpan;

        # Convert the 0-1 range into a value in the right range.
        return rightMin + (valueScaled * rightSpan);
    },

    new : func (canvas_item, sx, sy){
        var obj = {parents : [F15_HMD] };

        #obj.canvas= canvas.new({
         #       "name": "F15 HMD",
          #          "size": [1024,1024],
           #         "view": [sx,sy],#1024,1024
            #        "mipmapping": 0, # mipmapping will make the HUD text blurry on smaller screens
             #       "additive-blend": 1# bool
              #      });


        uv_x1 = 0;
        uv_x2 = 1;
        uv_used = uv_x2-uv_x1;
        tran_x = 0;

        obj.sy = 1024;
        obj.sx = 1024*uv_used;

        #obj.canvas.addPlacement({"node": canvas_item});
        #obj.canvas.setColorBackground(0.30, 1, 0.3, 0.00);

# Create a group for the parsed elements
        obj.svg_canvas = canvas.getDesktop();#obj.canvas.createGroup().hide();
        obj.svg_canvas.setColor(0.5,1,0.5);



        obj.hydra = 0;

        #obj.canvas._node.setValues({
         #       "name": "F15 HMD",
          #          "size": [1024,1024],
           #         "view": [sx,sy],
            #        "mipmapping": 0,
             #       "additive-blend": 1# bool
              #      });



# Convert from old HMCS 3D model to new Canvas on Desktop:
        tran_x = screen_w*0.5;
        tran_y = screen_h*0.5;

        obj.svg_orig = obj.svg_canvas.createChild("group");
        obj.svg_orig.setTranslation (tran_x,tran_y);
        obj.svg_orig.setCenter(tran_x,tran_y);
        #obj.svg_orig.setScale(1,-1);

        obj.svg = obj.svg_orig.createChild("group");

#printf("Screen %d,%d  degs512edge %.2f",screen_w,screen_h, degToEdge);#

        obj.canvasWidth = screen_w;
        obj.degToEdge = 10.23;#math.atan(0.025/0.1385); Real is 20 deg diameter, which in old HMCS was 500 pixels.So for 512 its 10.23
        obj.svg_new = obj.svg;
        obj.svg = obj.svg_new.createChild("group").hide();
        sx = 1024;
        sy = 1024;

# End convert from old HMCS 3D model to new Canvas on Desktop (more code further down)

        obj.mainCross = obj.svg.createChild("path")
                .moveTo(0,0)
                .lineTo(1024,1024)
                .moveTo(1024,0)
                .lineTo(0,1024)
                .setStrokeLineWidth(stroke1)
                .setColor(0,0,1)
                .hide();
        obj.mainCircle = obj.svg.createChild("path")
            .moveTo(12,512)
            .arcSmallCW(500,500, 0, 500*2, 0)
            .arcSmallCW(500,500, 0, -500*2, 0)
            .setStrokeLineWidth(stroke1)
            .hide()
            .setColor(0,0,1);

        obj.off = 1;


        HUD_FONT = aircraft.HUDFont;

        obj.window2 = obj.svg.createChild("text")
                .setText("BRAKES")
                .setTranslation(240,600)
                .setAlignment("right-bottom-baseline")
                .setColor(0,1,0,1)
                .setFont(HUD_FONT)
                .setFontSize(fontSize, 1.1);
        obj.window3 = obj.svg.createChild("text")
                .setText("R 30")
                .setTranslation(800,670)
                .setAlignment("right-bottom-baseline")
                .setColor(0,1,0,1)
                .setFont(HUD_FONT)
                .setFontSize(fontSize, 1.1);
        obj.window5 = obj.svg.createChild("text")
                .setText("05>07")
                .setTranslation(800,700)
                .setAlignment("right-bottom-baseline")
                .setColor(0,1,0,1)
                .setFont(HUD_FONT)
                .setFontSize(fontSize, 1.1);
        obj.window9 = obj.svg.createChild("text")
                .setText("AMM9")
                .setTranslation(240,630)
                .setAlignment("right-bottom-baseline")
                .setColor(0,1,0,1)
                .setFont(HUD_FONT)
                .setFontSize(fontSize, 1.1);
        obj.window11 = obj.svg.createChild("text")
                .setText("FUEL")
                .setTranslation(240,660)
                .setAlignment("right-bottom-baseline")
                .setColor(0,1,0,1)
                .setFont(HUD_FONT)
                .setFontSize(fontSize, 1.1);
        obj.window12 = obj.svg.createChild("text")
                .setText("1.0")
                .setTranslation(240,240)
                .setAlignment("right-bottom-baseline")
                .setColor(0,1,0,1)
                .setFont(HUD_FONT)
                .setFontSize(fontSize, 1.1);

        obj.total = [];
        obj.scaling = [];

        append(obj.total, obj.window2);
        append(obj.total, obj.window3);
        append(obj.total, obj.window5);
        append(obj.total, obj.window9);
        append(obj.total, obj.window11);
        append(obj.total, obj.window12);
        append(obj.total, obj.mainCircle);

        obj.color = [0,1,0];



#
# Load the target symbosl.
        obj.max_symbols = 10;
        obj.tgt_symbols =  setsize([],obj.max_symbols);
        obj.spike_symbols = setsize([],obj.max_symbols);


        obj.custom = obj.svg.createChild("group");
        obj.flyup = obj.svg.createChild("text")
                .setText("FLYUP")
                .setTranslation(sx*0.5*uv_used,sy*0.30)
                .setAlignment("center-center")
                .setColor(0,1,0,1)
                .setFont(HUD_FONT)
                .setFontSize(fontSize, 1.4);
        append(obj.total, obj.flyup);
        obj.stby = obj.svg.createChild("text")
                .setText("NO RAD")
                .setTranslation(sx*0.5*uv_used,sy*0.15)
                .setAlignment("center-top")
                .setColor(0,1,0,1)
                .setFont(HUD_FONT)
                .setFontSize(fontSize, 1.1);

          append(obj.total, obj.stby);
#        obj.raltR = obj.svg.createChild("text")
#                .setText("R")
#                .setTranslation(sx*1*0.675633-5,sy*0.45)
#                .setAlignment("right-center")
#                .setColor(0,1,0)
#                .setFont(HUD_FONT)
#                .setFontSize(9, 1.1);
#        obj.raltFrame = obj.svg.createChild("path")
#                .moveTo(sx*1*uv_x2-9,sy*0.45+5)
#                .horiz(-41)
#                .vert(-10)
#                .horiz(41)
#                .vert(10)
#                .setStrokeLineWidth(stroke1)
#                .hide()
#                .setColor(0,1,0);
#              append(obj.total, obj.raltFrame);
        obj.boreSymbol = obj.svg.createChild("path")
                .moveTo(472,512)
                .horiz(80)
                .moveTo(512,472)
                .vert(80)
                .setStrokeLineWidth(stroke1)
                .setColor(0,1,0);
            append(obj.total, obj.boreSymbol);



        #obj.speed_type = obj.svg.createChild("text")
        #        .setText("C")
        #        .setTranslation(4+0.25*sx*uv_used,sy*0.49)
        #        .setAlignment("left-bottom")
        #        .setColor(0,1,0,1)
        #        .setFont(HUD_FONT)
        #        .setFontSize(fontSize, 1.1);
        #obj.alt_type = obj.svg.createChild("text")
        #        .setText("R")
        #        .setTranslation(-4+0.75*sx*uv_used,sy*0.49)
        #        .setAlignment("right-bottom")
        #        .setColor(0,1,0,1)
        #        .setFont(HUD_FONT)
        #        .setFontSize(fontSize, 1.1);
        #append(obj.total, obj.speed_type);
        #append(obj.total, obj.alt_type);


        obj.speed_frame = obj.svg.createChild("path")
                .set("z-index",10001)
                .moveTo(8+0.20*sx*uv_used,sy*0.5)
                .lineTo(8+0.20*sx*uv_used-20,sy*0.5-24)
                .horiz(-100)
                .vert(48)
                .horiz(100)
                .lineTo(8+0.20*sx*uv_used,sy*0.5)
                .setStrokeLineWidth(stroke1)
                .setColor(1,0,0);
                append(obj.total, obj.speed_frame);
        obj.speed_curr = obj.svg.createChild("text")
                .set("z-index",10002)
                .setText("425")
                .setTranslation(0.18*sx*uv_used,sy*0.5)
                .setAlignment("right-center")
                .setColor(0,1,0,1)
                .setFont(HUD_FONT)
                .setFontSize(fontSize, 1.1);
        append(obj.total, obj.speed_curr);

        obj.alt_frame = obj.svg.createChild("path")
                .set("z-index",10001)
                .moveTo(32-8+0.80*sx*uv_used-40,sy*0.5)
                .lineTo(32-8+0.80*sx*uv_used+20-40,sy*0.5-24)
                .horiz(112)
                .vert(48)
                .horiz(-112)
                .lineTo(32-8+0.80*sx*uv_used-40,sy*0.5)
                .setStrokeLineWidth(stroke1)
                .setColor(1,0,0);
                append(obj.total, obj.alt_frame);
        obj.alt_curr = obj.svg.createChild("text")
                .set("z-index",10002)
                .setText("88888")
                .setTranslation(16+0.82*sx*uv_used-40,sy*0.5+14)
                .setAlignment("left-bottom-baseline")
                .setColor(0,1,0,1)
                .setFont(HUD_FONT)
                .setFontSize(fontSize, 1.1);
                append(obj.total, obj.alt_curr);

                #append(obj.total, obj.head_mask);
        obj.head_frame = obj.svg.createChild("path")
                .set("z-index",10001)
                .moveTo(40+0.50*sx*uv_used,sy*0.85+40)
                .vert(-40)
                .horiz(-80)
                .vert(40)
                .horiz(80)
                .setStrokeLineWidth(stroke1)
                .setColor(1,0,0);
                append(obj.total, obj.head_frame);
        obj.head_curr = obj.svg.createChild("text")
                .set("z-index",10002)
                .setText("360")
                .setTranslation(0.5*sx*uv_used,sy*0.85+32)
                .setAlignment("center-bottom")
                .setColor(0,1,0,1)
                .setFont(HUD_FONT)
                .setFontSize(fontSize, 1.1);
                append(obj.total, obj.head_curr);



        var mr = 0.4;#milliradians
        obj.ASEC262 = obj.svg.createChild("path")#rdsearch (Allowable Steering Error Circle (ASEC))
            .moveTo(-262*mr,0)
            .arcSmallCW(262*mr,262*mr, 0, 262*mr*2, 0)
            .arcSmallCW(262*mr,262*mr, 0, -262*mr*2, 0)
            .setStrokeLineWidth(stroke1)
            .setColor(0,1,0).hide()
            .setTranslation(sx*0.5*uv_used,sy*0.25+262*mr*0.5);
            append(obj.total, obj.ASEC262);
        obj.ASC = obj.svg.createChild("path")# (Attack Steering Cue (ASC))
            .moveTo(-8*mr,0)
            .arcSmallCW(8*mr,8*mr, 0, 8*mr*2, 0)
            .arcSmallCW(8*mr,8*mr, 0, -8*mr*2, 0)
            .setStrokeLineWidth(stroke1)
            .setColor(0,1,0).hide();
            append(obj.total, obj.ASC);
        obj.ASEC100 = obj.svg.createChild("path")#irsearch
            .moveTo(-100*mr,0)
            .arcSmallCW(100*mr,100*mr, 0, 100*mr*2, 0)
            .arcSmallCW(100*mr,100*mr, 0, -100*mr*2, 0)
            .setStrokeLineWidth(stroke1)
            .setColor(0,1,0).hide()
            .setTranslation(sx*0.5*uv_used,sy*0.25);
            append(obj.total, obj.ASEC100);
        obj.ASEC120 = obj.svg.createChild("path")#rdlock
            .moveTo(-120*mr,0)
            .arcSmallCW(120*mr,120*mr, 0, 120*mr*2, 0)
            .arcSmallCW(120*mr,120*mr, 0, -120*mr*2, 0)
            .setStrokeLineWidth(stroke1)
            .setColor(0,1,0).hide()
            .setTranslation(sx*0.5*uv_used,sy*0.25);
            append(obj.total, obj.ASEC120);
        obj.ASEC65 = obj.svg.createChild("path")#irlock
            .moveTo(-65*mr,0)
            .arcSmallCW(65*mr,65*mr, 0, 65*mr*2, 0)
            .arcSmallCW(65*mr,65*mr, 0, -65*mr*2, 0)
            .setStrokeLineWidth(stroke1)
            .setColor(0,1,0).hide()
            .setTranslation(sx*0.5*uv_used,sy*0.25);
            append(obj.total, obj.ASEC65);
        obj.ASEC65Aspect  = obj.svg.createChild("path")#small triangle on ASEC that denotes aspect of target
            .moveTo(0,-65*mr)
            .lineTo(-5*mr,-75*mr)
            .lineTo(5*mr,-75*mr)
            .lineTo(0,-65*mr)
            .setStrokeLineWidth(stroke1)
            .setColorFill(0,1,0)
            .setColor(0,1,0)
            #.set("z-index",10500)
            .setTranslation(sx*0.5*uv_used,sy*0.25);
            append(obj.total, obj.ASEC65Aspect);
        obj.ASEC120Aspect = obj.svg.createChild("path")
            .setCenter(0,0)
            .moveTo(0,-0*mr)
            .lineTo(-5*mr,-10*mr)
            .lineTo(5*mr,-10*mr)
            .lineTo(0,-0*mr)
            .setColorFill(0,1,0)
            .setStrokeLineWidth(stroke1)
            .setColor(0,1,0)
            #.set("z-index",10500)
            .setTranslation(sx*0.5*uv_used,sy*0.25);
            append(obj.total, obj.ASEC120Aspect);


        mr = mr*1.5;#incorrect, but else in FG it will seem too small.

        obj.initUpdate =1;

        obj.alpha = getprop("sim/model/f15/avionics/hmd-sym");
        obj.power = getprop("sim/model/f15/avionics/hmd-power");



        obj.dlzX      = sx*uv_used*0.75-16;
        obj.dlzY      = sy*0.4;
        obj.dlzWidth  =  20;
        obj.dlzHeight = sy*0.25;
        obj.dlzLW     =   stroke1;
        obj.dlz      = obj.svg.createChild("group")
                        .setTranslation(obj.dlzX, obj.dlzY);
        append(obj.total, obj.dlz);
        obj.dlz2     = obj.dlz.createChild("group");
        obj.dlzArrow = obj.dlz.createChild("path")
           .moveTo(0, 0)
           .lineTo( -obj.dlzWidth*0.5, obj.dlzWidth*0.4)
           .moveTo(0, 0)
           .lineTo( -obj.dlzWidth*0.5, -obj.dlzWidth*0.4)
           .setColor(1,1,1)
           .setStrokeLineWidth(obj.dlzLW);
        obj.dlzClo = obj.dlz.createChild("text")
                .setText("+3409")
                .setAlignment("right-center")
                .setColor(0,1,0)
                .setFont(HUD_FONT)
                .setFontSize(fontSize, 1.0);



        ############################## new center origin stuff that used hud math #################


        obj.centerOrigin = obj.svg.createChild("group");

        obj.flyupLeft    = obj.centerOrigin.createChild("path")
                            .lineTo(-50,-50)
                            .moveTo(0,0)
                            .lineTo(-50,50)
                            .setStrokeLineWidth(stroke1)
                            .setColor(0,1,0);
        obj.flyupRight  = obj.centerOrigin.createChild("path")
                            .lineTo(50,-50)
                            .moveTo(0,0)
                            .lineTo(50,50)
                            .setStrokeLineWidth(stroke1)
                            .setColor(0,1,0);
        append(obj.total, obj.flyupRight);
        append(obj.total, obj.flyupLeft);



        var boxRadius = 30;
        var boxRadiusHalf = boxRadius*0.5;
        var hairFactor = 0.8;
        obj.tgt_symbols = [];
        obj.spike_symbols = [];
        for(var k = 0; k<obj.max_symbols;k+=1) {
            obj.tgt = obj.centerOrigin.createChild("path")
                .moveTo(-boxRadiusHalf,-boxRadiusHalf)
                .vert(boxRadius)
                .horiz(boxRadius)
                .vert(-boxRadius)
                .horiz(-boxRadius)
                .setStrokeLineWidth(stroke1)
                .hide()
                .setColor(0,1,0);
            append(obj.tgt_symbols, obj.tgt);
            append(obj.total, obj.tgt);
            obj.spike = obj.centerOrigin.createChild("path")
                .moveTo(-boxRadiusHalf*.7,-boxRadiusHalf*.7)  # spike boxes are a bit smaller than radar targets
                .vert(boxRadius*.7)
                .horiz(boxRadius*.7)
                .vert(-boxRadius*.7)
                .horiz(-boxRadius*.7)
                .setStrokeLineWidth(7)  # 4 is for targets, 7 is for spikes
                .hide()
                .setColor(0,1,0);
            append(obj.spike_symbols, obj.spike);
            append(obj.total, obj.spike);
        }
        obj.mark_symbols = [];
        for(var u = 0; u<steerpoints.number_of_markpoints_own + steerpoints.number_of_markpoints_dlnk;u+=1) {
            obj.tgt = obj.centerOrigin.createChild("path")
                .moveTo(-boxRadius*0.4,-boxRadius*0.4)
                .lineTo( boxRadius*0.4, boxRadius*0.4)
                .moveTo( boxRadius*0.4,-boxRadius*0.4)
                .lineTo(-boxRadius*0.4, boxRadius*0.4)
                .setStrokeLineWidth(stroke1)
                .hide()
                .setColor(0,1,0);
            append(obj.mark_symbols, obj.tgt);
            append(obj.total, obj.tgt);
        }
        obj.GPSSpotSquare = obj.centerOrigin.createChild("path")
                .moveTo(-boxRadius*.5, boxRadius*.25)
                .lineTo(-boxRadius*.5, boxRadius*.5)
                .lineTo(-boxRadius*.25, boxRadius*.5)
                .moveTo(boxRadius*.25, boxRadius*.5)
                .lineTo(boxRadius*.5, boxRadius*.5)
                .lineTo(boxRadius*.5, boxRadius*.25)
                .moveTo(boxRadius*.5, -boxRadius*.25)
                .lineTo(boxRadius*.5, -boxRadius*.5)
                .lineTo(boxRadius*.25, -boxRadius*.5)
                .moveTo(-boxRadius*.25, -boxRadius*.5)
                .lineTo(-boxRadius*.5, -boxRadius*.5)
                .lineTo(-boxRadius*.5, -boxRadius*.25)
                .setStrokeLineWidth(stroke1)
                .setColor(0,1,0)
                .hide();
        append(obj.total, obj.GPSSpotSquare);
        obj.steerPT = obj.centerOrigin.createChild("path")
                .moveTo(-boxRadius*0.3, 0)
                .lineTo(0, boxRadiusHalf*0.85)
                .lineTo(boxRadius*0.3, 0)
                .lineTo(0, -boxRadiusHalf*0.85)
                .lineTo(-boxRadius*0.3, 0)
                .setStrokeLineWidth(stroke1)
                .hide()
                .setColor(0,1,0);
        append(obj.total, obj.steerPT);
        obj.tgpPointF = obj.centerOrigin.createChild("path")
                     .moveTo(-boxRadiusHalf*0.75, -boxRadiusHalf*0.75)
                     .horiz(boxRadius*0.75)
                     .vert(boxRadius*0.75)
                     .horiz(-boxRadius*0.75)
                     .vert(-boxRadius*0.75)
                     .moveTo(-stroke1,-stroke1)
                     .horiz(2*stroke1)
                     .moveTo(-1*stroke1,0*stroke1)
                     .horiz(2*stroke1)
                     .setStrokeLineWidth(stroke1)
                     .setColor(0,0,0)
                     .hide();
        obj.tgpPointC = obj.centerOrigin.createChild("path")
                     .moveTo(-boxRadiusHalf*0.75, -boxRadiusHalf*0.75)
                     .lineTo(boxRadiusHalf*0.75, boxRadiusHalf*0.75)
                     .moveTo(boxRadiusHalf*0.75, -boxRadiusHalf*0.75)
                     .lineTo(-boxRadiusHalf*0.75, boxRadiusHalf*0.75)
                     .setStrokeLineWidth(stroke1)
                     .setColor(0,0,0)
                     .hide();
        append(obj.total, obj.tgpPointF);
        append(obj.total, obj.tgpPointC);
        obj.radarLock = obj.centerOrigin.createChild("path")
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
            .setStrokeLineWidth(stroke1)
            .setColor(0,1,0);
        append(obj.total, obj.radarLock);
        obj.irLock = obj.centerOrigin.createChild("path")
            .moveTo(-boxRadius*1.5,0)
            .lineTo(0,-boxRadius*1.5)
            .lineTo(boxRadius*1.5,0)
            .lineTo(0,boxRadius*1.5)
            .lineTo(-boxRadius*1.5,0)
            .setStrokeLineWidth(stroke1)
            .setColor(0,1,0);
        append(obj.total, obj.irLock);
        obj.irBore = obj.centerOrigin.createChild("path")
            .moveTo(-boxRadius*0.75,0)
            .lineTo(0,-boxRadius*0.75)
            .lineTo(boxRadius*0.75,0)
            .lineTo(0,boxRadius*0.75)
            .lineTo(-boxRadius*0.75,0)
            .setStrokeLineWidth(stroke1)
            .setColor(0,1,0);
        append(obj.total, obj.irBore);
        obj.irSearch = obj.centerOrigin.createChild("path")
            .moveTo(-boxRadiusHalf*0.75,0)
            .lineTo(0,-boxRadiusHalf*0.75)
            .lineTo(boxRadiusHalf*0.75,0)
            .lineTo(0,boxRadiusHalf*0.75)
            .lineTo(-boxRadiusHalf*0.75,0)
            .setStrokeLineWidth(stroke1)
            .setColor(0,1,0);
        append(obj.total, obj.irSearch);
        obj.rdrBore = obj.centerOrigin.createChild("path")
#            .moveTo(-boxRadiusHalf*4,0)
 #           .horiz(boxRadius*4)
#            .moveTo(0,-boxRadiusHalf*6)
#            .vert(boxRadius*6)
            .moveTo(-boxRadiusHalf*4,0)
            .arcSmallCW(boxRadiusHalf*4,boxRadius*4, 0, boxRadiusHalf*4*2, 0)
            .arcSmallCW(boxRadiusHalf*4,boxRadius*4, 0, -boxRadiusHalf*4*2, 0)
            .setStrokeLineWidth(stroke1)
            .hide()
            .setColor(0,1,0);
        append(obj.total, obj.rdrBore);

        obj.target_locked = obj.centerOrigin.createChild("path")
            .moveTo(-boxRadius,-boxRadius)
            .vert(boxRadius*2)
            .horiz(boxRadius*2)
            .vert(-boxRadius*2)
            .horiz(-boxRadius*2)
            .setStrokeLineWidth(stroke1)
            .hide()
            .setColor(0,1,0);
        append(obj.total, obj.target_locked);
        obj.locatorAngle = obj.svg.createChild("text")
                .setText("0")
                .setAlignment("right-center")
                .setColor(0,1,0,1)
                .setFont(HUD_FONT)
                .setFontSize(fontSize, 1.1);
        append(obj.total, obj.locatorAngle);
        obj.locatorLine = obj.centerOrigin.createChild("path")
                .moveTo(0,0)
                #.horiz(10)
                .vert(-30)
                .setStrokeLineWidth(stroke1)
                .setColor(0,1,0);
        append(obj.total, obj.locatorLine);


        obj.headingScale = Heading.new(obj.centerOrigin);
        obj.headingScale.set_dclt(0);
        append(obj.total, obj.headingScale.getGroup());





        obj.hidingScales = 0;



        #
        # set the update list - using the update manager to improve the performance
        # of the HUD update - without this there was a drop of 20fps (when running at 60fps)
        obj.update_items = [
            props.UpdateManager.FromHashList(["HmdSym", "HmdPower", "Red"], 0.05, func(val)#changed to 0.1, this function is VERY heavy to run.
                                    {
                                          if (0) {
                                            obj.color = [0.5,1,0.5,0];
                                            foreach(item;obj.total) {
                                              item.setColor(obj.color);
                                            }
                                            obj.ASEC120Aspect.setColorFill(obj.color);
                                            obj.ASEC65Aspect.setColorFill(obj.color);
                                          } elsif (val.HmdSym != nil and val.HmdPower != nil) {
                                            var brt = val.HmdSym * val.HmdPower * (getprop("fdm/jsbsim/systems/electrics/ac-left-main-bus") >= 75);
                                            # Ref: 16PR16226 page 60, adjusted up slightly
                                            var night_ratio = 0.6;
                                            obj.daylight_red = math.min(1, obj.extrapolate(val.Red, 0, 0.85, 0, 1));# treat 0.85 as full day light, so it dont have to june and noon at equator to get full brightness
                                            brt *= (night_ratio + (obj.daylight_red * (1 - night_ratio)));
                                            obj.color = [0.5,1,0.5,brt];
                                            foreach(item;obj.total) {
                                              item.setColor(obj.color);
                                            }
                                            obj.ASEC120Aspect.setColorFill(obj.color);
                                            obj.ASEC65Aspect.setColorFill(obj.color);
                                          }
                                      }),
            func(val) {
                                                 if (val.ControlsGearGearDown) {
                                                     #obj.boreSymbol.hide();
                                                 } else {
                                                     #obj.boreSymbol.setTranslation(obj.sx/2,obj.sy-obj.texels_up_into_hud);
                                                     #obj.eegsGroup.setTranslation(obj.sx/2,obj.sy-obj.texels_up_into_hud);
                                                     #printf("bore %d,%d",obj.sx/2,obj.sy-obj.texels_up_into_hud);
                                                     #obj.locatorAngle.setTranslation(obj.sx/2-10,obj.sy-obj.texels_up_into_hud);
                                                     #obj.boreSymbol.show();
                                                 }
                                      },
            #props.UpdateManager.FromHashList(["AltitudeAGL","cara","measured_altitude","altSwitch","alow"], 1.0, func(val)
                                    #  {
                                    #      obj.agl=val.AltitudeAGL;
                                    #      obj.altScaleMode = 0;#0=baro, 1=radar 2=thermo
                                    #      if (hdp.getproper("altSwitch") == 2) {#RDR
                                    #            obj.altScaleMode = hdp.getproper("cara");
                                    #      } elsif (hdp.getproper("altSwitch") == 1) {#BARO
                                    #            obj.altScaleMode = 0;
                                    #      } else {#AUTO
                                    #            if (obj["altScaleModeOld"] != nil) {
                                    #                if (obj.altScaleModeOld == 2) {
                                    #                    obj.altScaleMode = (obj.agl < 1500 and hdp.getproper("cara") and !obj.hidingScales)*2;  # should have and !hdp.getproper("dgft") TODO
                                    #                } else {
                                    #                    obj.altScaleMode = (obj.agl < 1200 and hdp.getproper("cara") and !obj.hidingScales)*2;  # should have and !hdp.getproper("dgft") TODO
                                    #                }
                                    #            } else {
                                    #                obj.altScaleMode = (obj.agl < 1300 and hdp.getproper("cara") and !obj.hidingScales)*2;  # should have and !hdp.getproper("dgft") TODO
                                    #            }
                                    #      }
                                    #      obj.altScaleModeOld = obj.altScaleMode;

                                    #      if(hdp.getproper("altSwitch") == 0 and hdp.getproper("cara") and obj.altScaleMode == 0) {
                                    #          #obj.ralt.setText(sprintf("AR %s", obj.getAltTxt(obj.agl)));
                                    #      } elsif(hdp.getproper("cara") and obj.altScaleMode == 0) {
                                    #          #obj.ralt.setText(sprintf("R %s", obj.getAltTxt(obj.agl)));
                                    #      } else {
                                    #          #obj.ralt.setText("    ,   ");
                                    #      }
                                    #  }),
            func(val) {
                                          obj.speed_curr.setText(sprintf("%03d", math.round(val.VelocitiesAirspeedKt)));
                                      },
            func(val) {

                                            # baro scale

                                            obj.alt_curr.setText(obj.getAltTxt(val.AltimeterIndicatedAltitudeFt));


                                      },
            func(val)  {
                                          obj.window12.setText(sprintf("%.1f", val.InstrumentedG));
                                          obj.window12.show();
                                      },
            func(val) {
                                          if (getprop("instrumentation/heading-indicator/serviceable")) {
                                            var lookDir = vector.Math.pitchYawVector(val.HmdP, val.HmdH,[1,0,0]);
                                            lookDir = vector.Math.rollPitchYawVector(val.OrientationRollDeg, val.OrientationPitchDeg, -val.OrientationHeadingDeg, lookDir);
                                            obj.lookEuler = vector.Math.cartesianToEuler(lookDir);
                                            var lookingAt = obj.lookEuler[0]==nil?val.OrientationHeadingDeg:obj.lookEuler[0];
                                            lookingAt += (val.HeadingMag-val.OrientationHeadingDeg);#convert to magn
                                            obj.head_curr.setText(sprintf("%03d",geo.normdeg(lookingAt)));
                                            obj.headingScale.update(geo.normdeg(lookingAt));
                                          }

                                      },
            func(val) {
                                                 
                                                # Update the GPS Spot
                                                # We got an active ordnance that's a Smart Weapon, and it's got a target
                                                if (pylons.fcs.getSelectedWeapon() != nil and fc.containsVector(fc.CCIP_CCRP, pylons.fcs.getSelectedWeapon().type) and pylons.fcs.getSelectedWeapon().Tgt != nil) {
                                                    obj.gpsPos = hudmath.HudMath.getDevFromCoord(pylons.fcs.getSelectedWeapon().Tgt.get_Coord(), val.HmdH, val.HmdP, {"OrientationRollDeg": val.OrientationRollDeg, "OrientationPitchDeg": val.OrientationPitchDeg, "OrientationHeadingDeg": val.OrientationHeadingDeg,}, geo.viewer_position());
													obj.gpsPos[0] = geo.normdeg180(obj.gpsPos[0]);
                                                    obj.gpsPos[0] = (512/center_to_edge_distance_m)*(math.tan(math.clamp(obj.stptPos[0],-89,89)*D2R))*eye_to_hmcs_distance_m;#0.2m from eye, 0.025 = 512
                                                    obj.gpsPos[1] = -(512/center_to_edge_distance_m)*(math.tan(math.clamp(obj.stptPos[1],-89,89)*D2R))*eye_to_hmcs_distance_m;#0.2m from eye, 0.025 = 512

                                                    obj.clamped = math.sqrt(obj.stptPos[0]*obj.stptPos[0]+obj.stptPos[1]*obj.stptPos[1]) > 500;
                                                    
													obj.GPSSpotSquare.setTranslation(obj.gpsPos);
													obj.GPSSpotSquare.show();
                                                } else {
                                                    obj.GPSSpotSquare.hide();
                                                }
                                                 
                                                 if (flightplan().current > -1 and getprop("autopilot/route-manager/active")) {  # should have !hdp.getproper("dgft") TODO
                                                    obj.plan = flightplan();
                                                    obj.wp = obj.plan.getWP(steerpoints.getCurrentNumber()-1);
                                                    if (obj.wp != nil) {
                                                        obj.wpC = geo.Coord.new();
                                                        if (obj.wp.alt_cstr != nil) {  # steerpoints don't necessarily got an altitude
                                                            obj.wpC.set_latlon(obj.wp.lat,obj.wp.lon,obj.wp.alt_cstr);
                                                        } else {
                                                            obj.wpC.set_latlon(obj.wp.lat,obj.wp.lon,0);
                                                        }
                                                        obj.stptPos = hudmath.HudMath.getDevFromCoord(obj.wpC, val.HmdH, val.HmdP, {"OrientationRollDeg": val.OrientationRollDeg, "OrientationPitchDeg": val.OrientationPitchDeg, "OrientationHeadingDeg": val.OrientationHeadingDeg,}, geo.viewer_position());
                                                        obj.stptPos[0] = geo.normdeg180(obj.stptPos[0]);
                                                        obj.stptPos[0] = (512/center_to_edge_distance_m)*(math.tan(math.clamp(obj.stptPos[0],-89,89)*D2R))*eye_to_hmcs_distance_m;#0.2m from eye, 0.025 = 512
                                                        obj.stptPos[1] = -(512/center_to_edge_distance_m)*(math.tan(math.clamp(obj.stptPos[1],-89,89)*D2R))*eye_to_hmcs_distance_m;#0.2m from eye, 0.025 = 512

                                                        obj.clamped = math.sqrt(obj.stptPos[0]*obj.stptPos[0]+obj.stptPos[1]*obj.stptPos[1]) > 500;

                                                        obj.steerPT.setTranslation(obj.stptPos);
                                                        obj.steerPT.show();
                                                        # Always display the steerpoint
                                                        #if (!obj.clamped) {
                                                        #    obj.steerPT.setTranslation(obj.stptPos);
                                                        #    obj.steerPT.show();
                                                        #} else {
                                                        #    obj.steerPT.hide();
                                                        #}
                                                    }
                                                 } else {
                                                     obj.steerPT.hide();
                                                 }
                                                 #for (var t = 400; t < steerpoints.number_of_markpoints_own+400; t+=1) {
                                                #    obj.paintMark(steerpoints.getNumber(t),t-400, hdp);
                                                 #}
                                                 #for (var t = 450; t < steerpoints.number_of_markpoints_own+450; t+=1) {
                                                #    obj.paintMark(steerpoints.getNumber(t),t-450+5, hdp);
                                                # }
                                             },
            func(val) {
                                          var currLimit = 0;
                                          var hd = math.abs(geo.normdeg180(val.HmdH));

                                          if (hd < 5) currLimit = 20.5;
                                          elsif (hd < 15) currLimit = -17;
                                          elsif (hd < 30) currLimit = -30;
                                          else currLimit = -50;

                                          if (val.HmdP < currLimit and getprop("sim/current-view/view-number") != 9) obj.off = 1;  # view 9 in backseater, and backseater should always be able to see it no matter what
                                          else
                                            obj.off = 0;

                                      },
            func(val) {
                                                 obj.ttc = val.TimeTilCrash;
                                                 if (obj.ttc != nil and obj.ttc>0 and obj.ttc<8) {
                                                     obj.flyup.setText("FLYUP");
                                                     #obj.flyup.setColor(1,0,0,1);
                                                     obj.flyup.show();
                                                 } elsif (val.VNE < val.VelocitiesAirspeedKt) {
                                                         obj.flyup.setText("LIMIT");
                                                         obj.flyup.show();
                                                 } elsif (val.FuelLow == 1) {
                                                         obj.flyup.setText("FUEL");
                                                         obj.flyup.show();
                                                 } elsif (val.BingoFuel == 1) {
                                                         obj.flyup.setText("BINGO");
                                                         obj.flyup.show();
                                                 } else {
                                                         obj.flyup.hide();
                                                 }
                                                 obj.flyup.update();
                                                 if (obj.ttc != nil and obj.ttc>0 and obj.ttc<10.5) {
                                                    obj.flyupAmount = math.max(0,obj.extrapolate(obj.ttc,8,9.5,0,1));
                                                    obj.flyupLeft.setTranslation(-obj.flyupAmount*150,0);
                                                    obj.flyupRight.setTranslation(obj.flyupAmount*150,0);
                                                    obj.flyupLeft.show().update();
                                                    obj.flyupRight.show().update();
                                                } else {
                                                    obj.flyupLeft.hide();
                                                    obj.flyupRight.hide();
                                                }
                                             },
            func(val) {
                                                 if (val.RadarStandby) {
                                                     obj.stby.setText("NO RAD");
                                                     obj.stby.setTranslation(obj.sx/2,obj.sy-obj.texels_up_into_hud+7+75);
                                                     obj.stby.show();
                                                 } else {
                                                     obj.stby.hide();
                                                 }
                                                 obj.stby.update();
                                             },




        ];



        obj.showmeCCIP = 0;
        obj.NzMax = 1.0;

        return obj;
    },

    paintMark: func (stpt, number, input) {
        if (stpt != nil) {
            me.stptPos = hudmath.HudMath.getDevFromCoord(steerpoints.stpt2coord(stpt), input.HmdH, input.HmdP, input, geo.viewer_position());
            me.stptPos[0] = geo.normdeg180(me.stptPos[0]);
            me.stptPos[0] = (512/center_to_edge_distance_m)*(math.tan(math.clamp(me.stptPos[0],-89,89)*D2R))*eye_to_hmcs_distance_m;#0.2m from eye, 0.025 = 512
            me.stptPos[1] = -(512/center_to_edge_distance_m)*(math.tan(math.clamp(me.stptPos[1],-89,89)*D2R))*eye_to_hmcs_distance_m;#0.2m from eye, 0.025 = 512

            me.clamped = math.sqrt(me.stptPos[0]*me.stptPos[0]+me.stptPos[1]*me.stptPos[1]) > 500;

            if (!me.clamped) {
                me.mark_symbols[number].setTranslation(me.stptPos);
                me.mark_symbols[number].show();
            } else {
                me.mark_symbols[number].hide();
            }
         } else {
             me.mark_symbols[number].hide();
         }
    },

    #######################################################################################################
    #######################################################################################################
    ########                                                                                     ##########
    ########                           Update loop                                               ##########
    ########                                                                                     ##########
    ########                                                                                     ##########
    #######################################################################################################
    #######################################################################################################

    update : func(hdp) {
        if (hdp.HmdSym == 0 or (getprop("sim/current-view/view-number") != 0 and getprop("sim/current-view/view-number") != 9)) {  # view 0 is front seat and 9 backseat
            me.svg.hide();
            setprop("payload/armament/hmd-active", 0);
            return;
        }
        if (me.off and !me.initUpdate) {
            me.svg.hide();
            me.old_hdp = {
                "hmcs_sym": hdp.HmdSym,
                "hud_power": getprop("sim/model/f15/avionics/hmd-power"),
                "hud_daytime": 1,  # not used in the F-15EX
                "red": hdp.Red,
            };
            me.firstOne = 1;
            foreach(var update_item; me.update_items)
            {
                if(me.firstOne) {update_item.update(hdp);me.firstOne = 0;}
                else update_item(hdp);
            }
            setprop("payload/armament/hmd-active", 0);
            return;
        }
        setprop("payload/armament/hmd-active", 1);
        setprop("payload/armament/hmd-horiz-deg", geo.normdeg180(-hdp.HmdH));
        setprop("payload/armament/hmd-vert-deg", hdp.HmdP);

        me.canvasWidth = getprop("sim/startup/xsize");
        me.canvasHeight = getprop("sim/startup/ysize");
        eye_to_hmcs_distance_m = getprop("sim/rendering/camera-group/znear");
        center_to_edge_distance_m = math.tan(me.degToEdge*D2R)*eye_to_hmcs_distance_m;

        me.svg_orig.setTranslation(me.canvasWidth*0.5,me.canvasHeight*0.5);
        me.svg_orig.setCenter(me.canvasWidth*0.5,me.canvasHeight*0.5);

        # degs2edge 10.23  meter2edge 0.02  Convert from old HMCS 3D model to new Canvas on Desktop:
        me.fov = getprop("sim/current-view/field-of-view");
        me.pixelsEye2canvas=me.canvasWidth*0.5/math.tan(0.5*me.fov*D2R);
        me.canvasPixelsToEdge = math.tan(me.degToEdge*D2R)*me.pixelsEye2canvas;
        me.scale = me.canvasPixelsToEdge/512;
#printf("scale %.2f  canvasPixelsToEdge  %d  fov %.2f  screen %d",me.scale,me.canvasPixelsToEdge,me.fov,me.canvasWidth);#scale 0.36  canvasPixelsToEdge  185

        me.svg_new.setScale(me.scale, me.scale);
        #me.svg.setCenter();

        me.svg.setTranslation (-512,-512);

        me.svg.show();

        setprop("sim/rendering/als-filters/use-night-vision", 0);# NVG not allowed while using HMD

        if (getprop("sim/model/f15/avionics/n-reset") == 1) {
            me.NzMax = 1.0;
            setprop("sim/model/f15/avionics/n-reset",0);
        }
#
# short cut the whole thing if the display is turned off
#        if (!hdp.getproper("hud_display or !hdp.getproper("hud_serviceable) {
#            me.svg.setColor(0.3,1,0.3,0);
#            return;
#        }
        # part 1. update data items
        #hdp.roll_rad = -hdp.getproper("roll")*D2R;
        if (me.initUpdate) {
            hdp.window12_txt = "12";
        }

        if (hdp.FrameCount == 2 or me.initUpdate == 1) {
            # calc of pitch_offset (compensates for AC3D model translated and rotated when loaded. Also semi compensates for HUD being at an angle.)
            me.Hz_b =    0.66213+0.010;#0.676226;#0.663711;#0.801701;# HUD position inside ac model after it is loaded, translated (0.08m) and rotated (0.7d).
            me.Hz_t =    0.85796+0.010;#0.86608;#0.841082;#0.976668;
            me.Hx_m =   (-4.7148+0.013-4.53759+0.013)*0.5;#-4.62737;#-4.65453;#-4.6429;# HUD median X pos
            me.Vz   =    hdp.CurrentViewYOffset; # view Z position (.94 meter per default)
            me.Vx   =    hdp.CurrentViewZOffset; # view X position (.94 meter per default)

            me.bore_over_bottom = me.Vz - me.Hz_b;
            me.Hz_height        = me.Hz_t-me.Hz_b;
            me.frac_up_the_hud = me.bore_over_bottom / me.Hz_height;
            me.texels_up_into_hud = me.frac_up_the_hud * me.sy;#sy default is 260
        }

        me.Vy   =    hdp.CurrentViewXOffset;



        me.centerOrigin.setTranslation(512, 512);
        me.custom.update();
        me.centerOrigin.update();
        me.svg.update();





        me.submode = 0;





        me.hydra = 0;

        # part2. update display, first with the update managed items
        var showASC = 0;
        me.ALOW_top = 0;
        me.TA_text = "";
        if (1) {#hdp.FrameCount == 2 or me.initUpdate == 1) {
            hdp.window1_txt = "";
            hdp.window2_txt = "";
            hdp.window3_txt = "";
            hdp.window4_txt = "";
            hdp.window5_txt = "";
            hdp.window6_txt = "";
            hdp.window7_txt = "";
            hdp.window8_txt = "";
            hdp.window9_txt = "";
            hdp.window10_txt = "";
            hdp.window11_txt = "";
            hdp.window12_txt = "";

            me.ASEC262.hide();
            me.ASEC100.hide();
            me.ASEC120.hide();
            me.ASEC65.hide();
            var currASEC = nil;
        }



        me.locatorLineShow = 0;
#        if (hdp.FrameCount == 1 or hdp.FrameCount == 3 or me.initUpdate == 1) {
            me.target_idx = 0;
            me.spike_index = 0;
            me.designated = 0;

        me.target_lock_show = 0;

        me.irL = 0;#IR lock
        me.irS = 0;#IR medium circle
        me.rdL = 0;
        me.irT = 0;#IR triangle aspect indicator
        me.rdT = 0;
        me.irB = 0;#IR search bore
        me.aimMode = SLAVE;
        #printf("%d %d %d %s",hdp.master_arm,pylons.fcs != nil,pylons.fcs.getAmmo(),hdp.weapon_selected);
        if(hdp.ControlsArmamentMasterArmSwitch != 0 and pylons.fcs != nil and pylons.fcs.getAmmo() > 0) {
            hdp.weapon_selected = pylons.fcs.selectedType;
            var aim = pylons.fcs.getSelectedWeapon();

            if (0 and hdp.weapon_selected == "AIM-120D" or hdp.weapon_selected == "AIM-7") {
                if (!pylons.fcs.isLock()) {
                    me.radarLock.setTranslation(0, -me.sy*0.25+262*0.3*0.5);
                    me.rdL = 1;
                }
            } elsif (hdp.weapon_selected == "AIM-9L" or hdp.weapon_selected == "AIM-9M" or hdp.weapon_selected == "AIM-9X" or hdp.weapon_selected == "CATM-9X" or hdp.weapon_selected == "IRIS-T" or hdp.weapon_selected == "AGM-65B" or hdp.weapon_selected == "AGM-65D" or hdp.weapon_selected == "AGM-88E" or hdp.weapon_selected == "AGM-119A") {
                if (aim != nil) {
                    if (!aim.isRadarSlaved()) {
                        me.aimMode = VISUAL;
                    }
                }
                if (aim != nil and aim.isCaged()) {
                    var coords = aim.getSeekerInfo();
                    if (coords != nil) {
                        me.echoPos = hudmath.HudMath.getDevFromHMD(coords[0], coords[1], -hdp.HmdH, hdp.HmdP);
                        me.echoPos[0] = geo.normdeg180(me.echoPos[0]);
                        me.echoPos[0] = (512/center_to_edge_distance_m)*(math.tan(math.clamp(me.echoPos[0],-89,89)*D2R))*eye_to_hmcs_distance_m;#0.2m from eye, 0.025 = 512 (should be 0.1385 from eye instead to be like real F-15EX)
                        me.echoPos[1] = -(512/center_to_edge_distance_m)*(math.tan(math.clamp(me.echoPos[1],-89,89)*D2R))*eye_to_hmcs_distance_m;#0.2m from eye, 0.025 = 512

                        me.clamped = math.sqrt(me.echoPos[0]*me.echoPos[0]+me.echoPos[1]*me.echoPos[1]) > 500;

                        if (me.clamped) {
                            me.clampAmount = 500/math.sqrt(me.echoPos[0]*me.echoPos[0]+me.echoPos[1]*me.echoPos[1]);
                            me.echoPos[0] *= me.clampAmount;
                            me.echoPos[1] *= me.clampAmount;
                            me.irBore.setStrokeDashArray([7,7]);
                        } else {
                            me.irBore.setStrokeDashArray([100]);
                        }
                        me.irBore.setTranslation(me.echoPos);
                        me.irB = 1;
                    }#atan((0.025*500)/(0.2*512)) = radius_fg = atan(12.5/102.4) = 6.96 degs => 13.92 deg diam
                    #atan((0.025*500)/(x*512)) => 12.5/tan(10)*512 = x
                } elsif (aim != nil) {
                    var coords = aim.getSeekerInfo();
                    if (coords != nil) {
                        me.echoPos = hudmath.HudMath.getDevFromHMD(coords[0], coords[1], -hdp.HmdH, hdp.HmdP);
                        me.echoPos[0] = geo.normdeg180(me.echoPos[0]);
                        me.echoPos[0] = (512/center_to_edge_distance_m)*(math.tan(math.clamp(me.echoPos[0],-89,89)*D2R))*eye_to_hmcs_distance_m;#0.2m from eye, 0.025 = 512
                        me.echoPos[1] = -(512/center_to_edge_distance_m)*(math.tan(math.clamp(me.echoPos[1],-89,89)*D2R))*eye_to_hmcs_distance_m;#0.2m from eye, 0.025 = 512

                        me.clamped = math.sqrt(me.echoPos[0]*me.echoPos[0]+me.echoPos[1]*me.echoPos[1]) > 500;

                        if (me.clamped) {
                            me.clampAmount = 500/math.sqrt(me.echoPos[0]*me.echoPos[0]+me.echoPos[1]*me.echoPos[1]);
                            me.echoPos[0] *= me.clampAmount;
                            me.echoPos[1] *= me.clampAmount;
                            me.irLock.setStrokeDashArray([7,7]);
                        } else {
                            me.irLock.setStrokeDashArray([100]);
                        }

                        me.irLock.setTranslation(me.echoPos);
                        me.irL = 1;
                    }
                }
            }
        }
        me.designatedDistanceFT = nil;
        me.groundDistanceFT = nil;
        me.u = awg_9.getPriorityTarget();
        if (me.u != nil) {
            me.callsign = "XX";
            me.callsign = me.u.get_Callsign();
            me.model = "XX";

            if (me.u.getModel() != "")
              me.model = me.u.getModel();
            me.lastCoord = me.u.getCoord();
            if ((me.target_idx < me.max_symbols or me.designatedDistanceFT == nil) and me.lastCoord != nil and me.lastCoord.is_defined()) {
                me.echoPos = hudmath.HudMath.getDevFromCoord(me.lastCoord, hdp.HmdH, hdp.HmdP, hdp, geo.viewer_position());
                #print(me.echoPos[0],",",me.echoPos[1],"    ", hdp.HmdH, "," ,hdp.HmdP);
                me.echoPos[0] = geo.normdeg180(me.echoPos[0]);
                #print("    ",me.echoPos[0]);
                me.echoPos[0] = (512/center_to_edge_distance_m)*(math.tan(math.clamp(me.echoPos[0],-89,89)*D2R))*eye_to_hmcs_distance_m;#0.2m from eye, 0.025 = 512
                me.echoPos[1] = -(512/center_to_edge_distance_m)*(math.tan(math.clamp(me.echoPos[1],-89,89)*D2R))*eye_to_hmcs_distance_m;#0.2m from eye, 0.025 = 512

                if (me.target_idx < me.max_symbols) {
                    me.tgt = me.tgt_symbols[me.target_idx];
                } else {
                    me.tgt = nil;
                }
                if (me.tgt != nil or me.designatedDistanceFT == nil) {
                    if (me.tgt != nil) {
                        me.tgt.setVisible(1);
                    }
                    me.clamped = math.sqrt(me.echoPos[0]*me.echoPos[0]+me.echoPos[1]*me.echoPos[1]) > 500;

                    if (me.clamped) {
                        me.clampAmount = 500/math.sqrt(me.echoPos[0]*me.echoPos[0]+me.echoPos[1]*me.echoPos[1]);
                        me.echoPos[0] *= me.clampAmount;
                        me.echoPos[1] *= me.clampAmount;
                        me.tgt.setStrokeDashArray([7,7]);
                    } else {
                        me.tgt.setStrokeDashArray([100]);
                    }

                    if (awg_9.getPriorityTarget() != nil and awg_9.getPriorityTarget().get_Callsign() != nil and me.u.get_Callsign() == awg_9.getPriorityTarget().get_Callsign()) {
                        me.designatedDistanceFT = awg_9.getPriorityTarget().get_range()*6076.11549;  # 6,076.11549 is the NM 2 FT coefficient
                        me.target_lock_show = 1;
                        if (me.tgt != nil) {
                            me.tgt.hide();
                        }

                        me.target_locked.setTranslation (me.echoPos);
                        if (me.clamped) {
                            me.target_locked.setStrokeDashArray([7,7]);
                        } else {
                            me.target_locked.setStrokeDashArray([100]);
                        }
                        me.target_locked.update();
                        if (0 and currASEC != nil) {
                            # disabled for now as it has issues
                            me.cue = nil;
                            call(func {me.cue = hdp.weapn.getIdealFireSolution();},[], nil, nil, var err = []);
                            if (me.cue != nil) {
                                me.ascpixel = me.cue[1]*hmd.HudMath.getPixelPerDegreeAvg(2);
                                me.ascPos = hmd.HudMath.getPosFromDegs(me.echoPos[2], me.echoPos[3]);
                                me.ascDist = math.sqrt(math.pow(me.ascPos[0]+math.cos(me.cue[0]*D2R)*me.ascpixel,2)+math.pow(me.ascPos[1]+math.sin(me.cue[0]*D2R)*me.ascpixel,2));
                                me.ascReduce = me.ascDist > me.sx*0.20?me.sx*0.20/me.ascDist:1;
                                me.ASC.setTranslation(currASEC[0]+me.ascReduce*(me.ascPos[0]+math.cos(me.cue[0]*D2R)*me.ascpixel),currASEC[1]+me.ascReduce*(me.ascPos[1]+math.sin(me.cue[0]*D2R)*me.ascpixel));
                                showASC = 1;
                            }
                        }
                        if (0 and pylons.fcs != nil and pylons.fcs.isLock()) {
                            #me.target_locked.setRotation(45*D2R);
                            if (hdp.weapon_selected == "AIM-120D" or hdp.weapon_selected == "AIM-7" or hdp.weapon_selected == "AIM-9L" or hdp.weapon_selected == "AIM-9M" or hdp.weapon_selected == "AIM-9X" or hdp.weapon_selected == "CATM-9X" or hdp.weapon_selected == "IRIS-T" or hdp.weapon_selected == "AGM-65B" or hdp.weapon_selected == "AGM-65D" or hdp.weapon_selected == "AGM-88E" or hdp.weapon_selected == "AGM-119A") {
                                var aim = pylons.fcs.getSelectedWeapon();
                                if (aim != nil) {
                                    var coords = aim.getSeekerInfo();
                                    if (coords != nil) {
                                        me.seekPos = hmd.HudMath.getCenterPosFromDegs(coords[0],coords[1]);

                                        me.clamped = math.sqrt(me.seekPos[0]*me.seekPos[0]+me.seekPos[1]*me.seekPos[1]) > 500;

                                        if (me.clamped) {
                                            me.clampAmount = 500/math.sqrt(me.seekPos[0]*me.seekPos[0]+me.seekPos[1]*me.seekPos[1]);
                                            me.seekPos[0] *= me.clampAmount;
                                            me.seekPos[1] *= me.clampAmount;
                                            me.irLock.setStrokeDashArray([7,7]);
                                        } else {
                                            me.irLock.setStrokeDashArray([100]);
                                        }

                                        me.irLock.setTranslation(me.seekPos);
                                        me.radarLock.setTranslation(me.seekPos);
                                    }
                                }
                            }
                            if (hdp.weapon_selected == "AIM-120D" or hdp.weapon_selected == "AIM-7") {
                                #me.radarLock.setTranslation(me.xcS, me.ycS); too perfect
                                me.ASEC120Aspect.setRotation(D2R*(awg_9.getPriorityTarget().get_heading()-hdp.OrientationHeadingDeg+180));
                                me.rdL = 1;
                                me.rdT = 1;
                            } elsif (hdp.weapon_selected == "AIM-9L" or hdp.weapon_selected == "AIM-9M" or hdp.weapon_selected == "AIM-9X" or hdp.weapon_selected == "CATM-9X" or hdp.weapon_selected == "IRIS-T") {
                                #me.irLock.setTranslation(me.xcS, me.ycS);
                                me.ASEC65Aspect.setRotation(D2R*(awg_9.getPriorityTarget().get_heading()-hdp.OrientationHeadingDeg+180));
                                me.irL = 1;
                                me.irT = 1;
                            }
                        } else {
                            #me.target_locked.setRotation(0);
                        }
                        if (me.clamped) {
                            me.locatorLineShow = 0;
                        }
                    } else {
                        # TODO - Disabled for now
                        # if in symbol reject mode then only show the active target.
                        #if (hdp.getproper("symbol_reject") and me.tgt != nil) {
                        #  me.tgt.setVisible(0);
                        #}
                    }
                    if (me.tgt != nil) {
                        me.tgt.setTranslation (me.echoPos);
                        me.tgt.update();
                    }
                    if (ht_debug)
                      printf("%-10s %f,%f [%f,%f,%f] :: %f,%f",me.callsign,me.xc,me.yc, me.devs[0], me.devs[1], me.devs[2], me.u_dev_rad*D2R, me.u_elev_rad*D2R);
                } else {
                    print("[ERROR]: HUD too many targets ",me.target_idx);
                }
                me.target_idx += 1;
            }

            for (me.nv = me.target_idx; me.nv < me.max_symbols;me.nv += 1) {
                me.tgt = me.tgt_symbols[me.nv];
                if (me.tgt != nil) {
                    me.tgt.setVisible(0);
                }
            }
        }

        me.designatedDistanceFT = nil;
        me.groundDistanceFT = nil;

        me.missile_launcher = getprop("payload/armament/MLW-launcher");
        if (me.missile_launcher != "" and me.missile_launcher != nil) {
            me.u = me.missile_launcher;
            if (me.u != nil) {
                me.callsign = me.u;

                foreach(c ; Mp.getChildren()) {
                    type = c.getName();

                    if (c.getNode("valid") == nil or !c.getNode("valid").getValue()) {
                        continue;
                    }
                    if (type == "multiplayer" or type == "tanker" or type == "aircraft" or type == "carrier" or type == "ship" or type == "groundvehicle") {
                        print(c.getNode("callsign").getValue());
                        if (c.getNode("callsign").getValue() == me.callsign) {
                            me.lat = c.getNode("position/latitude-deg").getValue();
                            me.lon = c.getNode("position/longitude-deg").getValue();
                            me.alt = c.getNode("position/altitude-ft").getValue();
                            me.lastCoord = geo.Coord.new().set_latlon(me.lat,me.lon,me.alt*FT2M);
                        }
                    }
                }
                if ((me.spike_index < me.max_symbols or me.designatedDistanceFT == nil) and me.lastCoord != nil and me.lastCoord.is_defined()) {
                    me.echoPos = hudmath.HudMath.getDevFromCoord(me.lastCoord, hdp.HmdH, hdp.HmdP, hdp, geo.viewer_position());
                    #print(me.echoPos[0],",",me.echoPos[1],"    ", hdp.HmdH, "," ,hdp.HmdP);
                    me.echoPos[0] = geo.normdeg180(me.echoPos[0]);
                    #print("    ",me.echoPos[0]);
                    me.echoPos[0] = (512/center_to_edge_distance_m)*(math.tan(math.clamp(me.echoPos[0],-89,89)*D2R))*eye_to_hmcs_distance_m;#0.2m from eye, 0.025 = 512
                    me.echoPos[1] = -(512/center_to_edge_distance_m)*(math.tan(math.clamp(me.echoPos[1],-89,89)*D2R))*eye_to_hmcs_distance_m;#0.2m from eye, 0.025 = 512

                    if (me.spike_index < me.max_symbols) {
                        me.spike = me.spike_symbols[me.spike_index];
                    } else {
                        me.spike = nil;
                    }
                    if (me.spike != nil or me.designatedDistanceFT == nil) {
                        if (me.spike != nil) {
                            me.spike.setVisible(1);
                        }
                        me.clamped = math.sqrt(me.echoPos[0]*me.echoPos[0]+me.echoPos[1]*me.echoPos[1]) > 500;

                        if (me.clamped) {
                            me.clampAmount = 500/math.sqrt(me.echoPos[0]*me.echoPos[0]+me.echoPos[1]*me.echoPos[1]);
                            me.echoPos[0] *= me.clampAmount;
                            me.echoPos[1] *= me.clampAmount;
                            me.spike.setStrokeDashArray([7,7]);
                        } else {
                            me.spike.setStrokeDashArray([100]);
                        }
                        if (me.spike != nil) {
                            me.spike.setTranslation (me.echoPos);
                            me.spike.update();
                        }
                        if (ht_debug)
                          #printf("%-10s %f,%f [%f,%f,%f] :: %f,%f",me.callsign,me.xc,me.yc, me.devs[0], me.devs[1], me.devs[2], me.u_dev_rad*D2R, me.u_elev_rad*D2R);
                    } else {
                        print("[ERROR]: HUD too many spikes ",me.spike_index);
                    }
                    me.spike_index += 1;
                }

                for (me.nv = me.spike_index; me.nv < me.max_symbols;me.nv += 1) {
                    me.spike = me.spike_symbols[me.nv];
                    if (me.spike != nil) {
                        me.spike.setVisible(0);
                    }
                }
            }
        }

        me.ASC.setVisible(showASC);

        #print(me.irS~" "~me.irL);

        me.locatorLine.setVisible(me.locatorLineShow);
        me.locatorAngle.setVisible(me.locatorLineShow);
        me.target_locked.setVisible(me.target_lock_show);

        # TODO - IMPLEMENT THAT, DISABLED FOR NOW
        if (!me.target_lock_show and !hdp.RadarStandby and 1 == 0) { #  radar_system.apg68Radar.currentMode.longName == radar_system.acmBoreMode.longName
            me.echoPos = hudmath.HudMath.getDevFromHMD(radar_system.apg68Radar.eulerX, radar_system.apg68Radar.eulerY, -hdp.HmdH, hdp.HmdP);
            me.echoPos[0] = (512/center_to_edge_distance_m)*(math.tan(math.clamp(me.echoPos[0],-89,89)*D2R))*eye_to_hmcs_distance_m;#0.2m from eye, 0.025 = 512
            me.echoPos[1] = -(512/center_to_edge_distance_m)*(math.tan(math.clamp(me.echoPos[1],-89,89)*D2R))*eye_to_hmcs_distance_m;
            me.clamped = math.sqrt(me.echoPos[0]*me.echoPos[0]+me.echoPos[1]*me.echoPos[1]) > 500;
            if (!me.clamped) {
                me.rdrBore.setTranslation(me.echoPos);
                me.rdrBore.show();
            } else {
                me.rdrBore.hide();
            }
        } else {
            me.rdrBore.hide();
        }

        var showtgpTD = 0;
        var showtgpTDcross = 0;
        if (tgp.flir_updater.click_coord_cam != nil and getprop("sim/model/f15/avionics/tgp-lock") and getprop("sim/model/f15/stores/tgp-mounted")) {
            if (getprop("sim/view[105]/heading-offset-deg")==0 and getprop("sim/view[105]/pitch-offset-deg")==-30 and armament.contactPoint != nil) {
                # Programmed GPS target
                me.echoPos = hudmath.HudMath.getDevFromCoord(armament.contactPoint.get_Coord(), hdp.HmdH, hdp.HmdP, hdp, geo.viewer_position());
                #print(me.echoPos[0],",",me.echoPos[1],"    ", hdp.hmdH, "," ,hdp.hmdP);
                me.echoPos[0] = geo.normdeg180(me.echoPos[0]);
                #print("    ",me.echoPos[0]);
                me.echoPos[0] = (512/center_to_edge_distance_m)*(math.tan(math.clamp(me.echoPos[0],-89,89)*D2R))*eye_to_hmcs_distance_m;#0.2m from eye, 0.025 = 512
                me.echoPos[1] = -(512/center_to_edge_distance_m)*(math.tan(math.clamp(me.echoPos[1],-89,89)*D2R))*eye_to_hmcs_distance_m;#0.2m from eye, 0.025 = 512

                me.clamped = math.sqrt(me.echoPos[0]*me.echoPos[0]+me.echoPos[1]*me.echoPos[1]) > 500;

                if (me.clamped) {
                    me.clampAmount = 500/math.sqrt(me.echoPos[0]*me.echoPos[0]+me.echoPos[1]*me.echoPos[1]);
                    me.echoPos[0] *= me.clampAmount;
                    me.echoPos[1] *= me.clampAmount;
                    showtgpTDcross = 1;
                    me.tgpPointC.setTranslation(me.echoPos);
                }

                #printf("TGP idle: %.2f,%.2f",me.echoPos[0],me.echoPos[1]);
                me.tgpPointF.setTranslation(me.echoPos);
                showtgpTD = 1;
            } else {
                # TGP target
                var b = geo.normdeg180(getprop("sim/view[105]/heading-offset-deg"));
                var p = getprop("sim/view[105]/pitch-offset-deg");
                #printf("From TGP stat: %.2f,%.2f",b,p);
                #printf("From HMD stat: %.2f,%.2f",hdp.HmdH, hdp.HmdP);
                me.echoPos = hudmath.HudMath.getDevFromHMD(b, p, -hdp.HmdH, hdp.HmdP);
                me.echoPos[0] = geo.normdeg180(me.echoPos[0]);
                #printf(" Math:    (%.2f,%.2f) degs",me.echoPos[0],me.echoPos[1]);

                #var behind = 0;
                #if(0 and b < -90) {
                #    b = -180-b;
                #    p = -p;
                #    behind = 1;
                #} elsif (0 and b > 90) {
                #    b = 180-b;
                #    p = -p;
                #    behind = 1;
                #}#printf(" Behind:%d   (%.2f,%.2f)",behind,b,p);
                me.echoPos[0] = (512/center_to_edge_distance_m)*(math.tan(math.clamp(me.echoPos[0],-89,89)*D2R))*eye_to_hmcs_distance_m;#0.2m from eye, 0.025 = 512 (should be 0.1385 from eye instead to be like real F-15EX)
                me.echoPos[1] = -(512/center_to_edge_distance_m)*(math.tan(math.clamp(me.echoPos[1],-89,89)*D2R))*eye_to_hmcs_distance_m;#0.2m from eye, 0.025 = 512
                me.clamped = math.sqrt(me.echoPos[0]*me.echoPos[0]+me.echoPos[1]*me.echoPos[1]) > 500;

                if (me.clamped) {
                    me.clampAmount = 500/math.sqrt(me.echoPos[0]*me.echoPos[0]+me.echoPos[1]*me.echoPos[1]);
                    me.echoPos[0] *= me.clampAmount;
                    me.echoPos[1] *= me.clampAmount;
                    me.tgpPointC.setTranslation(me.echoPos);
                    showtgpTDcross = 1;
                }
                me.tgpPointF.setTranslation(me.echoPos);
                showtgpTD = 1;
            }
        }
        me.tgpPointF.setVisible(showtgpTD);
        me.tgpPointC.setVisible(showtgpTDcross);

        me.dlzArray = pylons.getDLZ();
        #me.dlzArray =[10,8,6,2,9];#test
        if (me.dlzArray == nil or size(me.dlzArray) == 0) {
                me.dlz.hide();
        } else {
            #printf("%d %d %d %d %d",me.dlzArray[0],me.dlzArray[1],me.dlzArray[2],me.dlzArray[3],me.dlzArray[4]);
            me.dlz2.removeAllChildren();
            me.dlzArrow.setTranslation(0,-me.dlzArray[4]/me.dlzArray[0]*me.dlzHeight);
            if (awg_9.getPriorityTarget() != nil) {
                me.dlzClo.setTranslation(0,-me.dlzArray[4]/me.dlzArray[0]*me.dlzHeight);
                me.lcr = awg_9.getPriorityTarget().get_closure_rate();
                me.dlzClo.setText(me.lcr!=0?sprintf("%+d ",me.lcr):"XXX");
                if (pylons.fcs.isLock() and me.dlzArray[4] < me.dlzArray[2] and math.mod(int(4*(getprop("sim/time/elapsed-sec")-int(getprop("sim/time/elapsed-sec")))),2)>0) {
                    me.irL = 0;
                    me.rdL = 0;
                }
                if (pylons.fcs.isLock()) {
                    me.scale120 = me.extrapolate(me.dlzArray[4],me.dlzArray[2],me.dlzArray[3],1,30/120);
                    me.scale120 = me.clamp(me.scale120,30/120,1);
                    me.ASEC120.setScale(me.scale120,me.scale120);#todo error
                    me.ASEC120.setStrokeLineWidth(1/me.scale120);
                    #me.ASEC120Aspect.setScale(me.scale120,me.scale120);
                    #me.ASEC120Aspect.setStrokeLineWidth(1/me.scale120);
                    me.ASEC120Aspect.setTranslation(me.sx*0.5,me.sy*0.25-me.scale120*0.4*120);#0.4=mr
                    #me.ASEC120Aspect.setCenter(0,me.scale120*0.4*120);
                    me.ASEC120Aspect.setCenter(0,me.scale120*0.4*120);
                }
            } else {
                me.dlzClo.setText("");
            }
            me.dlzGeom = me.dlz2.createChild("path")
                    .moveTo(me.dlzWidth, 0)
                    .horiz(-me.dlzWidth)
                    .lineTo(0, -me.dlzArray[3]/me.dlzArray[0]*me.dlzHeight)
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
                    .setColor(me.color);
            me.dlz2.update();
            me.dlz.show();
        }

        me.radarLock.setVisible(0 and me.rdL);
        me.irSearch.setVisible(me.irS);
        me.irLock.setVisible(me.irL);
        me.irBore.setVisible(me.irB);
        me.ASEC120Aspect.setVisible(0 and me.rdT);
        me.ASEC65Aspect.setVisible(0 and me.irT);
        me.radarLock.update();
        me.irLock.update();
        me.irSearch.update();






        me.initUpdate = 0;

        hdp.submode = me.submode;

        wpn_selector = getprop("sim/model/f15/controls/armament/weapon-selector");
        wpn_mode = "M61A1";
        ammo_count = hdp.ArmamentRounds;
        ammo_string = 0;

        if (pylons.fcs.getSelectedWeapon() != nil and pylons.fcs.getSelectedWeapon().type == "LAU-68C") {
            wpn_mode = "M151";
            ammo_count = pylons.fcs.getAmmo();
        }

        if (wpn_selector == 1) {
            wpn_mode = "SRM";
            ammo_count = hdp.ArmamentAim9Count;
        } elsif (wpn_selector == 2) {
            wpn_mode = "AAM";
            ammo_count = hdp.ArmamentAim120Count;
        } elsif (wpn_selector == 5) {
            wpn_mode = "GND";
            if (getprop("sim/model/f15/systems/armament/selected-arm") != nil and getprop("sim/model/f15/systems/armament/selected-arm") != "") {  # additonaly display the current ground weapon's count along the total ground ordinance count
                ammo_count = sprintf("%2d/%2d", pylons.fcs.getAmmoOfType(getprop("sim/model/f15/systems/armament/selected-arm")), hdp.ArmamentAgmCount);
                ammo_string = 1;
            } else {
                ammo_count = hdp.ArmamentAgmCount;
            }
        }

        if (hdp.AutopilotRouteManagerActive) {
            if (hdp.AutopilotRouteManagerWpDist != nil) {
                hdp.window5_txt = sprintf(sprintf("N %4.1f", hdp.AutopilotRouteManagerWpDist));
            } else {
                hdp.window5_txt = "N XXX";
            }

            if (hdp.AutopilotRouteManagerWpEtaSeconds != nil) {
                nav_mins = sprintf("%.0f", hdp.AutopilotRouteManagerWpEtaSeconds / 60);
                nav_secs = (hdp.AutopilotRouteManagerWpEtaSeconds / 60 - nav_mins) * 60;  # remove whole minutes for seconds
                if (nav_secs < 0) {  # tiny fix
                    nav_mins = nav_mins - 1;
                    nav_secs = 60 + nav_secs;
                }
                hdp.window3_txt = sprintf("%02d:%02d", nav_mins, nav_secs);
            } else {
                hdp.window3_txt = "XX MIN";
            }
        } else {
            hdp.window5_txt = "";
            hdp.window3_txt = "";
        }

        hdp.window9_txt = wpn_mode;
        hdp.window2_txt = sprintf("%1.2f T/W", hdp.ThrustToWeightRatio);
        if (ammo_string == 0) {
            hdp.window11_txt = sprintf("%02d", ammo_count);
        } else {
            hdp.window11_txt = sprintf("%s", ammo_count);
        }
        hdp.window12_txt = sprintf("%02d %02d G", math.round(hdp.InstrumentedG*10.0), math.round(hdp.CadcOwsMaximumG*10.0));

        me.old_hdp = {
            "hmcs_sym" : hdp.HmdSym,
            "hud_power" : hdp.HmdPower,
            "hud_daytime" : 1,
            "red" : hdp.Red,
        };
        me.firstOne = 1;
        foreach(var update_item; me.update_items)
        {
            if(me.firstOne) {update_item.update(hdp);me.firstOne = 0;}
            else update_item(hdp);
        }
          if (hdp.window5_txt != nil and hdp.window5_txt != ""){
              me.window5.show();
              me.window5.setText(hdp.window5_txt);
          }
          else
            me.window5.hide();

          if (hdp.window3_txt != nil and hdp.window3_txt != ""){
              me.window3.show();
              me.window3.setText(hdp.window3_txt);
          }
          else
            me.window3.hide();

          if (hdp.window2_txt != nil and hdp.window2_txt != ""){
              me.window2.show();
              me.window2.setText(hdp.window2_txt);
          }
          else
            me.window2.hide();

          if (hdp.window9_txt != nil and hdp.window9_txt != ""){
              me.window9.show();
              me.window9.setText(hdp.window9_txt);
          }
          else
            me.window9.hide();

          if (hdp.window11_txt != nil and hdp.window11_txt != ""){
              me.window11.show();
              me.window11.setText(hdp.window11_txt);
          }
          else
            me.window11.hide();

          if (hdp.window12_txt != nil and hdp.window12_txt != ""){
              me.window12.show();
              me.window12.setText(hdp.window12_txt);
          }
          else
            me.window12.hide();
        return;
        me.window1.setText("window  1").show();
        me.window2.setText("window  2").show();
        me.window3.setText("window  3").show();
        me.window4.setText("window  4").show();
        me.window5.setText("window  5").show();
        me.window6.setText("window  6").show();
        me.window7.setText("window  7").show();
        me.window8.setText("window  8").show();
        me.window9.setText("window  9").show();
        me.window10.setText("window 10").show();
        me.window11.setText("window 11").show();
        me.window12.setText("window 12").show();#
    },

#  12
#
#     FG
#
#
#  2      10
#  7       3
#  8       4
#  9       5
# 11       6

#  5
#
#    REAL
#
#
#   30    32
#    3    37
#    4      26
#   7       25
#  8        10
# 15        13
# 35        14
# 36

#Text windows on the HUD (FG F-16 May 11 2021)
# 12 currG           1 not used
#                   10 ALOW
# 2 mode             3 slant            / callsign
# 7 mach             4 eta              / target angels
# 8 maxG             5 waypoint
# 9 weap             6 not used
# 11 fuel

#Text windows on the HUD (FG F-16 rework)
# 12 currG           1 ALOW-top
#
#                   10 ALOW             / target angels
# 2 mode             3 slant
# 7 mach             4 eta              / time to go      TODO: CCRP: time to release / closure rate in kt: A/A guns
# 8 maxG             5 waypoint
# 9 weap             6 callsign
# 11 fuel
#
# TA replace ALOW in A-A ALOW:top
# slant is F for radar computed, B for steerpoint, R for CARA, X XXX elsewise, empty for no target




    makeVector: func (siz,content) {
        var vec = setsize([],siz*2);
        var k = 0;
        while(k<siz*2) {
            vec[k] = content;
            k += 1;
        }
        return vec;
    },


    getAltTxt: func (alt) {
        if (alt < 1000) {
            me.txtRAlt = sprintf("%03d",math.round(alt,10));
        } else {
            # CARA is never more than 5 digits, and aircraft is not supposed to fly above 100k ft
            me.txtRAlt = sprintf("%d",math.round(alt,10));
        }
        if (alt < 0) {
            if (alt>-1000) {
                me.txtRAlt = sprintf(" -,%s", right(me.txtRAlt,3));
            } else {
                me.txtRAlt = sprintf("%s,%s", left(me.txtRAlt,size(me.txtRAlt)-3),right(me.txtRAlt,3));
            }
            # no reason to cope for alts lower than -9999ft
        } elsif (alt<1000) {
            me.txtRAlt = sprintf("  ,%s", right(me.txtRAlt,3));
        } else {
            me.txtRAlt = sprintf("%s%s,%s", size(me.txtRAlt)==4?" ":"",left(me.txtRAlt,size(me.txtRAlt)-3),right(me.txtRAlt,3));
        }
        return me.txtRAlt; # always return 6 char string
    },

    develev_to_devroll : func(notification, dev_rad, elev_rad)
    {
        var eye_hud_m          = me.Vx-me.Hx_m;
        var hud_position       = 4.65453;#4.6429;#4.61428;#4.65415;#5.66824; # really -5.6 but avoiding more complex equations by being optimal with the signs.
        var hud_radius_m       = 0.08429;
        var clamped = 0;

        eye_hud_m = hud_position + notification.current_view_z_offset_m; # optimised for signs so we get a positive distance.
# Deviation length on the HUD (at level flight),
        var h_dev = eye_hud_m / ( math.sin(dev_rad) / math.cos(dev_rad) );
        var v_dev = eye_hud_m / ( math.sin(elev_rad) / math.cos(elev_rad) );
# Angle between HUD center/top <-> HUD center/symbol position.
        # -90° left, 0° up, 90° right, +/- 180° down.
        var dev_deg =  math.atan2( h_dev, v_dev ) * R2D;
# Correction with own a/c roll.
        var combined_dev_deg = dev_deg - notification.roll;
# Lenght HUD center <-> symbol pos on the HUD:
        var combined_dev_length = math.sqrt((h_dev*h_dev)+(v_dev*v_dev));

# clamping
        var abs_combined_dev_deg = math.abs( combined_dev_deg );
        var clmp = hud_radius_m;

# squeeze the top of the display area for egg shaped HUD limits.
#   if ( abs_combined_dev_deg >= 0 and abs_combined_dev_deg < 90 ) {
#       var coef = ( 90 - abs_combined_dev_deg ) * 0.00075;
#       if ( coef > 0.050 ) { coef = 0.050 }
#       clamp -= coef;
        #   }
        if ( combined_dev_length > clmp ) {
            #combined_dev_length = clamp;
            clamped = 1;
        }
        var v = [combined_dev_deg, combined_dev_length, clamped];
        return(v);
    },
#



    extrapolate: func (x, x1, x2, y1, y2) {
        return y1 + ((x - x1) / (x2 - x1)) * (y2 - y1);
    },
    clamp: func(v, min, max) { v < min ? min : v > max ? max : v },
    list: [],
};

var F15HMDRecipient =
{
    new: func(_ident)
    {
        var new_class = emesary.Recipient.new(_ident~".HMD");
        new_class.HUDobj = F15_HMD.new("canvasHMCS", 1024,1024, 0,0);

        new_class.Receive = func(notification)
        {
            if (notification == nil)
            {
                print("bad notification nil");
                return emesary.Transmitter.ReceiptStatus_NotProcessed;
            }

            notification.range_rate = "RNGRATE";

            if (notification.NotificationType == "FrameNotification16")
            {

                me.HUDobj.update(notification);
                return emesary.Transmitter.ReceiptStatus_OK;
            }
            return emesary.Transmitter.ReceiptStatus_NotProcessed;
        };
        return new_class;
    },
    del: func()
    {
        HUDobj.canvas.del();
        emesary.GlobalTransmitter.DeRegister(f15_hmd);
    },
};

var f15_hmd = nil;
var HUDobj = nil;

var main = func (module) {
    var t = maketimer(1,main2);
    t.singleShot = 1;
    t.start();
}

var main2 = func () {
    f15_hmd = F15HMDRecipient.new("F15-HMD");
    HUDobj = f15_hmd.HUDobj;
    emesary.GlobalTransmitter.Register(f15_hmd);
}

var unload = func {
    if (f15_hmd != nil) {
        F15HMDRecipient.del();
        f15_hmd = nil;
        HUDobj = nil;
    }
}

var drag = func (Mach, _cd) {
    if (Mach < 0.7)
        return 0.0125 * Mach + _cd;
    elsif (Mach < 1.2)
        return 0.3742 * math.pow(Mach, 2) - 0.252 * Mach + 0.0021 + _cd;
    else
        return 0.2965 * math.pow(Mach, -1.1506) + _cd;
};

var isDropping = 0;
var dropTimer = nil;

var dropping = func {
    if (getprop("payload/armament/gravity-dropping")) {
        isDropping = 1;
    } else {
        dropTimer = maketimer(1.0, func {isDropping = 0;});
        dropTimer.singleShot = 1;
        dropTimer.start();
    }
}

# Heading scale
#
# Adapted from JA37 (Colin Genier)
var Heading = {
    Marker: {
        new: func(parent) {
            var m = { parents: [Heading.Marker], parent: parent, };
            m.initialize();
            return m;
        },

        initialize: func {
            me.group = me.parent.createChild("group");
            me.mark = make_path(me.group).vert(-25);
            me.text = make_text(me.group)
                .setAlignment("center-bottom")
                .setTranslation(0, 39);
            me.text.enableUpdate();
            me.long = 1;
        },

        set_pos: func(pos) { me.group.setTranslation(pos, 0); },

        update: func(hdg, long) {
            # Marker length
            if (long and !me.long) {
                me.long = 1;
                me.mark.setScale(1, 0.6);
                me.text.show();
            } elsif (!long and me.long) {
                me.long = 0;
                me.mark.setScale(1, 0.6);
                me.text.hide();
            }
            if (me.long and hdg != nil) {
                me.text.updateText(sprintf("%d", hdg));
            } else {
                me.text.updateText("");
            }
        },
    },

    new: func(parent) {
        var m = { parents: [Heading], parent: parent, mode: -1, };
        m.initialize();
        return m;
    },

    initialize: func {
        me.group = me.parent.createChild("group")
            .setTranslation(0, 100);

        # Fixed track index
        #make_path(me.group).moveTo(0,0).lineTo(-25,50).moveTo(0,0).lineTo(25,50);

        # Commanded track index
        #me.index = make_path(me.group)
        #    .moveTo(0,50).vert(75)
        #    .moveTo(-25,75).vert(50)
        #    .moveTo(25,75).vert(50);

        me.marker_grp = me.group.createChild("group");

        me.markers = [];
        setsize(me.markers, 7);
        forindex (var i; me.markers) {
            me.markers[i] = Heading.Marker.new(me.marker_grp);
        }

        me.scale_factor = -1;
        me.set_scale_factor(100/6.7);
    },

    getGroup: func {
        return me.group;
    },

    set_scale_factor: func(factor) {
        if (factor == me.scale_factor) return;
        me.scale_factor = factor;

        forindex (var i; me.markers) {
            me.markers[i].set_pos(me.scale_factor * (i-3) * 5);
        }
    },

    set_dclt: func(dclt) {
        me.mode = dclt;
        if (me.mode == 1) {
            me.group.hide();
        } elsif (me.mode == 0) {
            me.group.setTranslation(0, 350);
            me.set_scale_factor(14);
            me.group.show();
            #me.index.hide();
        }
    },

    update: func(fpv_heading) {
        if (me.mode == 1) return;

        # Track angle.
        var track = fpv_heading;

        var center_mark = math.round(track, 5);

        me.marker_grp.setTranslation((center_mark - track) * me.scale_factor, 0);
        # update() required: otherwise show()/hide() applies immediately,
        # while other changes wait for the next frame.
        me.marker_grp.update();

        forindex (var i; me.markers) {
            var hdg = geo.normdeg(center_mark + (i-3) * 5);
            var txt = math.mod(hdg, 10) == 0;
            if (math.abs(hdg - fpv_heading) < 5) hdg = nil;
            elsif (math.abs(geo.normdeg180(hdg - fpv_heading)) < 5) hdg = nil;
            me.markers[i].update(hdg, txt);
        }

        var pos = geo.normdeg180(track);
        pos *= me.scale_factor;
        pos = math.clamp(pos, -200, 200);
        #me.index.setTranslation(pos, 0);
        #me.index.hide();
    },
};

### Canvas elements creators

# Create a new path.
var make_path = func(parent, fill=0) {
    var p = parent.createChild("path");
    # Mask the global "fill" colour, cf. remarks above.
    if (!fill) p.set("fill", "none");
    return p;
}

# Create a new text element with default options.
var make_text = func(parent) {
    return parent.createChild("text")
        # Mask the global "stroke" colour, cf. remarks above.
        .set("stroke", "none")
        .setFont("NotoMono-Regular.ttf");
}

var isMarking = 0;
var markStart = func {
    if (getprop("controls/displays/cursor-click") and 1 == 1 and HUDobj["off"] == 0 and isMarking == 0) {  # stead of 1 should be f15.SOI
        isMarking = 1;
        var t = maketimer(0.55, func markStart());
        t.singleShot = 1;
        #print("markStart 1");
        t.start();
    } elsif (getprop("controls/displays/cursor-click") and 1 == 1 and HUDobj["off"] == 0 and isMarking == 1) {  # stead of 1 should be f15.SOI
        isMarking = 2;
        #print("markStart 2");
        mark();
    } elsif (!getprop("controls/displays/cursor-click") and isMarking > 0) {
        isMarking = 0;
        #print("markStart 0");
    } else {
        #print("markStart click ",getprop("controls/displays/cursor-click")," soi ",1 == 1," HMD ",HUDobj["off"] == 0," marking ",isMarking);  # stead of 1 should be f15.SOI
    }
};

var mark = func {
    if (getprop("controls/displays/cursor-click") and 1 == 1 and HUDobj["off"] == 0) {  # stead of 1 should be f15.SOI
        # Mark
        var coordA = geo.viewer_position();
        coordA.alt();# TODO: once fixed in FG this line is no longer needed.

        # get quaternion for view rotation:
        var q = [getprop("sim/current-view/debug/orientation-w"),getprop("sim/current-view/debug/orientation-x"),getprop("sim/current-view/debug/orientation-y"),getprop("sim/current-view/debug/orientation-z")];

        var V = [2 * (q[1] * q[3] - q[0] * q[2]), 2 * (q[2] * q[3] + q[0] * q[1]),1 - 2 * (q[1] * q[1] + q[2] * q[2])];
        var w= q[0];
        var x= q[1];
        var y= q[2];
        var z= q[3];

        #rotate from x axis using the quaternion:
        V = [1 - 2 * (y*y + z*z),2 * (x*y + w*z),2 * (x*z - w*y)];

        var xyz          = {"x":coordA.x(),                "y":coordA.y(),               "z":coordA.z()};
        #var directionLOS = {"x":dirCoord.x()-coordA.x(),   "y":dirCoord.y()-coordA.y(),  "z":dirCoord.z()-coordA.z()};
        var directionLOS = {"x":V[0],   "y":V[1],  "z":V[2]};

        # Check for terrain between own weapon and target:
        var terrainGeod = get_cart_ground_intersection(xyz, directionLOS);
        if (terrainGeod == nil) {
            #print("0 terrain");
            return;
        } else {
            var terrain = geo.Coord.new();
            terrain.set_latlon(terrainGeod.lat, terrainGeod.lon, terrainGeod.elevation);
            var ut = nil;
            #foreach (u ; radar_system.getCompleteList()) {
            #    if (terrain.direct_distance_to(u.get_Coord())<45) {
            #        ut = u;
            #        break;
            #    }
            #}
            if (ut!=nil) {
                var contact = ut.getNearbyVirtualTGPContact();
                armament.contactPoint = contact;
                #var tc = contact.getCoord();
                #print("contactPoint "~tc.lat()~", "~tc.lon()~" at "~(tc.alt()*M2FT)~" ft");
            } else {
                steerpoints.markHUD(terrain);
                ded.dataEntryDisplay.pageLast = ded.pMARK;# So it does not do a OFLY mark.
                ded.dataEntryDisplay.page     = ded.pMARK;
                #var crater_model = getprop("payload/armament/models") ~ "the-flare.xml";#
                #var static = geo.put_model(crater_model, terrain.lat(),terrain.lon(),terrain.alt(), 0);#
                #print("mark voila");
                #armament.contactPoint = radar_system.ContactTGP.new("TGP-Spot",terrain,1);
            }
        }
    }
};

setlistener("payload/armament/gravity-dropping",func{dropping()},nil,0);
setlistener("controls/displays/cursor-click", markStart);

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
		HeadingTrue                             : "orientation/true-heading-deg",
        HeadingMag                              : "orientation/heading-magnetic-deg",
		TacanStationDistance                    : "instrumentation/tacan/indicated-distance-nm",
		TacanChannel                            : "instrumentation/tacan/display/channel",
		TacanXShift                             : "instrumentation/tacan/display/x-shift",
		TacanYShift                             : "instrumentation/tacan/display/y-shift",
		GunsMode                                : "sim/model/f15/armament/gun-sight",
		GroundAlt                               : "instrumentation/tfs/ground-altitude-ft-now",
		RadarFilterMode                         : "instrumentation/radar/radar-filter-mode",
		IsRefueling                             : "fdm/jsbsim/propulsion/refuel",
		IsDumpingFuel                           : "fdm/jsbsim/propulsion/fuel_dump",
		CurrentFuelLb                           : "sim/model/f15/instrumentation/fuel-gauges/total-display",
		FuelPercentage                          : "consumables/fuel/total-fuel-norm",
		ThrustToWeightRatio                     : "sim/model/f15/avionics/thrust-weight-ratio",
        Red                                     : "rendering/scene/diffuse/red",
        HmdPower                                : "sim/model/f15/avionics/hmd-power",
        HmdSym                                  : "sim/model/f15/avionics/hmd-sym",
        AltitudeAGL                             : "position/altitude-agl-ft",
        HmdH                                    : "sim/current-view/heading-offset-deg",
        HmdP                                    : "sim/current-view/pitch-offset-deg",
        CurrentViewXOffset                      : "sim/current-view/x-offset-m",
        CurrentViewYOffset                      : "sim/current-view/y-offset-m",
        CurrentViewZOffset                      : "sim/current-view/z-offset-m",
};

emexec.ExecModule.register("f15_HMD", input, F15_HMD.new("canvasHMCS", 1024,1024, 0,0), 2);
