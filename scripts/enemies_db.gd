class_name EnemiesDB
## Static enemy database: stats, sprites, intent AI patterns, encounter tables.
## Intent fields: dmg, hits, block, strength, ritual, thorns (self effects),
## weak_p / vuln_p / frail_p / str_down_p (player debuffs), steal_gold,
## add_card {id, count} (status cards into the player's discard pile),
## heal_allies / buff_all / block_all (team effects), heal_self_from_damage,
## label (shown above the enemy). e.extra.revive = {hp, used} enables rebirth.

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
	"byrd": "res://assets/sprites/byrd.svg",
	"mugger": "res://assets/sprites/mugger.svg",
	"shelled_parasite": "res://assets/sprites/shelled_parasite.svg",
	"chosen": "res://assets/sprites/chosen.svg",
	"centurion": "res://assets/sprites/centurion.svg",
	"mystic": "res://assets/sprites/mystic.svg",
	"book_of_stabbing": "res://assets/sprites/book_of_stabbing.svg",
	"taskmaster": "res://assets/sprites/taskmaster.svg",
	"champ": "res://assets/sprites/champ.svg",
	"automaton": "res://assets/sprites/automaton.svg",
	"darkling": "res://assets/sprites/darkling.svg",
	"orb_walker": "res://assets/sprites/orb_walker.svg",
	"spiker": "res://assets/sprites/spiker.svg",
	"maw": "res://assets/sprites/maw.svg",
	"giant_head": "res://assets/sprites/giant_head.svg",
	"nemesis": "res://assets/sprites/nemesis.svg",
	"awakened_one": "res://assets/sprites/awakened_one.svg",
	"donu": "res://assets/sprites/donu.svg",
	"deca": "res://assets/sprites/deca.svg",
}

static func make(id: String, rng: RandomNumberGenerator) -> Dictionary:
	var e := {
		"id": id, "name": "Enemy", "max_hp": 20, "hp": 20, "block": 0,
		"strength": 0, "vulnerable": 0, "weak": 0, "ritual": 0, "thorns": 0,
		"poison": 0, "turn": 0, "intent": {}, "extra": {}, "size": 150,
	}
	match id:
		# ------------------------------------------------------- act 1 ----
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
		# ------------------------------------------------------- act 2 ----
		"byrd":
			e.name = "Byrd"
			e.max_hp = rng.randi_range(26, 30)
			e.size = 120
		"mugger":
			e.name = "Mugger"
			e.max_hp = rng.randi_range(48, 52)
		"shelled_parasite":
			e.name = "Shelled Parasite"
			e.max_hp = rng.randi_range(68, 72)
			e.block = 14
			e.size = 160
		"chosen":
			e.name = "Chosen"
			e.max_hp = rng.randi_range(95, 99)
			e.size = 170
		"centurion":
			e.name = "Centurion"
			e.max_hp = rng.randi_range(76, 80)
			e.size = 160
		"mystic":
			e.name = "Mystic"
			e.max_hp = rng.randi_range(48, 56)
		"book_of_stabbing":
			e.name = "Book of Stabbing"
			e.max_hp = rng.randi_range(160, 164)
			e.size = 200
			e.extra["stabs"] = 1
		"taskmaster":
			e.name = "Taskmaster"
			e.max_hp = rng.randi_range(54, 60)
		"champ":
			e.name = "The Champ"
			e.max_hp = 300
			e.size = 230
		"automaton":
			e.name = "Bronze Automaton"
			e.max_hp = 300
			e.size = 230
		# ------------------------------------------------------- act 3 ----
		"darkling":
			e.name = "Darkling"
			e.max_hp = rng.randi_range(48, 56)
			e.size = 130
		"orb_walker":
			e.name = "Orb Walker"
			e.max_hp = rng.randi_range(90, 96)
			e.size = 160
		"spiker":
			e.name = "Spiker"
			e.max_hp = rng.randi_range(42, 56)
			e.thorns = 4
			e.size = 130
		"maw":
			e.name = "The Maw"
			e.max_hp = 200
			e.size = 200
		"giant_head":
			e.name = "Giant Head"
			e.max_hp = 320
			e.size = 220
			e.extra["time"] = 0
		"nemesis":
			e.name = "Nemesis"
			e.max_hp = 185
			e.size = 190
		"awakened_one":
			e.name = "Awakened One"
			e.max_hp = 300
			e.size = 230
			e.extra["revive"] = {"hp": 150, "used": false}
		"donu":
			e.name = "Donu"
			e.max_hp = 125
			e.size = 180
		"deca":
			e.name = "Deca"
			e.max_hp = 125
			e.size = 180
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
			if (e.turn + e.extra.get("offset", 0)) % 2 == 0:
				return {"label": "Beam", "dmg": 9}
			return {"label": "Bolt", "add_card": {"id": "dazed", "count": 1}}
		"slaver":
			if (e.turn % 3) < 2:
				return {"label": "Stab", "dmg": 12}
			return {"label": "Rake", "dmg": 7, "weak_p": 1}
		"guardian":
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
					return {"label": "Fierce Bash", "dmg": 24}
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
		# ----------------------------------------------------------- act 2 ----
		"byrd":
			var r := rng.randf()
			if r < 0.5:
				return {"label": "Peck", "dmg": 2, "hits": 4}
			elif r < 0.8:
				return {"label": "Swoop", "dmg": 12}
			return {"label": "Caw", "strength": 1}
		"mugger":
			if (e.turn % 3) < 2:
				return {"label": "Mug", "dmg": 10, "steal_gold": 15}
			return {"label": "Lunge", "dmg": 16}
		"shelled_parasite":
			var r := rng.randf()
			if r < 0.4:
				return {"label": "Fell", "dmg": 18}
			elif r < 0.7:
				return {"label": "Double Strike", "dmg": 6, "hits": 2}
			return {"label": "Suck", "dmg": 10, "heal_self_from_damage": true}
		"chosen":
			if e.turn == 0:
				return {"label": "Hex", "weak_p": 2, "frail_p": 2}
			match e.turn % 3:
				0:
					return {"label": "Zap", "dmg": 18}
				1:
					return {"label": "Poke", "dmg": 5, "hits": 2}
				_:
					return {"label": "Drain", "weak_p": 2, "strength": 3}
		"centurion":
			match e.turn % 3:
				0:
					return {"label": "Slash", "dmg": 12}
				1:
					return {"label": "Fury", "dmg": 6, "hits": 3}
				_:
					return {"label": "Defend", "block": 15}
		"mystic":
			match e.turn % 3:
				0:
					return {"label": "Heal", "heal_allies": 16}
				1:
					return {"label": "Buff", "buff_all": 2}
				_:
					return {"label": "Attack Debuff", "dmg": 8, "frail_p": 2}
		"book_of_stabbing":
			if e.turn % 3 == 2:
				return {"label": "Single Stab", "dmg": 24}
			e.extra.stabs += 1
			return {"label": "Multi-Stab", "dmg": 6, "hits": e.extra.stabs}
		"taskmaster":
			return {"label": "Scouring Whip", "dmg": 7, "add_card": {"id": "wound", "count": 1}}
		"champ":
			if e.hp * 2 < e.max_hp and not e.extra.get("angered", false):
				e.extra["angered"] = true
				return {"label": "Anger", "strength": 4, "block": 10}
			match e.turn % 4:
				0:
					return {"label": "Heavy Slash", "dmg": 16}
				1:
					return {"label": "Defensive Stance", "block": 20, "strength": 2}
				2:
					return {"label": "Face Slap", "dmg": 14, "frail_p": 2}
				_:
					return {"label": "Execute", "dmg": 10, "hits": 2}
		"automaton":
			match e.turn % 6:
				0:
					return {"label": "Flail", "dmg": 7, "hits": 2}
				1:
					return {"label": "Boost", "block": 9, "strength": 3}
				2:
					return {"label": "Flail", "dmg": 7, "hits": 2}
				3:
					return {"label": "Boost", "block": 9, "strength": 3}
				4:
					return {"label": "HYPER BEAM", "dmg": 32}
				_:
					return {"label": "Stunned", "block": 0}
		# ----------------------------------------------------------- act 3 ----
		"darkling":
			var r := rng.randf()
			if r < 0.4:
				return {"label": "Nip", "dmg": 8 + e.turn}
			elif r < 0.7:
				return {"label": "Chomp", "dmg": 8, "hits": 2}
			return {"label": "Harden", "block": 12, "strength": 2}
		"orb_walker":
			if e.turn % 2 == 0:
				return {"label": "Laser", "dmg": 10, "add_card": {"id": "burn", "count": 1}}
			return {"label": "Claw", "dmg": 15}
		"spiker":
			if rng.randf() < 0.5:
				return {"label": "Cut", "dmg": 7}
			return {"label": "Spike", "thorns": 2}
		"maw":
			match e.turn % 4:
				0:
					return {"label": "Roar", "weak_p": 2, "frail_p": 2}
				1:
					return {"label": "Slam", "dmg": 22}
				2:
					return {"label": "Drool", "strength": 3}
				_:
					return {"label": "Nom", "dmg": 5, "hits": 3}
		"giant_head":
			if e.turn < 4:
				if e.turn % 2 == 0:
					return {"label": "Count", "dmg": 13}
				return {"label": "Glare", "weak_p": 1}
			e.extra.time += 1
			return {"label": "It Is Time", "dmg": 26 + 4 * (e.extra.time - 1)}
		"nemesis":
			match e.turn % 3:
				0:
					return {"label": "Attack", "dmg": 6, "hits": 3}
				1:
					return {"label": "Debuff", "add_card": {"id": "burn", "count": 3}}
				_:
					return {"label": "Scythe", "dmg": 32}
		"awakened_one":
			if e.extra.revive.used:
				match e.turn % 3:
					0:
						return {"label": "Dark Echo", "dmg": 26}
					1:
						return {"label": "Sludge", "dmg": 18, "add_card": {"id": "dazed", "count": 1}}
					_:
						return {"label": "Tackle", "dmg": 10, "hits": 3}
			if e.turn == 0:
				return {"label": "Curiosity", "strength": 2}
			if e.turn % 2 == 1:
				return {"label": "Slash", "dmg": 18}
			return {"label": "Soul Strike", "dmg": 5, "hits": 4}
		"donu":
			if e.turn % 2 == 0:
				return {"label": "Circle of Power", "buff_all": 2}
			return {"label": "Beam", "dmg": 9, "hits": 2}
		"deca":
			if e.turn % 2 == 0:
				return {"label": "Beam", "dmg": 9, "hits": 2}
			return {"label": "Square of Protection", "block_all": 12}
	return {"label": "Attack", "dmg": 5}

static func encounter(kind: String, row: int, rng: RandomNumberGenerator, act: int = 1) -> Array:
	var pools: Array
	match act:
		2:
			if kind == "boss":
				pools = [["champ"], ["automaton"]]
			elif kind == "elite":
				pools = [["book_of_stabbing"], ["taskmaster", "slaver"]]
			elif row < 3:
				pools = [["byrd", "byrd"], ["mugger"], ["shelled_parasite"], ["chosen"]]
			else:
				pools = [
					["chosen", "byrd"],
					["centurion", "mystic"],
					["shelled_parasite", "byrd"],
					["mugger", "mugger"],
					["byrd", "byrd", "byrd"],
				]
		3:
			if kind == "boss":
				pools = [["awakened_one"], ["donu", "deca"]]
			elif kind == "elite":
				pools = [["giant_head"], ["nemesis"]]
			elif row < 3:
				pools = [["darkling", "darkling"], ["orb_walker"], ["spiker", "spiker"]]
			else:
				pools = [
					["darkling", "darkling", "darkling"],
					["orb_walker", "spiker"],
					["maw"],
					["orb_walker", "orb_walker"],
				]
		_:
			if kind == "boss":
				pools = [["guardian"], ["hexaghost"]]
			elif kind == "elite":
				pools = [["gremlin_nob"], ["lagavulin"], ["sentry", "sentry", "sentry"]]
			elif row < 3:
				pools = [
					["cultist"], ["jaw_worm"], ["louse", "green_louse"],
					["louse", "louse"], ["spike_slime"], ["acid_slime"],
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
