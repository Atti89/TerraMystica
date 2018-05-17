#version 150

in vec3 in_position;
in vec2 textureCoords;

uniform mat4 mvpMatrix;

out vec2 pass_textureCoords;

void main(void) {

	gl_Position = mvpMatrix * vec4(in_position, 1.0);
	pass_textureCoords = textureCoords;
	
}