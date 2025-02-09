#version 330

// ball fragment shader

#define PI 3.14159265359
#define PI_HALF 1.57079632679

in vec3 vertex;
in vec3 normal;
in vec3 up;
in vec3 front;
in vec3 center;
in vec2 texcoord;
in vec3 sphere;

uniform vec3 eye;
uniform vec3 light;
uniform int index;
uniform sampler2D probe;
uniform sampler2D numbers;

out vec4 finalColor;

vec2 sphereMap(vec3 ray)
{
    vec2 uv;
    uv.x = 0.5 + (atan(ray.z, ray.x) / (2.0 * 3.14159265359));
    uv.y = 0.5 - (asin(ray.y) / 3.14159265359);
    vec2 center = uv - vec2(0.5);
    float dist = length(center);
    if (dist > 0.49)
      center = normalize(center) * 0.49;
    uv = center + vec2(0.5);
    return uv;
}

vec3 digits(vec3 color)
{
    const float edge = 0.007;
    if (abs(texcoord.x) > edge || abs(texcoord.y) > edge)
        return color;
    vec2 uv;
    uv.x = (texcoord.x + edge) / (edge * 2);
    uv.y = (texcoord.y + edge) / (edge * 2);

    uv.y = 1 - uv.y;
    if (vertex.z < 0)
      uv.x = 1. - uv.x;
    // our number texture uses a 4x4 grid with 16 numbers
    int i = index - 1;
    uv = uv / 4.0;
    uv.x = uv.x + mod(i, 4) * 0.25;
    uv.y = uv.y + i / 4 * 0.25;
    color = texture(numbers, uv, -0.5).rgb;
    // reset the texure coord to 0, 0
    uv.x = uv.x - mod(i, 4) * 0.25;
    uv.y = uv.y - i / 4 * 0.25;
    const float cutoff = 0.0125;
    if (uv.y < cutoff)
      color = vec3(1);
    if (uv.x < cutoff)
      color = vec3(1);
    if (uv.x + cutoff > 0.25)
      color = vec3(1);
    if (uv.y + cutoff > 0.25)
      color = vec3(1);
    return color;
}

vec3 colors[8] = vec3[](
    vec3(1.000, 0.843, 0.000),
    vec3(1.000, 0.000, 0.000),
    vec3(0.000, 0.000, 1.000),
    vec3(0.502, 0.000, 0.502),
    vec3(0.900, 0.400, 0.000),
    vec3(0.000, 0.502, 0.000),
    vec3(0.549, 0.000, 0.102),
    vec3(0.100, 0.100, 0.100)
);

vec3 ball()
{
    if (index == 0)
      return vec3(1);
    vec3 color = colors[(index - 1) % 8];

    vec3 spot = front - center; //vec3(0, 0, -1);
    vec3 stripe = up; vec3(0, 1, 0);
    vec3 v = vertex - center;
    v = normalize(v);

    float angle = 0;
    float blend = 0;

    // stripe
    if (index > 8)
    {
      angle = acos(clamp(dot(v, stripe), -1.0, 1.0));
      if (angle > PI_HALF)
        angle = PI - angle;

      if (angle > 0.98)
        blend = smoothstep(0.98, 1.02, angle);
      color = mix(vec3(1), color, blend);
    }

    //
    //v = normalize(v);

    angle = acos(clamp(dot(v, spot), -1.0, 1.0));
    if (angle > PI_HALF)
      angle = PI - angle;
    blend = smoothstep(0.37, 0.41, angle);

    color = mix(vec3(1), color, blend);
    color = digits(color);

    return color;
}

vec3 shade(vec3 color)
{
    vec3 norm = normalize(normal);
    vec3 ray = normalize(light - vertex);

    // 3 lights blended together
    float diffa = max(dot(ray, norm), 0.4);
    float diffb = max(dot(normalize(vec3(1, 0.5, -0.8)), norm), -0.5);
    diffb = smoothstep(-0.5, 1, diffb);
    float diffc = max(dot(normalize(vec3(-1.5, 0.9, 0.8)), norm), -0.5);
    diffc = smoothstep(-0.5, 1, diffc);
    color = color * (diffa * 0.7 + diffb * 0.6 + diffc * 0.4);

    // specular light
    vec3 view = normalize(vertex - eye);
    vec3 bounce = reflect(view, normal);
    float spec = pow(max(dot(ray, bounce), 0.0), 10);

    // reflection
    vec2 uv = sphereMap(bounce);
    vec3 tex = texture(probe, uv).rgb * 1.3;
    float edge = 1 - max(dot(norm, normalize(vec3(eye - vertex))), 0);
    edge = pow(edge, 2);
    tex = mix(color, tex, edge);
    color = mix(tex, color, 0.5);

    return vec3(color + spec * 0.0);
}

void main()
{
    vec3 norm = normalize(normal);
    vec3 color = ball();
    color = shade(color);

    // fake ambient occlusion with the ground
    vec3 down = vec3(0, -1, 0);
    float shadow = 1 - max(dot(norm, down), 0.0);
    shadow = smoothstep(-0.2, 1, shadow);
    shadow = mix(0.3, 1, shadow);

    finalColor = vec4(color * shadow, 1);
}



