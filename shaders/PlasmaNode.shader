shader_type canvas_item;



void fragment(){
	vec2 U = UV/SCREEN_PIXEL_SIZE - .9;
    float x = .5 + length(UV) * cos( atan(UV.y,-UV.x) + TIME*2.628 ) ;
    COLOR = mix( vec4(1, 0, 0, 1), vec4(1, 1, 0, 1), smoothstep(0.,1.,x) );
}