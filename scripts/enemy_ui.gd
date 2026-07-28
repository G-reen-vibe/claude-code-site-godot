extends Control
## Visual enemy: sprite, intent icon + numbers, HP bar, block and statuses.
## Set `data` (the enemy dictionary, shared by reference with combat_screen.gd)
## before adding to the tree.

signal clicked(enemy_ui)

const ICON_ATTACK := preload("res://assets/icons/attack.svg")
const ICON_DEFEND := preload("res://assets/icons/defend.svg")
const ICON_BUFF := preload("res://assets/icons/buff.svg")
const ICON_DEBUFF := preload("res://assets/icons/debuff.svg")
const ICON_UNKNOWN := preload("res://assets/icons/unknown.svg")

var data: Dictionary = {}
var targeting := false
var dead := false

func _ready() -> void:
	if data.is_empty():
		return
	var side: int = data.get("size", 150)
	custom_minimum_size = Vector2(max(170, side + 16), 330)
	$V/SpriteBox.custom_minimum_size = Vector2(0, 214)
	$V/SpriteBox/Sprite.custom_minimum_size = Vector2(side, side)
	$V/SpriteBox/Sprite.texture = load(EnemiesDB.SPRITES[data.id])
	mouse_entered.connect(_on_hover.bind(true))
	mouse_exited.connect(_on_hover.bind(false))
	refresh(0)

func refresh(player_vulnerable: int) -> void:
	if data.is_empty() or dead:
		return
	if data.hp <= 0:
		_die()
		return
	$V/NameLabel.text = data.name
	$V/HPRow/HPBar.max_value = data.max_hp
	$V/HPRow/HPBar.value = data.hp
	$V/HPRow/HPBar/HPLabel.text = "%d/%d" % [data.hp, data.max_hp]
	$V/HPRow/BlockBox.visible = data.block > 0
	$V/HPRow/BlockBox/BlockLabel.text = str(data.block)
	$V/StatusLabel.text = _status_text()
	_refresh_intent(player_vulnerable)

func _status_text() -> String:
	var parts: Array = []
	if data.strength != 0:
		parts.append("Str %d" % data.strength)
	if data.vulnerable > 0:
		parts.append("Vuln %d" % data.vulnerable)
	if data.weak > 0:
		parts.append("Weak %d" % data.weak)
	if data.ritual > 0:
		parts.append("Ritual %d" % data.ritual)
	if data.thorns > 0:
		parts.append("Thorns %d" % data.thorns)
	if data.get("poison", 0) > 0:
		parts.append("Poison %d" % data.poison)
	return " · ".join(PackedStringArray(parts))

func _refresh_intent(player_vulnerable: int) -> void:
	if Run.relics.has("runic_dome"):
		$V/IntentBox/IntentIcon.texture = ICON_UNKNOWN
		$V/IntentBox/IntentNum.visible = false
		$V/IntentName.text = "???"
		tooltip_text = "Runic Dome hides enemy intents."
		return
	var it: Dictionary = data.intent
	var icon: Texture2D = ICON_UNKNOWN
	var txt := ""
	if it.get("dmg", 0) > 0:
		icon = ICON_ATTACK
		var dmg: int = max(0, it.dmg + data.strength)
		if data.weak > 0:
			dmg = int(dmg * 0.75)
		if player_vulnerable > 0:
			dmg = int(dmg * 1.5)
		txt = str(dmg) if it.get("hits", 1) <= 1 else "%dx%d" % [dmg, it.hits]
	elif it.get("block", 0) > 0 or it.get("thorns", 0) > 0:
		icon = ICON_DEFEND
	elif it.get("strength", 0) > 0 or it.get("ritual", 0) > 0:
		icon = ICON_BUFF
	elif it.get("weak_p", 0) > 0 or it.get("vuln_p", 0) > 0 or it.get("frail_p", 0) > 0 \
			or it.get("str_down_p", 0) > 0 or not it.get("add_card", {}).is_empty():
		icon = ICON_DEBUFF
	$V/IntentBox/IntentIcon.texture = icon
	$V/IntentBox/IntentNum.text = txt
	$V/IntentBox/IntentNum.visible = txt != ""
	$V/IntentName.text = it.get("label", "")
	var hint: Array = []
	if it.get("block", 0) > 0:
		hint.append("gains %d Block" % it.block)
	if it.get("strength", 0) > 0:
		hint.append("gains %d Strength" % it.strength)
	if it.get("ritual", 0) > 0:
		hint.append("starts a ritual")
	if it.get("weak_p", 0) > 0:
		hint.append("applies %d Weak" % it.weak_p)
	if it.get("vuln_p", 0) > 0:
		hint.append("applies %d Vulnerable" % it.vuln_p)
	if it.get("frail_p", 0) > 0:
		hint.append("applies %d Frail" % it.frail_p)
	if it.get("str_down_p", 0) > 0:
		hint.append("saps your Strength")
	if not it.get("add_card", {}).is_empty():
		hint.append("adds %d %s to your discard" % [it.add_card.count, String(it.add_card.id).capitalize()])
	tooltip_text = it.get("label", "") + ("" if hint.is_empty() else ": " + ", ".join(PackedStringArray(hint)))

func set_targeting(v: bool) -> void:
	targeting = v
	if not v:
		$V/SpriteBox/Sprite.modulate = Color.WHITE

func _on_hover(entering: bool) -> void:
	if dead:
		return
	if targeting:
		$V/SpriteBox/Sprite.modulate = Color(1.35, 1.2, 0.85) if entering else Color(1.15, 1.1, 0.95)
	elif entering:
		$V/SpriteBox/Sprite.modulate = Color(1.08, 1.08, 1.08)
	else:
		$V/SpriteBox/Sprite.modulate = Color.WHITE

func play_hit(amount: int) -> void:
	var sprite: TextureRect = $V/SpriteBox/Sprite
	FloatText.spawn(self, sprite.global_position + sprite.size / 2.0, str(amount), Color(1, 0.35, 0.3), 30)
	var tw := create_tween()
	tw.tween_property(sprite, "modulate", Color(1, 0.25, 0.25), 0.06)
	tw.tween_property(sprite, "position:x", sprite.position.x + 10.0, 0.05)
	tw.tween_property(sprite, "position:x", sprite.position.x - 8.0, 0.07)
	tw.tween_property(sprite, "position:x", sprite.position.x, 0.05)
	tw.tween_property(sprite, "modulate", Color.WHITE, 0.15)

func play_blocked() -> void:
	var sprite: TextureRect = $V/SpriteBox/Sprite
	FloatText.spawn(self, sprite.global_position + sprite.size / 2.0, "Blocked", Color(0.6, 0.8, 1), 20)

func play_poison(amount: int) -> void:
	var sprite: TextureRect = $V/SpriteBox/Sprite
	FloatText.spawn(self, sprite.global_position + sprite.size / 2.0, "%d Poison" % amount, Color(0.6, 0.95, 0.4), 24)

func play_reborn() -> void:
	var sprite: TextureRect = $V/SpriteBox/Sprite
	FloatText.spawn(self, sprite.global_position + sprite.size / 2.0, "REBORN!", Color(0.95, 0.3, 0.45), 32)
	var tw := create_tween()
	tw.tween_property(sprite, "modulate", Color(1.6, 0.6, 0.7), 0.25)
	tw.tween_property(sprite, "modulate", Color.WHITE, 0.4)

func play_lunge() -> void:
	var sprite: TextureRect = $V/SpriteBox/Sprite
	var tw := create_tween().set_trans(Tween.TRANS_QUAD)
	tw.tween_property(sprite, "position:x", sprite.position.x - 26.0, 0.12).set_ease(Tween.EASE_OUT)
	tw.tween_property(sprite, "position:x", sprite.position.x, 0.2).set_ease(Tween.EASE_IN_OUT)

func _die() -> void:
	if dead:
		return
	dead = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.45).set_trans(Tween.TRANS_QUAD)
	tw.tween_callback(hide)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)
