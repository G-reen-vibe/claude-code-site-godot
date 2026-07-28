# Slay the Spire (Godot)

A fully playable, three-act *Slay the Spire*-style deckbuilding roguelike built with
**Godot 4.3+**. Two playable characters, pure GDScript, pre-written `.tscn` scenes,
and hand-authored SVG art — no external assets or plugins.

![Godot 4.3+](https://img.shields.io/badge/Godot-4.3%2B-blue)

## How to run

1. Install [Godot 4.3 or newer](https://godotengine.org/download) (standard build, not .NET).
2. Open the Godot Project Manager, click **Import**, and select this folder's `project.godot`.
3. Press **F5** (Run Project).

## The run

- **Pick a hero** — the **Ironclad** (80 HP, Burning Blood, Strength & heavy hits) or
  the **Silent** (70 HP, Ring of the Snake, Poison, Shivs, Dexterity & card draw).
- **Neow's Blessing**, then climb **three acts** — The Exordium, The City, The Beyond —
  each with its own enemy roster, elites and a randomly chosen boss.
- After each act boss, choose a **Boss Relic** (extra energy with a downside,
  Black Blood, Pandora's Box...).
- **Save & Continue**: your run is checkpointed at the map; quit anytime and resume
  from the title screen.

## Combat

Energy, draw/discard/exhaust piles (click the pile buttons to inspect them),
10-card hand limit, X-cost cards, targeted attacks and potions, telegraphed enemy
intents (numbers account for Strength/Weak/Vulnerable), and full status support:
Strength, Dexterity, Vulnerable, Weak, Frail, Poison, Thorns (both sides),
Metallicize, Demon Form, Ritual, plated block, next-turn block.

## Content

- **62 cards**: 33 Ironclad + 24 Silent playables with upgrades, Shivs, plus
  Slimed/Wound/Dazed/Burn statuses and the Injury curse
- **29 enemies** with authentic intent AI across three acts — from Cultists and
  Jaw Worms to Byrds, muggers that steal gold, healing Mystics, a stab-happy
  book, Darklings, thorny Spikers — and **6 bosses**: The Guardian, Hexaghost,
  The Champ, Bronze Automaton, the reviving Awakened One, and Donu & Deca
- **18 relics** (12 regular + 6 boss relics), **8 potions** (belt of 3),
  **7 narrative events**, Neow blessings, procedurally generated maps per act
- Exhaust-trigger powers, per-card-played powers (A Thousand Cuts, After Image),
  scaling cards (Rampage, Glass Knife), teamwork enemies (heals, group buffs,
  group block) and a boss that comes back from the dead

## Presentation

Hand-authored SVG sprites for both heroes and all 29 enemies, 20 UI icons, a global
dark-fantasy theme, animated combat (lunges, hit flashes, floating damage numbers,
turn banners, death fades, rebirth flash), an act-aware map with dotted trails and
a bobbing marker, and a visual deck browser used everywhere cards are chosen.

## Headless tests

```sh
godot --headless --path . -- --smoketest   # Silent run: neow, combat, potions, shop, events, save/load
godot --headless --path . -- --bosstest    # all 6 bosses, boss relics, act transitions, final victory
```

## Project structure

```
project.godot            # Godot 4 config (autoloads scripts/run.gd as "Run", global theme)
theme/main_theme.tres    # Global UI theme
assets/icons/*.svg       # UI icons     assets/sprites/*.svg  # Heroes + 29 enemies
scenes/*.tscn            # Main, Menu, CharSelect, Neow, Map, Combat, Card, Enemy,
                         # Player, HudBar, CardPicker, Reward, BossReward, Rest,
                         # Shop, Treasure, Event, GameOver
scripts/
  run.gd                 # Autoload: run state, acts, characters, save/load
  cards_db.gd            # 62-card database      enemies_db.gd  # 29 enemies, 3 acts
  relics_db.gd           # 18 relics             potions_db.gd  # 8 potions
  combat_screen.gd       # Turn-based combat engine
  card_ui.gd / enemy_ui.gd / player_view.gd / hud_bar.gd / card_picker.gd / float_text.gd
  *_screen.gd            # One controller per screen
```
