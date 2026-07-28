class_name CardLibrary
extends RefCounted
## Data-driven card definitions.
##
## Card fields:
##   name: String, cost: int, type: "attack"|"skill"|"power"
##   target: "enemy" (pick one) | "all_enemies" | "random_enemy" | "self"
##   desc: String shown on the card
##   exhaust: bool (optional) - removed from play for the rest of combat
##   effects: Array of effect dictionaries, executed in order:
##     {"kind": "damage", "amount": int, "times": int?, "str_mult": int?}
##     {"kind": "block", "amount": int}
##     {"kind": "draw", "amount": int}
##     {"kind": "energy", "amount": int}
##     {"kind": "lose_hp", "amount": int}
##     {"kind": "status", "status": "strength"|"vulnerable"|"weak",
##      "amount": int, "on": "target"|"self"}
##     {"kind": "add_card", "id": String}   (adds a copy to the discard pile)

const CARDS := {
	"strike": {
		"name": "Strike", "cost": 1, "type": "attack", "target": "enemy",
		"desc": "Deal 6 damage.",
		"effects": [{"kind": "damage", "amount": 6}],
	},
	"defend": {
		"name": "Defend", "cost": 1, "type": "skill", "target": "self",
		"desc": "Gain 5 Block.",
		"effects": [{"kind": "block", "amount": 5}],
	},
	"bash": {
		"name": "Bash", "cost": 2, "type": "attack", "target": "enemy",
		"desc": "Deal 8 damage. Apply 2 Vulnerable.",
		"effects": [
			{"kind": "damage", "amount": 8},
			{"kind": "status", "status": "vulnerable", "amount": 2, "on": "target"},
		],
	},
	"cleave": {
		"name": "Cleave", "cost": 1, "type": "attack", "target": "all_enemies",
		"desc": "Deal 8 damage to ALL enemies.",
		"effects": [{"kind": "damage", "amount": 8}],
	},
	"pommel_strike": {
		"name": "Pommel Strike", "cost": 1, "type": "attack", "target": "enemy",
		"desc": "Deal 9 damage. Draw 1 card.",
		"effects": [
			{"kind": "damage", "amount": 9},
			{"kind": "draw", "amount": 1},
		],
	},
	"shrug_it_off": {
		"name": "Shrug It Off", "cost": 1, "type": "skill", "target": "self",
		"desc": "Gain 8 Block. Draw 1 card.",
		"effects": [
			{"kind": "block", "amount": 8},
			{"kind": "draw", "amount": 1},
		],
	},
	"iron_wave": {
		"name": "Iron Wave", "cost": 1, "type": "attack", "target": "enemy",
		"desc": "Gain 5 Block. Deal 5 damage.",
		"effects": [
			{"kind": "block", "amount": 5},
			{"kind": "damage", "amount": 5},
		],
	},
	"twin_strike": {
		"name": "Twin Strike", "cost": 1, "type": "attack", "target": "enemy",
		"desc": "Deal 5 damage twice.",
		"effects": [{"kind": "damage", "amount": 5, "times": 2}],
	},
	"thunderclap": {
		"name": "Thunderclap", "cost": 1, "type": "attack", "target": "all_enemies",
		"desc": "Deal 4 damage and apply 1 Vulnerable to ALL enemies.",
		"effects": [
			{"kind": "damage", "amount": 4},
			{"kind": "status", "status": "vulnerable", "amount": 1, "on": "target"},
		],
	},
	"clothesline": {
		"name": "Clothesline", "cost": 2, "type": "attack", "target": "enemy",
		"desc": "Deal 12 damage. Apply 2 Weak.",
		"effects": [
			{"kind": "damage", "amount": 12},
			{"kind": "status", "status": "weak", "amount": 2, "on": "target"},
		],
	},
	"uppercut": {
		"name": "Uppercut", "cost": 2, "type": "attack", "target": "enemy",
		"desc": "Deal 13 damage. Apply 1 Weak and 1 Vulnerable.",
		"effects": [
			{"kind": "damage", "amount": 13},
			{"kind": "status", "status": "weak", "amount": 1, "on": "target"},
			{"kind": "status", "status": "vulnerable", "amount": 1, "on": "target"},
		],
	},
	"inflame": {
		"name": "Inflame", "cost": 1, "type": "power", "target": "self",
		"desc": "Gain 2 Strength.",
		"exhaust": true,
		"effects": [{"kind": "status", "status": "strength", "amount": 2, "on": "self"}],
	},
	"flex": {
		"name": "Flex", "cost": 0, "type": "skill", "target": "self",
		"desc": "Gain 2 Strength. Exhaust.",
		"exhaust": true,
		"effects": [{"kind": "status", "status": "strength", "amount": 2, "on": "self"}],
	},
	"anger": {
		"name": "Anger", "cost": 0, "type": "attack", "target": "enemy",
		"desc": "Deal 3 damage. Add a copy of Anger to your discard pile.",
		"effects": [
			{"kind": "damage", "amount": 3},
			{"kind": "add_card", "id": "anger"},
		],
	},
	"sword_boomerang": {
		"name": "Sword Boomerang", "cost": 1, "type": "attack", "target": "random_enemy",
		"desc": "Deal 3 damage to a random enemy 3 times.",
		"effects": [{"kind": "damage", "amount": 3, "times": 3}],
	},
	"bludgeon": {
		"name": "Bludgeon", "cost": 3, "type": "attack", "target": "enemy",
		"desc": "Deal 32 damage. Exhaust.",
		"exhaust": true,
		"effects": [{"kind": "damage", "amount": 32}],
	},
	"impervious": {
		"name": "Impervious", "cost": 2, "type": "skill", "target": "self",
		"desc": "Gain 30 Block. Exhaust.",
		"exhaust": true,
		"effects": [{"kind": "block", "amount": 30}],
	},
	"offering": {
		"name": "Offering", "cost": 0, "type": "skill", "target": "self",
		"desc": "Lose 6 HP. Gain 2 Energy. Draw 3 cards. Exhaust.",
		"exhaust": true,
		"effects": [
			{"kind": "lose_hp", "amount": 6},
			{"kind": "energy", "amount": 2},
			{"kind": "draw", "amount": 3},
		],
	},
	"heavy_blade": {
		"name": "Heavy Blade", "cost": 2, "type": "attack", "target": "enemy",
		"desc": "Deal 14 damage. Strength affects this card 3 times.",
		"effects": [{"kind": "damage", "amount": 14, "str_mult": 3}],
	},
	"disarm": {
		"name": "Disarm", "cost": 1, "type": "skill", "target": "enemy",
		"desc": "Enemy loses 2 Strength. Exhaust.",
		"exhaust": true,
		"effects": [{"kind": "status", "status": "strength", "amount": -2, "on": "target"}],
	},
}

## Cards that can appear in post-combat rewards (starters excluded).
const REWARD_POOL := [
	"cleave", "pommel_strike", "shrug_it_off", "iron_wave", "twin_strike",
	"thunderclap", "clothesline", "uppercut", "inflame", "flex", "anger",
	"sword_boomerang", "bludgeon", "impervious", "offering", "heavy_blade",
	"disarm",
]
