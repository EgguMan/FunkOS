package states.options;

import openfl.events.Event;
import openfl.net.FileFilter;
#if desktop
import backend.Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import backend.Controls;
import backend.save.ClientPrefs;

using StringTools;

class GameplaySettingsSubState extends BaseOptionsMenu
{
	var bgOption:Option;

	public function new()
	{
		title = 'Gameplay Settings';
		rpcTitle = 'Gameplay Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Pure Chart Mode',
		'Dont load in the characters, backgrounds, etc. Just load the notes.'#if !Pure_Chart_Allowed + " WARNING! The creator of this build has disabled Pure Charting mode! This will only effect your save." #end,
		'pureChart',
		'bool',
		false);
		addOption(option);
		
		var option:Option = new Option('Pure Chart Background',
		'Chooese a background for pure chart mode! Press R to reset to original.'#if !Pure_Chart_Allowed + " WARNING! The creator of this build has disabled Pure Charting mode! This will only effect your save." #end,
		'pureBGPath',
		'path',
		"menuBG");
		addOption(option);
		bgOption = option;
		option.onInteraction = () -> {trace('hi'); getThePath();};
		var option:Option = new Option('Player Note Lane',
		'Show a note lane behind the player\'s strum/notes.',
		'showPlayerLane',
		'bool',
		false);
		addOption(option);

		var option:Option = new Option('Player Note Lane Alpha',
		'The alpha for the note lane mentioned in the option above.',
		'playerLaneAlpha',
		'float',
		0.6);
		option.scrollSpeed = 1;
		option.minValue = 0;
		option.maxValue = 1;
		option.changeValue = 0.05;
		option.decimals = 2;
		addOption(option);

		var option:Option = new Option('Controller Mode',
			'Check this if you want to play with\na controller instead of using your Keyboard.',
			'controllerMode',
			'bool',
			false);
		addOption(option);

		//I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Downscroll', //Name
			'If checked, notes go Down instead of Up, simple enough.', //Description
			'downScroll', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		var option:Option = new Option('Middlescroll',
			'If checked, your notes get centered.',
			'middleScroll',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Opponent Notes',
			'If unchecked, opponent notes get hidden.',
			'opponentStrums',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Ghost Tapping',
			"If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.",
			'ghostTapping',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Disable Reset Button',
			"If checked, pressing Reset won't do anything.",
			'noReset',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Hitsound Volume',
			'Funny notes does \"Tick!\" when you hit them."',
			'hitsoundVolume',
			'percent',
			0);
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = onChangeHitsoundVolume;

		var option:Option = new Option('Rating Offset',
			'Changes how late/early you have to hit for a "Sick!"\nHigher values mean you have to hit later.',
			'ratingOffset',
			'int',
			0);
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);

		var option:Option = new Option('Sick! Hit Window',
			'Changes the amount of time you have\nfor hitting a "Sick!" in milliseconds.',
			'sickWindow',
			'int',
			45);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 15;
		option.maxValue = 45;
		addOption(option);

		var option:Option = new Option('Good Hit Window',
			'Changes the amount of time you have\nfor hitting a "Good" in milliseconds.',
			'goodWindow',
			'int',
			90);
		option.displayFormat = '%vms';
		option.scrollSpeed = 30;
		option.minValue = 15;
		option.maxValue = 90;
		addOption(option);

		var option:Option = new Option('Bad Hit Window',
			'Changes the amount of time you have\nfor hitting a "Bad" in milliseconds.',
			'badWindow',
			'int',
			135);
		option.displayFormat = '%vms';
		option.scrollSpeed = 60;
		option.minValue = 15;
		option.maxValue = 135;
		addOption(option);

		var option:Option = new Option('Safe Frames',
			'Changes how many frames you have for\nhitting a note earlier or late.',
			'safeFrames',
			'float',
			10);
		option.scrollSpeed = 5;
		option.minValue = 2;
		option.maxValue = 10;
		option.changeValue = 0.1;
		addOption(option);

		super();
	}

	function onChangeHitsoundVolume()
	{
		FlxG.sound.play(backend.Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
	}

	function getThePath() {
		var file = new openfl.filesystem.File();
		file.browseForOpen('TITLE DEMO', [new FileFilter("PNG Files", 'png')]);
		file.addEventListener(Event.SELECT, selectedCover);
	}

	function selectedCover(e:Event) {
		trace('t');
		var event:openfl.filesystem.File = cast(e.target, openfl.filesystem.File);
		var sto:String = event.nativePath.replace(openfl.filesystem.File.applicationDirectory.nativePath, '');
		sto = sto.replace('\\', '/');
		var ret = sto.replace("/assets/shared/images/", '').replace("/assets/images/", '').replace('.png', '');
		bgOption.interact(ret);
	}
}