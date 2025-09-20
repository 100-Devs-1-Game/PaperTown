shader_type canvas_item;

uniform float BLUR_STRENGTH: hint_range(0.0, 5.0) = 2.0;
uniform float DARKEN_STRENGTH: hint_range(-1.0, 1.0) = 0.1;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV, BLUR_STRENGTH);
	color.rgb *= 1.0 - DARKEN_STRENGTH;
	COLOR = color;
}
