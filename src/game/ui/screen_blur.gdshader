shader_type canvas_item;

uniform float BLUR_STRENGTH: hint_range(0.0, 8.0) = 2.0;
uniform vec4 BACKGROUND_COLOR: source_color;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV, BLUR_STRENGTH * COLOR.a);
	color.rgb = mix(color.rgb, BACKGROUND_COLOR.rgb, BACKGROUND_COLOR.a);
	COLOR = color;
}
