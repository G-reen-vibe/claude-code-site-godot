class_name FloatText
## Spawns a floating, fading text label (damage numbers, block gains, etc.).

static func spawn(parent: Node, global_pos: Vector2, text: String, color: Color, font_size: int = 26) -> void:
	var label := Label.new()
	label.text = text
	label.top_level = true
	label.z_index = 50
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("outline_size", 6)
	parent.add_child(label)
	var jitter := Vector2(randf_range(-18.0, 18.0), randf_range(-8.0, 0.0))
	label.global_position = global_pos + jitter - Vector2(20, 20)
	var tw := label.create_tween().set_parallel(true)
	tw.tween_property(label, "global_position", label.global_position + Vector2(0, -48), 0.85)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(label, "modulate:a", 0.0, 0.85).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(label.queue_free)
