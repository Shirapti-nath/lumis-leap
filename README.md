# Lumi's Leap

A bright, kid-friendly 2D platformer built from scratch in **Godot 4** (GDScript) —
fully original characters, art, code, and sound. Run, double-jump, air-dash, wall-jump,
collect coins and hidden stars, stomp enemies, grab the grow power-up, and reach the
goal flag. The weather darkens into a storm as you lose lives.

## ▶ Play in your browser

**https://shirapti-nath.github.io/lumis-leap/**

No install needed — it runs on desktop and mobile.

## Controls

| Action | Keys |
|--------|------|
| Move | `A` / `D` or arrow keys |
| Jump / Double jump | `Space` / `Up` |
| Dash | `Shift` or `J` |
| Pause | `Esc` |
| Retry (on the end screen) | `R` |

On phones/tablets, on-screen touch buttons appear automatically.

## Features

- Smooth movement: acceleration/friction, coyote time, jump buffering, variable jump
  height, double jump, air-dash, wall-slide + wall-jump.
- Animated player (`AnimatedSprite2D`) with squash-and-stretch, screen shake, hit-stop,
  and particle "poofs".
- Coins + combo scoring, hidden stars, checkpoints, a goal flag, and a grow power-up.
- Patrolling/flying enemies (stomp to defeat) and spike hazards.
- Lives-driven **weather** system (clear → cloudy → storm with rain + lightning).
- Polished UI with a shared theme, animated HUD, and Main / Pause / Settings menus.
- Procedurally synthesised music + SFX, a `user://` save file (best score/stars), and
  accessibility toggles (screen shake, mute, touch controls).

## Run / edit locally

1. Install [Godot 4](https://godotengine.org) (Standard).
2. Open this folder's `project.godot` in Godot and press **F5**.

To regenerate the placeholder art:

```bash
python3 scripts/generate_placeholders.py
```

## Re-export the web build

In Godot: **Project → Export → Web** (single-threaded), or headless:

```bash
godot --headless --path . --export-release "Web" publish/index.html
```

The contents of `publish/` are what get deployed to GitHub Pages.

See `docs/PROGRESS.md` and `docs/MILESTONE_0*.md` for the full build log.
