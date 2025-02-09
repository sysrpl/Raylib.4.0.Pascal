#version 330

// shape fragment shader

in vec3 vertex;
in vec3 normal;

uniform vec3 eye;
uniform vec3 light;

out vec4 finalColor;

vec3 chrome(float y)
{
    vec3 zenith = vec3(0.85, 0.85, 1);
    vec3 sky = vec3(0.6, 0.6, 1);
    vec3 ground = vec3(0.5, 0.3, 0.15);
    vec3 nadir = vec3(0.7, 0.5, 0.35);
    if (y > -0.1)
      return mix(zenith, sky, smoothstep(-0.1, 1, y));
    if (y > -0.4)
      return mix(ground, zenith, smoothstep(-0.4, -0.1, y));
    return mix(nadir, ground, smoothstep(-1, -0.4, y));
}

vec4 phong(bool metal)
{
    vec3 norm = normalize(normal);
    vec3 ray = normalize(light - vertex);
    float diff = max(dot(ray, norm), 0.2);

    vec3 view = normalize(vertex - eye);
    vec3 bounce = reflect(view, normal);
    float spec = pow(max(dot(ray, bounce), 0.0), 50);

    vec3 color = vec3(0.8, 0.6, 0.4);
    if (metal)
        color = chrome(bounce.y);
    else
      color = color * diff;

    return vec4(color + spec, 1);
}

void main()
{
    finalColor = phong(false);
}

