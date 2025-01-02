#[compute]
#version 460

layout(local_size_x = 32, local_size_y = 1, local_size_z = 1) in;

struct FractalData {
    float depth;
    float idx;
    float parent_idx;
    float __pad0;
    vec3 position;
    float __pad1;
    vec4 world_quaternion;
    float spin_angle;
    float __pad2;
    float __pad3;
    float __pad4;
};

layout(set = 0, binding = 0, std430) readonly buffer ParentData {
    FractalData parent_data[];
};

layout(set = 1, binding = 0, std430) buffer CurrentData {
    FractalData current_data[];
};

layout(push_constant, std430) uniform Params {
	float delta;
};

void main() {
    current_data[0].depth = parent_data[0].depth;
    current_data[0].idx = parent_data[0].idx;
    current_data[0].parent_idx = parent_data[0].parent_idx;
    current_data[0].position = parent_data[0].position;
    current_data[0].world_quaternion = parent_data[0].world_quaternion;
    current_data[0].spin_angle = parent_data[0].spin_angle;

    current_data[1].depth = delta * parent_data[0].depth;
    current_data[1].idx = delta * parent_data[0].idx;
    current_data[1].parent_idx = delta * parent_data[0].parent_idx;
    current_data[1].position = delta * parent_data[0].position;
    current_data[1].world_quaternion = delta * parent_data[0].world_quaternion;
    current_data[1].spin_angle = delta * parent_data[0].spin_angle;
}
