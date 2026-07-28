extends Control
## Shared top bar: HP, gold, floor, potion belt, relic icons, deck viewer.

signal potion_pressed(slot: int, right_click: bool)

const CARD_PICKER := preload("res://scenes/CardPicker.tscn")
const RELIC_TEX := preload("res://assets/icons/relic.svg")
const POTION_TEX := preload("res://assets/icons/potion.svg")

## When false (map & other screens), left-clicking a potion shows a hint.
var potions_usable := false

func _ready() -> void:
	refresh()

func refresh() -> void:
	$H/HPLabel.text = "%d/%d" % [Run.hp, Run.max_hp]
	$H/GoldLabel.text = str(Run.gold)
	$H/FloorLabel.text = "Floor %d/%d" % [Run.current_row + 1, Run.MAP_ROWS]
	for i in Run.MAX_POTIONS:
		var slot: TextureRect = $H/PotionBox.get_child(i)
		if i < Run.potions.size():
			var def: Dictionary = PotionsDB.POTIONS[Run.potions[i]]
			slot.texture = POTION_TEX
			slot.modulate = def.color
			slot.tooltip_text = "%s — %s%s" % [
				def.name, def.text,
				" (click to drink)" if potions_usable else " (usable in combat; right-click to toss)",
			]
		else:
			slot.texture = POTION_TEX
			slot.modulate = Color(1, 1, 1, 0.18)
			slot.tooltip_text = "Empty potion slot"
	var relic_box: HBoxContainer = $H/RelicBox
	while relic_box.get_child_count() > Run.relics.size():
		var c := relic_box.get_child(relic_box.get_child_count() - 1)
		relic_box.remove_child(c)
		c.queue_free()
	while relic_box.get_child_count() < Run.relics.size():
		var tr := TextureRect.new()
		tr.texture = RELIC_TEX
		tr.custom_minimum_size = Vector2(28, 28)
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		relic_box.add_child(tr)
	for i in Run.relics.size():
		var rd: Dictionary = RelicsDB.RELICS[Run.relics[i]]
		var tr: TextureRect = relic_box.get_child(i)
		tr.modulate = rd.color
		tr.tooltip_text = "%s — %s" % [rd.name, rd.text]

func _on_potion_input(event: InputEvent, slot: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if slot >= Run.potions.size():
			return
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			potion_pressed.emit(slot, event.button_index == MOUSE_BUTTON_RIGHT)

func _on_deck_button_pressed() -> void:
	var picker := CARD_PICKER.instantiate()
	get_parent().add_child(picker)
	picker.open(Run.deck, "Your Deck (%d cards)" % Run.deck.size(), false)
