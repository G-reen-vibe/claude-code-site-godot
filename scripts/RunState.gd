extends Node
## Autoloaded as "Run". Holds all persistent state for the current run:
## player HP, gold, deck, and the generated map with the player's position.

const MAX_HP := 80
const MAP_ROWS := 8

var player_max_hp: int = MAX_HP
var player_hp: int = MAX_HP
var gold: int = 99
var deck: Array[String] = []

## map_rows[r] is an Array of node dictionaries:
##   {"type": "monster"|"elite"|"rest"|"boss", "col": int, "next": Array[int]}
## "next" lists the columns reachable in row r + 1.
var map_rows: Array = []
var current_row: int = -1
var current_col: int = -1


func new_run() -> void:
	player_max_hp = MAX_HP
	player_hp = MAX_HP
	gold = 99
	deck.clear()
	for i in 5:
		deck.append("strike")
	for i in 4:
		deck.append("defend")
	deck.append("bash")
	current_row = -1
	current_col = -1
	_generate_map()


func node_at(row: int, col: int) -> Dictionary:
	for n in map_rows[row]:
		if n["col"] == col:
			return n
	return {}


func _generate_map() -> void:
	map_rows.clear()
	for r in MAP_ROWS:
		var row: Array = []
		if r == MAP_ROWS - 1:
			row.append({"type": "boss", "col": 1, "next": []})
		else:
			for c in 3:
				var t := "monster"
				if r == MAP_ROWS - 2:
					t = "rest"  # guaranteed campfire before the boss
				elif r >= 1:
					var roll := randf()
					if r >= 2 and roll < 0.18:
						t = "elite"
					elif roll < 0.38:
						t = "rest"
				var next: Array = []
				if r == MAP_ROWS - 2:
					next = [1]  # everything funnels into the boss
				else:
					for nc in [c - 1, c, c + 1]:
						if nc < 0 or nc > 2:
							continue
						if nc == c or randf() < 0.45:
							next.append(nc)
				row.append({"type": t, "col": c, "next": next})
		map_rows.append(row)
