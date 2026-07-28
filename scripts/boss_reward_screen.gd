extends Control
## Shown after defeating an act boss (acts 1-2): choose one boss relic,
## then ascend to the next act.

var offers: Array = []

func _ready() -> void:
	$Panel/V/Title.text = "ACT %d COMPLETE" % Run.act
	$Panel/V/GoldLabel.text = "You plunder %d gold from the boss." % Run.pending_reward.get("gold", 0)
	offers = RelicsDB.random_boss_relics(Run.rng, Run.relics, 3)
	for id in offers:
		var rd: Dictionary = RelicsDB.RELICS[id]
		var b := Button.new()
		b.text = "%s — %s" % [rd.name, rd.text]
		b.clip_text = true
		b.tooltip_text = b.text
		b.custom_minimum_size = Vector2(0, 46)
		b.pressed.connect(_on_relic_chosen.bind(id))
		$Panel/V/Choices.add_child(b)
	$Hud.refresh()

func _on_relic_chosen(id: String) -> void:
	Run.add_relic(id)
	_continue()

func _on_skip_button_pressed() -> void:
	_continue()

func _continue() -> void:
	Run.next_act()
	Run.save_game()
	get_node("/root/Main").goto("map")
