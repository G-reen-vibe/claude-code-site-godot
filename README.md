# Slay the Spire (Godot)

A fully playable, single-act *Slay the Spire*-style deckbuilding roguelike built with
**Godot 4.3+**, using pure GDScript and pre-written `.tscn` scene files (no art assets
required — everything is rendered with Control nodes).

## How to run

1. Install [Godot 4.3 or newer](https://godotengine.org/download) (the standard build, not .NET).
2. Open the Godot Project Manager, click **Import**, and select this folder's `project.godot`.
3. Press **F5** (Run Project).

## How to play

- **Map** — climb from the bottom row to the top. Click a highlighted node to travel.
  `M` monster, `E` elite, `R` rest site, `S` shop, `T` treasure, `B` boss.
- **Combat** — click a card to play it. If several enemies are alive, targeted attacks
  ask you to click the enemy to hit. Press **End Turn** when done; enemies then act out
  the intents telegraphed above their heads (`ATK`, `BLK`, `BUFF`, `DEBUFF`).
- **Rest sites** heal 30% of Max HP or let you upgrade a card. **Shops** sell cards and
  card removal. **Treasure** grants relics. Beat **The Guardian** on floor 13 to win.

## Implemented mechanics

- Energy, draw/discard/exhaust piles with automatic reshuffle, 10-card hand limit
- Statuses: Strength (incl. temporary), Vulnerable, Weak, Metallicize, Demon Form, Thorns, Ritual
- 28 cards (Ironclad-flavored) across starter/common/uncommon/rare, each with an upgraded version
- 9 enemies with authentic intent AI patterns (Cultist, Jaw Worm, Red Louse, slimes,
  Fungi Beast, elites Gremlin Nob & Lagavulin, and The Guardian boss)
- 8 relics (Burning Blood, Vajra, Bag of Marbles, Anchor, Lantern, Orichalcum,
  Bronze Scales, Strawberry)
- Procedurally generated branching map, card rewards, gold, shop, card removal,
  upgrades, treasure, victory/defeat screens

## Project structure

```
project.godot          # Godot 4 project config (autoloads scripts/run.gd as "Run")
scenes/                # Pre-written TSCN scene files (Main, Menu, Map, Combat, Card,
                       # Enemy, Reward, Rest, Shop, Treasure, GameOver)
scripts/
  run.gd               # Autoload: run state (HP, gold, deck, relics, map)
  cards_db.gd          # Card database (static)
  enemies_db.gd        # Enemy stats, intent AI, encounter tables (static)
  relics_db.gd         # Relic database (static)
  main.gd              # Screen switcher
  combat_screen.gd     # Turn-based combat engine
  *_screen.gd          # Map, menu, reward, rest, shop, treasure, game-over screens
  card_ui.gd, enemy_ui.gd, edges.gd   # Reusable UI components
```
