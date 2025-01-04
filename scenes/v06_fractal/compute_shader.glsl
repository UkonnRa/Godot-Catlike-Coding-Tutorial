#[compute]
#version 460

#define PI 3.1415926535897932384626433832795
#define CHILD_COUNT 5

layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

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

layout(set = 0, binding = 0, std430) buffer DataBuffer {
    FractalData data[];
};

layout(push_constant, std430) uniform Params {
    float depth;
	float delta;
} params;

float get_scale(uint depth) {
    return pow(0.5, depth);
}

uint total_count_in_depth(uint depth) {
    return uint(round((pow(CHILD_COUNT, float(depth + 1)) - 1.0) / 4.0));
}

uint convert_local_to_global(uint idx, uint depth) {
    if (depth == 0) {
        return 0;        
    }
    return idx + total_count_in_depth(depth - 1);
}

vec4 quanternion_from_euler(vec3 euler) {
    float half_a1 = euler.y * 0.5f;
    float half_a2 = euler.x * 0.5f;
    float half_a3 = euler.z * 0.5f;

    float cos_a1 = cos(half_a1), sin_a1 = sin(half_a1);
    float cos_a2 = cos(half_a2), sin_a2 = sin(half_a2);
    float cos_a3 = cos(half_a3), sin_a3 = sin(half_a3);

    return vec4(
        sin_a1 * cos_a2 * sin_a3 + cos_a1 * sin_a2 * cos_a3,
		sin_a1 * cos_a2 * cos_a3 - cos_a1 * sin_a2 * sin_a3,
		-sin_a1 * sin_a2 * cos_a3 + cos_a1 * cos_a2 * sin_a3,
		sin_a1 * sin_a2 * sin_a3 + cos_a1 * cos_a2 * cos_a3);
}

vec4 quanternion_mul(vec4 a, vec4 b) {
    float xx = a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y;
    float yy = a.w * b.y + a.y * b.w + a.z * b.x - a.x * b.z;
    float zz = a.w * b.z + a.z * b.w + a.x * b.y - a.y * b.x;
    float ww = a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z;
    return vec4(xx, yy, zz, ww);
}

vec3 quanternion_mul(vec4 a, vec3 b) {
    vec3 u = vec3(a.x, a.y, a.z);
    vec3 uv = cross(u, b);
    return b + (uv * a.w + cross(u, uv)) * 2.0;
}

vec4 quanternion_mul_euler(vec4 a, vec3 b) {
    return quanternion_mul(a, quanternion_from_euler(b));
}

vec3[][2] DIRECTION_ROTATIONS = {
    { vec3(0, 1, 0), vec3(0, 0, 0) },
    { vec3(1, 0, 0), vec3(0, 0, -0.5 * PI) },
    { vec3(-1, 0, 0), vec3(0, 0, 0.5 * PI) },
    { vec3(0, 0, -1), vec3(-0.5 * PI, 0, 0) },
    { vec3(0, 0, 1), vec3(0.5 * PI, 0, 0) },
};

void main() {
    uint depth = uint(params.depth);
    float delta_angle = -PI / 8.0 * params.delta;

    if (depth == 0) {
        data[0].depth = depth;
        data[0].idx = 0;
        data[0].parent_idx = -1;
        data[0].position = vec3(0, 0, 0);

        data[0].spin_angle += delta_angle;
        data[0].world_quaternion = quanternion_from_euler(vec3(0, data[0].spin_angle, 0));

        return;
    }
    
    vec3[] dir_rot = DIRECTION_ROTATIONS[gl_GlobalInvocationID.x % 5];
    uint idx = convert_local_to_global(gl_GlobalInvocationID.x, depth);

    uint parent_local_idx = uint(round(gl_GlobalInvocationID.x / CHILD_COUNT));
    uint parent_idx = convert_local_to_global(parent_local_idx, depth - 1);
    FractalData parent = data[parent_idx];

    data[idx].depth = depth;
    data[idx].idx = idx;
    data[idx].parent_idx = parent_idx;

    data[idx].spin_angle += delta_angle;
    data[idx].world_quaternion = quanternion_mul_euler(
        quanternion_mul_euler(parent.world_quaternion, dir_rot[1]),
        vec3(0, data[idx].spin_angle, 0)
    );
    data[idx].position = parent.position + quanternion_mul(
        parent.world_quaternion,
        dir_rot[0]
    ) * 1.5 * get_scale(depth);
}
