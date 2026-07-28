extends Control
## Shown on both defeat and victory (Run.victory decides which).

func _ready() -> void:
	if Run.victory:
		$Title.text = "VICTORY!"
		$Title.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
		$StatsLabel.text = "You slew The Guardian and conquered the Spire!\nFinal HP: %d/%d — Gold: %d — Deck size: %d" % [
			Run.hp, Run.max_hp, Run.gold, Run.deck.size(),
		]
	else:
		$Title.text = "DEFEAT"
		$Title.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
		$StatsLabel.text = "You died on floor %d of %d.\nGold: %d — Deck size: %d" % [
			Run.current_row + 1, Run.MAP_ROWS, Run.gold, Run.deck.size(),
		]

func _on_menu_button_pressed() -> void:
	get_node("/root/Main").goto("menu")
