package shaders;

import openfl.filters.ShaderFilter;
import openfl.filters.BitmapFilter;
import states.PlayState;
import flixel.tweens.FlxTween;

class FlashShader extends AeroShader {
    public static var ID:Int = 0;
    public var filterInstace:BitmapFilter;
    var localID:Int = 0;
    @glFragmentSource('
    #pragma header
    uniform vec4 colOvr;
    uniform float ints;
    void main(void) {
        vec2 uv = openfl_TextureCoordv.xy;
        vec4 col = flixel_texture2D(bitmap, uv);
        col.rgb += colOvr.rgb * colOvr.a;

        gl_FragColor = (mix(texture2D( bitmap, uv),col,ints));
    }
    ')

    public function new() {
        super(false);
        this.colOvr.value = [1,1,1,1];
        this.localID = FlashShader.ID;
        this.ints.value = [0];
        FlashShader.ID++;
        filterInstace = new ShaderFilter(this);
    } 
}