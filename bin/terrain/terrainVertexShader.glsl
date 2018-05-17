#version 400 core


uniform mat4 transformationMatrix;
uniform mat4 projectionMatrix;
uniform mat4 viewMatrix;
uniform vec3 lightPosition[4];
uniform vec4 clipPlane;
uniform mat4 toShadowMapSpace;


in vec3 position;
in vec2 textureCoords;
in vec3 normal;


out vec2 pass_textureCoords;
out vec3 surfaceNormal;
out vec3 toLightVector[4];
out vec3 toCameraVector;
out float visibility;
out vec4 shadowCoords;

const float density = 0.003;
const float gradient = 30;

void main(void) {

	vec4 worldPosition = transformationMatrix * vec4(position, 1.0);
	
	gl_ClipDistance[0] = dot(worldPosition, clipPlane);
	
	vec4 relativePositionToCamera = viewMatrix * worldPosition;
	shadowCoords = toShadowMapSpace * worldPosition;
	
	for (int i=0; i<4; i++) {
		toLightVector[i] = lightPosition[i] - worldPosition.xyz;
	}
	surfaceNormal = (transformationMatrix * vec4(normal, 0.0)).xyz;
	toCameraVector = (inverse(viewMatrix) * vec4(0.0, 0.0, 0.0, 1.0)).xyz - worldPosition.xyz;
	
	gl_Position = projectionMatrix * relativePositionToCamera;
	pass_textureCoords = textureCoords;
	
	float distance = length(relativePositionToCamera.xyz);
	visibility = exp(-pow((distance*density),gradient));
	visibility = clamp(visibility, 0.0, 1.0);
	
}