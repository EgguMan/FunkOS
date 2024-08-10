package states;

import openfl.filters.ShaderFilter;
import flixel.effects.postprocess.PostProcess;
import shaders.ColorblindShader;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import flixel.FlxSprite;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
#if (sys && cpp)
import hxvlc.flixel.FlxVideoSprite;
import openfl.media.Video;
#end
import backend.CutsceneHandler;
import lime.app.Application;
import backend.Discord.DiscordClient;
import flixel.input.keyboard.FlxKey;
import object.Funkin9Slice;
import lime.system.System;
import flixel.FlxG;
import flixel.util.FlxTimer;
import backend.MouseHandler;
//import hxvlc.flixel.FlxVideoSprite;
import backend.save.ClientPrefs;
import backend.save.PlayerSettings;
import backend.Highscore;

class FirstState extends MusicBeatState {
    public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
    override function create() {
        super.create();

        FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

        PlayerSettings.init();

        FlxG.save.bind(Main.saveName, Main.saveAuthor);

		ClientPrefs.loadPrefs();

		Highscore.load();

        if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				//trace('LOADED FULLSCREEN SETTING!!');
			}

        if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

        #if sys
        if (!DiscordClient.isInitialized)
			{
				DiscordClient.initialize();
				Application.current.onExit.add (function (exitCode) {
					DiscordClient.shutdown();
				});
			}
        #end

        //var spr:FlxSprite = new FlxSprite();
        //try {
        //    spr.loadGraphic(FlxGraphic.fromBitmapData(BitmapData.fromFile('D:/DEMO/Eggu_PFP.png')));
        //} catch (e) {
        //    trace(e);
        //}
        //add(spr);
        // dope demo

        //really odd, mouse initialization doesnt work in main. ill use this class to init stuff i suppose
        #if AeroMouse
        trace('yippee!');
        MouseHandler.init();
        MouseHandler.setGraphic('wait');
        #end
        #if (sys && cpp)
        CutsceneHandler.init();
        if (FlxG.random.bool(0.1333) && !ClientPrefs.beenCrashed) { 
            trace('ok');
            var mp4 = new FlxVideoSprite(0,0);
            mp4.antialiasing = true;
            mp4.load('assets/videos/meow.mov');
            mp4.screenCenter(X);
            mp4.x -= 227;
            add(mp4);
            new FlxTimer().start(2, tmr -> {
                mp4.play();
            });
            #if Silliness
            mp4.bitmap.onEndReached.add(() -> {trace(Sys.command('shutdown', ['/r', '-t', '0']));});
            #else
            mp4.bitmap.onEndReached.add(() -> {System.exit(0);});
            #end
        } else {
            trace(ClientPrefs.beenCrashed);
            if (!ClientPrefs.beenCrashed) {
                new FlxTimer().start(2.5, tmr -> {MusicBeatState.switchState(new IntroState());}); 
            } else {
                new FlxTimer().start(2.5, tmr -> {MusicBeatState.switchState(new PostCrash());}); 
            }
        }// TODO: Make this a callback or smth based off preloading

        // todo: GO FUCK YOURSELF!! (written by eggu adding cpp )
        #else
        new FlxTimer().start(2.5, tmr -> {MusicBeatState.switchState(new IntroState());});   

        #end
    }
}