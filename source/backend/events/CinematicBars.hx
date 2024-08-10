package backend.events;

import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import states.PlayState;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;

class CinematicBars  {
    static var bar0:FlxSprite;
    static var bar1:FlxSprite;
    static var tween:FlxTween;

    public static var distances:Array<Array<Float>> = [];
    static var curVal:Int = 0;
    static var targetY:Float = 0;
    static var lastTarget:Float = 0;
    
    public static var initialized:Bool = false;

    public static function reset() {
        targetY = 0;
        lastTarget = 0;
        initialized = false;
    }

    public static function init() {
        if (!EventsCore.classes.contains(CinematicBars)) EventsCore.classes.push(CinematicBars);
        bar0 = new FlxSprite().makeGraphic(FlxG.width, Std.int(FlxG.height/2), 0xFF000000); // she Flx on my height until I have a Std on my int
        bar1 = bar0.clone();

        bar0.cameras = [PlayState.instance.camHUD];
        bar1.cameras = [PlayState.instance.camHUD];

        bar0.y = -(FlxG.height/2);
        bar1.y = FlxG.height;

        PlayState.instance.insert(PlayState.instance.members.indexOf(PlayState.instance.strumLineNotes), bar0);
        PlayState.instance.insert(PlayState.instance.members.indexOf(PlayState.instance.strumLineNotes), bar1);
        
        if (!GameplayEvents.GAME_UPDATE.has(update)) {
            GameplayEvents.GAME_UPDATE.add(update);
        }
    }

    public static function update(e:Float) {
        bar0.y = FlxG.height-targetY;
        bar1.y = (-(FlxG.height/2))+targetY;
    }

    public static function next() {
        trace('ja');
        var goTo = distances[curVal][0];
        var time = distances[curVal][1];
        trace(goTo == Math.NaN);
        if (goTo == -2763 || goTo == Math.NaN) {
            trace(targetY);
            if (lastTarget > 0) {
                goTo = 0;
            } else {
                goTo = 110;
            }
        }
        lastTarget = goTo;

        trace(goTo);
        trace(Std.isOfType(goTo, Float));


        tween = FlxTween.num(targetY, goTo, time, {ease:FlxEase.quadOut, onComplete: twn -> {
            PlayState.instance.runningTweens.remove('KinoEvent');
            GameplayEvents.GAME_UPDATE.remove(update);
        }}, v -> {
            targetY = v;
        });

        PlayState.instance.runningTweens.set('KinoEvent', tween);
        curVal++;
    }
}