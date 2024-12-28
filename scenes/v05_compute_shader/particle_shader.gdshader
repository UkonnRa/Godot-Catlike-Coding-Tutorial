shader_type particles;
render_mode disable_force, disable_velocity;

uniform sampler2D texture_position;
uniform int resolution;

void process() {
	int idx = int(INDEX);
	float u = float(idx / resolution) / float(resolution);
	float v = float(idx % resolution) / float(resolution);
	vec4 pos = texture(texture_position, vec2(u, v));
	TRANSFORM[3].xyz = pos.xyz;
}
