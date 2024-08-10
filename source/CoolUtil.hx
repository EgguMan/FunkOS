package;

import sys.io.Process;
import openfl.system.System;
import flixel.math.FlxPoint;
import openfl.Lib;
import flixel.tweens.FlxTween.TweenCallback;
import flixel.tweens.FlxEase;
import haxe.Json;
import flixel.FlxG;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import flixel.system.FlxSound;
#if sys
import sys.io.File;
import sys.FileSystem;
#else
import openfl.utils.Assets;
#end
import states.PlayState;

using StringTools;

enum RemovalTypes {
	TWEEN;
	TIMER;
	SOUND;
}

class CoolUtil
{

	public static function reloadGame() {
		new Process(Sys.programPath(), []);
        System.exit(0);
	}

	public static function removeType(type:RemovalTypes, key:String, ?cb:()->Void):TweenCallback {
		if (cb == null) cb = ()->{};
		switch (type) {
			case TWEEN:
				return (twn -> {PlayState.instance.runningTweens.remove(key); cb();});
			case TIMER:
				return (twn -> {PlayState.instance.runningTweens.remove(key); cb();});	
			case SOUND:
			return (twn -> {PlayState.instance.runningTweens.remove(key); cb();});
		}
		return (twn -> {trace(key + ' could not be removed!');});
	}

	public static function easeFromTime(time:Float) {
		if (time < 0.25000001) {
			return FlxEase.linear;
		} else if (time < 0.50000001) {
			return FlxEase.quadIn;
		} else {
			return FlxEase.quadInOut;
		}
	}
	public static var defaultDifficulties:Array<String> = [
		'Easy',
		'Normal',
		'Hard'
	];

	#if !final
	public static var debugVals(get,default):Dynamic;
	private static function get_debugVals() {
		debugVals = Json.parse(File.getContent('assets/data/debug.json'));
		return debugVals;
	}
	#end

	public static var defaultDifficulty:String = 'Normal'; //The chart that has no suffix and starting difficulty on Freeplay/Story Mode

	public static var difficulties:Array<String> = [];

	inline public static function quantize(f:Float, snap:Float){
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		trace(snap);
		return (m / snap);
	}
	
	public static function getDifficultyFilePath(num:Null<Int> = null)
	{
		if(num == null) num = PlayState.storyDifficulty;

		var fileSuffix:String = difficulties[num];
		if(fileSuffix != defaultDifficulty)
		{
			fileSuffix = '-' + fileSuffix;
		}
		else
		{
			fileSuffix = '';
		}
		return backend.Paths.formatToSongPath(fileSuffix);
	}

	public static function difficultyString():String
	{
		return '';
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = [];
		#if sys
		if(FileSystem.exists(path)) daList = File.getContent(path).trim().split('\n');
		#else
		if(Assets.exists(path)) daList = Assets.getText(path).trim().split('\n');
		#end

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
	public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
	public static function dominantColor(sprite:flixel.FlxSprite):Int{
		var countByColor:Map<Int, Int> = [];
		for(col in 0...sprite.frameWidth){
			for(row in 0...sprite.frameHeight){
			  var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
			  if(colorOfThisPixel != 0){
				  if(countByColor.exists(colorOfThisPixel)){
				    countByColor[colorOfThisPixel] =  countByColor[colorOfThisPixel] + 1;
				  }else if(countByColor[colorOfThisPixel] != 13520687 - (2*13520687)){
					 countByColor[colorOfThisPixel] = 1;
				  }
			  }
			}
		 }
		var maxCount = 0;
		var maxKey:Int = 0;//after the loop this will store the max color
		countByColor[flixel.util.FlxColor.BLACK] = 0;
			for(key in countByColor.keys()){
			if(countByColor[key] >= maxCount){
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	//uhhhh does this even work at all? i'm starting to doubt
	public static function precacheSound(sound:String, ?library:String = null):Void {
		backend.Paths.sound(sound, library);
	}

	public static function precacheMusic(sound:String, ?library:String = null):Void {
		backend.Paths.music(sound, library);
	}

	public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	public static var windowScaleRatio(get, never):FlxPoint; 

	public static function get_windowScaleRatio() {
		return new FlxPoint(Lib.application.window.width/2560, Lib.application.window.height/1440);
	}
}
