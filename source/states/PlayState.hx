package states;

import flixel.input.mouse.FlxMouseEvent;
import shaders.ChromaticSillines.ChromaticSilliness;
import haxe.Timer;
import shaders.SonicDotExe;
import states.substates.MusicBeatSubstate;
import backend.events.FlashEvent;
import backend.events.VHSLines;
import backend.events.Barrel;
import backend.events.GlitchyEvent;
import backend.events.Viginette;
import shaders.SpookyShader;
import backend.events.TrailEvent;
import backend.events.ColorContrastEvent;
import backend.events.MidSongCutscene;
import backend.GameplayEvents;
import backend.events.CreditsEvent;
import backend.events.NoteFadeEvent;
import backend.events.CinematicBars;
import backend.events.SubtitleEvent;
import shaders.FlashShader;
import haxe.PosInfos;
import haxe.CallStack;
import shaders.AeroShader;
import shaders.HeatWaveShader;
import object.BGCharacter;
import backend.MouseHandler;
import openfl.display.BitmapData;
import backend.CutsceneHandler;
import haxe.Int64;
#if (sys && cpp)
import hxvlc.flixel.FlxVideoSprite;
import openfl.media.Video;
#end
import haxe.Exception;
#if AeroEvents
import backend.GameplayEvents;
#end
import flixel.graphics.FlxGraphic;
#if desktop
import backend.Discord.DiscordClient;
#end
import backend.chart.Section.SwagSection;
import backend.chart.Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import object.note.*;
import object.note.Note.EventNote;
import openfl.events.KeyboardEvent;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxSave;
import flixel.animation.FlxAnimationController;
import animateatlas.AtlasFrameMaker;
import object.DialogueBoxPsych;
import backend.chart.Conductor.Rating;
import states.substates.GameOverSubstate;
import states.substates.PauseSubState;
import object.BGSprite;
import object.note.*;
import object.*;
import data.*;
import data.StageData.StageFile;
import backend.events.EventsCore;
import backend.events.CharacterSwap;
import backend.save.ClientPrefs;
import backend.chart.Song;

#if !flash 
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter; 
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end

import backend.chart.Conductor;
import backend.Highscore;



using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

	//event variables
	private var isCameraOnForcedPos:Bool = false;

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var spawnTime:Float = 2000;

	public var vocals:FlxSound;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;

	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var healthLerp:Float = 1;
	var lastLerp:Float = 1;
	var goingDown:Bool = false;
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;

	public var ratingsData:Array<Rating> = [];
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	/*public var cameraProperties:Map<String, Dynamic> = [
		"zoom" => 1.05,
		"angle" => 0,
		"zoomOriginal" => 1.05,
		"zoomMax" => 0.7
	];
	
	
	LOCK THE FUCK IN!!!!!
		-eggu
	*/

	public var cameraProperties:Array<Dynamic> = [1.05, 0, 1.05, 0.7];

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public static var instance:PlayState;
	public var introSoundsSuffix:String = '';
	// Less laggy controls
	private var keysArray:Array<Dynamic>;
	private var controlArray:Array<String>;
	
	// stores the last judgement object
	public static var lastRating:FlxSprite;
	// stores the last combo sprite object
	public static var lastCombo:FlxSprite;
	// stores the last combo score objects in an array
	public static var lastScore:Array<FlxSprite> = [];

	public var runningTweens:Map<String, FlxTween> = []; // replacement of the modchart stuff
	public var runningTimers:Map<String, FlxTimer> = [];
	public var runningSounds:Map<String, FlxSound> = [];

	public var bgGroup:FlxTypedGroup<Dynamic>;
	public var foregroundGroup:FlxTypedGroup<Dynamic>;
	//useful for stuff such as switching BGs
	var bgMap:Map<String, Array<Array<Dynamic>>> = [];
	var useBgMap:Bool = false;

	var cutscenePaused:Bool = false;

	public var holdNoteSplashes:Array<HoldNoteSplash> = [null, null, null, null];
	var lastHitNotes:Array<Note> = [null, null, null, null]; // jesus fucking christ how many more arrays do I need
	var splashTimeChange:Array<Float> = [0,0,0,0]; // how long since a splash has changed
	public var grpSusSplash:FlxTypedGroup<HoldNoteSplash>;

	var bgCharacters:Array<BGCharacter> = [];

	public var shaderDepo:Array<Array<openfl.filters.BitmapFilter>> = [[], [], []]; // the place where cam shaders are stored

	static var accessed:Bool = false; // if the state has been accessed before

	@:isVar public var stunnedBF(get, set):Bool = false;
	@:isVar public var stunnedDAD(get, set):Bool = false;

	var sillyShader:SonicDotExe;
	var cover:FlxSprite;

	var hitOnBeat:Int = 0;
	var powerOnBeat:Float = 0;

	var chromaticSillyShader:ChromaticSilliness = null;

	var rpcName:String= '';

	var skipSong:FlxSpriteGroup;

	public function get_stunnedBF() {
		if (boyfriend != null) {
			return boyfriend.stunned;
		}
		return stunnedBF;
	}

	public function set_stunnedBF(inp:Bool) {
		if (boyfriend != null) {
			return (boyfriend.stunned = inp);
		}
		return (stunnedBF = inp);
	}

	public function get_stunnedDAD() {
		if (dad != null) {
			return stunnedDAD;
		}
		return stunnedDAD;
	}

	public function set_stunnedDAD(inp:Bool) {
		if (dad != null) {
			return (stunnedDAD = inp);
		}
		return (stunnedDAD = inp);
	}

	var playerLane:StrumLane;

	override public function create()
	{
		ClientPrefs.beenCrashed = false;
		ClientPrefs.saveSettings();
		#if !noDesktop
		FlxTween.tween(Main.instance.flxWindow, {scaleX: 1, scaleY: 1, x:0, y:0}, 1.5);
		FlxTween.tween(Main.instance.taskbar, {y:Main.instance.taskbar.y + Main.instance.taskbar.height}, 3);
		FlxTween.tween(Main.instance.time, {y:Main.instance.time.y + (Main.instance.time.height*1.5)},2.25);
		for (i in Main.instance.taskbarIcons) {
			FlxTween.tween(i, {y:i.y+(i.height*1.5)},2.25);
        }
		FlxTween.tween(Main.fpsVar, {alpha:0}, 2.25);
        #end

		#if AeroMouse
		MouseHandler.setGraphic('idle');
		#end

		instance = this;
		shaderDepo = [[], [], []];

		#if (sys && cpp)
		CutsceneHandler.reset(); // clear the cutscene map
		#end


		states.substates.PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed', 1);

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		controlArray = [
			'NOTE_LEFT',
			'NOTE_DOWN',
			'NOTE_UP',
			'NOTE_RIGHT'
		];

		//Ratings
		ratingsData.push(new Rating('sick')); //default rating

		var rating:Rating = new Rating('good');
		rating.ratingMod = 0.7;
		rating.score = 200;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('bad');
		rating.ratingMod = 0.4;
		rating.score = 100;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('shit');
		rating.ratingMod = 0;
		rating.score = 50;
		rating.noteSplash = false;
		ratingsData.push(rating);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		#if AeroEvents
		GameplayEvents.init(); // make sure the events actually exist & they have no listeners
		#end

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		grpSusSplash = new FlxTypedGroup<HoldNoteSplash>();

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		CustomFadeTransition.nextCamera = camOther;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		switch (SONG.song.toLowerCase()) {
			case 'foreign-entity':
				DiscordClient.iconType = 'foreign_entity';
			case 'defender':
				DiscordClient.iconType = 'defender';
			case '(re)boot1':
				DiscordClient.iconType = 'reboot';
			case '(re)boot2':
				DiscordClient.iconType = 'reboot';
			default:
				trace(SONG.song.toLowerCase());
				DiscordClient.iconType = 'foreign_entity';
		}

		rpcName = SONG.song;
		if (rpcName.charAt(0) == '(') {
			rpcName = '(re)boot';
		} else {
			trace(rpcName.charAt(0));
		}

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: FunkOS";
		}
		else
		{
			detailsText = "FunkOS";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = backend.Paths.formatToSongPath(SONG.song);

		curStage = SONG.stage;
		if(SONG.stage == null || SONG.stage.length < 1) 
			curStage = 'stage';
		SONG.stage = curStage;
		var camPos:FlxPoint = null;
		#if Pure_Chart_Allowed
		if (!ClientPrefs.pureChart) {
		#end
			var stageData:StageFile = StageData.getStageFile(curStage);
			if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
				stageData = {
					directory: "",
					defaultZoom: 0.9,
					maximumZoom:0.7,
					isPixelStage: false,

					boyfriend: [770, 100],
					girlfriend: [400, 130],
					opponent: [100, 100],
					hide_girlfriend: false,

					camera_boyfriend: [0, 0],
					camera_opponent: [0, 0],
					camera_girlfriend: [0, 0],
					camera_speed: 1
				};
			}

			cameraProperties[0] = stageData.defaultZoom;
			cameraProperties[1] = stageData.defaultZoom;
			cameraProperties[2] = stageData.maximumZoom;
			isPixelStage = stageData.isPixelStage;
			BF_X = stageData.boyfriend[0];
			BF_Y = stageData.boyfriend[1];
			GF_X = stageData.girlfriend[0];
			GF_Y = stageData.girlfriend[1];
			DAD_X = stageData.opponent[0];
			DAD_Y = stageData.opponent[1];

			cameraProperties = [stageData.defaultZoom, 0, stageData.defaultZoom, stageData.maximumZoom]; // better than assigning a var to all of them

			if(stageData.camera_speed != null)
				cameraSpeed = stageData.camera_speed;

			boyfriendCameraOffset = stageData.camera_boyfriend;
			if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
				boyfriendCameraOffset = [0, 0];

			opponentCameraOffset = stageData.camera_opponent;
			if(opponentCameraOffset == null)
				opponentCameraOffset = [0, 0];

			girlfriendCameraOffset = stageData.camera_girlfriend;
			if(girlfriendCameraOffset == null)
				girlfriendCameraOffset = [0, 0];

			boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
			dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
			gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

			createStage(curStage);
			add(bgGroup);

			if(isPixelStage) {
				introSoundsSuffix = '-pixel';
			}

			add(gfGroup); //Needed for blammed lights
			add(dadGroup);
			add(boyfriendGroup);

			add(foregroundGroup); // real layering

			if (!stageData.hide_girlfriend)
			{
				gf = new Character(0, 0, 'gf');
				startCharacterPos(gf);
				gf.scrollFactor.set(0.95, 0.95);
				gfGroup.add(gf);
			}

			dad = new Character(0, 0, SONG.player2);
			if (SONG.player2.toLowerCase() == 'defender') {
				var shadow = new BGSprite('bg/computerGood/shadow',0,0,1,1);
				dadGroup.add(shadow);
				shadow.x -= shadow.width/2;
				shadow.y = DAD_Y + 700;
				shadow.updateHitbox();
				GameplayEvents.GAME_UPDATE.add(e -> {
					//smart
					dad.x = (Math.sin(SillyThing.time) * 250)-225;
					dad.y = Math.cos(SillyThing.time/2) * 75;
					if (!SONG.notes[curSection].mustHitSection) {
						moveCamera(true);
					}

					shadow.x = (dad.x + shadow.width/2)-55;
					shadow.alpha = 1.6 - (1-((75+(dad.y)) / 100));

					var to = 1.9 - (1-((75+(dad.y)) / 100));
					
					shadow.scale.set(Math.min(1,to),Math.min(1,to));
				});
				
			} else if (SONG.player2.toLowerCase() == 'super virus' && ClientPrefs.shaders) {
					dad.useFramePixels = true;

					if (SONG.song.toLowerCase() == '(ret)boot1') {
						chromaticSillyShader = new ChromaticSilliness({loopTime:2.5, width:0.75,offs:0.0005,timeMult:1.5},{loopTime:1.5, width:1,offs:0.0075,timeMult:1.},87);
					} else {
						chromaticSillyShader = new ChromaticSilliness({loopTime:1.5, width:1,offs:0.0075,timeMult:1.},{loopTime:0.35, width:3,offs:0.01,timeMult:6.},66);
					}
					dad.shader = chromaticSillyShader;
					//shaderDepo[0].push(new ShaderFilter(new ChromaticSilliness()));
			}
			boyfriend = new Boyfriend(0, 0, SONG.player1);
				dadGroup.add(dad);
				startCharacterPos(dad, true);

			startCharacterPos(boyfriend);
			boyfriendGroup.add(boyfriend);

			camPos = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
			if(gf != null)
			{
				camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
				camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
			}

			if(dad.curCharacter.startsWith('gf')) {
				dad.setPosition(GF_X, GF_Y);
				if(gf != null)
					gf.visible = false;
			}
		#if Pure_Chart_Allowed }  else {
			var bg = new PureBG(ClientPrefs.pureBGPath, 0, 0, 0, 0);
			bg.screenCenter();
			bg.cameras = [camHUD];
			add(bg);
		}
		#end

		var file:String = backend.Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}

		var file:String = backend.Paths.txt(songName + '/' + songName + 'Dialogue'); //Checks for vanilla/Senpai dialogue
		if (OpenFlAssets.exists(file)) {
			dialogue = CoolUtil.coolTextFile(file);
		}
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;

		Conductor.songPosition = -5000 / Conductor.songPosition;

		if (ClientPrefs.HUDType != 'None') {
			if (ClientPrefs.HUDType != 'No Gradient') {
				var hudGrad = new BGSprite('hud/grad', 0, 0, 1, 1);
				hudGrad.cameras = [camHUD];
				add(hudGrad);
				runningTweens.set('Hud Gradient', FlxTween.tween(hudGrad, {alpha:0}, 7.5, {ease:FlxEase.smootherStepInOut, type:PINGPONG}));
			}
	
			var hudMain = new BGSprite('hud/border', 0, 0, 1, 1);
			hudMain.cameras = [camHUD];
			add(hudMain);
		}

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(backend.Paths.uiFont, 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.song;
		}
		updateTime = showTime;

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		if (ClientPrefs.showPlayerLane) {
			playerLane = new StrumLane();
			playerLane.cameras = [camHUD];
			add(playerLane);
		}
		add(strumLineNotes);
		add(grpNoteSplashes);

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);
		add(grpSusSplash); // add the sustain splashes above the notes


		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		#if Pure_Chart_Allowed if (!ClientPrefs.pureChart) { #end
			camFollow = new FlxPoint();
			camFollowPos = new FlxObject(0, 0, 1, 1);

			snapCamFollowToPos(camPos.x, camPos.y);
			if (prevCamFollow != null)
			{
				camFollow = prevCamFollow;
				prevCamFollow = null;
			}
			if (prevCamFollowPos != null)
			{
				camFollowPos = prevCamFollowPos;
				prevCamFollowPos = null;
			}
			add(camFollowPos);

			FlxG.camera.follow(camFollowPos, LOCKON, 1);
			// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
			FlxG.camera.zoom = cameraProperties[3];
			FlxG.camera.focusOn(camFollow);

			FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

			FlxG.fixedTimestep = false;
			moveCameraSection();
			#if Pure_Chart_Allowed } #end

		var healthBarString = 'healthBar';

		if (ClientPrefs.HUDType != 'None') {
			healthBarString+='-MOD';
		}

		healthBarBG = new AttachedSprite(healthBarString);
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;
		healthLerp = 1; // smooth health bar
		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'healthLerp', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.numDivisions *= 5;
		if (ClientPrefs.HUDType == 'None') {
			add(healthBarBG);
		}
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		add(healthBar);
		if (ClientPrefs.HUDType != 'None') {
			add(healthBarBG);
		}
		healthBarBG.sprTracker = healthBar;

		#if Pure_Chart_Allowed if (!ClientPrefs.pureChart) { #end
			iconP1 = new HealthIcon(boyfriend.healthIcon, true);
			iconP2 = new HealthIcon(dad.healthIcon, false);
		#if Pure_Chart_Allowed } else {
			iconP1 = new HealthIcon('face', true);
			iconP2 = new HealthIcon('face', false);
		} #end
		
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);

		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		reloadHealthBarColors();

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(50, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(50, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x);

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(backend.Paths.uiFont, 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);


		if (cpuControlled) {
			botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
			botplayTxt.setFormat(backend.Paths.uiFont, 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			botplayTxt.scrollFactor.set();
			botplayTxt.borderSize = 1.25;
			botplayTxt.visible = true;
			add(botplayTxt);
			if(ClientPrefs.downScroll) {
				botplayTxt.y = timeBarBG.y - 78;
			}
			#if AeroEvents
			GameplayEvents.GAME_UPDATE.add(elapsed -> { // this is why i like gameplay events! instead of running an "if" every frame, you only run it once!
				botplaySine += 180 * elapsed;
				botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
			});
			#else
			botplayTxt.alpha = 1;
			#end

			botplayTxt.cameras = [camHUD];
		}
		

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		grpSusSplash.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		if (SONG.song.toLowerCase() == 'foreign-entity' && Highscore.songScores.exists('foreign-entity')) {
			skipSong = new FlxSpriteGroup();
			var text = new FlxText(0,0,0,'Click me to\nskip!',16);
			text.setFormat(Paths.font('vcr.ttf'), 20, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
			text.drawFrame(true);
			text.x = 40;
			text.y = 12.5;
			var bg = Funkin9Slice.giveSlice(2, 200, 75);
			skipSong.add(bg);
			skipSong.add(text);
			add(skipSong);
			skipSong.x = -750;
			skipSong.y = 500;
			FlxMouseEvent.add(skipSong, null, txt -> {
				KillNotes();
				FlxG.sound.music.onComplete();
			});
			skipSong.cameras = [camHUD];
		}

		if (cover != null) {
			cover.cameras = [camOther];
			add(cover);
		}



		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;
		
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		var daSong:String = backend.Paths.formatToSongPath(curSong); 
		#if (sys && cpp)
		if (SONG.cutscene != null && SONG.cutscene.hasCutscene && ClientPrefs.playCutscenes && !FreeplayState.been) { //  play the pre-song cutscene if the song has it, and if your settings want you to
			if (SONG.cutscene.alwaysPlay) { // if it always plays the cutscene then play it always
				CutsceneHandler.loadVideo(PlayState.SONG.cutscene.filePath, PlayState.SONG.cutscene.fileExtension, ()->{}, 'GameplayIntroCutscene');
				startSongCutscene();
			} else if (!seenCutscene) { // or, if the cutscene doesnt always play but you havent seen it.
				CutsceneHandler.loadVideo(PlayState.SONG.cutscene.filePath, PlayState.SONG.cutscene.fileExtension, ()->{}, 'GameplayIntroCutscene');
				startSongCutscene();
			} else {
				startCountdown();
			}
		} else {
			startCountdown();
		}
		#else
		startCountdown();
		#end
		//way messier than it needs to be i dont care LMAO 
		// -eggu
		
		RecalculateRating();

		// > PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		// L
		backend.Paths.sound('hitsound');
		backend.Paths.sound('missnote1');
		backend.Paths.sound('missnote2');
		backend.Paths.sound('missnote3');

		if (PauseSubState.songName != null) {
			backend.Paths.music(PauseSubState.songName);
		} else if (ClientPrefs.pauseMusic != 'None') {
			backend.Paths.music(backend.Paths.formatToSongPath(ClientPrefs.pauseMusic));
		}

		backend.Paths.image('alphabet');
	
		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, rpcName, iconP2.getCharacter());
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		#if AeroEvents
		if (!ClientPrefs.noReset) {
			GameplayEvents.GAME_UPDATE.add(e -> {
				if (controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
					{
						health = 0;
					}
			});
		}
		#end

		updateShaderDepo(); //cleaner way of handling shaders imo instead of constantly removing them from the actual cameras. you can delete this though, its not that big of a diff
		super.create();

		cacheCountdown();
		cachePopUpScore();

		//dad.shader = new shaders.DemoShader();

		CustomFadeTransition.nextCamera = camOther;
	}

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes) note.resizeByRatio(ratio);
			for (note in unspawnNotes) note.resizeByRatio(ratio);
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		if(generatedMusic)
		{
			if(vocals != null) vocals.pitch = value;
			FlxG.sound.music.pitch = value;
		}
		playbackRate = value;
		FlxAnimationController.globalSpeed = value;
		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000 * value;
		return value;
	}

	public function reloadHealthBarColors() {
		#if Pure_Chart_Allowed if (!ClientPrefs.pureChart) { #end
			healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
		#if Pure_Chart_Allowed } else {
			healthBar.createFilledBar(0xFF6D6D6D, 0xFFFFFFFF);
		} #end
		
		healthBar.updateBar();
	}

	public function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		introAssets.set('default', ['ready', 'set', 'go']);
		introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

		var introAlts:Array<String> = introAssets.get('default');
		if (isPixelStage) introAlts = introAssets.get('pixel');
		
		for (asset in introAlts)
			backend.Paths.image(asset);
		
		backend.Paths.sound('intro3' + introSoundsSuffix);
		backend.Paths.sound('intro2' + introSoundsSuffix);
		backend.Paths.sound('intro1' + introSoundsSuffix);
		backend.Paths.sound('introGo' + introSoundsSuffix);
	}

	public function startCountdown():Void
	{
		if(startedCountdown) {
			trace('fuck off');
			return;
		}

		inCutscene = false;
		if (strumLineNotes.members != []) {
			strumLineNotes.killMembers();
			strumLineNotes.forEach(mem -> {strumLineNotes.remove(mem);trace('remove');});
		}
			generateStaticArrows(0);
			generateStaticArrows(1);

			notesMade = true;

			startedCountdown = true;
			Conductor.songPosition = -Conductor.crochet * 5;

			//trace()

			if (Conductor.lastSongPos > 0) {
				Conductor.songPosition -= 450; // idk why but this works
			}

			var swagCounter:Int = 0;

			if(startOnTime < 0) startOnTime = 0;

			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return;
			}
			else if (skipCountdown)
			{
				setSongTime(0);
				return;
			}

			var sillyIntro = false;
			if (sillyIntro) {
					runningTweens.set('intro zooming shit', FlxTween.tween(FlxG.camera, {zoom: cameraProperties[0]}, (Conductor.crochet / 1000 / playbackRate)*5, {ease:FlxEase.smootherStepInOut, onComplete: twn -> {runningTweens.remove('intro zooming shit');}}));
			}
			if (skipSong != null) {
				runningTimers.set('intro skip button', new FlxTimer().start(3, tmr -> {
					runningTimers.remove('intro skip button');
					runningTweens.set('intro skip button', 
					FlxTween.tween(skipSong, {x: 15}, 5, {ease:FlxEase.quadOut, onComplete:tmr -> {
						runningTweens.remove('intro skip button');
						runningTimers.set('intro skip button', new FlxTimer().start(5, tmr -> {
							runningTimers.remove('intro skip button');
							runningTweens.set('intro skip button', FlxTween.tween(skipSong, {x:-750}, 5, {ease:FlxEase.smoothStepIn,onComplete:twn -> {
								FlxMouseEvent.remove(skipSong);
								runningTweens.remove('intro skip button');
							}}));
						}));
					}})
					);
				}));
			}
			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
				{
					gf.dance();
				}
				if (#if Pure_Chart_Allowed !ClientPrefs.pureChart && #end tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !stunnedBF)
				{
					boyfriend.dance();
				}
				if (#if Pure_Chart_Allowed !ClientPrefs.pureChart && #end tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !stunnedDAD)
				{
					dad.dance();
				}
				#if Pure_Chart_Allowed  if (!ClientPrefs.pureChart)
				{
				#end
					for (char in bgCharacters) {
						if ((tmr.loopsLeft) % char.danceEveryNumBeats == 0 && char.animation.curAnim != null && !(char.isCheering)) {
							char.dance();
						}
					}
				#if Pure_Chart_Allowed 
				}
				#end

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if(isPixelStage) {
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				switch (swagCounter)
				{
					case 0:
						FlxG.sound.play(backend.Paths.sound('intro3' + introSoundsSuffix), 0.6);
					case 1:
						countdownReady = new FlxSprite().loadGraphic(backend.Paths.image(introAlts[0]));
						countdownReady.cameras = [camHUD];
						countdownReady.scrollFactor.set();
						countdownReady.updateHitbox();

						if (PlayState.isPixelStage)
							countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

						countdownReady.screenCenter();
						countdownReady.antialiasing = antialias;
						insert(members.indexOf(notes), countdownReady);
						FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownReady);
								countdownReady.destroy();
							}
						});
						FlxG.sound.play(backend.Paths.sound('intro2' + introSoundsSuffix), 0.6);
					case 2:
						countdownSet = new FlxSprite().loadGraphic(backend.Paths.image(introAlts[1]));
						countdownSet.cameras = [camHUD];
						countdownSet.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

						countdownSet.screenCenter();
						countdownSet.antialiasing = antialias;
						insert(members.indexOf(notes), countdownSet);
						FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownSet);
								countdownSet.destroy();
							}
						});
						FlxG.sound.play(backend.Paths.sound('intro1' + introSoundsSuffix), 0.6);
					case 3:
						countdownGo = new FlxSprite().loadGraphic(backend.Paths.image(introAlts[2]));
						countdownGo.cameras = [camHUD];
						countdownGo.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

						countdownGo.updateHitbox();

						countdownGo.screenCenter();
						countdownGo.antialiasing = antialias;
						insert(members.indexOf(notes), countdownGo);
						FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownGo);
								countdownGo.destroy();
							}
						});
						FlxG.sound.play(backend.Paths.sound('introGo' + introSoundsSuffix), 0.6);
					case 4:
				}

				notes.forEachAlive(function(note:Note) {
					if(ClientPrefs.opponentStrums || note.mustPress)
					{
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
						if(ClientPrefs.middleScroll && !note.mustPress) {
							note.alpha *= 0.35;
						}
					}
				});

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
	}

	public function addBehindGF(obj:FlxObject)
	{
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxObject)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad (obj:FlxObject)
	{
		insert(members.indexOf(dadGroup), obj);
	}
	public function addBehindNotes(obj:FlxObject){
		insert(members.indexOf(strumLineNotes), obj); // useful for a few things
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function updateScore(miss:Bool = false)
	{
		scoreTxt.text = 'Score: ' + songScore
		+ ' | Misses: ' + songMisses
		+ ' | Rating: ' + ratingName
		+ (ratingName != '?' ? ' (${Highscore.floorDecimal(ratingPercent * 100, 2)}%) - $ratingFC' : '');

		if(ClientPrefs.scoreZoom && !miss && !cpuControlled)
		{
			if(scoreTxtTween != null) {
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.075;
			scoreTxt.scale.y = 1.075;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					scoreTxtTween = null;
				}
			});
		}
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
			vocals.pitch = playbackRate;
		}
		vocals.play();
		Conductor.songPosition = time;
		songTime = time;
	}

	function startNextDialogue() {
		dialogueCount++;
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(backend.Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.play();

		if(startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if(paused) {
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, rpcName, iconP2.getCharacter(), true, songLength);
		#end
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(backend.Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		vocals.pitch = playbackRate;
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(backend.Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = backend.Paths.formatToSongPath(SONG.song);
		var file:String = backend.Paths.json(songName + '/events');
		if (OpenFlAssets.exists(file)) {
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					#if Pure_Chart_Allowed if (ClientPrefs.pureChart) {
						if (EventsCore.allowedInPurechart.contains(event[1][0][0])) {
							var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
							var subEvent:EventNote = {
								strumTime: newEventNote[0] + ClientPrefs.noteOffset,
								event: newEventNote[1],
								value1: newEventNote[2],
								value2: newEventNote[3]
							};
							eventNotes.push(subEvent);
							eventPushed(subEvent);
						}
					} else { #end
						var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
						var subEvent:EventNote = {
							strumTime: newEventNote[0] + ClientPrefs.noteOffset,
							event: newEventNote[1],
							value1: newEventNote[2],
							value2: newEventNote[3]
						};
						eventNotes.push(subEvent);
						eventPushed(subEvent);
					#if Pure_Chart_Allowed } #end
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = states.editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts

				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						swagNote.tail.push(sustainNote);
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}
				if(!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}
		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				#if Pure_Chart_Allowed if (ClientPrefs.pureChart) {
					if (EventsCore.allowedInPurechart.contains(event[1][0][0])) {
						var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
						var subEvent:EventNote = {
							strumTime: newEventNote[0] + ClientPrefs.noteOffset,
							event: newEventNote[1],
							value1: newEventNote[2],
							value2: newEventNote[3]
						};
						eventNotes.push(subEvent);
						eventPushed(subEvent);
					}
				} else { #end
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				#if Pure_Chart_Allowed } #end
				
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'Zoom On Beat':
				if (ClientPrefs.camZooms) {
					GameplayEvents.CONDUCTOR_BEAT.add(beat->{
						if (hitOnBeat != 0) {
							if (((beat+1) % hitOnBeat) == 0) {
								if (SONG.song.toLowerCase() == 'defender') camGame.zoom += (powerOnBeat/2);
								else camGame.zoom += powerOnBeat;
							}
						}
					});
				}
			case 'BSOD':
				Paths.image('bsod');
			case 'BSOD pre':
				Paths.sound('Windows-Foreground');
				Paths.image('bsod');
			case 'VHS lines':
				VHSLines.queue(event.value1);
			case 'Barrel':
				Barrel.queue(event.value1);
			case 'Glitchy':
				GlitchyEvent.queue(event.value1);
			case 'Viginette':
				Viginette.queue(event.value1);
			case 'Trail':
				TrailEvent.queue(event.value1, event.value2);
			case 'Color Contrast':
				ColorContrastEvent.anotherOne(event.value1);
			case 'Credits': // NOTE!!! ONLY USE THIS EVENT ONCE
			var v1 = 0.5;
			var st = Std.parseFloat(event.value1);
			if (!Math.isNaN(st)) v1=st;
			CreditsEvent.init(st);
			case 'Mid-Song Cutscene':
				#if (sys && cpp)
				if (!MidSongCutscene.initialized) {
					MidSongCutscene.init();
				}
				var time:Float = Std.parseFloat(event.value2); // setting default values to then be run only on create, instead of when the event is called. I aint gonna repeat this every event
				if (Math.isNaN(time)){
					time = 0;
				} 
				MidSongCutscene.queueCutscene(event.value1, time);
				#end
			case 'Note Fade':
				var inp = Std.parseInt(event.value1);
				var time = Std.parseFloat(event.value2);

				if (Math.isNaN(inp) || event.value1 == '') 
					inp = 2;
				if (Math.isNaN(time) || event.value2 == '')
					time = Conductor.crochet/1000;
				NoteFadeEvent.pushed();
				NoteFadeEvent.vals.push([inp, time]);
			case 'Cinematic Bars':
				if (!CinematicBars.initialized) {
					CinematicBars.init();
				}
				var goTo = Std.parseFloat(event.value1);
				var time = Std.parseFloat(event.value2);
				if (time == -2763 || Math.isNaN(time)) {
					time = Conductor.crochet/2000;
				}
				if (Math.isNaN(goTo) || event.value1 == '') {
					goTo = -2763;
				}
				CinematicBars.distances.push([goTo, time]);
			case 'Subtitle':
				var optionArray:Array<String> = event.value2.toLowerCase().replace(' ', '').split(',');
				var item:TextData = {font:backend.Paths.uiFont, width:FlxG.width-100, mainColor: 0xFFFFFFFF, borderColor:0xFF000000, scale:15, introTime:0, persistTime: Conductor.crochet/500};

				var i:Int = 0;
				while (i < optionArray.length) {
					switch(optionArray[i]) {
						case 'font':
							item.font = optionArray[i+1];
						case 'width':
							var int = Std.parseInt(optionArray[i+1]);
							if (!Math.isNaN(int)) {
								item.width = FlxMath.minInt(int, item.width);
							}
						case 'maincolor':
							item.mainColor = Std.parseInt(optionArray[i+1]);
						case 'bordercolor':
							item.borderColor = Std.parseInt(optionArray[i+1]);
						case 'scale' | 'size':
							item.scale = Std.parseInt(optionArray[i+1]);
						case 'introtime':
							item.introTime = Std.parseFloat(optionArray[i+1]);
						case 'persisttime' | 'time':
							item.persistTime = Std.parseFloat(optionArray[i+1]);
						default:
							trace(optionArray[i]);
					}

					i+=2;
				}

				SubtitleEvent.queue(event.value1, item);


			case 'Flash Camera':
				FlashEvent.queue(event.value1);
			case 'Change Background': // i tried to turn this into its own class but it didnt work
				if (!useBgMap) {
					//put the current stage in the bg map, since it usually doesnt do that.
					bgMap = new Map<String, Array<Array<Dynamic>>>();
					useBgMap = true;
					var lc1L:Array<Dynamic> = [];
					var lc2L:Array<Dynamic> = [];
					bgGroup.forEach(o->{lc1L.push(o);});
					foregroundGroup.forEach(o->{lc2L.push(o);});
					bgMap.set(curStage, [lc1L, lc2L, [StageData.getStageFile(curStage)]]);
				}
				createStage(event.value1, true);
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				CharacterSwap.addCharacterToList(newCharacter, charType);
		}

		if (eventPushedMap == null) {
			eventPushedMap = new Map<String, Bool>();
		}

		if(!eventPushedMap.exists(event.event)) {
			eventPushedMap.set(event.event, true);
		}
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if(!ClientPrefs.opponentStrums) targetAlpha = 0;
				else if(ClientPrefs.middleScroll) targetAlpha = 0.35;
			}

			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;
			if (!isStoryMode)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				if ((SONG.song.toLowerCase() == '(re)boot1' || SONG.song.toLowerCase() == '(re)boot2') && ClientPrefs.shaders) {
					babyArrow.useFramePixels = true;
					babyArrow.shader = chromaticSillyShader;
				}
				if(ClientPrefs.middleScroll)
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		} 

		if (ClientPrefs.showPlayerLane && player == 1) {
			playerLane.calculatedWidth = ((playerStrums.members[playerStrums.length-1].x+playerStrums.members[playerStrums.length-1].width) - playerStrums.members[0].x)+30;
			playerLane.createLane();
			playerLane.x = playerStrums.members[0].x - 15;
			playerLane.alpha = ClientPrefs.playerLaneAlpha;
		}

		
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}

			for (tween in runningTweens) {
				tween.active = false;
			}
			for (timer in runningTimers) {
				timer.active = false;
			}
			for (sound in runningSounds) {
				sound.pause();
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;


			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}

			for (tween in runningTweens) {
				tween.active = true;
			}
			for (timer in runningTimers) {
				timer.active = true;
			}
			for (sound in runningSounds) {
				sound.resume();
			}
			paused = false;
			GameplayEvents.GAME_PLAYUPDATE.dispatch(false);

			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, rpcName, iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, rpcName, iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, rpcName, iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, rpcName, iconP2.getCharacter());
			}
		}
		#end
		
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song, iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		FlxG.sound.music.pitch = playbackRate;
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
			vocals.pitch = playbackRate;
		}
		vocals.play();
	}

	public static var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var notesMade:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	override public function update(elapsed:Float)
	{
		if(!inCutscene #if Pure_Chart_Allowed &&!ClientPrefs.pureChart #end) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed * playbackRate, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}


		super.update(elapsed);

		for (i in 0...4) {
			splashTimeChange[i] += elapsed;
		}

		#if AeroEvents
		GameplayEvents.GAME_UPDATE.dispatch(elapsed); // run the event for update
		#end

		if (controls.PAUSE && startedCountdown && canPause)
		{
				openPauseMenu();
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		lastLerp = healthLerp;
		healthLerp = FlxMath.lerp(healthLerp, health, elapsed*(6 + ((SONG.bpm * 1.25) / 100))); // smooth healthbar :3
		var posMod:Int = 0;
		if (ratingName != '?') { //lowkey a bodge but it works for what it is.
			if (lastLerp >= healthLerp) {
				posMod = -20;
			} else {
				posMod = 20;
			}
		}

		iconP1.x = FlxMath.lerp(iconP1.x, (healthBar.x + (healthBar.width * ((Math.abs(healthBar.percent-100)))*0.01))-(30+posMod), elapsed*4); // rewritten icon code, shadowmario why did you think remap was a good idea??
		iconP2.x = FlxMath.lerp(iconP2.x, (healthBar.x + ((healthBar.width * (Math.abs(healthBar.percent-100)))*0.01))-(130+posMod), elapsed*4);
		
		

		if (health > 2)
			health = 2;

		if (healthBar.percent < 17)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 65)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (startedCountdown)
		{
			Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;
		}

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= 0)
				startSong();
			else if(!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5;
		}
		else
		{
			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
				}

				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					var lenToUse = songLength;
					if (SONG.song.toLowerCase() == '(re)boot1') songLength += 63;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					if(ClientPrefs.timeBarType == 'Time Elapsed') songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					if(ClientPrefs.timeBarType != 'Song Name')
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		FlxG.camera.zoom = FlxMath.lerp(Math.max(cameraProperties[0], cameraProperties[3]), FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
		if (camZooming)
		{
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime;
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned=true;

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic && !inCutscene)
		{
			if(!cpuControlled) {
				keyShit();
			} else if(#if Pure_Chart_Allowed !ClientPrefs.pureChart && #end boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}

			if(startedCountdown && notesMade)
			{
				var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
				notes.forEachAlive(function(daNote:Note)
				{
					var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
					if(!daNote.mustPress) strumGroup = opponentStrums;

					var strumX:Float = strumGroup.members[daNote.noteData].x;
					var strumY:Float = strumGroup.members[daNote.noteData].y;
					var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
					var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
					var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
					var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

					strumX += daNote.offsetX;
					strumY += daNote.offsetY;
					strumAngle += daNote.offsetAngle;
					strumAlpha *= daNote.multAlpha;

					daNote.alpha = strumAlpha;


					if (strumScroll) //Downscroll
					{
						//daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
						daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
					}
					else //Upscroll
					{
						//daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
						daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
					}

					var angleDir = strumDirection * Math.PI / 180;
					if (daNote.copyAngle)
						daNote.angle = strumDirection - 90 + strumAngle;

					if(daNote.copyAlpha)
						daNote.alpha = strumAlpha;

					if(daNote.copyX)
						daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

					if(daNote.copyY)
					{
						daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

						//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
						if(strumScroll && daNote.isSustainNote)
						{
							if (daNote.animation.curAnim.name.endsWith('end')) {
								daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
								daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
								if(PlayState.isPixelStage) {
									daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
								} else {
									daNote.y -= 19;
								}
							}
							daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
							daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
						}
					}

					if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
					{
						opponentNoteHit(daNote);
					}

					if(!daNote.blockHit && daNote.mustPress && cpuControlled && daNote.canBeHit) {
						if(daNote.isSustainNote) {
							if(daNote.canBeHit) {
								goodNoteHit(daNote);
							} else {
							}
						} else if(daNote.strumTime <= Conductor.songPosition || daNote.isSustainNote) {
							goodNoteHit(daNote);
						}
					}

					var center:Float = strumY + Note.swagWidth / 2;
					if(strumGroup.members[daNote.noteData].sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
						(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						if (strumScroll)
						{
							if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
								swagRect.height = (center - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
						else
						{
							if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}

					// Kill extremely late notes and cause misses
					if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
					{
						if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
							noteMiss(daNote);
						}

						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
			}
			else
			{
				notes.forEachAlive(function(daNote:Note)
				{
					daNote.canBeHit = false;
					daNote.wasGoodHit = false;
				});
			}
		}
		checkEventNote();

		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end
	}

	function openPauseMenu()
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		GameplayEvents.GAME_PLAYUPDATE.dispatch(true);

		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
		}
		#if Pure_Chart_Allowed  if (ClientPrefs.pureChart ) {
			openSubState(new states.substates.PauseSubState(FlxG.width/2, FlxG.height/2));
		} else { #end
			openSubState(new states.substates.PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			#if Pure_Chart_Allowed } #end
		//}

		#if desktop
		DiscordClient.changePresence(detailsPausedText, SONG.song, iconP2.getCharacter());
		#end
	}

	public var isDead:Bool = false;
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead)
		{
				stunnedBF = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				for (tween in runningTweens) {
					tween.active = true;
				}
				for (timer in runningTimers) {
					timer.active = true;
				}
				#if Pure_Chart_Allowed
				if (ClientPrefs.pureChart) {
					openSubState(new states.substates.GameOverSubstate(FlxG.width/2, FlxG.height/2,  FlxG.width/2, FlxG.height/2));
				} else {
				#end
					openSubState(new states.substates.GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));
				#if Pure_Chart_Allowed
				}
				#end

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song, iconP2.getCharacter());
				#end
				isDead = true;
				return true;
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		return pressed;
	}

	var sub:MusicBeatSubstate = null;

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'black':
				var cover = new FlxSprite().makeGraphic(FlxG.width*3, FlxG.height*3, 0xFF000000);
				cover.scrollFactor.set(0,0);
				cover.x -= 750;
				cover.y -= 500;
				add(cover);
			case 'fadeUI out':
				runningTweens.set('the other FUCKC HIJDFNVSFDGMK', FlxTween.num(opponentCameraOffset[1], opponentCameraOffset[1]-450, Std.parseFloat(value1), {onComplete: twn -> {runningTweens.remove('the other FUCKC HIJDFNVSFDGMK');}}, f -> {opponentCameraOffset[1] = f;}));
				runningTweens.set('sillyUIFUNYNTJBFRDGB ', FlxTween.tween(camHUD, {alpha:0}, Std.parseFloat(value1), {onComplete: twn -> {runningTweens.remove('sillyUIFUNYNTJBFRDGB ');}}));
			case 'Zoom On Beat':
				var v = Std.parseInt(value1);
				if (Math.isNaN(v)) {
					v = 2;
				}
				hitOnBeat = v;

				var v2 = Std.parseFloat(value2);
				if (Math.isNaN(v2)) {
					v2 = 0.0025;
				}
				powerOnBeat = v2;
			case 'BSOD':
				var spr = new FlxSprite().loadGraphic(Paths.image('bsod'));
				spr.scrollFactor.set(0,0);
				spr.cameras = [camOther];
				add(spr);
				Sys.sleep(5);
				#if noDesktop
				Sys.exit(0);
				#else
				CoolUtil.reloadGame();
				#end
				
			case 'BSOD pre':
				var tmr1:Timer = null;
				if (ClientPrefs.shaders) {
					tmr1 = new Timer(81);
					tmr1.run = () -> {
						sillyShader.next();
					}
				}
				this.persistentUpdate = false;
				sub = new MusicBeatSubstate();
				openSubState(sub);
				for (k=>v in runningTweens) {
					v.active = false;
				}
				for (k=>v in runningTimers) {
					v.active = false;
				}

				ClientPrefs.beenCrashed = true;
				ClientPrefs.saveSettings();
				
				Timer.delay(() -> {
					FlxG.sound.play(Paths.sound('Windows-Foreground'), 2);
					if (ClientPrefs.shaders && tmr1 != null) tmr1.stop();
					Main.instance.removeChild(Main.fpsVar);
					var spr = new FlxSprite().loadGraphic(Paths.image('bsod'));
					spr.scrollFactor.set(0,0);
					spr.cameras = [camOther];
					sub.add(spr);
					FlxG.sound.music.stop();
					vocals.stop();
					haxe.Timer.delay(() -> {
						Sys.sleep(5);
						#if noDesktop
						Sys.exit(0);
						#else
						CoolUtil.reloadGame();
						#end
					}, 1000);
				}, 2900);
			case 'VHS lines':
				VHSLines.next();
			case 'Barrel':
				Barrel.next();
			case 'Glitchy':
				GlitchyEvent.next();
			case 'Viginette': 
				Viginette.next();
			case 'Trail':
				TrailEvent.nextTrail();
			case 'Color Contrast':
				ColorContrastEvent.next();
			case 'Credits':
				CreditsEvent.showCredits();
			case 'Mid-Song Cutscene':
				#if (cpp && sys)
				MidSongCutscene.playNextVideo();
				#end
			case 'Note Fade':
				NoteFadeEvent.fadeNotes(); // its that easy
			case 'Camera Zoom':
				var time = Std.parseFloat(value2); // why arnt you run on create
				var goTo = Std.parseFloat(value1);
				if (Math.isNaN(goTo)) {
					goTo = cameraProperties[2];
				}
				if (time != 0) {
					if (runningTweens.exists('camGameZoomEvent'))  
						runningTweens.get('camGameZoomEvent').cancel();
					if (Math.isNaN(time) || time < 0) 
						time = Conductor.crochet/100;
					//runningTweens.set('camGameZoomEvent', FlxTween.tween(this.cameraProperties, {"[0]": goTo}, time, {ease:CoolUtil.easeFromTime(time) /* we love funkin origins*/ ,onComplete: twn -> {runningTweens.remove('camGameZoomEvent');}})); oopsies thats not how tweens work :3
					runningTweens.set('camGameZoomEvent', FlxTween.num(this.cameraProperties[0], goTo,  time, {ease:CoolUtil.easeFromTime(time) /* we love funkin origins*/ ,onComplete: twn -> {runningTweens.remove('camGameZoomEvent');}}, f -> {cameraProperties[0] = f;}));
				} else {
					camGame.zoom = goTo;
					cameraProperties[0] = goTo;
				}
			case 'Cinematic Bars':
				CinematicBars.next();
			case 'Subtitle':
				SubtitleEvent.nextTitle();
			case 'Flash Camera':
				FlashEvent.next();
			case 'Change Background': 
				if (value1 != curStage) changeBG(value1);
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}
				for (char in bgCharacters) {
					char.cheer();
				}
			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Play Animation':
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;

						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				if(camFollow != null)
				{
					var val1:Float = Std.parseFloat(value1);
					var val2:Float = Std.parseFloat(value2);
					if(Math.isNaN(val1)) val1 = 0;
					if(Math.isNaN(val2)) val2 = 0;

					isCameraOnForcedPos = false;
					if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
						camFollow.x = val1;
						camFollow.y = val2;
						isCameraOnForcedPos = true;
					}
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}


			case 'Change Character':
				var charType:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				CharacterSwap.swapChar(charType, value1, value2);
				
				reloadHealthBarColors();

			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2 / playbackRate, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}

		}
	}

	function moveCameraSection():Void {
		if(SONG.notes[curSection] == null#if Pure_Chart_Allowed  && !ClientPrefs.pureChart#end) return;

		if (gf != null && SONG.notes[curSection].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			return;
		}

		if (!SONG.notes[curSection].mustHitSection)
		{
			moveCamera(true);
		}
		else
		{
			moveCamera(false);
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		if(isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}


	public var transitioning = false;
	public function endSong():Void
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}

		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;


			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, 0, percent);
				#end
			}
			playbackRate = 1;

			//if (chartingMode)
			//{
				//openChartEditor();
				//return;
			//}
			if (SONG.song.toLowerCase() != 'foreign-entity' || FreeplayState.been) {
					WeekData.loadTheFirstEnabledMod();
					cancelMusicFadeTween();
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					if (FreeplayState.been) {
						MusicBeatState.switchState(new FreeplayState());
						FlxG.sound.playMusic(backend.Paths.music('freakyMenu'));
					} else {
						if (SONG.song.toLowerCase() == '(re)boot2' || SONG.song.toLowerCase() == '(re)boot1') FinalCutscene.type = 'VIRUS';
						else FinalCutscene.type = 'DEFENDER';
						MusicBeatState.switchState(new states.FinalCutscene());
					}
					changedDifficulty = false;
					
				} else {
					FreeplayState.been = false;
					runningTimers.set('sillyPostSong',
					new FlxTimer().start(1, tmr-> {
						MusicBeatState.switchState(new states.SecurityAlert());
					})
					);
				}
			transitioning = true;
	}

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showCombo:Bool = false;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	private function cachePopUpScore()
	{
		var pixelShitPart1:String = '';
		var pixelShitPart2:String = '';
		if (isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		backend.Paths.image(pixelShitPart1 + "sick" + pixelShitPart2);
		backend.Paths.image(pixelShitPart1 + "good" + pixelShitPart2);
		backend.Paths.image(pixelShitPart1 + "bad" + pixelShitPart2);
		backend.Paths.image(pixelShitPart1 + "shit" + pixelShitPart2);
		backend.Paths.image(pixelShitPart1 + "combo" + pixelShitPart2);
		
		for (i in 0...10) {
			backend.Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2);
		}
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);

		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		//tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(note, noteDiff / playbackRate);

		if (daRating.name == 'sick'){  // why get the rating & shit all over again if its already rated for me?
			for (i in bgCharacters) {
				i.cheerCount++;
			}
		} else if (daRating.name == 'bad' || daRating.name == 'shit' ) {
			for (i in bgCharacters) {
				i.cheerCount = 0;
			}
		}

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if(!note.ratingDisabled) daRating.increase();
		note.rating = daRating.name;
		score = daRating.score;

		if(daRating.noteSplash)
		{
			spawnNoteSplashOnNote(note);
		}

		if(!practiceMode && !cpuControlled) {
			songScore += score;
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating(false);
			}
		}

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(backend.Paths.image(pixelShitPart1 + daRating.image + pixelShitPart2));
		rating.cameras = [camHUD];
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550 * playbackRate * playbackRate;
		rating.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
		rating.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
		rating.visible = (!ClientPrefs.hideHud && showRating);
		rating.x += ClientPrefs.comboOffset[0];
		rating.y -= ClientPrefs.comboOffset[1];

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(backend.Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.cameras = [camHUD];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
		comboSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
		comboSpr.visible = (!ClientPrefs.hideHud && showCombo);
		comboSpr.x += ClientPrefs.comboOffset[0];
		comboSpr.y -= ClientPrefs.comboOffset[1];
		comboSpr.y += 60;
		comboSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;

		insert(members.indexOf(strumLineNotes), rating);
		
		if (!ClientPrefs.comboStacking)
		{
			if (lastRating != null) lastRating.kill();
			lastRating = rating;
		}

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		var xThing:Float = 0;
		if (showCombo)
		{
			insert(members.indexOf(strumLineNotes), comboSpr);
		}
		if (!ClientPrefs.comboStacking)
		{
			if (lastCombo != null) lastCombo.kill();
			lastCombo = comboSpr;
		}
		if (lastScore != null)
		{
			while (lastScore.length > 0)
			{
				lastScore[0].kill();
				lastScore.remove(lastScore[0]);
			}
		}
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(backend.Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.cameras = [camHUD];
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			numScore.x += ClientPrefs.comboOffset[2];
			numScore.y -= ClientPrefs.comboOffset[3];
			
			if (!ClientPrefs.comboStacking)
				lastScore.push(numScore);

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
			numScore.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
			numScore.velocity.x = FlxG.random.float(-5, 5) * playbackRate;
			numScore.visible = !ClientPrefs.hideHud;

			//if (combo >= 10 || combo == 0)
			if(showComboNum)
				insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2 / playbackRate, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002 / playbackRate
			});

			daLoop++;
			if(numScore.x > xThing) xThing = numScore.x;
		}
		comboSpr.x = xThing + 50;

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2 / playbackRate, {
			startDelay: Conductor.crochet * 0.001 / playbackRate
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2 / playbackRate, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.002 / playbackRate
		});
	}

	public var strumsBlocked:Array<Bool> = [];
	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if(!stunnedBF && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (!strumsBlocked[daNote.noteData] && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && !daNote.blockHit)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else{
					if (canMiss) {
						noteMissPress(key);
					}
				}

				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(!strumsBlocked[key] && spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
		}
	}

	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			updateHoldSplash(lastHitNotes[key], false); 
			/*if (key > 3 &&holdNoteSplashes[key] != null && holdNoteSplashes[key].visible) { //if you let go, it will update quicker than if you missed. 
				var name = 'hold buffer $key';
				runningTimers.set(name, new FlxTimer().start(Conductor.crochet/4, tmr -> {
					if (!FlxG.keys.anyPressed([eventKey])) {
						if (splashTimeChange[key] > Conductor.crochet/4) {
							updateHoldSplash(noteReleasedOn, false); // gaslighting
						}
					}
					runningTimers.remove(name);
				}));
			}*/
		}
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var parsedHoldArray:Array<Bool> = parseKeys();

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var parsedArray:Array<Bool> = parseKeys('_P');
			if(parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if(parsedArray[i] && !strumsBlocked[i])
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (startedCountdown && !stunnedBF && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (!strumsBlocked[daNote.noteData] && daNote.isSustainNote && parsedHoldArray[daNote.noteData] && daNote.canBeHit
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.blockHit) {
					goodNoteHit(daNote);
				}
			});

			if (FlxG.sound.music != null) {
				if (#if Pure_Chart_Allowed !ClientPrefs.pureChart && #end boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
					{
						boyfriend.dance();
						//boyfriend.animation.curAnim.finish();
					}
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode || strumsBlocked.contains(true))
		{
			var parsedArray:Array<Bool> = parseKeys('_R');
			if(parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if(parsedArray[i] || strumsBlocked[i]) // why did bro use == true
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	private function parseKeys(?suffix:String = ''):Array<Bool>
	{
		var ret:Array<Bool> = [];
		for (i in 0...controlArray.length)
		{
			ret[i] = Reflect.getProperty(controls, controlArray[i] + suffix);
		}
		return ret;
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		holdNoteSplashes[daNote.noteData] = null;
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;
		health -= daNote.missHealth * healthLoss;
		
		if(instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		#if AeroEvents
		GameplayEvents.NOTE_MISS.dispatch(daNote);
		#end
		//updateHoldSplash(daNote, false);
		for (i in bgCharacters) {
			i.cheerCount = 0;
		}
		songMisses++;
		vocals.volume = 0;
		if(!practiceMode) songScore -= 10;

		totalPlayed++;
		RecalculateRating(true);

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if(char != null && !daNote.noMissAnimation && char.hasMissAnimations)
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daNote.animSuffix;
			char.playAnim(animToPlay, true);
		}

	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if(ClientPrefs.ghostTapping) return; //fuck it

		if (!stunnedBF)
		{
			health -= 0.05 * healthLoss;
			if(instakillOnMiss)
			{
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating(true);

			FlxG.sound.play(backend.Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(backend.Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*stunnedBF = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				stunnedBF = false;
			});*/

			if(boyfriend.hasMissAnimations) {
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			vocals.volume = 0;
		}
	}

	function opponentNoteHit(note:Note):Void
	{
		#if AeroEvents
		GameplayEvents.NOTE_HIT.dispatch(note);
		#end

		if (backend.Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection) {
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if(note.gfNote) {
				char = gf;
			}

			if(char != null)
			{
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
		}

		if (SONG.needsVoices)
			vocals.volume = 1;

		var time:Float = 0.15;
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)), time);
		note.hitByOpponent = true;

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			#if AeroEvents
			GameplayEvents.NOTE_HIT.dispatch(note);
			#end
			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				FlxG.sound.play(backend.Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}
			//holdNoteSplashes[note.noteData] = null;
			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashDisabled) {
					if (!note.isSustainNote) {
						spawnNoteSplashOnNote(note);
					}
				}

				if(!note.noMissAnimation)
				{
					switch(note.noteType) {
						case 'Hurt Note': //Hurt note
							if(boyfriend.animation.getByName('hurt') != null) {
								boyfriend.playAnim('hurt', true);
								boyfriend.specialAnim = true;
							}
					}
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			} 
			lastHitNotes[note.noteData] = note;
			if (!note.noteSplashDisabled) {
				updateHoldSplash(note, true);
			}
			


			if (!note.isSustainNote)
			{
				combo += 1;
				if(combo > 9999) combo = 9999;
				popUpScore(note);
			}
			health += note.hitHealth * healthGain;

			if(#if Pure_Chart_Allowed !ClientPrefs.pureChart && #end !note.noAnimation) {
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				if(note.gfNote)
				{
					if(gf != null)
					{
						gf.playAnim(animToPlay + note.animSuffix, true);
						gf.holdTimer = 0;
					}
				}
				else
				{
					boyfriend.playAnim(animToPlay + note.animSuffix, true);
					boyfriend.holdTimer = 0;
				}

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}

					if(gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)), time);
			} else {
				var spr = playerStrums.members[note.noteData];
				if(spr != null)
				{
					spr.playAnim('confirm', true);
				}
			}
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	public function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

		var hue:Float = 0;
		var sat:Float = 0;
		var brt:Float = 0;
		if (data > -1 && data < ClientPrefs.arrowHSV.length)
		{
			hue = ClientPrefs.arrowHSV[data][0] / 360;
			sat = ClientPrefs.arrowHSV[data][1] / 100;
			brt = ClientPrefs.arrowHSV[data][2] / 100;
			if(note != null) {
				skin = note.noteSplashTexture;
				hue = note.noteSplashHue;
				sat = note.noteSplashSat;
				brt = note.noteSplashBrt;
			}
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash); // i'd like to do this for sustain splashes, but im not fucking with that more than i've had to.
		splash.alpha = strumLineNotes.members[data].alpha;
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	override function destroy() {
		resetEventStuff();
		/*for (room in shaderDepo) {
			for (worker in room) {
				worker.kill();
			}
		}nuh uh uh*/
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		FlxG.animationTimeScale = 1;
		instance = null;
		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();
		#if AeroEvents
		GameplayEvents.CONDUCTOR_STEP.dispatch(curStep);
		#end
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)))
		{
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
	}

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		super.beatHit();
		#if AeroEvents
		#end

		if(lastBeatHit >= curBeat) {
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
		{
			gf.dance();
		}
		if (#if Pure_Chart_Allowed !ClientPrefs.pureChart && #end curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !stunnedBF)
		{
			boyfriend.dance();
		}
		if (#if Pure_Chart_Allowed !ClientPrefs.pureChart && #end curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !stunnedDAD)
		{
			dad.dance();
		}

		#if Pure_Chart_Allowed if (!ClientPrefs.pureChart) { #end
			for (char in bgCharacters) {
				if ((curBeat) % char.danceEveryNumBeats == 0 && char.animation.curAnim != null && !(char.isCheering)) {
					char.dance();
				}
			}
		#if Pure_Chart_Allowed } #end

		lastBeatHit = curBeat;

		GameplayEvents.CONDUCTOR_BEAT.dispatch(curBeat);

	}

	override function sectionHit()
	{
		super.sectionHit();


		if (SONG.notes[curSection] != null #if Pure_Chart_Allowed  && !ClientPrefs.pureChart #end)
		{
			for (char in bgCharacters) {
				char.mustHit = SONG.notes[curSection].mustHitSection;
			}
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
			{
				moveCameraSection();
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && hitOnBeat != 2)
			{
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
			}

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[curSection].bpm);
			}
		}

		GameplayEvents.CONDUCTOR_SECTION.dispatch(curSection);
	}

	
	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating(badHit:Bool = false) {
			if(totalPlayed < 1) //Prevent divide by 0
				ratingName = '?';
			else
			{
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));

				// Rating Name
				if(ratingPercent >= 1)
				{
					ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				}
				else
				{
					for (i in 0...ratingStuff.length-1)
					{
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (sicks > 0) ratingFC = "SFC";
			if (goods > 0) ratingFC = "GFC";
			if (bads > 0 || shits > 0) ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
			else if (songMisses >= 10) ratingFC = "Clear";
		updateScore(badHit); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce -Ghost
	}

	public function createStage(stage:String, ?preload:Bool = false) { // yayayaya actual function
		if (!preload) {
			curStage = stage;
			bgGroup = new FlxTypedGroup<Dynamic>();
			foregroundGroup = new FlxTypedGroup<Dynamic>();
		}
		var bgArray:Array<Array<Dynamic>> = [];
		//split into 2, bg and fg
		if (ClientPrefs.shaders) {
			sillyShader = new SonicDotExe();
			var filter = new ShaderFilter(sillyShader);
			this.shaderDepo[0].push(filter);
			this.shaderDepo[1].push(filter);
		}
		switch (stage)
		{
			case 'Computer1' | 'ComputerEvil' | 'ComputerGood':

				var path = 'bg/computer/';

				if (stage == 'ComputerEvil') {
					path = 'bg/computerEvil/';
					ZBall.type = 'bad';
				} else if (stage == 'ComputerGood') {
					path = 'bg/computerGood/';
					ZBall.type = 'what';
				} else {
					ZBall.type = 'good';
				}

				var sky = new BGSprite(path+'sky',0,0,0,0);
				sky.scale.set(2,2);
				sky.screenCenter();

				var buildings1 = new BGSprite(path+'buildings1', 0, 0, 0.05, 0.6);
				buildings1.scale.set(1.25,1.25);
				buildings1.screenCenter();
				buildings1.y -= 175;

				var buildings2 = new BGSprite(path+'buildings2', 0, 0, 0.1375, 0.7);
				buildings2.scale.set(1.25,1.25);
				buildings2.screenCenter();

				var buildings3 = new BGSprite(path+'buildings3', 0, 0, 0.225, 0.8);
				buildings3.scale.set(1.25,1.25);
				buildings3.screenCenter();

				var haze = new BGSprite(path+'haze', 0, 0, 0, 1);
				haze.scale.set(1.25,1.25);
				haze.screenCenter();

				haze.y += 425;

				var floor = new BGSprite(path+'floor', 0, 0, 1, 1);
				floor.screenCenter();
				floor.scale.set(1.25,1.25);

				floor.y += 325;

				var iconsFar:FlxSpriteGroup = null;
				var iconsMid:FlxSpriteGroup = null;
				var iconsFinal:FlxSpriteGroup = null;
				var logo:BGSprite = null;
				
				SillyThing.total = 0;
				SillyThing.time = 0;
				
				if (stage == 'Computer1' || stage == 'ComputerGood') {
					GameplayEvents.GAME_UPDATE.add(e -> {
						SillyThing.time += e;
					});
				}

				if (stage == 'Computer1') {
					iconsFar = new FlxSpriteGroup();
					iconsFar.scrollFactor.set(buildings1.scrollFactor.x,buildings1.scrollFactor.y);
	
					var logos = ['google','SEXOOO'];
					var offsets = [[-700, -750],[1100,-675]];
	
					if (!ClientPrefs.lowQuality) {
						for (i in 0...logos.length) { 
							var img = new SillyThing('bg/computerIcons/'+logos[i], 0, 0,0,0);
							img.scale.set(1.25, 1.25);
							img.screenCenter();
							img.x += offsets[i][0];
							img.y += offsets[i][1];
							img.baseY = img.y;
							img.sillyX = buildings1.scrollFactor.x;
							iconsFar.add(img);
						}
						iconsMid = new FlxSpriteGroup();
						iconsMid.scrollFactor.set(buildings2.scrollFactor.x,buildings2.scrollFactor.y);
						
						logos = ["web", "pinterest", "ng", "github", "miiverse"];
						offsets = [[-1100,-600],[-700,-350],[350,-400],[900,-600],[2450,-750]];
						
						for (i in 0...logos.length) {
							var img = new SillyThing('bg/computerIcons/'+logos[i], 0, 0,0,0);
							img.scale.set(1.25, 1.25);
							img.screenCenter();
							img.x += offsets[i][0];
							img.y += offsets[i][1];
							img.sillyX = buildings2.scrollFactor.x;
							img.baseY = img.y;
							iconsMid.add(img);
						}
					
						iconsFinal = new FlxSpriteGroup();
						iconsFinal.scrollFactor.set(buildings3.scrollFactor.x,buildings3.scrollFactor.y);
					
						logos = ["youtube", "arrow", "gamebanana"];
						offsets = [[-1450,-750],[-600,-150],[600,-250]];
					
						for (i in 0...logos.length) {
							var img = new SillyThing('bg/computerIcons/'+logos[i], 0, 0,0,0);
							img.scale.set(1.25, 1.25);
							img.screenCenter();
							img.x += offsets[i][0];
							img.y += offsets[i][1];
							img.baseY = img.y;
							img.sillyX = buildings3.scrollFactor.x;
							iconsFinal.add(img);
						}
					}
				} else {
					if (stage == 'ComputerEvil') {
						logo = new BGSprite('bg/computerEvil/bad', 0, 0, buildings3.scrollFactor.x, buildings3.scrollFactor.y);
						logo.screenCenter();
						logo.y -= 150;
						runningTweens.set('logo thingy', FlxTween.tween(logo, {y:logo.y -200}, 15, {ease:FlxEase.smoothStepInOut, type:PINGPONG}));
						logo.alpha = 0.75;
						if (ClientPrefs.lowQuality) logo.alpha -= 0.25;
						else logo.blend = BlendMode.ADD;
						GameplayEvents.CONDUCTOR_SECTION.add(s->{
							if (SONG.notes[s].mustHitSection) {
								cameraProperties[0] = 0.6;
							} else {
								cameraProperties[0] = cameraProperties[2];
							}
						});
					} else {
						logo = new BGSprite('bg/computerGood/good', 0, 0, buildings3.scrollFactor.x, buildings3.scrollFactor.y);
						logo.screenCenter();
						logo.y -= 150;
						runningTweens.set('logo thingy', FlxTween.tween(logo, {y:logo.y -200}, 15, {ease:FlxEase.smoothStepInOut, type:PINGPONG}));
						logo.alpha = 0.75;
						if (ClientPrefs.lowQuality) logo.alpha -= 0.25;
						else logo.blend = BlendMode.ADD;
					}
				}

				var ballGroup:FlxTypedSpriteGroup<ZBall> = new FlxTypedSpriteGroup<ZBall>();

				if (!ClientPrefs.lowQuality) {
					var newBall = () -> {
						var initScale:Float = FlxG.random.float(ZBall.scaleBounds.min, ZBall.scaleBounds.max);
						var silly = Math.max(0, ((ZBall.scaleBounds.max-(initScale))/ZBall.scaleBounds.max) - 0.25);
	
						var ball = new ZBall(initScale);
						ball.scrollFactor.set(0.35 - (silly), 0.9125);
		
						ball.x = ZBall.posBounds.max+FlxG.random.float(0, 200)+(silly*750);
						ball.x -=50;
		
						var timeOffs = FlxG.random.float(1, -2);
	
	
						timeOffs -= silly*5;
	
						var tot = ZBall.total;
						runningTweens.set('zballZ$tot', FlxTween.tween(ball, {z:1}, 5-timeOffs));
						runningTweens.set('zballX$tot',FlxTween.tween(ball, {x:(ZBall.posBounds.min-(silly*750))-FlxG.random.float(0, 200)}, 5-timeOffs, {ease:FlxEase.quadInOut, onComplete: twn -> {
							ballGroup.remove(ball);
							ball.kill();
							ball = null;
							runningTweens.remove('zballZ$tot');
							runningTweens.remove('zballX$tot');
						}}));
						ballGroup.add(ball);
					}
					GameplayEvents.CONDUCTOR_STEP.add(b->{
						newBall();
						newBall();
	
						
						new FlxTimer().start(Conductor.crochet/2, tmr -> {
							newBall();
							newBall();
						});
					});
					GameplayEvents.GAME_UPDATE.add(b->{
						ballGroup.sort(ZBall.sortByZ);
					});
				}
			

				var secondArray = [];

				if (stage == 'ComputerEvil' || stage == 'ComputerGood') {
					var overlay = new BGSprite(path+'overlay', 0, 0, 0, 0);
					overlay.scale.set(1.2,1.2);
					overlay.screenCenter();
					overlay.blend = ADD;
					overlay.alpha = 0.25;
					secondArray.push(overlay);
				}


				if (SONG.song.toLowerCase() == '(re)boot2') {
					skipCountdown = true;
					cover = new FlxSprite().makeGraphic(1280,720,0xFF000000);
					cover.cameras = [camHUD];
					add(cover);
					new FlxTimer().start(1.5, tmr -> {
						FlxTween.tween(cover, {alpha:0}, 0.15);
					});
				}

				if (stage == 'Computer1') {
					if (ClientPrefs.lowQuality) {
						bgArray = [[sky, buildings1, buildings2, buildings3, ballGroup, haze, floor],secondArray];
					} else {
						bgArray = [[sky, buildings1, iconsFar, buildings2, iconsMid, buildings3, iconsFinal, ballGroup, haze, floor],secondArray];
					}
				} else if (stage == 'ComputerEvil' || stage == 'ComputerGood') {
					bgArray = [[sky, buildings1, buildings2, buildings3, logo, ballGroup, haze, floor],secondArray];
				}
			case 'spooky': //playtesting
				var halloweenBG:BGSprite;
				if(!ClientPrefs.lowQuality) {
					halloweenBG = new BGSprite('bg/halloween/hq', -200, -85, ['creepyHouse0', 'creepyHouse lightning strike']);
				} else {
					halloweenBG = new BGSprite('bg/halloween/lq', -200, -85);
				}
				add(halloweenBG);
				bgArray = [[halloweenBG], []];

				var lightningStrikeBeat:Int = 0;
				var lightningOffset:Int = 0;
				
				GameplayEvents.CONDUCTOR_BEAT.add(cb -> {

					if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
					{
						var snd = FlxG.sound.play(Paths.soundRandom('stageSounds/halloween/thunder_', 1, 2));
						runningSounds.set('lightning', snd);
						snd.onComplete = () -> {runningSounds.remove('lightning');}
						if(!ClientPrefs.lowQuality) halloweenBG.animation.play('creepyHouse lightning strike');
				
						lightningStrikeBeat = curBeat;
						lightningOffset = FlxG.random.int(8, 24);
				
						if(boyfriend.animOffsets.exists('scared')) {
							boyfriend.playAnim('scared', true);
						}
				
						if(gf != null && gf.animOffsets.exists('scared')) {
							gf.playAnim('scared', true);
						} 
				
						if(ClientPrefs.camZooms) {
							FlxG.camera.zoom += 0.015;
							camHUD.zoom += 0.03;
						}
					}

				});
			case 'stage':
				var bg:BGSprite = new BGSprite('bg/stage/stageback', -600, -200, 0.9, 0.9);

				var stageFront:BGSprite = new BGSprite('bg/stage/stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				var pico = new BGCharacter('picoBG');
				pico.scrollFactor.set(0.9,0.9);
				bgCharacters.push(pico);
				bgArray.push([bg, stageFront, pico]);
				if(!ClientPrefs.lowQuality) {
					var fg:Array<Dynamic> = [];
					var stageLight:BGSprite = new BGSprite('bg/stage/stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					fg.push(stageLight);
					var stageLight:BGSprite = new BGSprite('bg/stage/stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					fg.push(stageLight);

					var stageCurtains:BGSprite = new BGSprite('bg/stage/stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					fg.push(stageCurtains);

					var file = StageData.getStageFile(stage);


					bgArray.push(fg);
				}
		}

		bgArray.push([StageData.getStageFile(stage)]);

		if (useBgMap) {
			bgMap.set(stage, bgArray);
		}
		if (!preload) {
			for (i in bgArray[0]) {
				bgGroup.add(i);
			};
			if (bgArray[1] != null) {
				for (i in bgArray[1]) {
					foregroundGroup.add(i);
				}
			}
			
		}
	}

	public function changeBG(stage:String) {
		if (bgMap.exists(stage)) {
			var f = bgMap.get(stage);
			var bg = f[0];
			var fg = f[1];
			//there should be no reason to make a 3rd layer, right? right???

			for (i in bgGroup.members) {
				remove(i, true); //for some reason, some objects wont be removed.
				bgGroup.remove(i, true); // remove all the bg stuff from the game
				if (bgCharacters.contains(i)) {
					remove(i);
					bgCharacters.remove(i);
				}
			}

			for (i in foregroundGroup.members) {
				remove(i, true);
				foregroundGroup.remove(i, true); // do the same for the foreground
			
				if (bgCharacters.contains(i)) {
					foregroundGroup.remove(i, true);
					bgCharacters.remove(i);
				}
			}
			for (i in bg) bgGroup.add(i); // add the members from the incoming group
			for (i in fg) foregroundGroup.add(i);
			curStage = stage;	

			var js:StageFile = f[2][0];
			//there was a reason to make a 3rd layer

			dadGroup.setPosition(js.opponent[0], js.opponent[1]); //move then to where they should be
			opponentCameraOffset = js.camera_opponent; //also fix his cam offset
			boyfriendGroup.setPosition(js.boyfriend[0], js.boyfriend[1]);
			boyfriendCameraOffset = js.camera_boyfriend;
			if (gf != null) { //I aint doin allat
				gfGroup.setPosition(js.girlfriend[0], js.girlfriend[1]);
				gfGroup.visible = !js.hide_girlfriend;
				girlfriendCameraOffset = js.camera_girlfriend;
			}

			camGame.zoom = js.defaultZoom;
			cameraProperties[0] = js.defaultZoom;
			cameraProperties[2] = js.defaultZoom;
			cameraProperties[3] = js.maximumZoom; // update the camera accordingly
			
		} else {
			throw new Exception('$stage is not a stage in the bgMap!');
		}
	}
	#if (sys && cpp)
	function startSongCutscene() { // these functions are to only be used by the intro cutscene!
		var cutscene:FlxVideoSprite;
		var cover:FlxSprite = null;
		var csDat:Cutscene = null;
		if (CutsceneHandler.cutscenesByName.exists('GameplayIntroCutscene')) { // if the cutscene actually exists
			csDat = CutsceneHandler.cutscenesByName.get('GameplayIntroCutscene'); // then get the cutscene
			cutscene = csDat.cutsceneObject; // the video itself
			cutscene.bitmap.position = 0;
			switch(SONG.cutscene.coverType) { // the cover that appears before the cutscene
				case 'color':
					cover = new FlxSprite().loadGraphic(FlxGraphic.fromBitmapData(new BitmapData(1280, 720, false, Std.parseInt(SONG.cutscene.coverVal)))); //it wont work any other way and I have no clue why
				case 'image':
					cover = new FlxSprite().loadGraphic(backend.Paths.image(SONG.cutscene.coverVal));
					cover.scale.set(SONG.cutscene.coverScale[0], SONG.cutscene.coverScale[1]);
				default:
					cover = new FlxSprite();
			}
			csDat.coverObject = cover;
		} else {
			FlxG.log.warn('FUCK YOU!!! YOU FORGOT TO CACHE ${SONG.cutscene.filePath}');
			throw new Exception('FUCK YOU!!! YOU FORGOT TO CACHE ${SONG.cutscene.filePath}');
		}
		if (cutscene.cameras != [camHUD]) {
			cutscene.cameras = [camHUD];
			cutscene.scrollFactor.set(0,0);
			cutscene.centerOrigin();
			cutscene.screenCenter(); // make sure the camera is set
		}
		cutscene.visible = false;
		cover.cameras = [camHUD];
        cover.scrollFactor.set(0,0);
		cover.centerOrigin();
		cover.screenCenter();
		cover.visible = true;
		add(cover);

		

		add(cutscene);
		
		csDat.cutsceneObject = cutscene;
		
		if (SONG.cutscene.beginningDelay != 0) {
			//i know this isnt its intended use, but it would be dumb to make another variable. + if theres ever a scenario where the fade time intersects with the beginning time thats your problem lol
			// - eggu
			csDat.fadeTimer = new FlxTimer().start(SONG.cutscene.beginningDelay, tmr -> {playCutscene();}); 
		} else {
			playCutscene(); // if theres no beginning delay dont even bother with a timer
		}
		if (SONG.cutscene.canSkip) {
			var pauseCheck:Bool->Void;
			pauseCheck = p -> {
				if (p) { // hehehehehehe if p (it sounds like if pee)
					promptSkip();
					GameplayEvents.GAME_PLAYUPDATE.remove(pauseCheck);
				}
			}
			cutscene.bitmap.onEndReached.add(() -> {
				if (GameplayEvents.GAME_PLAYUPDATE.has(pauseCheck)) 
					GameplayEvents.GAME_PLAYUPDATE.remove(pauseCheck);
			});
			GameplayEvents.GAME_PLAYUPDATE.add(pauseCheck);
		}
	}

	public function resumeCutscene() { // when you decide not to skip t he cutscene
		var csDat = CutsceneHandler.cutscenesByName.get('GameplayIntroCutscene');
		if (csDat.cutsceneObject.bitmap != null) 
			csDat.cutsceneObject.resume();
		if (csDat.fadeTimer != null)
			csDat.fadeTimer.active = true;
		if (csDat.fadeTween != null)
			csDat.fadeTween.active = true;
		var pauseCheck:Bool->Void;
		pauseCheck = p -> {
			if (p) { 
				promptSkip();
				GameplayEvents.GAME_PLAYUPDATE.remove(pauseCheck);
			}
		}
		GameplayEvents.GAME_PLAYUPDATE.add(pauseCheck);
	}

	public function promptSkip() { // when you prompt the game to skip the cutscene (suprising ik), this exists just to open the substate and pause all the related items
		var csDat = CutsceneHandler.cutscenesByName.get('GameplayIntroCutscene');
		var cover = csDat.coverObject;
		if (csDat.cutsceneObject.bitmap != null) {
			csDat.cutsceneObject.pause();
			cutscenePaused = true;
		}
		if (csDat.fadeTimer != null)
			csDat.fadeTimer.active = false;
		if (csDat.fadeTween != null)
			csDat.fadeTween.active = false;
		openSubState(new states.substates.SkippingCutsceneSubstate());
	}

	function playCutscene() { // actually play the cutscene itself
		var csObj = CutsceneHandler.cutscenesByName.get('GameplayIntroCutscene');
		var cover = csObj.coverObject;
		var cutscene:FlxVideoSprite = csObj.cutsceneObject;
		cutscene.stop();
		cutscene.play();
		cutscene.alpha = 1;
		new FlxTimer().start(SONG.cutscene.beginningDelay + 0.25, tmr -> {
			if (cover != null && !SONG.cutscene.constantCover) {
				remove(cover);
				cover.visible = false;
			}
		});
		var skibidi = () -> { // just make sure the cutscene looks fine - especially for non-16:9 cutscenes
			cutscene.visible = true;
			cutscene.centerOrigin();
			cutscene.screenCenter();
			cutscene.bitmap.onDisplay.removeAll();
		};
		cutscene.bitmap.onDisplay.add(skibidi);
		if (SONG.cutscene.fadeOutTime != 0) {
			cutscene.bitmap.onOpening.add(() -> {
				trace(((Int64.toInt(cutscene.bitmap.length))/1000)); //int to int......
				csObj.fadeTimer = new FlxTimer().start(((Int64.toInt(cutscene.bitmap.length))/1000) - SONG.cutscene.fadeOutTime, tmr -> { // fade out on end
					csObj.fadeTween = FlxTween.tween(csObj, {"cutsceneObject.alpha":0, "coverObject.alpha":0}, SONG.cutscene.fadeOutTime);
				});
			});
		}
		cutscene.bitmap.onEndReached.add(() -> {cutsceneFinished();});
	}

	function cutsceneFinished() { // when the cutscene is nah yknow what figure it out on your own
		var cutscene = CutsceneHandler.cutscenesByName.get('GameplayIntroCutscene');
		var cover = cutscene.coverObject;
		if (SONG.cutscene.constantCover) 
			cover.visible = false;
		seenCutscene = true;
		var obj:FlxVideoSprite = cutscene.cutsceneObject;
		if (obj != null) {
			cutscene.cutsceneObject.stop();
		}
		cutscene.fadeTimer = null;
		cutscene.fadeTween = null;
		obj.visible = false;
		remove(obj);
		startCountdown();
	}

	public function skipCutscene() {
		var cutscene = CutsceneHandler.cutscenesByName.get('GameplayIntroCutscene');
		var cover = cutscene.coverObject;
		if (!SONG.cutscene.constantCover)
			cover.visible = false;
		if (cutscene.fadeTimer != null)  // basically reset the cutscene incase its reused
			cutscene.fadeTimer.cancel();	
		if (cutscene.fadeTween != null) 
			cutscene.fadeTween.cancel();
		if (cutscene.cutsceneObject != null) {
			if (SONG.cutscene.fadeOnSkip) {
				var fadeTime:Float = 0.5;
				if (SONG.cutscene.fadeOutTime/4 > 0.25) { // i forgot why this exists tbhs
					fadeTime = SONG.cutscene.fadeOutTime/4; // we love fading out
				}
				FlxTween.tween(cutscene.cutsceneObject, {alpha:0}, fadeTime, {onComplete: twn -> {cutsceneFinished();}});
			} else {
				cutscene.cutsceneObject.bitmap.onEndReached.removeAll();
				cutsceneFinished();
			}
		} else {
			cutsceneFinished();
		}
	}
	#end
	public static function exitStuff() { //when you exit back to the main menu for whatever reason - idk why shadowmario didnt do this in base psych (-eggu)
		accessed = false;
		deathCounter = 0;
		seenCutscene = false;
		chartingMode = false;
		FlxG.sound.playMusic(backend.Paths.music('freakyMenu'));
		WeekData.loadTheFirstEnabledMod();
	}

	function resetEventStuff() {
		EventsCore.resetSong();
	}

	function updateHoldSplash(note:Note, hit:Bool, ?pos:PosInfos) { // updates the hold splashes! note is the note that was hit, and hit was if it was hit or not
		if (hit) {
			if ((holdNoteSplashes[note.noteData] == null) && (!note.animation.curAnim.name.contains('end')) && note.isSustainNote) { // the circumstances in which it would need to make a new splash
				var splash = new HoldNoteSplash(note.noteData);
				splash.ID = note.ID;
				splash.setPosition(strumLineNotes.members[note.noteData+4].x - 110, strumLineNotes.members[note.noteData+4].y - 100);
				holdNoteSplashes[note.noteData] = splash;
				splash.animState = 'hold';
				splash.start();
				grpSusSplash.add(splash);
				splashTimeChange[note.noteData] = 0;
			} /*else if (note.animation.curAnim.name.contains('end') && holdNoteSplashes[note.noteData] != null && note.nextNote != null && !note.nextNote.isSustainNote) { // or, if it shouldnt make one but the sustain is the last in the sequence
				var thisNote = holdNoteSplashes[note.noteData].ID;
				var lasthitid = lastHitNotes[note.noteData].ID;
				new FlxTimer().start(Conductor.crochet/4000, tmr -> { // best way i can think of doing it, its not that good but it works
					if (holdNoteSplashes[note.noteData] != null && splashTimeChange[note.noteData] >= Conductor.crochet/4000 && thisNote == holdNoteSplashes[note.noteData].ID && holdNoteSplashes[note.noteData].animation.curAnim.name != 'end' && lasthitid == lastHitNotes[note.noteData].ID) {
						holdNoteSplashes[note.noteData].kill();
					}
				}); 
			} */else if (holdNoteSplashes[note.noteData] != null) {
				holdNoteSplashes[note.noteData].updated();
			}
		} else if (note != null && note.animation != null) {
			if (note.animation.curAnim.name.contains('end') && holdNoteSplashes[note.noteData] != null) { // if you let go on the end of a sustain then make it pop!
				holdNoteSplashes[note.noteData].animation.play('end');
				holdNoteSplashes[note.noteData] = null;
				for (char in bgCharacters) {
					char.cheerCount++;
				}
			} else if (holdNoteSplashes[note.noteData] != null) { // or, if you didnt let go on the end then just make it die
				holdNoteSplashes[note.noteData].kill();
			}
		}
	}

	function updateShaderDepo() { // synchronize the shaders with the cameras
		camGame.filters = shaderDepo[0];
		camHUD.filters = shaderDepo[1];
		camOther.filters = shaderDepo[2];
	}
}