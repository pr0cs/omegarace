shader_type canvas_item;



void fragment(){
	// optimized https://www.shadertoy.com/view/Mt2XDK
	
	vec4 startColor = vec4(1.0, 0.0, 0.0, 1.0);
    vec4 endColor = vec4(1.0, 1.0, 0.0, 1.0);
    float currentAngle = -(TIME * 336.0);
    
    vec2 uv = FRAGCOORD.xy / SCREEN_PIXEL_SIZE.xy;
    
    vec2 origin = vec2(0.5, 0.5);
    uv -= origin;
    
    float angle = radians(90.0) - radians(currentAngle) + atan(UV.y, UV.x);

    float len = length(UV);
    uv = vec2(cos(angle) * len, sin(angle) * len) + (origin/4.0);
	    
    //COLOR = mix(startColor, endColor, smoothstep(0.0, 1.0, uv.x));
	COLOR = mix( vec4(1, 0, 0, 1), vec4(1, 1, 0, 1), smoothstep(0.,1.,uv.x) );
	
	
	/* 
	// OPTIMIZED
	vec2 U = UV/SCREEN_PIXEL_SIZE - .9;
    float x = .5 + length(UV) * cos( atan(UV.y,-UV.x) + TIME*2.628 ) ;
    COLOR = mix( vec4(1, 0, 0, 1), vec4(1, 1, 0, 1), smoothstep(0.,1.,x) );
	*/
}