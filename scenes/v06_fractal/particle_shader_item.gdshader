shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

void fragment() {
	ALBEDO = COLOR.rgb;
}