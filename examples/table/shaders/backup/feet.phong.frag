#version 330

// cabinet fragment shader

in vec3 vertex;
in vec3 normal;

uniform vec3 eye;
uniform vec3 light;

out vec4 finalColor;

void main()
{
    vec3 norm = normalize(normal);
    vec3 ray = normalize(light - vertex);
    float diff = max(dot(ray, norm), 0.1);
    vec3 color = vec3(0.6, 0.3, 0.0);
    if (vertex.y > -0.6)
    {   float s = smoothstep(-0.4, -0.6, vertex.y);
        color = mix(color * 0.2, color, s);
    }
    finalColor = vec4(color * diff, 1);
}



