# Difficulty Curve Tuning Spec

**Author**: Designer Agent
**Date**: 2026-04-16
**Priority**: P1 HIGH
**Status**: Design Complete
**H5 Reference**: `config.js` -> `CFG.DIFFICULTY`, `CFG.WAVE_PROGRESS`, `CFG.ENDLESS`

---

## 1. Design Overview

This document analyzes the current difficulty curve across all four modes (easy/normal/hard/endless), compares it against H5 `config.js` values, and proposes tuning adjustments. The goal is to ensure that: (1) Easy mode is accessible to new players, (2) Normal mode provides a balanced 5-minute challenge, (3) Hard mode is punishing but fair, and (4) Endless mode provides a sustainable long-term challenge with meaningful rewards.

The analysis covers enemy HP/speed/damage scaling, spawn rate tuning, boss HP pacing, player survivability, and the XP economy across difficulties.

---

## 2. Current Difficulty Presets vs H5 Baseline

### 2.1 Preset Comparison Table

| Parameter | H5 Easy | Godot Easy | H5 Normal | Godot Normal | H5 Hard | Godot Hard | H5 Endless | Godot Endless |
|---|---|---|---|---|---|---|---|---|
| player_hp_mul | 1.25 | 1.25 | 1.0 | 1.0 | 0.75 | 0.75 | 1.0 | 1.0 |
| player_speed_mul | 1.0 | 1.0 | 1.0 | 1.0 | 0.9 | 0.9 | 1.0 | 1.0 |
| enemy_hp_mul | 0.7 | 0.7 | 1.0 | 1.0 | 1.5 | 1.5 | 1.0 | 1.0 |
| enemy_speed_mul | 0.8 | 0.8 | 1.0 | 1.0 | 1.3 | 1.3 | 1.0 | 1.0 |
| enemy_dmg_mul | 0.75 | 0.75 | 1.0 | 1.0 | 1.5 | 1.5 | 1.0 | 1.0 |
| spawn_interval_mul | 1.4 | 1.4 | 1.0 | 1.0 | 0.7 | 0.7 | 1.0 | 1.0 |
| spawn_count_mod | -1 | -1 | 0 | 0 | 1 | 1 | 0 | 0 |
| boss_hp_mul | 0.6 | 0.6 | 1.0 | 1.0 | 2.0 | 2.0 | 1.0 | 1.0 |
| boss_speed_mul | 0.8 | 0.8 | 1.0 | 1.0 | 1.3 | 1.3 | 1.0 | 1.0 |
| exp_mul | 1.3 | 1.3 | 1.0 | 1.0 | 0.8 | 0.8 | 1.0 | 1.0 |
| food_drop_mul | 1.5 | 1.5 | 1.0 | 1.0 | 0.6 | 0.6 | 1.0 | 1.0 |

**Verdict**: All difficulty presets match H5 config.js exactly. No changes needed to base multipliers.

---

## 3. Spawn Rate Curve Analysis

### 3.1 Current Spawn Intervals (enemy_spawner.gd)

```
Time < 30s:  base = 2.0s
Time < 60s:  base = 1.5s
Time < 120s: base = 1.2s
Time < 180s: base = 1.0s
Time >= 180s: base = 0.8s
Final = base * difficulty.spawn_interval_mul
```

### 3.2 Effective Spawn Intervals by Difficulty

| Time Range | Easy | Normal | Hard | Endless |
|---|---|---|---|---|
| 0-30s | 2.8s | 2.0s | 1.4s | 2.0s |
| 30-60s | 2.1s | 1.5s | 1.05s | 1.5s |
| 60-120s | 1.68s | 1.2s | 0.84s | 1.2s |
| 120-180s | 1.4s | 1.0s | 0.7s | 1.0s |
| 180s+ | 1.12s | 0.8s | 0.56s | 0.8s |

### 3.3 Issue: Hard Mode Late-Game Spawn Rate Too Aggressive

At 180s in hard mode, enemies spawn every 0.56s with spawn_count=5+1=6. This means approximately 10.7 enemies per second. With max_enemy_cap=70, the screen fills in ~6.5 seconds.

**Problem**: Combined with enemy_hp_mul=1.5 and enemy_speed_mul=1.3, the player cannot kill enemies fast enough to prevent being overwhelmed. The spawn interval floor (0.56s) combined with high HP (enemies are 1.5x tankier) creates a situation where enemies accumulate faster than the player can clear them.

**Proposed Tuning**: Add a minimum spawn interval floor for hard mode.

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| `MIN_SPAWN_INTERVAL_HARD` | 0.7 | seconds | Hard mode floor; matches current 180s hard value |

This prevents spawn rate from going below 0.7s in hard mode, keeping the late-game challenging but survivable.

### 3.4 Issue: Easy Mode Spawn Count Too Low

Easy mode has spawn_count_mod=-1, which means:
- 0-30s: max(1, 1-1) = 1 enemy per spawn
- 30-60s: max(1, 2-1) = 1 enemy per spawn
- 60-120s: max(1, 3-1) = 2 enemies per spawn
- 120-180s: max(1, 4-1) = 3 enemies per spawn
- 180s+: max(1, 5-1) = 4 enemies per spawn

This is appropriate for easy mode. No change needed.

---

## 4. Enemy HP/Speed Scaling Over Time

### 4.1 Endless Mode Linear Scaling

Current implementation (in `_spawn_wave_enemies`):
```gdscript
if is_endless:
    var minutes: float = GameManager.elapsed_time / 60.0
    data.max_hp *= 1.0 + minutes * 0.1
    data.speed *= 1.0 + minutes * 0.05
```

### 4.2 Zombie HP at Various Endless Times

| Time | HP Mult | Zombie HP | Bat HP | Skeleton HP | Elite HP | Boss HP (base, before cycle scaling) |
|---|---|---|---|---|---|---|
| 0 min | 1.0x | 3 | 1 | 5 | 12 | 200 |
| 5 min | 1.5x | 4.5 | 1.5 | 7.5 | 18 | 200 |
| 10 min | 2.0x | 6 | 2 | 10 | 24 | 200 |
| 15 min | 2.5x | 7.5 | 2.5 | 12.5 | 30 | 200 |
| 20 min | 3.0x | 9 | 3 | 15 | 36 | 200 |

### 4.3 Issue: Linear Scaling Leads to Bullet Sponges at 20+ Minutes

At 20 minutes in endless, even basic zombies have 9 HP. With a knife doing 3 damage at Lv1, that's 3 hits per zombie. At 30+ minutes (zombie HP 6+ base), the player's weapons need to be sufficiently leveled to keep up.

**Analysis**: This is actually acceptable because:
1. The player gains XP and levels weapons over time, keeping pace with HP scaling.
2. Weapon evolution provides a major damage spike.
3. The wave/stage system (from `stage-system.md`) introduces cycle multipliers that are more gradual.

**However**, if we implement the wave/stage system, the endless scaling changes to per-cycle rather than per-minute:

### 4.4 Proposed Endless Cycle Scaling (with Wave System)

| Cycle | Time (approx) | HP Mult | Spd Mult | Spawn Rate Mult |
|---|---|---|---|---|
| 1 | 0-5 min | 1.0x | 1.0x | 1.0x |
| 2 | 5-10 min | 1.3x | 1.1x | 0.9x |
| 3 | 10-15 min | 1.7x | 1.2x | 0.8x |
| 4 | 15-20 min | 2.2x | 1.3x | 0.7x |
| 5 | 20-25 min | 2.8x | 1.4x | 0.6x |
| 6 | 25-30 min | 3.5x | 1.5x | 0.55x |
| N | (5N) min | 1.0 + 0.3*N + 0.05*N*(N-1)/2 | 1.0 + 0.1*(N-1) | max(0.5, 1.0 - 0.1*(N-1)) |

This replaces the current per-minute linear scaling with per-cycle stepped scaling. Benefits:
- **More predictable**: Players can feel the difficulty jump at each cycle boundary.
- **Paired with wave structure**: Difficulty increase coincides with a new cycle of waves.
- **Slower early escalation**: Cycle 2 is only 1.3x HP vs. old 1.5x at 5 min.

---

## 5. Boss HP Pacing

### 5.1 Boss HP Across Modes

| Mode | Boss Base HP | Difficulty Boss HP Mul | Effective HP |
|---|---|---|---|
| Easy | 200 | 0.6 | 120 |
| Normal | 200 | 1.0 | 200 |
| Hard | 200 | 2.0 | 400 |
| Endless (Cycle 1) | 200 | 1.0 | 200 |
| Endless (Cycle 2) | 200 * 1.5 = 300 | 1.0 | 300 |
| Endless (Cycle 3) | 300 * 1.5 = 450 | 1.0 | 450 |

### 5.2 Boss Kill Time Analysis

Assuming mid-run DPS of approximately 15 damage/second (2 weapons at Lv2-3):

| Mode | Boss HP | Estimated Kill Time | Notes |
|---|---|---|---|
| Easy | 120 | ~8s | Very fast, appropriate for easy |
| Normal | 200 | ~13s | Good pacing, boss lasts ~13s |
| Hard | 400 | ~27s | Long fight, high pressure from adds |
| Endless C1 | 200 | ~13s | Standard |
| Endless C2 | 300 | ~20s | Noticeably longer |
| Endless C3 | 450 | ~30s | Very long, adds significant pressure |
| Endless C5 | 1013 | ~67s | Extreme, requires evolved weapons |

### 5.3 Issue: Hard Mode Boss HP May Be Too High

A 400 HP boss in hard mode takes ~27 seconds to kill. During this time, enemies spawn every 0.56s at count 6, meaning approximately 290 additional enemies spawn during the boss fight. With max_enemy_cap=70, this creates sustained full-screen pressure.

**Analysis**: This is intentional -- hard mode SHOULD be extremely challenging. However, the boss fight duration of 27s is on the edge of being tedious rather than exciting. A minor HP reduction would make the fight feel more dynamic.

**Proposed Tuning**: Reduce hard mode `boss_hp_mul` from 2.0 to 1.8.

| Constant Name | Current Value | Proposed Value | Notes |
|---|---|---|---|
| `HARD_BOSS_HP_MUL` | 2.0 | 1.8 | Boss still 360 HP (18s kill time vs 27s) |

This reduces the boss fight to ~18 seconds, which is more engaging while still being harder than normal.

---

## 6. Player Survivability Analysis

### 6.1 Effective HP by Character and Difficulty

| Character | Base HP | Easy (x1.25) | Normal (x1.0) | Hard (x0.75) | Shop HP Bonus |
|---|---|---|---|---|---|
| Mage | 8 | 10 | 8 | 6 | +0/+1/+2/+3 (max 3 shop levels) |
| Warrior | 12 | 15 | 12 | 9 | +0/+1/+2/+3 |
| Ranger | 6 | 7.5 | 6 | 4.5 | +0/+1/+2/+3 |

### 6.2 Issue: Ranger in Hard Mode Has Very Low Survivability

Ranger at 4.5 HP in hard mode, with enemy_dmg_mul=1.5, means:
- Zombie hit: max(1, 1*1.5 - armor) = 1.5 damage (33% of HP)
- Boss hit: max(1, 2*1.5 - armor) = 3 damage (67% of HP)

Ranger dies in 3 hits from normal enemies or 2 hits from the boss. With invincibility frames of 0.5s (HIT_INVINCIBILITY_TIME), the player needs to avoid being hit for 1.5 seconds between boss hits to survive a 3-hit encounter.

**Analysis**: This is working as designed -- Ranger is the "glass cannon" character. The high speed (190 * 0.9 = 171 in hard) compensates for low HP. No change needed.

### 6.3 Armor Impact Analysis

Warrior starts with +1 armor. With armor at various stacks:

| Armor | Zombie Hit (Normal) | Zombie Hit (Hard) | Boss Hit (Normal) | Boss Hit (Hard) |
|---|---|---|---|---|
| 0 | max(1, 1-0) = 1 | max(1, 1.5-0) = 1.5 | max(1, 2-0) = 2 | max(1, 3-0) = 3 |
| 1 | max(1, 1-1) = 1 | max(1, 1.5-1) = 1 | max(1, 2-1) = 1 | max(1, 3-1) = 2 |
| 2 | max(1, 1-2) = 1 | max(1, 1.5-2) = 1 | max(1, 2-2) = 1 | max(1, 3-2) = 1 |
| 3 | max(1, 1-3) = 1 | max(1, 1.5-3) = 1 | max(1, 2-3) = 1 | max(1, 3-3) = 1 |

Armor is capped by the minimum damage rule (MIN_DAMAGE=1.0). With 3 armor, all non-boss hits are reduced to 1 damage. The armor_maxhp synergy (armor effect doubled) effectively doubles this cap:
- 3 armor + synergy = effective armor 6, which still caps at min 1 damage.

**Analysis**: Armor diminishing returns kick in at armor=2 for normal enemies, armor=3 for hard boss. This is appropriate.

---

## 7. XP Economy Across Difficulties

### 7.1 XP Table and Level Progression

| Level | XP Needed | Cumulative XP | Enemies Killed (avg 2 XP each) |
|---|---|---|---|
| 1->2 | 8 | 8 | 4 |
| 2->3 | 12 | 20 | 10 |
| 3->4 | 18 | 38 | 19 |
| 4->5 | 24 | 62 | 31 |
| 5->6 | 32 | 94 | 47 |
| 6->7 | 42 | 136 | 68 |
| 7->8 | 55 | 191 | 96 |
| 8->9 | 70 | 261 | 131 |
| 9->10 | 88 | 349 | 175 |
| 10->11 | 108 | 457 | 229 |
| 11->12 | 132 | 589 | 295 |
| 12->13 | 160 | 749 | 375 |
| 13->14 | 195 | 944 | 472 |
| 14->15 | 240 | 1184 | 592 |

### 7.2 Expected Level at 5 Minutes by Difficulty

| Difficulty | XP Mul | Est Kills (5 min) | Est XP from Kills | + Combo Bonus (avg 20%) | + Chest XP | Total XP | Expected Level |
|---|---|---|---|---|---|---|---|
| Easy | 1.3 | ~100 | 200 * 1.3 = 260 | +52 | +20 | 332 | Lv 9 |
| Normal | 1.0 | ~180 | 360 | +72 | +20 | 452 | Lv 10 |
| Hard | 0.8 | ~150 | 300 * 0.8 = 240 | +48 | +20 | 308 | Lv 9 |

**Analysis**: Players reach approximately Lv 9-10 in a 5-minute run across all difficulties. This gives them:
- 3-4 weapon slots (start with 1, gain from upgrades)
- 1-2 weapons at Lv3 (ready for evolution)
- Possibly 1 evolved weapon if they got lucky with upgrade options

This pacing feels right -- the player is powerful but not maxed out, leaving room for "one more run" to try a different build.

### 7.3 Endless Mode XP Curve

| Time | Est Level | Notes |
|---|---|---|
| 5 min | ~10 | Same as normal |
| 10 min | ~14 | Near end of XP table |
| 15 min | ~16 | Beyond XP table, using scaling formula |
| 20 min | ~18 | Diminishing returns on XP per level |

Beyond level 14, the XP scaling formula is `240 * (1 + (idx - 13) * 0.5)`:
- Lv 15: 240 * 1.5 = 360
- Lv 16: 240 * 2.0 = 480
- Lv 17: 240 * 2.5 = 600
- Lv 18: 240 * 3.0 = 720

This creates a natural soft cap on leveling, which is appropriate for endless mode.

---

## 8. Proposed Tuning Changes Summary

### 8.1 Changes to Implement

| # | Parameter | Current | Proposed | Reason |
|---|---|---|---|---|
| 1 | Hard `boss_hp_mul` | 2.0 | 1.8 | 400 HP boss takes 27s to kill; 360 HP takes 18s, more engaging |
| 2 | Hard minimum spawn interval | None (0.56s effective) | 0.7s floor | Prevents overwhelming spawn rate at 180s+ |
| 3 | Endless HP scaling | Per-minute linear (+10%/min) | Per-cycle stepped (+30% per cycle, see stage-system.md) | Smoother early scaling, pairs with wave structure |
| 4 | Endless speed scaling | Per-minute linear (+5%/min) | Per-cycle stepped (+10% per cycle) | Same reason as above |

### 8.2 Numerical Constants for Changes

```gdscript
# In game_manager.gd DIFFICULTY_PRESETS, modify "hard":
"hard": {
    "player_hp_mul": 0.75, "player_speed_mul": 0.9,
    "enemy_hp_mul": 1.5, "enemy_speed_mul": 1.3, "enemy_dmg_mul": 1.5,
    "spawn_interval_mul": 0.7, "spawn_count_mod": 1,
    "boss_hp_mul": 1.8,  # Changed from 2.0
    "boss_speed_mul": 1.3, "exp_mul": 0.8, "food_drop_mul": 0.6
}

# In enemy_spawner.gd, add:
const MIN_SPAWN_INTERVAL: float = 0.7  # Hard mode floor

# In _get_spawn_interval(), apply:
func _get_spawn_interval() -> float:
    var base: float
    # ... existing time-based logic ...
    var interval: float = base * GameManager.get_difficulty_mul("spawn_interval_mul")
    return maxf(MIN_SPAWN_INTERVAL, interval)
```

### 8.3 Endless Cycle Scaling Constants (for stage-system.md integration)

```gdscript
# In enemy_spawner.gd (or wave system)
const ENDLESS_CYCLE_HP_BASE: float = 0.3       # +30% HP per cycle
const ENDLESS_CYCLE_SPD_BASE: float = 0.1      # +10% speed per cycle
const ENDLESS_CYCLE_RATE_BASE: float = 0.1     # -10% spawn rate per cycle
const ENDLESS_CYCLE_RATE_FLOOR: float = 0.5    # Minimum spawn rate multiplier

func get_endless_cycle_multiplier(cycle: int) -> Dictionary:
    return {
        "hp_mul": 1.0 + ENDLESS_CYCLE_HP_BASE * cycle,
        "spd_mul": 1.0 + ENDLESS_CYCLE_SPD_BASE * cycle,
        "rate_mul": maxf(ENDLESS_CYCLE_RATE_FLOOR, 1.0 - ENDLESS_CYCLE_RATE_BASE * (cycle - 1))
    }
```

---

## 9. Impact Analysis

### 9.1 Hard Mode Boss Kill Time Comparison

| Metric | Current (2.0x) | Proposed (1.8x) | Change |
|---|---|---|---|
| Boss HP | 400 | 360 | -10% |
| Kill time (15 DPS) | ~27s | ~24s | -3s |
| Enemies spawned during boss | ~290 | ~257 | -33 |
| Feels | Grueling | Challenging | Better |

### 9.2 Hard Mode Late Game Spawn Rate Comparison

| Metric | Current | With 0.7s Floor | Change |
|---|---|---|---|
| Interval at 180s | 0.56s | 0.7s | +25% slower |
| Enemies/sec (count 6) | 10.7 | 8.6 | -20% fewer |
| Time to fill 70 cap | 6.5s | 8.1s | +1.6s breathing room |

### 9.3 Endless Mode Scaling Comparison

| Time | Current HP Mult | Proposed HP Mult (Cycle) | Difference |
|---|---|---|---|
| 5 min | 1.5x (linear) | 1.0x (still cycle 1) | -0.5x (easier) |
| 10 min | 2.0x (linear) | 1.3x (cycle 2) | -0.7x (easier) |
| 15 min | 2.5x (linear) | 1.7x (cycle 3) | -0.8x (easier) |
| 20 min | 3.0x (linear) | 2.2x (cycle 4) | -0.8x (easier) |
| 30 min | 4.0x (linear) | 3.5x (cycle 6) | -0.5x (easier) |

The proposed cycle-based scaling is gentler in the early-to-mid game (5-15 min) and roughly catches up at 20+ min. This creates a better experience where:
- Players feel a gradual ramp rather than an immediate spike.
- The first 10 minutes feel similar to normal mode difficulty.
- Difficulty escalates noticeably at cycle boundaries (every 5 minutes).

---

## 10. File Change Map

### 10.1 Files to Modify

| File | Change | Lines |
|---|---|---|
| `scripts/autoload/game_manager.gd` | Change `DIFFICULTY_PRESETS["hard"].boss_hp_mul` from 2.0 to 1.8; add `MIN_SPAWN_INTERVAL` constant | ~3 lines |
| `scripts/enemy_spawner.gd` | Add `MIN_SPAWN_INTERVAL = 0.7`; apply floor in `_get_spawn_interval()`; replace per-minute scaling with per-cycle scaling (when stage system is integrated) | ~10 lines |

### 10.2 New Files Needed

None.

### 10.3 Testing Impact

Existing tests that assert hard mode boss HP multiplier = 2.0 will need to be updated:
- `test/unit/test_difficulty_data.gd` -- verify boss_hp_mul = 1.8 for hard
- `test/unit/test_enemy_spawner.gd` -- verify spawn interval floor is respected

---

## 11. Design Decisions Log

| Decision | Why | Alternative Considered |
|---|---|---|
| Hard boss HP 1.8x instead of 2.0x | 27s boss fight is tedious; 24s is still very challenging | Keep 2.0x (too long), reduce to 1.5x (not hard enough) |
| 0.7s spawn floor for hard mode | Prevents spawn spam that overwhelms without skill-based counterplay | No floor (current), 0.8s floor (too generous) |
| Cycle-based endless scaling | Pairs with wave structure, creates clear difficulty jumps | Keep per-minute linear (less predictable, harder to balance) |
| No changes to Easy/Normal | Presets match H5 exactly and provide appropriate difficulty | N/A |
| No changes to player survivability | Ranger/Hard difficulty is working as designed (glass cannon trade-off) | Buff Ranger HP (removes character identity) |
