extends Control
## Rest site: heal 30% of Max HP, or upgrade one card.

const CARD_PICKER := preload("res://scenes/CardPicker.tscn")

func _ready() -> void:
	$Panel/V/RestButton.text = "Rest — heal %d HP" % int(Run.max_hp * 0.3)
	var has_upgradable := false
	for entry in Run.deck:
		if CardsDB.can_upgrade(entry):
			has_upgradable = true
			break
	$Panel/V/SmithButton.disabled = not has_upgradable
	if Run.relics.has("coffee_dripper"):
		$Panel/V/RestButton.disabled = true
		$Panel/V/RestButton.text = "Rest (blocked by Coffee Dripper)"
	if Run.relics.has("fusion_hammer"):
		$Panel/V/SmithButton.disabled = true
		$Panel/V/SmithButton.text = "Smith (blocked by Fusion Hammer)"

func _on_rest_button_pressed() -> void:
	Run.heal(int(Run.max_hp * 0.3))
	_finish("You rest by the fire and recover. HP: %d/%d" % [Run.hp, Run.max_hp])

func _on_smith_button_pressed() -> void:
	var picker := CARD_PICKER.instantiate()
	add_child(picker)
	picker.open(Run.deck, "Choose a card to upgrade", true, CardsDB.can_upgrade)
	picker.picked.connect(func(idx: int) -> void:
		Run.deck[idx].up = true
		_finish("Upgraded: %s" % CardsDB.get_def(Run.deck[idx]).display_name))

func _finish(result: String) -> void:
	$Panel/V/RestButton.visible = false
	$Panel/V/SmithButton.visible = false
	$Panel/V/Result.text = result
	$Panel/V/ContinueButton.visible = true
	$Hud.refresh()

func _on_continue_button_pressed() -> void:
	get_node("/root/Main").goto("map")
