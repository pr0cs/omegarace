shader_type canvas_item;

uniform float square_size = 0.05;
uniform vec4 from : hint_color = vec4(0.2, 0.2, 0.6, 1.0);
uniform vec4 to : hint_color = vec4(0.4, 1.0, 1.0, 1.0);

float rand(float seed) {
	return fract(sin(dot(vec2(seed, 10), vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
	COLOR *= mix(from, to, rand(float(int(UV.x / square_size)) * square_size + TIME / 100000.0));
}