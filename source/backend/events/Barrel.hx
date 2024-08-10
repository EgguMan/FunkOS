package backend.events;

import shaders.BarrelShader;
import flixel.tweens.FlxEase;
import openfl.filters.BitmapFilter;
import flixel.tweens.FlxTween;
import backend.chart.Conductor;
import openfl.filters.ShaderFilter;
import states.PlayState;

class Barrel {
    static var thisShader:BarrelShader;
    static var vals:Array<Array<Float>> = [];
    static var iteration:Int = 0;
    
    public static function reset() {
        thisShader.mult.value = [0];
        vals = [];
        iteration = 0;
    }

    public static function queue(v1:String) {
        if (!EventsCore.classes.contains(Barrel)) {
            EventsCore.classes.push(Barrel);
        }

        var options = ShaderOptionHandler.handle(v1, {defaultTime: Conductor.crochet/2000, defaultValue:[-1200]});

        var useIntensity = options.get('intensity');

        if (options.get('intensity')[0] == -1200) {
            if (vals.length == 0 || vals[vals.length-1][1] == 0) {
                useIntensity = -1; // i like that one more sorryyyyyy
            } else {
                useIntensity = 0;
            }
        }
        
        vals.push([options.get('time'), useIntensity]);

        if (vals.length == 1) {
            thisShader = new BarrelShader();
            PlayState.instance.shaderDepo[0].push(new ShaderFilter(thisShader));
        }

    }

    public static function next() {
        trace(thisShader.mult.value[0]);
        PlayState.instance.runningTweens.set('Barrel fade', FlxTween.num(thisShader.mult.value[0], vals[iteration][1], vals[iteration][0], {ease:FlxEase.smoothStepOut, onComplete:CoolUtil.removeType(TWEEN, 'Barrel fade')}, f -> {
            thisShader.mult.value[0] = f;
        }));
        iteration++;
    }
}