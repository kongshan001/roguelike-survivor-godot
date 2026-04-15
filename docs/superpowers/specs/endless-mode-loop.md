# Endless Mode Complete Loop Design Spec

**Author**: Designer Agent
**Date**: 2026-04-16
**Priority**: P0 HIGH
**Status**: Design Complete
**H5 Reference**: `config.js` -> `CFG.ENDLESS`

---

## 1. Design Overview

The Endless Mode Complete Loop closes the gameplay cycle for the endless difficulty mode. Currently, endless mode has basic Boss cycling (every 240s with HP/speed scaling) and enemy scaling over time, but lacks: (1) a way for players to voluntarily end a run with their rewards intact, (2) Boss kill bonus rewards, (3) milestone rewards every 60 seconds, (4) soul shard multiplier, and (5) passive gold income. This spec defines all missing elements to create a complete "play -> earn -> retreat -> upgrade -> play again" loop.

**Why this design**: Endless mode is H5's core retention mechanic. Without a retreat option, players either die and lose momentum or feel trapped. Boss kill rewards give tangible milestones. The soul shard multiplier (1.5x) makes endless the preferred mode for grinding. Passive gold income provides baseline progression even on bad runs.

---

## 2. Numerical Constants Table

All values reference H5 `CFG.ENDLESS`. Values are defined as named constants.

### 2.1 Boss Kill Reward

| Constant Name | Value | Unit | H5 Source | Notes |
|---|---|---|---|---|
| `BOSS_KILL_GOLD` | 50 | gold | `ENDLESS.bossKillReward.gold` | Added to GameManager.gold immediately |
| `BOSS_KILL_EXP` | 30 | XP | `ENDLESS.bossKillReward.exp` | Added via GameManager.add_xp() |
| `BOSS_KILL_FOOD` | 5 | food items | `ENDLESS.bossKillReward.food` | Spawned as food pickups at boss death position |

### 2.2 Milestone System

| Constant Name | Value | Unit | H5 Source | Notes |
|---|---|---|---|---|
| `MILESTONE_INTERVAL` | 60 | seconds | `ENDLESS.milestoneInterval` | Triggers at 60s, 120s, 180s, ... |
| `MILESTONE_GOLD_BONUS` | 0.5 | gold/min | `ENDLESS.goldBonusPerMin` | Passive income per elapsed minute |

### 2.3 Soul Shard Economy

| Constant Name | Value | Unit | H5 Source | Notes |
|---|---|---|---|---|
| `SOUL_FRAGMENT_BONUS_MUL` | 1.5 | multiplier | `ENDLESS.soulFragmentBonusMul` | Multiplies soul fragment conversion |
| `SOUL_FRAGMENT_BASE_RATE` | 0.3 | ratio | `SHOP.soulFragmentRate` | 30% of gold -> soul fragments |

### 2.4 Enemy Scaling (Already Implemented, Documented for Reference)

| Constant Name | Value | Unit | H5 Source | Notes |
|---|---|---|---|---|
| `BOSS_INTERVAL` | 240 | seconds | `ENDLESS.bossInterval` | Time between boss spawns |
| `BOSS_HP_SCALE_PER_CYCLE` | 1.5 | multiplier | `ENDLESS.bossScalePerCycle.hpMul` | Exponential per cycle |
| `BOSS_SPEED_SCALE_PER_CYCLE` | 1.1 | multiplier | `ENDLESS.bossScalePerCycle.speedMul` | Exponential per cycle |
| `EXTRA_HP_PER_MIN` | 0.1 | multiplier/min | `ENDLESS.extraHpPerMin` | Linear per minute |
| `EXTRA_SPD_PER_MIN` | 0.05 | multiplier/min | `ENDLESS.extraSpdPerMin` | Linear per minute |
| `MIN_SPAWN_INTERVAL` | 0.25 | seconds | `ENDLESS.minSpawnInterval` | Floor for spawn interval |
| `MAX_ENEMY_BONUS` | 30 | count | `ENDLESS.maxEnemyBonus` | Added to base 70 cap |
| `MAX_ENEMIES_CAP` | 100 | count | `ENDLESS.maxEnemiesCap` | Hard cap |

---

## 3. Active Retreat System

### 3.1 Overview

A "Retreat" button on the HUD that allows the player to voluntarily end the current endless run, triggering normal game-over flow (quest/achievement checks, gold-to-soul conversion, stats display).

### 3.2 HUD Button Specification

| Property | Value | Notes |
|---|---|---|
| Position | Bottom-right of HUD | Below GoldLabel, right-aligned |
| Label | "Retreat [Q]" | Keyboard shortcut Q |
| Visibility | Only when `selected_difficulty == "endless"` | Hidden in other modes |
| Confirmation | None required | Single press triggers retreat |
| Cooldown | None | Available from t=0 |

**Design Decision -- No confirmation dialog**: In Vampire Survivors, the "Quit" button triggers immediately. Adding a confirmation dialog interrupts flow and feels clunky in an action game. If the player presses Q by accident, they simply restart a new run -- the cost is low because all rewards are kept.

### 3.3 Retreat Flow

```
Player presses Q (or clicks Retreat button)
  |
  +-> GameManager.initiate_retreat()
  |     - Sets is_game_over = true
  |     - Emits player_died (reuses existing flow)
  |
  +-> Scene transitions to game_over_screen.tscn
  |     - SaveManager.check_quests_and_achievements() runs as normal
  |     - Gold -> Soul Fragment conversion runs as normal
  |     - Additional endless-specific stats displayed (see Section 5)
  |
  +-> Player sees summary, can restart or return to menu
```

### 3.4 State Machine: Endless Mode Game States

```
                    +-----------+
                    |  PLAYING  |<-------------------+
                    +-----------+                    |
                     |        |                      |
           Boss dies |        | Player dies          |
                     v        |                      |
              +-------------+ |                      |
              | BOSS_KILLED | |                      |
              +-------------+ |                      |
                     |        |                      |
           Rewards   |        |                      |
           applied   |        |                      |
                     v        v                      |
              +---------------------------+          |
              | Continue / Boss_Spawning  |----------+
              +---------------------------+  (next boss timer)
                     |
                     | Player presses Q (Retreat)
                     v
              +-----------+
              | RETREAT   |
              +-----------+
                     |
                     v
              +-----------+
              | GAME_OVER |
              +-----------+
                     |
                     v
              game_over_screen.tscn
```

---

## 4. Boss Kill Reward System

### 4.1 Trigger

When an enemy with `is_boss == true` dies in endless mode, trigger the following bonus rewards IN ADDITION to normal kill rewards (XP gem, gold, food drop).

### 4.2 Reward Application

```gdscript
# In enemy.gd die() function, after normal death rewards:
if GameManager.selected_difficulty == "endless" and enemy_data.is_boss:
    _apply_endless_boss_reward()

func _apply_endless_boss_reward():
    # 1. Gold bonus
    GameManager.add_gold(50)

    # 2. XP bonus
    GameManager.add_xp(30.0)

    # 3. Food drops at boss position
    for i in range(5):
        spawn_food_at(global_position + Vector2(randf_range(-30, 30), randf_range(-30, 30)))

    # 4. Visual feedback
    # Show floating text: "Boss Down! +50G +30XP"
    # Screen shake intensity 8.0 for 0.3s (already exists in SCREEN_SHAKE.boss)
```

### 4.3 Reward Table (Per Boss Kill)

| Reward | Amount | Accumulation | Notes |
|---|---|---|---|
| Gold | 50 | GameManager.gold | Immediate |
| XP | 30 | GameManager.add_xp() | Immediate, may trigger level up |
| Food | 5 items | Spawned on ground | Player must pick up; affected by magnet range |

### 4.4 Accumulated Boss Rewards Over Time

| Cycle | Time | Boss HP Scale | Gold Earned | XP Earned | Food Earned | Cumulative Gold |
|---|---|---|---|---|---|---|
| 1 | ~270s | 1.0x | 50 | 30 | 5 | 50 |
| 2 | ~510s | 1.5x | 50 | 30 | 5 | 100 |
| 3 | ~750s | 2.25x | 50 | 30 | 5 | 150 |
| 4 | ~990s | 3.375x | 50 | 30 | 5 | 200 |

---

## 5. Milestone Reward System

### 5.1 Overview

Every 60 seconds in endless mode, the player receives a passive gold bonus and a milestone notification.

### 5.2 Passive Gold Income

The passive gold bonus is calculated as:

```
milestone_gold = floor(elapsed_time / 60) * 0.5
```

Applied at each 60-second boundary:
- At 60s: +0.5 gold (rounded: +1 gold)
- At 120s: +1 gold
- At 180s: +1 gold
- At 240s: +2 gold
- At 300s: +2 gold

**Implementation**: Instead of applying 0.5 gold per minute (which would be fractional), accumulate and apply as integer:

```gdscript
# In enemy_spawner.gd or a new milestone_tracker on arena:
var _milestone_timer: float = 60.0
var _milestone_gold_accumulated: float = 0.0

func _process_milestone(delta):
    if GameManager.selected_difficulty != "endless":
        return
    _milestone_timer -= delta
    if _milestone_timer <= 0:
        _milestone_timer += 60.0
        _milestone_gold_accumulated += 0.5 * (GameManager.elapsed_time / 60.0)
        var gold_to_add: int = int(_milestone_gold_accumulated)
        if gold_to_add > 0:
            _milestone_gold_accumulated -= float(gold_to_add)
            GameManager.add_gold(gold_to_add)
        # Show milestone toast
        var minutes: int = int(GameManager.elapsed_time / 60.0)
        _show_milestone_toast(minutes, gold_to_add)
```

### 5.3 Milestone Toast Display

```
+----------------------------------+
|  60s Milestone! +1 Gold         |
+----------------------------------+

+----------------------------------+
|  5 min Milestone! +2 Gold       |
+----------------------------------+

+----------------------------------+
|  10 min Milestone! +5 Gold      |
+----------------------------------+
```

Toast appears at top-center of screen, lasts 2 seconds, then fades.

---

## 6. Soul Shard Multiplier

### 6.1 Current Behavior

In `save_manager.gd` line 283:
```gdscript
var soul_reward: int = int(GameManager.gold * 0.3)
```

### 6.2 Endless Mode Enhancement

```gdscript
# In save_manager.gd check_quests_and_achievements():
var rate: float = 0.3  # SOUL_FRAGMENT_BASE_RATE
if GameManager.selected_difficulty == "endless":
    rate *= 1.5  # SOUL_FRAGMENT_BONUS_MUL = 1.5
var soul_reward: int = int(GameManager.gold * rate)
add_soul_fragments(soul_reward)
```

### 6.3 Impact Example

| Mode | Gold at End | Soul Rate | Soul Fragments Earned |
|---|---|---|---|
| Normal | 100 | 30% | 30 |
| Endless | 100 | 45% | 45 |
| Endless | 200 | 45% | 90 |

The 1.5x multiplier makes endless mode the most efficient mode for earning soul fragments, incentivizing players to push further.

---

## 7. Game Over Screen: Endless-Specific Stats

### 7.1 Additional Display Elements

When `selected_difficulty == "endless"`, the game over screen shows additional stats:

```
+--------------------------------------------------+
|  GAME OVER                                        |
|                                                   |
|  Time: 08:42                                      |
|  Enemies Killed: 187                              |
|  Level: 12                                        |
|  Score: 2340                                      |
|  Gold: 245 -> Soul Fragments: 110 (+45% bonus!)  |
|                                                   |
|  --- Endless Stats ---                            |
|  Bosses Killed: 2                                 |
|  Best Combo: 34                                   |
|  Milestones Reached: 8                            |
|                                                   |
|  [Restart]  [Menu]                                |
+--------------------------------------------------+
```

### 7.2 New Labels Required in game_over_screen.tscn

| Node Name | Content | Visibility |
|---|---|---|
| EndlessStatsLabel | "Bosses Killed: X / Milestones: X" | Only in endless |
| SoulBonusLabel | "(+45% endless bonus!)" appended to GoldLabel | Only in endless |

---

## 8. Complete Integration Map

### 8.1 Files to Modify

| File | Change | Scope |
|---|---|---|
| `scripts/hud.gd` | Add RetreatButton node, connect signal, Q key binding | New node + 20 lines |
| `scripts/autoload/game_manager.gd` | Add `initiate_retreat()` method, `is_retreat` flag | ~10 lines |
| `scripts/enemy.gd` | Add endless boss kill reward in `die()` | ~15 lines |
| `scripts/enemy_spawner.gd` | Add milestone timer tracking | ~20 lines |
| `scripts/game_over_screen.gd` | Add endless-specific stat display | ~15 lines |
| `scenes/hud.tscn` | Add RetreatButton node | Scene edit |
| `scenes/game_over_screen.tscn` | Add EndlessStatsLabel | Scene edit |
| `scripts/autoload/save_manager.gd` | Modify soul conversion rate for endless | ~3 lines |

### 8.2 New Files Needed

None -- all changes are modifications to existing files.

### 8.3 New Signals

| Signal | Emitter | Listener | Purpose |
|---|---|---|---|
| `boss_kill_reward` | GameManager | HUD | Display boss kill bonus toast |
| `milestone_reached` | GameManager or EnemySpawner | HUD | Display milestone toast |

Add to `game_manager.gd`:
```gdscript
signal boss_kill_reward(gold: int, exp: int)
signal milestone_reached(minutes: int, gold: int)
```

---

## 9. Balance Analysis

### 9.1 Run Duration vs Reward Curve

| Duration | Bosses | Gold from Bosses | Gold from Kills (~3/kill) | Passive Gold | Total Gold | Soul Fragments (45%) |
|---|---|---|---|---|---|---|
| 3 min | 0 | 0 | ~30 | 2 | 32 | 14 |
| 5 min | 1 | 50 | ~90 | 7 | 147 | 66 |
| 8 min | 1 | 50 | ~200 | 18 | 268 | 120 |
| 10 min | 2 | 100 | ~300 | 25 | 425 | 191 |
| 15 min | 3 | 150 | ~500 | 56 | 706 | 317 |

### 9.2 Difficulty Progression

At 10 minutes in endless mode:
- Enemy HP multiplier: 1.0 + 10 * 0.1 = 2.0x
- Enemy speed multiplier: 1.0 + 10 * 0.05 = 1.5x
- Boss HP multiplier (cycle 2): 1.5^2 = 2.25x
- Max enemies: 100 (hard cap)

This is significantly harder than normal mode's 5-minute run, justifying the 1.5x soul shard bonus.

---

## 10. Design Decisions Log

| Decision | Why | Alternative Considered |
|---|---|---|
| No confirmation on Retreat | Smooth flow; low cost of accidental press | Confirmation dialog (breaks action pacing) |
| Q key for Retreat | Unlikely to be pressed accidentally during WASD play | Esc (conflicts with pause) |
| Passive gold = 0.5/min | Subtle but meaningful; ~5 gold over 10 minutes | 1.0/min (too generous) |
| Boss rewards: flat 50g/30xp/5food | Simple, predictable, rewards every boss equally | Scaling rewards (unnecessary complexity) |
| Milestone toast at top-center | Visible but non-intrusive; matches boss warning pattern | Bottom-center (conflicts with upgrade panel) |
| Soul multiplier applied to rate, not result | Cleaner calculation; `rate * 1.5` vs `result * 1.5` | Same result either way |
| Milestone timer in enemy_spawner | Co-located with existing endless logic | Separate milestone_spawner.gd (over-engineering) |
