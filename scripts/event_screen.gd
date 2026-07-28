extends Control
## "?" map nodes: a random narrative event with choices.

const CARD_PICKER := preload("res://scenes/CardPicker.tscn")

var event: Dictionary = {}

func _ready() -> void:
	var events: Array = [
		{
			"title": "Golden Idol",
			"desc": "A gleaming idol rests on a pedestal. It is obviously a trap — but so much gold...",
			"choices": [
				{"label": "Take it (gain 250 Gold, gain an Injury curse)", "fn": _golden_take},
				{"label": "Leave it be", "fn": _leave},
			],
		},
		{
			"title": "Bonfire Spirits",
			"desc": "Playful spirits circle a purple bonfire. They hunger for an offering from your deck.",
			"choices": [
				{"label": "Offer a card (remove it, heal 12 HP)", "fn": _bonfire_offer},
				{"label": "Decline", "fn": _leave},
			],
		},
		{
			"title": "The Shrine",
			"desc": "An ancient whetstone shrine hums with power. Steel sharpened here never dulls.",
			"choices": [
				{"label": "Sharpen (upgrade a card)", "fn": _shrine_upgrade},
				{"label": "Move on", "fn": _leave},
			],
		},
		{
			"title": "Purification Fountain",
			"desc": "Crystal water flows from a stone maw. Sins may be washed away here.",
			"choices": [
				{"label": "Bathe (remove a card from your deck)", "fn": _fountain_remove},
				{"label": "Move on", "fn": _leave},
			],
		},
		{
			"title": "Winged Statue",
			"desc": "A statue of a forgotten god demands tribute in blood.",
			"choices": [
				{"label": "Pray (lose 7 HP, gain 7 Max HP)", "fn": _statue_pray},
				{"label": "Refuse", "fn": _leave},
			],
		},
		{
			"title": "Transmogrifier",
			"desc": "A shimmering pool of chaotic energy. Whatever enters comes out... different.",
			"choices": [
				{"label": "Dip a card (transform it into a random card)", "fn": _transmogrify},
				{"label": "Keep your distance", "fn": _leave},
			],
		},
		{
			"title": "Big Fish",
			"desc": "An enormous fish floats before you, whispering promises through the murk.",
			"choices": [
				{"label": "Eat the banana (heal a third of your Max HP)", "fn": _fish_heal},
				{"label": "Eat the donut (gain 5 Max HP)", "fn": _fish_maxhp},
				{"label": "Open the box (random relic, gain an Injury curse)", "fn": _fish_relic},
			],
		},
	]
	event = events[Run.rng.randi_range(0, events.size() - 1)]
	$Panel/V/Title.text = event.title
	$Panel/V/Desc.text = event.desc
	for choice in event.choices:
		var b := Button.new()
		b.text = choice.label
		b.pressed.connect(choice.fn)
		$Panel/V/Choices.add_child(b)

func _finish(result: String) -> void:
	$Panel/V/Choices.visible = false
	$Panel/V/Result.text = result
	$Panel/V/ContinueButton.visible = true
	$Hud.refresh()

func _leave() -> void:
	_finish("You continue on your way.")

func _golden_take() -> void:
	Run.gold += 250
	Run.deck.append({"id": "injury", "up": false})
	_finish("You pocket the idol. 250 gold richer — but something aches deep inside. (Injury added to your deck)")

func _bonfire_offer() -> void:
	_pick_card("Offer a card to the spirits", func(idx: int) -> void:
		var card_name: String = CardsDB.get_def(Run.deck[idx]).display_name
		Run.deck.remove_at(idx)
		Run.heal(12)
		_finish("The spirits consume %s and warmth fills you. You heal 12 HP." % card_name))

func _shrine_upgrade() -> void:
	_pick_card("Choose a card to upgrade", func(idx: int) -> void:
		Run.deck[idx].up = true
		_finish("Upgraded: %s" % CardsDB.get_def(Run.deck[idx]).display_name),
		CardsDB.can_upgrade)

func _fountain_remove() -> void:
	_pick_card("Choose a card to remove", func(idx: int) -> void:
		var card_name: String = CardsDB.get_def(Run.deck[idx]).display_name
		Run.deck.remove_at(idx)
		_finish("%s dissolves in the water." % card_name))

func _statue_pray() -> void:
	Run.lose_hp(7)
	Run.max_hp += 7
	if Run.hp <= 0:
		Run.hp = 1
	_finish("Blood for stone. Your Max HP rises by 7.")

func _transmogrify() -> void:
	_pick_card("Choose a card to transform", func(idx: int) -> void:
		var old: String = CardsDB.get_def(Run.deck[idx]).display_name
		Run.deck.remove_at(idx)
		var new_id := CardsDB.random_of_pool(Run.rng)
		Run.deck.append({"id": new_id, "up": false})
		_finish("%s twists and reforms into %s!" % [old, CardsDB.CARDS[new_id].name]))

func _fish_heal() -> void:
	Run.heal(int(Run.max_hp / 3.0))
	_finish("Delicious. You heal %d HP." % int(Run.max_hp / 3.0))

func _fish_maxhp() -> void:
	Run.max_hp += 5
	Run.hp += 5
	_finish("Sugary power! Your Max HP rises by 5.")

func _fish_relic() -> void:
	Run.deck.append({"id": "injury", "up": false})
	var id := RelicsDB.random_new(Run.rng, Run.relics)
	if id != "":
		Run.add_relic(id)
		_finish("Inside: %s! But the lid slams on your fingers. (Injury added to your deck)" % RelicsDB.RELICS[id].name)
	else:
		Run.gold += 75
		_finish("Inside: 75 gold! But the lid slams on your fingers. (Injury added to your deck)")

func _pick_card(title: String, on_pick: Callable, filter: Callable = Callable()) -> void:
	var picker := CARD_PICKER.instantiate()
	add_child(picker)
	picker.open(Run.deck, title, true, filter)
	picker.picked.connect(on_pick)

func _on_continue_button_pressed() -> void:
	get_node("/root/Main").goto("map")
