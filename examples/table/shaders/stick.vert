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
out vec3 stick;
out vec3 texcoords;

void main()
{
    vertex = (matModel * vec4(vertexPosition, 1.0)).xyz;
    normal = normalize(mat3(matModel) * vertexNormal);
    stick = vertexPosition;
    texcoords = vertexPosition;
    texcoords.x = texcoords.x / 1.51;
    gl_Position = mvp * vec4(vertexPosition, 1.0);
}
