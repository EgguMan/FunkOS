package backend.events;

import shaders.VHSLinesShader;
import shaders.BarrelShader;
import flixel.tweens.FlxEase;
import openfl.filters.BitmapFilter;
import flixel.tweens.FlxTween;
import backend.chart.Conductor;
import openfl.filters.ShaderFilter;
import states.PlayState;

class VHSLines {
    static var thisShader:VHSLinesShader;
    static var vals:Array<Array<Float>> = [];
    static var iteration:Int = 0;
    
    public static function reset() {
        thisShader.blocks.value = [-1];
        thisShader.timeMult.value = [-1];
        vals = [];
        iteration = 0;
    }

    public static function queue(v1:String) {
        if (!EventsCore.classes.contains(VHSLines)) {
            thisShader = new VHSLinesShader();
            EventsCore.classes.push(VHSLines);
            PlayState.instance.shaderDepo[0].push(new ShaderFilter(thisShader));
        }

        var options = ShaderOptionHandler.handle(v1, {defaultSize:-63, defaultTime: Conductor.crochet/2000, defaultValue:[-1200]});

        
        if (options.get('size') == -63) {
            if (vals.length == 0 || vals[vals.length-1][1] == -1) {
                options.set('size', 32);
            } else {
                options.set('size', -1);
            }
        }

        if (options.get('intensity') == [-1200]) {
            if (vals.length == 0 || vals[vals.length-1][2] == 0) {
                options.set('intensity', 2);
            } else {
                options.set('intensity', 0);
            }
        }

        trace(options);
        
        vals.push([options.get('time'), options.get('size'), options.get('intensity')]);
    }

    public static function next() {
        trace(vals);
        trace(vals[iteration][1]);
        if (vals[iteration][1] != thisShader.blocks.value[0]) {
            PlayState.instance.runningTweens.set('VHS fade 1', FlxTween.num(thisShader.blocks.value[0], vals[iteration][1], vals[iteration][0], {ease:FlxEase.smoothStepOut, onComplete:CoolUtil.removeType(TWEEN, 'VHS fade 1')}, f -> {
                thisShader.blocks.value[0] = Std.int(f);
            }));
        }
        if (vals[iteration][2] != thisShader.timeMult.value[0]) {
            PlayState.instance.runningTweens.set('VHS fade 1', FlxTween.num(thisShader.timeMult.value[0], vals[iteration][2], vals[iteration][0], {ease:FlxEase.smoothStepOut, onComplete:CoolUtil.removeType(TWEEN, 'VHS fade 1')}, f -> {
                thisShader.timeMult.value[0] = Std.int(f);
            }));
        }
        iteration++;
    }
}