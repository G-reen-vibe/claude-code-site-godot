// ============================================================================
// Fake volumetric light shafts / god rays (Godot 4.3, Forward+)
//
// Additive, unshaded "light shaft card" — the classic trick Octopath Traveler
// uses to paint sunbeams through trees. Place a QuadMesh roughly aligned with
// the sun direction; the shader draws slowly drifting vertical beams that
// fade out toward the bottom and the sides of the quad.
// ============================================================================
shader_type spatial;
render_mode blend_add, unshaded, cull_disabled, depth_draw_never, shadows_disabled, fog_disabled;

uniform vec4 ray_color : source_color = vec4(1.0, 0.93, 0.72, 1.0);
uniform float intensity : hint_range(0.0, 3.0) = 0.7;
uniform float ray_speed : hint_range(0.0, 0.5) = 0.04;
// Seamless noise; sampled along one row so the beams stay vertical.
uniform sampler2D ray_noise : filter_linear, repeat_enable;

void fragment() {
	// Sample a single noise row: X gives the beam pattern, TIME drifts it.
	float beams = texture(ray_noise, vec2(UV.x * 1.5 - TIME * ray_speed, 0.35)).r;
	beams = pow(beams, 2.2);

	// Bright at the top of the quad, dissolving toward the ground.
	float vertical_fade = 1.0 - smoothstep(0.15, 0.95, UV.y);
	// Soft falloff toward the left/right edges of the card.
	float side_fade = sin(UV.x * 3.14159265);

	ALBEDO = ray_color.rgb;
	ALPHA = beams * vertical_fade * side_fade * intensity * ray_color.a;
}
