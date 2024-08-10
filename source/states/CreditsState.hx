package states;

import flixel.FlxObject;
import flixel.graphics.FlxGraphic;
import backend.MouseHandler;
import flixel.util.FlxTimer;
import openfl.filters.GlowFilter;
import flixel.util.FlxColor;
#if sys
import sys.FileSystem;
#end
import flixel.util.FlxSpriteUtil;
import flixel.input.mouse.FlxMouseEvent;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import data.*;
import object.*;
import shaders.*;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class CreditsState extends MusicBeatState {
    static var curSelected:Int = 0;
    static var lastSelected:Int = 0;
    var items:FlxSpriteGroup;
    static final credits:Array<Array<Dynamic>> = [
        ['FunkOS Team'],
        ['Eggu',                    'Programmer, Sprite Animator',              'Free Palestine',                                                                                                                                                                                                                                                                                                                                'assets/fonts/valorax.otf'],
        ['Otrees',                  'Artist, Cutscene animator',                'Free Palestine',                                                                                                                                                                                                                                                                                                                               backend.Paths.uiFont],
        ['Nasa',                    'BG Artist, Musician, Charter',             '',                                                                                                                                                                                                                                                                                                                                             backend.Paths.uiFont],
        ['Koi',                     'Sprite Artist, Musician',                  '“hey ignore everyone else on this list go check out my youtube and The Escape”',                                                                                                                                                                                                                                                               'assets/fonts/Mont-Heavy.otf'],
        ['Aero Engine Team'],
        //Name                      Job,                                        title,                                                                                                                                                                                                                                                                                                                                              font
        ['Eggu',                    'Creator of Aero Engine',                   'Whats up, im eggu. Im the lead dev for this engine, doing 90% of the new code, doing the directing, you get it! Thanks for checking the engine out! I hope you like it, and if you find a bug or would like a fearture added feel free to DM. Anyways, i\'ve got a stage builder to make, so i\'ll see you guys in 2.0!',                      'assets/fonts/valorax.otf'],
        ['SnoWave',                 'Main Artist, Assistant programmer,\nProducer of "Demo"','X',                                                                                                                                                                                                                                                                                                                                backend.Paths.uiFont],
        ['Kn1ghtNight',             'Quality Assurance',                       'X',                                                                                                                                                                                                                                                                                                                                              backend.Paths.uiFont],
        ['AlWasHere',               'Quality Assurance',                       'X',                                                                                                                                                                                                                                                                                                                                              backend.Paths.uiFont],
        ['Rend',                    'Quality Assurance, Pico BGSprite',        'X',                                                                                                                                                                                                                                                                                                                                              backend.Paths.uiFont],
        ['KawaiiMochaOra',          'Quality Assurance, art',                  'Silly creature being up to mischief',                                                                                                                                                                                                                                                                                                           'assets/fonts/roman.ttf'],
        ['SRingo',                  'Quality Assurance',                        'i can type the silly code',                                                                                                                                                                                                                                                                                                                    'assets/fonts/orbitron-bold.otf'],
        ['Flezard',                 'Quality Assurance',                        "Hi! I'm Flezard, a LUA coder and a Charter! I work on multiple projects, and you can learn more about me by checking out my Carrd (the first button below)! If you want to contact me, use discord because I don't use the other socials much lol. Thank you for reading this! (Portrait by @ya_mari_6363 on Twitter)",                        'assets/fonts/omori.ttf'],
        ['Aero Engine Contributors'],
        ['MAJigsaw77',              'Developer of HXVlc',                       '',backend.Paths.uiFont],
        ['Psych Engine Credits'],
        ['Shadow Mario',            'Main Programmer of Psych Enginem',         '',backend.Paths.uiFont],
        ['RiverOaken',              'Main Artist/Animator of Psych Engine',     '',backend.Paths.uiFont],
        ['Shubs',                   'Additional Programmer of Psych Engine',    '',backend.Paths.uiFont],
        ['Former Psych Members'],
        ['bb-panzu',                'Ex-Programmer of Psych Engine',            '',backend.Paths.uiFont],
        ['Psych Contributors'],
        ['iFlicky',                 'Composer of Psync and Tea Time.\nMade the Dialogue Sounds','',backend.Paths.uiFont],
        ['SqirraRNG',               'Crash Handler and Base code for\nChart Editor\'s Waveform','',backend.Paths.uiFont],
        ['KadeDev','Fixed some cool stuff on Chart Editor\nand other PRs',                  '',backend.Paths.uiFont],
        ['Keoiki','Note Splash Animations','',backend.Paths.uiFont],
        ['Funkin\' Crew'],
        ['ninjamuffin99','Programmer of Friday Night Funkin\'','',backend.Paths.uiFont],
        ['PhantomArcade','Animator of Friday Night Funkin\'','',backend.Paths.uiFont],
        ['evilsk8r','Artist of Friday Night Funkin\'','',backend.Paths.uiFont],
        ['kawaisprite','Composer of Friday Night Funkin\'','',backend.Paths.uiFont]
        

    ];

    var links:Array<Array<Link>> = [ //haxe doesnt like iterating dynamic vals, so this is needed.
        [],
        [new Link('twitter', 'https://twitter.com/IAmEggu'), new Link('discord', 'https://discord.com/users/302234192715055104'), new Link('github', 'https://github.com/EgguMan')],
        [new Link('twitter', 'https://twitter.com/artrees17')],
        [new Link('twitter', 'https://twitter.com/nasadotexe'), new Link('youtube', 'https://www.youtube.com/channel/UCzC6yxh1PMxWrgpt7J8cO7g'), new Link('spotify', 'https://open.spotify.com/user/31ezoltdhro7btpjphy2pr4ore3u')],
        [new Link('twitter', 'https://twitter.com/toasted_milk_'), new Link('youtube', 'https://www.youtube.com/channel/UCTFzlP7utEEXQmQZ-ztklOg'), new Link('github', 'https://github.com/toasted-milk')],
        [],
        [new Link('twitter', 'https://twitter.com/IAmEggu'), new Link('discord', 'https://discord.com/users/302234192715055104'), new Link('github', 'https://github.com/EgguMan')],
        [new Link('youtube', 'https://www.youtube.com/channel/UCJqKo-VfoDjuJ6qtsIh0gCA'), new Link('github', 'https://github.com/SnoWaveDEV')],
        [new Link('twitter', 'https://twitter.com/Kn1ghtDev'), new Link('github', 'https://github.com/Kn1ghtNight'), new Link('youtube', 'https://www.youtube.com/channel/UC71wRHwKOPhMP0IfSGCWdsg')],
        [new Link('twitter', 'https://twitter.com/SpookyLags')],
        [new Link('twitter', 'https://twitter.com/Rend_mpeglol')],
        [new Link('twitter', 'https://twitter.com/kawaiimochiora'), new Link('youtube', 'https://www.youtube.com/channel/UCxrMHn2hIiD8WAfEgQnKK2A')],
        [new Link('twitter', 'https://twitter.com/SRingo__'), new Link('github','https://github.com/SonicRing'), new Link('youtube','https://www.youtube.com/@SonicRingo/featured'), new Link('newgrounds','https://sringo.newgrounds.com/'), new Link('gamejolt', 'https://gamejolt.com/@Sonic_Ring')],
        [new Link('twitter', 'https://twitter.com/New_Soup_Flez_U'), new Link('youtube', 'https://www.youtube.com/channel/UCQp3NkhD9EXCuO05c0J9tZQ'), new Link('discord','https://discord.com/users/692805282673197136'), new Link('carrd', 'https://flezard.carrd.co/'), new Link('gamebanana', 'https://gamebanana.com/members/1743213')],
        [],
        [new Link('twitter','https://twitter.com/MAJigsaw77')],
        [],
        [new Link('twitter','https://twitter.com/Shadow_Mario_')],
        [new Link('twitter','https://twitter.com/RiverOaken')],
        [new Link('twitter','https://twitter.com/yoshubs')],
        [],
        [new Link('twitter','https://twitter.com/bbsub3')],
        [],
        [new Link('twitter','https://twitter.com/flicky_i')],
        [new Link('twitter','https://twitter.com/gedehari')],
        [new Link('twitter','https://twitter.com/kade0912')],
        [new Link('twitter','https://twitter.com/Keoiki_')],
        [],
        [new Link('tenor','https://tenor.com/view/epstein-one-piece-luffy-sanji-zoro-gif-8145927398779363650')],
        [new Link('twitter','https://twitter.com/PhantomArcade3K')],
        [new Link('twitter','https://twitter.com/evilsk8r')],
        [new Link('twitter','https://twitter.com/kawaisprite')]


    ];

    var scrollBar1:FlxSprite;
    var scrollBar2:FlxSprite;

    var draggingBar:Bool = false;
    var mouseOffset:Float = 0;

    var iteration:Float = 0;
    
    var title:FlxText;
    var portrait:FlxSprite;
    var desc:FlxText;
    var bio:FlxText;

    override function create() { // you couldnt get me to comment all of this if you tried
        var bg = new FlxSprite().loadGraphic(backend.Paths.image('menuBG'));
        bg.screenCenter();
        add(bg);
        items = new FlxSpriteGroup();

        for (i in 0...credits.length) {
            var text:Alphabet = null;
            if (credits[i].length < 2) {
                text = newText(credits[i][0], true);
                text.ID = i;
                items.add(text);
                for (i in 0...text.members.length) {
                    text.members[i].scale.set(0.75,0.75);
                    text.members[i].x -= 12.5*i;
                    text.members[i].y -= -50; //scaling alphabet normally sucks balls
                }
            } else {
                text = newText(credits[i][0]);
                var textGroup = new FlxSpriteGroup(50, 0);
                text.setPosition(0,0);
                var path:String = 'credits/icons/'+credits[i][0].toLowerCase();
                #if sys
                if (!FileSystem.exists('assets/ui/images/'+path+'.png')) {
                    path = 'credits/icons/unknown';
                }
                #else
                if (!OpenFlAssets.exists('assets/ui/images/'+path+'.png')) {
                    path ='credits/icons/unknown';
                }
                #end
                var icon = new AttachedSprite(path, null, 'ui');
                icon.sprTracker = text;
                icon.xAdd = text.width + 15;
                icon.yAdd = 45;
                icon.setGraphicSize(icon.width / Math.min(icon.height/75, icon.width/75), icon.height / Math.min(icon.height/75, icon.width/75));
                icon.updateHitbox();
                text.ID = i;
                items.add(text);
                add(icon);
            }
            var setY = ((i - 0)* (75*1.75))+360;
            var setX = ((-1*((Math.abs((0 - i)))*75)+75));
            text.y = setY;
            text.x = setX;
            text.alpha = 1 - (Math.abs(Math.max(0, i) - Math.min(0, i)) / (5));
        }

        scrollBar1 = new FlxSprite().loadGraphic(backend.Paths.image('credits/bar1', 'ui'));
        scrollBar1.screenCenter();
        add(scrollBar1);

        scrollBar2 = new FlxSprite().loadGraphic(backend.Paths.image('credits/bar2', 'ui'));
        scrollBar2.screenCenter();
        scrollBar2.y = scrollBar1.y + 15;
        add(scrollBar2);

        FlxMouseEvent.add(scrollBar2, spr -> {
            mouseOffset = scrollBar2.y-FlxG.mouse.y;
            draggingBar = true;
        }, spr -> {draggingBar = false;});

        /*for (i in 1...credits.length) {
            var debugDraw = new FlxSprite().makeGraphic(50,50,0x00FFFFFF);
            FlxSpriteUtil.drawCircle(debugDraw, 0, 0, 50, 0xFF0000);
            debugDraw.centerOrigin();
            debugDraw.screenCenter().x;
            debugDraw.y = scrollBar1.y + (scrollBar2.height/(credits.length-1))*i;
            add(debugDraw);
        }*/

        add(items);

        iteration =  scrollBar1.height/credits.length-1;

        title = new FlxText(0, 0, 750, credits[0][0], 64);
        title.setFormat(credits[curSelected][3], 64, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        title.screenCenter();
        title.x += 325;
        title.y += 25;
        add(title);
        title.visible = false;

        desc = new FlxText(0, 0, 800, credits[0][1], 28);
        desc.setFormat(backend.Paths.uiFont, 28, FlxColor.WHITE, CENTER, OUTLINE_FAST, FlxColor.BLACK);
        desc.screenCenter();
        desc.x += 325;
        desc.y += 75;
        add(desc);
        desc.visible = false;

        bio = new FlxText(0,0,600,credits[0][2], 23);
        bio.setFormat(backend.Paths.uiFont, 23, FlxColor.WHITE, CENTER, OUTLINE_FAST, FlxColor.BLACK);
        bio.screenCenter();
        bio.x += 325;
        bio.y = desc.textField.height + desc.y + 15;
        add(bio);
        bio.visible = false;

        for (i in credits) {
            backend.Paths.image('credits/portraits/'+i[0].toLowerCase(),'ui', true);
        }

        for (i in links) {
            for (lnk in i) {
                lnk.screenCenter();
                lnk.y += 315;
                var index = i.lastIndexOf(lnk);
                lnk.updateHitbox();
                var totalWidth = (i.length-1)*(lnk.width+5);
                lnk.x = (940 - totalWidth/2) + ((lnk.width+5) * index);
                add(lnk);
                lnk.visible = false;
                FlxMouseEvent.add(lnk, spr -> {lnk.pressed();}, spr -> {lnk.released(true);}, 
                #if AeroMouse 
                spr -> {MouseHandler.setGraphic('finger');} 
                #else 
                null 
                #end, 
                spr -> {lnk.released(false);});
            }
        }

        portrait = new FlxSprite().loadGraphic(backend.Paths.image('credits/portraits/'+credits[0][0].toLowerCase(),'ui',true));
        portrait.centerOrigin();
        portrait.y = title.getGraphicMidpoint().y - 250;
        portrait.x = title.getGraphicMidpoint().x;
        portrait.visible = false;

        backend.Paths.getSparrowAtlas('credits/button', 'ui');

        add(portrait);

        super.create();
    }

    override function update(e:Float) {
        /*items.forEach(spr -> {
            var setY = (( spr.ID - curSelected)* (75*1.75))+360;
            var setX = ((-1*((Math.abs((curSelected - spr.ID)))*75)+75));
            spr.y = FlxMath.lerp(spr.y, setY, e*10);
            spr.x = FlxMath.lerp(spr.x, setX, e*10);
            spr.alpha = 1 - (Math.abs(Math.max(curSelected, spr.ID) - Math.min(curSelected, spr.ID)) / (5));
        });*/
        for (i in Std.int(Math.max(curSelected-7, 0))...Std.int(Math.min(credits.length, curSelected+9))) {
            var spr = items.members[i];
            var alphaSet = 1 - (Math.abs(Math.max(curSelected, spr.ID) - Math.min(curSelected, spr.ID)) / (5));
            if (i < curSelected-4 || i > curSelected+5) {
                var setY = (( spr.ID - curSelected)* (75*1.75))+300;
                var setX = ((-1*((Math.abs((curSelected - spr.ID)))*75)+75));
                spr.y = setY;
                spr.x = setX;
            } else {
                var setY = (( spr.ID - curSelected)* (75*1.75))+300;
                var setX = ((-1*((Math.abs((curSelected - spr.ID)))*75)+75));
                spr.y = FlxMath.lerp(spr.y, setY, e*10);
                spr.x = FlxMath.lerp(spr.x, setX, e*10);
            }
            if (credits[spr.ID].length < 2 && spr.ID != curSelected) 
                spr.alpha = FlxMath.lerp(spr.alpha, alphaSet-0.65, e*15);
            else 
                spr.alpha = FlxMath.lerp(spr.alpha, alphaSet-0.1, e*15);
            

        }

        if (controls.BACK || FlxG.mouse.justPressedRight) {
            FlxMouseEvent.remove(scrollBar2);
            for (i in credits) {
                for (credit in i) {
                    if (Std.isOfType(credit, FlxObject)) { // hashlink :3
                        FlxMouseEvent.remove(credit);
                    }
                }
            }
            FlxG.sound.play(backend.Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new states.MainMenuState());
        } else if (controls.UI_UP_P || controls.UI_DOWN_P || FlxG.mouse.wheel != 0) {
            lastSelected = curSelected;
            if (controls.UI_UP_P || FlxG.mouse.wheel == 1) {
                curSelected--;
            } else if (controls.UI_DOWN_P || FlxG.mouse.wheel == -1) {
                curSelected++;
            }

            if (curSelected == -1) {
                curSelected = 0;
            } else if (curSelected == credits.length) {
                curSelected = credits.length-1;
            }
            var itt = (scrollBar1.y) + ((iteration-5)*curSelected) + 15;
            scrollBar2.y = Math.max(scrollBar1.y + 15, Math.min(itt, 570));
            if (lastSelected != curSelected) {
                updateText();
            }
        }
        

        if (draggingBar) {
            if (FlxG.mouse.justReleased) {
                draggingBar = false;
            }
            scrollBar2.y = Math.max(scrollBar1.y + 15, Math.min(FlxG.mouse.y + mouseOffset, 570));

            for (i in 0...credits.length) { // the logic behind the scroll of wheel
                if (scrollBar2.getGraphicMidpoint().y < (iteration*i)+scrollBar1.y) {
                    lastSelected = curSelected;
                    curSelected = i;
                    if (lastSelected != curSelected) {
                        updateText();
                    }
                    break;
                }
            }
        }

        super.update(e);
    }

    static inline function newText(text:String, ?header:Bool = false) {
        return new Alphabet(50, 0, text, header);
    }

    public function updateText() {
        title.text = credits[curSelected][0];
        title.font = credits[curSelected][3];
        title.visible = credits[curSelected].length > 2;


        if (credits[curSelected].length > 2) {
            desc.text = credits[curSelected][1];
            desc.font = credits[curSelected][3];
        }
        desc.visible = credits[curSelected].length > 2;
        desc.updateHitbox();

        if (credits[curSelected].length > 2) {
            bio.text = credits[curSelected][2];
            bio.y = desc.textField.height + desc.y + 15;
        }
        bio.visible = credits[curSelected].length > 2;
        bio.updateHitbox();

        var graphic:FlxGraphic = null;
        #if sys
        if (FileSystem.exists('assets/ui/images/credits/portraits/'+credits[curSelected][0].toLowerCase()+'.png')){ // so Cmd doesnt explode with traces
        #else
        if (OpenFlAssets.exists('assets/ui/images/credits/portraits/'+credits[curSelected][0].toLowerCase()+'.png')){
        #end
            graphic = backend.Paths.image('credits/portraits/'+credits[curSelected][0].toLowerCase(),'ui');
            portrait.loadGraphic(graphic);
            portrait.setGraphicSize(300, 300);
            portrait.centerOrigin();
            portrait.screenCenter();
            portrait.y -= 175;
            portrait.x += 325;
        } 
        portrait.visible = credits[curSelected].length > 2 && (graphic != null);

        for (lnk in links[lastSelected]) lnk.visible = false;
        for (lnk in links[curSelected]) {
            lnk.visible = true;
            lnk.y = bio.y + bio.textField.height + 10; 
        };
        

        FlxG.sound.play(backend.Paths.sound('scrollMenu'));
        
    }
}

class Link extends FlxSprite {
    public var website:String;
    public var link:String;
    public var clicked:Bool = false;

    public static final recognizedLinks:Array<String> = ['bluesky', 'discord', 'github', 'instagram', 'newgrounds', 'soundcloud', 'spotify', 'twitter', 'youtube'];

    public function new(site:String, lnk:String) {
        website = site;
        link = lnk;
        super();
        this.frames = backend.Paths.getSparrowAtlas('credits/button', 'ui');
        if (!recognizedLinks.contains(website)) {
            website = 'unknown';
        }
        var str:String = '${website}_press';
        this.animation.addByPrefix('idle', '${website}_normal', 24, false);
        this.animation.addByPrefix('press',str, 24, false);
        playAnim('idle');
        this.scale.set(0.5,0.5);
        animation.finishCallback = finished;
    }

    public function finished(name:String) {
        if (name == 'press' && !clicked) {
            playAnim('idle');
        }
    }

    public function playAnim(animName:String) {
        if (animName == 'idle') {
            this.offset.y = 29;
        } else {
            this.offset.y = 35;
        }

        animation.play(animName);
    }

    public function pressed() {
        clicked = true;
        playAnim('press');
    }

    public function released(onSpr:Bool) {
        if (animation.curAnim.name == 'press')
            playAnim('idle');
        if (clicked && onSpr) 
            CoolUtil.browserLoad(link);
        clicked = false;
        #if AeroMouse
        MouseHandler.setGraphic('idle');
        #end
    }
}