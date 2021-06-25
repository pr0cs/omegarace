shader_type canvas_item;

uniform vec2 center;
uniform float force : hint_range(0,1);
uniform float size : hint_range(0,1);
uniform float thickness : hint_range(0,1);

void fragment(){
	float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	//ratio = 720.0/1280.0;
	vec2 scaledUV = (UV - vec2(0.5,0.0)) / vec2(ratio,1.0) + vec2(0.5,0.0);
	float mask = (1.0 - smoothstep(size-0.1,size,length(scaledUV - center))) *
		smoothstep(size-thickness-0.1,size-thickness,length(scaledUV - center)); // donut
	vec2 disp = normalize(scaledUV - center) * force * mask;
	//COLOR = vec4(UV - disp,0.0,1.0);
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV - disp);
	//COLOR.rgb = vec3(mask);
	
}