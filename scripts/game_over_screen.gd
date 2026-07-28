extends Control
## Shown on both defeat and victory (Run.victory decides which).

const ICON_WIN := preload("res://assets/icons/boss.svg")
const ICON_LOSE := preload("res://assets/icons/skull.svg")

func _ready() -> void:
	if Run.victory:
		$Icon.texture = ICON_WIN
		$Title.text = "VICTORY!"
		$Title.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
		$StatsLabel.text = "You conquered the Spire!\nFinal HP: %d/%d   ·   Gold: %d   ·   Deck: %d cards   ·   Relics: %d" % [
			Run.hp, Run.max_hp, Run.gold, Run.deck.size(), Run.relics.size(),
		]
	else:
		$Icon.texture = ICON_LOSE
		$Title.text = "DEFEAT"
		$Title.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
		$StatsLabel.text = "You died on floor %d of %d.\nGold: %d   ·   Deck: %d cards   ·   Relics: %d" % [
			Run.current_row + 1, Run.MAP_ROWS, Run.gold, Run.deck.size(), Run.relics.size(),
		]

func _on_menu_button_pressed() -> void:
	get_node("/root/Main").goto("menu")
