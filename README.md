# Slay the Spire — Godot Demake

A fully playable, self-contained demake of *Slay the Spire* built with **Godot 4.3+**.
No external assets — everything is rendered with Godot's built-in UI nodes.

## How to run

1. Install [Godot 4.3 or newer](https://godotengine.org/download) (the standard build, not .NET).
2. Open the project: `Project Manager → Import → select project.godot`.
3. Press **F5** (or the Play button).

## How to play

- **Begin Run** starts a fresh run with the classic Ironclad starter deck
  (5× Strike, 4× Defend, 1× Bash), 80 HP, and 99 gold.
- **Map** — climb 8 floors from bottom to top. Click a highlighted node:
  - **M** Monster fight  ·  **E** Elite fight  ·  **R** Rest site (+25 HP)  ·  **B** Boss
- **Combat**
  - You get 3 Energy per turn and draw 5 cards.
  - Click a card to play it. If there are multiple enemies and the card needs a
    target, click an enemy (right-click cancels targeting).
  - Enemy **intents** are shown above each enemy (e.g. `Attack 11`, `Buffing`).
  - **Block** absorbs damage and expires at the start of your next turn.
  - Statuses: **Strength** (+damage), **Vulnerable** (take +50% damage),
    **Weak** (deal −25% damage). Vulnerable/Weak tick down each turn.
  - **End Turn** discards your hand and lets the enemies act.
- After each fight you gain gold and may pick 1 of 3 reward cards.
- Defeat **The Guardian** on floor 8 to win the run.

## Card pool

Starters: Strike, Defend, Bash.
Rewards: Cleave, Pommel Strike, Shrug It Off, Iron Wave, Twin Strike,
Thunderclap, Clothesline, Uppercut, Inflame, Flex, Anger, Sword Boomerang,
Bludgeon, Impervious, Offering, Heavy Blade, Disarm.

## Project structure

| Path | Purpose |
| --- | --- |
| `scenes/Main.tscn` | Pre-built UI for every screen (title, map, combat, rewards, rest, game over, victory) |
| `scenes/Card.tscn` | Reusable card widget |
| `scripts/Main.gd` | Game-flow state machine (screen switching, rewards, rest) |
| `scripts/RunState.gd` | Autoload (`Run`): HP, gold, deck, map generation, position |
| `scripts/CombatScreen.gd` | Turn-based combat engine (energy, block, statuses, intents, piles) |
| `scripts/MapScreen.gd` | Map rendering, path lines, reachable-node logic |
| `scripts/CardUI.gd` | Card widget behaviour |
| `scripts/CardLibrary.gd` | Data-driven card definitions (20 cards) |
| `scripts/EnemyLibrary.gd` | Data-driven enemy definitions + encounter tables (6 enemies) |

Combat uses the authentic Slay the Spire damage formula:
`(base + Strength) × 0.75 if Weak × 1.5 if Vulnerable`, rounded down,
with Block absorbing damage before HP.
