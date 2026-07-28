class_name EnemiesDB
## Static enemy database: stats, sprites, intent AI patterns, encounter tables.
## Intent fields: dmg, hits, block, strength, ritual, thorns (self effects),
## weak_p / vuln_p / frail_p / str_down_p (player debuffs),
## add_card {id, count} (shuffles status cards into the player's discard pile),
## label (shown above the enemy).

const SPRITES := {
	"cultist": "res://assets/sprites/cultist.svg",
	"jaw_worm": "res://assets/sprites/jaw_worm.svg",
	"louse": "res://assets/sprites/louse_red.svg",
	"green_louse": "res://assets/sprites/louse_green.svg",
	"acid_slime": "res://assets/sprites/acid_slime.svg",
	"spike_slime": "res://assets/sprites/spike_slime.svg",
	"fungi_beast": "res://assets/sprites/fungi_beast.svg",
	"gremlin_nob": "res://assets/sprites/gremlin_nob.svg",
	"lagavulin": "res://assets/sprites/lagavulin.svg",
	"sentry": "res://assets/sprites/sentry.svg",
	"slaver": "res://assets/sprites/slaver.svg",
	"guardian": "res://assets/sprites/guardian.svg",
	"hexaghost": "res://assets/sprites/hexaghost.svg",
}

static func make(id: String, rng: RandomNumberGenerator) -> Dictionary:
	var e := {
		"id": id, "name": "Enemy", "max_hp": 20, "hp": 20, "block": 0,
		"strength": 0, "vulnerable": 0, "weak": 0, "ritual": 0, "thorns": 0,
		"turn": 0, "intent": {}, "extra": {}, "size": 150,
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
			e.size = 110
			e.extra["bite"] = rng.randi_range(5, 7)
		"green_louse":
			e.name = "Green Louse"
			e.max_hp = rng.randi_range(11, 17)
			e.size = 110
			e.extra["bite"] = rng.randi_range(5, 7)
		"acid_slime":
			e.name = "Acid Slime"
			e.max_hp = rng.randi_range(28, 32)
			e.size = 130
		"spike_slime":
			e.name = "Spike Slime"
			e.max_hp = rng.randi_range(28, 32)
			e.size = 130
		"fungi_beast":
			e.name = "Fungi Beast"
			e.max_hp = rng.randi_range(22, 28)
			e.size = 130
		"gremlin_nob":
			e.name = "Gremlin Nob"
			e.max_hp = rng.randi_range(82, 86)
			e.size = 190
		"lagavulin":
			e.name = "Lagavulin"
			e.max_hp = rng.randi_range(109, 111)
			e.size = 180
		"sentry":
			e.name = "Sentry"
			e.max_hp = rng.randi_range(38, 42)
			e.size = 140
		"slaver":
			e.name = "Blue Slaver"
			e.max_hp = rng.randi_range(46, 50)
		"guardian":
			e.name = "The Guardian"
			e.max_hp = 240
			e.size = 230
		"hexaghost":
			e.name = "Hexaghost"
			e.max_hp = 250
			e.size = 230
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
				return {"label": "Bite", "dmg": e.extra.bite}
			return {"label": "Grow", "strength": 3}
		"green_louse":
			if rng.randf() < 0.75:
				return {"label": "Bite", "dmg": e.extra.bite}
			return {"label": "Spit Web", "weak_p": 2}
		"acid_slime":
			var r := rng.randf()
			if r < 0.4:
				return {"label": "Tackle", "dmg": 10}
			elif r < 0.7:
				return {"label": "Corrosive Spit", "dmg": 3, "add_card": {"id": "slimed", "count": 1}}
			return {"label": "Lick", "weak_p": 1}
		"spike_slime":
			if rng.randf() < 0.55:
				return {"label": "Flame Tackle", "dmg": 8, "add_card": {"id": "slimed", "count": 1}}
			return {"label": "Lick", "frail_p": 1}
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
		"sentry":
			# Sentries alternate; offset by spawn position for a staggered volley.
			if (e.turn + e.extra.get("offset", 0)) % 2 == 0:
				return {"label": "Beam", "dmg": 9}
			return {"label": "Bolt", "add_card": {"id": "dazed", "count": 1}}
		"slaver":
			if (e.turn % 3) < 2:
				return {"label": "Stab", "dmg": 12}
			return {"label": "Rake", "dmg": 7, "weak_p": 1}
		"guardian":
			# Mode Shift: first time below half HP, goes defensive for two turns.
			if e.hp * 2 < e.max_hp and not e.extra.get("shifted", false):
				e.extra["shifted"] = true
				e.extra["defensive"] = 2
			if e.extra.get("defensive", 0) > 0:
				e.extra.defensive -= 1
				if e.extra.defensive == 1:
					return {"label": "Defensive Mode", "block": 20, "thorns": 3}
				return {"label": "Twin Slam", "dmg": 8, "hits": 2, "thorns": -3}
			match e.turn % 4:
				0:
					return {"label": "Charging Up", "block": 15}
				1:
					return {"label": "Fierce Bash", "dmg": 26}
				2:
					return {"label": "Vent Steam", "weak_p": 2, "vuln_p": 2}
				_:
					return {"label": "Whirlwind", "dmg": 4, "hits": 4}
		"hexaghost":
			if e.turn == 0:
				return {"label": "Activate", "block": 6}
			if e.turn == 1:
				return {"label": "Divider", "dmg": 3, "hits": 6}
			match (e.turn - 2) % 4:
				0:
					return {"label": "Sear", "dmg": 6, "add_card": {"id": "burn", "count": 1}}
				1:
					return {"label": "Tackle", "dmg": 5, "hits": 2}
				2:
					return {"label": "Sear", "dmg": 6, "add_card": {"id": "burn", "count": 1}}
				_:
					return {"label": "Inferno", "dmg": 2, "hits": 6, "add_card": {"id": "burn", "count": 2}}
	return {"label": "Attack", "dmg": 5}

static func encounter(kind: String, row: int, rng: RandomNumberGenerator) -> Array:
	if kind == "boss":
		return [["guardian"], ["hexaghost"]][rng.randi_range(0, 1)].duplicate()
	if kind == "elite":
		var elites: Array = [["gremlin_nob"], ["lagavulin"], ["sentry", "sentry", "sentry"]]
		return elites[rng.randi_range(0, elites.size() - 1)].duplicate()
	var pools: Array
	if row < 3:
		pools = [
			["cultist"],
			["jaw_worm"],
			["louse", "green_louse"],
			["louse", "louse"],
			["spike_slime"],
			["acid_slime"],
		]
	else:
		pools = [
			["cultist", "cultist"],
			["jaw_worm", "louse"],
			["fungi_beast", "fungi_beast"],
			["acid_slime", "spike_slime"],
			["slaver"],
			["green_louse", "acid_slime"],
			["louse", "louse", "green_louse"],
		]
	return pools[rng.randi_range(0, pools.size() - 1)].duplicate()
