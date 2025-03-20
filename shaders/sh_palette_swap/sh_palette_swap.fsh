varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int colors;
uniform sampler2D palettes;

void main() {
	vec4 color = texture2D(gm_BaseTexture, v_vTexcoord);
	
	for (int i = 0; i < colors; ++i) {
		vec3 old = texture2D(palettes, vec2(float(i) / float(colors), 0.0)).rgb;
		vec3 new = texture2D(palettes, vec2(float(i) / float(colors), 0.5)).rgb;
		
		if (distance(color.rgb, old) < 0.01) {
			color.rgb = new;
			break;
		}
	}
	
	gl_FragColor = color * v_vColour;
}
