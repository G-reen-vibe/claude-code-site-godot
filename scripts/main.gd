extends Control
## Root scene: swaps between the game's screens.

const SCREENS := {
	"menu": "res://scenes/Menu.tscn",
	"map": "res://scenes/Map.tscn",
	"combat": "res://scenes/Combat.tscn",
	"reward": "res://scenes/Reward.tscn",
	"rest": "res://scenes/Rest.tscn",
	"shop": "res://scenes/Shop.tscn",
	"treasure": "res://scenes/Treasure.tscn",
	"game_over": "res://scenes/GameOver.tscn",
}

var current: Node = null

func _ready() -> void:
	goto("menu")
	if OS.get_cmdline_user_args().has("--smoketest"):
		_smoke_test()

func goto(screen: String) -> void:
	if current:
		current.queue_free()
	current = load(SCREENS[screen]).instantiate()
	add_child(current)

## Automated playthrough used by CI / headless testing:
## godot --headless --path . -- --smoketest
func _smoke_test() -> void:
	print("[smoke] starting")
	await get_tree().process_frame
	Run.new_run()
	goto("map")
	await get_tree().process_frame
	print("[smoke] map ok, rows=%d" % Run.map_rows.size())
	Run.current_row = 0
	Run.current_col = 0
	Run.pending_node_type = "monster"
	Run.pending_encounter = ["louse", "louse"]
	goto("combat")
	await get_tree().process_frame
	var combat: Node = current
	var turns := 0
	var guard := 0
	while is_instance_valid(combat) and not combat.combat_over and turns < 40:
		turns += 1
		var played := true
		while played and is_instance_valid(combat) and not combat.combat_over:
			played = false
			for c in combat.hand.duplicate():
				var def: Dictionary = CardsDB.get_def(c.entry)
				if def.cost <= combat.energy:
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
	await get_tree().process_frame
	print("[smoke] combat done after %d turns, hp=%d, screen=%s" % [turns, Run.hp, current.name])
	if current.name == "Reward":
		current._on_skip_button_pressed()
		await get_tree().process_frame
		print("[smoke] reward ok, back on %s" % current.name)
	goto("rest")
	await get_tree().process_frame
	current._on_rest_button_pressed()
	current._on_continue_button_pressed()
	await get_tree().process_frame
	print("[smoke] rest ok, hp=%d" % Run.hp)
	goto("shop")
	await get_tree().process_frame
	print("[smoke] shop ok, offers=%d" % current.offers.size())
	current._on_leave_button_pressed()
	await get_tree().process_frame
	goto("treasure")
	await get_tree().process_frame
	print("[smoke] treasure ok, relics=%s" % Run.relic_names())
	current._on_continue_button_pressed()
	await get_tree().process_frame
	Run.victory = true
	goto("game_over")
	await get_tree().process_frame
	print("[smoke] game over ok: %s" % current.get_node("Title").text)
	print("[smoke] PASS")
	get_tree().quit(0)
