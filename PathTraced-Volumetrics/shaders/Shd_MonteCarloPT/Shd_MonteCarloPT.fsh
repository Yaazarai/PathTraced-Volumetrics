varying vec2 in_TexelCoord;
uniform sampler2D emissivity;
uniform sampler2D absorption;
uniform sampler2D noise;
uniform vec2 worldExt;
uniform float rayCount;

#define LINEAR(c) vec4(pow(c.rgb, vec3(2.2)), c.a)
#define SRGB(c) vec4(pow(c.rgb, vec3(1.0 / 2.2)), 1.0)
#define RADIANS(n) ((n) * 6.283185)

void trace(vec2 x1y1, vec2 x2y2, out vec3 radiance, out vec3 transmit) {
	const float stride = 1.0;
	vec2  segment = x2y2 - x1y1;
	float intrv = max(abs(segment.x), abs(segment.y));
	vec2 delta = segment / vec2(intrv);
	
	radiance = vec3(0.0);
	transmit = vec3(1.0);
	
	for(float ii = 0.0; ii < intrv; ii += stride) {
		vec2 ray = (x1y1 + (delta * ii)) / worldExt;
		
		if (floor(ray) != vec2(0.0)) break;
		radiance += transmit * SRGB(texture2D(emissivity, ray)).rgb * stride;
		transmit *= exp(-SRGB(texture2D(absorption, ray)).rgb * stride);
	}
}

void main() {
	float bluenoise = texture2D(noise, in_TexelCoord).r;
	for(float i = 0.0; i < rayCount; i += 1.0) {
		float theta = RADIANS((i + bluenoise) / rayCount);
		vec2 delta = vec2(cos(theta), -sin(theta)) * length(worldExt);
		vec2 origin = in_TexelCoord * worldExt;
<<<<<<< Updated upstream
		gl_FragColor += LINEAR(trace(origin, delta, abs(delta)));
	}
	gl_FragColor = SRGB(vec4(gl_FragColor / rayCount));
}

/*
	Emissivity:
		Additive Color Blending
	
	Absorption:
		Subtractive Color Blending
*/
=======
		vec3 radiance = vec3(0.0), transmit = vec3(1.0);
		delta = origin + delta;
		trace(origin, delta, radiance, transmit);
		gl_FragColor += LINEAR(vec4(radiance, 1.0));
	}
	
	gl_FragColor = SRGB(vec4(gl_FragColor / rayCount));
}
>>>>>>> Stashed changes
