extends Panel
## Visual enemy panel. Set `data` (the enemy dictionary, shared by reference
## with combat_screen.gd) before adding to the tree.

signal clicked(enemy_ui)

var data: Dictionary = {}

func _ready() -> void:
	refresh(0)

func refresh(player_vulnerable: int) -> void:
	if data.is_empty():
		return
	if data.hp <= 0:
		visible = false
		return
	$V/NameLabel.text = data.name
	$V/HPBar.max_value = data.max_hp
	$V/HPBar.value = data.hp
	$V/HPLabel.text = "%d/%d" % [data.hp, data.max_hp]
	$V/BlockLabel.text = "Block: %d" % data.block
	var parts: Array = []
	if data.strength != 0:
		parts.append("Str %d" % data.strength)
	if data.vulnerable > 0:
		parts.append("Vuln %d" % data.vulnerable)
	if data.weak > 0:
		parts.append("Weak %d" % data.weak)
	if data.ritual > 0:
		parts.append("Ritual %d" % data.ritual)
	$V/StatusLabel.text = " | ".join(PackedStringArray(parts))
	$V/IntentLabel.text = _intent_text(player_vulnerable)

func _intent_text(player_vulnerable: int) -> String:
	var it: Dictionary = data.intent
	var parts: Array = []
	if it.get("dmg", 0) > 0:
		var dmg: int = max(0, it.dmg + data.strength)
		if data.weak > 0:
			dmg = int(dmg * 0.75)
		if player_vulnerable > 0:
			dmg = int(dmg * 1.5)
		if it.get("hits", 1) > 1:
			parts.append("ATK %d x%d" % [dmg, it.hits])
		else:
			parts.append("ATK %d" % dmg)
	if it.get("block", 0) > 0:
		parts.append("BLK %d" % it.block)
	if it.get("strength", 0) > 0 or it.get("ritual", 0) > 0:
		parts.append("BUFF")
	if it.get("weak_p", 0) > 0 or it.get("vuln_p", 0) > 0 or it.get("str_down_p", 0) > 0:
		parts.append("DEBUFF")
	return "%s\n%s" % [it.get("label", "?"), " + ".join(PackedStringArray(parts))]

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)
