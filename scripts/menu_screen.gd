extends Control

func _ready() -> void:
	var title: Label = $Title
	title.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(title, "modulate:a", 1.0, 0.8)
	$ContinueButton.visible = Run.has_save()

func _on_start_button_pressed() -> void:
	get_node("/root/Main").goto("charselect")

func _on_continue_button_pressed() -> void:
	if Run.load_game():
		get_node("/root/Main").goto("map")
	else:
		$ContinueButton.visible = false

func _on_quit_button_pressed() -> void:
	get_tree().quit()
