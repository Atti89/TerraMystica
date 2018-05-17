#version 150

in vec2 textureCoords;

out vec4 out_Color;

uniform sampler2D colourTexture;
uniform sampler2D highlightTexture;

void main(void){

	vec4 sceneColor = texture(colourTexture, textureCoords);
	vec4 highLightColor = texture(highlightTexture, textureCoords);
	
	out_Color = sceneColor + highLightColor;

}