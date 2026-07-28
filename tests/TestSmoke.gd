extends Node
## Headless smoke test. Run with:
##   godot --headless res://tests/TestSmoke.tscn
## Exits with code 0 if all checks pass, 1 otherwise.

var fails := 0


func check(cond: bool, msg: String) -> void:
	if cond:
		print("PASS: " + msg)
	else:
		fails += 1
		printerr("FAIL: " + msg)


func _ready() -> void:
	var main: Control = load("res://scenes/Main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame

	# --- Run setup / map generation ---
	main._start_run()
	check(Run.deck.size() == 10, "starter deck has 10 cards")
	check(Run.player_hp == 80, "player starts at 80 HP")
	check(Run.map_rows.size() == 8, "map has 8 rows")
	check(Run.map_rows[7][0]["type"] == "boss", "top row is the boss")
	for n in Run.map_rows[6]:
		check(n["type"] == "rest" and n["next"] == [1], "pre-boss row is rest funneling to boss")

	# --- Damage formula ---
	var combat: Control = main.get_node("Combat")
	check(combat._calc_damage(6, 0, false, true) == 9, "vulnerable = 150% damage")
	check(combat._calc_damage(8, 0, true, false) == 6, "weak = 75% damage")
	check(combat._calc_damage(6, 3, false, false) == 9, "strength adds damage")
	check(combat._calc_damage(14, 6, false, false) == 20, "heavy blade str x3 (2 str) = 20")

	# --- Combat: player turn ---
	Run.current_row = 0
	Run.current_col = 0
	main._start_combat(["jaw_worm"], "monster")
	await get_tree().process_frame
	check(combat.hand.size() == 5, "drew 5 cards")
	check(combat.energy == 3, "player has 3 energy")
	check(combat.enemies.size() == 1, "one enemy spawned")
	var enemy: Dictionary = combat.enemies[0]
	var enemy_hp_start: int = enemy["hp"]

	# Force a known hand so the assertions below are deterministic.
	combat.draw_pile.append_array(combat.hand)
	combat.hand = ["strike", "strike", "bash", "defend", "defend"]
	combat._refresh_all()

	var guard := 0
	while combat.is_player_turn and guard < 20:
		guard += 1
		var played := false
		for i in combat.hand.size():
			var card: Dictionary = CardLibrary.CARDS[combat.hand[i]]
			if combat.energy >= card["cost"]:
				var target := {}
				if card["target"] == "enemy":
					target = enemy
				combat._play_card(i, target)
				played = true
				break
		if not played:
			break
	# Plays Strike (6), Strike (6), then Defend (Bash unaffordable at 1 energy).
	check(enemy["hp"] == enemy_hp_start - 12, "two strikes dealt exactly 12 damage")
	check(combat.player_block == 5, "defend granted 5 block")
	check(combat.discard_pile.size() == 3, "played cards went to discard")

	# --- Combat: enemy turn ---
	# Jaw Worm turn 0 is always Chomp for 11; 5 block absorbs, HP drops by 6.
	var hp_before_enemy_turn: int = Run.player_hp
	combat._on_end_turn()
	await get_tree().create_timer(2.0).timeout
	check(Run.player_hp == hp_before_enemy_turn - 6, "chomp dealt 11 through 5 block")
	check(combat.is_player_turn, "control returned to player after enemy turn")
	check(combat.hand.size() == 5, "redrew 5 cards on new turn")
	check(combat.energy == 3, "energy refilled")

	# --- Finish combat -> reward ---
	var results: Array = []
	combat.combat_finished.connect(func(v): results.append(v))
	enemy["hp"] = 1
	combat._attack_enemy(enemy, 100, 1)
	check(results == [true], "killing last enemy ends combat in victory")
	await get_tree().process_frame
	check(main.get_node("Reward").visible, "reward screen shown after victory")
	var choices: HBoxContainer = main.get_node("Reward/Center/Panel/Margin/VBox/CardChoices")
	var visible_choices := choices.get_children().filter(func(c): return c.visible)
	check(visible_choices.size() == 3, "three reward cards offered")
	main._on_reward_card("cleave")
	check(Run.deck.size() == 11, "reward card added to deck")

	# --- Rest site ---
	Run.player_hp = 40
	main._enter_rest()
	check(main.get_node("Rest").visible, "rest screen shown")
	main._on_rest_heal()
	check(Run.player_hp == 65, "rest heals 25 HP")
	Run.player_hp = 70
	main._on_rest_heal()  # button would be disabled in UI; direct call re-heals
	check(Run.player_hp == 80, "heal caps at max HP")

	# --- Defeat path ---
	main._start_combat(["louse"], "monster")
	await get_tree().process_frame
	var results2: Array = []
	combat.combat_finished.connect(func(v): results2.append(v))
	Run.player_hp = 1
	combat._damage_player(10)
	check(results2 == [false], "player death ends combat in defeat")
	await get_tree().process_frame
	check(main.get_node("GameOver").visible, "game over screen shown after defeat")

	if fails == 0:
		print("ALL CHECKS PASSED")
	else:
		printerr("%d CHECK(S) FAILED" % fails)
	get_tree().quit(1 if fails > 0 else 0)
