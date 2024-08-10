import openfl.events.MouseEvent;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;

class TaskbarIcon extends Bitmap {
    public var window:Window;
    public function new (_name:String, bmp:BitmapData) {
        super(bmp);
        this.scaleX = 40 / this.width;
        this.scaleY = 40 / this.height;
        this.name = _name + ' TASKBAR';
    }

    public function kill() {
        trace ("you killed me!");
    }

    public function click() {
        Main.instance.bringBackWindow(window);
    }
}