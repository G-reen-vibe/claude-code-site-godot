class_name CardsDB
## Static card database. Effect fields interpreted by combat_screen.gd:
## damage, hits, block, draw, energy, vulnerable, weak, strength, strength_down,
## metallicize, demon_form, self_damage, heal_from_damage, copy_to_discard,
## exhaust, unplayable, x_cost, strength_mult, damage_from_block, double_block,
## rampage (also negative), armaments, feel_no_pain, dark_embrace, ethereal,
## end_turn_damage, poison, dexterity, next_turn_block, add_shivs,
## discard_random, poison_mult, thousand_cuts, after_image.
## "char": "ironclad" / "silent" / "any" (statuses, curses, shared starters).

const CARDS: Dictionary = {
	# ---------------------------------------------------------- shared ----
	"strike": {
		"name": "Strike", "type": "attack", "rarity": "starter", "cost": 1, "target": "enemy", "char": "any",
		"damage": 6, "text": "Deal 6 damage.",
		"up": {"damage": 9, "text": "Deal 9 damage."},
	},
	"defend": {
		"name": "Defend", "type": "skill", "rarity": "starter", "cost": 1, "target": "self", "char": "any",
		"block": 5, "text": "Gain 5 Block.",
		"up": {"block": 8, "text": "Gain 8 Block."},
	},
	# -------------------------------------------------------- ironclad ----
	"bash": {
		"name": "Bash", "type": "attack", "rarity": "starter", "cost": 2, "target": "enemy", "char": "ironclad",
		"damage": 8, "vulnerable": 2, "text": "Deal 8 damage. Apply 2 Vulnerable.",
		"up": {"damage": 10, "vulnerable": 3, "text": "Deal 10 damage. Apply 3 Vulnerable."},
	},
	"cleave": {
		"name": "Cleave", "type": "attack", "rarity": "common", "cost": 1, "target": "all", "char": "ironclad",
		"damage": 8, "text": "Deal 8 damage to ALL enemies.",
		"up": {"damage": 11, "text": "Deal 11 damage to ALL enemies."},
	},
	"clothesline": {
		"name": "Clothesline", "type": "attack", "rarity": "common", "cost": 2, "target": "enemy", "char": "ironclad",
		"damage": 12, "weak": 2, "text": "Deal 12 damage. Apply 2 Weak.",
		"up": {"damage": 14, "weak": 3, "text": "Deal 14 damage. Apply 3 Weak."},
	},
	"pommel_strike": {
		"name": "Pommel Strike", "type": "attack", "rarity": "common", "cost": 1, "target": "enemy", "char": "ironclad",
		"damage": 9, "draw": 1, "text": "Deal 9 damage. Draw 1 card.",
		"up": {"damage": 10, "draw": 2, "text": "Deal 10 damage. Draw 2 cards."},
	},
	"twin_strike": {
		"name": "Twin Strike", "type": "attack", "rarity": "common", "cost": 1, "target": "enemy", "char": "ironclad",
		"damage": 5, "hits": 2, "text": "Deal 5 damage twice.",
		"up": {"damage": 7, "text": "Deal 7 damage twice."},
	},
	"iron_wave": {
		"name": "Iron Wave", "type": "attack", "rarity": "common", "cost": 1, "target": "enemy", "char": "ironclad",
		"damage": 5, "block": 5, "text": "Gain 5 Block. Deal 5 damage.",
		"up": {"damage": 7, "block": 7, "text": "Gain 7 Block. Deal 7 damage."},
	},
	"shrug_it_off": {
		"name": "Shrug It Off", "type": "skill", "rarity": "common", "cost": 1, "target": "self", "char": "ironclad",
		"block": 8, "draw": 1, "text": "Gain 8 Block. Draw 1 card.",
		"up": {"block": 11, "text": "Gain 11 Block. Draw 1 card."},
	},
	"anger": {
		"name": "Anger", "type": "attack", "rarity": "common", "cost": 0, "target": "enemy", "char": "ironclad",
		"damage": 6, "copy_to_discard": true,
		"text": "Deal 6 damage. Add a copy of this card to your discard pile.",
		"up": {"damage": 8, "text": "Deal 8 damage. Add a copy of this card to your discard pile."},
	},
	"thunderclap": {
		"name": "Thunderclap", "type": "attack", "rarity": "common", "cost": 1, "target": "all", "char": "ironclad",
		"damage": 4, "vulnerable": 1, "text": "Deal 4 damage and apply 1 Vulnerable to ALL enemies.",
		"up": {"damage": 7, "text": "Deal 7 damage and apply 1 Vulnerable to ALL enemies."},
	},
	"sword_boomerang": {
		"name": "Sword Boomerang", "type": "attack", "rarity": "common", "cost": 1, "target": "enemy", "char": "ironclad",
		"damage": 3, "hits": 3, "text": "Deal 3 damage 3 times.",
		"up": {"hits": 4, "text": "Deal 3 damage 4 times."},
	},
	"heavy_blade": {
		"name": "Heavy Blade", "type": "attack", "rarity": "common", "cost": 2, "target": "enemy", "char": "ironclad",
		"damage": 14, "strength_mult": 3, "text": "Deal 14 damage. Strength affects this card 3 times.",
		"up": {"strength_mult": 5, "text": "Deal 14 damage. Strength affects this card 5 times."},
	},
	"body_slam": {
		"name": "Body Slam", "type": "attack", "rarity": "common", "cost": 1, "target": "enemy", "char": "ironclad",
		"damage": 0, "damage_from_block": true, "text": "Deal damage equal to your Block.",
		"up": {"cost": 0, "text": "Deal damage equal to your Block."},
	},
	"armaments": {
		"name": "Armaments", "type": "skill", "rarity": "common", "cost": 1, "target": "self", "char": "ironclad",
		"block": 5, "armaments": true,
		"text": "Gain 5 Block. Upgrade all cards in your hand for this combat.",
		"up": {"block": 8, "text": "Gain 8 Block. Upgrade all cards in your hand for this combat."},
	},
	"uppercut": {
		"name": "Uppercut", "type": "attack", "rarity": "uncommon", "cost": 2, "target": "enemy", "char": "ironclad",
		"damage": 13, "weak": 1, "vulnerable": 1,
		"text": "Deal 13 damage. Apply 1 Weak and 1 Vulnerable.",
		"up": {"weak": 2, "vulnerable": 2, "text": "Deal 13 damage. Apply 2 Weak and 2 Vulnerable."},
	},
	"bloodletting": {
		"name": "Bloodletting", "type": "skill", "rarity": "uncommon", "cost": 0, "target": "self", "char": "ironclad",
		"self_damage": 3, "energy": 2, "text": "Lose 3 HP. Gain 2 Energy.",
		"up": {"energy": 3, "text": "Lose 3 HP. Gain 3 Energy."},
	},
	"battle_trance": {
		"name": "Battle Trance", "type": "skill", "rarity": "uncommon", "cost": 0, "target": "self", "char": "ironclad",
		"draw": 3, "text": "Draw 3 cards.",
		"up": {"draw": 4, "text": "Draw 4 cards."},
	},
	"flex": {
		"name": "Flex", "type": "skill", "rarity": "uncommon", "cost": 0, "target": "self", "char": "ironclad",
		"strength": 2, "strength_down": 2,
		"text": "Gain 2 Strength. Lose 2 Strength at the end of this turn.",
		"up": {"strength": 4, "strength_down": 4, "text": "Gain 4 Strength. Lose 4 Strength at the end of this turn."},
	},
	"inflame": {
		"name": "Inflame", "type": "power", "rarity": "uncommon", "cost": 1, "target": "self", "char": "ironclad",
		"strength": 2, "text": "Gain 2 Strength.",
		"up": {"strength": 3, "text": "Gain 3 Strength."},
	},
	"shockwave": {
		"name": "Shockwave", "type": "skill", "rarity": "uncommon", "cost": 2, "target": "all", "char": "ironclad",
		"weak": 3, "vulnerable": 3, "exhaust": true,
		"text": "Apply 3 Weak and 3 Vulnerable to ALL enemies. Exhaust.",
		"up": {"weak": 5, "vulnerable": 5, "text": "Apply 5 Weak and 5 Vulnerable to ALL enemies. Exhaust."},
	},
	"metallicize": {
		"name": "Metallicize", "type": "power", "rarity": "uncommon", "cost": 1, "target": "self", "char": "ironclad",
		"metallicize": 3, "text": "At the end of your turn, gain 3 Block.",
		"up": {"metallicize": 4, "text": "At the end of your turn, gain 4 Block."},
	},
	"hemokinesis": {
		"name": "Hemokinesis", "type": "attack", "rarity": "uncommon", "cost": 1, "target": "enemy", "char": "ironclad",
		"self_damage": 2, "damage": 15, "text": "Lose 2 HP. Deal 15 damage.",
		"up": {"damage": 20, "text": "Lose 2 HP. Deal 20 damage."},
	},
	"carnage": {
		"name": "Carnage", "type": "attack", "rarity": "uncommon", "cost": 2, "target": "enemy", "char": "ironclad",
		"damage": 20, "text": "Deal 20 damage.",
		"up": {"damage": 28, "text": "Deal 28 damage."},
	},
	"whirlwind": {
		"name": "Whirlwind", "type": "attack", "rarity": "uncommon", "cost": 0, "target": "all", "char": "ironclad",
		"x_cost": true, "damage": 5,
		"text": "Deal 5 damage to ALL enemies X times. (X = all your Energy)",
		"up": {"damage": 8, "text": "Deal 8 damage to ALL enemies X times. (X = all your Energy)"},
	},
	"entrench": {
		"name": "Entrench", "type": "skill", "rarity": "uncommon", "cost": 2, "target": "self", "char": "ironclad",
		"double_block": true, "text": "Double your Block.",
		"up": {"cost": 1, "text": "Double your Block."},
	},
	"seeing_red": {
		"name": "Seeing Red", "type": "skill", "rarity": "uncommon", "cost": 1, "target": "self", "char": "ironclad",
		"energy": 2, "exhaust": true, "text": "Gain 2 Energy. Exhaust.",
		"up": {"cost": 0, "text": "Gain 2 Energy. Exhaust."},
	},
	"rampage": {
		"name": "Rampage", "type": "attack", "rarity": "uncommon", "cost": 2, "target": "enemy", "char": "ironclad",
		"damage": 8, "rampage": 5,
		"text": "Deal 8 damage. Each time this is played, its damage rises by 5 this combat.",
		"up": {"rampage": 8, "text": "Deal 8 damage. Each time this is played, its damage rises by 8 this combat."},
	},
	"feel_no_pain": {
		"name": "Feel No Pain", "type": "power", "rarity": "uncommon", "cost": 1, "target": "self", "char": "ironclad",
		"feel_no_pain": 3, "text": "Whenever a card is Exhausted, gain 3 Block.",
		"up": {"feel_no_pain": 4, "text": "Whenever a card is Exhausted, gain 4 Block."},
	},
	"bludgeon": {
		"name": "Bludgeon", "type": "attack", "rarity": "rare", "cost": 3, "target": "enemy", "char": "ironclad",
		"damage": 32, "text": "Deal 32 damage.",
		"up": {"damage": 42, "text": "Deal 42 damage."},
	},
	"impervious": {
		"name": "Impervious", "type": "skill", "rarity": "rare", "cost": 2, "target": "self", "char": "ironclad",
		"block": 30, "exhaust": true, "text": "Gain 30 Block. Exhaust.",
		"up": {"block": 40, "text": "Gain 40 Block. Exhaust."},
	},
	"demon_form": {
		"name": "Demon Form", "type": "power", "rarity": "rare", "cost": 3, "target": "self", "char": "ironclad",
		"demon_form": 2, "text": "At the start of each turn, gain 2 Strength.",
		"up": {"demon_form": 3, "text": "At the start of each turn, gain 3 Strength."},
	},
	"offering": {
		"name": "Offering", "type": "skill", "rarity": "rare", "cost": 0, "target": "self", "char": "ironclad",
		"self_damage": 6, "energy": 2, "draw": 3, "exhaust": true,
		"text": "Lose 6 HP. Gain 2 Energy. Draw 3 cards. Exhaust.",
		"up": {"draw": 5, "text": "Lose 6 HP. Gain 2 Energy. Draw 5 cards. Exhaust."},
	},
	"reaper": {
		"name": "Reaper", "type": "attack", "rarity": "rare", "cost": 2, "target": "all", "char": "ironclad",
		"damage": 4, "heal_from_damage": true,
		"text": "Deal 4 damage to ALL enemies. Heal HP equal to unblocked damage.",
		"up": {"damage": 5, "text": "Deal 5 damage to ALL enemies. Heal HP equal to unblocked damage."},
	},
	"dark_embrace": {
		"name": "Dark Embrace", "type": "power", "rarity": "rare", "cost": 2, "target": "self", "char": "ironclad",
		"dark_embrace": 1, "text": "Whenever a card is Exhausted, draw 1 card.",
		"up": {"cost": 1, "text": "Whenever a card is Exhausted, draw 1 card."},
	},
	# ---------------------------------------------------------- silent ----
	"neutralize": {
		"name": "Neutralize", "type": "attack", "rarity": "starter", "cost": 0, "target": "enemy", "char": "silent",
		"damage": 3, "weak": 1, "text": "Deal 3 damage. Apply 1 Weak.",
		"up": {"damage": 4, "weak": 2, "text": "Deal 4 damage. Apply 2 Weak."},
	},
	"survivor": {
		"name": "Survivor", "type": "skill", "rarity": "starter", "cost": 1, "target": "self", "char": "silent",
		"block": 8, "discard_random": 1, "text": "Gain 8 Block. Discard a card at random.",
		"up": {"block": 11, "text": "Gain 11 Block. Discard a card at random."},
	},
	"shiv": {
		"name": "Shiv", "type": "attack", "rarity": "special", "cost": 0, "target": "enemy", "char": "silent",
		"damage": 4, "exhaust": true, "text": "Deal 4 damage. Exhaust.",
		"up": {"damage": 6, "text": "Deal 6 damage. Exhaust."},
	},
	"poisoned_stab": {
		"name": "Poisoned Stab", "type": "attack", "rarity": "common", "cost": 1, "target": "enemy", "char": "silent",
		"damage": 6, "poison": 3, "text": "Deal 6 damage. Apply 3 Poison.",
		"up": {"damage": 8, "poison": 4, "text": "Deal 8 damage. Apply 4 Poison."},
	},
	"dagger_throw": {
		"name": "Dagger Throw", "type": "attack", "rarity": "common", "cost": 1, "target": "enemy", "char": "silent",
		"damage": 9, "draw": 1, "discard_random": 1,
		"text": "Deal 9 damage. Draw 1 card. Discard a card at random.",
		"up": {"damage": 12, "text": "Deal 12 damage. Draw 1 card. Discard a card at random."},
	},
	"slice": {
		"name": "Slice", "type": "attack", "rarity": "common", "cost": 0, "target": "enemy", "char": "silent",
		"damage": 6, "text": "Deal 6 damage.",
		"up": {"damage": 9, "text": "Deal 9 damage."},
	},
	"backflip": {
		"name": "Backflip", "type": "skill", "rarity": "common", "cost": 1, "target": "self", "char": "silent",
		"block": 5, "draw": 2, "text": "Gain 5 Block. Draw 2 cards.",
		"up": {"block": 8, "text": "Gain 8 Block. Draw 2 cards."},
	},
	"deadly_poison": {
		"name": "Deadly Poison", "type": "skill", "rarity": "common", "cost": 1, "target": "enemy", "char": "silent",
		"poison": 5, "text": "Apply 5 Poison.",
		"up": {"poison": 7, "text": "Apply 7 Poison."},
	},
	"dodge_and_roll": {
		"name": "Dodge and Roll", "type": "skill", "rarity": "common", "cost": 1, "target": "self", "char": "silent",
		"block": 4, "next_turn_block": 4, "text": "Gain 4 Block. Next turn, gain 4 Block.",
		"up": {"block": 6, "next_turn_block": 6, "text": "Gain 6 Block. Next turn, gain 6 Block."},
	},
	"cloak_and_dagger": {
		"name": "Cloak and Dagger", "type": "skill", "rarity": "common", "cost": 1, "target": "self", "char": "silent",
		"block": 6, "add_shivs": 1, "text": "Gain 6 Block. Add 1 Shiv to your hand.",
		"up": {"add_shivs": 2, "text": "Gain 6 Block. Add 2 Shivs to your hand."},
	},
	"blade_dance": {
		"name": "Blade Dance", "type": "skill", "rarity": "common", "cost": 1, "target": "self", "char": "silent",
		"add_shivs": 3, "text": "Add 3 Shivs to your hand.",
		"up": {"add_shivs": 4, "text": "Add 4 Shivs to your hand."},
	},
	"acrobatics": {
		"name": "Acrobatics", "type": "skill", "rarity": "common", "cost": 1, "target": "self", "char": "silent",
		"draw": 3, "discard_random": 1, "text": "Draw 3 cards. Discard a card at random.",
		"up": {"draw": 4, "text": "Draw 4 cards. Discard a card at random."},
	},
	"leg_sweep": {
		"name": "Leg Sweep", "type": "skill", "rarity": "uncommon", "cost": 2, "target": "enemy", "char": "silent",
		"block": 11, "weak": 2, "text": "Apply 2 Weak. Gain 11 Block.",
		"up": {"block": 14, "weak": 3, "text": "Apply 3 Weak. Gain 14 Block."},
	},
	"dash": {
		"name": "Dash", "type": "attack", "rarity": "uncommon", "cost": 2, "target": "enemy", "char": "silent",
		"damage": 10, "block": 10, "text": "Gain 10 Block. Deal 10 damage.",
		"up": {"damage": 13, "block": 13, "text": "Gain 13 Block. Deal 13 damage."},
	},
	"terror": {
		"name": "Terror", "type": "skill", "rarity": "uncommon", "cost": 1, "target": "enemy", "char": "silent",
		"vulnerable": 99, "exhaust": true, "text": "Apply 99 Vulnerable. Exhaust.",
		"up": {"cost": 0, "text": "Apply 99 Vulnerable. Exhaust."},
	},
	"footwork": {
		"name": "Footwork", "type": "power", "rarity": "uncommon", "cost": 1, "target": "self", "char": "silent",
		"dexterity": 2, "text": "Gain 2 Dexterity.",
		"up": {"dexterity": 3, "text": "Gain 3 Dexterity."},
	},
	"noxious_fumes": {
		"name": "Noxious Fumes", "type": "power", "rarity": "uncommon", "cost": 1, "target": "self", "char": "silent",
		"noxious_fumes": 2, "text": "At the start of each turn, apply 2 Poison to ALL enemies.",
		"up": {"noxious_fumes": 3, "text": "At the start of each turn, apply 3 Poison to ALL enemies."},
	},
	"catalyst": {
		"name": "Catalyst", "type": "skill", "rarity": "uncommon", "cost": 1, "target": "enemy", "char": "silent",
		"poison_mult": 2, "exhaust": true, "text": "Double an enemy's Poison. Exhaust.",
		"up": {"poison_mult": 3, "text": "Triple an enemy's Poison. Exhaust."},
	},
	"adrenaline": {
		"name": "Adrenaline", "type": "skill", "rarity": "rare", "cost": 0, "target": "self", "char": "silent",
		"energy": 1, "draw": 2, "exhaust": true, "text": "Gain 1 Energy. Draw 2 cards. Exhaust.",
		"up": {"energy": 2, "text": "Gain 2 Energy. Draw 2 cards. Exhaust."},
	},
	"die_die_die": {
		"name": "Die Die Die", "type": "attack", "rarity": "rare", "cost": 1, "target": "all", "char": "silent",
		"damage": 13, "exhaust": true, "text": "Deal 13 damage to ALL enemies. Exhaust.",
		"up": {"damage": 17, "text": "Deal 17 damage to ALL enemies. Exhaust."},
	},
	"glass_knife": {
		"name": "Glass Knife", "type": "attack", "rarity": "rare", "cost": 1, "target": "enemy", "char": "silent",
		"damage": 8, "hits": 2, "rampage": -2,
		"text": "Deal 8 damage twice. Its damage drops by 2 each time it is played.",
		"up": {"damage": 12, "text": "Deal 12 damage twice. Its damage drops by 2 each time it is played."},
	},
	"a_thousand_cuts": {
		"name": "A Thousand Cuts", "type": "power", "rarity": "rare", "cost": 2, "target": "self", "char": "silent",
		"thousand_cuts": 1, "text": "Whenever you play a card, deal 1 damage to ALL enemies.",
		"up": {"thousand_cuts": 2, "text": "Whenever you play a card, deal 2 damage to ALL enemies."},
	},
	"after_image": {
		"name": "After Image", "type": "power", "rarity": "rare", "cost": 1, "target": "self", "char": "silent",
		"after_image": 1, "text": "Whenever you play a card, gain 1 Block.",
		"up": {"after_image": 2, "text": "Whenever you play a card, gain 2 Block."},
	},
	# -------------------------------------------------- status & curse ----
	"slimed": {
		"name": "Slimed", "type": "status", "rarity": "status", "cost": 1, "target": "self", "char": "any",
		"exhaust": true, "text": "Unplayable filler. Exhaust.",
		"up": {},
	},
	"wound": {
		"name": "Wound", "type": "status", "rarity": "status", "cost": 0, "target": "self", "char": "any",
		"unplayable": true, "text": "Unplayable.",
		"up": {},
	},
	"dazed": {
		"name": "Dazed", "type": "status", "rarity": "status", "cost": 0, "target": "self", "char": "any",
		"unplayable": true, "ethereal": true, "text": "Unplayable. Ethereal: exhausts at end of turn.",
		"up": {},
	},
	"burn": {
		"name": "Burn", "type": "status", "rarity": "status", "cost": 0, "target": "self", "char": "any",
		"unplayable": true, "end_turn_damage": 2,
		"text": "Unplayable. At the end of your turn, take 2 damage.",
		"up": {},
	},
	"injury": {
		"name": "Injury", "type": "curse", "rarity": "curse", "cost": 0, "target": "self", "char": "any",
		"unplayable": true, "text": "Unplayable. A permanent wound.",
		"up": {},
	},
}

static func get_def(entry: Dictionary) -> Dictionary:
	var base: Dictionary = CARDS[entry.id]
	var def := base.duplicate(true)
	def.erase("up")
	if entry.get("up", false) and not base.up.is_empty():
		for k in base.up:
			def[k] = base.up[k]
		def["display_name"] = str(base.name) + "+"
	else:
		def["display_name"] = base.name
	return def

static func can_upgrade(entry: Dictionary) -> bool:
	return not entry.get("up", false) and not CARDS[entry.id].up.is_empty()

static func describe(entry: Dictionary) -> String:
	var def := get_def(entry)
	return "%s  [%s, %d Energy]  %s" % [
		def.display_name, String(def.type).capitalize(), def.cost, def.text,
	]

static func ids_by_rarity(rarity: String, character: String) -> Array:
	var out: Array = []
	for id in CARDS:
		if CARDS[id].rarity == rarity and CARDS[id].char == character:
			out.append(id)
	return out

static func random_rewards(rng: RandomNumberGenerator, character: String, n: int = 3) -> Array:
	var out: Array = []
	var guard := 0
	while out.size() < n and guard < 300:
		guard += 1
		var roll := rng.randf()
		var rarity := "common"
		if roll < 0.07:
			rarity = "rare"
		elif roll < 0.42:
			rarity = "uncommon"
		var pool := ids_by_rarity(rarity, character)
		var id: String = pool[rng.randi_range(0, pool.size() - 1)]
		if not out.has(id):
			out.append(id)
	return out

static func random_of_pool(rng: RandomNumberGenerator, character: String) -> String:
	# Any obtainable (non-starter, non-status, non-curse) card for the character.
	var pool: Array = []
	for r in ["common", "uncommon", "rare"]:
		pool.append_array(ids_by_rarity(r, character))
	return pool[rng.randi_range(0, pool.size() - 1)]
