#version 120

uniform int size;
uniform int ball;

vec3 colorData[8] = vec3[](
  vec3(1.000, 0.843, 0.000),
  vec3(0.000, 0.000, 1.000),
  vec3(1.000, 0.000, 0.000),
  vec3(0.502, 0.000, 0.502),
  vec3(1.000, 0.647, 0.000),
  vec3(0.000, 0.502, 0.000),
  vec3(0.549, 0.000, 0.102),
  vec3(0.100, 0.100, 0.100)
);

void main() {
  vec2 coord = 2.0 * (gl_FragCoord.xy / size - 0.5);
  float a = distance(coord, vec2(0.0));
  a = a > 0.99 ? 1.0 - smoothstep(0.99, 1.0, a) : 1.0;
  vec3 color = vec3(1.0);
  if (ball > 0)
    color = colorData[ball - 1];
  gl_FragColor = vec4(color, a);
}
