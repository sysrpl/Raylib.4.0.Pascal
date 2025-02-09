#version 330

// stick vertex shader

in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec3 vertexNormal;
in vec4 vertexColor;

uniform mat4 matModel;
uniform mat4 mvp;

out vec3 vertex;
out vec3 normal;

void main()
{
    vertex = (matModel * vec4(vertexPosition, 1.0)).xyz;
    normal = normalize(mat3(matModel) * vertexNormal);
    gl_Position = mvp * vec4(vertexPosition, 1.0);
}
