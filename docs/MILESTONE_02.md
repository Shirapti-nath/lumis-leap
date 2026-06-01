# Milestone 2 — A Full Mario-style Level

This milestone turned the bare prototype into a real, scrolling platformer level with
collectibles, enemies, modern moves, progression, "juice", and mobile support — all
using auto-generated placeholder art (swap in Canva art later by replacing the PNGs).

It was built in seven small phases (2A–2G).

---

## What got built

### Phase 2A — Continuous world + coins + HUD
- **Rebuilt `levels/Level_01.tscn`** into one long (~6000 px) level made of several
  ground segments with **intentional gaps to jump**, plus floating platforms.
- **Camera limits** (set by `levels/Level.gd`) so the view stops at the level edges.
- **`items/Coin.tscn` / `Coin.gd`** — an `Area2D` pickup that bobs and, on touch,
  tells the `GameManager` and removes itself.
- **`managers/GameManager.gd`** — an **autoload (singleton)** that holds score, coins,
  lives, time, stars, and a coin **combo**, and broadcasts changes via **signals**.
- **`ui/HUD.tscn` / `HUD.gd`** — a `CanvasLayer` that *listens* to GameManager signals
  and shows Score / Coins / Stars / Time / Lives, a combo popup, and a banner for
  "Level Complete" / "Game Over" (press **R** to restart).
- **Fall-into-the-void** death + respawn at the last checkpoint.

### Phase 2B — Enemies + hazards + damage
- **`enemies/Enemy.gd`** — one shared script configured per scene:
  - **Bird** (`Bird.tscn`) flies in a sine wave.
  - **Walker** (`Walker.tscn`) patrols the ground.
  - **Spike** (`obstacles/Spike.tscn`) is a static hazard.
- **Stomp to defeat**: landing on an enemy's head (falling + above it) defeats it and
  bounces you; any other contact damages you.

### Phase 2C — Modern moves
- **Air-dash** (new `dash` input action — **Shift** or **J**): a quick horizontal burst
  with a cooldown, refreshed on landing.
- **Wall-slide + wall-jump**: slows your fall against a wall and lets you jump off it
  (uses `is_on_wall_only()` and `get_wall_normal()`).

### Phase 2D — Progression
- **`items/Checkpoint.tscn`** — sets the respawn point and lights up green.
- **`levels/Goal.tscn`** — the finish flag; touching it shows the Level Complete banner.
- **`items/Star.tscn`** ×3 — hidden stars placed in tricky spots, tracked by GameManager.

### Phase 2E — Power-up
- **`items/PowerUp.tscn`** — a "grow" pickup. While big, the next hit just shrinks you
  instead of killing you (Mario-mushroom style). Player tracks a small/big state.

### Phase 2F — Game juice
- **Screen shake** on land/stomp/damage, **hit-stop** (brief slow-motion) on hits,
  **squash & stretch** on jump/land/dash, and **particle bursts** (`effects/Poof.tscn`)
  for jumps, landings, coins, stars, and defeated enemies.

### Phase 2G — Mobile + atmosphere
- **`ui/TouchControls.tscn`** — on-screen Left / Right / Dash / Jump buttons that map to
  the same input actions; auto-shown only on touch devices.
- **Multi-layer `ParallaxBackground`** (mountains / hills / clouds) that scrolls at
  different speeds for depth.
- **`effects/DayNight.gd`** — a `CanvasModulate` that slowly tints the world between day
  and night.

---

## Controls

| Action | Keyboard | Touch |
|--------|----------|-------|
| Move | A / D or ← / → | Left / Right buttons |
| Jump / double jump | Space / W / ↑ | Jump button |
| Dash | Shift / J | Dash button |
| Restart (after win/lose) | R | — |

---

## Key concepts introduced

- **Autoload singletons** for global state (`GameManager`).
- **Signals** to decouple systems (pickups/enemies → GameManager → HUD).
- **`Area2D` + `body_entered`** for non-solid pickups and enemy hitboxes.
- **Groups** (`"player"`) so any object can safely check "is this the player?".
- **`Tween`** for bobbing, squash/stretch, and UI flashes.
- **`CPUParticles2D`** one-shot bursts that free themselves.
- **`Camera2D` limits**, **`ParallaxBackground`**, and **`CanvasModulate`** for feel.
- **`TouchScreenButton`** reusing existing input actions for mobile.

---

## File map (new this milestone)

```
managers/GameManager.gd        # global state + signals (autoload)
levels/Level.gd                # resets state, sets camera limits
levels/Goal.gd / Goal.tscn     # finish flag
items/Coin.*                   # collectible coin
items/Star.*                   # hidden star
items/Checkpoint.*             # respawn point
items/PowerUp.*                # grow power-up
enemies/Enemy.gd               # shared enemy behaviour
enemies/Bird.tscn              # flying enemy
enemies/Walker.tscn            # ground enemy
obstacles/Spike.tscn           # static hazard
effects/Poof.* / DayNight.gd   # particles + day/night tint
ui/HUD.* / TouchControls.*     # heads-up display + mobile buttons
```

---

## How to run

- **In Godot:** open the project and press **F5**.
- **In a browser:** the build is exported to `build/web/` and served at
  `http://localhost:8000` via `python3 scripts/serve_web.py` (sets the cross-origin
  headers Godot 4 web builds require). Re-export after changes with:

```bash
"/Users/shiraptinath/Downloads/Godot.app/Contents/MacOS/Godot" \
  --headless --path . --export-release "Web" build/web/index.html
```

---

## Next steps (Milestone 3)

1. Swap placeholder PNGs for Canva art (same filenames in `assets/`).
2. Add `AnimatedSprite2D` idle/run/jump animations for Lumi.
3. Add sound effects and background music.
