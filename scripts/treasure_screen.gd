extends Control
## Treasure chest: grants a random relic you don't own yet (gold as fallback).

func _ready() -> void:
	var relic_id := RelicsDB.random_new(Run.rng, Run.relics)
	if relic_id == "":
		Run.gold += 35
		$ResultLabel.text = "The chest holds 35 gold!"
	else:
		Run.add_relic(relic_id)
		var rd: Dictionary = RelicsDB.RELICS[relic_id]
		$ResultLabel.text = "You found a relic: %s\n%s" % [rd.name, rd.text]

func _on_continue_button_pressed() -> void:
	get_node("/root/Main").goto("map")
