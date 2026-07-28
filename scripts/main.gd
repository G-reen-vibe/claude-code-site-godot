extends Control
## Root scene: swaps between the game's screens.

const SCREENS := {
	"menu": "res://scenes/Menu.tscn",
	"neow": "res://scenes/Neow.tscn",
	"map": "res://scenes/Map.tscn",
	"combat": "res://scenes/Combat.tscn",
	"reward": "res://scenes/Reward.tscn",
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

## Fights both bosses back-to-back with a strong deck to exercise burns,
## mode shift, thorns and X-cost cards: godot --headless --path . -- --bosstest
func _boss_test() -> void:
	await get_tree().process_frame
	for boss in ["hexaghost", "guardian"]:
		Run.new_run()
		Run.deck = []
		for i in 4:
			Run.deck.append({"id": "bludgeon", "up": true})
			Run.deck.append({"id": "impervious", "up": true})
		Run.deck.append({"id": "whirlwind", "up": true})
		Run.deck.append({"id": "demon_form", "up": false})
		Run.current_row = 13
		Run.pending_node_type = "boss"
		Run.pending_encounter = [boss]
		goto("combat")
		await get_tree().process_frame
		var combat: Node = current
		var turns := 0
		var guard := 0
		while is_instance_valid(combat) and not combat.combat_over and turns < 60:
			turns += 1
			var played := true
			while played and is_instance_valid(combat) and not combat.combat_over:
				played = false
				for c in combat.hand.duplicate():
					var def: Dictionary = CardsDB.get_def(c.entry)
					if not def.get("unplayable", false) and def.cost <= combat.energy:
						combat._on_card_clicked(c)
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
		print("[bosstest] %s done in %d turns, hp=%d, victory=%s, screen=%s" % [
			boss, turns, Run.hp, str(Run.victory), current.name,
		])
	print("[bosstest] PASS")
	get_tree().quit(0)

## Automated playthrough used by CI / headless testing:
## godot --headless --path . -- --smoketest
func _smoke_test() -> void:
	print("[smoke] starting")
	await get_tree().process_frame
	Run.new_run()
	goto("neow")
	await get_tree().process_frame
	current._on_gold_pressed()
	await get_tree().process_frame
	print("[smoke] neow ok, gold=%d, screen=%s" % [Run.gold, current.name])
	print("[smoke] map rows=%d" % Run.map_rows.size())
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
	var turns := 0
	var guard := 0
	while is_instance_valid(combat) and not combat.combat_over and turns < 40:
		turns += 1
		var played := true
		while played and is_instance_valid(combat) and not combat.combat_over:
			played = false
			for c in combat.hand.duplicate():
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
		while is_instance_valid(combat) and combat.busy and not combat.combat_over and guard < 5000:
			guard += 1
			await get_tree().process_frame
	while is_instance_valid(combat) and combat == current and guard < 5000:
		guard += 1
		await get_tree().process_frame
	print("[smoke] combat done after %d turns, hp=%d, screen=%s" % [turns, Run.hp, current.name])
	if current.name == "Reward":
		if Run.pending_reward.get("potion", "") != "":
			current._on_potion_button_pressed()
			print("[smoke] took potion reward, belt=%d" % Run.potions.size())
		current._on_skip_button_pressed()
		await get_tree().process_frame
		print("[smoke] reward ok, back on %s" % current.name)
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
	print("[smoke] event resolved, back on %s, relics=%s" % [current.name, Run.relic_names()])
	Run.victory = true
	goto("game_over")
	await get_tree().process_frame
	print("[smoke] game over ok: %s" % current.get_node("Title").text)
	print("[smoke] PASS")
	get_tree().quit(0)
