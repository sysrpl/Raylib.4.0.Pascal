#version 330

// ball fragment shader

// the radius of a ball in meters
#define radius 0.028575

// half the size of the slate and the height of the rails in meters
#define slatex 1.270
#define slatez 0.635
#define railheight 0.044

// half the size of the cabinet and the width of the cloth on the rails
#define cabinetx 1.524
#define cabinetz 0.889
#define railwidth 0.0508

// where the pockets open along the rails from the center of the table
#define sidepocket 0.067
#define cornerx 1.189
#define cornerz 0.554

// the radius of both ends of the cue stick
#define sticktip 0.006
#define stickbutt 0.015

// the strength of reflections when looking straight at a ball, they get
// stronger toward the rim
#define reflectstrength 0.04

in vec3 world;
flat in int index;
flat in vec3 center;
flat in mat3 turn;
flat in float fade;

uniform mat4 mvp;
uniform vec3 eye;
uniform vec3 light;
uniform vec3 stick[2];
// where each ball is, and the axes of each ball in the world
uniform vec3 centers[16];
uniform vec3 turnx[16];
uniform vec3 turny[16];
uniform vec3 turnz[16];
uniform sampler2D probe;
uniform sampler2D numbers;
uniform bool shadows;
uniform bool reflections;
uniform int smoothing;

out vec4 finalColor;

// these are set by main from where the view ray hits the ball
//   vertex is the point on the ball in the world
//   normal is the normal of that point
//   sphere is the normal turned into the space of the ball
//   spherex and spherey are the change in sphere from one pixel to the next

vec3 vertex;
vec3 normal;
vec3 sphere;
vec3 spherex;
vec3 spherey;

// coverage returns how much of a pixel is covered by a shape
//    d is the distance from the center, r is the distance to the edge
//    w is the pixel size

float coverage(float d, float r, float w)
{
    if (smoothing == 0)
        return d > r ? 0.0 : 1.0;
    return clamp((min(d + w * 0.5, r) - max(d - w * 0.5, -r)) / w, 0.0, 1.0);
}

// cap returns how much of a pixel is covered by the round caps at both ends of
// an axis
//    c, cx, cy are the sphere, spherex, and spherey components of the axis
//    edge is the size of the caps in radians

float cap(float c, float cx, float cy, float edge)
{
    float angle = acos(min(abs(c), 1.0));
    // the pixel size measured as an angle from the axis
    float w = length(vec2(cx, cy)) / max(sqrt(max(1.0 - c * c, 0.0)), 0.001);
    w = max(w, min(length(spherex), length(spherey)));
    return coverage(angle, edge, max(w, 0.000001));
}

float capx(float edge)
{
    return cap(sphere.x, spherex.x, spherey.x, edge);
}

float capy(float edge)
{
    return cap(sphere.y, spherex.y, spherey.y, edge);
}

float capz(float edge)
{
    return cap(sphere.z, spherex.z, spherey.z, edge);
}

// digits returns how much of a pixel is covered by the ink of the number

float digits()
{
    // half the size of the number as a part of the radius
    const float edge = 0.007 / radius;
    // the border of each number is left out
    const float border = edge * 0.9;

    float flip = sphere.z < 0.0 ? -1.0 : 1.0;
    vec2 uv = vec2(sphere.x * flip, -sphere.y) / (edge * 2.0) + 0.5;
    uv = clamp(uv, 0.0, 1.0);
    // our number texture uses a 4x4 grid with 16 numbers
    int i = max(index - 1, 0);
    uv = (uv + vec2(i % 4, i / 4)) / 4.0;

    // the change in texture position from one pixel to the next
    vec2 gx = vec2(spherex.x * flip, -spherex.y) / (edge * 8.0);
    vec2 gy = vec2(spherey.x * flip, -spherey.y) / (edge * 8.0);
    float ink = 1.0 - textureGrad(numbers, uv, gx * 0.7, gy * 0.7).r;

    if (smoothing > 0)
    {
        // sharpen the edges of the number when it is magnified
        float w = length(vec2(dFdx(ink), dFdy(ink)));
        float sharp = clamp((ink - 0.5) / max(w, 0.0001) + 0.5, 0.0, 1.0);
        float texels = max(length(gx), length(gy)) * float(textureSize(numbers, 0).x);
        ink = mix(sharp, ink, smoothstep(0.5, 1.0, texels));
    }

    vec2 w = max(vec2(length(vec2(spherex.x, spherey.x)),
        length(vec2(spherex.y, spherey.y))), vec2(0.000001));
    ink = ink * coverage(abs(sphere.x), border, w.x) * coverage(abs(sphere.y), border, w.y);
    return index == 0 ? 0.0 : ink;
}

const vec3 colors[8] = vec3[](
    vec3(1.000, 0.843, 0.000),
    vec3(1.000, 0.000, 0.000),
    vec3(0.000, 0.000, 1.000),
    vec3(0.502, 0.000, 0.502),
    vec3(0.900, 0.400, 0.000),
    vec3(0.000, 0.502, 0.000),
    vec3(0.549, 0.000, 0.102),
    vec3(0.100, 0.100, 0.100)
);

vec3 cueball()
{
    const vec3 red = vec3(0.7, 0.0, 0.0);
    vec3 color = vec3(1.0);
    color = mix(color, red, capz(0.15));
    color = mix(color, red, capy(0.15));
    color = mix(color, red, capx(0.15));
    return color;
}

vec3 ball()
{
    if (index == 0)
      return cueball();
    vec3 color = colors[(index - 1) % 8];
    // stripe
    if (index > 8)
        color = mix(color, vec3(1.0), capy(1.0));
    // dot
    return mix(color, vec3(1.0), capz(0.39));
}

vec2 sphereMap(vec3 ray)
{
    vec2 uv;
    uv.x = 0.5 + (atan(ray.z, ray.x) / (2.0 * 3.14159265359));
    uv.y = 0.5 - (asin(clamp(ray.y, -1.0, 1.0)) / 3.14159265359);
    vec2 center = uv - vec2(0.5);
    float dist = length(center);
    if (dist > 0.49)
      center = normalize(center) * 0.49;
    uv = center + vec2(0.5);
    return uv;
}

// lighting returns 3 lights blended together at point p with normal n

float lighting(vec3 p, vec3 n)
{
    float diffa = max(dot(normalize(light - p), n), 0.4);
    float diffb = max(dot(normalize(vec3(1, 0.5, -0.8)), n), -0.5);
    diffb = smoothstep(-0.5, 1, diffb);
    float diffc = max(dot(normalize(vec3(-1.5, 0.9, 0.8)), n), -0.5);
    diffc = smoothstep(-0.5, 1, diffc);
    return diffa * 0.7 + diffb * 0.6 + diffc * 0.4;
}

// occlusion is fake ambient occlusion of a ball with the ground

float occlusion(vec3 n)
{
    float shadow = 1 - max(-n.y, 0.0);
    shadow = smoothstep(-0.2, 1, shadow);
    return mix(0.3, 1, shadow);
}

float segment(in vec2 p, in vec2 a, in vec2 b)
{
    vec2 pa = p - a, ba = b - a;
    float h = clamp( dot(pa, ba) / dot(ba, ba), 0, 1);
    return length(pa - ba * h);
}

// stickShadow returns the soft shadow of the cue stick at point p

float stickShadow(vec3 p)
{
    float d = segment(p.xz, stick[0].xz, stick[1].xz);
    if (d >= 0.02)
        return 0.0;
    d = smoothstep(0.02, -0.02, d);
    float h = segment(p.xy, stick[0].xy, stick[1].xy);
    if (h > 0.15)
        return 0.0;
    return d * ((0.15 - h) / 0.15);
}

// darken applies a sum of soft shadows to a color

vec3 darken(vec3 color, float sum)
{
    return mix(color, vec3(0), clamp(sum, 0, 1) * 0.7);
}

// the cloth color, where the noise of the slate shader is averaged

const vec3 cloth = vec3(0.5, 0.9, 0.5) * 0.8 * 0.955;

// slateColor returns the color of the slate at point p using the same shadows
// as the slate shader

vec3 slateColor(vec3 p)
{
    vec3 color = cloth;
    float sum = 0.0;
    if (shadows)
    {
        // rail shadows
        color = color * mix(1.0, 0.6, smoothstep(0.600, 0.650, abs(p.z)));
        color = color * mix(1.0, 0.6, smoothstep(1.250, 1.300, abs(p.x)));
        // soft shadows under the balls
        for (int i = 0; i < 16; i++)
        {
            float d = distance(p.xz, centers[i].xz);
            if (d < 0.05)
                sum += smoothstep(0.0, 1.0, 1.0 - d / 0.05);
        }
        sum += stickShadow(p);
    }
    float diff = max(normalize(light - p).y, 0.2);
    return darken(color, sum) * diff;
}

// otherBall returns the color of ball i at point p with normal n, and w is the
// pixel size as an angle

vec3 otherBall(int i, vec3 p, vec3 n, float w)
{
    vec3 s = vec3(dot(n, turnx[i]), dot(n, turny[i]), dot(n, turnz[i]));
    s = acos(clamp(abs(normalize(s)), 0.0, 1.0));
    vec3 color = vec3(1.0);
    if (i == 0)
    {
        const vec3 red = vec3(0.7, 0.0, 0.0);
        color = mix(color, red, coverage(s.x, 0.15, w));
        color = mix(color, red, coverage(s.y, 0.15, w));
        color = mix(color, red, coverage(s.z, 0.15, w));
    }
    else
    {
        color = colors[(i - 1) % 8];
        // stripe
        if (i > 8)
            color = mix(color, vec3(1.0), coverage(s.y, 1.0, w));
        // dot
        color = mix(color, vec3(1.0), coverage(s.z, 0.39, w));
    }
    color = color * lighting(p, n) * occlusion(n);
    if (shadows)
        color = darken(color, stickShadow(p));
    return color;
}

// over returns 0 to 1 as position passes edge and is blended over a pixel of size w

float over(float position, float edge, float w)
{
    return clamp((position - edge) / w + 0.5, 0.0, 1.0);
}

// stickColor returns the color of the cue stick at point p with normal n
//    x is the position along the stick from 0 to 1, and w is the pixel size

vec3 stickColor(float x, vec3 p, vec3 n, float w)
{
    // the wrap picture of the stick is averaged
    vec3 color = mix(vec3(0.90, 0.76, 0.62), vec3(0.0), smoothstep(0.68, 0.978, x));
    color = mix(color, vec3(0.0), coverage(abs(x - 0.5), 0.001, w));
    color = mix(vec3(1.0), color, over(x, 0.015, w));
    color = mix(vec3(0.451, 0.486, 0.859), color, over(x, 0.0025, w));
    return color * lighting(p, n);
}

// reflection returns what is seen along the ray bounced off of the ball

vec3 reflection(vec3 bounce)
{
    // the sky is read before any branches so its derivatives are valid
    vec3 color = texture(probe, sphereMap(bounce)).rgb * 1.3;

    // the change in the bounced ray from one pixel to the next, which gives the
    // size of one pixel at any distance along the ray
    vec3 px = dFdx(vertex);
    vec3 py = dFdy(vertex);
    vec3 bx = dFdx(bounce);
    vec3 by = dFdy(bounce);

    // the distance to the rails around the slate
    vec2 side = vec2(bounce.x < 0.0 ? -slatex : slatex, bounce.z < 0.0 ? -slatez : slatez);
    vec2 away = max(abs(bounce.xz), vec2(0.00001));
    vec2 reach = max((side - vertex.xz) * sign(side), vec2(0.0)) / away;
    float wall = min(reach.x, reach.y);
    vec3 p = vertex + bounce * wall;
    float w = max(max(length(px + bx * wall), length(py + by * wall)), 0.000001);
    if (smoothing == 0)
        w = 0.000001;

    // the tops of the rails, cloth and then wood out to the edge of the cabinet
    if (bounce.y < -0.00001 && vertex.y > railheight)
    {
        float t = (vertex.y - railheight) / -bounce.y;
        vec3 q = vertex + bounce * t;
        float s = max(max(length(px + bx * t), length(py + by * t)), 0.000001);
        if (smoothing == 0)
            s = 0.000001;
        float inner = max(abs(q.x) - slatex, abs(q.z) - slatez);
        float outer = max(abs(q.x) - cabinetx, abs(q.z) - cabinetz);
        vec3 top = mix(cloth, vec3(0.27, 0.18, 0.12), over(inner, railwidth, s));
        top = top * max(normalize(light - q).y, 0.4);
        color = mix(top, color, over(outer, 0.0, s));
    }

    // the faces of the rails are walls around the slate
    bool ends = reach.x < reach.y;
    vec3 n = ends ? vec3(-sign(side.x), 0.0, 0.0) : vec3(0.0, 0.0, -sign(side.y));
    vec3 rail = cloth * max(dot(normalize(light - p), n), 0.4);
    // the bottoms of the rails are darker, and the pockets are openings in them
    if (shadows)
        rail = rail * mix(0.6, 1.0, smoothstep(0.0, 0.03, p.y));
    float pocket = over(abs(p.z), cornerz, w);
    if (!ends)
        pocket = max(over(abs(p.x), cornerx, w), 1.0 - over(abs(p.x), sidepocket, w));
    rail = mix(rail, vec3(0.02), pocket);
    color = mix(rail, color, over(p.y, railheight, w));
    // anything past the face of a rail is hidden
    float hidden = p.y < railheight ? wall : 1000.0;

    // the slate
    float ground = 1000.0;
    if (bounce.y < -0.00001 && vertex.y > 0.0)
    {
        ground = vertex.y / -bounce.y;
        vec3 q = vertex + bounce * min(ground, wall);
        color = mix(slateColor(q), color, over(p.y, 0.0, w));
    }

    // the cue stick, using the nearest points between it and the ray
    vec3 pole = vec3(0.0);
    float poleCover = 0.0;
    float poleDist = 1000.0;
    {
        vec3 e = stick[1] - stick[0];
        vec3 r = vertex - stick[0];
        float ee = max(dot(e, e), 0.000001);
        float b = dot(bounce, e);
        float c = dot(bounce, r);
        float f = dot(e, r);
        float s = clamp((f - b * c) / max(ee - b * b, 0.000001), 0.0, 1.0);
        float t = b * s - c;
        if (t > 0.0 && t < min(ground, hidden))
        {
            vec3 o = vertex + bounce * t - (stick[0] + e * s);
            float d = length(o);
            float size = mix(sticktip, stickbutt, s);
            float z = max(max(length(px + bx * t), length(py + by * t)), 0.000001);
            poleCover = coverage(d, size, z);
            if (poleCover > 0.0)
            {
                // the normal rises toward the ball across the width of the stick
                vec3 across = bounce - e * (b / ee);
                across = across / max(length(across), 0.000001);
                if (d > size)
                    o *= size / d;
                o = normalize(o - across * sqrt(max(size * size - dot(o, o), 0.0)));
                pole = stickColor(s, stick[0] + e * s + o * size, o, z / sqrt(ee));
                poleDist = t - size;
            }
        }
    }

    // the nearest of the other balls
    int hit = -1;
    float best = ground;
    float cover = 0.0;
    vec3 nearest = vec3(0.0);
    float size = 0.0;
    for (int i = 0; i < 16; i++)
    {
        if (i == index)
            continue;
        vec3 o = vertex - centers[i];
        float along = -dot(o, bounce);
        if (along <= 0.0)
            continue;
        o += bounce * along;
        float d = length(o);
        w = max(max(length(px + bx * along), length(py + by * along)), 0.000001);
        float c = clamp((radius - d) / w + 0.5, 0.0, 1.0);
        if (smoothing == 0)
            c = d > radius ? 0.0 : 1.0;
        if (c <= 0.0)
            continue;
        if (d > radius)
            o *= radius / d;
        float h = sqrt(max(radius * radius - dot(o, o), 0.0));
        if (along - h < best)
        {
            best = along - h;
            hit = i;
            cover = c;
            nearest = normalize(o - bounce * h);
            size = w / radius;
        }
    }
    // the stick is behind the nearest ball
    if (hit > -1 && poleDist > best)
        color = mix(color, pole, poleCover);
    if (hit > -1)
    {
        p = centers[hit] + nearest * radius;
        // the pixel is larger on parts of the ball facing away
        size = size / max(-dot(nearest, bounce), 0.1);
        color = mix(color, otherBall(hit, p, nearest, max(size, 0.000001)), cover);
    }
    // the stick is in front of everything else
    if (hit < 0 || poleDist <= best)
        color = mix(color, pole, poleCover);
    return color;
}

// shade lights the color of the ball and adds its reflection

vec3 shade(vec3 color, vec3 view)
{
    color = color * lighting(vertex, normal) * occlusion(normal);
    if (shadows)
        color = darken(color, stickShadow(vertex));

    // reflections are stronger at shallow angles
    vec3 bounce = reflect(view, normal);
    float edge = clamp(1.0 + dot(normal, view), 0.0, 1.0);
    if (reflections)
    {
        edge = reflectstrength + (1.0 - reflectstrength) * pow(edge, 5.0);
        color = mix(color, reflection(bounce), edge);
    }
    else
    {
        // only the sky is reflected
        vec3 sky = texture(probe, sphereMap(bounce)).rgb * 1.3;
        color = mix(color, sky, edge * edge * 0.3);
    }

    // specular light
    float spec = pow(max(dot(normalize(light - vertex), bounce), 0.0), 40);
    return color + spec * 0.7;
}

void main()
{
    // o is from the center of the ball to the nearest point on the view ray
    vec3 ray = normalize(world - eye);
    vec3 o = eye - center;
    float along = -dot(o, ray);
    o += ray * along;
    float d = length(o);

    // the rim is blended by how much of the pixel is covered by the ball
    float pixel = max(length(vec2(dFdx(d), dFdy(d))), 0.0000001);
    float alpha = clamp((radius - d) / pixel + 0.5, 0.0, 1.0);
    if (smoothing == 0)
        alpha = d > radius ? 0.0 : 1.0;

    // a pixel of the rim outside the radius is shaded as the very edge
    if (d > radius)
        o *= radius / d;
    float h = sqrt(max(radius * radius - dot(o, o), 0.0));
    // do not draw the ball if it is behind the camera
    if (along - h < 0.0)
        alpha = 0.0;

    normal = normalize(o - ray * h);
    vertex = center + normal * radius;
    sphere = normalize(normal * turn);
    spherex = dFdx(sphere);
    spherey = dFdy(sphere);

    vec3 color = ball();
    color = mix(color, vec3(0.0), digits());
    color = shade(color, ray);

    // the depth is of the point on the ball and not the quad
    vec4 clip = mvp * vec4(vertex, 1.0);
    gl_FragDepth = clip.z / clip.w * 0.5 + 0.5;

    // discard is last because it can disturb the derivatives above
    if (alpha <= 0.0)
        discard;
    // balls falling into a pocket fade to black
    finalColor = vec4(color * (1.0 - fade), alpha);
}
