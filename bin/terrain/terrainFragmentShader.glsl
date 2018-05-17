#version 400 core

in vec2 pass_textureCoords;
in vec3 surfaceNormal;
in vec3 toLightVector[4];
in vec3 toCameraVector;

in float visibility;
in vec4 shadowCoords;

out vec4 out_color;

uniform float transparency;

uniform sampler2D backgroundTexture;
uniform sampler2D rTexture;
uniform sampler2D gTexture;
uniform sampler2D bTexture;
uniform sampler2D blendMap;
uniform sampler2D shadowMap;
uniform vec3 lightColour[4];
uniform vec3 attenuation[4];
uniform float shineDamper;
uniform float reflectivity;
uniform vec3 skyColour;
uniform int mapSize;
uniform float shadowOn;

const int pcfCount = 3;
const float totalTexels = (pcfCount * 2.0 + 1.0) * (pcfCount * 2.0 + 1.0);

void main(void) {

	float lightFactor = 1;
	if (shadowOn == 1) {
		float texelSize = 1.0 / mapSize;
		float total = 0.0;
		for (int x=-pcfCount; x<=pcfCount; x++) {
			for (int y=-pcfCount; y<=pcfCount; y++) {
				float objectNearestLight = texture(shadowMap, shadowCoords.xy + vec2(x, y) * texelSize).r;
				if (shadowCoords.z > objectNearestLight) {
					total += 1.0;
				}
			}
		}
		total /= totalTexels;
		lightFactor = 1.0 - (total * shadowCoords.w);
	}
	vec4 blendMapColour = texture(blendMap, pass_textureCoords);
	float backTextureAmount = 1 - (blendMapColour.r + blendMapColour.g + blendMapColour.b);
	vec2 tiledCoords = pass_textureCoords * 25.0;
	vec4 backgroundTextureColour = texture(backgroundTexture, tiledCoords) *  backTextureAmount;
	vec4 rTextureColour = texture(rTexture, tiledCoords) * blendMapColour.r;
	vec4 gTextureColour = texture(gTexture, tiledCoords) * blendMapColour.g;
	vec4 bTextureColour = texture(bTexture, tiledCoords) * blendMapColour.b;
	vec4 totalColour = backgroundTextureColour + rTextureColour + gTextureColour + bTextureColour;

	vec3 unitNormal = normalize(surfaceNormal);
	vec3 unitVectorToCamera = normalize(toCameraVector);
	
	vec3 totalDiffuse = vec3(0.0);
	vec3 totalSpecular = vec3(0.0);
	
	for (int i=0; i<4; i++) {
		float distance = length(toLightVector[i]);
		float attFactor = attenuation[i].x + (attenuation[i].y * distance) + (attenuation[i].z * distance * distance); 
		vec3 unitLightVector = normalize(toLightVector[i]);
		float normalDotLight = dot(unitNormal, unitLightVector);
		float brightness = max(normalDotLight, 0.0);	
		vec3 lightDirection = -unitLightVector;
		vec3 reflectedLightDirection = reflect(lightDirection, unitNormal);
		float specularFactor = dot(reflectedLightDirection, unitVectorToCamera);
		specularFactor = max(specularFactor, 0.0);
		float dampedFactor = pow(specularFactor, shineDamper);
		totalDiffuse =  totalDiffuse + (brightness * lightColour[i]) / attFactor;
		totalSpecular = totalSpecular + (dampedFactor * reflectivity * lightColour[i]) / attFactor;
	}
	
	totalDiffuse = max(totalDiffuse * lightFactor, 0.2);
	if (transparency == 1) {
		discard;
	} else {
		out_color = (vec4(totalDiffuse, 1) * totalColour + vec4(totalSpecular, 0));
	}
	out_color = mix(vec4(skyColour,1.0), out_color, 1);
}