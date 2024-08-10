package backend;

import haxe.PosInfos;
import flixel.FlxG;
#if sys
import sys.io.File;
#end
import haxe.Json;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import states.PlayState;
#if (sys && cpp)
import hxvlc.flixel.FlxVideoSprite;
import openfl.media.Video;
#end
using StringTools; //for .replace

typedef CutsceneData = {
    hasCutscene:Bool, //duh

    filePath:String, //the path.
    fileExtension:String, //mp4, mov, avi, etc...

    fadeOutTime:Float, //will fade out at the end of the video
    beginningDelay:Float, //will wait to play the video, and show the cover in the meantime

    coverType:String, // image, color, or null
    constantCover:Bool, // if the cover shows up even if the video has played. good for non-16:9 videos
    coverVal:String, // image path from preload / color hex value (0x000000 for black (; )
    coverScale:Array<Float>, // size multiplier for image 
    // dude the cover actually somehow gave me more problems than the video itself. From fucking up the renderer, to deleting its own graphic, this was suprisingly hard.

    alpha:Float, // the alpha of the cutscene - only used for mid-song

    canSkip:Bool, // if you're allowed to skip it
    fadeOnSkip:Bool, // if it will fade out when you skip it

    alwaysPlay:Bool //if false, it will not play if you've seen it already. does not have priority over the "show cutscenes" option
}


class CutsceneHandler {
    #if (sys && cpp)
    public static var cutscenesByName:Map<String, Cutscene>;

    public static function init(?pos:PosInfos) {
        cutscenesByName = new Map<String, Cutscene>();
    }

    public static function reset() {
        cutscenesByName.clear();
    }

    /*ublic static function clean(?from:PosInfos) {
        for (k => v in cutsceneCache.keyValueIterator()) {
            v.cutsceneObject.bitmap.dispose();
            v.cutsceneObject.kill();
            v.cutsceneObject.destroy();
            if (v.coverObject != null) {
                v.coverObject.kill();
                v.coverObject.destroy();
            }
            cutsceneCache.remove(k);
        }
        for (k => v in cutscenesByName.keyValueIterator()) {
            cutscenesByName.remove(k);
        }
        trace('clean called from ${from.fileName}:${from.lineNumber}');
    }*/ //it doesnt seem the cache works, not my problem though the bitmap will make itself null for some reason, so ill just scrap the cache entireley.

    public static function loadVideo(inp:String, fileExtension:String, ?cb:Void->Void, ?name:String = ''):Cutscene {
        //TODO - multithread
        //todo- GO FUCK YOURSELF!
        var toSet = inp;
        if (name != '') toSet = name;
        var vid = new Cutscene(inp+'.'+fileExtension, cb);
        cutscenesByName.set(toSet, vid);
        trace('set the name to $toSet');
        return vid;
        
    }
    #end
}

class Cutscene {
    #if (sys && cpp)
    public var data:CutsceneData;
    public var fadeTween:FlxTween;
    public var fadeTimer:FlxTimer;
    public var fadeInTime:Float; // for mid-song cutscenes

    //better than accessing the map methinks
    public var cutsceneObject:FlxVideoSprite;
    public var coverObject:FlxSprite;

    public function new(path:String, ?cb:Void->Void) {
        cutsceneObject = new FlxVideoSprite();
        cutsceneObject.load('assets/videos/$path');
        trace('assets/videos/$path');
        if (cb!=null) {
            cutsceneObject.bitmap.onMediaChanged.add(cb);
        }
        
    }

    public function loadData(path:String, ?song:Bool = false) {
        if (song) {
            var formattedFolder:String = backend.Paths.formatToSongPath(path) + CoolUtil.getDifficultyFilePath();
            var formattedSong:String = backend.Paths.formatToSongPath(path);
            #if sys
            trace(backend.Paths.json(formattedFolder + '/' + formattedSong + 'CUTSCENE'));

			var rawJson = File.getContent(backend.Paths.json(formattedFolder + '/' + formattedSong + 'CUTSCENE')).trim();
			#else
			rawJson = Assets.getText(backend.Paths.json(formattedFolder + '/' + formattedSong + 'CUTSCENE')).trim();
			#end
            data = Json.parse(rawJson);
        }
    }
    #end
}