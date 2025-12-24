Basic and barebones implementation of path traced volumetrics for only emissivity and absorption properties.

The renderer can be tweaked by the `render_size` (square) for the resolution and `render_rays` for the number of rays to cast per-pixel. The `emissivity` and `absorption` properties have their own individual surfaces/textures that can be drawn to--sample scene included. Radiance and Transmittance is applied per each RGB channel allowing for colored emissive and colored absorbative objects. Emissiion and Absorption can be overlapped between both textures to dampen emissive output and/or combine the two properties.

<div align="center">
  <video src="https://github.com/user-attachments/assets/1f847138-ddd3-4d24-9751-b897a35f431d" width="400" />
</div>

The full shader in GLSL 1.0 is as follows:
```glsl
varying vec2 in_TexelCoord;
uniform sampler2D emissivity, absorption, noise;
uniform vec2 worldExt;
uniform float rayCount;

#define LINEAR(c) vec4(pow(c.rgb, vec3(2.2)), c.a)
#define SRGB(c) vec4(pow(c.rgb, vec3(1.0 / 2.2)), 1.0)
#define RADIANS(n) ((n) * 6.283185)

vec4 trace(vec2 rxy, vec2 dxy) {
	vec3 radiance = vec3(0.0), transmit = vec3(1.0);
	const float stepSize = 1.0;
	vec2 delta = dxy / max(abs(dxy.x), abs(dxy.y));
	vec2 invWorldExt = 1.0 / worldExt;
	for(float ii = 0.0; ii < worldExt.x; ii += stepSize) {
		vec2 ray = (rxy + (delta * ii)) * invWorldExt;
		if (floor(ray) != vec2(0.0)) break;
		vec3 emiss = LINEAR(texture2D(emissivity, ray)).rgb;
		vec3 absrp = LINEAR(texture2D(absorption, ray)).rgb;
		vec3 trans = exp(-absrp);
		vec3 radnc = (1.0 - trans) * emiss;
		
		radiance += radnc * transmit;
		transmit *= trans;
	}
	return vec4(radiance, 1.0);
}

void main() {
	for(float i = 0.0; i < rayCount; i += 1.0) {
        float bluenoise = texture2D(noise, in_TexelCoord).r;
		float theta = RADIANS((i + bluenoise) / rayCount);
		vec2 delta = vec2(cos(theta), -sin(theta)) * length(worldExt);
		vec2 origin = in_TexelCoord * worldExt;
		gl_FragColor += LINEAR(trace(origin, delta, abs(delta)));
	}
	gl_FragColor = SRGB(vec4(gl_FragColor / rayCount));
}
```
The path-tracer doesn't do actual monte-carlo temporal filtering--because whatever--it just casts uniformly-spaced noisely offset rays and converts the final output from SRGB -> LINEAR -> SRGB. The rendered output is done in SRGB, whereas for rendering we want to operate in linear color space (as the rendering equation is linear), so a conversion to linear and back is required.

The raymarch function allws adjusting the stepSize either for performance (assuming some minimum size object), but consequently produces skipping artifacts.

Absorption is the particle mean-free path (average distance a particle travels through a medium before being absorbed). This defines the average loss of energy per-each raymarch step through aa medium.

Emissivity is the unit energy given off by an object through thermal radiation, in this case in the visible spectrum. This defines the average gain of energy per-each raymarch step through a medium.
