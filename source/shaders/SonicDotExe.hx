package shaders;

import flixel.FlxG;

class SonicDotExe extends AeroShader {

    var total:Float = 0;

    @:glFragmentSource('
    #pragma header

    uniform float seed;
    uniform float time;
    uniform float thresh;
    uniform float sc;
    
    float rand(vec2 co){
        co += seed;
        return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
    }
    
    void main()
    {
        vec2 uv = openfl_TextureCoordv.xy;
    
        // Normalized pixel coordinates (from 0 to 1)
        if (rand(floor(uv*sc)) < thresh){
            uv.xy += rand(floor(uv*(sc*rand(vec2(sc*thresh, sc*thresh)))));
        }

        if (uv.x > 1.) {
            uv.x -= floor(uv.x);
        }
        if (uv.y > 1.) {
            uv.y -= floor(uv.y);
        }
    
        // Time varying pixel color
        vec4 col = flixel_texture2D(bitmap, uv);
    
        // Output to screen
        gl_FragColor = col;
    }
    ')

    public function new() {
        super(true);
        time.value = [0];
        seed.value = [0];
        thresh.value = [0];
        sc.value = [0];
    }

    override function update(e:Float) {
        super.update(e);
        total += e/100;
    }

    public function next() {
        this.time.value = [total];
        this.seed.value = [FlxG.random.float(0,10)];
        this.thresh.value = [this.thresh.value[0]+FlxG.random.float(0.005, 0.2)];
        this.sc.value = [this.sc.value[0]+FlxG.random.float(2.5, 12.5)];
    }
}