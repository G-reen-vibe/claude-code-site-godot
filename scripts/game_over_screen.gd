extends Control
## Shown on both defeat and victory (Run.victory decides which).

const ICON_WIN := preload("res://assets/icons/boss.svg")
const ICON_LOSE := preload("res://assets/icons/skull.svg")

func _ready() -> void:
	Run.delete_save()
	var char_name: String = Run.CHARACTERS[Run.character].name
	var score := Run.score()
	if Run.victory:
		var new_unlock := Run.record_victory()
		$Icon.texture = ICON_WIN
		$Title.text = "VICTORY!"
		$Title.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
		var text := "%s conquered the Spire on Ascension %d!\nFinal HP: %d/%d   ·   Gold: %d   ·   Deck: %d cards   ·   Relics: %d\nScore: %d" % [
			char_name, Run.ascension, Run.hp, Run.max_hp, Run.gold,
			Run.deck.size(), Run.relics.size(), score,
		]
		if new_unlock > 0:
			text += "\nAscension %d unlocked for %s!" % [new_unlock, char_name]
		$StatsLabel.text = text
	else:
		$Icon.texture = ICON_LOSE
		$Title.text = "DEFEAT"
		$Title.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
		$StatsLabel.text = "%s died in Act %d, floor %d (Ascension %d).\nGold: %d   ·   Deck: %d cards   ·   Relics: %d\nScore: %d" % [
			char_name, Run.act, Run.current_row + 1, Run.ascension,
			Run.gold, Run.deck.size(), Run.relics.size(), score,
		]

func _on_menu_button_pressed() -> void:
	get_node("/root/Main").goto("menu")
