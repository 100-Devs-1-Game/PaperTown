// https://godotshaders.com/shader/chromatic-spin/
// with some mods by me :D

shader_type canvas_item;

uniform vec2 center = vec2(0.5);
uniform int stripes = 24;
uniform float speed : hint_range(0.0, 5.0, 0.1) = 0.2;
uniform int direction : hint_range(-1, 1, 2) = 1;
uniform vec4 stripe_colors[8] : source_color;
uniform int color_count : hint_range(1, 8) = 2;
uniform float alpha_mul : hint_range(0, 10) = 2;
uniform float stripe_distance_mul : hint_range(-10, 10) = 1;
uniform float stripe_strength_mul : hint_range(-10, 10) = 1;
uniform float minimum_alpha : hint_range(-1, 1) = 0;
uniform float maximum_alpha : hint_range(0, 1) = 1;

void fragment() {
	vec2 uv_deriv = fwidth(UV);
	float aspect_ratio = uv_deriv.y / uv_deriv.x;
	vec2 corrected_uv = UV * vec2(aspect_ratio, 1.0);
	vec2 corrected_center = center * vec2(aspect_ratio, 1.0);

	vec2 dir = corrected_center - corrected_uv;
	float angle = atan(dir.y, dir.x) - (TIME * speed * float(direction));

	int stripe_index = int(floor(angle / (TAU / float(stripes)))) % stripes;
	int color_index = stripe_index % color_count;
	color_index = clamp(color_index, 0, color_count - 1);

	vec2 rel_distance_vec = vec2(abs(corrected_uv.x - corrected_center.x), abs(corrected_uv.y - corrected_center.y));
	rel_distance_vec *= 1.0 / stripe_distance_mul;
	rel_distance_vec.x *= rel_distance_vec.x;
	rel_distance_vec.y *= rel_distance_vec.y;
	float rel_distance = 1.5 - sqrt(rel_distance_vec.x + rel_distance_vec.y);
	//if (UV.x < 0.5) {
		//rel_distance = 1.0 - (((abs(UV.x - center.x)) + (abs(UV.y - center.y))) / 2.0);
	//}

    COLOR.rgb = mix(COLOR.rgb, stripe_colors[color_index].rgb, rel_distance * stripe_strength_mul);
	COLOR.a *= mix(stripe_colors[color_index].a, maximum_alpha * COLOR.a, (minimum_alpha * COLOR.a) + (rel_distance * stripe_strength_mul));
}
