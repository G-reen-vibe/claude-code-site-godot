extends Control
## Turn-based card combat. Reads Run.pending_encounter / Run.pending_node_type.

const CARD_SCENE := preload("res://scenes/Card.tscn")
const ENEMY_SCENE := preload("res://scenes/Enemy.tscn")
const CARD_PICKER := preload("res://scenes/CardPicker.tscn")
const DEFAULT_PROMPT := "Play cards, then press End Turn."

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
var dexterity := 0
var vulnerable := 0
var weak := 0
var frail := 0
var metallicize := 0
var demon_form := 0
var thorns := 0
var feel_no_pain := 0
var dark_embrace := 0
var noxious_fumes := 0
var thousand_cuts := 0
var after_image := 0
var next_turn_block := 0
var cleaning_up := false

var selected_card: Panel = null
var pending_potion := -1
var busy := true
var combat_over := false
var node_type := "monster"

func _ready() -> void:
	node_type = Run.pending_node_type
	energy_cap = 3 + RelicsDB.energy_bonus(Run.relics)
	$Hud.potions_usable = true
	$Hud.potion_pressed.connect(_on_potion_pressed)
	for id in Run.pending_encounter:
		var e := EnemiesDB.make(id, Run.rng)
		if id == "sentry":
			e.extra["offset"] = enemies.size()
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
	if Run.relics.has("blood_vial"):
		Run.heal(2)
	if Run.relics.has("bag_of_marbles"):
		for e in enemies:
			e.vulnerable += 1
	if Run.relics.has("philosophers_stone"):
		for e in enemies:
			e.strength += 1
	_start_player_turn()

func _start_player_turn() -> void:
	turn += 1
	block = 0
	if turn == 1 and Run.relics.has("anchor"):
		block = 10
	if next_turn_block > 0:
		block += next_turn_block
		$Player.play_block_gain(next_turn_block)
		next_turn_block = 0
	energy = energy_cap + (1 if turn == 1 and Run.relics.has("lantern") else 0)
	if demon_form > 0:
		strength += demon_form
	if noxious_fumes > 0:
		for i in _alive():
			enemies[i].poison += noxious_fumes
	var draws := 5
	if turn == 1 and Run.relics.has("ring_of_snake"):
		draws += 2
	_draw_cards(draws)
	busy = false
	_set_prompt(DEFAULT_PROMPT)
	_show_banner("YOUR TURN")
	_update_ui()

func _show_banner(text: String) -> void:
	var banner: Label = $TurnBanner
	banner.text = text
	banner.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(banner, "modulate:a", 1.0, 0.18)
	tw.tween_interval(0.55)
	tw.tween_property(banner, "modulate:a", 0.0, 0.3)

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
		_add_to_hand(draw_pile.pop_back())

func _add_to_hand(entry: Dictionary) -> void:
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

func _set_targeting(v: bool) -> void:
	for i in enemy_uis.size():
		if enemies[i].hp > 0:
			enemy_uis[i].set_targeting(v)

# ------------------------------------------------------------------ cards ----

func _on_card_clicked(card: Panel) -> void:
	if busy or combat_over:
		return
	if selected_card == card:
		_deselect()
		return
	_deselect()
	var def := CardsDB.get_def(card.entry)
	if def.get("unplayable", false):
		_set_prompt("%s is unplayable." % def.display_name)
		return
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
			_set_targeting(true)
			_set_prompt("Choose a target for %s (click the card again to cancel)." % def.display_name)
	else:
		_play(card, -1)

func _deselect() -> void:
	if selected_card and is_instance_valid(selected_card):
		selected_card.set_selected(false)
	selected_card = null
	pending_potion = -1
	_set_targeting(false)
	_set_prompt(DEFAULT_PROMPT)

func _on_enemy_clicked(ui: Control) -> void:
	if busy or combat_over:
		return
	var idx := enemy_uis.find(ui)
	if idx < 0 or enemies[idx].hp <= 0:
		return
	if pending_potion >= 0:
		var slot := pending_potion
		_deselect()
		_use_potion(slot, idx)
		return
	if selected_card == null:
		return
	var card := selected_card
	selected_card = null
	card.set_selected(false)
	_set_targeting(false)
	_play(card, idx)

func _play(card: Panel, target_idx: int) -> void:
	var entry: Dictionary = card.entry
	var def := CardsDB.get_def(entry)
	var x_value := 0
	if def.get("x_cost", false):
		x_value = energy
		energy = 0
	else:
		energy -= def.cost
	hand.erase(card)
	card.queue_free()
	_apply_card(def, entry, target_idx, x_value)
	if not combat_over:
		if def.type == "power":
			pass  # Powers are consumed when played.
		elif def.get("exhaust", false):
			_exhaust(entry)
		else:
			discard_pile.append(entry)
		_card_played_triggers()
		_set_prompt(DEFAULT_PROMPT)
	_update_ui()
	_check_victory()

func _card_played_triggers() -> void:
	if thousand_cuts > 0:
		for i in _alive():
			_damage_enemy(i, thousand_cuts)
	if after_image > 0:
		block += after_image

func _apply_card(def: Dictionary, entry: Dictionary, target_idx: int, x_value: int) -> void:
	if def.type == "attack":
		$Player.play_lunge()
	if def.get("self_damage", 0) > 0:
		Run.lose_hp(def.self_damage)
		$Player.play_hit(def.self_damage)
		if Run.hp <= 0:
			_lose()
			return
	energy += def.get("energy", 0)
	strength += def.get("strength", 0)
	strength_down += def.get("strength_down", 0)
	dexterity += def.get("dexterity", 0)
	metallicize += def.get("metallicize", 0)
	demon_form += def.get("demon_form", 0)
	feel_no_pain += def.get("feel_no_pain", 0)
	dark_embrace += def.get("dark_embrace", 0)
	noxious_fumes += def.get("noxious_fumes", 0)
	thousand_cuts += def.get("thousand_cuts", 0)
	after_image += def.get("after_image", 0)
	if def.get("block", 0) > 0:
		_gain_block(def.block + dexterity)
	if def.get("next_turn_block", 0) > 0:
		next_turn_block += def.next_turn_block + dexterity
	if def.get("double_block", false) and block > 0:
		_gain_block(block)
	if def.get("armaments", false):
		for c in hand:
			if CardsDB.can_upgrade(c.entry):
				c.entry.up = true
				c.refresh()
	var targets: Array = []
	if def.target == "enemy" and target_idx >= 0:
		targets = [target_idx]
	elif def.target == "all":
		targets = _alive()
	var base := int(def.get("damage", 0))
	if def.get("damage_from_block", false):
		base += block
	base = max(0, base + int(entry.get("_bonus", 0)))
	if base > 0 and not targets.is_empty():
		var hits: int = x_value if def.get("x_cost", false) else def.get("hits", 1)
		for h in hits:
			for ti in targets:
				if enemies[ti].hp <= 0:
					continue
				var dmg: int = max(0, base + strength * int(def.get("strength_mult", 1)))
				if weak > 0:
					dmg = int(dmg * 0.75)
				if enemies[ti].vulnerable > 0:
					dmg = int(dmg * 1.5)
				if Run.relics.has("boot") and dmg < 5:
					dmg = 5
				var unblocked := _damage_enemy(ti, dmg)
				if def.get("heal_from_damage", false) and unblocked > 0:
					Run.heal(unblocked)
					$Player.play_heal(unblocked)
				if enemies[ti].thorns > 0:
					_player_take_damage(enemies[ti].thorns)
					if Run.hp <= 0:
						_lose()
						return
	if def.get("rampage", 0) != 0:
		entry["_bonus"] = int(entry.get("_bonus", 0)) + int(def.rampage)
	for ti in targets:
		if enemies[ti].hp <= 0:
			continue
		enemies[ti].vulnerable += def.get("vulnerable", 0)
		enemies[ti].weak += def.get("weak", 0)
		enemies[ti].poison += def.get("poison", 0)
		if def.get("poison_mult", 0) > 0:
			enemies[ti].poison *= def.poison_mult
	if def.get("add_shivs", 0) > 0:
		for n in def.add_shivs:
			if hand.size() < 10:
				_add_to_hand({"id": "shiv", "up": false})
	if def.get("draw", 0) > 0:
		_draw_cards(def.draw)
	if def.get("discard_random", 0) > 0:
		for n in def.discard_random:
			if hand.is_empty():
				break
			var victim: Panel = hand[Run.rng.randi_range(0, hand.size() - 1)]
			hand.erase(victim)
			discard_pile.append(victim.entry)
			victim.queue_free()
	if def.get("copy_to_discard", false):
		discard_pile.append(entry.duplicate())

func _gain_block(amount: int) -> void:
	if frail > 0:
		amount = int(amount * 0.75)
	if amount <= 0:
		return
	block += amount
	$Player.play_block_gain(amount)

func _exhaust(entry: Dictionary) -> void:
	exhaust_pile.append(entry)
	if feel_no_pain > 0:
		block += feel_no_pain
		$Player.play_block_gain(feel_no_pain)
	if dark_embrace > 0 and not cleaning_up:
		_draw_cards(dark_embrace)

func _damage_enemy(idx: int, dmg: int) -> int:
	var e: Dictionary = enemies[idx]
	var blocked: int = min(e.block, dmg)
	e.block -= blocked
	var unblocked: int = dmg - blocked
	e.hp = max(0, e.hp - unblocked)
	if unblocked > 0:
		enemy_uis[idx].play_hit(unblocked)
	else:
		enemy_uis[idx].play_blocked()
	_check_revive(idx)
	return unblocked

func _check_revive(idx: int) -> void:
	var e: Dictionary = enemies[idx]
	if e.hp > 0:
		return
	var rev: Dictionary = e.extra.get("revive", {})
	if rev.is_empty() or rev.used:
		return
	rev.used = true
	e.hp = rev.hp
	e.vulnerable = 0
	e.weak = 0
	e.poison = 0
	e.strength += 2
	e.intent = EnemiesDB.choose_intent(e, Run.rng)
	enemy_uis[idx].play_reborn()

func _player_take_damage(dmg: int) -> void:
	var blocked: int = min(block, dmg)
	block -= blocked
	var unblocked := dmg - blocked
	if unblocked > 0:
		Run.lose_hp(unblocked)
		$Player.play_hit(unblocked)
	else:
		$Player.play_blocked()

# ---------------------------------------------------------------- potions ----

func _on_potion_pressed(slot: int, right_click: bool) -> void:
	if combat_over:
		return
	if right_click:
		Run.potions.remove_at(slot)
		$Hud.refresh()
		return
	if busy:
		return
	var def: Dictionary = PotionsDB.POTIONS[Run.potions[slot]]
	if def.target == "enemy" and _alive().size() > 1:
		_deselect()
		pending_potion = slot
		_set_targeting(true)
		_set_prompt("Choose a target for the %s." % def.name)
		return
	var target := -1
	if def.target == "enemy":
		target = _alive()[0]
	_use_potion(slot, target)

func _use_potion(slot: int, target_idx: int) -> void:
	var def: Dictionary = PotionsDB.POTIONS[Run.potions[slot]]
	Run.potions.remove_at(slot)
	if Run.relics.has("toy_ornithopter"):
		Run.heal(5)
		$Player.play_heal(5)
	if def.get("damage", 0) > 0 and target_idx >= 0:
		var dmg: int = def.damage
		if enemies[target_idx].vulnerable > 0:
			dmg = int(dmg * 1.5)
		_damage_enemy(target_idx, dmg)
	if target_idx >= 0 and enemies[target_idx].hp > 0:
		enemies[target_idx].weak += def.get("weak", 0)
		enemies[target_idx].vulnerable += def.get("vulnerable", 0)
	if def.get("block", 0) > 0:
		_gain_block(def.block)
	strength += def.get("strength", 0)
	if def.get("heal_pct", 0.0) > 0.0:
		var amount := int(Run.max_hp * def.heal_pct)
		Run.heal(amount)
		$Player.play_heal(amount)
	energy += def.get("energy", 0)
	if def.get("draw", 0) > 0:
		_draw_cards(def.draw)
	_update_ui()
	_check_victory()

# ---------------------------------------------------------------- outcome ----

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
	if Run.relics.has("black_blood"):
		Run.heal(12)
	elif Run.relics.has("burning_blood"):
		Run.heal(6)
	if Run.relics.has("meat_on_the_bone") and Run.hp * 2 <= Run.max_hp:
		Run.heal(12)
	var gold_gain := 0
	match node_type:
		"monster":
			gold_gain = 12 + Run.current_row + Run.rng.randi_range(0, 8)
		"elite":
			gold_gain = 30 + Run.current_row + Run.rng.randi_range(0, 10)
		"boss":
			gold_gain = 70 + Run.rng.randi_range(0, 25)
	Run.gold += gold_gain
	Run.pending_reward = {"gold": gold_gain, "node_type": node_type}
	if node_type != "boss" and Run.rng.randf() < 0.4:
		Run.pending_reward["potion"] = PotionsDB.random_id(Run.rng)
	if node_type == "boss":
		if Run.act < Run.ACTS:
			_goto_delayed("boss_reward")
		else:
			Run.victory = true
			_goto_delayed("game_over")
	else:
		_goto_delayed("reward")

func _lose() -> void:
	if combat_over:
		return
	combat_over = true
	busy = true
	Run.victory = false
	_goto_delayed("game_over")

func _goto_delayed(screen: String) -> void:
	# Let the last hit/death animations breathe before switching screens.
	var tw := create_tween()
	tw.tween_interval(0.7)
	tw.tween_callback(func() -> void: get_node("/root/Main").goto(screen))

# ------------------------------------------------------------- enemy turn ----

func _on_end_turn_pressed() -> void:
	if busy or combat_over:
		return
	busy = true
	_deselect()
	_set_prompt("Enemy turn...")
	_show_banner("ENEMY TURN")
	if strength_down > 0:
		strength -= strength_down
		strength_down = 0
	if metallicize > 0:
		_gain_block(metallicize)
	if Run.relics.has("orichalcum") and block == 0:
		block += 6
	cleaning_up = true
	for c in hand.duplicate():
		var def := CardsDB.get_def(c.entry)
		if def.get("end_turn_damage", 0) > 0:
			_player_take_damage(def.end_turn_damage)
		if def.get("ethereal", false):
			_exhaust(c.entry)
		else:
			discard_pile.append(c.entry)
		c.queue_free()
	hand.clear()
	cleaning_up = false
	if Run.hp <= 0:
		_lose()
		return
	_update_ui()
	await get_tree().create_timer(0.55).timeout
	for i in enemies.size():
		if combat_over:
			break
		if enemies[i].hp <= 0:
			continue
		_enemy_act(i)
		_update_ui()
		if combat_over:
			break
		await get_tree().create_timer(0.65).timeout
	if combat_over:
		return
	if vulnerable > 0:
		vulnerable -= 1
	if weak > 0:
		weak -= 1
	if frail > 0:
		frail -= 1
	_start_player_turn()

func _enemy_act(idx: int) -> void:
	var e: Dictionary = enemies[idx]
	if e.poison > 0:
		e.hp = max(0, e.hp - e.poison)
		enemy_uis[idx].play_poison(e.poison)
		e.poison -= 1
		_check_revive(idx)
		if e.hp <= 0:
			if _alive().is_empty():
				_win()
			return
	e.block = 0
	var it: Dictionary = e.intent
	e.block += it.get("block", 0)
	e.strength += it.get("strength", 0)
	e.ritual += it.get("ritual", 0)
	e.thorns = max(0, e.thorns + it.get("thorns", 0))
	if it.get("heal_allies", 0) > 0:
		for ai in _alive():
			enemies[ai].hp = min(enemies[ai].max_hp, enemies[ai].hp + it.heal_allies)
	if it.get("buff_all", 0) > 0:
		for ai in _alive():
			enemies[ai].strength += it.buff_all
	if it.get("block_all", 0) > 0:
		for ai in _alive():
			enemies[ai].block += it.block_all
	if it.get("dmg", 0) > 0:
		enemy_uis[idx].play_lunge()
		for h in it.get("hits", 1):
			if e.hp <= 0:
				break
			var dmg: int = max(0, it.dmg + e.strength)
			if e.weak > 0:
				dmg = int(dmg * 0.75)
			if vulnerable > 0:
				dmg = int(dmg * 1.5)
			_player_take_damage(dmg)
			if it.get("heal_self_from_damage", false):
				e.hp = min(e.max_hp, e.hp + dmg)
			if it.get("steal_gold", 0) > 0:
				var stolen: int = min(Run.gold, it.steal_gold)
				Run.gold -= stolen
				if stolen > 0:
					$Player.play_gold_stolen(stolen)
			if thorns > 0:
				_damage_enemy(idx, thorns)
			if Run.hp <= 0:
				_lose()
				return
	weak += it.get("weak_p", 0)
	vulnerable += it.get("vuln_p", 0)
	frail += it.get("frail_p", 0)
	strength -= it.get("str_down_p", 0)
	var add: Dictionary = it.get("add_card", {})
	if not add.is_empty():
		for n in add.count:
			discard_pile.append({"id": add.id, "up": false})
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

# --------------------------------------------------------------------- ui ----

func _on_draw_button_pressed() -> void:
	var entries := draw_pile.duplicate()
	entries.sort_custom(func(a, b) -> bool: return String(a.id) < String(b.id))
	var picker := CARD_PICKER.instantiate()
	add_child(picker)
	picker.open(entries, "Draw Pile (%d cards, order hidden)" % entries.size(), false)

func _on_discard_button_pressed() -> void:
	var picker := CARD_PICKER.instantiate()
	add_child(picker)
	picker.open(discard_pile, "Discard Pile (%d) — Exhausted: %d" % [discard_pile.size(), exhaust_pile.size()], false)

func _player_status_text() -> String:
	var parts: Array = []
	if strength != 0:
		parts.append("Str %d" % strength)
	if dexterity != 0:
		parts.append("Dex %d" % dexterity)
	if vulnerable > 0:
		parts.append("Vuln %d" % vulnerable)
	if weak > 0:
		parts.append("Weak %d" % weak)
	if frail > 0:
		parts.append("Frail %d" % frail)
	if metallicize > 0:
		parts.append("Metal %d" % metallicize)
	if demon_form > 0:
		parts.append("Demon %d" % demon_form)
	if thorns > 0:
		parts.append("Thorns %d" % thorns)
	if feel_no_pain > 0:
		parts.append("FNP %d" % feel_no_pain)
	if dark_embrace > 0:
		parts.append("Dark Embrace")
	if noxious_fumes > 0:
		parts.append("Fumes %d" % noxious_fumes)
	if thousand_cuts > 0:
		parts.append("1000 Cuts %d" % thousand_cuts)
	if after_image > 0:
		parts.append("After Image %d" % after_image)
	if next_turn_block > 0:
		parts.append("Next Block %d" % next_turn_block)
	return " · ".join(PackedStringArray(parts))

func _update_ui() -> void:
	$Hud.refresh()
	$Player.refresh(block, _player_status_text())
	$EnergyOrb/EnergyLabel.text = "%d/%d" % [energy, energy_cap]
	$DrawButton.text = "Draw: %d" % draw_pile.size()
	$DiscardButton.text = "Discard: %d | Exh: %d" % [discard_pile.size(), exhaust_pile.size()]
	$EndTurnButton.disabled = busy or combat_over
	for ui in enemy_uis:
		ui.refresh(vulnerable)
	for c in hand:
		var def := CardsDB.get_def(c.entry)
		c.set_affordable(not def.get("unplayable", false) and def.cost <= energy)
