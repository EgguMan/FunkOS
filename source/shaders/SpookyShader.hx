package shaders;

import flixel.FlxG;

class SpookyShader extends AeroShader {
    @glFragmentSource('
    #pragma header

    uniform float vigVal;
    uniform float abberationVal;
    uniform float staticVal;

    uniform float iTime;
    
    float rand(vec2 co){ //https://stackoverflow.com/questions/4200224/random-noise-functions-for-glsl
        return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
    }
    
    void main()
    {
        vec2 uv = openfl_TextureCoordv.xy;
        
        float ran = rand(vec2(uv.x*sin(iTime),uv.y*cos(iTime)));
        
        
        vec4 col;
        if (abberationVal == 0.) {
            col = flixel_texture2D(bitmap, uv);
        } else {
            col = vec4(0.,0.,0.,1.);

            col.r = flixel_texture2D(bitmap, vec2(uv.x-(abberationVal/350.), uv.y)).r;
            col.ga = flixel_texture2D(bitmap, uv).ga;
            col.b = flixel_texture2D(bitmap, vec2(uv.x+(abberationVal/350.), uv.y)).b;
        }

        if (staticVal/50. > 1.-ran) {
            col.rgb = vec3(0.75, 0.75, 0.75);
        } else if (staticVal/5. > ran) {
            col.rgb = vec3(0.,0.,0.);
        } 
        
        col -= max(0.,distance(uv, vec2(0.5,0.5))-(0.7-vigVal))*(0.25+vigVal);
        col -= mix(vigVal, 0., 0.8);

        gl_FragColor = col;
    }
    ')

    public function new() {
        super(true);
        vigVal.value = [0.];
        staticVal.value = [0.];
        abberationVal.value = [0.];
        iTime.value = [FlxG.elapsed];
    }

    override public function update(e:Float) {
        iTime.value = [shaderTime];
        super.update(e);
    }

    public function getVal(val:Int) {
        switch (val) {
            case 0:
                return vigVal.value[0];
            case 2:
                return staticVal.value[0];
            case 3:
                return abberationVal.value[0];
        }
        return 0;
    }

    public function setVal(val:Int, toSet:Float) {
        switch (val) {
            case 0:
                vigVal.value[0] = toSet;
            case 2:
                staticVal.value[0] = toSet;
            case 3:
                abberationVal.value[0] = toSet;
        }
    }
}