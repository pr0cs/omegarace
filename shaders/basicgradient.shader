shader_type canvas_item;
// Basic radial gradient : https://www.shadertoy.com/view/4tjSWh
float dist(vec2 p0, vec2 pf){return sqrt((pf.x-p0.x)*(pf.x-p0.x)+(pf.y-p0.y)*(pf.y-p0.y));}

void fragment() {
	float d = dist(SCREEN_PIXEL_SIZE.xy*0.5,FRAGCOORD.xy)*(sin(TIME)+1.5)*0.003;
	COLOR = mix(vec4(1.0, 1.0, 1.0, 1.0), vec4(0.0, 0.0, 0.0, 1.0), d);
}