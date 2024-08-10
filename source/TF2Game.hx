import openfl.media.SoundChannel;
import motion.Actuate;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.filesystem.File;
import openfl.text.Font;
import openfl.text.TextFormat;
import openfl.Assets;
import openfl.text.TextField;
import sys.FileSystem;
import openfl.media.Sound;
import haxe.Timer;
import haxe.io.Path;
import openfl.globalization.LocaleID;
#if cpp
import hxvlc.openfl.Location;
#end
import openfl.display.Shape;
import openfl.display.Sprite;
#if cpp
import hxvlc.openfl.Video;
#end

class TF2Game extends Sprite {

    var bg:Shape;

    var loaded:Int = 0;
    #if cpp var video:Video; #end
    var introSound:Sound;
    var introChannel:SoundChannel;

    var copyrightText:TextField;
    var poweredBy:Bitmap;

    var loading:Bitmap;

    var c1:Float = 0;

    var onReset:Void->Void;

    public function new() {
        super();

        #if cpp c1 = Timer.stamp();

        bg = new Shape();
		bg.graphics.beginFill(0x000000, 1);
		bg.graphics.drawRect(0, 0, 1280, 720);
		bg.graphics.endFill();
		addChild(bg);
        video = new Video(false);
        video.load(Path.join([Sys.getCwd(), 'assets/ui/video/valveIntro.mp4']), []);
        video.onEndReached.add(() -> {videoDone();});
        Timer.delay(()->{load();}, 1000);
        addChild(video);

        Sound.loadFromFile('assets/ui/sounds/tf2.ogg').onComplete(snd -> {introSound = snd; trace('sound loaded'); load();}).onError(err -> {trace('error $err');});

        //trace(Assets.list(FONT));
        copyrightText = new TextField();
        copyrightText.text = "©  2010  Valve  Corporation.  All  rights  reserved.  Valve,  the  Valve  logo,  Half-Life,  the  Half-Life  logo,  the  Lambda  logo,  Team  Fortress,  the  Team  fortress  logo,  Portal,  the  Portal  logo,  Source  and  the  Source  logo  are  trademarks  and/or  registered  trademarks  of  Valve  corporation  in  the  United  States,  and  other  countries.  This  product  uses  Havok  Physics.  Copyright  Havok.com  Inc.  (and  its  Licensors).  All  Rights  Reserved.  See  www.havok.com  for  details.  This  product  uses  Miles  Sound  System.  Copyright  1997-2019  by  RAD  Game  Tools,  Inc.  MPEG  Layer-3  playback  supplied  with  the  Miles  Sound  System  from  RAD  Game  Tools,  Inc.  MPEG  Layer-3  audio  compression  technology  licensed  by  Fraunhofer  IIS  and  THOMSON  multimedia.  This  product  includes  code  licensed  from  NVIDIA.";
        var fm = new TextFormat(Assets.getFont('assets/fonts/Verdana-Bold.ttf').fontName, 15, 0xFF6b6a6c, false, false, false, null, null, LEFT);
        fm.letterSpacing = 0.5;
        copyrightText.setTextFormat(fm);
        copyrightText.width = 750;
        copyrightText.height = 400;
        copyrightText.x = (bg.width/2) - (copyrightText.width/2);
        copyrightText.y = 400;
        copyrightText.multiline = true;
        copyrightText.wordWrap = true;
        copyrightText.selectable = false;
        copyrightText.alpha = 0;
        addChild(copyrightText);

        BitmapData.loadFromFile('assets/ui/images/computer/applications/Team Fortress 2/sauce.png').onComplete(bmp -> {
            poweredBy = new Bitmap(bmp);
            poweredBy.alpha = 0;
            poweredBy.x = (bg.width/2) - (poweredBy.width/2);
            poweredBy.y = 200;
            addChild(poweredBy);
            load();
        });

        BitmapData.loadFromFile('assets/ui/images/computer/applications/Team Fortress 2/loading.png').onComplete(bmp -> {
            loading = new Bitmap(bmp);
            loading.scaleX = 1280/1920;
            loading.scaleY = 720/1080;
            loading.visible = false;
            addChild(loading);
            load();
        });

        onReset = () -> {
            trace('hi');
            if (introChannel != null) {
                introChannel.stop();
            }
        } #end
    }

    function load() {
        #if cpp
        loaded++;
        trace(loaded + ' is loaded');
        if (loaded == 3) {
            var st = Timer.stamp();
            if ((st - c1) > 5000) {
                applicationReady();
            } else {
                Timer.delay(applicationReady, Std.int(5000 - (st - c1)));
            }
        }
        #end
    }

    function applicationReady() {
        #if cpp
        video.play();
        video.x += 64;
        introChannel = introSound.play();
        #end
    }

    function videoDone() {
        #if cpp
        removeChild(video);
        #end
        Timer.delay(copyright, 150);
    }

    function copyright() {
        Actuate.tween(poweredBy, 0.25, {alpha:1});
        Actuate.tween(copyrightText, 0.25, {alpha:1});

        Timer.delay(fadeOut, 2750);
    }

    function fadeOut() {
        Actuate.tween(poweredBy, 0.25, {alpha:0});
        Actuate.tween(copyrightText, 0.25, {alpha:0});
        Timer.delay(()->{loading.visible = true;}, 350);
    }
}