class_name EnemyLibrary
extends RefCounted
## Data-driven enemy definitions and encounter tables.
##
## Enemy fields:
##   name: String, hp: [min, max], color: Color (portrait swatch)
##   pattern: "cycle" (moves in order, looping)
##          | "random" (uniform random each turn)
##          | "opener_random" (move 0 on the first turn, then random among the rest)
##   moves: Array of move dictionaries:
##     {"name": String, "intent": "attack"|"defend"|"buff"|"debuff",
##      "effects": [ ... same effect format as cards, but "on" is "player"|"self" ]}

const ENEMIES := {
	"jaw_worm": {
		"name": "Jaw Worm", "hp": [40, 44], "color": Color(0.45, 0.75, 0.3),
		"pattern": "cycle",
		"moves": [
			{"name": "Chomp", "intent": "attack",
				"effects": [{"kind": "damage", "amount": 11}]},
			{"name": "Bellow", "intent": "buff",
				"effects": [
					{"kind": "status", "status": "strength", "amount": 3, "on": "self"},
					{"kind": "block", "amount": 6},
				]},
			{"name": "Thrash", "intent": "attack",
				"effects": [
					{"kind": "damage", "amount": 7},
					{"kind": "block", "amount": 5},
				]},
		],
	},
	"cultist": {
		"name": "Cultist", "hp": [48, 54], "color": Color(0.35, 0.55, 0.9),
		"pattern": "opener_random",
		"moves": [
			{"name": "Incantation", "intent": "buff",
				"effects": [{"kind": "status", "status": "strength", "amount": 4, "on": "self"}]},
			{"name": "Dark Strike", "intent": "attack",
				"effects": [{"kind": "damage", "amount": 6}]},
		],
	},
	"louse": {
		"name": "Red Louse", "hp": [11, 16], "color": Color(0.85, 0.35, 0.3),
		"pattern": "random",
		"moves": [
			{"name": "Bite", "intent": "attack",
				"effects": [{"kind": "damage", "amount": 6}]},
			{"name": "Grow", "intent": "buff",
				"effects": [{"kind": "status", "status": "strength", "amount": 3, "on": "self"}]},
		],
	},
	"slime": {
		"name": "Acid Slime", "hp": [28, 32], "color": Color(0.55, 0.85, 0.4),
		"pattern": "random",
		"moves": [
			{"name": "Tackle", "intent": "attack",
				"effects": [{"kind": "damage", "amount": 10}]},
			{"name": "Corrosive Spit", "intent": "attack",
				"effects": [{"kind": "damage", "amount": 7}]},
			{"name": "Lick", "intent": "debuff",
				"effects": [{"kind": "status", "status": "weak", "amount": 1, "on": "player"}]},
		],
	},
	"gremlin_nob": {
		"name": "Gremlin Nob", "hp": [84, 90], "color": Color(0.95, 0.5, 0.2),
		"pattern": "opener_random",
		"moves": [
			{"name": "Bellow", "intent": "buff",
				"effects": [{"kind": "status", "status": "strength", "amount": 3, "on": "self"}]},
			{"name": "Rush", "intent": "attack",
				"effects": [{"kind": "damage", "amount": 14}]},
			{"name": "Skull Bash", "intent": "attack",
				"effects": [
					{"kind": "damage", "amount": 6},
					{"kind": "status", "status": "vulnerable", "amount": 2, "on": "player"},
				]},
		],
	},
	"guardian": {
		"name": "The Guardian", "hp": [150, 150], "color": Color(0.75, 0.4, 0.95),
		"pattern": "cycle",
		"moves": [
			{"name": "Charging Up", "intent": "defend",
				"effects": [{"kind": "block", "amount": 9}]},
			{"name": "Fierce Bash", "intent": "attack",
				"effects": [{"kind": "damage", "amount": 24}]},
			{"name": "Vent Steam", "intent": "debuff",
				"effects": [
					{"kind": "status", "status": "weak", "amount": 2, "on": "player"},
					{"kind": "status", "status": "vulnerable", "amount": 2, "on": "player"},
				]},
			{"name": "Whirlwind", "intent": "attack",
				"effects": [{"kind": "damage", "amount": 5, "times": 4}]},
		],
	},
}

const MONSTER_ENCOUNTERS := [
	["jaw_worm"],
	["cultist"],
	["louse", "louse"],
	["slime"],
	["slime", "louse"],
]
const ELITE_ENCOUNTERS := [["gremlin_nob"]]
const BOSS_ENCOUNTERS := [["guardian"]]
