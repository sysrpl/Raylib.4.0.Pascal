#version 330

// rails fragment shader

in vec3 vertex;
in vec3 normal;

uniform vec3 eye;
uniform vec3 light;
uniform vec3 stick[2];
uniform bool moving;

out vec4 finalColor;

float rand(vec2 n)
{
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p)
{
    vec2 ip = floor(p);
    vec2 u = fract(p);
    u = u * u * (3.0 - 2.0 * u);
    float res = mix(
	      mix(rand(ip),rand(ip + vec2(1.0, 0.0)), u.x),
	      mix(rand(ip + vec2(0.0, 1.0)), rand(ip + vec2(1.0, 1.0)), u.x), u.y);
    return res*res;
}

float segment(in vec2 p, in vec2 a, in vec2 b)
{
    vec2 pa = p - a, ba = b - a;
    float h = clamp( dot(pa, ba) / dot(ba, ba), 0, 1);
    return length(pa - ba * h);
}

vec3 stickShadow(vec3 color, float sum)
{
    float d = segment(vertex.xz, stick[0].xz, stick[1].xz);
    if (d < 0.02)
    {
        d = smoothstep(0.02, -0.02, d);
        float h = segment(vertex.xy, stick[0].xy, stick[1].xy);
        if (h > 0.15)
          d = 0;
        d = d * ((0.15 - h) / 0.15);
        sum += d;
    }
    return mix(color, vec3(0), clamp(sum, 0, 1) * 0.7);
}

void main()
{
    if (vertex.y < 0)
    {
      finalColor = vec4(0, 0, 0, 1);
      return;
    }
    vec3 norm = normalize(normal);
    vec3 ray = normalize(light - vertex);
    float diff = max(dot(ray, norm), 0.4);


    vec3 color = vec3(0.5, 0.9, 0.5) * 0.8;
    float n = noise(vertex.xz * 1000);
    n = (n + 15) / 16;
    color = color * n;

    //    color = stickShadow(color, 0);

    finalColor = vec4(color * diff, 1);
}

