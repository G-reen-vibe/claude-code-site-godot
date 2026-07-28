class_name RelicsDB
## Static relic database. Effects are implemented in combat_screen.gd,
## reward_screen.gd and run.gd where relevant.

const RELICS: Dictionary = {
	"burning_blood": {
		"name": "Burning Blood", "color": Color(0.85, 0.25, 0.2),
		"text": "At the end of combat, heal 6 HP.",
	},
	"vajra": {
		"name": "Vajra", "color": Color(0.9, 0.55, 0.3),
		"text": "Start each combat with 1 Strength.",
	},
	"bag_of_marbles": {
		"name": "Bag of Marbles", "color": Color(0.6, 0.6, 0.9),
		"text": "Enemies start combat with 1 Vulnerable.",
	},
	"anchor": {
		"name": "Anchor", "color": Color(0.5, 0.6, 0.7),
		"text": "Start each combat with 10 Block.",
	},
	"lantern": {
		"name": "Lantern", "color": Color(1.0, 0.85, 0.4),
		"text": "Gain 1 extra Energy on your first turn.",
	},
	"orichalcum": {
		"name": "Orichalcum", "color": Color(0.4, 0.8, 0.7),
		"text": "If you end your turn without Block, gain 6 Block.",
	},
	"bronze_scales": {
		"name": "Bronze Scales", "color": Color(0.7, 0.5, 0.3),
		"text": "Whenever an enemy hits you, deal 3 damage back.",
	},
	"strawberry": {
		"name": "Strawberry", "color": Color(0.9, 0.3, 0.4),
		"text": "On pickup: raise your Max HP by 7.",
	},
	"blood_vial": {
		"name": "Blood Vial", "color": Color(0.75, 0.2, 0.25),
		"text": "At the start of each combat, heal 2 HP.",
	},
	"meat_on_the_bone": {
		"name": "Meat on the Bone", "color": Color(0.85, 0.6, 0.45),
		"text": "If your HP is at or below 50% after combat, heal 12 HP.",
	},
	"boot": {
		"name": "The Boot", "color": Color(0.6, 0.45, 0.3),
		"text": "Your attacks always deal at least 5 damage.",
	},
	"toy_ornithopter": {
		"name": "Toy Ornithopter", "color": Color(0.5, 0.75, 0.9),
		"text": "Whenever you use a potion, heal 5 HP.",
	},
	"ring_of_snake": {
		"name": "Ring of the Snake", "color": Color(0.4, 0.8, 0.5), "starter": true,
		"text": "Draw 2 additional cards on your first turn of each combat.",
	},
	# ------------------------------------------------------ boss relics ----
	"fusion_hammer": {
		"name": "Fusion Hammer", "color": Color(0.9, 0.6, 0.2), "boss": true, "energy": true,
		"text": "Gain 1 Energy each turn. You can no longer Smith at Rest Sites.",
	},
	"coffee_dripper": {
		"name": "Coffee Dripper", "color": Color(0.65, 0.45, 0.3), "boss": true, "energy": true,
		"text": "Gain 1 Energy each turn. You can no longer Rest at Rest Sites.",
	},
	"philosophers_stone": {
		"name": "Philosopher's Stone", "color": Color(0.85, 0.3, 0.5), "boss": true, "energy": true,
		"text": "Gain 1 Energy each turn. ALL enemies start combat with 1 Strength.",
	},
	"runic_dome": {
		"name": "Runic Dome", "color": Color(0.5, 0.55, 0.75), "boss": true, "energy": true,
		"text": "Gain 1 Energy each turn. You can no longer see enemy Intents.",
	},
	"black_blood": {
		"name": "Black Blood", "color": Color(0.4, 0.1, 0.15), "boss": true,
		"text": "Replaces Burning Blood. At the end of combat, heal 12 HP.",
	},
	"pandoras_box": {
		"name": "Pandora's Box", "color": Color(0.75, 0.7, 0.85), "boss": true,
		"text": "On pickup: transform all your Strikes and Defends into random cards.",
	},
}

static func random_new(rng: RandomNumberGenerator, owned: Array) -> String:
	var candidates: Array = []
	for id in RELICS:
		var r: Dictionary = RELICS[id]
		if r.get("boss", false) or r.get("starter", false) or id == "burning_blood":
			continue
		if not owned.has(id):
			candidates.append(id)
	if candidates.is_empty():
		return ""
	return candidates[rng.randi_range(0, candidates.size() - 1)]

static func random_boss_relics(rng: RandomNumberGenerator, owned: Array, n: int = 3) -> Array:
	var candidates: Array = []
	for id in RELICS:
		if RELICS[id].get("boss", false) and not owned.has(id):
			candidates.append(id)
	var out: Array = []
	while out.size() < n and not candidates.is_empty():
		out.append(candidates.pop_at(rng.randi_range(0, candidates.size() - 1)))
	return out

static func energy_bonus(owned: Array) -> int:
	var bonus := 0
	for id in owned:
		if RELICS[id].get("energy", false):
			bonus += 1
	return bonus
