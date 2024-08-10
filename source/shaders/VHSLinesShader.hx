package shaders;

class VHSLinesShader extends AeroShader {
    @:glFragmentSource('
    #pragma header

    float rand(vec2 co){
        return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
    }
    
    uniform int blocks;
    uniform int timeMult;
    uniform float iTime;
    
    void main()
    {
        vec2 uv = openfl_TextureCoordv.xy;
    
        vec4 col = flixel_texture2D(bitmap, uv);
        
        if (blocks != -1 && timeMult != -1) {
            float lowestBlock = 0.;
            float midpointToEnd = 0.;
        
             for (float i = 0.; i < float(blocks); i++) {
                    if (1.-uv.y < ((i+1.)/float(blocks))) {
                        lowestBlock = ((i+1.)/float(blocks));
                        break;
                    }
             }
             
            float div = 1000.;
            
            for (int i = 0; i<timeMult; i++) {
                div *= 10.;
            }
            
            bool todo = rand(vec2(iTime/div, lowestBlock))>0.95;
            if (todo) {
                int sideBlocks = int(float(blocks)*(16./9.));
                for (float i = 0.; i < float(blocks); i++) {
                   if (uv.x < (i+1.)/float(blocks)) {
                       float ret = (i)/float(blocks); 
                       ret *= (pow(distance(uv.x, 0.5), rand(vec2(iTime))*(rand(vec2(iTime))*5.)))*20.;
                       float r = min(rand(vec2(iTime*lowestBlock))/7., 0.2);
                       todo = (ret < r || 1.-ret < r-(rand(vec2(iTime))-0.5)/10.);
                       break;
                   }
                }
                
               if (todo) col.rgb = mix(col.rgb, vec3(1.), rand(vec2(iTime, uv.y)));
               
            }
        }
        gl_FragColor = col;
    }
    ')

    public function new() {
        super(true);
        this.blocks.value = [-1];
        this.timeMult.value = [0];
    }

    override function update(e:Float) {
        super.update(e);
        iTime.value = [shaderTime];
    }
}