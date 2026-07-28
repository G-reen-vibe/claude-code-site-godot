// ============================================================================
// Stylized HD-2D water (Godot 4.3, Forward+)
//
// Octopath-style pond/river surface:
//   * Gerstner-ish vertex bobbing from two crossed sine waves
//   * Two scrolling noise layers for surface movement
//   * Depth-fade from shallow to deep color (reads the depth buffer)
//   * Foam at intersections with geometry and around the plane's rim
//   * Fresnel sky tint + sparse HDR "sparkle" glints that feed the bloom pass
//
// Assign to a subdivided PlaneMesh. `wave_noise` expects a seamless noise
// texture (a NoiseTexture2D works out of the box).
// ============================================================================
shader_type spatial;
render_mode cull_disabled, specular_schlick_ggx;

uniform vec4 shallow_color : source_color = vec4(0.26, 0.58, 0.62, 1.0);
uniform vec4 deep_color : source_color = vec4(0.06, 0.22, 0.38, 1.0);
uniform float depth_fade_distance : hint_range(0.05, 8.0) = 1.5;

group_uniforms waves;
uniform sampler2D wave_noise : filter_linear, repeat_enable;
uniform float wave_scale : hint_range(0.5, 20.0) = 4.0;
uniform float wave_speed : hint_range(0.0, 0.5) = 0.05;
uniform float wave_height : hint_range(0.0, 0.5) = 0.05;

group_uniforms foam;
uniform vec4 foam_color : source_color = vec4(0.93, 0.97, 1.0, 1.0);
// Depth difference (metres) under which contact foam appears.
uniform float foam_distance : hint_range(0.0, 2.0) = 0.30;
// How close to the plane's UV border the rim foam starts.
uniform float rim_foam_start : hint_range(0.5, 1.0) = 0.86;

group_uniforms sparkle;
uniform float sparkle_strength : hint_range(0.0, 16.0) = 5.0;

uniform sampler2D depth_texture : hint_depth_texture, filter_linear;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float bob = sin(world_pos.x * 2.1 + TIME * 1.4) * 0.5
			+ sin(world_pos.z * 1.7 + TIME * 1.1) * 0.5;
	VERTEX.y += bob * wave_height;
}

void fragment() {
	// Two noise layers scrolling in different directions = living surface.
	vec2 uv1 = world_pos.xz / wave_scale + TIME * wave_speed * vec2(1.0, 0.7);
	vec2 uv2 = world_pos.xz / (wave_scale * 1.7) + TIME * wave_speed * vec2(-0.8, 0.5);
	float noise1 = texture(wave_noise, uv1).r;
	float noise2 = texture(wave_noise, uv2).r;
	float waves = noise1 * 0.5 + noise2 * 0.5;

	// Reconstruct the view-space depth of the opaque scene behind the surface.
	float depth_raw = texture(depth_texture, SCREEN_UV).r;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth_raw);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float scene_dist = -view.z;
	float surface_dist = -VERTEX.z;
	float depth_diff = max(scene_dist - surface_dist, 0.0);

	float water_depth = clamp(depth_diff / depth_fade_distance, 0.0, 1.0);
	vec3 col = mix(shallow_color.rgb, deep_color.rgb, water_depth);

	// Contact foam where geometry pierces the surface + rim foam at the edge.
	vec2 edge_uv = abs(UV - 0.5) * 2.0;
	float edge = max(edge_uv.x, edge_uv.y);
	float rim_foam = smoothstep(rim_foam_start, 0.99, edge + (waves - 0.5) * 0.12);
	float contact_foam = 1.0 - smoothstep(0.0, foam_distance, depth_diff);
	float foam = max(rim_foam, contact_foam) * smoothstep(0.30, 0.62, waves + 0.25);
	col = mix(col, foam_color.rgb, clamp(foam, 0.0, 1.0));

	// Fresnel push toward a pale sky tint at grazing angles.
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	col = mix(col, vec3(0.72, 0.83, 0.94), fresnel * 0.35);

	// Sparse glints where both noise layers peak; >1.0 values trigger bloom.
	float glint = pow(clamp(noise1 + noise2 - 1.15, 0.0, 1.0), 3.0);
	EMISSION = vec3(1.0, 0.97, 0.88) * glint * sparkle_strength;

	ALBEDO = col;
	ROUGHNESS = 0.12;
	SPECULAR = 0.6;
	ALPHA = mix(0.78, 0.95, water_depth);
}
