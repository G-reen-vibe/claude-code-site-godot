class_name PotionsDB
## Static potion database. Potions are usable during combat only.
## Fields: damage / block / strength / weak / vulnerable / heal_pct / energy /
## draw, target ("enemy" needs a target when several are alive).

const POTIONS: Dictionary = {
	"fire": {
		"name": "Fire Potion", "color": Color(0.95, 0.45, 0.25), "target": "enemy",
		"damage": 20, "text": "Deal 20 damage to a target enemy.",
	},
	"block": {
		"name": "Block Potion", "color": Color(0.4, 0.6, 0.95), "target": "self",
		"block": 12, "text": "Gain 12 Block.",
	},
	"strength": {
		"name": "Strength Potion", "color": Color(0.85, 0.3, 0.35), "target": "self",
		"strength": 2, "text": "Gain 2 Strength.",
	},
	"weak": {
		"name": "Weak Potion", "color": Color(0.55, 0.75, 0.4), "target": "enemy",
		"weak": 3, "text": "Apply 3 Weak to a target enemy.",
	},
	"fear": {
		"name": "Fear Potion", "color": Color(0.6, 0.4, 0.8), "target": "enemy",
		"vulnerable": 3, "text": "Apply 3 Vulnerable to a target enemy.",
	},
	"blood": {
		"name": "Blood Potion", "color": Color(0.8, 0.15, 0.2), "target": "self",
		"heal_pct": 0.2, "text": "Heal 20% of your Max HP.",
	},
	"energy": {
		"name": "Energy Potion", "color": Color(1.0, 0.75, 0.2), "target": "self",
		"energy": 2, "text": "Gain 2 Energy.",
	},
	"swift": {
		"name": "Swift Potion", "color": Color(0.35, 0.8, 0.8), "target": "self",
		"draw": 3, "text": "Draw 3 cards.",
	},
	"explosive": {
		"name": "Explosive Potion", "color": Color(0.9, 0.6, 0.2), "target": "self",
		"damage_all": 10, "text": "Deal 10 damage to ALL enemies.",
	},
	"dexterity": {
		"name": "Dexterity Potion", "color": Color(0.4, 0.85, 0.55), "target": "self",
		"dexterity": 2, "text": "Gain 2 Dexterity.",
	},
	"ancient": {
		"name": "Ancient Potion", "color": Color(0.85, 0.75, 0.4), "target": "self",
		"artifact": 1, "text": "Gain 1 Artifact (negates the next debuff).",
	},
	"fairy": {
		"name": "Fairy in a Bottle", "color": Color(0.95, 0.7, 0.9), "target": "self",
		"fairy": true, "text": "Cannot be drunk. When you would die, revive at 30% HP instead.",
	},
}

static func random_id(rng: RandomNumberGenerator) -> String:
	var keys := POTIONS.keys()
	return keys[rng.randi_range(0, keys.size() - 1)]
