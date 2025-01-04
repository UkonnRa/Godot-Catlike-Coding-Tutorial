shader_type particles;
render_mode disable_force, disable_velocity;

uniform highp sampler2D position;
uniform highp sampler2D rotation;
uniform highp sampler2D data_info;
uniform int total;

const vec4 COLORS[] = { 
  vec4(1, 0, 0, 1), 
  vec4(0.823529, 0.411765, 0.117647, 1), 
  vec4(1, 1, 0, 1), 
  vec4(0, 1, 0, 1), 
  vec4(0, 1, 1, 1),
  vec4(0, 0, 1, 1),
  vec4(0.627451, 0.12549, 0.941176, 1)
};

void process() {
    highp float u = (float(INDEX) + 0.5) / float(total);
	vec4 pos = texture(position, vec2(u, 0));
	vec4 rot = texture(rotation, vec2(u, 0));
	vec4 info = texture(data_info, vec2(u, 0));
	float depth = info.z;

	float scale = pow(0.5, depth);
	
	mat4 translate_mat = mat4(
		vec4(1, 0, 0, 0),
		vec4(0, 1, 0, 0),
		vec4(0, 0, 1, 0),
		vec4(pos.xyz, 1)
	);
	
	mat4 scale_mat = mat4(
		vec4(scale, 0, 0, 0),
		vec4(0, scale, 0, 0),
		vec4(0, 0, scale, 0),
		vec4(0, 0, 0, 1)
	);
	
	TRANSFORM = translate_mat * scale_mat;
	
	COLOR = COLORS[int(depth)];
}
