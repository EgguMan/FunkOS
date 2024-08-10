package backend.events;

#if sys
import sys.io.File;
#end
import haxe.Json;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import haxe.Int64;
import states.PlayState;
import flixel.util.FlxTimer;
#if (cpp && sys)
import hxvlc.flixel.FlxVideoSprite;
#end
import backend.CutsceneHandler.Cutscene;
import backend.CutsceneHandler;

using StringTools;

class MidSongCutscene {
    public static var cutscenes:Array<String> = [];
    public static var iteration:Int = -1;

    public static var dataArray:Array<CutsceneData>=[];
    public static var miniIteration:Int = 0;

    public static var initialized:Bool = false;

    public static function reset() {
        cutscenes = [];
        iteration = -1;
        miniIteration = 0;
        initialized = false;
    }

    public static function init() {
		#if (cpp && sys)
        if (!EventsCore.classes.contains(MidSongCutscene)) EventsCore.classes.push(MidSongCutscene);
        initialized = true;
        var path = PlayState.SONG.song;
        var formattedFolder:String = backend.Paths.formatToSongPath(path) + CoolUtil.getDifficultyFilePath();
        var formattedSong:String = backend.Paths.formatToSongPath(path);
        #if sys
        trace(backend.Paths.json(formattedFolder + '/' + formattedSong + 'CUTSCENE'));

        var rawJson = File.getContent(backend.Paths.json(formattedFolder + '/' + formattedSong + 'CUTSCENE')).trim();
        #else
        rawJson = Assets.getText(backend.Paths.json(formattedFolder + '/' + formattedSong + 'CUTSCENE')).trim();
        #end
        dataArray = Json.parse(rawJson);
        #else
        trace('Mid-song cutscenes not supported on this platform');
        #end
    }

    #if (cpp && sys)
    public static function queueCutscene(cutsceneName:String, fadeIntTime:Float) {
        iteration = -1;
        var cs = cutsceneName.split('.');
        if (!CutsceneHandler.cutscenesByName.exists(cutsceneName)) {
            CutsceneHandler.loadVideo(cs[0], cs[1], () -> {makeNewCutscene(cs, fadeIntTime);}, cutsceneName + ' MIDSONG PLEASE DONT OVERWRITE');
        } else {
            queue2(cs[0], fadeIntTime);
        }
        trace('cutscenes are not supported on this platform!');
    }

    public static function queue2(name:String, fadeIntTime:Float) {
        var csObj:Cutscene = CutsceneHandler.cutscenesByName.get(name);
        cutscenes.push(name);
        csObj.fadeInTime = fadeIntTime;
        csObj.coverObject.visible = false;
    }

    public static function makeNewCutscene(inp:Array<String>, fadeIntTime:Float) {
        trace('lol it doesnt exist! but it did run, so thats a plus. give it ${inp[0]}.${inp[1]}');
        var csObj = CutsceneHandler.cutscenesByName.get(inp[0]+'.'+inp[1] + ' MIDSONG PLEASE DONT OVERWRITE');
        csObj.data = dataArray[miniIteration];
        miniIteration++;
        csObj.cutsceneObject.scrollFactor.set(0,0);
        csObj.cutsceneObject.screenCenter();
        csObj.cutsceneObject.bitmap.position = 0;

        var cover:FlxSprite = null;
        if ((csObj.data.coverType != 'none' && csObj.data.coverType != '')) {
            switch(csObj.data.coverType) {
                case 'color':
                    cover = new FlxSprite().loadGraphic(FlxGraphic.fromBitmapData(new BitmapData(1280, 720, false, Std.parseInt(csObj.data.coverVal)))); //it wont work any other way and I have no clue why
                case 'image':
                    cover = new FlxSprite().loadGraphic(backend.Paths.image(csObj.data.coverVal));
                default:
                    cover = new FlxSprite(); // klein
            }
            cover.cameras = [PlayState.instance.camHUD];
        }
        csObj.coverObject = cover;
        queue2(inp[0]+'.'+inp[1] + ' MIDSONG PLEASE DONT OVERWRITE', fadeIntTime);
    }

    public static function playNextVideo() {
        iteration++;
        if (cutscenes[iteration] != null) {
            play();
        } else {
            trace(cutscenes);
            trace(cutscenes[iteration]);
            trace(iteration);
            trace('DUMBASS THE CUTSCENE IS NULL');
        }
    }

    public static function play() {
        trace('playing mid-song cutscene');
		var csObj = CutsceneHandler.cutscenesByName.get(cutscenes[iteration]);
		var cover = csObj.coverObject;
		var cutscene:FlxVideoSprite = csObj.cutsceneObject;
		PlayState.instance.add(cutscene);
		cutscene.stop();
		cutscene.play();
        cover.visible = true;
        GameplayEvents.GAME_PLAYUPDATE.add(gamePausePlay);
		var skibidi = () -> {
			cutscene.visible = true;
			cutscene.centerOrigin();
			cutscene.screenCenter();
			cutscene.bitmap.onDisplay.removeAll();
		};
		cutscene.bitmap.onDisplay.add(skibidi);
        if (csObj.fadeInTime != 0) {
            if (csObj.coverObject != null) {
                csObj.fadeTween = FlxTween.tween(csObj, {"cutsceneObject.alpha":csObj.data.alpha, "coverObject.alpha":1}, csObj.fadeInTime, {onComplete: tmr -> {csObj.fadeTween = null;}});
            } else {
                csObj.fadeTween = FlxTween.tween(csObj, {"cutsceneObject.alpha":csObj.data.alpha}, csObj.fadeInTime, {onComplete: tmr -> {csObj.fadeTween = null;}});
            }
        } else {
            csObj.cutsceneObject.alpha = csObj.data.alpha;
        }
		if (csObj.data.fadeOutTime != 0) {
			cutscene.bitmap.onOpening.add(() -> {
				trace(((Int64.toInt(cutscene.bitmap.length))/1000));
				csObj.fadeTimer = new FlxTimer().start(((Int64.toInt(cutscene.bitmap.length))/1000) - csObj.data.fadeOutTime, tmr -> {
					csObj.fadeTween = FlxTween.tween(csObj, {"cutsceneObject.alpha":0, "coverObject.alpha":0}, csObj.data.fadeOutTime);
				});
			});
		}
		cutscene.bitmap.onEndReached.add(() -> {cutsceneFinished();});
    }

    public static function gamePausePlay(pause:Bool) {
        if (pause) {
            var csDat = CutsceneHandler.cutscenesByName.get(cutscenes[iteration]);
            if (csDat.cutsceneObject.bitmap != null) {
                csDat.cutsceneObject.pause();
            }
            if (csDat.fadeTimer != null)
                csDat.fadeTimer.active = false;
            if (csDat.fadeTween != null)
                csDat.fadeTween.active = false;
        } else {
            var csDat = CutsceneHandler.cutscenesByName.get(cutscenes[iteration]);
            if (csDat.cutsceneObject.bitmap != null) {
                csDat.cutsceneObject.resume();
            }
            if (csDat.fadeTimer != null)
                csDat.fadeTimer.active = true;
            if (csDat.fadeTween != null)
                csDat.fadeTween.active = true;
        }
    }
    
    public static function cutsceneFinished() {
		var cutscene = CutsceneHandler.cutscenesByName.get(cutscenes[iteration]);
        trace(iteration);
        trace(cutscenes);
        trace(CutsceneHandler.cutscenesByName);
		var cover = cutscene.coverObject;
		trace('done');
		if (cutscene.data.constantCover) 
			cover.visible = false;
		var obj:FlxVideoSprite = cutscene.cutsceneObject;
		if (obj != null) {
			cutscene.cutsceneObject.stop();
		}
		cutscene.fadeTimer = null;
		cutscene.fadeTween = null;
		obj.visible = false;
        GameplayEvents.GAME_PLAYUPDATE.remove(gamePausePlay);
		PlayState.instance.remove(obj);
	}
    #end
}