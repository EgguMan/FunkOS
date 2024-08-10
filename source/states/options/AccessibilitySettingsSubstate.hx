package states.options;

import shaders.ColorblindShader;
import backend.MouseHandler;
import flixel.FlxG;
import states.substates.MusicBeatSubstate;
import backend.save.ClientPrefs;

class AccessibilitySettingsSubstate extends BaseOptionsMenu {
    public function new() {
        title = 'Accessibility';
        rpcTitle = 'Acessibility Settings menu';

        var option:Option = new Option('Flashing Lights',
			"Uncheck this if you're sensitive to flashing lights!",
			'flashing',
			'bool',
			true);
		addOption(option);

        var option:Option = new Option('Camera Zooms',
			"If unchecked, the camera won't zoom in on a beat hit.",
			'camZooms',
			'bool',
			true);
		addOption(option);

        #if (AeroMouse && noDesktop)
        var option:Option = new Option('Cursor Size', 'The size for your mouse cursor to be.', 'cursorSize', 'float', 0.25);
        option.scrollSpeed = 5;
		option.minValue = 0.125;
		option.maxValue = 1.5;
		option.changeValue = 0.1;
        option.onChange = () -> {
            MouseHandler.countdown = 0;
            FlxG.mouse.cursor.scaleX = ClientPrefs.cursorSize;
            FlxG.mouse.cursor.scaleY = ClientPrefs.cursorSize;
        }
		addOption(option);
        #end

        var array:Array<String> = ['None'].concat(ColorblindShader.colors);
        trace(array); // wouldnt work if I directly concat
        var option:Option = new Option('Colorblind Filters', 'Apply filters to the game that make the game more accessible to people with color blindness!', 'colorblindMode', 'string', 'None', array);
        option.onChange = changedShader;
        addOption(option);

        super();
    }

    public function changedShader() {
        if (ClientPrefs.colorblindMode != 'None') {
            if (ColorblindShader.instance == null) 
                new ColorblindShader();
            ColorblindShader.instance.select.value = [ColorblindShader.getSelect()];
            FlxG.game.setFilters([ColorblindShader.instanceFILTER]);                
        } else if (ColorblindShader.instanceFILTER != null) { // should never happen, but, you never know.
            trace('should be removed');
            FlxG.game.setFilters([]);
        }
    }
}