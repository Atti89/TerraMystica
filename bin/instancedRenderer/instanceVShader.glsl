#version 140

in vec3 position;
in vec2 textureCoords;
in vec3 normal;
in mat4 modelMatrix;

uniform mat4 projectionMatrix;
uniform mat4 viewMatrix;
uniform vec3 lightPosition[4];
uniform vec4 clipPlane;
uniform mat4 toShadowMapSpace;

out vec2 pass_textureCoords;
out vec3 surfaceNormal;
out vec3 toLightVector[4];
out vec3 toCameraVector;
out float visibility;
out vec4 shadowCoords;

const float density = 0.00;
const float gradient = 0;

void main(void) {

	vec4 worldPosition = modelMatrix * vec4(position, 1.0);

	vec4 relativePositionToCamera = viewMatrix * worldPosition;
	
	for (int i=0; i<4; i++) {
		toLightVector[i] = lightPosition[i] - worldPosition.xyz;
	}
	surfaceNormal = (modelMatrix * vec4(normal, 0.0)).xyz;
	toCameraVector = (inverse(viewMatrix) * vec4(0.0, 0.0, 0.0, 1.0)).xyz - worldPosition.xyz;

	gl_Position =  projectionMatrix * relativePositionToCamera;
	pass_textureCoords = textureCoords;
	
	float distance = length(relativePositionToCamera.xyz);
	visibility = exp(-pow((distance*density),gradient));
	visibility = clamp(visibility, 0.0, 1.0);	
}