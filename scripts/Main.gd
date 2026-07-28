extends Control
## Top-level game flow: switches between the title, map, combat, reward,
## rest, game-over and victory screens, and hands out post-combat rewards.

const CardScene := preload("res://scenes/Card.tscn")
const SCREENS := ["Title", "Map", "Combat", "Reward", "Rest", "GameOver", "Victory"]
const REST_HEAL := 25

@onready var map_screen: Control = $Map
@onready var combat_screen: Control = $Combat
@onready var reward_title: Label = $Reward/Center/Panel/Margin/VBox/RewardTitle
@onready var gold_reward_label: Label = $Reward/Center/Panel/Margin/VBox/GoldLabel
@onready var card_choices: HBoxContainer = $Reward/Center/Panel/Margin/VBox/CardChoices
@onready var rest_info: Label = $Rest/Center/Panel/Margin/VBox/RestInfo
@onready var heal_button: Button = $Rest/Center/Panel/Margin/VBox/HealButton

var current_kind := ""


func _ready() -> void:
	$Title/Center/VBox/StartButton.pressed.connect(_start_run)
	map_screen.node_selected.connect(_on_node_selected)
	combat_screen.combat_finished.connect(_on_combat_finished)
	$Reward/Center/Panel/Margin/VBox/SkipButton.pressed.connect(_return_to_map)
	heal_button.pressed.connect(_on_rest_heal)
	$Rest/Center/Panel/Margin/VBox/ContinueButton.pressed.connect(_return_to_map)
	$GameOver/Center/VBox/RestartButton.pressed.connect(_start_run)
	$Victory/Center/VBox/RestartButton.pressed.connect(_start_run)
	_show("Title")


func _show(screen_name: String) -> void:
	for s in SCREENS:
		get_node(s).visible = s == screen_name


func _start_run() -> void:
	Run.new_run()
	_show("Map")
	map_screen.refresh()


func _return_to_map() -> void:
	_show("Map")
	map_screen.refresh()


func _on_node_selected(row: int, col: int) -> void:
	Run.current_row = row
	Run.current_col = col
	match Run.node_at(row, col)["type"]:
		"monster":
			_start_combat(EnemyLibrary.MONSTER_ENCOUNTERS.pick_random(), "monster")
		"elite":
			_start_combat(EnemyLibrary.ELITE_ENCOUNTERS.pick_random(), "elite")
		"boss":
			_start_combat(EnemyLibrary.BOSS_ENCOUNTERS.pick_random(), "boss")
		"rest":
			_enter_rest()


func _start_combat(encounter: Array, kind: String) -> void:
	current_kind = kind
	_show("Combat")
	combat_screen.start_combat(encounter, kind)


func _on_combat_finished(victory: bool) -> void:
	if not victory:
		$GameOver/Center/VBox/OverInfo.text = \
			"You made it to floor %d of %d." % [Run.current_row + 1, Run.MAP_ROWS]
		_show("GameOver")
		return
	if current_kind == "boss":
		$Victory/Center/VBox/VictoryInfo.text = \
			"The Guardian falls!\nFinal deck: %d cards   Gold: %d" % [Run.deck.size(), Run.gold]
		_show("Victory")
		return
	_open_reward()


func _open_reward() -> void:
	var gold_gain := randi_range(30, 45) if current_kind == "elite" else randi_range(15, 25)
	Run.gold += gold_gain
	reward_title.text = "Victory!"
	gold_reward_label.text = "You gained %d gold." % gold_gain
	for c in card_choices.get_children():
		c.visible = false
		c.queue_free()
	var pool: Array = CardLibrary.REWARD_POOL.duplicate()
	pool.shuffle()
	for i in 3:
		var id: String = pool[i]
		var cu := CardScene.instantiate()
		card_choices.add_child(cu)
		cu.setup(id, i)
		cu.card_clicked.connect(func(_idx): _on_reward_card(id))
	_show("Reward")


func _on_reward_card(id: String) -> void:
	Run.deck.append(id)
	_return_to_map()


func _enter_rest() -> void:
	heal_button.disabled = false
	heal_button.text = "Rest  (+%d HP)" % REST_HEAL
	_update_rest_info()
	_show("Rest")


func _on_rest_heal() -> void:
	Run.player_hp = mini(Run.player_max_hp, Run.player_hp + REST_HEAL)
	heal_button.disabled = true
	_update_rest_info()


func _update_rest_info() -> void:
	rest_info.text = "You settle down by the fire.\nHP %d/%d" % [Run.player_hp, Run.player_max_hp]
