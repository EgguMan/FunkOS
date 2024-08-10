import sys.FileSystem;
import openfl.events.MouseEvent;
import openfl.filters.BitmapFilterQuality;
import openfl.filters.DropShadowFilter;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;

class DesktopIcon extends Sprite {
    public static var shortcutBmp:BitmapData;
    public var onPress:Bool->Void = b -> {};
    public function new(_Name:String) {
        trace('desktop name $_Name');
        super();
        name = _Name;
        trace('assets/ui/images/computer/applications/$name/$name.png');
        trace(FileSystem.exists('assets/ui/images/computer/applications/$name/$name.png'));
        BitmapData.loadFromFile('assets/ui/images/computer/applications/$name/$name.png').onComplete(make);
    }

    
    public function make(bmp:BitmapData) {
        var bitmap = new Bitmap(bmp);
        
        var sc = Math.max(65/bitmap.width, 65/bitmap.height);
        bitmap.scaleX = sc;
        bitmap.scaleY = sc;
        bitmap.x -= 5;
        addChild(bitmap);
    
        var shortcut = new Bitmap(shortcutBmp);
        shortcut.y = bitmap.height-shortcut.height;
        shortcut.x = bitmap.x;
        addChild(shortcut);

        var text = new TextField();
        text.text = name;
        text.width = bitmap.width*1.75;
        text.setTextFormat(new TextFormat("Segoe UI", 17, 0xFFFFFFFF, false, false, false, null, null, CENTER));
        text.y = bitmap.y + 65;
        text.x = bitmap.x-(bitmap.width/2)+5;
        text.multiline = true;
        text.wordWrap = true;
        text.selectable = false;
        addChild(text);

        var dropShadow = new DropShadowFilter(3,45,0xFF000000,1,1,2,2,BitmapFilterQuality.HIGH);

        text.filters = [dropShadow];

        this.addEventListener(MouseEvent.MOUSE_DOWN, press);
        //this.addEventListener(MouseEvent.MOUSE_UP, rel);
    }

    public function press(evt:MouseEvent) {
        onPress(true);
    }

    /*public function rel(evt:MouseEvent) {
        trace('up');
        onPress(false);
    }*/
}