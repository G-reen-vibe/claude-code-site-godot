extends Control
## Card combat: energy, block, statuses (Strength / Vulnerable / Weak),
## enemy intents, and the draw/discard/exhaust piles.
##
## Damage formula (matches Slay the Spire):
##   (base + strength) * 0.75 if attacker is Weak, then * 1.5 if target is
##   Vulnerable, rounded down. Block absorbs damage before HP.

signal combat_finished(victory: bool)

const CardScene := preload("res://scenes/Card.tscn")
const HAND_LIMIT := 10
const DEFAULT_HINT := "Click a card to play it. Right-click cancels targeting."

@onready var top_info: Label = $TopInfo
@onready var enemy_area: HBoxContainer = $EnemyArea
@onready var hint_label: Label = $HintLabel
@onready var energy_label: Label = $EnergyLabel
@onready var end_turn_button: Button = $EndTurnButton
@onready var piles_label: Label = $PilesLabel
@onready var hand_area: HBoxContainer = $HandArea
@onready var hp_bar: ProgressBar = $PlayerPanel/Margin/VBox/HPBar
@onready var hp_label: Label = $PlayerPanel/Margin/VBox/HPLabel
@onready var block_label: Label = $PlayerPanel/Margin/VBox/BlockLabel
@onready var status_label: Label = $PlayerPanel/Margin/VBox/StatusLabel

var draw_pile: Array = []
var discard_pile: Array = []
var exhaust_pile: Array = []
var hand: Array = []
var enemies: Array = []
var energy := 0
var max_energy := 3
var player_block := 0
var player_status := {}
var is_player_turn := false
var pending_card_index := -1
var finished := false
var encounter_kind := ""


func _ready() -> void:
	end_turn_button.pressed.connect(_on_end_turn)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_RIGHT:
		_cancel_targeting()


func start_combat(encounter: Array, kind: String) -> void:
	finished = false
	encounter_kind = kind
	is_player_turn = false
	pending_card_index = -1
	player_block = 0
	player_status = {}
	max_energy = 3
	draw_pile = Run.deck.duplicate()
	draw_pile.shuffle()
	discard_pile = []
	exhaust_pile = []
	hand = []
	top_info.text = "Floor %d  -  %s Fight" % [Run.current_row + 1, kind.capitalize()]

	for c in enemy_area.get_children():
		c.visible = false
		c.queue_free()
	enemies.clear()
	for id in encounter:
		var def: Dictionary = EnemyLibrary.ENEMIES[id]
		var e := {
			"id": id,
			"name": def["name"],
			"max_hp": randi_range(def["hp"][0], def["hp"][1]),
			"block": 0,
			"status": {},
			"turn": 0,
		}
		e["hp"] = e["max_hp"]
		e["move"] = _pick_move(e)
		_make_enemy_panel(e, def)
		enemies.append(e)

	_start_player_turn()


# --- Turn flow ---------------------------------------------------------------

func _start_player_turn() -> void:
	if finished:
		return
	player_block = 0
	energy = max_energy
	_draw_cards(5)
	is_player_turn = true
	hint_label.text = DEFAULT_HINT
	_refresh_all()


func _on_end_turn() -> void:
	if not is_player_turn or finished:
		return
	is_player_turn = false
	pending_card_index = -1
	discard_pile.append_array(hand)
	hand.clear()
	_tick_debuffs(player_status)
	hint_label.text = "Enemy turn..."
	_refresh_all()
	await _enemy_turns()


func _enemy_turns() -> void:
	for e in enemies:
		if finished:
			return
		if e["hp"] <= 0:
			continue
		e["block"] = 0
		e["ui"]["panel"].modulate = Color(1.35, 1.15, 1.15)
		await get_tree().create_timer(0.5).timeout
		_enemy_act(e)
		if is_instance_valid(e["ui"]["panel"]):
			e["ui"]["panel"].modulate = Color(1, 1, 1)
		_tick_debuffs(e["status"])
		_refresh_all()
		if finished:
			return
	await get_tree().create_timer(0.35).timeout
	_start_player_turn()


func _pick_move(e: Dictionary) -> Dictionary:
	var def: Dictionary = EnemyLibrary.ENEMIES[e["id"]]
	var moves: Array = def["moves"]
	match def["pattern"]:
		"cycle":
			return moves[e["turn"] % moves.size()]
		"random":
			return moves.pick_random()
		"opener_random":
			if e["turn"] == 0:
				return moves[0]
			return moves.slice(1).pick_random()
	return moves[0]


func _enemy_act(e: Dictionary) -> void:
	var move: Dictionary = e["move"]
	for eff in move["effects"]:
		match eff["kind"]:
			"damage":
				for i in eff.get("times", 1):
					var dmg := _calc_damage(
						eff["amount"],
						e["status"].get("strength", 0),
						e["status"].get("weak", 0) > 0,
						player_status.get("vulnerable", 0) > 0)
					_damage_player(dmg)
					if finished:
						return
			"block":
				e["block"] += eff["amount"]
			"status":
				if eff.get("on", "player") == "self":
					_apply_status(e["status"], eff["status"], eff["amount"])
				else:
					_apply_status(player_status, eff["status"], eff["amount"])
	e["turn"] += 1
	e["move"] = _pick_move(e)


# --- Playing cards -----------------------------------------------------------

func _on_card_clicked(idx: int) -> void:
	if not is_player_turn or finished or idx >= hand.size():
		return
	if pending_card_index == idx:
		_cancel_targeting()
		return
	var card: Dictionary = CardLibrary.CARDS[hand[idx]]
	if energy < card["cost"]:
		hint_label.text = "Not enough energy!"
		return
	if card["target"] == "enemy" and _living_enemies().size() > 1:
		pending_card_index = idx
		hint_label.text = "Choose a target - click an enemy."
		_refresh_enemies()
		return
	var target := {}
	if card["target"] == "enemy":
		var living := _living_enemies()
		if living.is_empty():
			return
		target = living[0]
	_play_card(idx, target)


func _on_enemy_input(event: InputEvent, e: Dictionary) -> void:
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and pending_card_index >= 0 and e["hp"] > 0:
		var idx := pending_card_index
		pending_card_index = -1
		_play_card(idx, e)


func _cancel_targeting() -> void:
	if pending_card_index >= 0:
		pending_card_index = -1
		hint_label.text = DEFAULT_HINT
		_refresh_enemies()


func _play_card(idx: int, target: Dictionary) -> void:
	pending_card_index = -1
	hint_label.text = DEFAULT_HINT
	var id: String = hand[idx]
	var card: Dictionary = CardLibrary.CARDS[id]
	energy -= card["cost"]
	hand.remove_at(idx)
	_execute_card(card, target)
	if finished:
		return
	if card.get("exhaust", false):
		exhaust_pile.append(id)
	else:
		discard_pile.append(id)
	_refresh_all()


func _execute_card(card: Dictionary, chosen: Dictionary) -> void:
	for eff in card["effects"]:
		match eff["kind"]:
			"damage":
				for i in eff.get("times", 1):
					for t in _card_targets(card, chosen):
						_attack_enemy(t, eff["amount"], eff.get("str_mult", 1))
						if finished:
							return
			"block":
				player_block += eff["amount"]
			"draw":
				_draw_cards(eff["amount"])
			"energy":
				energy += eff["amount"]
			"lose_hp":
				Run.player_hp -= eff["amount"]
				if Run.player_hp <= 0:
					Run.player_hp = 0
					_finish(false)
					return
			"status":
				if eff.get("on", "target") == "self":
					_apply_status(player_status, eff["status"], eff["amount"])
				else:
					for t in _card_targets(card, chosen):
						_apply_status(t["status"], eff["status"], eff["amount"])
			"add_card":
				discard_pile.append(eff["id"])


func _card_targets(card: Dictionary, chosen: Dictionary) -> Array:
	match card["target"]:
		"enemy":
			return [chosen] if (not chosen.is_empty() and chosen["hp"] > 0) else []
		"all_enemies":
			return _living_enemies()
		"random_enemy":
			var living := _living_enemies()
			return [living.pick_random()] if not living.is_empty() else []
	return []


# --- Damage / statuses / piles ----------------------------------------------

func _calc_damage(base: int, strength: int, attacker_weak: bool, target_vulnerable: bool) -> int:
	var dmg := float(base + strength)
	if attacker_weak:
		dmg *= 0.75
	if target_vulnerable:
		dmg *= 1.5
	return maxi(0, int(floor(dmg)))


func _attack_enemy(e: Dictionary, base: int, str_mult: int) -> void:
	var strength: int = int(player_status.get("strength", 0)) * str_mult
	var dmg := _calc_damage(
		base, strength,
		player_status.get("weak", 0) > 0,
		e["status"].get("vulnerable", 0) > 0)
	var blocked: int = mini(e["block"], dmg)
	e["block"] -= blocked
	e["hp"] -= dmg - blocked
	if e["hp"] <= 0:
		e["hp"] = 0
		if _living_enemies().is_empty():
			_finish(true)


func _damage_player(amount: int) -> void:
	var blocked: int = mini(player_block, amount)
	player_block -= blocked
	Run.player_hp -= amount - blocked
	if Run.player_hp <= 0:
		Run.player_hp = 0
		_finish(false)


func _apply_status(status: Dictionary, key: String, amount: int) -> void:
	status[key] = int(status.get(key, 0)) + amount


func _tick_debuffs(status: Dictionary) -> void:
	for key in ["vulnerable", "weak"]:
		if status.get(key, 0) > 0:
			status[key] -= 1


func _draw_cards(n: int) -> void:
	for i in n:
		if draw_pile.is_empty():
			if discard_pile.is_empty():
				break
			draw_pile = discard_pile.duplicate()
			draw_pile.shuffle()
			discard_pile.clear()
		if hand.size() >= HAND_LIMIT:
			break
		hand.append(draw_pile.pop_back())


func _living_enemies() -> Array:
	return enemies.filter(func(e): return e["hp"] > 0)


func _finish(victory: bool) -> void:
	if finished:
		return
	finished = true
	is_player_turn = false
	combat_finished.emit(victory)


# --- UI ----------------------------------------------------------------------

func _make_enemy_panel(e: Dictionary, def: Dictionary) -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(215, 200)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.gui_input.connect(_on_enemy_input.bind(e))
	enemy_area.add_child(panel)

	var vb := VBoxContainer.new()
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(vb)

	var intent := Label.new()
	intent.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intent.add_theme_font_size_override("font_size", 20)
	intent.add_theme_color_override("font_color", Color(1.0, 0.8, 0.5))

	var portrait := ColorRect.new()
	portrait.color = def["color"]
	portrait.custom_minimum_size = Vector2(100, 64)
	portrait.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	var name_l := Label.new()
	name_l.text = e["name"]
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_l.add_theme_font_size_override("font_size", 20)

	var bar := ProgressBar.new()
	bar.max_value = e["max_hp"]
	bar.value = e["hp"]
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 12)

	var hp_l := Label.new()
	hp_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var status_l := Label.new()
	status_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_l.add_theme_font_size_override("font_size", 14)

	for child in [intent, portrait, name_l, bar, hp_l, status_l]:
		child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vb.add_child(child)

	e["ui"] = {"panel": panel, "intent": intent, "bar": bar, "hp": hp_l, "status": status_l}


func _intent_text(e: Dictionary) -> String:
	var move: Dictionary = e["move"]
	match move["intent"]:
		"attack":
			var base := 0
			var times := 1
			for eff in move["effects"]:
				if eff["kind"] == "damage":
					base = eff["amount"]
					times = eff.get("times", 1)
			var dmg := _calc_damage(
				base,
				e["status"].get("strength", 0),
				e["status"].get("weak", 0) > 0,
				player_status.get("vulnerable", 0) > 0)
			if times > 1:
				return "Attack %d x%d" % [dmg, times]
			return "Attack %d" % dmg
		"defend":
			return "Defending"
		"buff":
			return "Buffing"
		"debuff":
			return "Debuffing"
	return "?"


func _status_text(status: Dictionary, block: int) -> String:
	var parts: Array[String] = []
	if block > 0:
		parts.append("Block %d" % block)
	if status.get("strength", 0) != 0:
		parts.append("Str %+d" % status["strength"])
	if status.get("vulnerable", 0) > 0:
		parts.append("Vuln %d" % status["vulnerable"])
	if status.get("weak", 0) > 0:
		parts.append("Weak %d" % status["weak"])
	return "  ".join(parts)


func _refresh_all() -> void:
	_refresh_player()
	_refresh_enemies()
	_refresh_hand()
	energy_label.text = "Energy %d/%d" % [energy, max_energy]
	piles_label.text = "Draw %d   Discard %d   Exhaust %d" % [
		draw_pile.size(), discard_pile.size(), exhaust_pile.size()]
	end_turn_button.disabled = not is_player_turn


func _refresh_player() -> void:
	hp_bar.max_value = Run.player_max_hp
	hp_bar.value = Run.player_hp
	hp_label.text = "HP %d/%d" % [Run.player_hp, Run.player_max_hp]
	block_label.text = "Block: %d" % player_block
	status_label.text = _status_text(player_status, 0)


func _refresh_enemies() -> void:
	for e in enemies:
		var ui: Dictionary = e["ui"]
		if not is_instance_valid(ui["panel"]):
			continue
		ui["panel"].visible = e["hp"] > 0
		if e["hp"] <= 0:
			continue
		ui["intent"].text = _intent_text(e)
		ui["bar"].value = e["hp"]
		ui["hp"].text = "HP %d/%d" % [e["hp"], e["max_hp"]]
		ui["status"].text = _status_text(e["status"], e["block"])
		if pending_card_index >= 0:
			ui["panel"].modulate = Color(1.0, 0.85, 0.55)
		elif is_player_turn:
			ui["panel"].modulate = Color(1, 1, 1)


func _refresh_hand() -> void:
	for c in hand_area.get_children():
		c.visible = false
		c.queue_free()
	for i in hand.size():
		var cu := CardScene.instantiate()
		hand_area.add_child(cu)
		cu.setup(hand[i], i)
		cu.card_clicked.connect(_on_card_clicked)
		var cost: int = CardLibrary.CARDS[hand[i]]["cost"]
		var playable := is_player_turn and energy >= cost
		cu.modulate = Color(1, 1, 1) if playable else Color(0.58, 0.58, 0.64)
