extends Control
## The act map: rows of nodes connected by paths. The player climbs from the
## bottom row to the boss at the top, choosing one reachable node per floor.

signal node_selected(row: int, col: int)

const TYPE_LETTER := {"monster": "M", "elite": "E", "rest": "R", "boss": "B"}
const TYPE_COLOR := {
	"monster": Color(0.88, 0.88, 0.92),
	"elite": Color(1.0, 0.55, 0.3),
	"rest": Color(0.5, 1.0, 0.55),
	"boss": Color(0.9, 0.4, 1.0),
}

@onready var map_area: Control = $MapArea
@onready var hp_label: Label = $HUD/Margin/HBox/HPLabel
@onready var gold_label: Label = $HUD/Margin/HBox/GoldLabel
@onready var deck_label: Label = $HUD/Margin/HBox/DeckLabel
@onready var floor_label: Label = $HUD/Margin/HBox/FloorLabel


func refresh() -> void:
	_update_hud()
	# Defer so container layout has run and map_area.size is valid.
	call_deferred("_build_map")


func _update_hud() -> void:
	hp_label.text = "HP %d/%d" % [Run.player_hp, Run.player_max_hp]
	gold_label.text = "Gold %d" % Run.gold
	deck_label.text = "Deck %d cards" % Run.deck.size()
	floor_label.text = "Floor %d/%d" % [Run.current_row + 1, Run.MAP_ROWS]


func _node_pos(row: int, col: int, area: Vector2) -> Vector2:
	var x := area.x * 0.5 + (col - 1) * 240.0
	var step := (area.y - 130.0) / float(Run.MAP_ROWS - 1)
	var y := area.y - 70.0 - row * step
	return Vector2(x, y)


func _build_map() -> void:
	for c in map_area.get_children():
		c.visible = false
		c.queue_free()
	var area := map_area.size
	if area.x < 50.0:
		area = Vector2(1280, 672)

	var reach_row := 0
	var reach_cols: Array = [0, 1, 2]
	if Run.current_row >= 0:
		reach_row = Run.current_row + 1
		reach_cols = Run.node_at(Run.current_row, Run.current_col)["next"]

	# Path lines first so buttons draw on top of them.
	for r in Run.map_rows.size() - 1:
		for n in Run.map_rows[r]:
			for nc in n["next"]:
				var line := Line2D.new()
				line.add_point(_node_pos(r, n["col"], area))
				line.add_point(_node_pos(r + 1, nc, area))
				line.width = 2.0
				var from_current: bool = r == Run.current_row and n["col"] == Run.current_col
				line.default_color = Color(1, 1, 1, 0.45 if from_current else 0.12)
				map_area.add_child(line)

	for r in Run.map_rows.size():
		for n in Run.map_rows[r]:
			var btn := Button.new()
			btn.text = TYPE_LETTER[n["type"]]
			btn.add_theme_font_size_override("font_size", 22)
			btn.custom_minimum_size = Vector2(52, 52)
			btn.position = _node_pos(r, n["col"], area) - Vector2(26, 26)
			btn.tooltip_text = String(n["type"]).capitalize()
			var is_current: bool = r == Run.current_row and n["col"] == Run.current_col
			var reachable: bool = r == reach_row and reach_cols.has(n["col"])
			btn.disabled = not reachable
			var tint: Color = TYPE_COLOR[n["type"]]
			if is_current:
				tint = Color(1.0, 0.85, 0.2)
			btn.modulate = tint if (reachable or is_current) else Color(tint, 0.45)
			if reachable:
				btn.pressed.connect(_on_node_pressed.bind(r, n["col"]))
			map_area.add_child(btn)


func _on_node_pressed(row: int, col: int) -> void:
	node_selected.emit(row, col)
