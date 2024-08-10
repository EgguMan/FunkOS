package backend.events;

import openfl.filters.BitmapFilter;
import flixel.tweens.FlxTween;
import backend.chart.Conductor;
import openfl.filters.ShaderFilter;
import states.PlayState;
import shaders.SpookyShader;

class GlitchyEvent {
    static var thisShader:SpookyShader;
    static var vals:Array<Array<Float>> = [];
    static var iteration:Int = 0;

    static final propertyNames:Array<String> = ['Glitch', 'Static', 'Abberation'];
    static final defaults:Array<Float> = [-1200, -1200, -1200];
    
    public static function reset() {
        thisShader.vigVal.value = [0];
        vals = [];
        iteration = 0;
    }

    public static function queue(v1:String) {
        if (!EventsCore.classes.contains(GlitchyEvent)) {
            thisShader = new SpookyShader();
            EventsCore.classes.push(GlitchyEvent);
            PlayState.instance.shaderDepo[0].push(new ShaderFilter(thisShader));
        }

        var options = ShaderOptionHandler.handle(v1, {defaultTime: Conductor.crochet/2000, defaultValue:[-1200, -1200]}); // using defaults would cause it to defauly to something else ???????

        var useIntensity:Array<Float> = options.get('intensity');

        for (i in 0...defaults.length) {
            if (i >= useIntensity.length) {
                useIntensity.push(-1200);
            }
            if (useIntensity[i] == -1200) {
                if (vals.length == 0 || vals[vals.length-1][i+1] == 0) {
                    trace('setting silly');
                    useIntensity[i] = (i+1)*0.25;
                } else {
                    useIntensity[i] = 0;
                }
            } else {
                trace(useIntensity[i]);
            }
        }

        options.set('intensity',useIntensity);

        vals.push([options.get('time'), useIntensity[0], useIntensity[1], useIntensity[2]]);
    }

    public static function next() {
        for (i in 0...3) {
            PlayState.instance.runningTweens.set('GlitchyFade' + propertyNames[i], FlxTween.num(thisShader.getVal(i+1), vals[iteration][i+1], vals[iteration][0], {ease:CoolUtil.easeFromTime(vals[iteration][0]), onComplete:CoolUtil.removeType(TWEEN, 'GlitchyFade' + propertyNames[i])}, f -> {
                thisShader.setVal(i+1, f);
            }));
        }
        iteration++;
    }
}