package object;

import openfl.display.BitmapData;
import sys.io.File;
import sys.FileSystem;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import backend.save.ClientPrefs;
import flixel.FlxSprite;

class PureBG extends FlxSprite {
    public function new(image:String, x:Float = 0, y:Float = 0, ?scrollX:Float = 1, ?scrollY:Float = 1, ?animArray:Array<String> = null, ?loop:Bool = false) {
		super(x, y);
        var graphic:FlxGraphic = backend.Paths.image(image);
        if (graphic == null) {
            trace(image);
            graphic = FlxGraphic.fromBitmapData(BitmapData.fromBytes(File.getBytes(image + '.png'))); // lol?
        }
		loadGraphic(graphic);
		scrollFactor.set(scrollX, scrollY);
		antialiasing = ClientPrefs.globalAntialiasing;
	}
}