#version 330

// cabinet fragment shader

in vec3 vertex;
in vec3 normal;

uniform vec3 eye;
uniform vec3 light;
uniform vec3 stick[2];
uniform bool moving;
uniform bool shadows;
uniform int smoothing;

out vec4 finalColor;

#define sat(x)	clamp(x, 0., 1.)
#define S(a, b, c)	smoothstep(a, b, c)
#define S01(a)	S(0., 1., a)

float sum2(vec2 v)
{
    return dot(v, vec2(1));
}

float h31(vec3 p3)
{
    p3 = fract(p3 * 0.1031);
    p3 += dot(p3, p3.yzx + 333.3456);
    return fract(sum2(p3.xy) * p3.z);
}

float h21(vec2 p)
{
    return h31(p.xyx);
}

float n31(vec3 p)
{
    const vec3 s = vec3(7, 157, 113);
    vec3 ip = floor(p);
    p = fract(p);
    p = p * p * (3.0 - 2.0 * p);
    vec4 h = vec4(0, s.yz, sum2(s.yz)) + dot(ip, s);
    h = mix(fract(sin(h) * 43758.545), fract(sin(h + s.x) * 43758.545), p.x);
    h.xy = mix(h.xz, h.yw, p.y);
    return mix(h.x, h.y, p.z);
}

float fbm(vec3 p, int octaves, float roughness)
{
    float sum = 0.0;
    float amp = 1.0;
    float tot = 0.0;
    roughness = sat(roughness);
    for (int i = 0; i < octaves; i++)
    {
        sum += amp * n31(p);
        tot += amp;
        amp *= roughness;
        p *= 2.0;
    }
    return sum / tot;
}

vec3 randomPos(float seed)
{
    vec4 s = vec4(seed, 0, 1, 2);
    return vec3(h21(s.xy), h21(s.xz), h21(s.xw)) * 1e2 + 1e2;
}

float fbmDistorted(vec3 p)
{
    p += (vec3(n31(p + randomPos(0.0)),
        n31(p + randomPos(1.0)),
        n31(p + randomPos(2.0))) * 2.0 - 1.0) * 1.12;
    return fbm(p, 8, 0.5);
}

float musgraveFbm(vec3 p, float octaves, float dimension, float lacunarity)
{
    float sum = 0.0;
    float amp = 1.0;
    float m = pow(lacunarity, -dimension);
    for (float i = 0.0; i < octaves; i++)
    {
        float n = n31(p) * 2.0 - 1.0;
        sum += n * amp;
        amp *= m;
        p *= lacunarity;
    }
    return sum;
}

vec3 waveFbmX(vec3 p)
{
    float n = p.x * 20.0;
    n += 0.4 * fbm(p * 3.0, 3, 3.0);
    return vec3(sin(n) * 0.5 + 0.5, p.yz);
}

float remap01(float f, float in1, float in2)
{
    return sat((f - in1) / (in2 - in1));
}

vec3 matWood(vec3 p)
{
    float n1 = fbmDistorted(p * vec3(7.8, 1.17, 1.17));
    n1 = mix(n1, 1.0, 0.2);

    float n2 = mix(musgraveFbm(vec3(n1 * 4.6), 8.0, 0.0, 2.5), n1, 0.85);
    float dirt = 1.0 - musgraveFbm(waveFbmX(p * vec3(0.01, 0.15, 0.15)), 15.0, 0.26, 2.4) * 0.4;
    float grain = 1.0 - S(0.2, 1.0, musgraveFbm(p * vec3(500.0, 6.0, 1.0), 2.0, 2.0, 2.5)) * 0.2;
    n2 *= dirt * grain;
    return mix(mix(vec3(0.03, 0.012, 0.003), vec3(0.25, 0.11, 0.04), remap01(n2, 0.19, 0.56)),
        vec3(0.52, 0.32, 0.19), remap01(n2, 0.56, 1.0));
}

vec4 generateWood(vec2 fc)
{
    vec3 p = vec3((fc - 0.5 * vec2(5.0, 3.0)) / 3.0, 8.0);
    return vec4(pow(matWood(p), vec3(0.4545)), 1.0);
}

#define pipSize 0.015
#define pipRange 0.04

//  edgeblend
//    smoothsteps hard edges using a position and edge
//    returns colorout if position is greater than edge
//    returns colorin if position is less than edge
//    returns mix of the two with smoothstep otherwise
//

vec3 edgeblend(vec3 colorout, vec3 colorin, float position, float edge)
{
    if (smoothing == 0)
        return position > edge ? colorout : colorin;

    float dist = distance(eye, vertex);
    float m = dist / 1000;

    if (smoothing == 2)
    {
      vec3 n = normalize(normal);
      vec3 v = normalize(eye - vertex);
      float d = dot(n, v);
      if (d < 0.0001)
        return colorout;
      m = m * (1 + 1 / d / 2);
    }

    if (position + m < edge)
      return colorin;
    if (position - m > edge)
      return colorout;
    m = smoothstep(position + m, position - m, edge);
    return mix(colorin, colorout, m);
}

float ndot(vec2 a, vec2 b)
{
    return a.x * b.x - a.y * b.y;
}

float rhombus(vec2 point, vec2 axis)
{
    point = abs(point);
    float h = clamp(ndot(axis - 2 * point, axis) / dot(axis, axis), -1, 1);
    float d = length(point - 0.5 * axis * vec2(1 - h, 1 + h));
    return d * sign(point.x * axis.y + point.y * axis.x - axis.x * axis.y);
}

const vec2 pips[18] = vec2[](
    vec2(-0.3175, 0.7360),
    vec2(-0.6350, 0.7360),
    vec2(-0.9530, 0.7360),
    vec2(0.3175, 0.7360),
    vec2(0.6350, 0.7360),
    vec2(0.9530, 0.7360),
    vec2(-0.3175, -0.7360),
    vec2(-0.6350, -0.7360),
    vec2(-0.9530, -0.7360),
    vec2(0.3175, -0.7360),
    vec2(0.6350, -0.7360),
    vec2(0.9530, -0.7360),
    vec2(1.3716, 0.3175),
    vec2(1.3716, 0),
    vec2(1.3716, -0.3175),
    vec2(-1.3716, 0.3175),
    vec2(-1.3716, 0),
    vec2(-1.3716, -0.3175)
);

vec3 findPip(vec3 color)
{
    vec2 r = vec2(pipSize / 2, pipSize);
    for (int i = 0; i < 18; i++)
    {
      float d = distance(vertex.xz, pips[i]);
      if (d < pipRange)
      {
          if (abs(pips[i].x) > 1)
              d = rhombus(vertex.xz - pips[i], r.yx);
          else
              d = rhombus(vertex.xz - pips[i], r);
          return edgeblend(color, vec3(1), d, 0);
      }
    }
    return color;
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
    vec3 norm = normalize(normal);
    vec3 ray = normalize(light - vertex);
    float diff = max(dot(ray, norm), 0.3);
    vec3 color = vec3(0.6, 0.3, 0.0);

    vec3 view = normalize(vertex - eye);
    vec3 bounce = reflect(view, norm);
    float spec = pow(max(dot(ray, bounce), 0.0), 50);
    float specmix = 0.5;
    float dark = 0.6;
    if (abs(vertex.x) > 1.3)
        color = generateWood(vertex.xz).rgb * dark;
    else
        color = generateWood(vertex.zx).rgb * dark;

    if (vertex.y > 0)
    {

        color = findPip(color);
        if (shadows)
            if (!moving)
                color = stickShadow(color, 0);
    }

    finalColor = vec4(color * diff + spec * specmix, 1);
}

