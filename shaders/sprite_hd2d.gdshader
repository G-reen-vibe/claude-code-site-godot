// ============================================================================
// HD-2D billboard sprite (Godot 4.3, Forward+)
//
// Renders a pixel-art texture on a QuadMesh the way Octopath Traveler renders
// characters inside a 3D world:
//   * Y-axis billboarding (sprite spins to face the camera, stays upright)
//   * Fully lit by the 3D scene (sun, point lights, shadows, SSAO, fog)
//   * Alpha-scissored so it casts and receives crisp shadows
//   * Backlight "rim" glow on the sprite's silhouette edge
//   * Optional luminance-keyed emission (bright texels feed the bloom pass)
//
// Assign as the QuadMesh material of a MeshInstance3D and set albedo_texture.
// ============================================================================
shader_type spatial;
render_mode cull_disabled, diffuse_lambert_wrap, specular_disabled;

uniform sampler2D albedo_texture : source_color, filter_nearest;
uniform vec4 modulate : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float alpha_scissor : hint_range(0.0, 1.0) = 0.5;
uniform bool y_billboard = true;

group_uniforms rim_light;
// Glow painted on the sprite's silhouette edge, mimicking Octopath's backlight.
uniform float rim_strength : hint_range(0.0, 4.0) = 0.35;
uniform vec4 rim_color : source_color = vec4(1.0, 0.95, 0.82, 1.0);

group_uniforms emission;
// Texels brighter than the threshold emit light (lanterns, crystals, magic).
// Leave the threshold above 1.0 to disable emission entirely.
uniform float emission_threshold : hint_range(0.0, 1.1) = 1.1;
uniform float emission_strength : hint_range(0.0, 16.0) = 3.0;

void vertex() {
	if (y_billboard) {
		vec3 scale = vec3(
			length(MODEL_MATRIX[0].xyz),
			length(MODEL_MATRIX[1].xyz),
			length(MODEL_MATRIX[2].xyz));
		vec3 to_camera = INV_VIEW_MATRIX[3].xyz - MODEL_MATRIX[3].xyz;
		to_camera.y = 0.0;
		if (length(to_camera) < 0.001) {
			to_camera = vec3(0.0, 0.0, 1.0);
		}
		vec3 forward = normalize(to_camera);
		vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), forward));
		mat4 billboard = mat4(
			vec4(right * scale.x, 0.0),
			vec4(0.0, scale.y, 0.0, 0.0),
			vec4(forward * scale.z, 0.0),
			MODEL_MATRIX[3]);
		MODELVIEW_MATRIX = VIEW_MATRIX * billboard;
		MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	}
}

void fragment() {
	vec4 tex = texture(albedo_texture, UV) * modulate;

	// Silhouette edge detection: a texel is "edge" when any 4-neighbour is
	// transparent. The rim glow hugs the sprite outline, whatever its shape.
	vec2 texel = 1.0 / vec2(textureSize(albedo_texture, 0));
	float left = texture(albedo_texture, UV + vec2(-texel.x, 0.0)).a;
	float right_a = texture(albedo_texture, UV + vec2(texel.x, 0.0)).a;
	float up = texture(albedo_texture, UV + vec2(0.0, -texel.y)).a;
	float down = texture(albedo_texture, UV + vec2(0.0, texel.y)).a;
	float neighbor_min = min(min(left, right_a), min(up, down));
	float edge = tex.a * (1.0 - neighbor_min);

	// Luminance-keyed emission for glowing texels (feeds the glow pass).
	float luma = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
	float glow_mask = smoothstep(emission_threshold, 1.0, luma);

	ALBEDO = tex.rgb;
	ALPHA = tex.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor;
	EMISSION = rim_color.rgb * rim_strength * edge
			+ tex.rgb * glow_mask * emission_strength;
}
