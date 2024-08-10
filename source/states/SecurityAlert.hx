package states;

import haxe.Timer;
import flixel.tweens.FlxEase;
#if cpp
import hxvlc.flixel.FlxVideoSprite;
#end
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.input.mouse.FlxMouseEvent;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.FlxSprite;

class SecurityAlert extends MusicBeatState {
    var button1:FlxSprite;
    var button2:FlxSprite;
    var alert:FlxSprite;

    var scary:FlxSprite;
    override function create() {

        Paths.clearStoredMemory();
        Paths.clearUnusedMemory();

        Paths.sound('defenderSpawn','shared');
        Paths.sound('virusDeath','shared');

        Paths.sound('bloop','shared');

        FlxG.sound.music.stop();

        alert = new FlxSprite().loadGraphic(Paths.image('alert/alert', 'shared'));
        alert.scale.set(0.75, 0.75);
        alert.screenCenter();

        button1= new FlxSprite().loadGraphic(Paths.image('alert/yes', 'shared'));
        button1.scale.set(0.75, 0.75);
        button1.screenCenter();

        button2= new FlxSprite().loadGraphic(Paths.image('alert/no', 'shared'));
        button2.scale.set(0.75, 0.75);
        button2.screenCenter();
       
        scary = new FlxSprite().loadGraphic(Paths.image('alert/scary', 'shared'));
        scary.scale.set(0.5,0.5);
        scary.screenCenter();
        scary.alpha = 0.5;

        #if cpp
        var cutscene = new FlxVideoSprite(0,0);
        cutscene.antialiasing = true;
        cutscene.load(Paths.video('transformation'));
        add(cutscene);
        cutscene.bitmap.onEndReached.add(() -> {
            new FlxTimer().start(1, preStart);
            cutscene.visible = false;
        });
        cutscene.bitmap.onEncounteredError.add(str -> {
            trace('Error enountered: ' + str);
            start(null);
        });
        new FlxTimer().start(4, tmr -> {
            cutscene.play();
            cutscene.bitmap.volume = 700;
            cutscene.updateHitbox();
            cutscene.screenCenter();
            cutscene.x -= 640;
            cutscene.y -= 360;
        });
        var txt = new FlxText(0, 0, 0, 'i see what you\'re doing player.',32);
        txt.setFormat(Paths.font('segoe-ui.ttf'), 32, 0xFFFF0000, CENTER);
        txt.screenCenter();
        Timer.delay(() -> {
            add(txt);
            Timer.delay(() -> {txt.visible = false;}, 750);
        }, 500);
        #else 
        add(scary);
        add(button1);
        add(button2);
        add(alert);
        start(null);
        #end
        super.create();
    }

    public function preStart(tmr:FlxTimer) {
        scary.alpha = 0;
        button1.alpha = 0;
        button2.alpha = 0;
        alert.alpha = 0;

        add(scary);
        add(button1);
        add(button2);
        add(alert);

        alert.scale.y = 0;
        alert.scale.x = 0.9;

        FlxTween.tween(alert, {"scale.y":1, "scale.x":1, alpha:1}, 0.25, {ease:FlxEase.quadOut, onComplete:start});
    }

    public function start(twn:FlxTween) {
        scary.alpha = 1;
        button1.alpha = 1;
        button2.alpha = 1;
        
        FlxMouseEvent.add(button1, null, spr -> {press(true);},null,null,true,true);
        FlxMouseEvent.add(button2, null, spr -> {press(false);},null,null,true,true);
    }

    function press(yes:Bool) {
        FlxMouseEvent.remove(button1);
        FlxMouseEvent.remove(button2);

        if (!yes) {
            FlxG.sound.play(Paths.sound('cultist_laugh', 'shared')).onComplete = () -> {
                play('(re)boot1');
            }
        } else {
            scary.visible = false;
            startSounds();
        }

        button1.visible = false;
        button2.visible = false;
        FlxTween.tween(alert, {alpha:0},0.5);
        FlxTween.tween(scary, {alpha:0},0.75);
    }

    public static function play(song:String) {
        PlayState.storyPlaylist = [song];

        var diffic = CoolUtil.getDifficultyFilePath(0);
        if(diffic == null) diffic = '';

        PlayState.storyDifficulty = 0;

        PlayState.SONG = backend.chart.Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0].toLowerCase());
        PlayState.campaignScore = 0;
        PlayState.campaignMisses = 0;
        LoadingState.loadAndSwitchState(new PlayState(), false, true);
    }

    final texts:Array<String> = ['Target 1 - FunkWARE.exe eliminated.', 'Target 2 - Boyfriend.ONNX identified.'];

    function startSounds() {
        FlxG.sound.play(Paths.sound('defenderSpawn','shared')).onComplete = () -> {
            new FlxTimer().start(2, tmr -> {
                FlxG.sound.play(Paths.sound('virusDeath','shared')).onComplete = () -> {
                    new FlxTimer().start(0.5, tmr -> {startDialogue();});
                };
            });
        };
    }
    
    function startDialogue() {
        var text1 = new FlxText(0,0,0,texts[0], 16);
        text1.setFormat(Paths.font('vcr.ttf'), 32, 0xFF44FF00, CENTER, OUTLINE, 0xFF004D34);
        text1.borderSize = 2;
        text1.screenCenter();
        text1.y += 250;
        text1.text = '';
        add(text1);

        var spl = texts[0].split('');
        new FlxTimer().start(0.1, tmr -> {
            FlxG.sound.play(Paths.sound('bloop', 'shared'));
            text1.text += spl[tmr.elapsedLoops-1];
            if (tmr.loopsLeft == 0) new FlxTimer().start(1, tmr -> {
                new FlxTimer().start(0.1, tmr ->{
                    FlxG.sound.play(Paths.sound('bloop', 'shared'));
                    text1.text += spl[9+tmr.elapsedLoops];
                }, spl.length-10);
            });
        }, 10);

        var text2 = new FlxText(0,0,0,texts[1], 16);
        text2.setFormat(Paths.font('vcr.ttf'), 32, 0xFF44FF00, CENTER, OUTLINE, 0xFF004D34);
        text2.borderSize = 2;
        text2.screenCenter();
        text2.y += 300;
        text2.text = '';
        add(text2);

        var spl2 = texts[1].split('');
        new FlxTimer().start(7, tmr -> {
            new FlxTimer().start(0.1, tmr -> {
                FlxG.sound.play(Paths.sound('bloop', 'shared'));
                text2.text += spl2[tmr.elapsedLoops-1];
                if (tmr.loopsLeft == 0) new FlxTimer().start(1, tmr -> {
                    new FlxTimer().start(0.1, tmr ->{
                        FlxG.sound.play(Paths.sound('bloop', 'shared'));
                        text2.text += spl2[9+tmr.elapsedLoops];
                        if (9+tmr.elapsedLoops == spl2.length-1) {
                            new FlxTimer().start(3, tmr -> {
                                FlxTween.tween(text1, {alpha:0},3);
                                FlxTween.tween(text2, {alpha:0},3);
                                new FlxTimer().start(4, tmr -> {
                                    play('Defender');
                                });
                            });
                        }
                    }, spl2.length-10);
                });
            }, 10);
        });
    }
}