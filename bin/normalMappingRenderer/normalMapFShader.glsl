#version 400 core

in vec2 pass_textureCoords;
in vec3 toLightVector[4];
in vec3 toCameraVector;
in float visibility;
in vec4 shadowCoords;

out vec4 out_Color;

uniform sampler2D modelTexture;
uniform sampler2D normalMap;

uniform sampler2D specularMap;
uniform float usesSpecularMap;

uniform sampler2D shadowMap;
uniform vec3 lightColour[4];
uniform vec3 attenuation[4];
uniform float shineDamper;
uniform float reflectivity;
uniform vec3 skyColour;
uniform int mapSize;
uniform float transparency;
uniform float objVisibility;
uniform float shadowOn;

const int pcfCount = 3;
const float totalTexels = (pcfCount * 2.0 + 1.0) * (pcfCount * 2.0 + 1.0);

void main(void){

	float lightFactor = 1;
	if (shadowOn == 1) {
		float texelSize = 1.0 / mapSize;
		float total = 0.0;	
		for (int x=-pcfCount; x<=pcfCount; x++) {
			for (int y=-pcfCount; y<=pcfCount; y++) {
				float objectNearestLight = texture(shadowMap, shadowCoords.xy + vec2(x, y) * texelSize).r;
				if (shadowCoords.z > objectNearestLight + 0.002) {
					total += 1.0;
				}
			}
		}
		total /= totalTexels;
		lightFactor = 1.0 - (total * shadowCoords.w);
	}
	vec4 normalMapValue = 2.0 * texture(normalMap, pass_textureCoords) - 1.0;

	vec3 unitNormal = normalize(normalMapValue.rgb);
	vec3 unitVectorToCamera = normalize(toCameraVector);
	
	vec3 totalDiffuse = vec3(0.0);
	vec3 totalSpecular = vec3(0.0);
	
	for(int i=0;i<4;i++){
		float distance = length(toLightVector[i]);
		float attFactor = attenuation[i].x + (attenuation[i].y * distance) + (attenuation[i].z * distance * distance);
		vec3 unitLightVector = normalize(toLightVector[i]);	
		float nDotl = dot(unitNormal,unitLightVector);
		float brightness = max(nDotl,0.0);
		vec3 lightDirection = -unitLightVector;
		vec3 reflectedLightDirection = reflect(lightDirection,unitNormal);
		float specularFactor = dot(reflectedLightDirection , unitVectorToCamera);
		specularFactor = max(specularFactor,0.0);
		float dampedFactor = pow(specularFactor,shineDamper);
		totalDiffuse = totalDiffuse + (brightness * lightColour[i])/attFactor;
		totalSpecular = totalSpecular + (dampedFactor * reflectivity * lightColour[i])/attFactor;
	}
	totalDiffuse = max(totalDiffuse * lightFactor, 0.2);
	
	vec4 textureColour = texture(modelTexture,pass_textureCoords);
	
	if(transparency == 1 && textureColour.a<0.5 || objVisibility == 0){
		discard;
	}
	
	if (usesSpecularMap > 0.5) {
		vec4 mapInfo = texture(specularMap, pass_textureCoords);
		totalSpecular *= mapInfo.r;
	}

	out_Color =  vec4(totalDiffuse,1.0) * textureColour + vec4(totalSpecular,1.0);
	out_Color = mix(vec4(skyColour,1.0),out_Color, visibility);
}