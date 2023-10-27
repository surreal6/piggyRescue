/*
	MatCap Shader by Firerabbit
	
	MIT License
*/

shader_type spatial;

uniform sampler2D matcap : source_color, hint_default_black;
uniform float metalness : hint_range(0.0,1.0) = 1.0;
uniform vec4 color : source_color = vec4(1.0);

void fragment() {
	vec2 matcap_uv = (NORMAL.xy * vec2(0.5, -0.5) + vec2(0.5, 0.5));
	ALBEDO = color.rgb;
	ALBEDO *= mix(vec3(1.0), texture(matcap, matcap_uv).rgb, metalness);
}