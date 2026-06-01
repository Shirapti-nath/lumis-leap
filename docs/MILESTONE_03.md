# Milestone 3 — Polish, Weather, Performance & Systems

This milestone turns the working Milestone 2 level into a polished, market-ready
game: crisp scalable UI, advanced animated player + UI motion, a weather system that
intensifies as lives are lost, a performance pass, and the core systems a finished
game needs (audio, save, menus). All new art is still procedurally generated, and all
audio is synthesised at runtime — there is **no third-party or copyrighted content**.

- **Engine:** Godot 4.x (GDScript)
- **Status:** ✅ Complete
- **Main scene is now:** `ui/MainMenu.tscn`

---

## 3A — Crisp UI foundation

**The blur problem:** the project used the `viewport` stretch mode, which renders the
whole game into a tiny 640×360 buffer and then upscales it — so HUD text looked soft.

**Fix:**
- `project.godot` → `window/stretch/mode="canvas_items"`. The world (pixel art) still
  scales as a unit, but **text/UI now render at the native window resolution** = sharp.
- New shared **`ui/Theme.tres`** (default font, sizes, white fill + dark outline for
  readability over the bright sky). Applied to a themed `Root` `Control` in the HUD so
  every label/button inherits one consistent style.

> Note: a bundled OFL font was planned, but the download was blocked by the
> environment's safety policy. Under `canvas_items` the default font is already crisp,
> so the Theme falls back to it gracefully (exactly as the plan allowed).

## 3A.2 — HUD motion + buttons

In `ui/HUD.gd` / `ui/HUD.tscn`:
- **Score count-up** — the score rolls up to its new value with a tween.
- **Pulses** — coins/stars/lives/combo labels pop on change.
- **Floating `+1` popups** on coin pickup that drift up and fade.
- **Banner slide-in** — Level Complete / Game Over scales in with a `TRANS_BACK` ease.
- **Real buttons** — `Retry` and `Play Again` (keyboard `R` still works).

## 3B — Advanced player animation

- `scripts/generate_placeholders.py` now renders procedural frames into
  `assets/player/`: `idle` (2), `run` (4), `jump`, `fall`, `dash`, `hurt`.
- **`characters/PlayerFrames.tres`** (`SpriteFrames`) bundles them into named clips.
- `characters/Player.tscn` swaps the `Sprite2D` for an **`AnimatedSprite2D`** (same node
  name, so existing paths and the squash/stretch + i-frame tweens are untouched).
- `Player.gd._update_animation()` picks the clip each frame from the existing state
  (`_dash_timer`, `is_on_floor()`, `velocity`).

## 3C — Weather system (lives-driven)

- **`managers/WeatherManager.gd`** (autoload) maps lives → intensity and broadcasts
  `weather_changed`: 3 lives = clear, 2 = cloudy (0.5), 1 or 0 = storm (1.0).
- **`effects/WeatherFX.tscn`** is a screen-space overlay that eases a rain
  `CPUParticles2D`, fades a dark storm tint, and at full intensity adds **lightning
  flashes + a screen shake** on the player. Instanced in `Level_01`.
- `assets/raindrop.png` added to the art generator.

## 3D — Performance pass

- **`managers/FXPool.gd`** (autoload) — object pool that reuses particle "poof" nodes
  instead of instancing/freeing one per coin/stomp/land. `Player`, `Coin`, `Star`,
  `PowerUp`, and `Enemy` all route through `FXPool.poof()`.
- **Off-screen culling** — `VisibleOnScreenEnabler2D` on `Bird`/`Walker` pauses their
  processing when they're not on screen.
- **`project.godot`** → fixed `physics_ticks_per_second=60` + **2D physics
  interpolation** for smooth motion at any frame rate. Decorative tween-driven nodes
  (Coin/Star/PowerUp) opt out of interpolation; the player resets interpolation on the
  respawn teleport so it never "streaks".

## 3E — Core systems + menus

- **`managers/AudioManager.gd`** — creates `Music`/`SFX` buses at runtime,
  **synthesises every sound** (jump/coin/stomp/hurt/powerup/dash + a looping music bed)
  as `AudioStreamWAV` data, and ducks music pitch as the storm worsens. Volumes/mute
  come from the save file.
- **`save_system/SaveManager.gd`** — load/save `user://save.json` (best score, max
  stars, settings). `GameManager` records a run on level complete / game over.
- **`managers/SceneManager.gd`** — fade-to-black scene transitions.
- **Menus** — `ui/MainMenu.tscn`, `ui/PauseMenu.tscn` (Esc to pause), and a reusable
  `ui/Settings.tscn` (music/SFX volume, mute, screen-shake toggle, touch-controls
  toggle). Main Menu is the new main scene.
- **Accessibility** — `Player.add_shake()` respects the screen-shake setting; touch
  controls can be forced on; everything is mutable from Settings.

## 3F — Export + docs

- Re-exported the **Web** build to `build/web/` (served at `http://localhost:8000` with
  the required `Cross-Origin-Opener-Policy` / `Cross-Origin-Embedder-Policy` headers).
- Each phase was validated with a headless import + run.

---

## The 10 performance/quality features (and where they live)

| # | Feature | Where |
|---|---------|-------|
| 1 | Object pooling for particles | `managers/FXPool.gd` |
| 2 | Off-screen enemy culling | `VisibleOnScreenEnabler2D` on Bird/Walker |
| 3 | Audio buses + pooled SFX voices | `managers/AudioManager.gd` |
| 4 | Fewer texture loads (shared spark/atlas-friendly art) | art generator |
| 5 | Fixed physics tick + 2D interpolation | `project.godot` `[physics]` |
| 6 | Save system (`user://` JSON) | `save_system/SaveManager.gd` |
| 7 | Music + SFX | `managers/AudioManager.gd` |
| 8 | Main / Pause / Settings menus + fades | `ui/*`, `managers/SceneManager.gd` |
| 9 | Level/scene flow groundwork (SceneManager) | `managers/SceneManager.gd` |
| 10 | Accessibility/feel toggles (shake, mute, touch) | `ui/Settings.tscn` + SaveManager |

---

## New / changed files

| File | Purpose |
|------|---------|
| `ui/Theme.tres` | Shared UI theme (font sizes, outline). |
| `ui/HUD.tscn` / `ui/HUD.gd` | Themed, animated HUD with buttons. |
| `characters/PlayerFrames.tres` | Player `SpriteFrames` (idle/run/jump/fall/dash/hurt). |
| `characters/Player.tscn` / `Player.gd` | `AnimatedSprite2D` + animation state + audio hooks + shake toggle. |
| `managers/WeatherManager.gd` | Lives → weather intensity (autoload). |
| `effects/WeatherFX.tscn` / `.gd` | Rain + storm tint + lightning overlay. |
| `managers/FXPool.gd` | Pooled particle bursts (autoload). |
| `managers/AudioManager.gd` | Synthesised music + SFX, buses (autoload). |
| `managers/SceneManager.gd` | Fade scene transitions (autoload). |
| `save_system/SaveManager.gd` | `user://save.json` persistence (autoload). |
| `ui/MainMenu.tscn` / `.gd` | Title screen (new main scene). |
| `ui/PauseMenu.tscn` / `.gd` | In-level pause (Esc). |
| `ui/Settings.tscn` / `.gd` | Reusable settings overlay. |
| `scripts/generate_placeholders.py` | Extended: player frames + raindrop. |
| `project.godot` | `canvas_items` stretch, `[physics]`, new autoloads, main scene. |

---

## Controls (recap)

| Action | Keys |
|--------|------|
| Move | `A` / `D` or arrows |
| Jump / Double jump | `Space` / `Up` |
| Dash | `Shift` or `J` |
| Pause | `Esc` |
| Retry (on banner) | `R` |
