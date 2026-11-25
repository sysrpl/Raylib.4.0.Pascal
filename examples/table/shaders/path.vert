#version 330

// path vertex shader

// each line or circle is one rectangle, and its units are the radius of the circle
// or half the width of the line
//   vertexPosition.xz is the position on the table
//   vertexPosition.y holds half the length of the line, 0 for a solid circle, or
//     for a hollow circle the wall thickness as a negative number
//   vertexTexCoord is the position from the center of the shape

in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec4 vertexColor;

uniform mat4 mvp;

out vec2 coord;
out float extent;
out vec4 color;

// the height of paths above the slate in meters

#define height 0.001

void main()
{
    coord = vertexTexCoord;
    extent = vertexPosition.y;
    color = vertexColor;
    gl_Position = mvp * vec4(vertexPosition.x, height, vertexPosition.z, 1.0);
}
