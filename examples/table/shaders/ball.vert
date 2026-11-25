#version 330

// ball vertex shader

// each ball is one quad facing the camera
//   vertexPosition is a corner of the quad in the world
//   vertexTexCoord.x is the index of the ball
//   vertexTexCoord.y is how much the ball fades to black from 0 to 1

in vec3 vertexPosition;
in vec2 vertexTexCoord;

uniform mat4 mvp;

// where each ball is, and the axes of each ball in the world

uniform vec3 centers[16];
uniform vec3 turnx[16];
uniform vec3 turny[16];
uniform vec3 turnz[16];

out vec3 world;
flat out int index;
flat out vec3 center;
flat out mat3 turn;
flat out float fade;

void main()
{
    world = vertexPosition;
    index = int(vertexTexCoord.x + 0.5);
    fade = clamp(vertexTexCoord.y, 0.0, 1.0);
    center = centers[index];
    turn = mat3(turnx[index], turny[index], turnz[index]);
    gl_Position = mvp * vec4(vertexPosition, 1.0);
}
