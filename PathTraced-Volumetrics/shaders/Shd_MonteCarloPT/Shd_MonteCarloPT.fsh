varying vec2 in_TexelCoord;
uniform sampler2D emissivity;
uniform sampler2D absorption;
uniform sampler2D noise;
uniform vec2 worldExt;
uniform float rayCount;

#define LINEAR(c) vec4(pow(c.rgb, vec3(2.2)), c.a)
#define SRGB(c) vec4(pow(c.rgb, vec3(1.0 / 2.2)), 1.0)
#define RADIANS(n) ((n) * 6.283185)

vec4 trace(vec2 probe, vec2 delta) {
	vec4 radiance = vec4(0.0), transmit = vec4(1.0);
	vec2 slope = delta / max(abs(delta.x), abs(delta.y));
	float stepLength = length(slope);
	vec2 invSize = 1.0 / worldExt;
	for(float ii = 0.0; ii < worldExt.x; ii ++) {
		vec2 ray = (probe + (slope * ii)) * invSize;
		if (floor(ray) != vec2(0.0)) break;
		vec4 emiss = LINEAR(texture2D(emissivity, ray));
		vec4 absrp = LINEAR(texture2D(absorption, ray));
		
		vec4 optic = absrp * stepLength;
		vec4 trans = exp(-optic);
		vec4 radnc = emiss * (1.0 - trans);
		
		radiance += radnc * transmit;
		transmit *= trans;
	}
	return radiance;
}

void main() {
	float bluenoise = texture2D(noise, in_TexelCoord).r;
	for(float i = 0.0; i < rayCount; i ++) {
		float theta = RADIANS(((i + bluenoise)/rayCount));
		vec2 limit = vec2(cos(theta), -sin(theta));
		vec2 origin = in_TexelCoord * worldExt;
		gl_FragColor += trace(origin, limit);
	}
	gl_FragColor = SRGB((gl_FragColor / rayCount));
}