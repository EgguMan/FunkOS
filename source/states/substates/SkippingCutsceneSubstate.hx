package states.substates;

import backend.GameplayEvents;
import flixel.effects.FlxFlicker;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import object.Funkin9Slice;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import object.*;

class SkippingCutsceneSubstate extends MusicBeatSubstate {

    var bg:FlxSprite;

    var prompt:Funkin9Slice;

    var texts:Array<Alphabet>;

    public static var opened:Bool = false;
    var canInput:Bool = false;

    var selected:Int = 0;
    var pointer:Alphabet;
    
    var header:Alphabet;

    override function create() { // create the graphics
        bg = new FlxSprite().makeGraphic(1280, 720, 0x55000000);
        bg.alpha = 0;
        add(setUI(bg));

        FlxG.sound.play(backend.Paths.sound('confirmMenu'));

        prompt = Funkin9Slice.giveSlice(0, 850, 450);
        prompt.scale.set(0.5, 0.5,);
        prompt.alpha = 0;
        add(setUI(prompt));
        

        texts = [];

        var text = new Alphabet(0, 0, 'YES', false); // theyre not animated but i dont care enough to fix it
        setUI(text);
        text.x -= 225;
        text.y += 75;
        text.alpha = 0;
        add(text);
        texts.push(text);

        var text = new Alphabet(0, 0, 'NO', false);
        setUI(text);
        text.x += 250;
        text.y += 75;
        text.alpha = 0;
        add(text);
        texts.push(text);

        pointer = new Alphabet(0, 0, '>');
        pointer.angle = 90;
        setUI(pointer);
        add(pointer);
        pointer.offset.x = -25;
        pointer.y += 50;
        pointer.alpha = 0;
        pointer.x = texts[0].getGraphicMidpoint().x;

        header = new Alphabet(0, 0, '', true);
        header.scale.set(1.5, 1.5);
        header.text = 'SKIP CUTSCENE?';
        header.alpha = 0;
        setUI(header);
        header.y -= 125;
        add(header);
        

        FlxTween.tween(bg, {alpha: 1}, 0.5);
        new FlxTimer().start(0.25, tmr -> {
            FlxTween.tween(prompt, {alpha: 1, "scale.x": 1}, 0.15, {ease:FlxEase.quadOut});
            FlxTween.tween(header, {alpha: 1}, 0.25, {ease:FlxEase.quadOut});
            FlxTween.tween(pointer, {alpha: 1}, 0.75);
            FlxTween.tween(prompt.scale, {y: 1}, 0.025, {ease:FlxEase.quadOut}); 
            for (i in 0...texts.length) {
                var obj = texts[i];
                new FlxTimer().start(0.15 + (i * 0.325), tmr -> {
                    FlxTween.tween(obj, {alpha:1}, 0.75, {ease:FlxEase.quintOut});
                });
            }
            new FlxTimer().start(1, tmr -> {
                canInput = true;
            });
        });

        super.create();

    }

    inline function setUI(obj:FlxSprite) { // just set an object to be on the UI
        obj.cameras = [PlayState.instance.camOther];
        obj.scrollFactor.set(0,0);
        obj.screenCenter();
        return obj;
    }

    override function update(e:Float) {
        if (canInput) {
            if (controls.UI_LEFT_P || FlxG.mouse.wheel == -1) {
                selected--;
                FlxG.sound.play(backend.Paths.sound('scrollMenu'));
            }
            if (controls.UI_RIGHT_P || FlxG.mouse.wheel == 1) {
                selected++;
                FlxG.sound.play(backend.Paths.sound('scrollMenu'));
            }
            if (selected > 1) {
                selected = 0;
            }
            if (selected < 0) {
                selected = 1;
            }
            pointer.x = texts[selected].getGraphicMidpoint().x;

            if (controls.ACCEPT || FlxG.mouse.justReleased) { // wether to skip da cutscene oder nein
                var flickerTime:Float = 1;
                if (PlayState.SONG.cutscene.fadeOnSkip) {
                    FlxG.sound.play(backend.Paths.sound('confirmMenu'));
                    flickerTime = PlayState.SONG.cutscene.fadeOutTime - (PlayState.SONG.cutscene.fadeOutTime/4);
                    if (selected == 0) {
                        PlayState.instance.skipCutscene();
                    }
                    FlxFlicker.flicker(texts[selected], flickerTime, 0.04, false);
                    new FlxTimer().start(flickerTime/4, tmr -> {
                        FlxTween.tween(this, {"bg.alpha":0, "prompt.alpha":0, "pointer.alpha":0, "header.alpha":0}, flickerTime - (flickerTime/4), {onComplete:tmr -> {
                            if (selected == 1) {
                                PlayState.instance.resumeCutscene();
                            }
                            close();
                        }});
                        trace(Math.floor(Math.abs(1-selected)));
                        FlxTween.tween(texts[Math.floor(Math.abs(1-selected))], {alpha:0}, flickerTime - (flickerTime/4));
                    });
                } else {
                        if (selected == 1) {
                            FlxG.sound.play(backend.Paths.sound('cancelMenu'));
                            PlayState.instance.resumeCutscene();
                        } else {
                            FlxG.sound.play(backend.Paths.sound('cancelMenu'));
                            PlayState.instance.skipCutscene();
                        }
                    close();
                }
                
                canInput = false;
            }
        }
    }
}