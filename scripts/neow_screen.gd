extends Control
## Neow's Blessing: pick one boon before the climb begins.

const CARD_PICKER := preload("res://scenes/CardPicker.tscn")

func _on_max_hp_pressed() -> void:
	Run.max_hp += 8
	Run.hp += 8
	_done()

func _on_gold_pressed() -> void:
	Run.gold += 100
	_done()

func _on_relic_pressed() -> void:
	var id := RelicsDB.random_new(Run.rng, Run.relics)
	if id != "":
		Run.add_relic(id)
	else:
		Run.gold += 100
	_done()

func _on_remove_pressed() -> void:
	var picker := CARD_PICKER.instantiate()
	add_child(picker)
	picker.open(Run.deck, "Choose a card to remove", true)
	picker.picked.connect(func(idx: int) -> void:
		Run.deck.remove_at(idx)
		_done())

func _done() -> void:
	get_node("/root/Main").goto("map")
