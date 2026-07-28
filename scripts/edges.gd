extends Control
## Draws the path lines between map nodes. `lines` is an array of
## [Vector2 from, Vector2 to] pairs set by map_screen.gd.

var lines: Array = []

func _draw() -> void:
	for l in lines:
		draw_line(l[0], l[1], Color(1, 1, 1, 0.18), 2.0)
