shader_type spatial;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

global uniform float w_height_scale;
global uniform float w_noise_scale;

global uniform sampler2D w_wave;
global uniform float w_wave_speed;

global uniform float w_wave_time;


uniform float water_level = 1.0;
uniform sampler2D wave;

uniform float edge_scale = 0.25;
uniform vec4 edge_color : source_color;

varying vec3 world_pos;

uniform vec4 tint : source_color;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float height = texture(w_wave, world_pos.xz / w_noise_scale + w_wave_time * w_wave_speed).r;
	float depth;
	if (world_pos.y - water_level <= height * w_height_scale) {
		depth = 1.0;
	} else {
		depth = 0.0;
	}
	float edge;
	float edge_scale2 = edge_scale * 0.1;
	if (world_pos.y - water_level > (height + edge_scale2) * w_height_scale ||
		 world_pos.y - water_level < (height - edge_scale2) * w_height_scale ) {
		edge = 0.0;
	} else {
		edge = 1.0;
	}
	vec3 prev_ALBEDO = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	ALBEDO = mix(mix(prev_ALBEDO, prev_ALBEDO * tint.rgb, depth), edge_color.rgb, edge);
}
