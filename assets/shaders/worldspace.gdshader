// Copyright 2024 Emerson Rowland
// MIT License
// Dodecahedral Multi-Planar projection shader.

shader_type spatial;

uniform sampler2D albedo_tex : source_color, filter_nearest;
uniform float blend_value : hint_range(0.05, 0.2, 0.01) = 0.1;

// Dodecahedron Face Normals
const vec3 p_normals[12] = vec3[12](
	vec3(0.0, 1.0, 0.0),
	vec3(0.0, -0.447214, 0.894427),
	vec3(0.0, 0.447214, -0.894427),
	vec3(0.0, -1.0, 0.0),
	vec3(0.85369, 0.443003, -0.273791),
	vec3(-0.85369, 0.443003, -0.273791),
	vec3(0.85369, -0.443003, 0.273791),
	vec3(-0.85369, -0.443003, 0.273791),
	vec3(0.530692, 0.445591, 0.720982),
	vec3(-0.530692, 0.445591, 0.720982),
	vec3(0.530692, -0.445591, -0.720982),
	vec3(-0.530692, -0.445591, -0.720982)
);

varying vec3 w_vertex;
varying vec3 w_normal;

vec3[4] d_normal(vec3 surface_normal) {
	float dot_a = -1.0;
	float dot_b = -1.0;
	float dot_c = -1.0;
	int p_index_a = 0;
	int p_index_b = 0;
	int p_index_c = 0;
	// Determine 1st, 2nd & 3rd Nearest Faces.
    for (int i = 0; i < 12; i++) {
		float dot_product = dot(surface_normal, p_normals[i]);
		if (dot_product > dot_a) {
			dot_c = dot_b;
			p_index_c = p_index_b;
			dot_b = dot_a;
			p_index_b = p_index_a;
			dot_a = dot_product;
			p_index_a = i;
		} else if (dot_product > dot_b) {
			dot_c = dot_b;
			p_index_c = p_index_b;
			dot_b = dot_product;
			p_index_b = i;
		} else if (dot_product > dot_c) {
			dot_c = dot_product;
			p_index_c = i;
		}
	}
	return vec3[4](
		// Primary 12 Face Direction
		p_normals[p_index_a],
		// Secondary Direction
		normalize(p_normals[p_index_a] + p_normals[p_index_b]),
		// Tertiary Direction
		normalize(p_normals[p_index_a] + p_normals[p_index_b] + p_normals[p_index_c]),
		// Blending weights
		vec3(
			smoothstep(0.833,1.0,dot_a),
			smoothstep(0.833,1.0,dot_b+blend_value),
			smoothstep(0.833,1.0,dot_c+(blend_value * 2.0))
		)
	);
}

// Derived from https://iquilezles.org/articles/noacos/ MIT license - Inigo Quilez 2013
mat3 p_align(vec3 normal) {
	const vec3 up = vec3(0., 1., 0.);
	if (dot(up, normal) < -0.999) {
		normal *= -1.0;
	}
	vec3 v = cross(up, normal);
	float c = dot(up, normal);
	float k = 1.0 / (1.0 + c);

	float vxy = v.x * v.y;
	float vxz = v.x * v.z;
	float vyz = v.y * v.z;

	return mat3(
		vec3(fma(v.x * v.x, k, c), fma(vxy, k, -v.z), fma(vxz, k, v.y)),
		vec3(fma(vxy, k, v.z), fma(v.y * v.y, k, c), fma(vyz, k, -v.x)),
		vec3(fma(vxz, k, -v.y), fma(vyz, k, v.x), fma(v.z * v.z, k, c))
	);
}

vec4 tri_blend(vec4 value_a, vec4 value_b, vec4 value_c, vec3 weights) {
	weights /= weights[0] + weights[1] + weights[2];
	vec4 weighted_value = (
		value_a * weights[0] +
		value_b * weights[1] +
		value_c * weights[2]
		);
	return weighted_value;
}

void vertex() {
	// Obtain world space vertex and normal values.
	w_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	w_normal = MODEL_NORMAL_MATRIX * NORMAL;
	// Ensure Tangent/Binormal align with world space
	TANGENT = normalize(p_align(vec3(-1.0, 0.0 , 0.0)) * w_normal);
	BINORMAL = normalize(p_align(vec3(0.0, 0.0 , 1.0)) * w_normal);
}

void fragment() {
	// If wanting per-pixel normals, eg. for terrain
	//NORMAL = mat3(VIEW_MATRIX) * (w_normal);
	//TANGENT = mat3(VIEW_MATRIX) * (p_align(vec3(-1.0, 0.0 , 0.0)) * w_normal);
	//BINORMAL = mat3(VIEW_MATRIX) * (p_align(vec3(0.0, 0.0 , 1.0)) * w_normal);
	
	// Vector 3's containing 3 orthogonal Projection vectors, and 1 set of 3 blending weights.
	vec3[4] p_dir = d_normal(w_normal);
	
	vec4 albedo_a = vec4(1), albedo_b = vec4(1), albedo_c = vec4(1);
	vec4 normal_a = vec4(1), normal_b = vec4(1), normal_c = vec4(1);

	vec2 p_uv[3] = vec2[3](
		(p_align(p_dir[0]) * w_vertex).xz,
		(p_align(p_dir[1]) * w_vertex).xz,
		(p_align(p_dir[2]) * w_vertex).xz
	);

	if (p_dir[3][0] > 0.0) {
	albedo_a = texture(albedo_tex, p_uv[0]);
	}

	if (p_dir[3][1] > 0.0) {
	albedo_b = texture(albedo_tex, p_uv[1]);
	}

	if (p_dir[3][2] > 0.0) {
	albedo_c = texture(albedo_tex, p_uv[2]);
	}

	vec4 out_albedo = tri_blend(albedo_a, albedo_b, albedo_c, p_dir[3]);

	ALBEDO = out_albedo.rgb;

}
