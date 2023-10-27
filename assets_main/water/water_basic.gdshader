shader_type spatial;
render_mode cull_disabled, unshaded;

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

uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;
uniform vec2 wave_direction = vec2(2.0,0.0);
uniform vec2 wave_2_direction = vec2(0.0,1.0);
uniform float time_scale : hint_range(0.0, 0.2, 0.005) = 0.025;

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
	vec2 time = (TIME * wave_direction) * time_scale;
	vec2 time2 = (TIME * wave_2_direction) * time_scale;
	vec3 normal_blend = mix(texture(texture_normal, world_pos.xz / w_noise_scale + time).rgb, 
							texture(texture_normal2, world_pos.xz / w_noise_scale + time2).rgb, 0.5);
	
//	NORMAL_MAP = normal_blend;
	
	vec3 wave_normal_map = mix(texture(w_wave_bump, world_pos.xz / w_noise_scale + w_wave_time * w_wave_speed).xyz,
								texture(w_wave_bump, world_pos.xz / w_noise_scale + w_wave_time * w_wave_speed).xyz, 0.3);

	NORMAL_MAP = mix(wave_normal_map, normal_blend, normal_mix);
	
//	if (!FRONT_FACING) {
//		NORMAL_MAP = -NORMAL_MAP;
//    }

	vec2 matcap_uv = (NORMAL_MAP.xy * vec2(0.5, -0.5) + vec2(0.5, 0.5));
	ALBEDO = color.rgb * (COLOR.xyz + 0.3);
	ALBEDO *= mix(vec3(1.0), texture(matcap, matcap_uv).rgb, metalness);

	float fresnel = fresnel(5.0, NORMAL, VIEW);
	vec3 surface_color = mix(w_albedo.rgb, w_albedo2.rgb, fresnel);
//	ALBEDO = surface_color;
	ALBEDO = mix(ALBEDO, ALBEDO * vec3(albedo_factor) * surface_color, albedo_mix);
	//ROUGHNESS = 1.0;
	//SPECULAR = 0.0;
}