package backend.events;

import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText;
#if sys
import sys.io.File;
#end
import openfl.Assets;
import states.PlayState;
import flixel.math.FlxMath;
import flixel.util.FlxGradient;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import haxe.Json;
import backend.Paths;

using StringTools;

typedef CreditsDetails = {
    header:String,
    textFormatting:CreditTextFormat,
    credits:Array<Credit>,
    persistTime:Float
}

typedef CreditTextFormat = {
    sizeName:Int,
    sizeDesc:Int,
    font:String,
    mainColor:String,
    strokeColor:String,
    align:FlxTextAlign,
    bgCol:String,
    width:Int
}

typedef Credit = {
    name:String,
    description:String,
    icon:String,
    iconOffset:Array<Float>
}

class CreditsEvent {
    public static var initialized:Bool = false;

    static var credits:CreditsDetails = null;
    static var creditDisplayGroup:FlxSpriteGroup;

    static var simpleCredits:Bool = false;

    static var moveTime:Float = 0.5;
    static var tweens:Array<FlxTween> = [];

    static var blackBacker:FlxSprite = null;

    public static function reset() {
        if (initialized) {
            trace('creds reset... ur just insane');
    
            if (PlayState.instance.runningTimers.exists('creditDelayTimer')) {
                PlayState.instance.runningTimers.get('creditDelayTimer').cancel();
            }
            
            creditDisplayGroup.forEach(spr -> {
                spr.kill();
                creditDisplayGroup.remove(spr);
            });
            PlayState.instance.remove(creditDisplayGroup);
    
            for (t in tweens) t.cancel;
    
            credits = null;
            simpleCredits = false;
            if (blackBacker != null) blackBacker.kill();
        }
        initialized = false;
    }


    public static function init(time:Float) {
        if (!EventsCore.classes.contains(CreditsEvent)) EventsCore.classes.push(CreditsEvent);
        initialized = true;
        moveTime = time;

        var path = PlayState.SONG.song;
        var formattedFolder:String = backend.Paths.formatToSongPath(path) + CoolUtil.getDifficultyFilePath();
        var formattedSong:String = backend.Paths.formatToSongPath(path);
        #if sys
        trace(backend.Paths.json(formattedFolder + '/credits'));
        var rawJson = File.getContent(backend.Paths.json(formattedFolder + '/credits')).trim();
        #else
        var rawJson = Assets.getText(backend.Paths.json(formattedFolder + '/credits')).trim();
        #end

        credits = Json.parse(rawJson);

        creditDisplayGroup = new FlxSpriteGroup();
        
        var prevHeight:Float = 0;
        if (credits.credits.length <=9) {
            for (credit in credits.credits) {
                var obj = new CreditObject(credit, credits.textFormatting, false);
                obj.centerOrigin();
                obj.screenCenter(X);
                creditDisplayGroup.add(obj);
                obj.y = 0-(250+(prevHeight*2));
                prevHeight += obj.height+5;
                if (((credits.credits.lastIndexOf(credit)+1)%3)==0) prevHeight=0;
            }
    
            for (i in 0...creditDisplayGroup.length) {
                var member = creditDisplayGroup.members[i];
                var lim = 4;
                if ((i%6)==0) lim = 3;
                var mult:Float = Math.floor((i+1)/lim);
                mult *= 2;
                member.x -= credits.textFormatting.width*mult;
                if (((Math.floor(creditDisplayGroup.length/3))%2) == 0) member.x += credits.textFormatting.width;
                else if (((Math.floor(creditDisplayGroup.length/3))%3) == 0) member.x += credits.textFormatting.width*2;
            }
        } else { // now its time to get simple
            simpleCredits = true;
            var maxAxes:FlxPoint = new FlxPoint(0,0);
            for (credit in credits.credits) {
                var obj = new CreditObject(credit, credits.textFormatting, true);
                creditDisplayGroup.add(obj);
                maxAxes.y = Std.int(Math.max(maxAxes.y, obj.height));
                maxAxes.x = Std.int(Math.max(maxAxes.x, obj.width));
            }

            maxAxes.y *= 10;

            for (obj in creditDisplayGroup.members) {
                obj.y -= 100 + (maxAxes.y*(creditDisplayGroup.members.lastIndexOf(obj)/(creditDisplayGroup.length-1)));
                obj.x = (FlxG.width/2)-(obj.width/2);
            }

            var col = FlxColor.fromString(credits.textFormatting.strokeColor);
            col.alpha = 127;
            blackBacker = new FlxSprite().makeGraphic(Std.int(maxAxes.x*1.05), 1280, col);
            blackBacker.cameras = [PlayState.instance.camHUD];
            blackBacker.screenCenter(X);
            blackBacker.y = -1280;
        }
        

        var thisArray:Array<CreditObject> = [];
        
        creditDisplayGroup.cameras = [PlayState.instance.camHUD];
    }

    public static function showCredits() {
        if (simpleCredits) {
            PlayState.instance.add(blackBacker);
        }
        PlayState.instance.add(creditDisplayGroup);
        if (!simpleCredits) {
            var prevHeight:Float = 0;
            for (i in 0...creditDisplayGroup.length) {
                var member = creditDisplayGroup.members[i];
                var name:String = 'creditTweenIn$i';
                var curTween:FlxTween;
                curTween = FlxTween.tween(member, {y:250+prevHeight}, moveTime+(0.05*(Math.abs(i-creditDisplayGroup.members.length))), {ease:FlxEase.smootherStepOut, onComplete:CoolUtil.removeType(TWEEN, name, () -> {tweens.remove(curTween);})});
                tweens.push(curTween);
                PlayState.instance.runningTweens.set(name, curTween);            
                prevHeight += member.height+5;
                if (((i+1)%3)==0) prevHeight=0;
            }
    
            var curTimer = new FlxTimer();
            PlayState.instance.runningTimers.set('creditDelayTimer', curTimer);
            curTimer.start(credits.persistTime + moveTime, tmr -> {
                CoolUtil.removeType(TIMER, 'creditDelayTimer');
                for (i in 0...creditDisplayGroup.length) {
                    var name:String = 'creditTweenOut$i';
                    var member = creditDisplayGroup.members[i];
                    var curTween:FlxTween;
                    curTween =  FlxTween.tween(member, {y:1280+prevHeight+5}, moveTime+(0.05*(Math.abs(i-creditDisplayGroup.members.length))), {ease:FlxEase.smootherStepIn, onComplete:CoolUtil.removeType(TWEEN, name, () -> {tweens.remove(curTween);})});
                    tweens.push(curTween);
                    PlayState.instance.runningTweens.set(name, curTween);
                }
            });
        } else {
            var secondTween:FlxTween;
            var name2 = 'creditBackingTweenIn';
            secondTween = FlxTween.tween(blackBacker, {y:0}, moveTime, {ease:FlxEase.circOut, onComplete:CoolUtil.removeType(TWEEN, name2, () -> {
                var curTween:FlxTween;
                var name = 'creditTweenIn';
                tweens.remove(secondTween);
                creditDisplayGroup.centerOrigin();
                curTween = FlxTween.tween(creditDisplayGroup, {y:1300+creditDisplayGroup.frameHeight}, credits.persistTime, {onComplete:CoolUtil.removeType(TWEEN, name, () -> {
                    tweens.remove(curTween);
                    trace('hi');
                    var anotherTween:FlxTween;
                    var name3 = 'creditBackingTweenOut';
                    anotherTween = FlxTween.tween(blackBacker, {y:1280}, moveTime, {ease:FlxEase.circIn, onComplete:CoolUtil.removeType(TWEEN, name3, () -> {tweens.remove(anotherTween);})});
                    tweens.push(anotherTween);
                    PlayState.instance.runningTweens.set(name3, anotherTween);
                })});
                tweens.push(curTween);
                PlayState.instance.runningTweens.set(name, curTween);
            })});
            tweens.push(secondTween);
            PlayState.instance.runningTweens.set(name2, secondTween);
        }
    }
    
}

class CreditObject extends FlxTypedSpriteGroup<FlxSprite> {
    var iconSpr:FlxSprite;
    var nameText:FlxText;
    var descText:FlxText;

    var font:String;

    public function new(credit:Credit, format:CreditTextFormat, simple:Bool) {
        super();
        var name = credit.name;
        var icon = credit.icon;
        var desc = credit.description;
        iconSpr = new FlxSprite().loadGraphic(backend.Paths.image('credits/icons/$icon', 'ui'));
        if (format.font == 'ui') format.font = Paths.uiFont;
        if (!simple) {
            var backing:FlxSprite = new FlxSprite();
            add(backing);
            iconSpr.setGraphicSize(iconSpr.width / Math.min(iconSpr.height/75, iconSpr.width/75), iconSpr.height / Math.min(iconSpr.height/75, iconSpr.width/75));
            iconSpr.updateHitbox();
            iconSpr.updateFramePixels();
            if (format.font != 'alphabet') {
                nameText = new FlxText(0,0, format.width, name, format.sizeName);
                nameText.setFormat(format.font, format.sizeName, Std.parseInt(format.mainColor), format.align, OUTLINE_FAST, Std.parseInt(format.strokeColor));
                add(nameText);
    
                descText = new FlxText(0, nameText.height + 5, format.width, desc, format.sizeDesc);
                descText.setFormat(format.font, format.sizeDesc, Std.parseInt(format.mainColor), format.align, OUTLINE_FAST, Std.parseInt(format.strokeColor));
                add(descText);
            } else { // will do one day
    
            }
            add(iconSpr);
            if (format.align == RIGHT) {
                iconSpr.x = format.width;
            } else {
                iconSpr.x = nameText.textField.width;
            }
    
            backing.makeGraphic(Math.floor(this.width + 5), Math.floor(this.height+5), Std.parseInt(format.bgCol));
            backing.x -= 5;
            backing.y -= 5;
        } else {
            iconSpr.setGraphicSize(iconSpr.width / Math.min(iconSpr.height/45, iconSpr.width/45), iconSpr.height / Math.min(iconSpr.height/45, iconSpr.width/45));
            iconSpr.updateHitbox();
            iconSpr.updateFramePixels();
            nameText = new FlxText(0,0, 0, name + ' - ' + desc, Std.int(format.sizeName/2));
            nameText.setFormat(format.font, Std.int(format.sizeName/2), Std.parseInt(format.mainColor), CENTER, OUTLINE_FAST, Std.parseInt(format.strokeColor));
            iconSpr.x = nameText.textField.width + (iconSpr.width/2) + 5;
            add(nameText);
            add(iconSpr);
        }
        iconSpr.offset.set(credit.iconOffset[0], credit.iconOffset[1]);
    }
}