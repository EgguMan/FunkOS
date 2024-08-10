import flixel.math.FlxMath;
import openfl.events.MouseEvent;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.display.Shape;
import openfl.display.Sprite;

using StringTools;

enum Operations {
    NONE;
    ADD;
    SUBTRACT;
    CLEAR;
    MULTIPLY;
    DIVIDE;
    EQUALS;
}


class Calculator extends Sprite {
    var bg:Shape;
    var result:TextField;
    var held:TextField;

    var curOperation:Operations = NONE;
    var holding:Bool = false;
    var heldValue(default, set):Float = 0;

    function set_heldValue(inp:Float) {
        heldValue = inp;
        held.text = ""+inp;
        return inp;
    }

    final operationList:Array<String> = ['+', '-', '=', '×', '÷', '•'];

    final enumToOperation:Map<Operations, String> = [
        ADD => '+',
        SUBTRACT => '-',
        EQUALS => '=',
        MULTIPLY => '×',
        DIVIDE => '÷',
        NONE => '',
        CLEAR => ''
    ];

    public function new() {
        super();
        bg = new Shape();
		bg.graphics.beginFill(0xFFFFFF, 1);
		bg.graphics.drawRect(0, 0, 280, 450);
		bg.graphics.endFill();
        addChild(bg);

        var backer = new Shape();
		backer.graphics.beginFill(0xE0E0E0, 1);
		backer.graphics.drawRect(0, 30, 280, 55);
		backer.graphics.endFill();
        addChild(backer);

        result = new TextField();
        editText("0");
        result.width = 270;
        result.height = 75;
        result.type = openfl.text.TextFieldType.INPUT;
        result.wordWrap = false;
        result.multiline = false;
        result.setTextFormat(new TextFormat("Segoe UI", 35, 0xFF000000, false, false, false, null, null, RIGHT));
        addChild(result);
        result.y = 30;

        held = new TextField();
        held.text = '0';
        held.width = 270;
        held.height = 75;
        held.type = openfl.text.TextFieldType.INPUT;
        held.wordWrap = false;
        held.multiline = false;
        held.setTextFormat(new TextFormat("Segoe UI", 20, 0xFF848484, false, false, false, null, null, RIGHT));
        addChild(held);
        held.y = 0;
        held.selectable = false;

        for (i in 0...3) {
            for (j in 0...3) {
                var spr = new NumberButton((i*3)+j);
                spr.x = 3.5 + j*(205/3);
                spr.y = 115 + i*(205/3);
                addChild(spr);
                spr.attatchedInstance = this;
            }
        }
        var nine = new NumberButton(9);
        nine.x = 3.5 + 3*(205/3);
        nine.y = 115;
        nine.attatchedInstance = this;
        addChild(nine);

        var clear = new NumberButton(10, [175/3, 125, 9.7222222222222, 'Clear', 15, 40]);
        clear.x = 3.5 + 3*(205/3);
        clear.y = 115 + (205/3);
        clear.attatchedInstance = this;
        addChild(clear);

        for (i in 0...2) {
            for (j in 0...3) {
                var spr = new NumberButton(10+(i*3)+j, [(250/3), 50, 9.7222222222222, operationList[(i*3)+j], 40, -12.5]);
                spr.x = 3.5 + j*(270/3);
                spr.y = 135 + (3+i)*(60);
                spr.attatchedInstance = this;
                addChild(spr);
            }
        }
    }

    public function editText(string:Dynamic, ?set:Bool = false) {
        final len:Int = 14;
        var fin:String;
        if (result.text == "∞" || (string == '.' && result.text.contains('.'))) {
            return;
        }
        if (set) {
            fin = string + "";
        } else {
            if (result.text == '0') {
                result.text = '';
            }
            fin = result.text + string;
        }
        if (fin.contains(".")) {
            if (fin.split('.')[1].length > 7) {
                fin = ""+FlxMath.roundDecimal(Std.parseFloat(fin), 2);
            }
        }
        if (fin.length > len) fin = "∞";
        if (fin.charAt(0) == '.') '0' + '.';
        result.text = fin;
    }

    public function specialOperation(op:String) {
        switch(op) {
            case 'Clear':
                holding = false;
                if (Std.parseFloat(result.text) == 0 ){
                    heldValue = 0;
                } else {
                    result.text = '0';
                }
                curOperation = NONE;
            case '+':
                if (curOperation == ADD) {
                    if (Std.parseFloat(result.text) == 0) {
                        editText(heldValue*2, true);
                    } else if (heldValue == 0) {
                        editText(Std.parseFloat(result.text)*2, true);
                    } else {
                        editText(Std.parseFloat(result.text) + heldValue, true);
                        heldValue = 0;
                    }
                } else {
                    curOperation = ADD;
                    holding = true;
                    heldValue = Std.parseFloat(result.text);
                    result.text = "0";
                }   
            case '-':
                if (curOperation == SUBTRACT) {
                    if (Std.parseFloat(result.text) == 0) {
                        editText(-1*heldValue, true);
                    } else {
                        editText(heldValue-Std.parseFloat(result.text), true);
                        heldValue = 0;
                    }
                } else {
                    curOperation = SUBTRACT;
                    holding = true;
                    heldValue = Std.parseFloat(result.text);
                    result.text = "0";
                }    
            case '=':
                specialOperation(enumToOperation.get(curOperation));
                trace(curOperation);
            case '×':
                if (curOperation == MULTIPLY) {
                    if (Std.parseFloat(result.text) == 0 ) {
                        editText(Math.pow(heldValue, 2), true);
                    } else if (heldValue == 0) {
                        editText(Math.pow(Std.parseFloat(result.text), 2), true);
                    } else {
                        editText(Std.parseFloat(result.text) * heldValue, true);
                    }
                } else {
                    curOperation = MULTIPLY;
                    heldValue = Std.parseFloat(result.text);
                    result.text = "0"; 
                }
            case '÷':
                if (curOperation == DIVIDE) {
                    if (Std.parseFloat(result.text) == 0 ) {
                        editText(1, true);
                    } else if (heldValue == 0) {
                        editText(1, true);
                    } else {
                        editText(heldValue / Std.parseFloat(result.text), true);
                    }
                } else {
                    curOperation = DIVIDE;
                    heldValue = Std.parseFloat(result.text);
                    result.text = "0"; 
                }
            case '•':
                editText('.');
            default:
                trace(op);
        }
    }
}

class NumberButton extends Sprite {
    public var attatchedInstance:Calculator;
    public function new(num:Int, ?specialParams:Array<Dynamic>) {
        super();

        var shape = new Shape();
        if (specialParams == null) {
            final w = 175/3;
            shape.graphics.beginFill(0xCECECE, 1);
            shape.graphics.drawRoundRect(0, 0, w, w, w/6, w/6);
            shape.graphics.endFill();
        } else {
            shape.graphics.beginFill(0xCECECE, 1);
            shape.graphics.drawRoundRect(0, 0, specialParams[0], specialParams[1], specialParams[2], specialParams[2]);
            shape.graphics.endFill();
        }
        addChild(shape);


        var numTXT = new TextField();
        if (specialParams == null) {
            numTXT.text = ''+num;
        } else {
            numTXT.text = specialParams[3];
        }
        numTXT.width = shape.width;
        numTXT.type = openfl.text.TextFieldType.INPUT;
        numTXT.wordWrap = false;
        numTXT.multiline = false;
        var sc:Int = 35;
        if (specialParams != null) sc = specialParams[4];
        numTXT.setTextFormat(new TextFormat("Segoe UI", sc, 0xFF000000, false, false, false, null, null, CENTER));
        numTXT.selectable = false;
        numTXT.y += (numTXT.height/32);
        if (specialParams != null) numTXT.y += specialParams[5];
        addChild(numTXT);

        if (specialParams == null) {
            addEventListener(MouseEvent.MOUSE_UP, ms -> {attatchedInstance.editText(num+'');trace('press $num');});
        } else {
            addEventListener(MouseEvent.MOUSE_UP, ms -> {attatchedInstance.specialOperation(specialParams[3]);});
        }
    }
}