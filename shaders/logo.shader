shader_type canvas_item;

void fragment(){
	vec4 originalColor = texture(TEXTURE,UV);
	vec2 U = UV/SCREEN_PIXEL_SIZE - .9;
    float x = .5 + length(UV) * cos( atan(UV.y,-UV.x) + TIME*2.628 ) ;
	if(originalColor.a < 0.5){
    	COLOR = mix( vec4(1, 0, 0, 1), vec4(1, 1, 0, 1), smoothstep(0.,1.,x) );
	}else{
		COLOR = originalColor;
		COLOR.a = 0.0;
	}
	
	
}