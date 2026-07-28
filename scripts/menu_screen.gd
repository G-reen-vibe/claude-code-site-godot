extends Control

func _ready() -> void:
	var title: Label = $Title
	title.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(title, "modulate:a", 1.0, 0.8)

func _on_start_button_pressed() -> void:
	Run.new_run()
	get_node("/root/Main").goto("neow")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
