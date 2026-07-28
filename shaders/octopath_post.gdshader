// ============================================================================
// Octopath Traveler-style full-screen post-processing (Godot 4.3, Forward+)
//
// Combines the signature HD-2D "diorama" look in a single pass:
//   * Tilt-shift depth of field (vertical focus band + mip-based blur)
//   * Chromatic aberration that grows toward the screen edges
//   * Painterly color grade (contrast / saturation / cool shadows, warm lights)
//   * Soft colored vignette
//   * Animated film grain
//
// Attach to a full-rect ColorRect on a CanvasLayer drawn above the 3D view.
// Every stage can be toggled independently at runtime via the bool uniforms.
// ============================================================================
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

group_uniforms tilt_shift;
uniform bool tilt_shift_enabled = true;
// Vertical center of the sharp band, in screen UV (0 = top, 1 = bottom).
uniform float focus_center : hint_range(0.0, 1.0) = 0.45;
// Half-height of the fully sharp band.
uniform float focus_height : hint_range(0.0, 0.5) = 0.12;
// Distance over which sharpness falls off to maximum blur.
uniform float focus_falloff : hint_range(0.01, 1.0) = 0.32;
// Maximum blur, expressed in screen-texture mip levels.
uniform float blur_strength : hint_range(0.0, 6.0) = 3.2;

group_uniforms chromatic_aberration;
uniform bool aberration_enabled = true;
uniform float aberration_amount : hint_range(0.0, 0.02) = 0.003;

group_uniforms color_grade;
uniform bool grade_enabled = true;
uniform float grade_contrast : hint_range(0.5, 2.0) = 1.06;
uniform float grade_saturation : hint_range(0.0, 2.0) = 1.15;
uniform float grade_brightness : hint_range(0.5, 2.0) = 1.02;
uniform vec4 shadow_tint : source_color = vec4(0.22, 0.28, 0.42, 1.0);
uniform float shadow_tint_amount : hint_range(0.0, 1.0) = 0.30;
uniform vec4 highlight_tint : source_color = vec4(1.0, 0.93, 0.80, 1.0);
uniform float highlight_tint_amount : hint_range(0.0, 1.0) = 0.35;

group_uniforms vignette;
uniform bool vignette_enabled = true;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.45;
uniform float vignette_softness : hint_range(0.01, 1.0) = 0.55;
uniform vec4 vignette_color : source_color = vec4(0.05, 0.05, 0.09, 1.0);

group_uniforms film_grain;
uniform bool grain_enabled = true;
uniform float grain_amount : hint_range(0.0, 0.2) = 0.03;

// Five-tap blur around `uv` at mip `lod`. The extra taps hide the blocky
// artifacts that raw mip sampling produces at high lod values.
vec3 sample_scene(vec2 uv, float lod) {
	vec2 texel = 1.0 / vec2(textureSize(screen_texture, 0));
	vec2 spread = texel * (1.0 + exp2(lod) * 0.5);
	vec3 col = textureLod(screen_texture, uv, lod).rgb * 0.4;
	col += textureLod(screen_texture, uv + vec2(spread.x, spread.y), lod).rgb * 0.15;
	col += textureLod(screen_texture, uv + vec2(-spread.x, spread.y), lod).rgb * 0.15;
	col += textureLod(screen_texture, uv + vec2(spread.x, -spread.y), lod).rgb * 0.15;
	col += textureLod(screen_texture, uv + vec2(-spread.x, -spread.y), lod).rgb * 0.15;
	return col;
}

float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 from_center = uv - vec2(0.5);

	// --- Tilt-shift: blur grows with vertical distance from the focus band.
	float lod = 0.0;
	if (tilt_shift_enabled) {
		float dist = max(abs(uv.y - focus_center) - focus_height, 0.0);
		lod = smoothstep(0.0, focus_falloff, dist) * blur_strength;
	}

	// --- Chromatic aberration: split channels radially from screen center.
	vec3 col;
	if (aberration_enabled) {
		vec2 shift = from_center * aberration_amount;
		col.r = sample_scene(uv + shift, lod).r;
		col.g = sample_scene(uv, lod).g;
		col.b = sample_scene(uv - shift, lod).b;
	} else {
		col = sample_scene(uv, lod);
	}

	// --- Color grade: contrast, saturation, split-toned shadows/highlights.
	if (grade_enabled) {
		col = (col - 0.5) * grade_contrast + 0.5;
		col *= grade_brightness;
		float luma = dot(col, vec3(0.299, 0.587, 0.114));
		col = mix(vec3(luma), col, grade_saturation);
		float shadow_mask = pow(clamp(1.0 - luma, 0.0, 1.0), 2.0);
		float highlight_mask = pow(clamp(luma, 0.0, 1.0), 2.0);
		col += shadow_tint.rgb * shadow_mask * shadow_tint_amount * 0.30;
		col = mix(col, col * highlight_tint.rgb, highlight_mask * highlight_tint_amount);
	}

	// --- Vignette: multiply toward a tinted dark at the edges.
	if (vignette_enabled) {
		float dist = length(from_center * vec2(1.15, 1.0));
		float vig = smoothstep(0.75, 0.75 - vignette_softness, dist);
		vig = mix(1.0 - vignette_intensity, 1.0, vig);
		col = mix(vignette_color.rgb, col, clamp(vig, 0.0, 1.0));
	}

	// --- Animated film grain.
	if (grain_enabled) {
		float noise = hash21(uv * 512.0 + vec2(TIME * 53.0, TIME * 91.0));
		col += (noise - 0.5) * grain_amount;
	}

	COLOR = vec4(col, 1.0);
}
