import lime.app.Application;
import openfl.text.Font;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;

class Time extends TextField {
    var focused:Bool = false;
    public function new() {
        super();
        this.text = getTime();
        var format = new TextFormat("Segoe UI", 15, 0xFF000000, false, false, false, null, null, CENTER);
        this.setTextFormat(format);
        this.autoSize = TextFieldAutoSize.RIGHT;
        this.selectable = false;
        Application.current.window.onFocusIn.add(() -> {focused = true;});
        Application.current.window.onFocusOut.add(() -> {focused = false;});
    }

    public function update() {
        this.text = getTime();
        if (focused) {
            x = Application.current.window.width - (width+5);
		    y = Application.current.window.height - (height+2);
        }
    }

    public function getTime() {
        var date = Date.now();
        var hour = date.getHours();
        if (hour >= 13) hour -= 12;
        if (hour == 0) {
            hour = 12;
        }
        var minute:Dynamic = date.getMinutes();
        if (minute < 10) {
            minute = "0"+minute;
        }
        return hour + ":" + minute + "\n" + date.getDate() + "/" + date.getMonth() + "/" + date.getFullYear();
    }
}