shader_type canvas_item;

vec3 Strand(in vec2 ir, in float itime,in vec2 fragCoord, in vec3 color, in float hoffset, in float hscale, in float vscale, in float timescale)
{
    float glow = 0.06 * ir.y;
    float twopi = 6.28318530718;
    float curve = 1.0 - abs(fragCoord.y - (sin(mod(fragCoord.x * hscale / 100.0 / ir.x * 1000.0 + itime * timescale + hoffset, twopi)) * ir.y * 0.25 * vscale + ir.y / 2.0));
    float i = clamp(curve, 0.0, 1.0);
    i += clamp((glow + curve) / glow, 0.0, 1.0) * 0.4 ;
    return i * color;
}

vec3 Muzzle(in vec2 ir, in float itime, in vec2 fragCoord, in float timescale)
{
    float theta = atan(ir.y / 2.0 - fragCoord.y, ir.x - fragCoord.x + 0.13 * ir.x);
	float len = ir.y * (10.0 + sin(theta * 20.0 + float(int(itime * 20.0)) * -35.0)) / 11.0;
    float d = max(-0.6, 1.0 - (sqrt(pow(abs(ir.x - fragCoord.x), 2.0) + pow(abs(ir.y / 2.0 - ((fragCoord.y - ir.y / 2.0) * 4.0 + ir.y / 2.0)), 2.0)) / len));
    return vec3(d * (1.0 + sin(theta * 10.0 + floor(itime * 20.0) * 10.77) * 0.5), d * (1.0 + -cos(theta * 8.0 - floor(itime * 20.0) * 8.77) * 0.5), d * (1.0 + -sin(theta * 6.0 - floor(itime * 20.0) * 134.77) * 0.5));
}

void fragment(){
	float timescale = 14.0;
	vec3 c = vec3(0, 0, 0);
	//vec3 sps = SCREEN_PIXEL_SIZE;
	//float itime = TIME;
	//vec2 fg = FRAGCOORD;
	vec2 uv = UV;
	
    c += Strand(1.0/SCREEN_PIXEL_SIZE,TIME,UV, vec3(1.0, 0, 0), 0.7934 + 1.0 + sin(TIME) * 30.0, 1.0, 0.16, 10.0 * timescale);
    c += Strand(1.0/SCREEN_PIXEL_SIZE,TIME,UV, vec3(0.0, 1.0, 0.0), 0.645 + 1.0 + sin(TIME) * 30.0, 1.5, 0.2, 10.3 * timescale);
    c += Strand(1.0/SCREEN_PIXEL_SIZE,TIME,UV, vec3(0.0, 0.0, 1.0), 0.735 + 1.0 + sin(TIME) * 30.0, 1.3, 0.19, 8.0 * timescale);
    c += Strand(1.0/SCREEN_PIXEL_SIZE,TIME,UV, vec3(1.0, 1.0, 0.0), 0.9245 + 1.0 + sin(TIME) * 30.0, 1.6, 0.14, 12.0 * timescale);
    c += Strand(1.0/SCREEN_PIXEL_SIZE,TIME,UV, vec3(0.0, 1.0, 1.0), 0.7234 + 1.0 + sin(TIME) * 30.0, 1.9, 0.23, 14.0 * timescale);
    c += Strand(1.0/SCREEN_PIXEL_SIZE,TIME,UV, vec3(1.0, 0.0, 1.0), 0.84525 + 1.0 + sin(TIME) * 30.0, 1.2, 0.18, 9.0 * timescale);
    c += clamp(Muzzle(SCREEN_PIXEL_SIZE,TIME,UV, timescale), 0.0, 1.0);
	COLOR = vec4(c.r, c.g, c.b, 1.0);
}