shader_type canvas_item;

uniform float flashState : hint_range(0,1);
uniform sampler2D noise;
uniform float dissolveState : hint_range(0,1);

void fragment(){
	vec4 color = texture(TEXTURE,UV);
	float brightness = (color.r + color.b +color.g) / 3.0;
	COLOR = vec4(mix(color.rgb, vec3(brightness), flashState),color.a);
	
	float noise_val = texture(noise, UV).r;
	if (noise_val < dissolveState)
		COLOR.a = 0.0;
	//COLOR.rgb = vec3(noise_val);
	
	// HI
	
}