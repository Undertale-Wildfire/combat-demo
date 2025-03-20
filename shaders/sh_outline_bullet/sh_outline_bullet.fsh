varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float pixel_width;
uniform float pixel_height;

void main() {
	vec2 offset_x = vec2(pixel_width, 0.0);
	vec2 offset_y = vec2(0.0, pixel_height);

	float alpha = texture2D(gm_BaseTexture, v_vTexcoord).a;
	alpha = max(alpha, texture2D(gm_BaseTexture, v_vTexcoord + offset_x).a);
	alpha = max(alpha, texture2D(gm_BaseTexture, v_vTexcoord - offset_x).a);
	alpha = max(alpha, texture2D(gm_BaseTexture, v_vTexcoord + offset_y).a);
	alpha = max(alpha, texture2D(gm_BaseTexture, v_vTexcoord - offset_y).a);
	alpha = max(alpha, texture2D(gm_BaseTexture, v_vTexcoord + offset_x + offset_y).a);
	alpha = max(alpha, texture2D(gm_BaseTexture, v_vTexcoord - offset_x + offset_y).a);
	alpha = max(alpha, texture2D(gm_BaseTexture, v_vTexcoord + offset_x - offset_y).a);
	alpha = max(alpha, texture2D(gm_BaseTexture, v_vTexcoord - offset_x - offset_y).a);

	gl_FragColor = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor.a = alpha;
}