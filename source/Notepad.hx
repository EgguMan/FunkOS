import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.text.TextFormat;
import openfl.text.TextField;

class Notepad extends Window {
    public function new(type:String) {
        super("Notepad");
        
        windowContent = new Sprite();
		var windowThingy = new Shape();
		windowThingy.graphics.beginFill(0xFFFFFF, 1);
		windowThingy.graphics.drawRect(0, 0, 360, 450);
		windowThingy.graphics.endFill();
		addChild(windowThingy);
        windowContent.addChild(windowThingy);
		var text = new TextField();
        text.text = "Text can go here :3 : 3: 3: 3 :3 :3 :# :3 :3 :3 :3 ";
        text.width = 350;
        text.height = 445;
        text.type = openfl.text.TextFieldType.INPUT;
        text.wordWrap = true;
        text.multiline = true;
        text.setTextFormat(new TextFormat("Segoe UI", 35, 0xFF000000, false, false, false, null, null, LEFT));

        text.x = 5;
        text.y = 5;
        windowContent.addChild(text);
    }
}