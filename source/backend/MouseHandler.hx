package backend;

import openfl.ui.Mouse;
import openfl.Lib;
import openfl.events.Event;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import openfl.events.MouseEvent;
import haxe.Exception;
import flixel.FlxG;
import openfl.display.BitmapData;
import backend.save.ClientPrefs;

class MouseHandler {

    public static var justReleasedAccurately(get, never):Bool;

    public static var inFocus:Bool = false;

    public static function get_justReleasedAccurately():Bool {
        return #if !noDesktop !Main.instance.flxWindow.clickMax && Main.instance.flxWindow.visible  && Main.instance.flxWindow.hitTestPoint(Main.instance.mouseX, Main.instance.mouseY, false) && !Main.instance.flxWindow.clickingHeader && #end FlxG.mouse.justReleased #if AeroMouse && !inFocus #end;
    }


    #if AeroMouse
    static var graphics:Map<String, Array<Dynamic>>;

    //name, offsets, play 'press' anim or nah
    static final images:Array<Array<Dynamic>> = [['idle', [0, 0], true], ['press', [-7, -2], false], ['wait', [0,0], false], ['deny', [0,0], false], ['finger', [0,0], true]];

    static var curGraphic:String = 'idle';
    static var pastIdle = 'idle';

    //the mouse will fade out after some time if inactive. These vars dictate that

    //how often to update the time
    static final updateTime:Int = 60;
    static final time:Int = 7;
    static final fullTime:Int = 15;
    public static var countdown:Float = 0;

    @:keep static var timer:haxe.Timer = null; // FlxTimers reset after each state, i assume due to the timer manager, so its just easier for me to use haxe.timer

    

    public static function init() {
        graphics = new Map<String, Array<Dynamic>>();
        trace('yea');

        for (i in images) {
            graphics.set(i[0], ['assets/ui/images/mouse/${i[0]}.png', i[1], i[2]]);
        }

        setGraphic('wait');

        
        FlxG.stage.addEventListener(MouseEvent.MOUSE_DOWN, down);
        FlxG.stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, down);
        FlxG.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, down);
        FlxG.stage.addEventListener(MouseEvent.MOUSE_UP, up);
        FlxG.stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, up);
        FlxG.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, up);

        FlxG.stage.addEventListener(MouseEvent.MOUSE_MOVE, moved);

        FlxG.signals.focusLost.add(focusLost);

        timer = new haxe.Timer(#if !sys Std.int(#end 1/updateTime#if !sys ) #end);

        timer.run = () -> {
            var alpha = FlxG.mouse.cursorContainer.alpha;
            var elapsed = 1/updateTime;
            countdown += elapsed;
            if (countdown > time) {
                if (countdown > fullTime) {
                    #if !noDesktop
                    Mouse.hide();
                    #end
                    if (alpha != 0) {
                        FlxG.mouse.cursorContainer.alpha = FlxMath.lerp(alpha, 0, elapsed*2);
                    }
                } else {
                    if (alpha != 0.35) {
                        FlxG.mouse.cursorContainer.alpha = FlxMath.lerp(alpha, 0.35, elapsed);
                    }
                }
            } else {
                #if !noDesktop
                Mouse.show();
                #end
                if (alpha != 1) {
                    FlxG.mouse.cursorContainer.alpha = FlxMath.lerp(alpha, 1, elapsed*7);
                }
            }
        }
    }

    private static function down(e:MouseEvent) {
        if (graphics.get(curGraphic)[2] && curGraphic == 'idle') {
            setGraphic('press');
        }
    }

    private static function up(e:MouseEvent) {
        setGraphic('idle');
        new FlxTimer().start(0.01, tmr -> { // not very optimized but I dont care too much
            inFocus = false;
        });
    }

    private static function moved(e:MouseEvent) {
        countdown = 0;
    }

    public static function setGraphic(name:String) {
        if (graphics.exists(name)) {
            curGraphic = name;
            #if noDesktop
            var grph:Array<Dynamic> = graphics.get(name);
            FlxG.mouse.load(grph[0]);
            FlxG.mouse.cursor.scaleX = ClientPrefs.cursorSize;
            FlxG.mouse.cursor.scaleY = ClientPrefs.cursorSize;
            FlxG.mouse.cursor.x = grph[1][0];
            FlxG.mouse.cursor.y = grph[1][1];
            #end
        } else {
            trace(graphics);
            throw new Exception('Error!\n$name does not have an animation.');
        }
    }

    public static function focusLost() {
        inFocus = true;
    }
    #end
}