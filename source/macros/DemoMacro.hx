package macros;

import haxe.macro.Context;
import haxe.macro.Expr;

class DemoMacro {
    macro public static function buildDemo():Array<Field> {
        final excludeList = ['loadDefaultKeys', 'saveSettings', 'loadPrefs', 'getGameplaySetting', 'reloadControls', 'copyKey']; // excude functions here
        var f = Context.getBuildFields();
        for (i in f) {
            if (!excludeList.contains(i.name)) {
                trace(i.name);
            }
        }
        return f;
    }
}