extends Node
## Autoloaded as "Run". Holds all state that persists across screens for one run.

const MAP_ROWS := 14
const ACTS := 3
const MAX_POTIONS := 3
const SAVE_PATH := "user://savegame.json"

const CHARACTERS := {
	"ironclad": {
		"name": "The Ironclad", "max_hp": 80, "relic": "burning_blood",
		"sprite": "res://assets/sprites/ironclad.svg",
		"desc": "The remaining soldier of the Ironclads. Wields heavy strikes, raw Strength, and the power of his cursed blood.",
		"deck": [
			["strike", 5], ["defend", 4], ["bash", 1],
		],
	},
	"silent": {
		"name": "The Silent", "max_hp": 70, "relic": "ring_of_snake",
		"sprite": "res://assets/sprites/silent.svg",
		"desc": "A deadly huntress from the foglands. Wins with Poison, flurries of Shivs, and slippery card draw.",
		"deck": [
			["strike", 5], ["defend", 5], ["neutralize", 1], ["survivor", 1],
		],
	},
}

var rng := RandomNumberGenerator.new()

var character := "ironclad"
var act: int = 1
var max_hp: int = 80
var hp: int = 80
var gold: int = 99
var deck: Array = []      # entries: {"id": String, "up": bool}
var relics: Array = []    # relic id strings
var potions: Array = []   # potion id strings, up to MAX_POTIONS
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
	new_run("ironclad")

func new_run(character_id: String) -> void:
	character = character_id
	var cdef: Dictionary = CHARACTERS[character]
	act = 1
	max_hp = cdef.max_hp
	hp = max_hp
	gold = 99
	victory = false
	deck.clear()
	for pair in cdef.deck:
		for i in pair[1]:
			deck.append({"id": pair[0], "up": false})
	relics = [cdef.relic]
	potions = []
	current_row = -1
	current_col = 0
	_generate_map()

func next_act() -> void:
	act += 1
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
	if r < 0.42:
		return "monster"
	if r < 0.56:
		return "event"
	if r < 0.68:
		return "elite" if row >= 4 else "monster"
	if r < 0.78:
		return "rest"
	if r < 0.89:
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
	if id == "black_blood":
		relics.erase("burning_blood")
	relics.append(id)
	if id == "strawberry":
		max_hp += 7
		hp += 7
	if id == "pandoras_box":
		for entry in deck:
			if entry.id == "strike" or entry.id == "defend":
				entry.id = CardsDB.random_of_pool(rng, character)
				entry.up = false

func add_potion(id: String) -> bool:
	if potions.size() >= MAX_POTIONS:
		return false
	potions.append(id)
	return true

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

# ------------------------------------------------------------ save/load ----

func save_game() -> void:
	var data := {
		"version": 1,
		"character": character,
		"act": act,
		"max_hp": max_hp,
		"hp": hp,
		"gold": gold,
		"deck": deck,
		"relics": relics,
		"potions": potions,
		"map_rows": map_rows,
		"current_row": current_row,
		"current_col": current_col,
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))

static func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return false
	var data = JSON.parse_string(f.get_as_text())
	if not data is Dictionary or int(data.get("version", 0)) != 1:
		return false
	character = data.character
	act = int(data.act)
	max_hp = int(data.max_hp)
	hp = int(data.hp)
	gold = int(data.gold)
	victory = false
	deck.clear()
	for entry in data.deck:
		deck.append({"id": String(entry.id), "up": bool(entry.up)})
	relics.clear()
	for id in data.relics:
		relics.append(String(id))
	potions.clear()
	for id in data.potions:
		potions.append(String(id))
	map_rows.clear()
	for row in data.map_rows:
		var nodes: Array = []
		for node in row:
			nodes.append({"type": String(node.type), "visited": bool(node.visited)})
		map_rows.append(nodes)
	current_row = int(data.current_row)
	current_col = int(data.current_col)
	return true
