package backend.events;

class EventsCore { // I thought putting bigger events, like character events, in their own class would make PlayState a lot cleaner for big projects

	public static var classes:Array<Dynamic> = []; //trust

	public static final allowedInPurechart:Array<String> = [
		'Credits',
		'Change Scroll Speed'
	];

	/*

	Don't turn your back on me
	Don't bury your head deep
	Just cause you don't know what to say
	
	*/

    public static final eventStuff:Array<Dynamic> = // better here than charting state imo
	[
		['', 'mod events'],
		['black', ''],
		['fadeUI out', ''],
		['Zoom On Beat', 'Zoom on a beat!\nV1 = modVal, leave blank for 2\nV2 = power, leave blank for 0.0025\n\nSetting the ModVal to 0 will stop the bwabwabwa'],
		['next', 'x'],
		['BSOD', 'y'],
		['BSOD pre', 'z'],
		['', "Aero Engine Events."],
		['Trail', 'V1 = target, or operation. read docs\nV2 = options, just read docs'],
		['Mid-Song Cutscene','Play a cutscene in the middle of the song!\n\nValue 1 = cutscene name\nValue2 = fade in time, can be blank'],
		['Credits', 'Show the credits! Credits are added via\njson in \'assets/data/[songName]/credits.json\'\nIMPORTANT: ONLY USE ONCE PER SONG!!\n\nValue 1 = time to move, can be blank'],
		['Note Fade', 'Fade the strums out! \n\nValue 1 = strum to fade, can be blank for all\nValue 2 = time to fade, can be blank'],
		['Camera Zoom', 'Smoothly tween the camera!\n\nValue 1 = value to go to. leaving blank sets it to the \nstage\'s original camera zoom\nValue 2 = time to take. can be zero.'],
		['Cinematic Bars', 'Those thingys, you know the ones.\n\nValue 1 = y to go to, or just leave it blank\nValue 2 = time to take, can be left blank.'],
        ['Subtitle', 'Display a subtitle onscreen!\n\nValue 1 = text to display\nValue 2 = subtitle options, can be blank, but read docs'],
		['Change Background', 'Change the background to any other background ingame!\n\nValue 1 = BG name\nv'],
		['','Base psych events'],
		['Hey!', "Plays the \"Hey!\" animation from Bopeebo,\nValue 1: BF = Only Boyfriend, GF = Only Girlfriend,\nSomething else = Both.\nValue 2: Custom animation duration,\nleave it blank for 0.6s"],
		['Set GF Speed', "Sets GF head bopping speed,\nValue 1: 1 = Normal speed,\n2 = 1/2 speed, 4 = 1/4 speed etc.\nUsed on Fresh during the beatbox parts.\n\nWarning: Value must be integer!"],
		['Add Camera Zoom', "Used on MILF on that one \"hard\" part\nValue 1: Camera zoom add (Default: 0.015)\nValue 2: UI zoom add (Default: 0.03)\nLeave the values blank if you want to use Default."],
		['Play Animation', "Plays an animation on a Character,\nonce the animation is completed,\nthe animation changes to Idle\n\nValue 1: Animation to play.\nValue 2: Character (Dad, BF, GF)"],
		['Camera Follow Pos', "Value 1: X\nValue 2: Y\n\nThe camera won't change the follow point\nafter using this, for getting it back\nto normal, leave both values blank."],
		['Alt Idle Animation', "Sets a specified suffix after the idle animation name.\nYou can use this to trigger 'idle-alt' if you set\nValue 2 to -alt\n\nValue 1: Character to set (Dad, BF or GF)\nValue 2: New suffix (Leave it blank to disable)"],
		['Screen Shake', "Value 1: Camera shake\nValue 2: HUD shake\n\nEvery value works as the following example: \"1, 0.05\".\nThe first number (1) is the duration.\nThe second number (0.05) is the intensity."],
		['Change Character', "Value 1: Character to change (Dad, BF, GF)\nValue 2: New character's name"],
		['Change Scroll Speed', "Value 1: Scroll Speed Multiplier (1 is default)\nValue 2: Time it takes to change fully in seconds."]
	];

	public static final shaderEvents:Array<Dynamic> = 
	[
		['','These are events that use the shader operation \nstandard in their values! These are good for\natmospheric effects.\n\nRead the docs for formatting info'],
		['Flash Camera', 'Flash the camera with a color!\n\nSupports a 1 component color value and time\nUsing a color pallet will use the first color'],
		['Color Contrast', 'Some call it bad apple\n\nOptions support a 4 component hex array, time.\nSupports 4 component color pallets'],
		['Viginette', 'Put a viginette around the camera! The more intense it \nis, the more it will darken the screen so its \ngood for intense or horror vibes\n\nOptions support Time and Intensity, which can both be blank'],
		['Glitchy', 'supports a 2 component intensity, and time.\n\nIntensity 1 = static Intensity 2 = abberation'],
		['Barrel', 'Pair this with glitchy and VHS Lines to get that \ngeneric VHS look!\n\nSupports intensity, time. A negative\nintensity will invert the shader'],
		['VHS lines', 'shadertoy dot com slash VHS no credit provided \n\nSupports size, speed, and time.\nSpeed is how quick the lines move, time is how fast\nto tween']
	];

    public static var localMaps:Array<Map<Dynamic, Dynamic>> = [];

    public static function resetSong() {
        for (map in localMaps) {
            map.clear();
        }
        localMaps = [];
		for (i in classes) {
			i.reset(); // scary!
		}
		classes = [];
    }
}