import openfl.filters.BitmapFilterQuality;
import openfl.filters.GlowFilter;
import haxe.Timer;
import lime.system.FileWatcher;
import sys.FileSystem;
import openfl.Assets;
import openfl.events.MouseEvent;
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Sprite;

class Window extends Sprite {

    public static var headerBmp:BitmapData;
    public static var minimizeBMP:BitmapData;
    public static var closeBMP:BitmapData;
    public static var maximizeBMP:BitmapData;

    public var windowContent(default, set):Dynamic;

    public function set_windowContent(inp:Dynamic) {
        if (inp != null) {
            addChild(inp);
        }
        windowContent = inp;
        return inp;
    }

    public var windowIsBitmap:Bool = false;

    public var windowHeader:Bitmap;

    public var clickingHeader(get, never):Bool;

    public function get_clickingHeader() {
        return Lib.current.mouseX > this.x && Lib.current.mouseX < (this.x + windowHeader.width) && Lib.current.mouseY > (this.y-windowHeader.height) && Lib.current.mouseY < ((this.y-windowHeader.height) + windowHeader.height);
    }

    public var icon:TaskbarIcon;

    public var close:Bitmap;
    public var minimize:Bitmap;
    public var maximize:Bitmap;

    public var clickMax:Bool = false; //Fuck hate this

    /*public var x(default, set):Float = 0;
    public var y(default, set):Float = 0;

    public function set_x(inp:Float) {
        windowContent.x = inp;
        x = inp;
        return x;
    }

    public function set_y(inp:Float) {
        windowContent.y = inp;
        y = inp;
        return y;
    }

    public var width(get, never):Float; 
    public var height(get, never):Float; 

    public function get_width() {
        return windowContent.width;
    }

    public function get_height() {
        return windowContent.height;
    }

    public var scaleX(get, set):Float; 
    public var scaleY(get, set):Float; 

    public function get_scaleX() {
        return windowContent.scaleX;
    }

    public function get_scaleY() {
        return windowContent.scaleY;
    }

    public function set_scaleX(inp:Float) {
        windowContent.scaleX = inp;
        windowHeader.scaleX = inp;
        return inp;
    }

    public function set_scaleY(inp:Float) {
        windowContent.scaleY = inp;
        windowHeader.scaleY = inp;
        return inp;
    }*/

    public function new(_name:String) {
        super();
        this.name=_name;
        trace('loading icon for $name');
        if (FileSystem.exists('assets/ui/images/computer/applications/$name/taskbar.png')) {
            BitmapData.loadFromFile('assets/ui/images/computer/applications/$name/taskbar.png').onComplete(loadTaskbarIcon);
        } else {
            BitmapData.loadFromFile('assets/ui/images/computer/applications/taskbarDefault.png').onComplete(loadTaskbarIcon);
        }

        var glow = new GlowFilter(0xAFAFAF, 1, 1, 1, 2500, BitmapFilterQuality.HIGH);
        this.filters = [glow];
    }

    public function loadTaskbarIcon(bmp:BitmapData) {
        icon = new TaskbarIcon(name, bmp);
        icon.window = this;
    }

    public function loadBar() {
        windowHeader = new Bitmap(Window.headerBmp);
        addChild(windowHeader);
        addEventListener(MouseEvent.MOUSE_DOWN, press);
        addEventListener(MouseEvent.MOUSE_UP, release);
    }

    public function setSize(width:Float, ?offsets:Int = 0) {
        var scale = width/windowHeader.width;
        windowHeader.scaleX = scale;
        windowHeader.y -= windowHeader.height;
        //windowHeader.x -= 1+offsets;
        
        close = new Bitmap(closeBMP);
        addChild(close);
        close.y = windowHeader.y + (windowHeader.height/2) - (close.height/2);
        close.x = windowHeader.width - (close.width + 2);

        minimize = new Bitmap(minimizeBMP);
        addChild(minimize);
        minimize.y = windowHeader.y + (windowHeader.height/2) - (minimize.height/2);
        minimize.x = close.x - (minimize.width + 2);

        if (windowContent is flixel.FlxGame) {
            trace('my name is flxgame');
            maximize = new Bitmap(maximizeBMP);
            addChild(maximize);
            maximize.y = windowHeader.y + (windowHeader.height/2) - (maximize.height/2);
            maximize.x = minimize.x - (maximize.width + 4);
        }
    }

    public function press(evt:MouseEvent) {
        Main.instance.removeChild(this);
        Main.instance.addChildAt(this, Main.instance.getChildIndex(Main.instance.taskbar));
        if (windowContent is flixel.FlxGame) {
		    @:privateAccess windowContent.onFocus();
        }
        clickMax = false;
        if (clickingHeader) {
            if (clickingSprite(minimize) || clickingSprite(close) || clickingSprite(maximize)) {
                if (windowContent is flixel.FlxGame) {
                    if (clickingSprite(close)) {
                        Main.instance.addIcon(this);
                        return;
                    }
                }
                if (clickingSprite(close)) {
                    Main.instance.deleteWindow(this);
                } else if (clickingSprite(minimize)) {
                    if (windowContent is flixel.FlxGame) 
                        @:privateAccess windowContent.onFocusLost();
                    Main.instance.addIcon(this);
                } else if (clickingSprite(maximize)) {
                    clickMax = true;
                    var the = [this.width, this.height];
                    if (this.scaleX >= 0.9) {
                        this.scaleX = 0.35;
                        this.scaleY = 0.35;
                    } else {
                        this.scaleX += 0.15;
                        this.scaleY += 0.15;
                    }

                    this.x = Math.max(this.x-((this.width-the[0])/2), 0);
                    this.y = Math.max(this.y-((this.height-the[1])/2), 0+windowHeader.height);
                }
            } else {
                if (windowContent is flixel.FlxGame) 
                    @:privateAccess windowContent.onFocusLost();
                this.startDrag();
            }
        }
    }

    function clickingSprite(sprite:Bitmap) { // ???? why doesnt the hit test point work but this does
        if (sprite == null) return false;
        return mouseX > sprite.getBounds(this).left && mouseX < sprite.getBounds(this).right && mouseY > sprite.getBounds(this).top && mouseY < sprite.getBounds(this).bottom;
    } 


    public function release(evt:MouseEvent) {
        this.stopDrag();
    }

    public function kill() {
        if (windowContent.onReset != null)
            windowContent.onReset();
        trace(Reflect.fields(windowContent));
        trace(Reflect.hasField(windowContent, "onReset"));
        windowContent = null;
        removeEventListener(MouseEvent.MOUSE_DOWN, press);
        removeEventListener(MouseEvent.MOUSE_UP, release);
    }
}