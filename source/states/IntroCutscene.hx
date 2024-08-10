package states;

import flixel.FlxG;
import flixel.util.FlxTimer;
#if cpp
import hxvlc.flixel.FlxVideoSprite;
#end

class IntroCutscene extends MusicBeatState {
    #if cpp
    var cutscene:FlxVideoSprite;
    #end

    override function create() {
        #if cpp
        cutscene = new FlxVideoSprite(0,0);
        cutscene.load(Paths.video('intro'));
        add(cutscene);
        cutscene.bitmap.onEndReached.add(() -> {
            new FlxTimer().start(1 , goToStoryMode); // using the engine's cutscene system lead to bugs. i'll need to patch those, so for now i'll use this
            cutscene.visible = false;
        });
        cutscene.bitmap.onEncounteredError.add(str -> {
            trace('Error enountered: ' + str);
            goToStoryMode(null);
        });
        FlxG.sound.music.fadeOut(1, 0);
        new FlxTimer().start(2, tmr -> {
            cutscene.play();
            cutscene.updateHitbox();
            cutscene.screenCenter();
            cutscene.x -= 640;
            cutscene.y -= 360;
        });
        #else
        goToStoryMode(null);
        #end
        
        super.create();
    }
    
    public static function goToStoryMode(tmr:FlxTimer) {
        PlayState.storyPlaylist = ["Foreign-Entity"];

        var diffic = CoolUtil.getDifficultyFilePath(0);
        if(diffic == null) diffic = '';

        PlayState.storyDifficulty = 0;

        PlayState.SONG = backend.chart.Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0].toLowerCase());
        PlayState.campaignScore = 0;
        PlayState.campaignMisses = 0;
        LoadingState.loadAndSwitchState(new PlayState(), false, true);
    }
}