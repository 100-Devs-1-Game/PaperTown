// https://docs.godotengine.org/en/latest/tutorials/shaders/advanced_postprocessing.html

// warning: could not get this working nicely for compatibility renderers
// because of transparent things turning invisible... :/

// p.s also has fog, too lazy to rename now though

shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_always;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform sampler2D depth_texture  : hint_depth_texture, filter_linear;

uniform float focus_target = 10.0; // how far away the thing "in focus" is
uniform float focus_range = 5.0; // how far the stuff around target is "focused"
uniform float max_blur = 4.0; // lower numbers work better
uniform float debug_red = 0.0; //set to 1.0 to make the blur red for debugging

// from https://godotshaders.com/shader/distance-gradient-fog-4-3/
uniform sampler2D fog_gradient;
uniform float fog_strength : hint_range(0.0, 1.0) = 1.0;
uniform float fog_amount : hint_range(0.0, 1.0) = 0.15;
uniform float fog_near = 1.0;
uniform float fog_far = 150.0;

void vertex() {
	// force it to cover entire viewport (even in editor)
	// use @tool script to turn it off in editor
    POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	// basically all from the tutorial, idk, magic math things
    float depth = texture(depth_texture, SCREEN_UV).x;
	#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	vec4 ndc = vec4(vec3(SCREEN_UV, depth) * 2.0 - 1.0, 1.0);
	#else
	vec4 ndc = vec4(vec3(SCREEN_UV * 2.0 - 1.0, depth), 1.0);
	#endif

    vec4 view = INV_PROJECTION_MATRIX * ndc;
    view.xyz /= view.w;
    float linear_depth = -view.z;

	// scale the max blur based on where the depth is relative to our range
	// I'm like 50% sure this works...
    float blur_strength = clamp(abs(linear_depth - focus_target) / focus_range, 0.0, 1.0);
    float radius = blur_strength * max_blur;

	// texel = 1 screen pixel, basically
    vec2 texel = 1.0 / vec2(textureSize(screen_texture, 0));

	// sample the pixel + 4 surrounding pixels, to get a decent but cheap blur
	// at high blur amounts, this won't look nice tho
    vec4 col = vec4(0.0);
	vec4 center = texture(screen_texture, SCREEN_UV);
	col += center;
    col += texture(screen_texture, SCREEN_UV + vec2(radius, 0.0) * texel);
    col += texture(screen_texture, SCREEN_UV - vec2(radius, 0.0) * texel);
    col += texture(screen_texture, SCREEN_UV + vec2(0.0, radius) * texel);
    col += texture(screen_texture, SCREEN_UV - vec2(0.0, radius) * texel);

 	// average center + 4 neighbours
    col /= 5.0;

	// from https://godotshaders.com/shader/distance-gradient-fog-4-3/
    float fog_factor = clamp((linear_depth - fog_near) / (fog_far - fog_near), 0.0, 1.0);
    fog_factor *= fog_amount;
    vec4 fog_color = texture(fog_gradient, vec2(fog_factor, 0.0));

    ALBEDO = mix(col.rgb, fog_color.rgb, fog_color.a * fog_strength);
	ALBEDO.r += clamp(debug_red, 0.0, 1.0) * blur_strength;
	ALBEDO.g -= clamp(debug_red, 0.0, 1.0) * blur_strength;
	ALBEDO.b -= clamp(debug_red, 0.0, 1.0) * blur_strength;
	// optionally blur alpha, but doesn't seem necessary?
    ALPHA = col.a;
}
