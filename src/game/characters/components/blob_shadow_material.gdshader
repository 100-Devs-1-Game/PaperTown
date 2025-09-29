shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix;

uniform vec4 shadow_color: source_color = vec4(0.0, 0.0, 0.0, 0.5);
uniform float radius = 1.0;
uniform float softness = 0.3;

void fragment() {
    vec2 uv_centered = UV - vec2(0.5);
    float dist = length(uv_centered);
    float alpha = smoothstep(radius, radius - softness, dist);

    ALBEDO = shadow_color.rgb;
    ALPHA = shadow_color.a * alpha;
}
