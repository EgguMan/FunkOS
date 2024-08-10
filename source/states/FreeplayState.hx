package states;

import flixel.effects.FlxFlicker;
import backend.save.ClientPrefs;
import flixel.tweens.FlxTween;
import flixel.util.FlxSpriteUtil;
import haxe.Timer;
import flixel.util.FlxTimer;
import backend.Discord.DiscordClient;
import flixel.FlxG;
import flixel.input.mouse.FlxMouseEvent;
import backend.Highscore;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

class FreeplayState extends MusicBeatState {
    var blueBG:FlxSprite;
    var redBG:FlxSprite;
    var greenBG:FlxSprite;

    var bgs:FlxTypedGroup<FlxSprite>;
    var hitboxes:FlxTypedGroup<FlxSprite>;
    var censors:FlxTypedGroup<FlxSprite>;

    var icons:FlxSprite;

    var select:Int = 0;
    var flashSpr:FlxSprite;

    public static var been:Bool = false;
    override function create() {
		DiscordClient.iconType = 'icon';
        been = true;
        bgs = new FlxTypedGroup<FlxSprite>();
        hitboxes = new FlxTypedGroup<FlxSprite>();
        censors = new FlxTypedGroup<FlxSprite>();

        flashSpr = new FlxSprite().makeGraphic(1280,720,0xFFFFFFFF);
        flashSpr.screenCenter();
        flashSpr.blend = ADD;
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

        blueBG = new FlxSprite().loadGraphic(Paths.image('freeplay/BlueBG','ui'));
        blueBG.scale.set(0.66666666666,0.66666666666);
        blueBG.screenCenter();
        if (Highscore.songScores.exists('foreign-entity')) {
            var blueHitbox = new FlxSprite().loadGraphic(Paths.image('freeplay/HTIBOX_foreign','ui'));
            hitboxes.add(blueHitbox);
            FlxMouseEvent.add(blueHitbox, null, spr -> {clicked('foreign');}, spr -> {highlighted('foreign');}, null, false, true, true);
        } else {
            var censor = new FlxSprite().loadGraphic(Paths.image('freeplay/CENSOR_foreign','ui'));
            censors.add(censor);
        }

        if (Highscore.songScores.exists('(re)boot2')) {//lol
        //if (false) {
            redBG = new FlxSprite().loadGraphic(Paths.image('freeplay/RedBG','ui'));
            redBG.scale.set(0.66666666666,0.66666666666);
            redBG.screenCenter();
            bgs.add(redBG);
            redBG.visible = false;

            var redHitbox = new FlxSprite().loadGraphic(Paths.image('freeplay/HITBOX_virus','ui'));
            hitboxes.add(redHitbox);
            FlxMouseEvent.add(redHitbox, null, spr -> {clicked('virus');}, spr -> {highlighted('virus');}, null, false, true, true);
        } else {
            var censor = new FlxSprite().loadGraphic(Paths.image('freeplay/CENSOR_virus','ui'));
            censors.add(censor);
        }

        if (Highscore.songScores.exists('defender')) { // ??? lol???
        //if (false) {
            greenBG = new FlxSprite().loadGraphic(Paths.image('freeplay/GreenBG','ui'));
            greenBG.scale.set(0.66666666666,0.66666666666);
            greenBG.screenCenter();
            bgs.add(greenBG);
            greenBG.visible = false;

            var greenHitbox = new FlxSprite().loadGraphic(Paths.image('freeplay/HITBOX_defender','ui'));
            hitboxes.add(greenHitbox);
            FlxMouseEvent.add(greenHitbox, null, spr -> {clicked('defender');}, spr -> {highlighted('defender');}, null, false, true, true);
        } else {
            var censor = new FlxSprite().loadGraphic(Paths.image('freeplay/CENSOR_defender','ui'));
            censors.add(censor);
        }

        bgs.add(blueBG);


        icons = new FlxSprite();
        icons.frames = Paths.getSparrowAtlas('freeplay/icons', 'ui');

        icons.animation.addByPrefix('foreign','foreignEntity');
        icons.animation.addByPrefix('virus','virusMix');
        icons.animation.addByPrefix('defender','defenderMix');

        icons.animation.play('foreign');


        add(bgs);
        add(hitboxes);
        add(icons);
        add(censors);


        super.create();
    }

    public function highlighted(name:String) {
        icons.animation.play(name);
        switch (name) {
            case 'foreign':
                if (select != 1) {
                    FlxG.sound.play(backend.Paths.sound('scrollMenu'));
                    select = 1;
                }
                blueBG.visible = true;
                if (redBG != null) redBG.visible = false;
                if (greenBG != null) greenBG.visible = false;
            case 'virus':
                if (select != 2) {
                    FlxG.sound.play(backend.Paths.sound('scrollMenu'));
                    select = 2;
                }
                blueBG.visible = false;
                if (redBG != null) redBG.visible = true;
                if (greenBG != null) greenBG.visible = false;
            case 'defender':
                if (select != 3) {
                    FlxG.sound.play(backend.Paths.sound('scrollMenu'));
                    select = 3;
                }
                blueBG.visible = false;
                if (redBG != null) redBG.visible = false;
                if (greenBG != null) greenBG.visible = true;
        }
    }

    public function clicked(name:String) {
		FlxG.sound.play(backend.Paths.sound('confirmMenu'));

        var exclude:FlxSprite = hitboxes.members[0];
        if (hitboxes.length == 3) {
            exclude = hitboxes.members[select-1];
        } else if (hitboxes.length == 2 && select == 2) {
            exclude = hitboxes.members[1];
        }

        for (box in hitboxes) {
            if (box != exclude) {
                box.visible = false;
                FlxMouseEvent.remove(box);
            } 
        }


        if (ClientPrefs.flashing) add(flashSpr);

        FlxTween.tween(flashSpr, {alpha: 0}, 0.5);
        FlxTween.tween(icons, {alpha:0}, 0.65);

        if (ClientPrefs.flashing) FlxFlicker.flicker(exclude, 2, 0.06, false, false);

        FlxG.sound.music.fadeOut(1, 0);

        Timer.delay(() -> {
            switch (name) {
                case 'foreign':
                    play('Foreign-Entity');
                case 'virus':
                    play('(re)boot1');
                case 'defender':
                    play('Defender');
            }
        }, 1500);
    }

    function play(song:String) {
        PlayState.storyPlaylist = [song];

        var diffic = CoolUtil.getDifficultyFilePath(0);
        if(diffic == null) diffic = '';

        PlayState.storyDifficulty = 0;

        PlayState.SONG = backend.chart.Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0].toLowerCase());
        PlayState.campaignScore = 0;
        PlayState.campaignMisses = 0;
        LoadingState.loadAndSwitchState(new PlayState(), false, true);
    }

    override function update(e:Float) {
        super.update(e);
        if (controls.BACK || FlxG.mouse.justReleasedRight) {
            MusicBeatState.switchState(new states.MainMenuState());
        }
    }
}