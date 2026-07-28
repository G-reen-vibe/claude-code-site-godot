extends Control
## Shop: buy up to 5 random cards, or pay 75 gold to remove a card from your deck.

const REMOVE_COST := 75

var offers: Array = []  # {"id": String, "price": int, "sold": bool}

func _ready() -> void:
	for id in CardsDB.random_rewards(Run.rng, 5):
		var def := CardsDB.get_def({"id": id, "up": false})
		var price := 50
		match def.rarity:
			"common":
				price = Run.rng.randi_range(45, 55)
			"uncommon":
				price = Run.rng.randi_range(68, 82)
			"rare":
				price = Run.rng.randi_range(135, 160)
		offers.append({"id": id, "price": price, "sold": false})
		var b := Button.new()
		b.custom_minimum_size = Vector2(0, 44)
		b.clip_text = true
		b.pressed.connect(_on_offer_pressed.bind(offers.size() - 1))
		$Offers.add_child(b)
	_refresh()

func _refresh() -> void:
	$GoldLabel.text = "Gold: %d" % Run.gold
	for i in offers.size():
		var o: Dictionary = offers[i]
		var b: Button = $Offers.get_child(i)
		if o.sold:
			b.text = "SOLD"
			b.disabled = true
		else:
			var def := CardsDB.get_def({"id": o.id, "up": false})
			b.text = "%s [%s, %d] — %dg : %s" % [
				def.display_name, String(def.type).capitalize(), def.cost, o.price, def.text,
			]
			b.tooltip_text = b.text
			b.disabled = Run.gold < o.price
	$RemoveButton.disabled = Run.gold < REMOVE_COST or Run.deck.is_empty()

func _on_offer_pressed(i: int) -> void:
	var o: Dictionary = offers[i]
	if o.sold or Run.gold < o.price:
		return
	Run.gold -= o.price
	o.sold = true
	Run.deck.append({"id": o.id, "up": false})
	$MsgLabel.text = "Bought %s." % CardsDB.get_def({"id": o.id, "up": false}).display_name
	_refresh()

func _on_remove_button_pressed() -> void:
	var list: ItemList = $RemoveList
	list.clear()
	for entry in Run.deck:
		list.add_item(CardsDB.describe(entry))
	list.visible = true
	$ConfirmRemoveButton.visible = true

func _on_confirm_remove_button_pressed() -> void:
	var sel = $RemoveList.get_selected_items()
	if sel.is_empty() or Run.gold < REMOVE_COST:
		return
	Run.gold -= REMOVE_COST
	$MsgLabel.text = "Removed %s." % CardsDB.get_def(Run.deck[sel[0]]).display_name
	Run.deck.remove_at(sel[0])
	$RemoveList.visible = false
	$ConfirmRemoveButton.visible = false
	_refresh()

func _on_leave_button_pressed() -> void:
	get_node("/root/Main").goto("map")
