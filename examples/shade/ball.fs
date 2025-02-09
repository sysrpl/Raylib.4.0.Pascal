#version 120

varying vec2 fragTexCoord;
varying vec4 fragColor;

#define PI 3.1415926538

// a texture with the numbers 1..16
uniform sampler2D texture0;
// the resolution of the window
uniform int size;
// light source controlled by the mouse
uniform vec2 lightpos;
// animated angle used to rotate the ball
uniform float angle;
// ball number 0..16
uniform int ball;
// optional specular highlights
uniform int highlight;

// the default ball color
const vec3 white = vec3(1.0);
// area reserved for ball number texture
const float square = 0.28;
// cleanup factor for texture artifacts
const float edge = 0.01;

// rotate on the X axis
mat4 rotationX(float angle ) {
	return mat4(
    1.0, 0.0, 0.0, 0.0,
    0.0, cos(angle), -sin(angle), 0.0,
    0.0, sin(angle), cos(angle), 0.0,
    0.0, 0.0, 0.0, 1);
}

// rotate on the Y axis
mat4 rotationY(float angle) {
  return mat4(
    cos(angle), 0.0, sin(angle), 0.0,
    0.0, 1.0, 0.0, 0.0,
    -sin(angle), 0.0, cos(angle), 0.0,
    0.0, 0.0, 0.0, 1);
}

// rotate on the Z axis
mat4 rotationZ(float angle) {
	return mat4(
    cos(angle), -sin(angle), 0.0, 0.0,
    sin(angle), cos(angle), 0.0, 0.0,
    0.0, 0.0, 1, 0.0,
    0.0, 0.0, 0.0, 1);
}

// ball color data
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

// lookup the color and texture pattern for a point on the ball
vec3 colorLookup(vec3 point, int number) {
  // the cue ball is white
  if (number == 0)
    return white;
  // all other balls hae a zero based index
  number--;
  vec3 color;
  // if the area where a number should be texure mapped
  if (abs(point.x) < square && abs(point.y) < square) {
    // convert the point to a texture coordinate
    vec2 tex = (point.xy + vec2(square)) / (square * 2.0);
    // flip it on the y
    tex.y = 1. - tex.y;
    // if we're on the backside flip the x
    if (point.z < 0.0)
      tex.x = 1. - tex.x;
    // our number texture uses a 4x4 grid with 16 numbers
    tex = tex / 4.0;
    tex.x = tex.x + mod(number, 4) * 0.25;
    tex.y = tex.y + number / 4 * 0.25;
    color = texture2D(texture0, tex).rgb;
    // reset the texure coord to 0, 0
    tex.x = tex.x - mod(number, 4) * 0.25;
    tex.y = tex.y - number / 4 * 0.25;
    // and cut off texture artifacts from the edges
    if (tex.x < edge) return white;
    if (tex.x + edge > 0.25) return white;
    if (tex.y < edge) return white;
    if (tex.y + edge > 0.25) return white;
    return color;
  }
  float d;
  // get ball color from our color data
  color = colorData[int(mod(number, 8))];
  // if we are in a striped ball
  if (number > 7)
    if (abs(point.y) > 0.55) {
      // generate a smooth stripe
      d = abs(point.y);
      d = smoothstep(0.55, 0.56, d);
      return mix(color, white, d);
    }
  // generate the circle for the number area
  d = distance(point.xy, vec2(0));
  // antialias the circle
  if (d < 0.4) return white;
  d = smoothstep(0.4, 0.41, d);
  return mix(white, color, d);
}

void main() {
    // convert resolution to coordinates in the -1..1 range
    vec2 coord = 2.0 * gl_FragCoord.xy / size - 1.0;
    // find the distance from the origin
    float d = distance(coord, vec2(0.0));
    // use the distance to create a circle mask
    float a = d > 0.99 ? 1.0 - smoothstep(0.99, 1.0, d) : 1.0;
    // build our normal using xy and a calculated z
    vec3 n = vec3(coord, sqrt(1.0 - clamp(dot(coord, coord), 0.0, 1.0)));
    // create a primary light source
    vec3 light = vec3(lightpos.x, -lightpos.y * 3.0, 200.0);
    // normalize the light as a direction
    light = normalize(light);
    // optional specularity
    float spec = 0.0;
    if (highlight > 0) {
      // generate the specular shine
      vec3 r = reflect(-light, n);
      vec3 spot = n * 10.;
      spot.z = 400.;
      vec3 v = normalize(spot);
      spec = max(dot(r, v), 0.0);
      spec = pow(spec, 10.0);
      spec = smoothstep(0.5, 1.0, spec);
      spec = pow(spec, 30.0) * 0.9;
    }
    // map the normal to a vertex
    vec4 vert = vec4(n, 0.0);
    // rotate the vertex to spin the ball
    vert = rotationX(angle) * vert;
    vert = rotationZ(angle * PI / 3.0) * vert;
    vert = rotationY(angle / 3.0) * vert;
    // lookup the color of the vertex for a given ball
    vec3 diffuse = colorLookup(vert.xyz, ball);
    // calculate the light as brightness intensity with 0.1 ambient lighting
    float brightness = clamp(dot(light, n), 0.1, 1.0);
    // create a secondard back light
    vec3 backlight = normalize(vec3(50.0, -90.0, -80.0));
    // calculate the backlight rim intensity
    float rim = dot(backlight, n);
    rim = pow(clamp(rim, 0.0, 1.0), 3.0);
    // calculate the final diffuse color
    diffuse = diffuse * (brightness + rim);
    // output the color while masking the circle
    gl_FragColor = vec4(diffuse + spec, a);
}

