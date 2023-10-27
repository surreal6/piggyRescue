shader_type spatial;
render_mode depth_draw_always, cull_disabled;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE: hint_depth_texture, filter_linear_mipmap;

global uniform vec4 w_albedo : source_color ;
global uniform vec4 w_albedo2 : source_color;
global uniform vec4 w_color_deep : source_color;
global uniform vec4 w_color_shallow : source_color;
global uniform float w_height_scale;
global uniform float w_noise_scale;
global uniform sampler2D w_text_normal;
global uniform sampler2D w_text_normal_2;
global uniform sampler2D w_wave;
global uniform sampler2D w_wave_bump;
global uniform float w_wave_speed;
global uniform float w_wave_time;
global uniform float w_normal_mix;
global uniform vec2 w_wave_direction;
global uniform vec2 w_wave_2_direction;

uniform float metallic : hint_range(0.0, 1.0) = 0;
uniform float roughness : hint_range(0.0, 1.0) = 0.02;

uniform float time_scale : hint_range(0.0, 0.2, 0.005) = 0.025;
uniform float beers_law = 2.0;
uniform float depth_offset = -0.75;

varying float height;
varying vec3 world_pos;

uniform float edge_scale = 0.1;
uniform float near = 0.5;
uniform float far = 100.0;
uniform vec3 edge_color : source_color;

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

float edge(float depth) {
	return near * far / (far + depth * (near - far));
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	height = texture(w_wave, world_pos.xz / w_noise_scale + w_wave_time * w_wave_speed).r;
	VERTEX.y += height * w_height_scale;
}

void fragment() {
	float depth_texture = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	float depth = PROJECTION_MATRIX[3][2] / (depth_texture + PROJECTION_MATRIX[2][2]);
	depth = depth + VERTEX.z;
	float depth_blend = exp((depth + depth_offset) * -beers_law);
	depth_blend = clamp(1.0 - depth_blend, 0.0, 1.0);
	
	vec3 screen_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, depth_blend * 2.5).rgb;
	vec3 depth_color = mix(w_color_shallow.rgb, w_color_deep.rgb, depth_blend);
	vec3 color = mix(screen_color * depth_color, depth_color * 0.25, depth_blend * 0.5);
	
	float z_depth = edge(texture(DEPTH_TEXTURE, SCREEN_UV).x);
	float z_pos = edge(FRAGCOORD.z);
	float z_dif = z_depth - z_pos;
	
	vec2 time = (TIME * w_wave_direction) * time_scale;
	vec2 time2 = (TIME * w_wave_2_direction) * time_scale;

	vec3 normal_blend = mix(texture(w_text_normal, world_pos.xz / w_noise_scale + time).rgb, 
							texture(w_text_normal_2, world_pos.xz / w_noise_scale + time2).rgb, 0.5);
	
	vec3 wave_normal_map = mix(texture(w_wave_bump, world_pos.xz / w_noise_scale + w_wave_time * w_wave_speed).xyz,
								texture(w_wave_bump, world_pos.xz / w_noise_scale + w_wave_time * w_wave_speed).xyz, 0.3);

	NORMAL_MAP = mix(wave_normal_map, normal_blend, w_normal_mix);
	
	float fresnel = fresnel(5.0, NORMAL, VIEW);
	vec3 surface_color = mix(w_albedo.rgb, w_albedo2.rgb, fresnel);
	vec3 depth_color_adj = mix(edge_color, color, step(edge_scale, z_dif));
	
	ALBEDO = clamp(surface_color + depth_color_adj,vec3(0),vec3(1.0));
	ALPHA = 1.0;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	NORMAL_MAP = normal_blend;
}