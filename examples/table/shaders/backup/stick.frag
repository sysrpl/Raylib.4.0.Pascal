#version 330

// stick fragment shader

#define PI 3.14159265359

in vec3 vertex;
in vec3 normal;
in vec3 stick;
in vec3 texcoords;

uniform vec3 eye;
uniform vec3 light;
uniform sampler2D probe;
uniform sampler2D wrap;

out vec4 finalColor;

vec2 cylinder()
{
    vec2 tex;
    tex.x = texcoords.x;
    tex.y = atan(texcoords.z, texcoords.y) / (2 * PI) + 0.5;
    tex = tex * vec2(0.9) + vec2(0.05);
    return tex;
}

//  edgeblend
//    smoothsteps hard edges using a position and edge
//    returns colorout if position is greater than edge
//    returns colorin if position is less than edge
//    returns mix of the two with smoothstep otherwise

vec3 edgeblend(vec3 colorout, vec3 colorin, float position, float edge)
{
    float dist = distance(eye, vertex);
    float m = dist / 1000;
    if (position + m < edge)
        return colorin;
    if (position - m > edge)
        return colorout;
    m = smoothstep(position + m, position - m, edge);
    return mix(colorin, colorout, m);
}

void main()
{
    vec3 norm = normalize(normal);
    vec3 ray = normalize(light - vertex);

    float diffa = max(dot(ray, norm), 0.4);
    float diffb = max(dot(normalize(vec3(1, 0.5, -0.8)), norm), -0.5);
    diffb = smoothstep(-0.5, 1, diffb);
    float diffc = max(dot(normalize(vec3(-1.5, 0.9, 0.8)), norm), -0.5);
    diffc = smoothstep(-0.5, 1, diffc);

    vec3 view = normalize(vertex - eye);
    vec3 bounce = reflect(view, norm);
    float spec = pow(max(dot(ray, bounce), 0.0), 50);
    vec2 uv = cylinder();

    vec3 color = texture(wrap, uv).rgb;
    // again we have a problem with mipmap seams
    //if (uv.x > 0.95)
      //  color = vec3(0);

    color = edgeblend(color, vec3(0), abs(texcoords.x - 0.5), 0.001);
    color = edgeblend(color, vec3(1), texcoords.x, 0.015);
    color = edgeblend(color, vec3(0.451, 0.486, 0.859), texcoords.x, 0.0025);
    color = color * (diffa * 0.7 + diffb * 0.6 + diffc * 0.4);

    finalColor = vec4(color + spec * 0.7, 1);
}

