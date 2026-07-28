extends Control
## Post-combat rewards: gold (already granted), possible potion, a relic for
## elites, and a choice of 1 of 3 cards.

const CARD_SCENE := preload("res://scenes/Card.tscn")

func _ready() -> void:
	var reward: Dictionary = Run.pending_reward
	$Panel/V/GoldLabel.text = "You found %d gold." % reward.get("gold", 0)
	if reward.get("node_type", "") == "elite":
		var relic_id := RelicsDB.random_new(Run.rng, Run.relics)
		if relic_id != "":
			Run.add_relic(relic_id)
			var rd: Dictionary = RelicsDB.RELICS[relic_id]
			$Panel/V/RelicLabel.text = "Relic found: %s — %s" % [rd.name, rd.text]
		else:
			Run.gold += 40
			$Panel/V/RelicLabel.text = "No new relics to find — you got 40 extra gold."
	else:
		$Panel/V/RelicLabel.visible = false
	var potion_id: String = reward.get("potion", "")
	if potion_id != "":
		var pd: Dictionary = PotionsDB.POTIONS[potion_id]
		$Panel/V/PotionRow/PotionIcon.modulate = pd.color
		$Panel/V/PotionRow/PotionButton.text = "Take %s (%s)" % [pd.name, pd.text]
		$Panel/V/PotionRow/PotionButton.disabled = Run.potions.size() >= Run.MAX_POTIONS
		if Run.potions.size() >= Run.MAX_POTIONS:
			$Panel/V/PotionRow/PotionButton.text += " — belt full!"
	else:
		$Panel/V/PotionRow.visible = false
	for id in CardsDB.random_rewards(Run.rng, Run.character, 3):
		var cu := CARD_SCENE.instantiate()
		cu.entry = {"id": id, "up": false}
		$Panel/V/Cards.add_child(cu)
		cu.clicked.connect(_on_card_chosen)
	$Hud.refresh()

func _on_potion_button_pressed() -> void:
	var potion_id: String = Run.pending_reward.get("potion", "")
	if potion_id != "" and Run.add_potion(potion_id):
		Run.pending_reward.erase("potion")
		$Panel/V/PotionRow/PotionButton.text = "Taken!"
		$Panel/V/PotionRow/PotionButton.disabled = true
		$Hud.refresh()

func _on_card_chosen(card: Panel) -> void:
	Run.deck.append(card.entry.duplicate())
	_done()

func _on_skip_button_pressed() -> void:
	_done()

func _done() -> void:
	get_node("/root/Main").goto("map")
