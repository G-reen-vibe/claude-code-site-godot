extends Control
## Turn-based card combat. Reads Run.pending_encounter / Run.pending_node_type.

const CARD_SCENE := preload("res://scenes/Card.tscn")
const ENEMY_SCENE := preload("res://scenes/Enemy.tscn")
const DEFAULT_PROMPT := "Your turn. Play cards, then press End Turn."

var enemies: Array = []
var enemy_uis: Array = []
var draw_pile: Array = []
var discard_pile: Array = []
var exhaust_pile: Array = []
var hand: Array = []

var block := 0
var energy := 0
var energy_cap := 3
var turn := 0
var strength := 0
var strength_down := 0
var vulnerable := 0
var weak := 0
var metallicize := 0
var demon_form := 0
var thorns := 0

var selected_card: Panel = null
var busy := true
var combat_over := false
var node_type := "monster"

func _ready() -> void:
	node_type = Run.pending_node_type
	for id in Run.pending_encounter:
		var e := EnemiesDB.make(id, Run.rng)
		e.intent = EnemiesDB.choose_intent(e, Run.rng)
		enemies.append(e)
		var ui := ENEMY_SCENE.instantiate()
		ui.data = e
		$Enemies.add_child(ui)
		ui.clicked.connect(_on_enemy_clicked)
		enemy_uis.append(ui)
	for entry in Run.deck:
		draw_pile.append(entry.duplicate())
	Run.shuffle_array(draw_pile)
	if Run.relics.has("vajra"):
		strength += 1
	if Run.relics.has("bronze_scales"):
		thorns = 3
	if Run.relics.has("bag_of_marbles"):
		for e in enemies:
			e.vulnerable += 1
	_start_player_turn()

func _start_player_turn() -> void:
	turn += 1
	block = 0
	if turn == 1 and Run.relics.has("anchor"):
		block = 10
	energy = energy_cap + (1 if turn == 1 and Run.relics.has("lantern") else 0)
	if demon_form > 0:
		strength += demon_form
	_draw_cards(5)
	busy = false
	_set_prompt(DEFAULT_PROMPT)
	_update_ui()

func _draw_cards(n: int) -> void:
	for i in n:
		if hand.size() >= 10:
			break
		if draw_pile.is_empty():
			if discard_pile.is_empty():
				break
			draw_pile = discard_pile
			discard_pile = []
			Run.shuffle_array(draw_pile)
		var entry: Dictionary = draw_pile.pop_back()
		var cu := CARD_SCENE.instantiate()
		cu.entry = entry
		$Hand.add_child(cu)
		cu.clicked.connect(_on_card_clicked)
		hand.append(cu)

func _set_prompt(t: String) -> void:
	$Prompt.text = t

func _alive() -> Array:
	var out: Array = []
	for i in enemies.size():
		if enemies[i].hp > 0:
			out.append(i)
	return out

func _on_card_clicked(card: Panel) -> void:
	if busy or combat_over:
		return
	if selected_card == card:
		_deselect()
		return
	_deselect()
	var def := CardsDB.get_def(card.entry)
	if def.cost > energy:
		_set_prompt("Not enough energy for %s." % def.display_name)
		return
	if def.target == "enemy":
		var alive := _alive()
		if alive.size() == 1:
			_play(card, alive[0])
		else:
			selected_card = card
			card.set_selected(true)
			_set_prompt("Choose a target for %s." % def.display_name)
	else:
		_play(card, -1)

func _deselect() -> void:
	if selected_card and is_instance_valid(selected_card):
		selected_card.set_selected(false)
	selected_card = null
	_set_prompt(DEFAULT_PROMPT)

func _on_enemy_clicked(ui: Panel) -> void:
	if busy or combat_over or selected_card == null:
		return
	var idx := enemy_uis.find(ui)
	if idx < 0 or enemies[idx].hp <= 0:
		return
	var card := selected_card
	selected_card = null
	card.set_selected(false)
	_play(card, idx)

func _play(card: Panel, target_idx: int) -> void:
	var entry: Dictionary = card.entry
	var def := CardsDB.get_def(entry)
	energy -= def.cost
	hand.erase(card)
	card.queue_free()
	_apply_card(def, entry, target_idx)
	if not combat_over:
		if def.type == "power":
			pass  # Powers are consumed when played.
		elif def.get("exhaust", false):
			exhaust_pile.append(entry)
		else:
			discard_pile.append(entry)
		_set_prompt(DEFAULT_PROMPT)
	_update_ui()
	_check_victory()

func _apply_card(def: Dictionary, entry: Dictionary, target_idx: int) -> void:
	if def.get("self_damage", 0) > 0:
		Run.lose_hp(def.self_damage)
		if Run.hp <= 0:
			_lose()
			return
	energy += def.get("energy", 0)
	strength += def.get("strength", 0)
	strength_down += def.get("strength_down", 0)
	metallicize += def.get("metallicize", 0)
	demon_form += def.get("demon_form", 0)
	block += def.get("block", 0)
	var targets: Array = []
	if def.target == "enemy" and target_idx >= 0:
		targets = [target_idx]
	elif def.target == "all":
		targets = _alive()
	if def.get("damage", 0) > 0:
		for h in def.get("hits", 1):
			for ti in targets:
				if enemies[ti].hp <= 0:
					continue
				var dmg: int = max(0, def.damage + strength)
				if weak > 0:
					dmg = int(dmg * 0.75)
				if enemies[ti].vulnerable > 0:
					dmg = int(dmg * 1.5)
				var unblocked := _damage_enemy(ti, dmg)
				if def.get("heal_from_damage", false):
					Run.heal(unblocked)
	for ti in targets:
		if enemies[ti].hp <= 0:
			continue
		enemies[ti].vulnerable += def.get("vulnerable", 0)
		enemies[ti].weak += def.get("weak", 0)
	if def.get("draw", 0) > 0:
		_draw_cards(def.draw)
	if def.get("copy_to_discard", false):
		discard_pile.append(entry.duplicate())

func _damage_enemy(idx: int, dmg: int) -> int:
	var e: Dictionary = enemies[idx]
	var blocked: int = min(e.block, dmg)
	e.block -= blocked
	var unblocked: int = dmg - blocked
	e.hp = max(0, e.hp - unblocked)
	return unblocked

func _check_victory() -> void:
	if combat_over:
		return
	if _alive().is_empty():
		_win()

func _win() -> void:
	if combat_over:
		return
	combat_over = true
	busy = true
	if Run.relics.has("burning_blood"):
		Run.heal(6)
	var gold_gain := 0
	match node_type:
		"monster":
			gold_gain = 12 + Run.current_row + Run.rng.randi_range(0, 8)
		"elite":
			gold_gain = 30 + Run.current_row + Run.rng.randi_range(0, 10)
	Run.gold += gold_gain
	Run.pending_reward = {"gold": gold_gain, "node_type": node_type}
	if node_type == "boss":
		Run.victory = true
		_main().goto("game_over")
	else:
		_main().goto("reward")

func _lose() -> void:
	if combat_over:
		return
	combat_over = true
	busy = true
	Run.victory = false
	_main().goto("game_over")

func _main() -> Node:
	return get_node("/root/Main")

func _on_end_turn_pressed() -> void:
	if busy or combat_over:
		return
	busy = true
	_deselect()
	_set_prompt("Enemy turn...")
	if strength_down > 0:
		strength -= strength_down
		strength_down = 0
	if metallicize > 0:
		block += metallicize
	if Run.relics.has("orichalcum") and block == 0:
		block += 6
	for c in hand:
		discard_pile.append(c.entry)
		c.queue_free()
	hand.clear()
	_update_ui()
	await get_tree().create_timer(0.5).timeout
	for i in enemies.size():
		if combat_over:
			break
		if enemies[i].hp <= 0:
			continue
		_enemy_act(i)
		_update_ui()
		if combat_over:
			break
		await get_tree().create_timer(0.6).timeout
	if combat_over:
		return
	if vulnerable > 0:
		vulnerable -= 1
	if weak > 0:
		weak -= 1
	_start_player_turn()

func _enemy_act(idx: int) -> void:
	var e: Dictionary = enemies[idx]
	e.block = 0
	var it: Dictionary = e.intent
	e.block += it.get("block", 0)
	e.strength += it.get("strength", 0)
	e.ritual += it.get("ritual", 0)
	if it.get("dmg", 0) > 0:
		for h in it.get("hits", 1):
			if e.hp <= 0:
				break
			var dmg: int = max(0, it.dmg + e.strength)
			if e.weak > 0:
				dmg = int(dmg * 0.75)
			if vulnerable > 0:
				dmg = int(dmg * 1.5)
			var blocked: int = min(block, dmg)
			block -= blocked
			Run.lose_hp(dmg - blocked)
			if thorns > 0:
				_damage_enemy(idx, thorns)
			if Run.hp <= 0:
				_lose()
				return
	weak += it.get("weak_p", 0)
	vulnerable += it.get("vuln_p", 0)
	strength -= it.get("str_down_p", 0)
	if e.ritual > 0:
		e.strength += e.ritual
	if e.vulnerable > 0:
		e.vulnerable -= 1
	if e.weak > 0:
		e.weak -= 1
	e.turn += 1
	e.intent = EnemiesDB.choose_intent(e, Run.rng)
	if _alive().is_empty():
		_win()

func _player_status_text() -> String:
	var parts: Array = []
	if strength != 0:
		parts.append("Strength %d" % strength)
	if vulnerable > 0:
		parts.append("Vulnerable %d" % vulnerable)
	if weak > 0:
		parts.append("Weak %d" % weak)
	if metallicize > 0:
		parts.append("Metallicize %d" % metallicize)
	if demon_form > 0:
		parts.append("Demon Form %d" % demon_form)
	if thorns > 0:
		parts.append("Thorns %d" % thorns)
	if parts.is_empty():
		return "-"
	return " | ".join(PackedStringArray(parts))

func _update_ui() -> void:
	$TopBar/HPLabel.text = "HP %d/%d" % [Run.hp, Run.max_hp]
	$TopBar/GoldLabel.text = "Gold: %d" % Run.gold
	$TopBar/FloorLabel.text = "Floor %d/%d" % [Run.current_row + 1, Run.MAP_ROWS]
	$TopBar/PilesLabel.text = "Draw %d | Discard %d | Exhaust %d" % [
		draw_pile.size(), discard_pile.size(), exhaust_pile.size(),
	]
	$TopBar/RelicsLabel.text = "Relics: " + Run.relic_names()
	$PlayerPanel/V/HPBar.max_value = Run.max_hp
	$PlayerPanel/V/HPBar.value = Run.hp
	$PlayerPanel/V/HPLabel.text = "%d/%d" % [Run.hp, Run.max_hp]
	$PlayerPanel/V/BlockLabel.text = "Block: %d" % block
	$PlayerPanel/V/StatusLabel.text = _player_status_text()
	$EnergyPanel/EnergyLabel.text = "%d/%d" % [energy, energy_cap]
	$EndTurnButton.disabled = busy or combat_over
	for ui in enemy_uis:
		ui.refresh(vulnerable)
	for c in hand:
		var def := CardsDB.get_def(c.entry)
		c.set_affordable(def.cost <= energy)
