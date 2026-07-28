class_name EnemiesDB
## Static enemy database: stats, intent AI patterns, and encounter tables.
## Intent fields: dmg, hits, block, strength, ritual (self buffs),
## weak_p / vuln_p / str_down_p (debuffs applied to the player), label.

static func make(id: String, rng: RandomNumberGenerator) -> Dictionary:
	var e := {
		"id": id, "name": "Enemy", "max_hp": 20, "hp": 20, "block": 0,
		"strength": 0, "vulnerable": 0, "weak": 0, "ritual": 0,
		"turn": 0, "intent": {},
	}
	match id:
		"cultist":
			e.name = "Cultist"
			e.max_hp = rng.randi_range(48, 54)
		"jaw_worm":
			e.name = "Jaw Worm"
			e.max_hp = rng.randi_range(42, 46)
		"louse":
			e.name = "Red Louse"
			e.max_hp = rng.randi_range(11, 16)
			e["bite"] = rng.randi_range(5, 7)
		"acid_slime":
			e.name = "Acid Slime"
			e.max_hp = rng.randi_range(28, 32)
		"spike_slime":
			e.name = "Spike Slime"
			e.max_hp = rng.randi_range(28, 32)
		"fungi_beast":
			e.name = "Fungi Beast"
			e.max_hp = rng.randi_range(22, 28)
		"gremlin_nob":
			e.name = "Gremlin Nob"
			e.max_hp = rng.randi_range(82, 86)
		"lagavulin":
			e.name = "Lagavulin"
			e.max_hp = rng.randi_range(109, 111)
		"guardian":
			e.name = "The Guardian"
			e.max_hp = 240
	e.hp = e.max_hp
	return e

static func choose_intent(e: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	match e.id:
		"cultist":
			if e.turn == 0:
				return {"label": "Incantation", "ritual": 3}
			return {"label": "Dark Strike", "dmg": 6}
		"jaw_worm":
			if e.turn == 0:
				return {"label": "Chomp", "dmg": 11}
			var r := rng.randf()
			if r < 0.35:
				return {"label": "Chomp", "dmg": 11}
			elif r < 0.65:
				return {"label": "Thrash", "dmg": 7, "block": 5}
			return {"label": "Bellow", "strength": 3, "block": 6}
		"louse":
			if rng.randf() < 0.75:
				return {"label": "Bite", "dmg": e.bite}
			return {"label": "Grow", "strength": 3}
		"acid_slime":
			if rng.randf() < 0.55:
				return {"label": "Tackle", "dmg": 10}
			return {"label": "Lick", "weak_p": 1}
		"spike_slime":
			if rng.randf() < 0.65:
				return {"label": "Flame Tackle", "dmg": 8}
			return {"label": "Lick", "weak_p": 1}
		"fungi_beast":
			if rng.randf() < 0.6:
				return {"label": "Bite", "dmg": 6}
			return {"label": "Grow", "strength": 3}
		"gremlin_nob":
			if e.turn == 0:
				return {"label": "Bellow", "strength": 3}
			if (e.turn - 1) % 3 == 0:
				return {"label": "Skull Bash", "dmg": 6, "vuln_p": 2}
			return {"label": "Rush", "dmg": 14}
		"lagavulin":
			if e.turn < 2:
				return {"label": "Sleeping", "block": 8}
			if (e.turn - 2) % 3 < 2:
				return {"label": "Attack", "dmg": 18}
			return {"label": "Siphon Soul", "str_down_p": 1, "weak_p": 1}
		"guardian":
			match e.turn % 4:
				0:
					return {"label": "Charging Up", "block": 15}
				1:
					return {"label": "Fierce Bash", "dmg": 26}
				2:
					return {"label": "Vent Steam", "weak_p": 2, "vuln_p": 2}
				_:
					return {"label": "Whirlwind", "dmg": 4, "hits": 4}
	return {"label": "Attack", "dmg": 5}

static func encounter(kind: String, row: int, rng: RandomNumberGenerator) -> Array:
	if kind == "boss":
		return ["guardian"]
	if kind == "elite":
		var elites: Array = [["gremlin_nob"], ["lagavulin"]]
		return elites[rng.randi_range(0, elites.size() - 1)].duplicate()
	var pools: Array
	if row < 3:
		pools = [
			["cultist"],
			["jaw_worm"],
			["louse", "louse"],
			["spike_slime"],
		]
	else:
		pools = [
			["cultist", "cultist"],
			["jaw_worm", "louse"],
			["fungi_beast", "fungi_beast"],
			["acid_slime", "spike_slime"],
			["acid_slime", "louse"],
		]
	return pools[rng.randi_range(0, pools.size() - 1)].duplicate()
