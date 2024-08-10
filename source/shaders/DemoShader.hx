package shaders;

class DemoShader extends AeroShader {
    @glFragmentSource('
    #pragma header
    void main(void) {
        vec2 uv = openfl_TextureCoordv.xy;
        uv.x += 0.5;
        vec4 col = flixel_texture2D(bitmap, uv);

        gl_FragColor = col;
    }
    ')

    public function new() {
        super(false);
    }
}