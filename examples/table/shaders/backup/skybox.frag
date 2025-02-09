#version 330

// skybox fragment shader

in vec3 vertex;
in vec3 normal;

uniform vec3 eye;
uniform vec3 light;
uniform sampler2D probe;

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

vec3 chrome(float y)
{
    vec3 zenith = vec3(0.9, 0.9, 1);
    vec3 sky = vec3(0.6, 0.6, 0.9);
    vec3 ground = vec3(0.3, 0.3, 0.4);
    vec3 nadir = vec3(0.7, 0.5, 0.35);
    if (y > -0.1)
      return mix(zenith, sky, smoothstep(-0.1, 1, y));
    if (y > -0.4)
      return mix(ground, zenith, smoothstep(-0.4, -0.1, y));
    return mix(nadir, ground, smoothstep(-1, -0.4, y));
}

void main()
{
    vec3 ray = normalize(vertex - eye);
    vec2 uv = sphereMap(ray);

    vec3 tex = texture2D(probe, uv).rgb;
    /*vec3 c = chrome(ray.y);*/
    float s = smoothstep(0.0, -0.4, ray.y);
    // vec3 color = mix(tex, c, 0.7);
    if (ray.y < 0.3)
      tex = mix(tex, vec3(0.17, 0.14, 0.1), s);


    finalColor = vec4(tex, 1);
}

