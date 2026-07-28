# Slay the Spire (Godot)

A fully playable, three-act *Slay the Spire*-style deckbuilding roguelike built with
**Godot 4.3+**. All four heroes, ascension levels, pure GDScript, pre-written `.tscn`
scenes, and hand-authored SVG art — no external assets or plugins.

![Godot 4.3+](https://img.shields.io/badge/Godot-4.3%2B-blue)

## How to run

1. Install [Godot 4.3 or newer](https://godotengine.org/download) (standard build, not .NET).
2. Open the Godot Project Manager, click **Import**, and select this folder's `project.godot`.
3. Press **F5** (Run Project).

## Four heroes

- **The Ironclad** — 80 HP, Burning Blood. Strength, heavy hits, exhaust synergies, Barricade.
- **The Silent** — 70 HP, Ring of the Snake. Poison, Shivs, Dexterity, discard tricks.
- **The Defect** — 75 HP, Cracked Core. Channels Lightning / Frost / Dark **orbs** in
  limited slots, amplified by Focus; Evoke them for bursts.
- **The Watcher** — 72 HP, Pure Water. Flows between **Calm and Wrath stances**,
  building Mantra toward Divinity; Retain cards and Miracles.

## The run

Character select with per-hero **Ascension levels (A1–A10)** — win to unlock the next,
progress saved in a persistent profile. Neow's Blessing, three acts (The Exordium /
The City / The Beyond) with their own rosters, elites and randomly chosen bosses,
**boss relic choices** between acts, and a final score screen. **Save & Continue**
checkpoints your run at the map.

## Combat

Energy, draw/discard/exhaust piles (clickable to inspect), 10-card hand limit, X-cost
cards, targeted attacks and potions, choose-a-card-to-discard prompts, telegraphed
intents, and the full status roster: Strength, Dexterity, Focus, Mantra, Vulnerable,
Weak, Frail, Poison, Thorns, Artifact, Intangible, Metallicize, Demon Form, Barricade,
Ritual, plated armor, next-turn block/energy, exhaust and per-card-played triggers.

## Content

- **100 cards** across four character pools plus Shivs, Miracles, statuses
  (Slimed / Wound / Dazed / Burn) and curses (Injury, Ascender's Bane)
- **29 enemies** with authentic intent AI: gold-stealing muggers that flee with the
  loot, healing Mystics, Dazed-spamming Sentries, an Intangible Nemesis — and
  **6 bosses** including the mode-shifting Guardian, the reviving Awakened One and
  the Donu & Deca duo
- **20 relics** + 6 boss relics (Fusion Hammer, Coffee Dripper, Philosopher's Stone,
  Runic Dome, Black Blood, Pandora's Box), **12 potions** (incl. Fairy in a Bottle
  auto-revive), **10 narrative events**, Neow blessings, per-act procedural maps

## Headless tests

```sh
godot --headless --path . -- --smoketest   # Silent+Defect+Watcher runs, potions, events, save/load
godot --headless --path . -- --bosstest    # all 6 bosses, boss relics, act transitions, final victory
```

## Project structure

```
project.godot            # Godot 4 config (autoloads scripts/run.gd as "Run", global theme)
theme/main_theme.tres    # Global UI theme
assets/icons/*.svg       # UI icons     assets/sprites/*.svg  # 4 heroes + 29 enemies
scenes/*.tscn            # Main, Menu, CharSelect, Neow, Map, Combat, Card, Enemy,
                         # Player, HudBar, CardPicker, Reward, BossReward, Rest,
                         # Shop, Treasure, Event, GameOver
scripts/
  run.gd                 # Autoload: run state, acts, ascension, profile, save/load
  cards_db.gd            # 100-card database     enemies_db.gd  # 29 enemies, 3 acts
  relics_db.gd           # 26 relics             potions_db.gd  # 12 potions
  combat_screen.gd       # Combat engine: orbs, stances, poison, statuses, animations
  card_ui.gd / enemy_ui.gd / player_view.gd / hud_bar.gd / card_picker.gd / float_text.gd
  *_screen.gd            # One controller per screen
```
