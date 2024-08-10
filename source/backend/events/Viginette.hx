package backend.events;

import flixel.tweens.FlxEase;
import openfl.filters.BitmapFilter;
import flixel.tweens.FlxTween;
import backend.chart.Conductor;
import openfl.filters.ShaderFilter;
import states.PlayState;
import shaders.SpookyShader;

class Viginette {
    static var thisShader:SpookyShader;
    static var vals:Array<Array<Float>> = [];
    static var iteration:Int = 0;
    
    public static function reset() {
        thisShader.vigVal.value = [0];
        vals = [];
        iteration = 0;
    }

    public static function queue(v1:String) {
        if (!EventsCore.classes.contains(Viginette)) {
            thisShader = new SpookyShader();
            EventsCore.classes.push(Viginette);
            trace('sigmasigmasigma');
            PlayState.instance.shaderDepo[0].push(new ShaderFilter(thisShader));
        }

        var options = ShaderOptionHandler.handle(v1, {defaultTime: Conductor.crochet/2000, defaultValue:[-1200]});

        var useIntensity = options.get('intensity');

        if (options.get('intensity')[0] == -1200) {
            if (vals.length == 0 || vals[vals.length-1][1] == 0) {
                useIntensity = 0.45;
            } else {
                useIntensity = 0;
            }
        }

        vals.push([options.get('time'), useIntensity]);
    }

    public static function next() {
        PlayState.instance.runningTweens.set('Viginette fade', FlxTween.num(thisShader.vigVal.value[0], vals[iteration][1], vals[iteration][0], {ease:FlxEase.smoothStepOut, onComplete:CoolUtil.removeType(TWEEN, 'Viginette fade')}, f -> {
            thisShader.vigVal.value[0] = f;
        }));
        iteration++;
    }
}