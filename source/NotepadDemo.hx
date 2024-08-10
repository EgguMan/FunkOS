import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Sprite;

class NotepadDemo extends Window {
    var windowThingy:Sprite;
    public function new() {
        super('Notepad');
        var data = new BitmapData(640, 360);
        data.fillRect(new Rectangle(0, 0, 640, 360), 0xFFFFFFFF);
        windowThingy = new Sprite();
        windowThingy.addChild(new Bitmap(data));
        var text = new TextField();
        text.text = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        text.setTextFormat(new TextFormat("Segoe UI", 35, 0xFF000000, false, false, false, null, null, LEFT, -2, 350));
        text.x = 5;
        text.y = 5;
        windowThingy.addChild(text);
        loadBar();
    }
}