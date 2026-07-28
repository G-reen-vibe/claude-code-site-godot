extends Control

const TYPE_INFO := {
	"monster": {"icon": preload("res://assets/icons/monster.svg"), "name": "Monster"},
	"elite": {"icon": preload("res://assets/icons/elite.svg"), "name": "Elite"},
	"rest": {"icon": preload("res://assets/icons/campfire.svg"), "name": "Rest Site"},
	"shop": {"icon": preload("res://assets/icons/shop.svg"), "name": "Merchant"},
	"treasure": {"icon": preload("res://assets/icons/chest.svg"), "name": "Treasure"},
	"event": {"icon": preload("res://assets/icons/event.svg"), "name": "Unknown Event"},
	"boss": {"icon": preload("res://assets/icons/boss.svg"), "name": "Boss"},
}
const MARKER_TEX := preload("res://assets/sprites/ironclad.svg")

func _ready() -> void:
	$Hud.potion_pressed.connect(_on_potion_pressed)
	_build()

func _on_potion_pressed(slot: int, right_click: bool) -> void:
	if right_click:
		Run.potions.remove_at(slot)
		$Hud.refresh()

func _node_pos(row: int, col: int, row_size: int) -> Vector2:
	return Vector2(640.0 + (col - (row_size - 1) / 2.0) * 190.0, 656.0 - row * 42.0)

func _build() -> void:
	var edge_lines: Array = []
	for r in Run.map_rows.size():
		var row: Array = Run.map_rows[r]
		for c in row.size():
			var pos := _node_pos(r, c, row.size())
			if r < Run.map_rows.size() - 1:
				var next: Array = Run.map_rows[r + 1]
				for nc in next.size():
					if next.size() == 1 or absi(nc - c) <= 1:
						edge_lines.append([pos, _node_pos(r + 1, nc, next.size())])
			var info: Dictionary = TYPE_INFO[row[c].type]
			var b := Button.new()
			b.icon = info.icon
			b.expand_icon = true
			b.tooltip_text = info.name
			var side := 52 if row[c].type == "boss" else 40
			b.position = pos - Vector2(side / 2.0, side / 2.0)
			b.size = Vector2(side, side)
			var reachable := Run.can_move_to(r, c)
			b.disabled = not reachable
			if row[c].visited:
				b.modulate = Color(0.5, 0.5, 0.5)
			elif not reachable:
				b.modulate = Color(0.62, 0.62, 0.66)
			b.pressed.connect(_on_node_pressed.bind(r, c))
			$Nodes.add_child(b)
			if reachable:
				var tw := b.create_tween().set_loops()
				tw.tween_property(b, "modulate", Color(1.25, 1.2, 0.9), 0.6)
				tw.tween_property(b, "modulate", Color.WHITE, 0.6)
	$Edges.lines = edge_lines
	$Edges.queue_redraw()
	if Run.current_row >= 0:
		var row: Array = Run.map_rows[Run.current_row]
		var marker := TextureRect.new()
		marker.texture = MARKER_TEX
		marker.custom_minimum_size = Vector2(44, 44)
		marker.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		marker.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		marker.size = Vector2(44, 44)
		var mpos := _node_pos(Run.current_row, Run.current_col, row.size()) + Vector2(-22, -64)
		marker.position = mpos
		marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$Nodes.add_child(marker)
		var tw := marker.create_tween().set_loops()
		tw.tween_property(marker, "position:y", mpos.y - 7.0, 0.7).set_trans(Tween.TRANS_SINE)
		tw.tween_property(marker, "position:y", mpos.y, 0.7).set_trans(Tween.TRANS_SINE)

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
		"event":
			_main().goto("event")

func _main() -> Node:
	return get_node("/root/Main")
