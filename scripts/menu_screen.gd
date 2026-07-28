extends Control

func _on_start_button_pressed() -> void:
	Run.new_run()
	get_node("/root/Main").goto("map")
