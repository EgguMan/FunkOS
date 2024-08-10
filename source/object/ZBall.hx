package object;

import flixel.util.FlxColor;
import flixel.math.FlxMath;
import states.PlayState;
import flixel.util.FlxSort;
import flixel.FlxG;
import flixel.util.FlxSpriteUtil;
import flixel.util.helpers.FlxBounds;
import flixel.FlxSprite;

class ZBall extends FlxSprite {
    public static final posBounds:FlxBounds<Int> = new FlxBounds(-1450,2615);
    public static final scaleBounds:FlxBounds<Int> = new FlxBounds(50,275);
    static final colorsGOATED:Array<Int> = [0xFF001A9C, 0xFF61A7FF];
    static final colorsEVIL:Array<Int> = [0xFFD60000, 0xFFFF4660];
    static final colorsGOOD:Array<Int> = [0xFF1F573D, 0xFF66F8A9];

    public var ogY:Float = 275;
    public var z:Float = 0;

    public var sc:Float = 0;

    public static var total:Int = 0;

    public static var type:String = 'good';
    public var randomMult:Float = 1;

    public function new(_width:Float) {
        super();
        sc = _width;
        switch (type) {
            case 'good':
                this.makeGraphic(Std.int(_width)*2, Std.int(_width)*2, 0x00000000, true);
                var col:FlxColor = FlxColor.fromInt(colorsGOATED[FlxG.random.int(0,1)]);
                FlxSpriteUtil.drawCircle(this, _width/2, _width/2, _width/2, col); 
            case 'bad':
                this.makeGraphic(Std.int(_width), Std.int(_width), 0x00000000, true);
                var col:FlxColor = FlxColor.fromInt(colorsEVIL[FlxG.random.int(0,1)]);
                FlxSpriteUtil.drawTriangle(this, 0, 0, _width, col);
                randomMult = FlxG.random.float(0.1, 3);
            case 'what':
                this.makeGraphic(Std.int(_width)*2, Std.int(_width)*2, 0x00000000, true);
                var col:FlxColor = FlxColor.fromInt(colorsGOOD[FlxG.random.int(0,1)]);
                //col.brightness += (1-(_width/scaleBounds.max))/2; tried to make balls lighter the further they are but this didnt work
                FlxSpriteUtil.drawCircle(this, _width/2, _width/2, _width/2, col); // this could be optimized yes, but, fuck off :3
        }
        this.ID = total;
        centerOrigin();
        total++;
    }
    override function draw() {

        if (!PlayState.paused) {
            var silly = Math.sin((z/2)*6.283);
            silly = 1 - silly;
            this.scale.set((silly/1.5)+0.5, (silly/1.5)+0.5);
            this.y = ogY + (silly*130);
            this.scrollFactor.x = 1 - ((sc/scaleBounds.max));
            if (type == 'bad') {
                this.angle -= (sc/scaleBounds.max)*randomMult;
            }
        }
        super.draw();
    }

    public static function sortByZ(order:Int, o1:ZBall, o2:ZBall) {
        var sc1 = 0.5;
        if (o1 != null) {
            sc1 = o1.sc;
        }

        var sc2 = 0.5;
        if (o2 != null) {
            sc2 = o2.sc;
        }
        return FlxSort.byValues(order, sc1, sc2);
    }
}