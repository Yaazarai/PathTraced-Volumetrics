Basic and barebones implementation of path traced volumetrics for only emissivity and absorption properties.

The renderer can be tweaked by the `render_size` (square) for the resolution and `render_rays` for the number of rays to cast per-pixel. The `emissivity` and `absorption` properties have their own individual surfaces/textures that can be drawn to--sample scene included. Radiance and Transmittance is applied per each RGB channel allowing for colored emissive and colored absorbative objects. Emissiion and Absorption can be overlapped between both textures to dampen emissive output and/or combine the two properties.

<div align="center">
  <video src="https://github.com/user-attachments/assets/1f847138-ddd3-4d24-9751-b897a35f431d" width="400" />
</div>

The full shader in GLSL 1.0 is as follows:
```glsl
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
	vec3 radiance = vec3(0.0), transmit = vec3(1.0);
	float theta = atan(delta.y, delta.x);
	vec2 slope = delta / max(abs(delta.x), abs(delta.y));
	float stepLength = length(slope);
	vec2 invSize = 1.0 / worldExt;
	
	for(float ii = 0.0; ii < worldExt.x; ii ++) {
		vec2 ray = (probe + (slope * ii)) * invSize;
		if (floor(ray) != vec2(0.0)) break;
		vec3 emiss = LINEAR(texture2D(emissivity, ray)).rgb;
		vec3 absrp = LINEAR(texture2D(absorption, ray)).rgb;
		
		vec3 optic = absrp * stepLength;
		vec3 trans = exp(-optic);
		vec3 radnc = emiss * (1.0 - trans);
		
		radiance += radnc * transmit;
		transmit *= trans;
	}
	return vec4(radiance, 1.0);
}

void main() {
	float bluenoise = texture2D(noise, in_TexelCoord).r;
	for(float i = 0.0; i < rayCount; i += 1.0) {
		float theta = RADIANS(((i)/rayCount));
		vec2 limit = vec2(cos(theta), -sin(theta));
		vec2 origin = in_TexelCoord * worldExt;
		gl_FragColor += trace(origin, limit);
	}
	gl_FragColor = SRGB(vec4(gl_FragColor / rayCount));
}
```
NOTE: With this raytracing function (line tracing) the path tracer has an angular bias on the diagonals due to poor contribution distribution. I've adjusted each sample such that it computes its total contribution based on the angle the ray was traced from. This is done by converting the absorption value to optical depth by multiplying by the simulated step length along the ray. The step length is equal to the length of the delta vector. Optical depth (also known as tau) is similar to absorption except that it takes the total path length along the sample into consideration, its the actual "thickness," of the sample.

The path-tracer doesn't do actual monte-carlo temporal filtering--because whatever--it just casts uniformly-spaced noisely offset rays and converts the final output from SRGB -> LINEAR -> SRGB. The rendered output is done in SRGB, whereas for rendering we want to operate in linear color space (as the rendering equation is linear), so a conversion to linear and back is required.

The raymarch function allws adjusting the stepSize either for performance (assuming some minimum size object), but consequently produces skipping artifacts.

Absorption is the particle mean-free path (average distance a particle travels through a medium before being absorbed). This defines the average loss of energy per-each raymarch step through aa medium.

Emissivity is the unit energy given off by an object through thermal radiation, in this case in the visible spectrum. This defines the average gain of energy per-each raymarch step through a medium.
