shader_type spatial;

uniform vec3 albedo : source_color;
uniform vec3 albedo2 : source_color;

uniform float fresnel_value : hint_range(0.0, 5.0, 0.1);

float fresnel(float amount, vec3 normal, vec3 view){
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void fragment() {
	float fresnel = fresnel(fresnel_value, NORMAL, VIEW);
	ALBEDO = mix(albedo, albedo2, fresnel);
}

