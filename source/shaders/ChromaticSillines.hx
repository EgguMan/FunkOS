package shaders;

import states.PlayState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
typedef To = {
    loopTime:Float,
    timeMult:Float,
    width:Float,
    offs:Float
}
class ChromaticSilliness extends AeroShader {

    @:glFragmentSource('
    #pragma header

    uniform float offs;
    uniform float loop;
    uniform float timeMult;
    uniform float scale;
    uniform float width;

    uniform float iTime;
    
    void main()
    {
        // Normalized pixel coordinates (from 0 to 1)
        vec2 uv = openfl_TextureCoordv.xy;
    
        // Time varying pixel color
        vec4 col = flixel_texture2D(bitmap, uv);
        
        float t = iTime*timeMult;
        while (t > loop*timeMult) {
            t -= loop*timeMult;
        }
        
        float distFrom = loop*timeMult - (loop*(0.25*timeMult)) + (t-(loop*timeMult));
        
        float c = (1. - (0.5 - distance(uv.x, 0.5)*2.));

        float useOffs = offs;
        
        useOffs += min(0.5, (c * max(0., 1.- distance(distFrom, 1.-uv.y)*(5./scale))/50.)*width);
        
        col.r = flixel_texture2D(bitmap, vec2(uv.x-useOffs, uv.y)).r;
        col.b = flixel_texture2D(bitmap, vec2(uv.x+useOffs, uv.y)).b;
        
        
        // Output to screen
        gl_FragColor = col;
    }
    ')

    public function new(def:To, end:To, time:Float) {
        super(true);
        this.precisionHint = FAST;
        loop.value = [def.loopTime];
        timeMult.value = [def.timeMult];
        scale.value = [1];
        width.value = [def.width];
        iTime.value = [0];
        offs.value = [def.offs];

        trace(time);
        trace(end.offs);
        PlayState.instance.runningTweens.set('loopTime',FlxTween.num(def.loopTime, end.loopTime, time, {onComplete:twn -> {PlayState.instance.runningTweens.remove('loopTime');}}, f -> {this.loop.value=[f];}));
        PlayState.instance.runningTweens.set('timeMult',FlxTween.num(def.timeMult, end.timeMult, time, {onComplete:twn -> {PlayState.instance.runningTweens.remove('timeMult');}}, f -> {this.timeMult.value=[f];}));
        PlayState.instance.runningTweens.set('width',FlxTween.num(def.width, end.width, time, {onComplete:twn -> {PlayState.instance.runningTweens.remove('width');}}, f -> {this.width.value=[f];}));
        PlayState.instance.runningTweens.set('offs',FlxTween.num(def.offs, end.offs, time, {onComplete:twn -> {PlayState.instance.runningTweens.remove('offs');}}, f -> {this.offs.value=[f];}));

        new FlxTimer().start(0.25, tmr -> {
            offs.value[0] += 0.005;
            timeMult.value[0] -= 0.01;
        });
    }

    override function update(e:Float) {
        iTime.value[0] += e;
        super.update(e);
    }
}