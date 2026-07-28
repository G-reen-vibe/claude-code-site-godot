extends Control

const TYPE_INFO := {
	"monster": {"letter": "M", "color": Color(0.85, 0.55, 0.55), "name": "Monster"},
	"elite": {"letter": "E", "color": Color(1.0, 0.35, 0.35), "name": "Elite"},
	"rest": {"letter": "R", "color": Color(0.5, 0.9, 0.5), "name": "Rest Site"},
	"shop": {"letter": "S", "color": Color(0.55, 0.65, 1.0), "name": "Shop"},
	"treasure": {"letter": "T", "color": Color(1.0, 0.85, 0.4), "name": "Treasure"},
	"boss": {"letter": "B", "color": Color(1.0, 0.25, 0.2), "name": "Boss"},
}

func _ready() -> void:
	_build()
	_update_top()

func _update_top() -> void:
	$TopBar/HPLabel.text = "HP %d/%d" % [Run.hp, Run.max_hp]
	$TopBar/GoldLabel.text = "Gold: %d" % Run.gold
	$TopBar/FloorLabel.text = "Floor %d/%d" % [Run.current_row + 1, Run.MAP_ROWS]
	$TopBar/RelicsLabel.text = "Relics: " + Run.relic_names()

func _node_pos(row: int, col: int, row_size: int) -> Vector2:
	return Vector2(640.0 + (col - (row_size - 1) / 2.0) * 170.0, 655.0 - row * 45.0)

func _build() -> void:
	var lines: Array = []
	for r in Run.map_rows.size():
		var row: Array = Run.map_rows[r]
		for c in row.size():
			var pos := _node_pos(r, c, row.size())
			if r < Run.map_rows.size() - 1:
				var next: Array = Run.map_rows[r + 1]
				for nc in next.size():
					if next.size() == 1 or abs(nc - c) <= 1:
						lines.append([pos, _node_pos(r + 1, nc, next.size())])
			var info: Dictionary = TYPE_INFO[row[c].type]
			var b := Button.new()
			b.text = info.letter
			b.tooltip_text = info.name
			b.position = pos - Vector2(21, 17)
			b.size = Vector2(42, 34)
			b.self_modulate = info.color
			if row[c].visited:
				b.modulate = Color(0.45, 0.45, 0.45)
			if r == Run.current_row and c == Run.current_col:
				b.modulate = Color(1, 1, 0.4)
			b.disabled = not Run.can_move_to(r, c)
			b.pressed.connect(_on_node_pressed.bind(r, c))
			$Nodes.add_child(b)
	$Edges.lines = lines
	$Edges.queue_redraw()

func _on_node_pressed(r: int, c: int) -> void:
	var node: Dictionary = Run.map_rows[r][c]
	Run.current_row = r
	Run.current_col = c
	node.visited = true
	match node.type:
		"monster", "elite", "boss":
			Run.pending_node_type = node.type
			Run.pending_encounter = EnemiesDB.encounter(node.type, r, Run.rng)
			_main().goto("combat")
		"rest":
			_main().goto("rest")
		"shop":
			_main().goto("shop")
		"treasure":
			_main().goto("treasure")

func _main() -> Node:
	return get_node("/root/Main")

func _on_deck_button_pressed() -> void:
	var list: ItemList = $DeckPanel/V/DeckList
	list.clear()
	for entry in Run.deck:
		list.add_item(CardsDB.describe(entry))
	$DeckPanel.visible = true

func _on_close_button_pressed() -> void:
	$DeckPanel.visible = false
