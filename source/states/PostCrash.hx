package states;

import flixel.addons.transition.FlxTransitionableState;
import data.WeekData;
import backend.chart.Song;
import backend.save.ClientPrefs;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.text.FlxText;

using StringTools;

class PostCrash extends MusicBeatState {

    final message:String = 'Do you really think this is over?';

    var texts:FlxSpriteGroup;
    var varience:Int = 3;

    override function create() {
        #if !noDesktop
        Main.instance.flxWindow.scaleX = 1;
        Main.instance.flxWindow.scaleY = 1;
        Main.instance.flxWindow.x = 0;
        Main.instance.flxWindow.y = 0;
        Main.instance.taskbar.visible = false;
        Main.instance.time.visible = false;
        for (i in Main.instance.taskbarIcons) {
            i.visible = false;
        }
        #end
        Main.fpsVar.visible = false;
        FlxG.fullscreen = true;
        trace('this');
        var spaces:String = '';
        var allSpaces:String = '';
        for (i in 0...message.length) {
            allSpaces+='  ';
        }
        texts = new FlxSpriteGroup();
        for (j in 0...message.split('').length) {
            var i = message.split('')[j];
            StringTools.ltrim(allSpaces);
            allSpaces = allSpaces.substring(0, allSpaces.length-2);
            var text = new FlxText(17*j, 0, FlxG.width-200, i);
            spaces+='  ';
            text.setFormat(Paths.font('segoe-ui.ttf'), 32-FlxG.random.int(-2, 2), 0xFF760000, CENTER);
            text.alpha = 0;
            texts.add(text);
        }
        texts.screenCenter();
        add(texts);
        new FlxTimer().start(1, tmr -> {
            for (i in 0...texts.members.length) {
                var text = texts.members[i];
                new FlxTimer().start(0.075*i, tmr -> {
                    FlxTween.tween(text, {alpha:1}, 0.75);
                });
            }
        });

        new FlxTimer().start(8, tmr -> {
            FlxTween.tween(this, {varience:0}, 2, {onComplete:twn -> {
                for (i in texts) {
                FlxTween.tween(i, {alpha:0}, 1);
                }
                new FlxTimer().start(1, tmr -> {
                    FlxG.sound.music.fadeOut(.8);
                });
                new FlxTimer().start(1.8, tmr -> {
                    loadSong();
                });
            }});
        });

        FlxG.sound.playMusic(Paths.sound('noise'), 0);
        FlxG.sound.music.fadeIn(2);

        FlxTransitionableState.skipNextTransIn = true;
        FlxTransitionableState.skipNextTransOut = true;
    }

    override function update(e:Float) {
        super.update(e);
        for (i in texts) {
            i.offset.set(FlxG.random.float(-1*varience, varience), FlxG.random.float(-1*varience, varience));
        }
    }
    
    function loadSong() {

			// Nevermind that's stupid lmao
			PlayState.storyPlaylist = ["(re)boot2"];

			var diffic = CoolUtil.getDifficultyFilePath(0);
			if(diffic == null) diffic = '';

			PlayState.storyDifficulty = 0;

			PlayState.SONG = backend.chart.Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0].toLowerCase());
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			LoadingState.loadAndSwitchState(new PlayState(), false, true);
    }
}