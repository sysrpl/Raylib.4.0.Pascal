#version 330

// path fragment shader

in vec2 coord;
in float extent;
in vec4 color;

out vec4 finalColor;

void main()
{
    // distance from the center of the line or circle, where 1 is the edge
    vec2 p = vec2(sign(coord.x) * max(abs(coord.x) - max(extent, 0.0), 0.0), coord.y);
    float d = length(p);
    // derivatives give the size of one pixel measured across the edge, using coord
    // because it has no crease at the center of the line
    vec2 n = d > 0.00001 ? p / d : vec2(0.0, 1.0);
    float w = length(vec2(dot(n, dFdx(coord)), dot(n, dFdy(coord))));
    w = max(w, 0.00001);
    float r = 1.0;
    if (extent < 0.0)
    {
        // hollow circles use the distance from the center of the wall
        r = -extent * 0.5;
        d = abs(d - 1.0 + r);
    }
    // never let the line be thinner than one pixel
    r = max(r, w * 0.5);
    // alpha is how much of the pixel is covered by the line
    float a = (min(d + w * 0.5, r) - max(d - w * 0.5, -r)) / w;
    if (a <= 0.0)
        discard;
    finalColor = vec4(color.rgb, color.a * min(a, 1.0));
}
