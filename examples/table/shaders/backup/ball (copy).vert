#version 330

in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec3 vertexNormal;
in vec4 vertexColor;

uniform mat4 matModel;
uniform mat4 mvp;

out vec3 vertex;
out vec3 normal;
out vec3 up;
out vec3 front;
out vec3 center;
out vec2 texcoord;
out vec3 sphere;

void main()
{
    sphere = vertexPosition;
    vertex = (matModel * vec4(vertexPosition, 1.0)).xyz;
    normal = (matModel * vec4(vertexNormal, 1.0)).xyz;
    up = (matModel * vec4(vec3(0, 1, 0), 1.0)).xyz;
    front = (matModel * vec4(vec3(0, 0, -1), 1.0)).xyz;
    center = (matModel * vec4(vec3(0), 1.0)).xyz;
    texcoord = vertexPosition.xy;

    gl_Position = mvp * vec4(vertexPosition, 1.0);
}
