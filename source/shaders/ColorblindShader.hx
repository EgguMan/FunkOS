package shaders;

import openfl.filters.ShaderFilter;
import openfl.filters.BitmapFilter;
import flixel.system.FlxAssets.FlxShader;
import backend.save.ClientPrefs;

class ColorblindShader extends AeroShader {
    public static var instance:ColorblindShader;
    public static var instanceFILTER:BitmapFilter;

    // important to note, I made this shader from scratch, but, it wouldnt be possible without this! https://www.alanzucconi.com/2015/12/16/color-blindness/

    #if !html5
    @:glFragmentSource('
    #pragma header

    uniform int select;
    
    vec3 rCol[4] = vec3[4](vec3(.56667, .43333, 0.), vec3(.625,.375,.0), vec3(0.95,0.5,0.), vec3(.299,0.587,0.114));
    vec3 gCol[4] = vec3[4](vec3(.55833, .44167, 0.), vec3(.70,.30,.0), vec3(0.,0.43333,0.56667), vec3(0.299,0.587,0.114));
    vec3 bCol[4] = vec3[4](vec3(0., .24167, .75833), vec3(0.,.3,.7), vec3(0.,0.475,0.255), vec3(0.299,0.587,0.114));
    
    void main()
    {
        vec2 uv = openfl_TextureCoordv.xy;
    
        vec4 col = texture(bitmap, uv);
        vec3 initialCol = col.rgb;
        col.rgb = vec3(0.,0.,0.);
        
        col.r += initialCol.r * rCol[select].r;
        col.r += initialCol.b * bCol[select].r;
        col.r += initialCol.g * gCol[select].r;
    
        col.g += initialCol.r * rCol[select].g;
        col.g += initialCol.g * gCol[select].g;
        col.g += initialCol.b * bCol[select].g;
    
        col.b += initialCol.r * rCol[select].b;
        col.b += initialCol.g * gCol[select].b;
        col.b += initialCol.b * bCol[select].b;
        
        gl_FragColor = col;
    }
    ')
    #else
    @:glFragmentSource('
    #pragma header

    uniform int select;
    
    vec3 rCol[4];
    vec3 gCol[4];
    vec3 bCol[4];
    
    void main()
    {
        rCol[0] = vec3(0.56667, 0.43333, 0.0);
        rCol[1] = vec3(0.625, 0.375, 0.0);
        rCol[2] = vec3(0.95, 0.5, 0.0);
        rCol[3] = vec3(0.299, 0.587, 0.114);
        
        gCol[0] = vec3(0.55833, 0.44167, 0.0);
        gCol[1] = vec3(0.7, 0.3, 0.0);
        gCol[2] = vec3(0.0, 0.43333, 0.56667);
        gCol[3] = vec3(0.299, 0.587, 0.114);

        bCol[0] = vec3(0.0, 0.24167, 0.75833);
        bCol[1] = vec3(0.0, 0.3, 0.7);
        bCol[2] = vec3(0.0, 0.475, 0.255);
        bCol[3] = vec3(0.299, 0.587, 0.114);

        vec2 uv = openfl_TextureCoordv.xy;
    
        vec4 col = flixel_texture2D(bitmap, uv);
        vec3 initialCol = col.rgb;
        col.rgb = vec3(0.,0.,0.);
        
        if (select == 0) {
            col.r += initialCol.r * rCol[0].r;
            col.r += initialCol.b * bCol[0].r;
            col.r += initialCol.g * gCol[0].r;

            col.g += initialCol.r * rCol[0].g;
            col.g += initialCol.g * gCol[0].g;
            col.g += initialCol.b * bCol[0].g;

            col.b += initialCol.r * rCol[0].b;
            col.b += initialCol.g * gCol[0].b;
            col.b += initialCol.b * bCol[0].b;
        } else if (select == 1) {
            col.r += initialCol.r * rCol[1].r;
            col.r += initialCol.b * bCol[1].r;
            col.r += initialCol.g * gCol[1].r;

            col.g += initialCol.r * rCol[1].g;
            col.g += initialCol.g * gCol[1].g;
            col.g += initialCol.b * bCol[1].g;

            col.b += initialCol.r * rCol[1].b;
            col.b += initialCol.g * gCol[1].b;
            col.b += initialCol.b * bCol[2].b;
        } else if (select == 2) {
            col.r += initialCol.r * rCol[2].r;
            col.r += initialCol.b * bCol[2].r;
            col.r += initialCol.g * gCol[2].r;

            col.g += initialCol.r * rCol[2].g;
            col.g += initialCol.g * gCol[2].g;
            col.g += initialCol.b * bCol[2].g;

            col.b += initialCol.r * rCol[2].b;
            col.b += initialCol.g * gCol[2].b;
            col.b += initialCol.b * bCol[2].b;
        } else if (select == 3) {
            col.r += initialCol.r * rCol[3].r;
            col.r += initialCol.b * bCol[3].r;
            col.r += initialCol.g * gCol[3].r;

            col.g += initialCol.r * rCol[3].g;
            col.g += initialCol.g * gCol[3].g;
            col.g += initialCol.b * bCol[3].g;

            col.b += initialCol.r * rCol[3].b;
            col.b += initialCol.g * gCol[3].b;
            col.b += initialCol.b * bCol[3].b;
        }
        
    
        
    

        
        gl_FragColor = col;
    }
    ')
    #end

    public static var colors:Array<String> = ['Protanopia', 'Deuteranopia', 'Tritanopia', 'Achromatopsia']; //easy to mod! I'd like to add more filters in the future, but you can also add your own :)
    public function new() {
        var int = getSelect();
        super(false);
        this.select.value = [int]; 
        if (ColorblindShader.instance != null) {
            for (i in 0...6) {
            trace('WARNING!! SHADER OVERWRITE'); // making sure you know, but, i dont wanna throw an exception cause thats scary
            }
        }
        ColorblindShader.instance = this;
        ColorblindShader.instanceFILTER = new ShaderFilter(ColorblindShader.instance);
    }
    
    public static function getSelect() {
        var int = 0;
        for (i in 0...colors.length) {
            if (colors[i] == ClientPrefs.colorblindMode) {
                int = i;
                return int;
                break;
            }
        }
        return 0;
    }

}