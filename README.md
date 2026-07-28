# Slay the Spire (Godot)

A fully playable, single-act *Slay the Spire*-style deckbuilding roguelike built with
**Godot 4.3+**. Pure GDScript, pre-written `.tscn` scenes, and hand-authored SVG art —
no external assets or plugins.

![Godot 4.3+](https://img.shields.io/badge/Godot-4.3%2B-blue)

## How to run

1. Install [Godot 4.3 or newer](https://godotengine.org/download) (standard build, not .NET).
2. Open the Godot Project Manager, click **Import**, and select this folder's `project.godot`.
3. Press **F5** (Run Project).

## How to play

- **Neow's Blessing** — every run starts with a choice of boon.
- **Map** — climb from the bottom row to the summit. Hover nodes to see what awaits:
  monsters, elites, rest sites, merchants, treasure, and mysterious `?` events.
- **Combat** — click a card to play it (targeted attacks ask you to click an enemy),
  click a potion in the top bar to drink it, then press **End Turn**. Enemies telegraph
  their intents — attack numbers account for their Strength and your Vulnerable.
- **Rest sites** heal 30% of Max HP or upgrade a card. **Shops** sell cards, potions,
  relics, and card removal. **Events** offer risk-vs-reward choices.
- Two possible bosses guard the top: **The Guardian** (mode-shifts into a thorny
  defensive stance) and **Hexaghost** (fills your deck with Burns).

## Implemented mechanics

- Energy, draw/discard/exhaust piles with reshuffle, 10-card hand limit, X-cost cards
- Statuses: Strength (incl. temporary & multipliers), Vulnerable, Weak, Frail,
  Metallicize, Demon Form, Thorns (both sides), Ritual
- **38 cards**: 33 Ironclad-flavored playables with upgrades (including Whirlwind,
  Heavy Blade, Body Slam, Entrench, Rampage, Feel No Pain, Dark Embrace, Armaments),
  plus status cards (Slimed, Wound, Dazed, Burn) and the Injury curse
- Exhaust-trigger powers, ethereal cards, end-of-turn Burn damage
- **13 enemies** with authentic intent AI: Cultist, Jaw Worm, red & green Louses,
  Acid/Spike Slimes (that Slime your deck), Fungi Beast, Blue Slaver, elites
  (Gremlin Nob, Lagavulin, a trio of Sentries stuffing Dazed into your discard),
  and two bosses with scripted patterns
- **12 relics** and **8 potions** (belt of 3, click to drink, right-click to toss)
- **7 narrative events**, Neow starting blessings, procedurally generated branching map
- Animated combat: attack lunges, hit flashes, floating damage numbers, turn banners,
  fading deaths, pulsing map nodes and a bobbing map marker
- Hand-authored SVG sprites for every enemy, the Ironclad, icons, and the title screen

## Headless tests

```sh
godot --headless --path . -- --smoketest   # full loop: neow, combat, rewards, shop, event...
godot --headless --path . -- --bosstest    # defeats both bosses with a stacked deck
```

## Project structure

```
project.godot            # Godot 4 config (autoloads scripts/run.gd as "Run", global theme)
theme/main_theme.tres    # Global UI theme (buttons, panels, bars)
assets/icons/*.svg       # UI icons (intents, gold, energy, map nodes, ...)
assets/sprites/*.svg     # Character art (Ironclad + 13 enemies)
scenes/*.tscn            # Pre-written scenes: Main, Menu, Neow, Map, Combat, Card,
                         # Enemy, Player, HudBar, CardPicker, Reward, Rest, Shop,
                         # Treasure, Event, GameOver
scripts/
  run.gd                 # Autoload: run state (HP, gold, deck, relics, potions, map)
  cards_db.gd            # Card database          enemies_db.gd  # Enemy AI & encounters
  relics_db.gd           # Relic database         potions_db.gd  # Potion database
  combat_screen.gd       # Turn-based combat engine
  card_ui.gd / enemy_ui.gd / player_view.gd / hud_bar.gd / card_picker.gd
  float_text.gd          # Floating damage numbers
  *_screen.gd            # Map, menu, neow, reward, rest, shop, treasure, event, game-over
```
