shader_type canvas_item;

uniform sampler2D noise: hint_white;

void fragment(){
	
	vec2 uv = FRAGCOORD.xy / SCREEN_PIXEL_SIZE.xy - 0.5;
    uv.x *= SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
    
    //float h = 0.01 + abs(sin(iTime)) / 30.0;
    float h = 0.3;
    float c = 0.0;
    float f = clamp(abs(sin(TIME)), 0.1, 1.0);
    
    float intensity = 2.8;
    float thickness = 0.2;
    
    if(abs(uv.y) < h) {
        c = pow(thickness * h / abs(uv.y), intensity);
        //c = 1.0 - pow(thickness / (h - abs(uv.y)), intensity);
    }
    
    vec3 col = vec3(c);
    
    COLOR = vec4(col, 1.0);
    COLOR *= vec4(1.0, 1.5, 2.1, 1.0) * f;
	
	/*
	 if(abs(uv.y) < h) {
    	c = 1.0 - smoothstep(0.0, h, abs(uv.y));
    }
    
    vec3 col = vec3(c);
    
    //COLOR = vec4(col, 1.0);
    //COLOR *= vec4(1.0, 1.5, 2.1, 1.0) * f;
	
	uv = ( FRAGCOORD -.5* SCREEN_PIXEL_SIZE.xy ) / SCREEN_PIXEL_SIZE.y; 
	COLOR = c * f *vec4( 1,  1.5, 2.1, 1 )
	*/
	
}