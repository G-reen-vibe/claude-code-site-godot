extends Control
## Rest site: heal 30% of Max HP, or upgrade one card.

func _ready() -> void:
	$RestButton.text = "Rest — heal %d HP" % int(Run.max_hp * 0.3)
	$HPLabel.text = "HP: %d/%d" % [Run.hp, Run.max_hp]
	$SmithButton.disabled = _upgradable().is_empty()

func _upgradable() -> Array:
	var out: Array = []
	for i in Run.deck.size():
		if not Run.deck[i].up:
			out.append(i)
	return out

func _on_rest_button_pressed() -> void:
	Run.heal(int(Run.max_hp * 0.3))
	$ResultLabel.text = "You rest by the fire and recover."
	_finish_choice()

func _on_smith_button_pressed() -> void:
	$RestButton.visible = false
	$SmithButton.visible = false
	var list: ItemList = $UpgradeList
	list.clear()
	for i in _upgradable():
		list.add_item(CardsDB.describe(Run.deck[i]))
		list.set_item_metadata(list.item_count - 1, i)
	list.visible = true
	$ConfirmButton.visible = true

func _on_confirm_button_pressed() -> void:
	var sel = $UpgradeList.get_selected_items()
	if sel.is_empty():
		return
	var deck_idx: int = $UpgradeList.get_item_metadata(sel[0])
	Run.deck[deck_idx].up = true
	$ResultLabel.text = "Upgraded: %s" % CardsDB.get_def(Run.deck[deck_idx]).display_name
	$UpgradeList.visible = false
	$ConfirmButton.visible = false
	_finish_choice()

func _finish_choice() -> void:
	$RestButton.visible = false
	$SmithButton.visible = false
	$ContinueButton.visible = true
	$HPLabel.text = "HP: %d/%d" % [Run.hp, Run.max_hp]

func _on_continue_button_pressed() -> void:
	get_node("/root/Main").goto("map")
