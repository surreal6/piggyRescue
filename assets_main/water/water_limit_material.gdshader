shader_type spatial;
render_mode unshaded;

global uniform float w_height_scale;
global uniform float w_noise_scale;
global uniform sampler2D w_wave;
global uniform sampler2D w_wave_bump;
global uniform float w_wave_speed;
global uniform float w_wave_time;

global uniform vec4 w_albedo : source_color ;
global uniform vec4 w_albedo2 : source_color;
global uniform vec4 w_color_deep : source_color;
global uniform vec4 w_color_shallow : source_color;

uniform sampler2D matcap : source_color, hint_default_black;
uniform float metalness : hint_range(0.0,1.0) = 1.0;
uniform vec4 color : source_color = vec4(1.0);

uniform float edge_scale = 0.1;
uniform float near = 0.5;
uniform float far = 100.0;
uniform vec3 edge_color : source_color;

uniform float albedo_factor : hint_range(0.0, 40.0) = 10;
uniform float albedo_mix : hint_range(0.0, 1.0) = 0.5;

uniform float normal_mix : hint_range(0.0, 1.0) = .8;

varying vec3 world_pos;

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float height = texture(w_wave, world_pos.xz / w_noise_scale + w_wave_time * w_wave_speed).r;
	VERTEX.y += height * w_height_scale;
	COLOR.xyz = vec3(height);
}

void fragment() {
	float fresnel = fresnel(5.0, NORMAL, VIEW);
	vec3 surface_color = mix(w_albedo.rgb, w_albedo2.rgb, fresnel);
//	ALBEDO = mix(ALBEDO, ALBEDO * vec3(albedo_factor) * surface_color, albedo_mix);
	ALBEDO = surface_color;
	//ROUGHNESS = 1.0;
	//SPECULAR = 0.0;
}