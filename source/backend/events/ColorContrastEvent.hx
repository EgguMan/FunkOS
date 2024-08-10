package backend.events;

import backend.chart.Conductor;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.util.FlxTimer;
import shaders.BadAppleShader;
import openfl.filters.ShaderFilter;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import states.PlayState;
import flixel.FlxSprite;

class ColorContrastEvent {
    public static var colors:Array<Dynamic> = [];

    public static var initialized:Bool = false;

    static var inCol:Bool = false;
    static var iteration:Int = 0;

    static var updateFunctions:Array<Float->Void> = [];
    static var shaders:Array<BadAppleShader> = [];
    static var shaderToSet:Array<Float> = [0,0,0,0];

    public static function reset() {
            for (c in colors) {
                if (c[0] != null) c[0].kill();
            }
            inCol = false;
            iteration = 0;
            updateFunctions = [];
            initialized = false;
            for (j in 0...shaders.length) {
                for (i in 0...5) {
                    updateShaders(j, i, 0);
                }
            }
            PlayState.instance.dad.shader = null;
            PlayState.instance.boyfriend.shader = null;
            if (PlayState.instance.gf != null) {
                PlayState.instance.gf.shader = null;
            }
            shaders = [];
            colors = [];
    }

    public static function anotherOne(values:String) {
        if (!EventsCore.classes.contains(ColorContrastEvent)) EventsCore.classes.push(ColorContrastEvent);
        initialized = true;
        var array = new Array<Dynamic>();

        var options = ShaderOptionHandler.handle(values, {defaultTime:Conductor.crochet/8000, defaultValue:[0]});
        var _colors:Array<Int> = options.get('colors');

        if (_colors == null) {
            array = [null, options.get('time')];
        } else {
            var bg = new FlxSprite().makeGraphic(1280,720,_colors[0]);
            bg.scrollFactor.set(0,0);
            var cols = [];
            _colors.shift();
            for (col in _colors) {
                cols.push(col);
                var shader = new BadAppleShader();
                shaders.push(shader);
            }
            PlayState.instance.boyfriend.shader = shaders[0];
            PlayState.instance.dad.shader = shaders[1];
            if (PlayState.instance.gf != null) {
                PlayState.instance.gf.shader = shaders[2];
            }
            array = [bg, cols, options.get('time')];
        }

        colors.push(array);
    }

    public static function next() {
        var entry:Array<Dynamic> = colors[iteration+1];
        if (inCol) {
            if (Std.isOfType(entry[0], FlxSprite)) {
                fadeBoth();
            } else {
                fadeOut();
            }
        } else {
            thisOne();
        }
    }

    public static function fadeBoth() {
        var entry:Array<Dynamic> = colors[iteration];
        var nextEntry:Array<Dynamic> = colors[iteration+1];
        var thisBG:FlxSprite = entry[0];
        var colArray = ['R','G','B'];
        if (nextEntry[2] != 0) {
            nextEntry[0].alpha = 0;
            nextEntry[0].scale.set(1/PlayState.instance.cameraProperties[0], 1/PlayState.instance.cameraProperties[0]);
            PlayState.instance.addBehindGF(nextEntry[0]);
            var name = 'BGFade$iteration${entry[0]}';
            PlayState.instance.runningTweens.set(name+'now', FlxTween.tween(thisBG, {alpha:0}, nextEntry[2], {ease:CoolUtil.easeFromTime(nextEntry[2]), onComplete: CoolUtil.removeType(TWEEN, name+'now')}));
            PlayState.instance.runningTweens.set(name+'then', FlxTween.tween(nextEntry[0], {alpha:1}, nextEntry[2]/1.5, {ease:CoolUtil.easeFromTime(nextEntry[2]), onComplete: CoolUtil.removeType(TWEEN, name+'then',()->{
                PlayState.instance.remove(thisBG);
                GameplayEvents.GAME_UPDATE.remove(updateFunctions[thisBG.ID]);
                updateFunctions.remove(updateFunctions[thisBG.ID]);
                var thisUpdate = f -> {
                    var scaleMult:Float = 1/PlayState.instance.cameraProperties[0];
                    nextEntry[0].scale.set(scaleMult, scaleMult);
                }
                GameplayEvents.GAME_UPDATE.add(thisUpdate);
                updateFunctions.push(thisUpdate);
                nextEntry[0].ID = updateFunctions.lastIndexOf(thisUpdate);
            })}));
            for (j in 0...FlxMath.minInt(entry[1].length, nextEntry[1].length)) {
                for(i in 0...4) {
                    var thisCol = FlxColor.fromInt(entry[1][i]);
                    var cols = [thisCol.redFloat, thisCol.greenFloat, thisCol.blueFloat, 1];
                    var newCol = FlxColor.fromInt(nextEntry[1][i]);
                    var cols2 = [newCol.redFloat, newCol.greenFloat, newCol.blueFloat, 1];
                    PlayState.instance.runningTweens.set(name+'CHAR$iteration ${colArray[i]}',FlxTween.num(cols[i], cols2[i], nextEntry[2], {onComplete: CoolUtil.removeType(TWEEN, name+'CHAR$iteration ${colArray[i]}')}, num -> {
                        updateShaders(j, i, num);
                    }));
                }
            }
        } else {
            thisBG.alpha = 0;
            GameplayEvents.GAME_UPDATE.remove(updateFunctions[thisBG.ID]);
            updateFunctions.remove(updateFunctions[thisBG.ID]);
            nextEntry[0].alpha = 1;
            PlayState.instance.remove(thisBG);
            PlayState.instance.addBehindGF(nextEntry[0]);
            var thisUpdate = f -> {
                var scaleMult:Float = 1/PlayState.instance.cameraProperties[0];
                nextEntry[0].scale.set(scaleMult, scaleMult);
            }
            GameplayEvents.GAME_UPDATE.add(thisUpdate);
            updateFunctions.push(thisUpdate);
            nextEntry[0].ID = updateFunctions.lastIndexOf(thisUpdate);
            for (j in 0...entry[1].length) {
                for(i in 0...4) {
                    var thisCol = FlxColor.fromInt(nextEntry[1][j]);
                    var cols2 = [thisCol.redFloat, thisCol.greenFloat, thisCol.blueFloat, 1];
                    updateShaders(j, i, cols2[i]);
                }
            }
        }
        iteration++;
    }

    public static function fadeOut() {
        inCol = false;
        var entry:Array<Dynamic> = colors[iteration+1];
        var pastEntry:Array<Dynamic> = colors[iteration];
        var thisBG:FlxSprite = entry[0];
        var colArray = ['R','G','B','A'];
        if (entry[2] != 0) {
            var name = 'BGFade$iteration${entry[0]}';
            PlayState.instance.runningTweens.set(name, FlxTween.tween(pastEntry[0], {alpha:0}, entry[2], {ease:CoolUtil.easeFromTime(entry[2]), onComplete: CoolUtil.removeType(TWEEN, name)}));
            PlayState.instance.runningTweens.set(name+'FG', FlxTween.tween(PlayState.instance.foregroundGroup, {alpha:1}, entry[2], {ease:CoolUtil.easeFromTime(entry[2]), onComplete: CoolUtil.removeType(TWEEN, name+'FG')}));
            for (j in 0...pastEntry[1].length) {
                for(i in 0...5) {
                    var thisCol = FlxColor.fromInt(pastEntry[1][i]);
                    var cols = [thisCol.redFloat, thisCol.greenFloat, thisCol.blueFloat, 1];
                    PlayState.instance.runningTweens.set(name+'CHAR$iteration ${colArray[i]}',FlxTween.num(cols[i], 0, entry[2], {onComplete: CoolUtil.removeType(TWEEN, name+'CHAR$iteration ${colArray[i]}')}, num -> {
                        updateShaders(j, i, num);
                    }));
                }
            }
        } else {
            thisBG.alpha = 0;
            GameplayEvents.GAME_UPDATE.remove(updateFunctions[thisBG.ID]);
            updateFunctions.remove(updateFunctions[thisBG.ID]);
            PlayState.instance.remove(thisBG);
            for (j in 0...entry[1].length) {
                for(i in 0...5) {
                    updateShaders(j, i, 0);
                }
            }
        }
        iteration++;
    }

    public static function thisOne() {
        inCol = true;
        var entry:Array<Dynamic> = colors[iteration];
        var thisBG:FlxSprite = entry[0];
        var thisUpdate = f -> {
            var scaleMult:Float = 1/PlayState.instance.cameraProperties[0];
            thisBG.scale.set(scaleMult, scaleMult);
        }
        updateFunctions.push(thisUpdate);
        entry[0].ID = updateFunctions.lastIndexOf(thisUpdate);
        colors[iteration].push(thisUpdate);
        GameplayEvents.GAME_UPDATE.add(thisUpdate);
        PlayState.instance.addBehindGF(thisBG);
            var colArray = ['R','G','B','A'];
        if (entry[2] != 0) {
            thisBG.alpha = 0;
            var name = 'BGFade$iteration${entry[0]}';
            PlayState.instance.runningTweens.set(name+'FG', FlxTween.tween(PlayState.instance.foregroundGroup, {alpha:0}, entry[2], {ease:CoolUtil.easeFromTime(entry[2]), onComplete: CoolUtil.removeType(TWEEN, name+'FG')}));
            PlayState.instance.runningTweens.set(name, FlxTween.tween(thisBG, {alpha:1}, entry[2], {ease:CoolUtil.easeFromTime(entry[2]), onComplete: CoolUtil.removeType(TWEEN, name)}));
            for (j in 0...entry[1].length){
                for(i in 0...5) {
                    var thisCol = FlxColor.fromInt(entry[1][j]);
                    var cols = [thisCol.redFloat, thisCol.greenFloat, thisCol.blueFloat, 1];
                    PlayState.instance.runningTweens.set(name+'CHAR$iteration ${colArray[i]}',FlxTween.num(0, cols[i], entry[2], {onComplete: CoolUtil.removeType(TWEEN, name+'CHAR$iteration ${colArray[i]}')}, num -> {
                        updateShaders(j, i, num);
                    }));
                }
            }
        } else {
            for (j in 0...entry[1].length) {
                for(i in 0...5) {
                    var thisCol = FlxColor.fromInt(entry[1][j]);
                    var cols = [thisCol.redFloat, thisCol.greenFloat, thisCol.blueFloat, 1];
                    updateShaders(j, i, cols[i]);
                }
            }
        }
    }

    public static function updateShaders(shader:Int, index:Int, val:Float) {
            shaders[shader].target.value[index] = val;
    }
}

/*class DiffUtils {
    public static function brightness() {
        var oldColBG:FlxColor;
        var oldColBF:FlxColor;
        var oldColDad:FlxColor;
        var oldColGF:FlxColor;
        trace(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][1][0]);
        trace(FlxColor.fromInt(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][1][0]));
        trace('gay');
        if (ColorContrastEvent.initialized) {
            oldColBG = FlxColor.fromInt(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][1][0]);
            oldColBG.brightness = FlxMath.lerp(oldColBG.brightness, 1, 0.2);
            oldColBF = FlxColor.fromInt(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][1][1]);
            oldColBF.brightness = FlxMath.lerp(oldColBF.brightness, 1, 0.2);
            oldColDad = FlxColor.fromInt(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][1][2]);
            oldColDad.brightness = FlxMath.lerp(oldColDad.brightness, 1, 0.2);
            oldColGF = FlxColor.fromInt(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][1][3]);
            oldColGF.brightness = FlxMath.lerp(oldColGF.brightness, 1, 0.2);
        } else {
            oldColBG = 0xFFFFFFFF;
            oldColBF = 0xFF888888;
            oldColDad = 0xFF888888;
            oldColGF = 0xFFFFFFFF;
        }

        return [oldColBG.toHexString(), oldColBF.toHexString(), oldColDad.toHexString(), oldColGF.toHexString()];
    }

    public static function darkness() {
        var oldColBG:FlxColor;
        var oldColBF:FlxColor;
        var oldColDad:FlxColor;
        var oldColGF:FlxColor;
        if (ColorContrastEvent.initialized) {
            oldColBG = FlxColor.fromInt(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][2][0]);
            oldColBG.brightness = FlxMath.lerp(oldColBG.brightness, 0, 0.2);
            oldColBF = FlxColor.fromInt(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][2][1]);
            oldColBF.brightness = FlxMath.lerp(oldColBF.brightness, 0, 0.2);
            oldColDad = FlxColor.fromInt(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][2][2]);
            oldColDad.brightness = FlxMath.lerp(oldColDad.brightness, 0, 0.2);
            oldColGF = FlxColor.fromInt(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][2][3]);
            oldColGF.brightness = FlxMath.lerp(oldColGF.brightness, 0, 0.2);
        } else {
            oldColBG = 0xFFFFFFFF;
            oldColBF = 0xFF888888;
            oldColDad = 0xFF888888;
            oldColGF = 0xFFFFFFFF;
        }
        return [oldColBG.toHexString(), oldColBF.toHexString(), oldColDad.toHexString(), oldColGF.toHexString()];
    }

    public static function lightness() {
        var oldColBG:FlxColor;
        var oldColBF:FlxColor;
        var oldColDad:FlxColor;
        var oldColGF:FlxColor;
        if (ColorContrastEvent.initialized) {
            oldColBG = FlxColor.fromInt(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][2][0]);
            oldColBG.lightness = FlxMath.lerp(oldColBG.lightness, 1, 0.2);
            oldColBF = FlxColor.fromInt(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][2][1]);
            oldColBF.lightness = FlxMath.lerp(oldColBF.lightness, 1, 0.2);
            oldColDad = FlxColor.fromInt(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][2][2]);
            oldColDad.lightness = FlxMath.lerp(oldColDad.lightness, 1, 0.2);
            oldColGF = FlxColor.fromInt(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][2][3]);
            oldColGF.lightness = FlxMath.lerp(oldColGF.lightness, 1, 0.2);
        } else {
            oldColBG = 0xFFFFFFFF;
            oldColBF = 0xFF888888;
            oldColDad = 0xFF888888;
            oldColGF = 0xFFFFFFFF;
        }
        return [oldColBG.toHexString(), oldColBF.toHexString(), oldColDad.toHexString(), oldColGF.toHexString()];
    }

    public static function unlight() {
        var oldColBG:FlxColor;
        var oldColBF:FlxColor;
        var oldColDad:FlxColor;
        var oldColGF:FlxColor;
        if (ColorContrastEvent.initialized) {
            oldColBG = FlxColor.fromInt(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][2][0]);
            oldColBG.lightness = FlxMath.lerp(oldColBG.lightness, 0, 0.2);
            oldColBF = FlxColor.fromInt(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][2][1]);
            oldColBF.lightness = FlxMath.lerp(oldColBF.lightness, 0, 0.2);
            oldColDad = FlxColor.fromInt(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][2][2]);
            oldColDad.lightness = FlxMath.lerp(oldColDad.lightness, 0, 0.2);
            oldColGF = FlxColor.fromInt(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][2][3]);
            oldColGF.lightness = FlxMath.lerp(oldColGF.lightness, 0, 0.2);
        } else {
            oldColBG = 0xFFFFFFFF;
            oldColBF = 0xFF888888;
            oldColDad = 0xFF888888;
            oldColGF = 0xFFFFFFFF;
        }
        return [oldColBG.toHexString(), oldColBF.toHexString(), oldColDad.toHexString(), oldColGF.toHexString()];
    }

    public static function saturation() {
        var oldColBG:FlxColor;
        var oldColBF:FlxColor;
        var oldColDad:FlxColor;
        var oldColGF:FlxColor;
        if (ColorContrastEvent.initialized) {
            oldColBG = FlxColor.fromInt(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][2][0]);
            oldColBG.saturation = FlxMath.lerp(oldColBG.saturation, 1, 0.2);
            oldColBF = FlxColor.fromInt(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][2][1]);
            oldColBF.saturation = FlxMath.lerp(oldColBF.saturation, 1, 0.2);
            oldColDad = FlxColor.fromInt(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][2][2]);
            oldColDad.saturation = FlxMath.lerp(oldColDad.saturation, 1, 0.2);
            oldColGF = FlxColor.fromInt(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][2][3]);
            oldColGF.saturation = FlxMath.lerp(oldColGF.saturation, 1, 0.2);
        } else {
            oldColBG = 0xFFFFFFFF;
            oldColBF = 0xFF888888;
            oldColDad = 0xFF888888;
            oldColGF = 0xFFFFFFFF;
        }
        return [oldColBG.toHexString(), oldColBF.toHexString(), oldColDad.toHexString(), oldColGF.toHexString()];
    }

    public static function unsaturate() {
        var oldColBG:FlxColor;
        var oldColBF:FlxColor;
        var oldColDad:FlxColor;
        var oldColGF:FlxColor;
        if (ColorContrastEvent.initialized) {
            oldColBG = FlxColor.fromString(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][2][0]);
            oldColBG.saturation = FlxMath.lerp(oldColBG.saturation, 0, 0.2);
            oldColBF = FlxColor.fromString(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][2][1]);
            oldColBF.saturation = FlxMath.lerp(oldColBF.saturation, 0, 0.2);
            oldColDad = FlxColor.fromString(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][2][2]);
            oldColDad.saturation = FlxMath.lerp(oldColDad.saturation, 0, 0.2);
            oldColGF = FlxColor.fromString(ColorContrastEvent.colors[ColorContrastEvent.colors.length-1][2][3]);
            oldColGF.saturation = FlxMath.lerp(oldColGF.saturation, 0, 0.2);
        } else {
            oldColBG = 0xFFFFFFFF;
            oldColBF = 0xFF888888;
            oldColDad = 0xFF888888;
            oldColGF = 0xFFFFFFFF;
        }
        return [oldColBG.toHexString(), oldColBF.toHexString(), oldColDad.toHexString(), oldColGF.toHexString()];
    }
}*/
