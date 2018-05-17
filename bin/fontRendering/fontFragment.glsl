#version 330

in vec2 pass_textureCoords;

out vec4 out_Color;

uniform vec3 colour;
uniform sampler2D fontAtlas;

void main(void){

	out_Color = vec4(colour, texture(fontAtlas, pass_textureCoords).a);

}