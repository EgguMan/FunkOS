package states;

import openfl.system.System;
import sys.io.Process;
import haxe.Timer;
import sys.thread.Thread;
import flixel.FlxG;
import flixel.util.FlxTimer;
import backend.save.ClientPrefs;
#if cpp
import hxvlc.flixel.FlxVideoSprite;
#end

class IntroState extends MusicBeatState {

   #if cpp 
   var flxSplash:FlxVideoSprite; 
   var aeroSplash:FlxVideoSprite;
   #end
   
 
    override function create() {
        #if cpp
        flxSplash = new FlxVideoSprite(0, 0);
        flxSplash.antialiasing = true;
        flxSplash.load(Paths.video('flixel'));
        add(flxSplash);
        flxSplash.bitmap.onEndReached.add(() -> {
            new FlxTimer().start(1, playAeroSplash);
            flxSplash.visible = false;
        });
        flxSplash.bitmap.onEncounteredError.add(str -> {
            trace('Error enountered: ' + str);
            introDone(null);
        });

        aeroSplash = new FlxVideoSprite(0, 0);
        aeroSplash.antialiasing = true;
        aeroSplash.load('assets/videos/aero.mov');
        add(aeroSplash);
        aeroSplash.bitmap.onEndReached.add(() -> {
            new FlxTimer().start(1, introDone);
            aeroSplash.visible = false;
        });
        aeroSplash.bitmap.onEncounteredError.add(str -> {
            trace('Error enountered: ' + str);
            introDone(null);
        });
    
        new FlxTimer().start(2, tmr -> {
            flxSplash.play();
            flxSplash.bitmap.volume = 100;
            flxSplash.updateHitbox();
            flxSplash.screenCenter();
            flxSplash.x -= 640;
            flxSplash.y -= 360;
        });#else 
        introDone(null);
        #end
        super.create();
    }

    function introDone(tmr:Null<FlxTimer>) {
        MusicBeatState.switchState(new TitleState());
        return;
    }

    function playAeroSplash(tmr:Null<FlxTimer>) {
        #if cpp
        new FlxTimer().start(1, tmr -> {
            aeroSplash.play();
            aeroSplash.updateHitbox();
            aeroSplash.screenCenter();
            aeroSplash.x -= 640;
            aeroSplash.y -= 360;
        });
        #end
    }

}