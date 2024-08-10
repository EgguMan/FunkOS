package backend.events;

import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteContainer;
import flixel.group.FlxContainer;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.FlxG;
import states.PlayState;
import flixel.util.FlxTimer;
import object.Alphabet;

using StringTools;

typedef TextData = {
    font:String,
    width:Int, 
    mainColor:Int,
    borderColor:Int,
    scale:Int,
    introTime:Float,
    persistTime:Float
} 

class SubtitleEvent {

    static var subtitleGroup:FlxSpriteContainer; //ooo neue feature
    static var times:Array<Array<Float>> = [];
    static var iteration:Int = 0;

    public static function reset() {
        subtitleGroup.forEachAlive(spr -> {spr.kill();});
        subtitleGroup.kill();
        times = [];
        trace('reset');
        iteration = 0;
    }
    
    public static function queue(text:String, textData:TextData) {
        if (!EventsCore.classes.contains(SubtitleEvent)) {
            EventsCore.classes.push(SubtitleEvent);
            subtitleGroup = new FlxSpriteContainer();
            PlayState.instance.add(subtitleGroup);
        }

        var thisText = new FlxText(0,0, textData.width, text, textData.scale);
        thisText.setFormat(textData.font, textData.scale, textData.mainColor, CENTER, OUTLINE_FAST, textData.borderColor);
        thisText.alpha = 0;
        thisText.screenCenter();
        thisText.y = 575-thisText.fieldHeight;
        subtitleGroup.add(thisText);
        times.push([textData.persistTime, textData.introTime]);
        subtitleGroup.cameras = [PlayState.instance.camHUD];
    }

    public static function nextTitle() {
        var time = times[0][0] + times[0][1];
        var timeOut:Float = times[0][1];
        var member = subtitleGroup.members[iteration];
        iteration++;
        var tweenName:String = time + ' tween event thingy sub';
        trace(iteration);
        trace(subtitleGroup.members);
        if (timeOut != 0) {
            member.y += 50;
            PlayState.instance.runningTweens.set(tweenName, FlxTween.tween(member, {alpha:1, y:member.y - 50}, timeOut, {onComplete:CoolUtil.removeType(TWEEN, tweenName), ease:FlxEase.smootherStepOut}));
        } else {
            member.alpha = 1;
        }

        var name:String = time + ' $subtitleGroup event';

        PlayState.instance.runningTimers.set(name, new FlxTimer().start(time, tmr -> {
            if (timeOut != 0) {
                tweenName += 'out';
                PlayState.instance.runningTweens.set(tweenName, FlxTween.tween(member, {alpha:0, y:member.y + 25}, timeOut/2, {onComplete:CoolUtil.removeType(TWEEN, tweenName, () -> {onComplete(member);}), ease:FlxEase.smootherStepOut}));
            } else {
                member.alpha = 0;
                onComplete(member);
            }

            PlayState.instance.runningTimers.remove(name);
        }));
    }

    static function onComplete(member:FlxSprite) {
        member.kill();
        times.shift();
    }
}