#version 410

uniform mat4 MVP;
in vec3 vCol;
in vec3 vPos;
out vec3 color;

void main() {
    gl_Position = MVP * vec4(vPos, 0.0, 1.0);
    color = vCol;
}
