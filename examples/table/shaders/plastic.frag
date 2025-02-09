#version 330

// plastic fragment shader

in vec3 vertex;
in vec3 normal;

uniform vec3 eye;
uniform vec3 light;

out vec4 finalColor;

void main()
{
    vec3 norm = normalize(normal);
    vec3 ray = normalize(light - vertex);
    float diff = max(dot(ray, norm), 0.2);

    vec3 view = normalize(vertex - eye);
    vec3 bounce = reflect(view, normal);
    float spec = pow(max(dot(ray, bounce), 0.0), 50);
    float specmix = 0.5;
    vec3 color = vec3(0.1, 0.1, 0.1);
    color * diff + spec * specmix;
    if (vertex.y < 0)
    {
        float s = smoothstep(0, -0.05, vertex.y);
        color = mix(color, vec3(0), s);
    }
    finalColor = vec4(color, 1);
}



