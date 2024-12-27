#[compute]
#version 460

#define PI 3.1415926535897932384626433832795

layout(local_size_x = 32, local_size_y = 1, local_size_z = 1) in;

layout(rgba32f, set = 0, binding = 0) uniform restrict image2D output_image;

layout(push_constant, std430) uniform Params {
	float resolution;
	float time;
	float funcIndex;
} params;

vec3 wave(float u, float v, float t) {
    return vec3(u, sin(PI * (u + v + t)), v);
}

vec3 multiWave(float u, float v, float t) {
    float y1 = sin(PI * (u + 0.5 * t));
    float y2 = 0.5 * sin(2 * PI * (v + t));
    return vec3(u, 2.0 / 3.0 * (y1 + y2), v);
}

vec3 ripple(float u, float v, float t) {
    float d = sqrt(u * u + v * v);
    return vec3(u, sin(PI * (4 * d - t)) / (1 + 10 * d), v);
}

vec3 bun(float u, float v, float t) {
    float r = cos(0.5 * PI * v);
    return vec3(r * sin(PI * u), v, r * cos(PI * u));
}

vec3 sphere(float u, float v, float t) {
    float r = 0.5 + 0.5 * sin(PI * t);
    float s = r * cos(0.5 * PI * v);
    return vec3(s * sin(PI * u), r * sin(0.5 * PI * v), s * cos(PI * u));
}

vec3 sphere_verticle_band(float u, float v, float t) {
    float r = 0.9 + 0.1 * sin(4 * PI * (u + t));
    float s = r * cos(0.5 * PI * v);
    return vec3(s * sin(PI * u), r * sin(0.5 * PI * v), s * cos(PI * u));
}

vec3 sphere_horizontal_band(float u, float v, float t) {
    float r = 0.9 + 0.1 * sin(4 * PI * (v + t));
    float s = r * cos(0.5 * PI * v);
    return vec3(s * sin(PI * u), r * sin(0.5 * PI * v), s * cos(PI * u));
}

vec3 sphere_twisted_band(float u, float v, float t) {
    float r = 0.9 + 0.1 * sin( PI * (6 * u + 4 * v + t));
    float s = r * cos(0.5 * PI * v);
    return vec3(s * sin(PI * u), r * sin(0.5 * PI * v), s * cos(PI * u));
}

vec3 torus(float u, float v, float t) {
    float r1 = 0.75 + 0.1 * sin(PI * (10 * u + 0.5 * t));
    float r2 = 0.15 + 0.05 * sin(PI * (8 * u + 5 * v + 2 * t));
    float s = r1 + r2 * cos(PI * v);
    return vec3(s * sin(PI * u), r2 * sin(PI * v), s * cos(PI * u));
}

void main() {
    uint idx = gl_GlobalInvocationID.x;
    uint resolution = uint(params.resolution);
    float t = params.time;
    float step = 2.0 / resolution;
    uint x = idx / resolution;
    uint z = idx % resolution;
    float u = (x + 0.5) * step - 1.0;
    float v = (z + 0.5) * step - 1.0;

    vec3 position;
    switch (uint(params.funcIndex)) {
    case 0:
        position = wave(u, v, t);
        break;
    case 1:
        position = multiWave(u, v, t);
        break;
    case 2:
        position = ripple(u, v, t);
        break;
    case 3:
        position = bun(u, v, t);
        break;
    case 4:
        position = sphere(u, v, t);
        break;
    case 5:
        position = sphere_verticle_band(u, v, t);
        break;
    case 6:
        position = sphere_horizontal_band(u, v, t);
        break;
    case 7:
        position = sphere_horizontal_band(u, v, t);
        break;
    case 8:
        position = sphere_twisted_band(u, v, t);
        break;
    case 9:
        position = torus(u, v, t);
        break;
    default:
        position = vec3(0, 0, 0);
        break;
    }

    imageStore(output_image, ivec2(x, z), vec4(position, 1.0));
}
