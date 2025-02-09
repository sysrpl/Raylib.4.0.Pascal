#version 330

// slate fragment shader

#define meter 3.280
#define width 0.600
#define depth 1.250
#define fade 0.050
#define radius 0.031750386
#define PI 3.1415927

in vec3 vertex;
in vec3 normal;

uniform float time;
uniform vec3 eye;
uniform vec3 light;
uniform vec2 balls[16];
uniform vec3 stick[2];
uniform bool collides;
uniform vec2 collidepoint;
uniform int collideindex;
uniform bool moving;
uniform bool errorcorrect;

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

float segment(vec2 p, vec2 a, vec2 b)
{
    vec2 pa = p - a, ba = b - a;
    float h = clamp( dot(pa, ba) / dot(ba, ba), 0, 1);
    return length(pa - ba * h);
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

    if (errorcorrect)
    {
      vec3 n = normalize(normal);
      vec3 v = normalize(eye - vertex);
      float d = dot(n, v);
      if (d < 0.0001)
        return colorout;
      m = m * (1 + 1 / d);
    }

    if (position + m < edge)
      return colorin;
    if (position - m > edge)
      return colorout;
    m = smoothstep(position + m, position - m, edge);
    return mix(colorin, colorout, m);
}

// floatblend
//    similar to edgeblend but returns a float from 0..1
//    where 0 is ouside and 1 is inside

float floatblend(float position, float edge)
{
    float dist = distance(eye, vertex);
    float m = dist / 1000;

    if (errorcorrect)
    {
      vec3 n = normalize(normal);
      vec3 v = normalize(eye - vertex);
      float d = dot(n, v);
      if (d < 0.0001)
        return 0.0;
      m = m * (1 + 1 / d);
    }

    if (position + m < edge)
      return 1.0;
    if (position - m > edge)
      return 0.0;
    return smoothstep(position - m, position + m, edge);
}

// line returns a solid line of width w

float line(vec2 a, vec2 b, float w)
{
    float d = segment(vertex.xz, a, b);
    if (d > w * 2)
      return 0.0;
    return floatblend(d, w / 2);
}

// dashedline returns line with d spaced dashes animated by t time

float dashedline(vec2 a, vec2 b, float w, float d, float t)
{
    float c = line(a, b, w);
    if (c == 0)
      return 0.0;
    vec2 e = normalize(b - a);
    e = a + e * 20;
    float r = distance(vertex.xz - a, e) + mod(t, 10);
    r = mod(r, d) - d / 2;
    return c * floatblend(r, 0);
}

// circle returns a solid circle shape

float circle(vec2 p, float r)
{
    float d = distance(p, vertex.xz);
    if (d > r * 2)
        return 0.0;
    return floatblend(d, r);
}

// ring returns a hollow circle shape of wall thickness w

float ring(vec2 p, float r, float w)
{
    float d = distance(p, vertex.xz);
    if (d > r * 2 + w)
        return 0.0;
    return floatblend(d, r + w / 2) * (1 - floatblend(d, r - w / 2));
}

// dashedring returns ring with n dashes animated by t time

float dashedring(vec2 p, float r, float w, float n, float t)
{
    float d = distance(p, vertex.xz);
    if (d > r * 2 + w)
        return 0.0;
    float a = floatblend(d, r + w / 2);
    float b = 1 - floatblend(d, r - w / 2);
    float c = a * b;
    if (c == 0)
        return c;
    p = p - vertex.xz;
    d = sin(atan(p.y, p.x) * n + mod(t, PI * 10));
    return c * floatblend(d, 0);
}

// width = 50.0 / 2.0 / 12.0 / meter
// depth = width * 2
// fade = 2 / 12 / meter

void main()
{
    vec3 norm = normalize(normal);
    vec3 ray = normalize(light - vertex);
    float diff = max(dot(ray, norm), 0.2);

    // table color with noise
    vec3 color = vec3(0.5, 0.9, 0.5) * 0.8;
    float n = noise(vertex.xz * 1000);
    n = (n + 15) / 16;
    color = color * n;

    // rail shadows
    float d = abs(vertex.z);
    if (d > width)
    {
      float s = smoothstep(fade + width, width, d);
      color = mix(color * 0.6, color, s);
    }
    d = abs(vertex.x);
    if (d > depth)
    {
      float s = smoothstep(fade + depth, depth, d);
      color = mix(color * 0.6, color, s);
    }

    // black line
    if (vertex.x > 0.58 && vertex.x < 0.69)
        color = mix(color, mix(vec3(0), color, 0.8), line(vec2(0.635, -4), vec2(0.635, 4), 0.005));

    // cue marker spot
    float spot = distance(vertex.xz, vec2(0.635, 0));
    color = edgeblend(color, vec3(1), spot, 0.01);

    // soft shadow under a balls
    float sum = 0;
    for (int i = 0; i < 16; i++)
    {
        d = distance(vertex.xz, balls[i].xy);
        if (d < 0.05)
        {
            d = smoothstep(0, 1, 1 - d / 0.05);
            sum += d;
        }
    }

    if (moving)
    {
        // do not draw paths or cue shadow if moving
        color = mix(color, vec3(0), clamp(sum, 0, 1) * 0.7) * diff;
        finalColor = vec4(color, 1);
        return;
    }

    // soft shadow under the cue stick
    d = segment(vertex.xz, stick[0].xz, stick[1].xz);
    if (d < 0.02)
    {
        d = smoothstep(0.02, -0.02, d);
        float h = segment(vertex.xy, stick[0].xy, stick[1].xy);
        if (h > 0.15)
          d = 0;
        d = d * ((0.15 - h) / 0.15);
        sum += d;
    }

    // apply shadows as sum along with the diffuse factor
    color = mix(color, vec3(0), clamp(sum, 0, 1) * 0.7) * diff;

    vec3 red = vec3(0.7, 0, 0);
    vec3 green = vec3(0, 0.9, 0);
    vec3 blue = vec3(0.0, 0, 0.6);
    // draw a ring around the cue ball
    color = mix(color, green, dashedring(balls[0], 0.04, 0.0065, 10, time * 8));
    vec2 pa = normalize(balls[0] - stick[0].xz);
    vec2 pb = pa * 0.04 + balls[0];
    if (collides)
    {
        pa = collidepoint;
        color = mix(color, red, dashedring(balls[collideindex], 0.04, 0.0065, 10, time * 8));
        color = mix(color, green, circle(collidepoint, 0.01));
    }
    else
        pa = pa * 10 + balls[0];

    // draw a line from the cue ball
    color = mix(color, green, dashedline(pb, pa, 0.0065, 0.025, time * 0.07));
    // draw an depart point from the cue ball
    color = mix(color, green, circle(pb, 0.01));

    finalColor = vec4(color, 1);
}

