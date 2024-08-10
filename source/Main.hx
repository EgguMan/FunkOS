package;

import openfl.geom.Point;
import flixel.math.FlxAngle;
#if cpp
import hxvlc.openfl.Video;
#end
import openfl.display.Shape;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.geom.Rectangle;
import states.MusicBeatState;
import flixel.math.FlxMath;
import openfl.display.Stage;
import openfl.events.FocusEvent;
#if cpp
import cpp.vm.Gc;
#end
import flixel.text.FlxText;
import haxe.Timer;
import openfl.events.MouseEvent;
import openfl.ui.Mouse;
import flixel.util.FlxTimer;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
#if (cpp && sys)
import hxvlc.util.Handle;
#end
import states.FirstState;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import backend.save.ClientPrefs;

//crash handler stuff
#if CRASH_HANDLER
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import backend.Discord.DiscordClient;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end

import flixel.addons.transition.FlxTransitionableState;

using StringTools;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = FirstState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 165; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	public static var fpsVar:FPS;

	public static final saveName =   'AeroEngine_globals';
	public static final saveNameCONTROLS =   'AeroEngine_keybinds';
	public static final saveAuthor = 'Eggu';

	// When I watch the world burn all I think about is you

	public var flxWindow:Window;
	public static var instance:Main; 

	static var bmpBG:BitmapData;
	static var bmpTaskbar:BitmapData;

	public static var loaded(default, set):Int = 0;
	
	public static function set_loaded(inp:Int) {
		trace(inp + ' LOADED');
		loaded = inp;
		return inp;
	}

	public var hold:Bool = false;

	public var taskbar:Bitmap;
	public var time:Time;

	var gameExists:Bool = false;

	final icons:Array<String> = ['Story Mode', 'Freeplay', 'Credits', 'Notepad', 'Calculator', 'Team Fortress 2'];
	final gameplayIcons:Array<String> = ['Story Mode', 'Freeplay', 'Credits'];
	var iconObjects:Array<DesktopIcon> = [];
	public var taskbarIcons:Array<TaskbarIcon> = [];

	var overFlx:Bool = false;
	var canSilly:Bool = false;

	var numByType:Map<String, Int> = [
	'Notepad'=>0,
	'FlxWindow'=>0,
	'Calculator'=>0,
	'Team Fortress 2'=>0
	];


	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();
		Lib.application.window.fullscreen = true;
		Lib.application.window.focus();
		Lib.current.stage.frameRate = 60;
		instance = this;

		#if (cpp && sys)
		trace('initializing libvlc instance');
		Handle.initAsync();
		#end

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		#if noDesktop
		setupGame();
		fpsVar = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if(fpsVar != null) {
			fpsVar.visible = ClientPrefs.showFPS;
		}
		#else
		Lib.application.window.onFocusOut.add(() -> {
			trace('sigma');
			Lib.application.window.focus();
			Lib.application.window.maximized = true;
			Lib.application.window.fullscreen = true;
		});
		bootUp();
		#end
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		//addChild(flxWindow);

		#if !noDesktop
		BitmapData.loadFromFile('assets/ui/images/computer/wallpaper.png').onComplete(bmp -> {		
			bmpBG = bmp;
			imageLoaded();
		});

		BitmapData.loadFromFile('assets/ui/images/computer/taskbar.png').onComplete(bmp -> {		
			bmpTaskbar = bmp;
			imageLoaded();
		});

		BitmapData.loadFromFile('assets/ui/images/computer/applications/shortcut.png').onComplete(bmp -> {		
			DesktopIcon.shortcutBmp = bmp;
			imageLoaded();
		});

		BitmapData.loadFromFile('assets/ui/images/computer/header.png').onComplete(bmp -> {
			Window.headerBmp = bmp;
			imageLoaded();
		});

		BitmapData.loadFromFile('assets/ui/images/computer/minimize.png').onComplete(bmp -> {
			Window.minimizeBMP = bmp;
			imageLoaded();
		});

		BitmapData.loadFromFile('assets/ui/images/computer/close.png').onComplete(bmp -> {
			Window.closeBMP = bmp;
			imageLoaded();
		});

		BitmapData.loadFromFile('assets/ui/images/computer/maximize.png').onComplete(bmp -> {
			Window.maximizeBMP = bmp;
			imageLoaded();
		});

		var tmr = new haxe.Timer(1/24).run = update;

		for (i in icons) {
			var icon = new DesktopIcon(i);
			trace('meow');
			iconObjects.push(icon);
		}


		#else 
		addChild(new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, false));
		FlxG.autoPause = false;
		#end

		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
	}

	function imageLoaded() {
		loaded++;
		if (loaded == 6) imagesLoaded();
	}

	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "PsychEngine_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					var pref = 'source/';
					var useFile = ""+file;
					if ((""+file).contains('\\')) {
						pref = '';
						useFile = useFile.replace('\\', '/');
					}
					errMsg += '[${callStack.lastIndexOf(stackItem)}] called from {'+pref + useFile + ':$line}';
					if (callStack.lastIndexOf(stackItem) == 0) errMsg += ' <---- (this is probably where you need to look!)\n';
					else errMsg+='\n';
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error + "\nIf you got this from a default feature, eg credits, bg characters, etc, then submit a report on the github!\nhttps://github.com/EgguMan/AeroEngineFNF/issues\n\n> Crash Handler written by: sqirra-rng, modified by the funny eggu";

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");
		DiscordClient.shutdown();
		Sys.exit(1);
	}
	#end

	function imagesLoaded() {
		
		var bg = new Bitmap(bmpBG);
		addChild(bg);

		bg.scaleX = CoolUtil.windowScaleRatio.x;
		bg.scaleY = CoolUtil.windowScaleRatio.y;

		for (i in iconObjects) {
			i.x = 30;
			var j = iconObjects.lastIndexOf(i);
			i.y = 30 + (j * 110);
			addChild(i);
			i.onPress = bool -> {
				iconClicked(i.name);
			}
		}

		taskbar = new Bitmap(bmpTaskbar);
		addChild(taskbar); 
		taskbar.scaleX = CoolUtil.windowScaleRatio.x;
		taskbar.scaleY = CoolUtil.windowScaleRatio.y;
		taskbar.y = Lib.application.window.height-(taskbar.height);

		time = new Time();
		addChild(time);
		#if debug
		time.x = Lib.application.window.width - (time.width+5);
		time.y = Lib.application.window.height - (time.height+2);
		#else
		time.x = Application.current.window.width - (time.width+5);
		time.y = Application.current.window.height - (time.height+2);
		#end

		addEventListener(MouseEvent.MOUSE_DOWN, down);
		addEventListener(MouseEvent.MOUSE_UP, up);

		#if !mobile
		fpsVar = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if(fpsVar != null) {
			fpsVar.visible = ClientPrefs.showFPS;
		}
		#end
	}

	function update() {
		if (time != null) {
			time.update();
		}
		for (i in 0...taskbarIcons.length) {
			var icon = taskbarIcons[i];
			icon.x = FlxMath.lerp(icon.x, 50 + (64*i), 1/20);
		}
		if (FlxG.mouse != null) FlxG.mouse.visible = true;
	}

	function down(event:MouseEvent) {
		//trace('down');
		hold = true;
		if (flxWindow != null && flxWindow.visible && canSilly) {
			if (!flxWindow.hitTestPoint(mouseX, mouseY)) {
				@:privateAccess flxWindow.windowContent.onFocusLost();
			} else {
				@:privateAccess flxWindow.windowContent.onFocus();
			}
		}

		for (i in taskbarIcons) {
			if (i.hitTestPoint(mouseX, mouseY, false)) {
				i.click();
			}
		}
	}

	function up(event:MouseEvent) {
		//trace('up');
		hold = false;
	}

	var totalt:Float = 0;

	function newFlxWindow() {
		numByType.set('flxWindow', 1);
		flxWindow = new Window("Friday Night Funkin'");
		flxWindow.windowContent = new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, true);
		flxWindow.loadBar();
		flxWindow.setSize(Lib.application.window.width);
		flxWindow.scaleX = 0.5;
		flxWindow.scaleY = 0.5;
		flxWindow.x = (Lib.current.width/2) - (flxWindow.width/2);
		flxWindow.y = (Lib.current.height/2) - (flxWindow.height/8);
		flxWindow.addEventListener(MouseEvent.MOUSE_OVER, ms -> {overFlx = true;});
		flxWindow.addEventListener(MouseEvent.MOUSE_OUT, ms -> {overFlx = false;});
		FlxG.mouse.useSystemCursor = true;
		addChildAt(flxWindow, getChildIndex(taskbar));
		Timer.delay(() -> {canSilly = true;}, 5000);
	}

	public function addIcon(window:Window) {
		window.visible = false;

		addChild(window.icon);
		taskbarIcons.push(window.icon);

		window.icon.y = taskbar.y + ((taskbar.height/2) - (window.icon.height/2));
		window.icon.x = taskbar.width/2;
		trace(window.icon.name);
	}

	public function deleteWindow(window:Window) {
		numByType.set(window.name, numByType.get(window.name)-1);
		window.icon.kill();
		if (this.contains(window.icon)) {
			removeChild(window.icon);
		}
		window.visible = false;
		removeChild(window);
		window.icon = null;
		window.kill();
		window = null;
		#if cpp
		Gc.run(false);
		#end
	}

	public function bringBackWindow(window:Window) {
		window.visible = true;

		Main.instance.removeChild(window);
        Main.instance.addChildAt(window, Main.instance.getChildIndex(Main.instance.taskbar));

		removeChild(window.icon);
		taskbarIcons.remove(window.icon);
	}

	function iconClicked(iconName:String) {
		if (gameplayIcons.contains(iconName)) {
			menuButtonPress(iconName);
		} else {
			switch(iconName) {
				case 'Notepad':
					newNotepad();
				case 'Calculator':
					newCalculator();
				case 'Team Fortress 2':
					openTF2();
					trace('yup');
				default:
					trace('WARNING! $iconName DOES NOT EXIST');
			};
		}
	}

	function newNotepad() {
		numByType.set('Notepad', numByType.get('Notepad')+1);
		var window = new Notepad('Notepad');
		window.loadBar();
		window.setSize(360, -1);
		window.x = (Lib.current.width/2) - (window.width/2) + (25 * (numByType.get('Notepad')-1));
		window.y = (Lib.current.height/2) - (window.height/2) + (25 * (numByType.get('Notepad')-1));
		addChildAt(window, getChildIndex(taskbar));
	}

	function newCalculator() {
		numByType.set('Calculator', numByType.get('Calculator')+1);
		var window = new Window('Calculator');
		window.windowContent = new Calculator();
		window.loadBar();
		window.setSize(280);
		window.x = (Lib.current.width/2) - (window.width/2) + (25 * (numByType.get('Calculator')-1));
		window.y = (Lib.current.height/2) - (window.height/2) + (25 * (numByType.get('Calculator')-1));
		addChildAt(window, getChildIndex(taskbar));
	}

	function menuButtonPress(name:String) {
		if (flxWindow == null) {
			newFlxWindow();
		} else if (FlxG.sound.music != null && !(FlxG.state is states.PlayState)) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			switch(name) {
				case 'Story Mode':
					MusicBeatState.switchState(new states.MainMenuState());
				case 'Freeplay':
					MusicBeatState.switchState(new states.FreeplayState());
				case 'Credits':
					MusicBeatState.switchState(new states.CreditsState());
			}
			if (!flxWindow.visible) {
				bringBackWindow(flxWindow);
			}
			Timer.delay(() -> {@:privateAccess flxWindow.windowContent.onFocus();}, 1);
		}
	}

	function openTF2() {
		if (numByType.get('Team Fortress 2') != 1) {
			numByType.set('Team Fortress 2', 1);
			var window = new Window('Team Fortress 2');
			window.windowContent = new TF2Game();
			window.loadBar();
			window.setSize(1280);
			window.x = (Lib.current.width/2) - (window.width/2);
			window.y = (Lib.current.height/2) - (window.height/2);
			addChildAt(window, getChildIndex(taskbar));
		}
	}

	var totalBootLoad:Int = 0;
	var textGraphic:BitmapData;
	var throbberGraphic:BitmapData;

	function bootUp() {
		var text = 'text';
		final chance = (1/5);
		var rand = Math.random();
		trace(rand);
		if (rand <= chance) {
			text += 'PANKO';
		}
		var bl = () -> {
			totalBootLoad++;
			if (totalBootLoad == 2) {
				allBootup();
			}
		}
		BitmapData.loadFromFile('assets/ui/images/computer/startup/$text.png').onComplete(bmp->{
			textGraphic = bmp;
			bl();
		});

		BitmapData.loadFromFile('assets/ui/images/computer/startup/throbber.png').onComplete(bmp->{
			throbberGraphic = bmp;
			bl();
		});
	}

	function allBootup() {
		var text = new Bitmap(textGraphic);
		text.scaleX = CoolUtil.windowScaleRatio.x;
		text.scaleY = CoolUtil.windowScaleRatio.y;
		addChild(text);
		text.x = (stage.stageWidth-text.width)/2;
		text.y = (stage.stageHeight-text.height)/2;

		var throbber = new Bitmap(throbberGraphic);
		throbber.scaleX = CoolUtil.windowScaleRatio.x;
		throbber.scaleY = CoolUtil.windowScaleRatio.y;
		addChild(throbber);
		throbber.x = ((stage.stageWidth-throbber.width)/2);
		throbber.y = ((stage.stageHeight-throbber.height)/2)+225;

		var origin = new Point(throbber.x + (throbber.width/2),throbber.y + (throbber.height/2));
		var timesMax = FlxG.random.int(1, 5);
		var times = 0.;
		var tmr = new Timer(125);
		tmr.run = () -> {
			if (Math.random() >= 0.75) {
				times+=0.125;
			}
			var matrix = throbber.transform.matrix.clone();
			matrix.translate(-origin.x, -origin.y);
			matrix.rotate(FlxAngle.TO_RAD*45);
			matrix.translate(origin.x, origin.y);
			throbber.transform.matrix = matrix;
			if (times == timesMax) {
				tmr.stop();
				setupGame();
			}
		}
	}
}