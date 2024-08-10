package macros;

import haxe.macro.Printer;
import haxe.macro.Context;
import haxe.macro.Expr;

class SaveMacro {
    public static var list:Array<Field> = [];
    public static var printer:Printer;

    //huge props to ne_eo for helping me out

    macro public static function build():Array<Field> {
        printer = new haxe.macro.Printer();
        SaveMacro.list = Context.getBuildFields();
        return Context.getBuildFields();
    }

    macro public static function save() {
        var exprs:Array<Expr> = [];

        for (field in SaveMacro.list) { 
            if(hasMeta(field.meta, ":noSave")) continue;

            switch (field.kind) {
                case FVar(_):
                    var fieldName = field.name;
                exprs.push(macro FlxG.save.data.$fieldName = $i{fieldName});
                case FFun(_):
                    //trace(printer.printField(field) + ' is a function');
                default:
                    //trace(printer.printField(field) + ' is anything else');
            }
                
        }
        return macro $b{exprs};
    }

    macro public static function load() {
        var exprs:Array<Expr> = [];
        for (field in SaveMacro.list) {
            if(hasMeta(field.meta, ":noLoad")) continue;
            switch (field.kind) {
                case FVar(_):
                    var fieldName = field.name;
                    exprs.push(macro if(FlxG.save.data.$fieldName != null) {
                        $i{fieldName} = FlxG.save.data.$fieldName;
                    });
                case FFun(_):
                    //trace(printer.printField(field) + ' is a function');
                default:
                    //trace(printer.printField(field) + ' is anything else');
            }
            
        }
        return macro $b{exprs}
    }

    private static function hasMeta(meta:Metadata, name:String) : Bool {
        for (m in meta) {
            if (m.name == name) return true;
        }
        return false;
    }
}