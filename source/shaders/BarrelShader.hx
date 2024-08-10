package shaders;

class BarrelShader extends AeroShader {
    @glFragmentSource('
    #pragma header

    uniform float mult;
    
    void main()
    {
        vec2 uv = openfl_TextureCoordv.xy;
        
        if (mult > 0) {
            uv.x += ((uv.x-0.46)*pow(uv.y-0.5,2.))*mult;
            uv.xy *= mix(1., 0.85, mult);
            uv.x += 0.075*mult;
            uv.y += 0.07*mult;
            if (uv.x < 0) {
                uv.x = 1.5;
            }
        } else {
            uv.x += (-(uv.x-0.46)*pow(uv.y-0.5,2.))*abs(mult);
        }
    
        vec4 col = flixel_texture2D(bitmap, uv);
        
        gl_FragColor = col;
    }
    ')

    public function new() {
        super(false);
        this.mult.value = [0];
    }

    /*
const bool i = true;

float  mult = 0.;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    mult = iTime;
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    
    if (i) {
        uv.x += ((uv.x-0.46)*pow(uv.y-0.5,2.))*mult;
        uv.xy *= mix(1., 0.85, mult);
        uv.x += 0.075*mult;
        uv.y += 0.07*mult;
    } else {
        uv.x += (-(uv.x-0.46)*pow(uv.y-0.5,2.))*mult;
    }

    // Time varying pixel color
    vec4 col = texture(iChannel0, uv);
    
    // Output to screen
    fragColor = col;
}
    */
}