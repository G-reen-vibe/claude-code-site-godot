extends Control
## Post-combat rewards: gold (already granted), a relic for elites,
## and a choice of 1 of 3 cards.

const CARD_SCENE := preload("res://scenes/Card.tscn")

func _ready() -> void:
	var reward: Dictionary = Run.pending_reward
	$GoldLabel.text = "You found %d gold." % reward.get("gold", 0)
	if reward.get("node_type", "") == "elite":
		var relic_id := RelicsDB.random_new(Run.rng, Run.relics)
		if relic_id != "":
			Run.add_relic(relic_id)
			var rd: Dictionary = RelicsDB.RELICS[relic_id]
			$RelicLabel.text = "Relic found: %s — %s" % [rd.name, rd.text]
		else:
			Run.gold += 40
			$RelicLabel.text = "No new relics to find — you got 40 extra gold."
	else:
		$RelicLabel.text = ""
	for id in CardsDB.random_rewards(Run.rng, 3):
		var cu := CARD_SCENE.instantiate()
		cu.entry = {"id": id, "up": false}
		$Cards.add_child(cu)
		cu.clicked.connect(_on_card_chosen)

func _on_card_chosen(card: Panel) -> void:
	Run.deck.append(card.entry.duplicate())
	_done()

func _on_skip_button_pressed() -> void:
	_done()

func _done() -> void:
	get_node("/root/Main").goto("map")
