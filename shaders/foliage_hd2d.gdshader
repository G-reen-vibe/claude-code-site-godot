// ============================================================================
// HD-2D foliage sprite (Godot 4.3, Forward+)
//
// Same billboard/lighting/rim treatment as sprite_hd2d.gdshader, plus a
// vertex-level wind sway. The sway is weighted by UV.y so the canopy waves
// while the trunk stays planted, and phase-shifted by world position so a
// forest never moves in lockstep.
// ============================================================================
shader_type spatial;
render_mode cull_disabled, diffuse_lambert_wrap, specular_disabled;

uniform sampler2D albedo_texture : source_color, filter_nearest;
uniform vec4 modulate : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float alpha_scissor : hint_range(0.0, 1.0) = 0.5;
uniform bool y_billboard = true;

group_uniforms wind;
uniform float sway_strength : hint_range(0.0, 0.5) = 0.06;
uniform float sway_speed : hint_range(0.0, 8.0) = 1.6;

group_uniforms rim_light;
uniform float rim_strength : hint_range(0.0, 4.0) = 0.30;
uniform vec4 rim_color : source_color = vec4(1.0, 0.96, 0.80, 1.0);

void vertex() {
	// Wind sway: top of the quad (UV.y == 0) moves the most.
	float phase = MODEL_MATRIX[3].x * 0.8 + MODEL_MATRIX[3].z * 1.3;
	float weight = 1.0 - UV.y;
	VERTEX.x += sin(TIME * sway_speed + phase) * sway_strength * weight;
	VERTEX.x += sin(TIME * sway_speed * 2.7 + phase * 1.7) * sway_strength * 0.35 * weight;

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

	vec2 texel = 1.0 / vec2(textureSize(albedo_texture, 0));
	float left = texture(albedo_texture, UV + vec2(-texel.x, 0.0)).a;
	float right_a = texture(albedo_texture, UV + vec2(texel.x, 0.0)).a;
	float up = texture(albedo_texture, UV + vec2(0.0, -texel.y)).a;
	float down = texture(albedo_texture, UV + vec2(0.0, texel.y)).a;
	float neighbor_min = min(min(left, right_a), min(up, down));
	float edge = tex.a * (1.0 - neighbor_min);

	ALBEDO = tex.rgb;
	ALPHA = tex.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor;
	EMISSION = rim_color.rgb * rim_strength * edge;
}
