extends Control
## Draws dotted path trails between map nodes. `lines` is an array of
## [Vector2 from, Vector2 to] pairs set by map_screen.gd.

var lines: Array = []

func _draw() -> void:
	for l in lines:
		var from: Vector2 = l[0]
		var to: Vector2 = l[1]
		var dist := from.distance_to(to)
		if dist < 1.0:
			continue
		var dir := (to - from) / dist
		var d := 12.0
		while d < dist - 12.0:
			draw_circle(from + dir * d, 2.4, Color(0.95, 0.9, 0.8, 0.28))
			d += 13.0
