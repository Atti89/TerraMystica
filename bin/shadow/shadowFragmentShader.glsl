#version 330

in vec2 pass_textureCoords;

out vec4 out_colour;

uniform sampler2D textureSampler;

void main(void) {

	vec4 textureColour = texture(textureSampler, pass_textureCoords);
	if (textureColour.a < 0.1f) {
		discard;
	} else {
		out_colour = vec4(1.0);
	}
	
}