shader_type spatial;
uniform sampler2D custom_texture : source_color, filter_nearest;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV;
	vec3 base_color = texture(custom_texture, uv).rgb;
	ALBEDO=base_color;
}