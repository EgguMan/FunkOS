package states;

import backend.chart.Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.FlxBasic;
import backend.Controls;
import backend.save.ClientPrefs;
import backend.save.PlayerSettings;
import backend.chart.Conductor;

class MusicBeatState extends FlxUIState
{
	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	public static var camBeat:FlxCamera;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create() {
		camBeat = FlxG.camera;
		var skip:Bool = FlxTransitionableState.skipNextTransOut;
		super.create();

		if(!skip) {
			openSubState(new CustomFadeTransition(0.7, true));
		}
		FlxTransitionableState.skipNextTransOut = false;
	}

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if(curStep > 0)
				stepHit();

			if(PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}

		if(FlxG.save.data != null) FlxG.save.data.fullscreen = FlxG.fullscreen;

		#if (Silliness && sys)
		if (FlxG.random.bool(0.001)) {
			FlxG.sound.play(Paths.sound('accControl', 'silly'), 2);
		}

		if (FlxG.random.bool(0.005)) {
			FlxG.sound.play(Paths.sound('remove', 'silly'), 2);
		}

		if (FlxG.random.bool(0.00001)) {
			bluescreenGag();
		}
		#end

		super.update(elapsed);
	}

	private function updateSection():Void
	{
		if(stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
		while(curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if(curStep < 0) return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if(stepsToDo > curStep) break;
				
				curSection++;
			}
		}

		if(curSection > lastSection) sectionHit();
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public static function switchState(nextState:FlxState) {
		FlxG.switchState(() -> nextState);
	}

	override function startOutro(onOutroComplete:()->Void):Void
		{
			if (!FlxTransitionableState.skipNextTransIn) {
				FlxG.state.openSubState(new CustomFadeTransition(0.6, false));

				CustomFadeTransition.finishCallback = onOutroComplete;
				return;
			}
			FlxTransitionableState.skipNextTransIn = false;
			onOutroComplete();
		}

	public static function resetState() {
		FlxG.resetState();
	}

	public static function getState():MusicBeatState {
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		return leState;
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//trace('Beat: ' + curBeat);
	}

	public function sectionHit():Void
	{
		//trace('Section: ' + curSection + ', Beat: ' + curBeat + ', Step: ' + curStep);
	}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if(PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}

	#if Silliness

	public function bluescreenGag() {
		FlxG.sound.play(Paths.sound('remove', 'silly'), 2);
		
		new FlxTimer().start(3, tmr ->{
			FlxG.sound.play(Paths.sound('accControl', 'silly'), 2);
			new FlxTimer().start(5, tmr -> {
				new FlxTimer().start(1, tmr -> {
					FlxG.sound.play(Paths.sound('accControl', 'silly'), 2);
					new FlxTimer().start(0.1, tmr -> {
						FlxG.sound.play(Paths.sound('accControl', 'silly'), 2);
						FlxG.stage.window.fullscreen = true;
						var bg = new FlxSprite().makeGraphic(1280, 720, 0x0079d8);
						bg.scrollFactor.set(0,0);
						bg.antialiasing = false;
						add(bg);
						Main.fpsVar.visible = false;
						var bsod = new FlxSprite().loadGraphic(Paths.image('bsod', 'silly'));
						bsod.setGraphicSize(bsod.width / Math.min(bsod.width/1280, bsod.height/720)*1.1, bsod.height / Math.min(bsod.width/1280, bsod.height/720)*1.1);
						bsod.scrollFactor.set(0,0);
						bsod.antialiasing = false;
						add(bsod);
						FlxG.sound.music.stop();
						FlxG.sound.volume = 0;
						FlxG.mouse.visible = false;
						new FlxTimer().start(0.0001, tmr -> {
							Sys.sleep(10);
							flash.system.System.exit(0);
						});
					});
				});
				FlxG.sound.play(Paths.sound('accControl', 'silly'), 2);
			});
		});
	}
	#end
}
