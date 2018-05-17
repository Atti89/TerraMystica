#version 140

in vec2 textureCoords;

uniform sampler2D guiTexture;

out vec4 out_Color;

void main(void) {

	out_Color = texture(guiTexture, textureCoords);
	
}