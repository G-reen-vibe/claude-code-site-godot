extends Node3D
## Hotkey control for the Octopath-style post-processing stack.
##
## 1 — toggle tilt-shift depth of field
## 2 — toggle vignette
## 3 — toggle color grade
## 4 — toggle film grain + chromatic aberration
## 5 — toggle the whole post-process layer
## R / F — move the tilt-shift focus band up / down
## H — hide/show the help overlay, Esc — quit

const TOGGLE_KEYS: Dictionary = {
	KEY_1: ["tilt_shift_enabled"],
	KEY_2: ["vignette_enabled"],
	KEY_3: ["grade_enabled"],
	KEY_4: ["grain_enabled", "aberration_enabled"],
}

@onready var _post_rect: ColorRect = %PostRect
@onready var _help_label: Label = %HelpLabel
@onready var _post_material: ShaderMaterial = _post_rect.material


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if TOGGLE_KEYS.has(event.keycode):
		for param: String in TOGGLE_KEYS[event.keycode]:
			var enabled: bool = _post_material.get_shader_parameter(param)
			_post_material.set_shader_parameter(param, not enabled)
		return
	match event.keycode:
		KEY_5:
			_post_rect.visible = not _post_rect.visible
		KEY_R:
			_nudge_focus(-0.05)
		KEY_F:
			_nudge_focus(0.05)
		KEY_H:
			_help_label.visible = not _help_label.visible
		KEY_ESCAPE:
			get_tree().quit()


func _nudge_focus(amount: float) -> void:
	var center: float = _post_material.get_shader_parameter("focus_center")
	_post_material.set_shader_parameter("focus_center", clampf(center + amount, 0.0, 1.0))
