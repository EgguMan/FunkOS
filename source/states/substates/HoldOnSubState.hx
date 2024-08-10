package states.substates;

import flixel.FlxG;
import object.Alphabet;
import flixel.util.FlxTimer;
import backend.save.ClientPrefs;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;

class HoldOnSubState extends MusicBeatSubstate {

    var bg:FlxSprite;
    var canInput:Bool = false;

    override function create() {
        bg = new FlxSprite().makeGraphic(1280,720, 0xFF000000);
        bg.alpha = 0;
        add(bg);
        bg.scrollFactor.set(0,0);

        var text = new Alphabet(0,0,'HOLD ON THERE!',true);
        text.alpha = 0;
        text.screenCenter();
        text.scrollFactor.set(0,0);

        var blurb = new FlxText(0, 0, 0, ' \nYou havent checked out the settings yet.\nIt is reccomended you do so before playing!\nPress [${ClientPrefs.keyBinds.get('accept')[1]}] to continue, or press [${ClientPrefs.keyBinds.get('back')[0]}] to escape.' #if noDesktop + '\nOh also you cant go back to the desktop after you enter.' #end );
        blurb.setFormat(Paths.font('vcr.ttf'), 32, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
        blurb.screenCenter();
        blurb.y += 100;
        blurb.alpha = 0;
        blurb.scrollFactor.set(0,0);

        FlxTween.tween(bg, {alpha:0.25},0.75);
        FlxTween.tween(blurb, {alpha:1},0.75);
        FlxTween.tween(text, {alpha:1},0.75);
        new FlxTimer().start(1.5, tmr -> {
            canInput = true;
        });
        add(text);
        add(blurb);
        super.create();
        
    }

    override function update(e:Float) {
        super.update(e);
        if (canInput) {
            if (controls.ACCEPT) {
                goToStoryMode();
            } else if (controls.BACK) {
                close();
                MusicBeatState.switchState(new states.MainMenuState());
            }
        }
    }

    public static function goToStoryMode() {
        MusicBeatState.switchState(new IntroCutscene());
    }
}