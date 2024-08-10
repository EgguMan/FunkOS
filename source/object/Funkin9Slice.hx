package object;

import haxe.Exception;
import flixel.graphics.FlxGraphic;
import openfl.geom.Rectangle;
import lime.tools.AssetType;
import flixel.addons.ui.FlxUI9SliceSprite;
import backend.Paths;

class Funkin9Slice extends FlxUI9SliceSprite {
    public function new(name:String, _x:Float, _y:Float, offs:Int, size:Array<Int>) {
        var img = Paths.image('9slice/$name', 'ui');
        super(_x, _y,img,new Rectangle(0,0,size[0],size[1]), [offs, offs, Std.int(img.width - offs), Std.int(img.height - offs)]); // set the bounds automatically
    }

    public static function giveSlice(num:Int, width:Int, height:Int):Funkin9Slice {
        switch (num) { 
            case 0: //this will quickly give you 9slice objects! Can be good for repetition or smth idk
                return new Funkin9Slice('UiBox1',0,0, 30, [width, height]);
            case 1:
                return new Funkin9Slice('UiBox2',0,0, 30, [width, height]);
            case 2:
                return new Funkin9Slice('UiBox3',0,0, 30, [width, height]);
        }
        throw new Exception('Slice $num is out of range!');
        return null;
    }
}