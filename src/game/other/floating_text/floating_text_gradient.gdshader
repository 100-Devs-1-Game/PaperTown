shader_type canvas_item;

uniform vec4 top_color : source_color;
uniform vec4 bottom_color : source_color;
uniform float rect_height;

void fragment() {
    float t = FRAGCOORD.y / rect_height;

    vec4 gradient = mix(top_color, bottom_color, t);

	// we treat "white" as the colour to replace with our gradient
	// this is also why we use (244, 244, 244) as the shadow colour
	if (COLOR.rgb == vec3(1.0, 1.0, 1.0)) {
    	COLOR = texture(TEXTURE, UV) * gradient;
	}
}
