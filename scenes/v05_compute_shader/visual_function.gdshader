shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform sampler2D texture_position;
uniform int idx;
uniform int resolution;

void vertex() {
    float offset = 2.0 / float(resolution);
    
    float u = float(idx / resolution) / float(resolution);
    float v = float(idx % resolution) / float(resolution);
    vec3 middle = texture(texture_position, vec2( u, v ) ).xyz;
    vec3 delta = vec3(0);
    if (VERTEX_ID == 0) {
    	delta = vec3(1, 1, 1);
    } else if (VERTEX_ID == 1) {
		delta = vec3(1, 1, -1);
	} else if (VERTEX_ID == 2) {
		delta = vec3(-1, 1, -1);
	} else if (VERTEX_ID == 3) {
		delta = vec3(-1, 1, 1);
	} else if (VERTEX_ID == 4) {
		delta = vec3(1, -1, 1);
    } else if (VERTEX_ID == 5) {
		delta = vec3(1, -1, -1);
	} else if (VERTEX_ID == 6) {
		delta = vec3(-1, -1, -1);
	} else if (VERTEX_ID == 7) {
		delta = vec3(-1, -1, 1);
	}
	
// 	VERTEX = vec3(float(idx), 0, 0);
	VERTEX = middle + delta * offset;
	POINT_SIZE = 10.0;
}

void fragment() {
// Input:14
	vec3 n_out14p0 = NODE_POSITION_WORLD;


// VectorOp:15
	vec3 n_in15p1 = vec3(0.50000, 0.50000, 0.50000);
	vec3 n_out15p0 = n_out14p0 * n_in15p1;


// VectorOp:16
	vec3 n_in16p1 = vec3(0.50000, 0.50000, 0.50000);
	vec3 n_out16p0 = n_out15p0 + n_in16p1;


// VectorFunc:17
	vec3 n_out17p0 = max(min(n_out16p0, vec3(1.0)), vec3(0.0));


// Output:0
	ALBEDO = n_out17p0;
}
