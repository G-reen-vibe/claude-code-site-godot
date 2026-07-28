extends Control
## Merchant: 5 cards (shown as real cards with price tags), 2 potions,
## 1 relic, and a card-removal service.

const CARD_SCENE := preload("res://scenes/Card.tscn")
const CARD_PICKER := preload("res://scenes/CardPicker.tscn")
const REMOVE_COST := 75

var card_offers: Array = []    # {"id", "price", "sold"}
var potion_offers: Array = []  # {"id", "price", "sold"}
var relic_offer: Dictionary = {}
var removed_used := false

func _ready() -> void:
	for id in CardsDB.random_rewards(Run.rng, Run.character, 5):
		var def := CardsDB.get_def({"id": id, "up": false})
		var price := 50
		match def.rarity:
			"common":
				price = Run.rng.randi_range(45, 55)
			"uncommon":
				price = Run.rng.randi_range(68, 82)
			"rare":
				price = Run.rng.randi_range(135, 160)
		card_offers.append({"id": id, "price": price, "sold": false})
		var box := VBoxContainer.new()
		box.add_theme_constant_override("separation", 6)
		var cu := CARD_SCENE.instantiate()
		cu.entry = {"id": id, "up": false}
		cu.hoverable = false
		box.add_child(cu)
		var b := Button.new()
		b.pressed.connect(_on_card_offer_pressed.bind(card_offers.size() - 1))
		box.add_child(b)
		$CardRow.add_child(box)
	for i in 2:
		var pid := PotionsDB.random_id(Run.rng)
		potion_offers.append({"id": pid, "price": Run.rng.randi_range(48, 58), "sold": false})
	var relic_id := RelicsDB.random_new(Run.rng, Run.relics)
	if relic_id != "":
		relic_offer = {"id": relic_id, "price": Run.rng.randi_range(140, 160), "sold": false}
	_refresh()

func _refresh() -> void:
	$Hud.refresh()
	for i in card_offers.size():
		var o: Dictionary = card_offers[i]
		var box: VBoxContainer = $CardRow.get_child(i)
		var b: Button = box.get_child(1)
		if o.sold:
			b.text = "SOLD"
			b.disabled = true
			box.get_child(0).modulate = Color(0.4, 0.4, 0.4)
		else:
			b.text = "%d gold" % o.price
			b.disabled = Run.gold < o.price
	for i in potion_offers.size():
		var o: Dictionary = potion_offers[i]
		var b: Button = $BottomRow.get_child(i)
		var pd: Dictionary = PotionsDB.POTIONS[o.id]
		if o.sold:
			b.text = "SOLD"
			b.disabled = true
		else:
			b.text = "%s — %dg" % [pd.name, o.price]
			b.tooltip_text = pd.text
			b.disabled = Run.gold < o.price or Run.potions.size() >= Run.MAX_POTIONS
	var rb: Button = $BottomRow/RelicButton
	if relic_offer.is_empty():
		rb.visible = false
	elif relic_offer.sold:
		rb.text = "SOLD"
		rb.disabled = true
	else:
		var rd: Dictionary = RelicsDB.RELICS[relic_offer.id]
		rb.text = "Relic: %s — %dg" % [rd.name, relic_offer.price]
		rb.tooltip_text = rd.text
		rb.disabled = Run.gold < relic_offer.price
	$BottomRow/RemoveButton.disabled = removed_used or Run.gold < REMOVE_COST or Run.deck.is_empty()
	if removed_used:
		$BottomRow/RemoveButton.text = "Removal used"

func _on_card_offer_pressed(i: int) -> void:
	var o: Dictionary = card_offers[i]
	if o.sold or Run.gold < o.price:
		return
	Run.gold -= o.price
	o.sold = true
	Run.deck.append({"id": o.id, "up": false})
	$MsgLabel.text = "Bought %s." % CardsDB.CARDS[o.id].name
	_refresh()

func _on_potion_offer_pressed(i: int) -> void:
	var o: Dictionary = potion_offers[i]
	if o.sold or Run.gold < o.price or not Run.add_potion(o.id):
		return
	Run.gold -= o.price
	o.sold = true
	$MsgLabel.text = "Bought %s." % PotionsDB.POTIONS[o.id].name
	_refresh()

func _on_relic_button_pressed() -> void:
	if relic_offer.is_empty() or relic_offer.sold or Run.gold < relic_offer.price:
		return
	Run.gold -= relic_offer.price
	relic_offer.sold = true
	Run.add_relic(relic_offer.id)
	$MsgLabel.text = "Bought %s." % RelicsDB.RELICS[relic_offer.id].name
	_refresh()

func _on_remove_button_pressed() -> void:
	var picker := CARD_PICKER.instantiate()
	add_child(picker)
	picker.open(Run.deck, "Pay %d gold to remove a card" % REMOVE_COST, true, CardsDB.removable)
	picker.picked.connect(func(idx: int) -> void:
		if Run.gold < REMOVE_COST:
			return
		Run.gold -= REMOVE_COST
		removed_used = true
		$MsgLabel.text = "Removed %s." % CardsDB.get_def(Run.deck[idx]).display_name
		Run.deck.remove_at(idx)
		_refresh())

func _on_leave_button_pressed() -> void:
	get_node("/root/Main").goto("map")
