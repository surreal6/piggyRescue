shader_type spatial;
render_mode cull_disabled, unshaded;

uniform vec4 albedo : source_color;

uniform sampler2D wave;

uniform float wave_time = 0;
uniform float wave_speed = 2.0;
uniform float noise_scale = 10.0;
uniform float height_scale = 1.5;

varying float height;
varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	height = texture(wave, world_pos.xz / noise_scale + wave_time * wave_speed).r;
	VERTEX.y += height * height_scale;
}

void fragment() {
	if (!FRONT_FACING) {
        NORMAL = -NORMAL;
    }
	ALBEDO = albedo.rgb;
//	ROUGHNESS = 0.0;
//	SPECULAR = 1.0;
}