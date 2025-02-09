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
    float diff = max(dot(ray, norm), 0.2);
    vec3 color = vec3(0.6, 0.3, 0.0);

    vec3 view = normalize(vertex - eye);
    vec3 bounce = reflect(view, normal);
    float spec = pow(max(dot(ray, bounce), 0.0), 50);
    float specmix = 0.5;
    finalColor = vec4(color * diff + spec * specmix, 1);
}



