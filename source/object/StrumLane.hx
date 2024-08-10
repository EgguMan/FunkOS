package object;

import flixel.FlxG;
import flixel.FlxSprite;

class StrumLane extends FlxSprite {

    public var calculatedWidth:Float = 0;

    public function new() {
        super();
        this.makeGraphic(5,5,0x00FFFFFF, true);
    }

    public function createLane() {
        this.makeGraphic(Math.floor(calculatedWidth), FlxG.height, 0xFF000000, true);
    }
}