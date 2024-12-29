#[compute]
#version 460

layout(local_size_x = 32, local_size_y = 1, local_size_z = 1) in;

struct FractalData {
    int depth;
    int idx;
    int parent_idx;
    vec3 position;
    vec4 world_quaternion;
    float spin_angle;
};

layout(set = 0, binding = 0) uniform FractalDataList {
    FractalData data[][];
};

void main() {
    uint idx = gl_GlobalInvocationID.x;
}
