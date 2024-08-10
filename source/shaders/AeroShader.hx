package shaders;

import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.system.FlxAssets.FlxShader;

class AeroShader extends FlxShader { // 2.0 will have more stuff done with this. For now, it exists so people's code doesnt break in the future.
    public var shaderTime:Float = 0;
    public var timer:FlxTimer;

    override public function new(needTimer:Bool) {
        super();
        if (needTimer) timer = new FlxTimer().start(1/FlxG.drawFramerate, tmr -> update(1/FlxG.drawFramerate), 0);
        
    }

    public function update(e:Float) {
       if (!states.PlayState.paused) {
        shaderTime += e;
       }
    }

    public function kill() {
        this.program.dispose();
    }
       
}