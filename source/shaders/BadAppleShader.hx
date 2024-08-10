package shaders;

class BadAppleShader extends AeroShader {
    @:glFragmentSource('
    #pragma header
    
    uniform vec4 target;
    
    void main()
    {
        vec4 col = flixel_texture2D(bitmap, openfl_TextureCoordv.xy);
        col.rgb = mix(col.rgb, target.rgb, target.a)*col.a;
        gl_FragColor = col;
        // a whole ass shader for just this lmao
    }
    ')

    public function new() {
        super(false);
        target.value = [0,0,0,0];
    }
}