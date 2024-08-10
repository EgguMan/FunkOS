package backend;

import flixel.FlxG;
import flixel.util.FlxColor;
import states.PlayState;
import backend.chart.Conductor;
using StringTools;

typedef Defaults = {
	defaultTime:Float,
	?camTypeNum:Bool,
	?defaultValue:Array<Float>,
	?defaultBool:Bool,
	?defaultSize:Int,
	?defaultColor:Array<Int> // color =/= colors
}

class ShaderOptionHandler {
    public static function handle(input:String, def:Defaults) {
        var retMap:Map<String, Dynamic> = new Map<String, Dynamic>();

        var options:Array<String> = input.toLowerCase().replace(' ', '').split(',');

        var i:Int = 0;

        while (i+1 < options.length) {
            var spl = options[i].split(':');
			var key = spl[0];
			var value = spl[1];

            switch(key) {
				case 'size':
					var p = Std.parseInt(value);
					if (Math.isNaN(p)) {
						p = def.defaultSize;
					}
					retMap.set('size', p);
				case 'bool' | 'boolean':
					if (value == 'true' || value == 't' || value == '1' || value == 'yes') {
						retMap.set('bool', true);
					} else {
						retMap.set('bool', false);
					}
                case 'time':
                    var rt=Std.parseFloat(value);
                    if (Math.isNaN(rt)) {
                        rt = def.defaultTime;
                    }
                    retMap.set('time', rt);
                case 'target' | 'camera':
                    if (!def.camTypeNum) {
						retMap.set('camera', handleCam(value));
					} else {
						var val = Std.parseInt(value);
						if (Math.isNaN(val)) {
							val = 0;
							switch(value) {
								case 'camhud':
									val = 1;
								case 'camother':
									val = 2;
	
							}
							
						}
						retMap.set('camera', val);
					}
                case 'intensity' | 'value' | 'speed':
					if (value == 'x' || value == 'd' || value == 'def' || value == 'default') {
						if (retMap.exists('intensity')) { // if you already have intensity, you are dealing with a multi-component intensity variable
							var num:Int = 0;
							var use:Float;
							var useArray:Array<Float> = [];
	
							if (!Std.isOfType(retMap.get('intensity'), Int) && !Std.isOfType(retMap.get('intensity'), Float)) {
								num = Std.int(retMap.get('intensity').length-1);
							}
	
							use = def.defaultValue[num];
	
							if (num == 0) {
								useArray = [retMap.get('intensity'), use];
							} else {
								var thjtghjier:Array<Float> = retMap.get('intensity');
								thjtghjier.push(use);
								useArray = thjtghjier;
							}
	
							trace(useArray);
	
							retMap.set('intensity', useArray);
						} else {
							var use = def.defaultValue[0];
							if ((Std.parseFloat(value)+"") == value) { //stupid but it works
								use = Std.parseFloat(value);
							}
							retMap.set('intensity', use);
						}
					} else {
						if (retMap.exists('intensity')) { // if you already have intensity, you are dealing with a multi-component intensity variable
							var num:Int = 0;
							var use:Float;
							var useArray:Array<Float> = [];
	
							if (!Std.isOfType(retMap.get('intensity'), Int) && !Std.isOfType(retMap.get('intensity'), Float)) {
								num = Std.int(retMap.get('intensity').length-1);
							}
	
							use = def.defaultValue[num];
	
							if ((Std.parseFloat(value)+"") == value) { //stupid but it works
								use = Std.parseFloat(value);
							}
	
							if (num == 0) { // if it is the second one then do special stuff
								useArray = [retMap.get('intensity'), use];
							} else { // else dont do special stuff
								var thjtghjier:Array<Float> = retMap.get('intensity');
								thjtghjier.push(use);
								useArray = thjtghjier;
							}
	
							retMap.set('intensity', useArray);
						} else {
							var use = def.defaultValue[0];
							if ((Std.parseFloat(value)+"") == value) { //stupid but it works
								use = Std.parseFloat(value);
							}
							retMap.set('intensity', use);
						}
					}
                case 'colors' | 'color' | 'colour' | 'colours': 
                    if (value.toLowerCase() == 'true' || value.toLowerCase() == 'false' || value.toLowerCase() == 'null' || value.toLowerCase() == 'instant') { 
                        retMap.set('colors', null);
                    } else if (value.contains('0x')) {
                        retMap.set('colors', handleColors(spl));
                    } else {
                        retMap.set('colors', colorPallets(value));
                    }
				default: 
					#if !debug
					trace('WARNING! ${key} is not a recognized shader input. Check your event!');
					#else
					FlxG.log.warn('WARNING! ${key} is not a recognized shader input. Check your event!');
					#end
            }

            i++;
        }

		if (!retMap.exists('time')) {
			retMap.set('time', def.defaultTime);
		}
		if (def.defaultValue != null && !retMap.exists('intensity')) {
			retMap.set('intensity', def.defaultValue);
		}
		if (def.defaultBool != null && !retMap.exists('bool')) {
			retMap.set('bool', def.defaultBool);
		}
		if ( def.defaultSize != null && !retMap.exists('size')) {
			retMap.set('size', def.defaultSize);
		}
		if (def.defaultColor != null && (!retMap.exists('colors') || retMap.get('colors') == [])) {
			retMap.set('colors', def.defaultColor);
		}

        return retMap;
    }

    static function handleCam(cam:String) {
        switch (cam) {
            case 'game':
                return PlayState.instance.camGame;
            case 'hud':
                return PlayState.instance.camHUD;
			default:
                return PlayState.instance.camOther;
        }
    }

    static function handleColors(options:Array<String>) {
        var retArray:Array<Int> = [];
        for (i in 1...options.length) {
            retArray.push(Std.parseInt(options[i]));
        }

        return retArray;
    }

    static function colorPallets(val:String) {
        var retVal1 = [];
        switch (val.toLowerCase().replace(' ', '')) {
									//bg			bf				dad				gf
					case 'badapple':
						retVal1 = [0xFFFFFFFF, 0xFF000000, 0xFF000000, 0xFF000000];
					case 'badapplealt':
						retVal1 = [0xFF000000, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF];

					// char based
					case 'funky':
						retVal1 = [0xFF515598, 0xFF00D5FF, 0xFFA800C6, 0xFFFF0088];
					case 'redvsblue':
						retVal1 = [0xff000000, 0xff00ffff, 0xffff0015, 0xff00ffff];
					case 'oghealthbar':
						retVal1 = [0xff000000, 0xffff0015, 0xff00f7ff, 0xff00f7ff];

					//simple patterns
					case 'sakura':
						retVal1 = [0xFFE881FF, 0xFFC60EEF, 0xFFAD5BFF, 0xFFB10085];
					case 'royal':
						retVal1 = [0xFF352EB5, 0xFF00146B, 0xFF00146B, 0xFF0C38A7];
					case 'forest':
						retVal1 = [0xFF1B5D34, 0xff10ff24, 0xff10ff24, 0xff4cfaa3];
					case 'monochrome':
						retVal1 = [0xFF000000, 0xFF565656, 0xFF565656, 0xFF323232];
					case 'grayscale':
						retVal1 = [0xFFFFFFFF, 0xFF828282, 0xFF828282, 0xFFC2C1C1];
					case 'gold':
						retVal1 = [0xFFCE9E00, 0xFFFFEE00, 0xFFFFEE00, 0xFFCCB800];
					case 'trans':
						retVal1 = [0xFF00E5FF, 0xFFF87AFF, 0xFFF87AFF,0xFFFFFFFF];
					case 'rivertothesea':
						retVal1 = [0xFFFFFFFF, 0xFF00FF00,  0xFFFF0000,0xFF000000];
					//black-centric patterns
					case 'pyrite':
						retVal1 = [0xFFffd900, 0xFF000000, 0xFF000000, 0xFF000000];
					case 'cobalt':
						retVal1 = [0xFF001eff, 0xFF000000, 0xFF000000, 0xFF000000];
					case 'zombie':
						retVal1 = [0xFF00FF00, 0xFF000000, 0xFF000000, 0xFF000000];
					case 'basic' :
						retVal1 = [0xFFFFFFFF, 0xFFFF0000, 0xFF00FF00, 0xFF0000FF];

					//meme patterns
					case 'homedepot':
						retVal1 = [0xFFF26722, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFF5B799];
					case 'ugly':
						retVal1 = [0xFF432705, 0xFFFF00D9, 0xFF09FF00, 0xFFFF5100];
					case 'random':
						retVal1 = [];
						for (i in 0...5) {
							var col = FlxColor.fromRGB(FlxG.random.int(0, 255), FlxG.random.int(0, 255), FlxG.random.int(0, 255), 255);
							retVal1.push(col);
						}

					/*case 'brighter' | 'bright' | 'b':
						trace('hi');
						retVal1 = DiffUtils.brightness();
					case 'lessbrighter' | 'lbright' | 'lb':
						retVal1 = DiffUtils.darkness();
					case 'lightness' | 'light' | 'l':
						retVal1 = DiffUtils.lightness();	
					case 'darkness' | 'dark' | 'd':
						retVal1 = DiffUtils.unlight();
					case 'saturation' | 'sat' | 's':
						retVal1 = DiffUtils.saturation();
					case 'unsaturation' | 'unsat' | 'us':
						retVal1 = DiffUtils.unsaturate();
					default:
						trace(event.value1.toLowerCase().replace(' ', ''));*/
				}
        return retVal1;
    }
    
}

class GeneralShaderHub { // ill prob do more with this one day
	public static var shaderMap:Map<String, Dynamic> = new Map<String,Dynamic>();

	public static function reset() {
		shaderMap.clear();
	}
}