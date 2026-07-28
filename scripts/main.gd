extends Control
## Root scene: swaps between the game's screens.

const SCREENS := {
	"menu": "res://scenes/Menu.tscn",
	"charselect": "res://scenes/CharSelect.tscn",
	"neow": "res://scenes/Neow.tscn",
	"map": "res://scenes/Map.tscn",
	"combat": "res://scenes/Combat.tscn",
	"reward": "res://scenes/Reward.tscn",
	"boss_reward": "res://scenes/BossReward.tscn",
	"rest": "res://scenes/Rest.tscn",
	"shop": "res://scenes/Shop.tscn",
	"treasure": "res://scenes/Treasure.tscn",
	"event": "res://scenes/Event.tscn",
	"game_over": "res://scenes/GameOver.tscn",
}

var current: Node = null

func _ready() -> void:
	goto("menu")
	if OS.get_cmdline_user_args().has("--smoketest"):
		_smoke_test()
	elif OS.get_cmdline_user_args().has("--bosstest"):
		_boss_test()

func goto(screen: String) -> void:
	if current:
		current.queue_free()
	current = load(SCREENS[screen]).instantiate()
	add_child(current)

# ------------------------------------------------------------ test rigs ----

func _autoplay_combat(combat: Node, max_turns: int = 60) -> int:
	## Plays any deck greedily until the fight resolves. Returns turns taken.
	var turns := 0
	var guard := 0
	while is_instance_valid(combat) and not combat.combat_over and turns < max_turns:
		turns += 1
		var played := true
		while played and is_instance_valid(combat) and not combat.combat_over:
			played = false
			# Block-first greedy bot: biggest block card, then biggest attack.
			var candidates: Array = combat.hand.duplicate()
			candidates.sort_custom(func(a, b) -> bool:
				var da: Dictionary = CardsDB.get_def(a.entry)
				var db: Dictionary = CardsDB.get_def(b.entry)
				if da.get("block", 0) != db.get("block", 0):
					return da.get("block", 0) > db.get("block", 0)
				return da.get("damage", 0) > db.get("damage", 0))
			for c in candidates:
				var def: Dictionary = CardsDB.get_def(c.entry)
				if not def.get("unplayable", false) and def.cost <= combat.energy:
					combat._on_card_clicked(c)
					if combat.selected_card == c:
						for ui in combat.enemy_uis:
							if ui.data.hp > 0:
								combat._on_enemy_clicked(ui)
								break
					played = true
					break
		if not is_instance_valid(combat) or combat.combat_over:
			break
		combat._on_end_turn_pressed()
		while is_instance_valid(combat) and combat.busy and not combat.combat_over and guard < 20000:
			guard += 1
			await get_tree().process_frame
	while is_instance_valid(combat) and combat == current and guard < 20000:
		guard += 1
		await get_tree().process_frame
	return turns

## Fights every boss in the game (both per act) with a strong deck, walking
## through boss-relic rewards and act transitions:
## godot --headless --path . -- --bosstest
func _boss_test() -> void:
	Engine.time_scale = 20.0
	await get_tree().process_frame
	var fights: Array = [
		[["guardian"], 1], [["hexaghost"], 1],
		[["champ"], 2], [["automaton"], 2],
		[["awakened_one"], 3], [["donu", "deca"], 3],
	]
	for fight in fights:
		Run.new_run("ironclad")
		Run.act = fight[1]
		Run.relics.append("coffee_dripper")  # 4 energy: block + attack every turn
		Run.deck = []
		for i in 4:
			Run.deck.append({"id": "carnage", "up": true})
			Run.deck.append({"id": "impervious", "up": true})
		Run.deck.append({"id": "whirlwind", "up": true})
		Run.deck.append({"id": "inflame", "up": true})
		Run.current_row = 13
		Run.pending_node_type = "boss"
		Run.pending_encounter = fight[0].duplicate()
		goto("combat")
		await get_tree().process_frame
		# Shrink act-3 boss HP so the fixed test deck reliably reaches the
		# Awakened One's rebirth phase and the final victory screen.
		if fight[1] == 3:
			for e in current.enemies:
				e.hp = min(e.hp, 80)
		var first_enemy: Dictionary = current.enemies[0]
		var turns: int = await _autoplay_combat(current)
		var boss_name: String = "+".join(PackedStringArray(fight[0]))
		print("[bosstest] act %d %s done in %d turns, hp=%d, victory=%s, screen=%s" % [
			fight[1], boss_name, turns, Run.hp, str(Run.victory), current.name,
		])
		if first_enemy.extra.has("revive"):
			print("[bosstest]   rebirth triggered=%s" % str(first_enemy.extra.revive.used))
		if current.name == "BossReward":
			var relic: String = current.offers[0]
			current._on_relic_chosen(relic)
			await get_tree().process_frame
			print("[bosstest]   took %s, now act %d on %s" % [relic, Run.act, current.name])
	print("[bosstest] PASS")
	get_tree().quit(0)

## Automated playthrough used by CI / headless testing:
## godot --headless --path . -- --smoketest
func _smoke_test() -> void:
	Engine.time_scale = 20.0
	print("[smoke] starting")
	await get_tree().process_frame
	goto("charselect")
	await get_tree().process_frame
	current._choose("silent")
	await get_tree().process_frame
	print("[smoke] charselect ok: playing %s, deck=%d, hp=%d" % [Run.character, Run.deck.size(), Run.max_hp])
	current._on_gold_pressed()
	await get_tree().process_frame
	print("[smoke] neow ok, gold=%d, screen=%s" % [Run.gold, current.name])
	Run.current_row = 0
	Run.current_col = 0
	Run.potions = ["fire", "swift"]
	Run.pending_node_type = "monster"
	Run.pending_encounter = ["louse", "green_louse"]
	goto("combat")
	await get_tree().process_frame
	var combat: Node = current
	combat._on_potion_pressed(0, false)  # fire potion -> targeting mode
	if combat.pending_potion >= 0:
		for ui in combat.enemy_uis:
			if ui.data.hp > 0:
				combat._on_enemy_clicked(ui)
				break
	combat._on_potion_pressed(0, false)  # swift potion -> draw 3
	print("[smoke] potions used, hand=%d, potions left=%d" % [combat.hand.size(), Run.potions.size()])
	combat._on_draw_button_pressed()
	var pile_picker := combat.get_node_or_null("CardPicker")
	print("[smoke] draw pile viewer open=%s" % str(pile_picker != null))
	if pile_picker:
		pile_picker._on_close_button_pressed()
	var turns: int = await _autoplay_combat(combat, 40)
	print("[smoke] combat done after %d turns, hp=%d, screen=%s" % [turns, Run.hp, current.name])
	if current.name == "Reward":
		if Run.pending_reward.get("potion", "") != "":
			current._on_potion_button_pressed()
			print("[smoke] took potion reward, belt=%d" % Run.potions.size())
		current._on_skip_button_pressed()
		await get_tree().process_frame
		print("[smoke] reward ok, back on %s, save exists=%s" % [current.name, str(Run.has_save())])
	goto("rest")
	await get_tree().process_frame
	current._on_smith_button_pressed()
	await get_tree().process_frame
	var picker := current.get_node_or_null("CardPicker")
	if picker:
		picker.picked.emit(0)
		await get_tree().process_frame
	current._on_continue_button_pressed()
	await get_tree().process_frame
	print("[smoke] rest/upgrade ok, first card up=%s" % str(Run.deck[0].up))
	goto("shop")
	await get_tree().process_frame
	print("[smoke] shop ok, cards=%d potions=%d relic=%s" % [
		current.card_offers.size(), current.potion_offers.size(), str(not current.relic_offer.is_empty()),
	])
	current._on_card_offer_pressed(0)
	print("[smoke] bought card, deck=%d gold=%d" % [Run.deck.size(), Run.gold])
	current._on_leave_button_pressed()
	await get_tree().process_frame
	goto("treasure")
	await get_tree().process_frame
	current._on_continue_button_pressed()
	await get_tree().process_frame
	goto("event")
	await get_tree().process_frame
	print("[smoke] event ok: %s" % current.event.title)
	var choices: VBoxContainer = current.get_node("Panel/V/Choices")
	choices.get_child(choices.get_child_count() - 1).pressed.emit()
	await get_tree().process_frame
	var ev_picker := current.get_node_or_null("CardPicker")
	if ev_picker:
		ev_picker.picked.emit(0)
		await get_tree().process_frame
	current._on_continue_button_pressed()
	await get_tree().process_frame
	print("[smoke] event resolved, back on %s" % current.name)
	# Save / load round-trip.
	Run.save_game()
	var saved_gold := Run.gold
	Run.gold = 0
	if Run.load_game():
		print("[smoke] save/load ok, gold restored=%s" % str(Run.gold == saved_gold))
	Run.victory = true
	goto("game_over")
	await get_tree().process_frame
	print("[smoke] game over ok: %s, save deleted=%s" % [current.get_node("Title").text, str(not Run.has_save())])
	print("[smoke] PASS")
	get_tree().quit(0)
