package shaders;

class HeatWaveShader extends AeroShader {
    public var intensityFactor:Float = 1;
    @glFragmentSource('
    #pragma header
    uniform float iTime;
    uniform float intensity;
    uniform float yFactor;


    void main(void) {
        vec2 uv = openfl_TextureCoordv.xy;
        
        uv.x -= intensity; // so the right side isnt black, the left side clamps
        uv.x += sin((uv.y/yFactor) + iTime)*intensity;
        vec4 col = flixel_texture2D(bitmap, uv);

        gl_FragColor = col; 
    }
    ') // scrapped cause look no good

    override public function new(intensity:Float, ?yFactor:Float = 0.5) {
        super(true);
        this.intensity.value = [intensity];
        this.iTime.value = [0.]; //glsl is a mind virus WHY DID I WRITE 0. IN HAXE
        this.yFactor.value = [yFactor]; 
    }

    override function update(e:Float) {
        super.update(e);
        this.iTime.value = [shaderTime];
    }
}