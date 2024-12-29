shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform int depth;

const vec3 COLORS[] = { vec3(1.0, 0, 0), vec3(0, 1, 0), vec3(0, 0, 1) };

void fragment() {
	ALBEDO = COLORS[depth % COLORS.length()];
}
