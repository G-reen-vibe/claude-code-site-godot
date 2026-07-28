extends Node
## Autoloaded as "Run". Holds all state that persists across screens for one run.

const MAP_ROWS := 13

var rng := RandomNumberGenerator.new()

var max_hp: int = 80
var hp: int = 80
var gold: int = 99
var deck: Array = []      # entries: {"id": String, "up": bool}
var relics: Array = []    # relic id strings
var map_rows: Array = []  # rows of {"type": String, "visited": bool}
var current_row: int = -1
var current_col: int = 0
var victory := false

# Hand-off data between screens.
var pending_encounter: Array = []
var pending_node_type := "monster"
var pending_reward: Dictionary = {}

func _ready() -> void:
	rng.randomize()
	new_run()

func new_run() -> void:
	max_hp = 80
	hp = 80
	gold = 99
	victory = false
	deck.clear()
	for i in 5:
		deck.append({"id": "strike", "up": false})
	for i in 4:
		deck.append({"id": "defend", "up": false})
	deck.append({"id": "bash", "up": false})
	relics = ["burning_blood"]
	current_row = -1
	current_col = 0
	_generate_map()

func _generate_map() -> void:
	map_rows.clear()
	for row in MAP_ROWS:
		if row == MAP_ROWS - 1:
			map_rows.append([{"type": "boss", "visited": false}])
			continue
		var nodes: Array = []
		for col in 3:
			nodes.append({"type": _roll_type(row), "visited": false})
		map_rows.append(nodes)

func _roll_type(row: int) -> String:
	if row == 0:
		return "monster"
	if row == MAP_ROWS - 2:
		return "rest"
	var r := rng.randf()
	if r < 0.46:
		return "monster"
	if r < 0.60:
		return "elite" if row >= 4 else "monster"
	if r < 0.74:
		return "rest"
	if r < 0.87:
		return "shop"
	return "treasure"

func can_move_to(row: int, col: int) -> bool:
	if row != current_row + 1:
		return false
	if row >= map_rows.size():
		return false
	if current_row == -1:
		return true
	if map_rows[row].size() == 1:
		return true
	return abs(col - current_col) <= 1

func heal(amount: int) -> void:
	hp = min(max_hp, hp + amount)

func lose_hp(amount: int) -> void:
	hp = max(0, hp - amount)

func add_relic(id: String) -> void:
	relics.append(id)
	if id == "strawberry":
		max_hp += 7
		hp += 7

func relic_names() -> String:
	var names: Array = []
	for id in relics:
		names.append(RelicsDB.RELICS[id].name)
	return ", ".join(PackedStringArray(names))

func shuffle_array(a: Array) -> void:
	for i in range(a.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = a[i]
		a[i] = a[j]
		a[j] = tmp
