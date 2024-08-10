package states.substates;

import flixel.FlxSprite;
import flixel.util.FlxSave;
import backend.save.ClientPrefs;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import object.Boyfriend;
import backend.chart.Conductor;

class GameOverSubstate extends MusicBeatSubstate
{
	public var boyfriend:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;
	var playingDeathSound:Bool = false;

	var stageSuffix:String = "";

	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	public static var instance:GameOverSubstate;

	public static function resetVariables() {
		characterName = 'bf-dead';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
	}

	override function create()
	{
		instance = this;

		super.create();
	}

	public var image:FlxSprite;

	public function new(x:Float, y:Float, camX:Float, camY:Float)
	{
		super();

		var bpm:Int = 100;

		if (PlayState.SONG.song.toLowerCase() == '(re)boot1' || PlayState.SONG.song.toLowerCase() == '(re)boot2') {
			loopSoundName = 'Dematerialized';
			endSoundName = 'Dematerialized_CONF';
		}

		Conductor.songPosition = 0;

		#if Pure_Chart_Allowed
		if (!ClientPrefs.pureChart) {
		#end
			boyfriend = new Boyfriend(x, y, characterName);
			boyfriend.x += boyfriend.positionArray[0];
			boyfriend.y += boyfriend.positionArray[1];
			add(boyfriend);
	
			camFollow = new FlxPoint(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y);
	
			FlxG.sound.play(backend.Paths.sound(deathSoundName));
			Conductor.changeBPM(100);
			// FlxG.camera.followLerp = 1;
			// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
			FlxG.camera.scroll.set();
			FlxG.camera.target = null;
	
			boyfriend.playAnim('firstDeath');
	
			camFollowPos = new FlxObject(0, 0, 1, 1);
			camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
			add(camFollowPos);
		#if Pure_Chart_Allowed
		} else {
			image = new FlxSprite().loadGraphic(Paths.image('pureDeath'));
			image.scrollFactor.set(0,0);
			image.screenCenter();
			add(image);
			image.alpha = 0;
			image.y -= 75;
			var snd = backend.Paths.sound(deathSoundName);
			FlxG.sound.play(snd);
			new FlxTimer().start(2, tmr -> {coolStartDeath();});
			new FlxTimer().start(1, tmr->{
				FlxTween.tween(image, {alpha:1}, 1.5);
				FlxTween.tween(image, {y:image.y+75}, 1.5, {ease:FlxEase.bounceOut});
			});
		}
		#end
		
	}

	var isFollowingAlready:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
		
			FlxG.sound.music.stop();
			PlayState.exitStuff();
			if (FreeplayState.been) {
				MusicBeatState.switchState(new FreeplayState());
			} else {
				MusicBeatState.switchState(new states.MainMenuState());
			}
		}

		if (#if Pure_Chart_Allowed !ClientPrefs.pureChart && #end boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name == 'firstDeath')
		{
			if(boyfriend.animation.curAnim.curFrame >= 12 && !isFollowingAlready)
			{
				FlxG.camera.follow(camFollowPos, LOCKON, 1);
				updateCamera = true;
				isFollowingAlready = true;
			}

			if (boyfriend.animation.curAnim.finished && !playingDeathSound)
			{
				if (PlayState.SONG.stage == 'tank')
				{
					playingDeathSound = true;
					coolStartDeath(0.2);
					
					var exclude:Array<Int> = [];
					//if(!ClientPrefs.cursing) exclude = [1, 3, 8, 13, 17, 21];

					FlxG.sound.play(backend.Paths.sound('jeffGameover/jeffGameover-' + FlxG.random.int(1, 25, exclude)), 1, false, null, true, function() {
						if(!isEnding)
						{
							FlxG.sound.music.fadeIn(0.2, 1, 4);
						}
					});
				}
				else
				{
					coolStartDeath();
				}
				boyfriend.startedDeath = true;
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(backend.Paths.music(loopSoundName), volume);

	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			#if Pure_Chart_Allowed
			if (!ClientPrefs.pureChart) {
			#end
				boyfriend.playAnim('deathConfirm', true);
			#if Pure_Chart_Allowed
			} else {
				FlxTween.tween(image.scale, {x:0, y:0}, 2, {ease:FlxEase.backIn});
			}
			#end
			FlxG.sound.music.stop();
			FlxG.sound.play(backend.Paths.music(endSoundName));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					MusicBeatState.switchState(new PlayState());
				});
			});
		}
	}
}
