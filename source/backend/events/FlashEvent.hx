package backend.events;

import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import openfl.filters.ShaderFilter;
import states.PlayState;
import backend.chart.Conductor;
import shaders.FlashShader;

class FlashEvent {
    public static var flashShader:FlashShader;

    public static var vals:Array<Array<Float>>=[];
    public static var iteration:Int = 0;

    public static function reset() {
        flashShader.colOvr.value = [1,1,1];
        flashShader.ints.value = [0];
        vals = [];
        iteration=0;
    }

    public static function queue(value:String) {
        if (!EventsCore.classes.contains(FlashEvent)) {
            EventsCore.classes.push(FlashEvent);
            if (flashShader == null) flashShader = new FlashShader();
            PlayState.instance.shaderDepo[0].push(new ShaderFilter(flashShader));
        }
        var options = ShaderOptionHandler.handle(value, {defaultTime: Conductor.crochet/2000, defaultColor: [0xFFFFFFAA]});

        if (options.get('colors') == [0xFFFFFFAA] && vals.length != 0) {
            options.set('colors', vals[vals.length-1][1]);
        } else if (options.get('colors') == [0xFFFFFFAA] && vals.length == 0) {
            options.set('colors', [0xFFFFFFFF]);
        }

        vals.push([options.get('time'), options.get('colors')[0]]);
    }

    public static function next() {
        var col:FlxColor = FlxColor.fromInt(Math.floor(vals[iteration][1]));
        if (col.alpha == 0) {
            col.alphaFloat = 1;
        }
        flashShader.colOvr.value = [col.redFloat, col.greenFloat, col.blueFloat, col.alphaFloat];
        PlayState.instance.runningTweens.set('Flash EventTween', FlxTween.num(1, 0, vals[iteration][0], {onComplete: CoolUtil.removeType(TWEEN, 'Flash EventTween')}, f -> {
            flashShader.ints.value = [f];
        }));
        iteration++;
    }
}