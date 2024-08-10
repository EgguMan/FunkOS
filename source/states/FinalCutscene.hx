package states;

import flixel.FlxG;
import flixel.util.FlxTimer;
#if cpp
import hxvlc.flixel.FlxVideoSprite;
#end

class FinalCutscene extends MusicBeatState {
    public static var type:String = 'DEFENDER';

    #if cpp
    var cutscene:FlxVideoSprite;
    #end

    override function create() {
        #if cpp
        cutscene = new FlxVideoSprite(0,0);
        cutscene.antialiasing = true;
        cutscene.load(Paths.video('outro_'+type.toUpperCase()));
        add(cutscene);
        cutscene.bitmap.onEndReached.add(() -> {
            new FlxTimer().start(1 , start);
            cutscene.visible = false;
        });
        cutscene.bitmap.onEncounteredError.add(str -> {
            trace('Error enountered: ' + str);
            start(null);
        });
        new FlxTimer().start(4, tmr -> {
            cutscene.play();
            cutscene.updateHitbox();
            cutscene.screenCenter();
            cutscene.x -= 640;
            cutscene.y -= 360;
        });
        #else
        start(null);
        #end
        
        super.create();
    }
    
    public function start(tmr:FlxTimer) {
        MusicBeatState.switchState(new MainMenuState());
        FlxG.sound.playMusic(backend.Paths.music('freakyMenu'));
    }
}