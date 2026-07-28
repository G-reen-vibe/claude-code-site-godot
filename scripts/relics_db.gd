class_name RelicsDB
## Static relic database. Effects are implemented in combat_screen.gd,
## reward_screen.gd and run.gd where relevant.

const RELICS: Dictionary = {
	"burning_blood": {"name": "Burning Blood", "text": "At the end of combat, heal 6 HP."},
	"vajra": {"name": "Vajra", "text": "Start each combat with 1 Strength."},
	"bag_of_marbles": {"name": "Bag of Marbles", "text": "Enemies start combat with 1 Vulnerable."},
	"anchor": {"name": "Anchor", "text": "Start each combat with 10 Block."},
	"lantern": {"name": "Lantern", "text": "Gain 1 extra Energy on your first turn."},
	"orichalcum": {"name": "Orichalcum", "text": "If you end your turn without Block, gain 6 Block."},
	"bronze_scales": {"name": "Bronze Scales", "text": "Whenever an enemy hits you, deal 3 damage back."},
	"strawberry": {"name": "Strawberry", "text": "On pickup: raise your Max HP by 7."},
}

static func random_new(rng: RandomNumberGenerator, owned: Array) -> String:
	var candidates: Array = []
	for id in RELICS:
		if id != "burning_blood" and not owned.has(id):
			candidates.append(id)
	if candidates.is_empty():
		return ""
	return candidates[rng.randi_range(0, candidates.size() - 1)]
