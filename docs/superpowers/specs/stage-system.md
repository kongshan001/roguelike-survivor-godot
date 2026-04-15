# Stage/Wave System Design Spec

**Author**: Designer Agent
**Date**: 2026-04-16
**Priority**: P1 HIGH
**Status**: Design Complete
**H5 Reference**: `config.js` -> `CFG.WAVE_PROGRESS`, `CFG.ENDLESS`

---

## 1. Design Overview

The current enemy spawn system uses continuous spawning with time-gated enemy type availability (zombies from 0s, bats from 120s, skeletons/ghosts from 180s, etc.). This creates a flat, undifferentiated experience -- the player has no sense of "progressing through waves" or "clearing a stage." Genre leaders (Vampire Survivors, Brotato, HoloCure) all use wave/stage boundaries to create rhythm: tension spikes during waves, relief between them, and a sense of accomplishment at stage transitions.

This spec introduces a wave-based structure on top of the existing continuous spawn system. Rather than replacing the current system (which works well for enemy type gating and spawn timing), it adds a "wave overlay" that groups spawns into named waves with clear start/end boundaries, inter-wave breathing room, and escalating wave composition.

**Why this design**: The continuous spawn system was adequate for the MVP but lacks the pacing rhythm that defines the genre. Players need:
1. **Tension peaks** (active wave with specific enemy composition)
2. **Tension valleys** (brief pause between waves for pickup collection and positioning)
3. **Progress milestones** (wave number displayed, toast notification on wave clear)
4. **Boss as climax** (Boss wave caps the stage, as in H5 WAVE_PROGRESS)

---

## 2. Wave Structure Definition

### 2.1 Normal Mode (5-minute run)

The normal mode run is divided into 5 waves, matching the H5 `WAVE_PROGRESS.stages` configuration. Each wave has a fixed duration, a specific enemy composition, and ends with a brief inter-wave pause.

```
Wave 1: "Opening"      t=0s    to t=60s    (60s)   Enemies: zombie only
-- Inter-wave pause: 3s --
Wave 2: "Swarm"        t=63s   to t=120s   (57s)   Enemies: zombie + bat
-- Inter-wave pause: 3s --
Wave 3: "Darkness"     t=123s  to t=180s   (57s)   Enemies: zombie + bat + skeleton + ghost
-- Inter-wave pause: 3s --
Wave 4: "Elite"        t=183s  to t=240s   (57s)   Enemies: all types + elite_skeleton + splitter
-- Inter-wave pause: 3s --
Wave 5: "Boss"         t=243s  to t=300s   (57s)   Enemies: all types + Boss at wave start
-- Victory at t=300s if alive --
```

### 2.2 Wave Numerical Constants

| Constant Name | Value | Unit | H5 Source | Notes |
|---|---|---|---|---|
| `WAVE_INTERMISSION` | 3.0 | seconds | New design | Pause between waves; no enemies spawn |
| `WAVE_1_START` | 0 | seconds | `WAVE_PROGRESS.stages[0].time` | |
| `WAVE_1_END` | 60 | seconds | Derived | First 60s is zombie-only |
| `WAVE_2_START` | 63 | seconds | Derived | 60 + 3 intermission |
| `WAVE_2_END` | 120 | seconds | Derived | |
| `WAVE_3_START` | 123 | seconds | Derived | 120 + 3 intermission |
| `WAVE_3_END` | 180 | seconds | Derived | |
| `WAVE_4_START` | 183 | seconds | Derived | 180 + 3 intermission |
| `WAVE_4_END` | 240 | seconds | Derived | |
| `WAVE_5_START` | 243 | seconds | Derived | 240 + 3 intermission |
| `WAVE_5_END` | 300 | seconds | `CFG.GAME_TIME` | 5-minute total run time |
| `BOSS_WARNING_TIME` | 15.0 | seconds | `WAVE_PROGRESS.warningTime` | Warning shown 15s before Boss wave |
| `TOAST_DURATION` | 2.5 | seconds | `WAVE_PROGRESS.toastDuration` | |

### 2.3 Wave Definitions Data Table

| Wave | ID | Name | Duration | Enemy Types | Spawn Rate | Spawn Count | Special |
|---|---|---|---|---|---|---|---|
| 1 | `wave_opening` | "Opening" | 60s | zombie | 2.0s base | 1 base | Tutorial-paced |
| 2 | `wave_swarm` | "Swarm" | 57s | zombie, bat | 1.5s base | 2 base | Bat swarm pressure |
| 3 | `wave_darkness` | "Darkness" | 57s | zombie, bat, skeleton, ghost | 1.2s base | 3 base | Ranged + phase enemies |
| 4 | `wave_elite` | "Elite" | 57s | all + elite_skeleton, splitter | 1.0s base | 4 base | Elite ranged + split |
| 5 | `wave_boss` | "Boss" | 57s | all + Boss | 0.8s base | 5 base | Boss spawns at wave start |

### 2.4 Endless Mode Wave Structure

In endless mode, waves repeat in a cycle after Wave 5, with increasing difficulty. Each "cycle" consists of 4 standard waves + 1 boss wave.

| Cycle | Wave | Duration | HP Mult | Spd Mult | Spawn Rate Mult | Notes |
|---|---|---|---|---|---|---|
| 1 | Wave 1-5 | As above | 1.0x | 1.0x | 1.0x | Standard |
| 2 | Wave 6-10 | Same pattern | 1.3x | 1.1x | 0.9x | First endless cycle |
| 3 | Wave 11-15 | Same pattern | 1.7x | 1.2x | 0.8x | |
| 4 | Wave 16-20 | Same pattern | 2.2x | 1.3x | 0.7x | |
| N | Wave (5N-4) to (5N) | Same pattern | 1.0 + 0.3*N | 1.0 + 0.1*N | max(0.5, 1.0 - 0.1*N) | Caps at spawn_rate_mult=0.5 |

**Boss waves in endless** occur at waves 5, 10, 15, 20, ... with HP scaling matching existing `bossScalePerCycle`:
- Boss HP: 200 * (1.5 ^ cycle) * difficulty_boss_hp_mul
- Boss Speed: 30 * (1.1 ^ cycle) * difficulty_boss_speed_mul

---

## 3. Inter-Wave Behavior

### 3.1 What Happens During Inter-Wave Pause

During the `WAVE_INTERMISSION` (3 seconds):
- **No enemies spawn** -- spawn timer is paused
- **Existing enemies remain** -- they continue to chase and attack
- **Pickups glow brighter** -- visual cue to collect (future enhancement)
- **HUD shows "Wave X Incoming..."** with a countdown (3, 2, 1)
- **XP gems magnetize from further away** -- pickup_range * 1.5 during intermission (future enhancement)

### 3.2 Intermission Flow

```
Last enemy of Wave N spawned
  |
  v
Wave N continues until Wave N timer expires
  |
  v
Intermission starts (3s)
  |
  +-> HUD: "Wave N Complete!" toast (1.5s)
  +-> HUD: "Wave N+1 Incoming... 3" countdown
  +-> No new enemy spawns
  +-> Existing enemies still active
  |
  v (3 seconds later)
Wave N+1 starts
  |
  +-> HUD: "Wave N+1: [Name]" toast (2.5s)
  +-> New enemy types become available
  +-> Spawn timer resumes
  +-> If Boss wave: Boss spawns immediately, boss_warning skipped (already warned)
```

---

## 4. Wave Progress Bar (HUD Element)

### 4.1 Visual Specification

A thin progress bar at the top of the screen showing current wave progress.

```
+================================================================+
| [Wave 3/5: Darkness]                                          |
| [============================-------------------------------] |
| [Combo: 12] [Gold: 45] [Lv 5]              [08:23 / 15:00]    |
+================================================================+
```

### 4.2 Progress Bar Numerical Constants

| Constant Name | Value | Unit | H5 Source | Notes |
|---|---|---|---|---|
| `WAVE_BAR_HEIGHT` | 4 | pixels | `WAVE_PROGRESS.barHeight` | Thin bar at screen top |
| `WAVE_BAR_COLOR` | Color(0.3, 0.69, 0.31) | Color | Current wave's stage color | Changes per wave |
| `WAVE_BAR_BG_COLOR` | Color(0.15, 0.15, 0.2) | Color | Dark background | Behind the fill |

### 4.3 Wave Color Coding

| Wave | Color | Hex | Source |
|---|---|---|---|
| 1 - Opening | Green | #4caf50 | `WAVE_PROGRESS.stages[0].color` |
| 2 - Swarm | Yellow | #ffd54f | `WAVE_PROGRESS.stages[1].color` |
| 3 - Darkness | Orange | #ff9100 | `WAVE_PROGRESS.stages[2].color` |
| 4 - Elite | Red | #ef5350 | `WAVE_PROGRESS.stages[3].color` |
| 5 - Boss | Dark Red | #ff1744 | `WAVE_PROGRESS.stages[4].color` |

### 4.4 ASCII Wireframe: Wave Progress Bar Layout

```
+------------------------------------------------------------------+
|                                                                  |  <- Top of viewport
|  [Wave 3/5: Darkness]                                           |  <- WaveLabel (font_size=12)
|  [=====================================--------------------------] |  <- WaveBar (height=4px)
|                                                                  |
|                                                                  |
|                                                                  |
|                        (Game Area)                                |
|                                                                  |
|                                                                  |
|                                                                  |
|  [HP: ████████░░ 8/12]  [XP: ████░░░░ 45/88]  [Gold: 45]      |  <- Existing HUD
+------------------------------------------------------------------+
```

### 4.5 Endless Mode Progress Display

In endless mode, the progress bar shows cycle and wave within cycle:
- Display: "Cycle 2, Wave 3/5: Darkness"
- Progress bar fills based on time within current wave (not total time)
- No "total" endpoint displayed (endless has no end)

---

## 5. Wave Toast Notifications

### 5.1 Toast Types

| Event | Text Template | Color | Duration |
|---|---|---|---|
| Wave Start | "Wave {n}: {name}" | Wave color | 2.5s |
| Wave Complete | "Wave {n} Complete!" | Green | 1.5s |
| Intermission Countdown | "Next wave in {t}..." | White | 3s |
| Boss Warning | "Boss Incoming!" | Red | 2.5s |
| Victory (Normal) | "Victory!" | Gold | Persistent until game over |

### 5.2 Toast Priority

Boss warning > Wave start > Wave complete > Intermission countdown. If multiple toasts are queued, boss warning takes priority.

---

## 6. Victory Condition (Normal Mode)

### 6.1 Current Behavior

Currently, the game has no explicit victory state. Enemies keep spawning past 300s until the player dies. H5 `CFG.GAME_TIME = 300` implies a 5-minute run.

### 6.2 New Victory Flow

```
t=300s reached in normal/hard mode
  |
  +-> GameManager trigger victory:
  |     - is_game_over = true
  |     - Set new flag: is_victory = true
  |
  +-> All existing enemies play death animation and despawn
  |
  +-> HUD: "Victory!" banner (gold text, persistent)
  |
  +-> Auto-transition to game_over_screen after 3s
  |
  +-> game_over_screen shows:
  |     - "VICTORY" header instead of "GAME OVER"
  |     - All normal stats
  |     - Quest/achievement checks as usual
  |     - Bonus gold reward: +50 for normal, +100 for hard
  |
  +-> Soul fragment conversion as usual
```

### 6.3 Victory Reward Constants

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| `VICTORY_GOLD_BONUS_NORMAL` | 50 | gold | Bonus for surviving 5 min in normal |
| `VICTORY_GOLD_BONUS_HARD` | 100 | gold | Bonus for surviving 5 min in hard |
| `VICTORY_GOLD_BONUS_EASY` | 25 | gold | Bonus for surviving 5 min in easy |
| `VICTORY_TRANSITION_DELAY` | 3.0 | seconds | Delay before auto-transition |

---

## 7. Implementation: State Machine

### 7.1 Wave State Machine

```
                    +-----------+
                    | WAVE_IDLE |  (before game start or intermission)
                    +-----------+
                         |
                         | wave_timer starts
                         v
                    +-----------+
            +------>| WAVE_ACTIVE|<-------> (enemies spawning)
            |       +-----------+
            |            |
            |            | wave_timer expires
            |            v
            |       +-----------+
            |       | WAVE_END  |  (show "Wave Complete" toast)
            |       +-----------+
            |            |
            |            | 3s intermission
            |            v
            |       +-------------+
            |       | INTERMISSION|  (countdown, no spawns)
            |       +-------------+
            |            |
            |            | intermission expires
            |            v
            |       +-----------+
            +-------| WAVE_START|  (show "Wave N" toast, start spawning)
                    +-----------+
                         |
                         | if wave 5 complete AND not endless
                         v
                    +-----------+
                    | VICTORY   |
                    +-----------+
                         |
                         | 3s delay
                         v
                    game_over_screen
```

### 7.2 Endless Mode State Extensions

After Wave 5 in endless mode, instead of VICTORY:
```
WAVE_END (wave 5)
  |
  | endless mode
  v
INTERMISSION (3s)
  |
  v
WAVE_START (wave 6, cycle 2)
  |  - Apply cycle 2 multipliers
  |  - Enemy HP *= 1.3, Speed *= 1.1
  |  - Spawn rate *= 0.9
  v
WAVE_ACTIVE (wave 6)
  ...
  (repeats indefinitely)
```

---

## 8. Spawn Rate Integration with Existing System

### 8.1 Current Spawn Logic (enemy_spawner.gd)

The existing `_get_spawn_interval()` and `_get_spawn_count()` use `GameManager.elapsed_time` to determine spawn parameters. The wave system will layer on top of this:

1. During `WAVE_ACTIVE`, spawn logic works exactly as current (time-based intervals and counts).
2. During `INTERMISSION`, `_spawn_timer` is frozen (not decremented).
3. Wave state is tracked in `enemy_spawner.gd` via a new `_wave_state` variable.

### 8.2 Wave Boundary Calculation

```gdscript
# In enemy_spawner.gd
var _wave_state: String = "active"  # "active", "intermission", "victory"
var _current_wave: int = 1
var _current_cycle: int = 1  # 1 for normal, increments in endless
var _wave_timer: float = 0.0
var _intermission_timer: float = 0.0

const WAVE_DEFS: Array = [
    {"name": "Opening",  "duration": 60.0, "enemies": ["zombie"],
     "spawn_base": 2.0, "count_base": 1, "color": Color(0.3, 0.69, 0.31)},
    {"name": "Swarm",    "duration": 57.0, "enemies": ["zombie", "bat"],
     "spawn_base": 1.5, "count_base": 2, "color": Color(1.0, 0.84, 0.31)},
    {"name": "Darkness", "duration": 57.0, "enemies": ["zombie", "bat", "skeleton", "ghost"],
     "spawn_base": 1.2, "count_base": 3, "color": Color(1.0, 0.57, 0.0)},
    {"name": "Elite",    "duration": 57.0, "enemies": ["zombie", "bat", "skeleton", "ghost", "elite_skeleton", "splitter"],
     "spawn_base": 1.0, "count_base": 4, "color": Color(0.94, 0.33, 0.31)},
    {"name": "Boss",     "duration": 57.0, "enemies": ["zombie", "bat", "skeleton", "ghost", "elite_skeleton", "splitter"],
     "spawn_base": 0.8, "count_base": 5, "color": Color(1.0, 0.09, 0.17), "boss": true},
]
const WAVE_INTERMISSION: float = 3.0
```

---

## 9. Complete Integration Map

### 9.1 Files to Modify

| File | Change | Scope |
|---|---|---|
| `scripts/enemy_spawner.gd` | Add wave state machine, wave timer, intermission timer, cycle tracking; modify `_physics_process` to respect wave state; add `_get_wave_def()` helper; modify `_get_available_types()` to use wave def; add signals `wave_started`, `wave_completed`, `victory` | ~80 lines added/modified |
| `scripts/autoload/game_manager.gd` | Add `is_victory: bool` flag, `current_wave: int` tracking, `current_cycle: int` tracking; add signals `wave_started(wave, name)`, `wave_completed(wave)`, `victory_achieved(gold_bonus)` | ~20 lines |
| `scripts/hud.gd` | Add wave progress bar (ColorRect), wave label (Label), connect wave signals, display wave countdown during intermission | ~40 lines |
| `scripts/arena.gd` | Connect victory signal for auto-transition; add wave state listeners | ~15 lines |
| `scripts/game_over_screen.gd` | Add "VICTORY" header variant, victory gold bonus display | ~10 lines |
| `scenes/hud.tscn` | Add WaveBar (ColorRect), WaveLabel (Label) nodes | Scene edit |

### 9.2 New Files Needed

None -- all changes are modifications to existing files.

### 9.3 New Signals

| Signal | Emitter | Listener | Purpose |
|---|---|---|---|
| `wave_started(wave: int, name: String, color: Color)` | GameManager | HUD | Show wave toast, update bar |
| `wave_completed(wave: int)` | GameManager | HUD | Show completion toast |
| `victory_achieved(gold_bonus: int)` | GameManager | Arena, HUD | Trigger victory flow |

Add to `game_manager.gd`:
```gdscript
signal wave_started(wave: int, name: String)
signal wave_completed(wave: int)
signal victory_achieved(gold_bonus: int)
var is_victory: bool = false
var current_wave: int = 1
var current_cycle: int = 1
```

---

## 10. Balance Analysis

### 10.1 Wave Duration vs Enemy Count

| Wave | Duration | Spawn Rate | Spawn Count | Total Enemies (approx) |
|---|---|---|---|---|
| 1 - Opening | 60s | 2.0s | 1 | ~30 |
| 2 - Swarm | 57s | 1.5s | 2 | ~76 |
| 3 - Darkness | 57s | 1.2s | 3 | ~143 |
| 4 - Elite | 57s | 1.0s | 4 | ~228 |
| 5 - Boss | 57s | 0.8s | 5 | ~356 + 1 Boss |

Note: Max enemy cap (70 normal, 100 endless) prevents these theoretical maximums. Actual on-screen enemies will be capped.

### 10.2 Experience Curve Per Wave

| Wave | Enemy Types | Avg XP/kill | Kills (est) | XP Earned |
|---|---|---|---|---|
| 1 | zombie | 2 | 25 | 50 |
| 2 | zombie + bat | 1.5 | 40 | 60 |
| 3 | + skeleton (3), ghost (4) | 2.5 | 50 | 125 |
| 4 | + elite (8), splitter (5) | 4 | 60 | 240 |
| 5 | All + Boss (100) | 4+ | 70 + Boss | 380 |
| **Total** | | | ~245 | ~855 XP |

With EXP_TABLE: 8+12+18+24+32+42+55+70+88+108 = 457 XP to reach Lv10. The player should reach approximately Lv10-12 in a standard 5-minute run, which aligns with having 2-3 weapons at Lv3 and potentially an evolution.

### 10.3 Intermission Balance

3-second pauses at 60s, 120s, 180s, 240s give the player 4 brief rest moments:
- Total pause time: 12s out of 300s (4% of run time)
- This is short enough to maintain tension but long enough to collect pickups and reposition
- VS uses chest drops as natural breakpoints; we use intermissions as explicit breakpoints

---

## 11. Design Decisions Log

| Decision | Why | Alternative Considered |
|---|---|---|
| 5 waves for normal mode | Matches H5 WAVE_PROGRESS exactly; clean pacing | 3 waves (too few), 7 waves (too granular) |
| 3s intermission | Short enough to maintain tension, long enough to collect pickups | 5s (too long, breaks flow), 1s (too short, no breathing room) |
| Intermission: enemies still active | Prevents exploiting pause to reposition freely | Freeze enemies (too easy, removes tension) |
| No enemy spawn during intermission | Gives natural pickup collection window | Continue spawning (defeats purpose of pause) |
| Boss spawns at wave 5 start | Boss is the climax, consistent with H5 | Boss at wave 5 end (anti-climactic, player already survived) |
| Victory at 300s in normal/hard | H5 GAME_TIME=300; provides clear endpoint | No victory condition (current state, no closure) |
| Endless cycles repeat wave pattern | Familiar rhythm, predictable escalation | Random wave composition (unpredictable, hard to balance) |
| Wave progress bar at top | Non-intrusive, genre convention | Side bar (wastes screen space) |
| Cycle multipliers: HP +30%, Spd +10%, Rate -10% per cycle | Gradual but noticeable escalation; matches H5 ENDLESS spirit | Exponential scaling (too harsh), flat scaling (too easy) |
| Victory gold bonus (25/50/100) | Meaningful reward proportional to difficulty | No bonus (victory is its own reward -- insufficient for meta-progression) |

---

## 12. Future Enhancements (Out of Scope for R6)

1. **Multiple arena maps** -- Different stages with unique enemy compositions, visual themes, and environmental hazards. Unlocked via achievements.
2. **XP magnet range boost during intermission** -- pickup_range * 1.5 to encourage collection.
3. **Wave-specific environmental effects** -- Wave 3 "Darkness" reduces visibility, Wave 4 "Elite" spawns in formations.
4. **Boss variants** -- Different boss behavior patterns per cycle in endless mode.
5. **Stage select screen** -- Player chooses which map to play on, each with unique wave compositions.
