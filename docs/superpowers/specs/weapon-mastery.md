# Weapon Mastery System Design

**Author**: Designer Agent
**Date**: 2026-04-17
**Round**: R19
**Status**: Design Spec
**Context**: v1.0.2 roadmap item ranked #4 by priority. Weapon mastery provides long-term per-weapon progression beyond shop upgrades, creating 28 milestones (7 weapons x 4 tiers) for dedicated players.

---

## 1. System Overview

### 1.1 Concept

Weapon Mastery is a persistent per-weapon progression system that tracks kills attributed to each base weapon type. As the player accumulates kills, they unlock mastery tiers that provide permanent bonuses when using that weapon. This creates long-term goals ("I want to master the boomerang") that persist across runs.

### 1.2 Design Goals

1. **Extend engagement beyond shop completion**: After ~10 runs, the shop is maxed (with T4). Weapon mastery provides an additional 28 milestones to pursue.
2. **Encourage weapon variety**: Each weapon tracks kills independently, incentivizing players to try different weapons across runs.
3. **Provide meaningful but not dominant bonuses**: Mastery bonuses should feel rewarding but never make or break a build.
4. **Leverage existing infrastructure**: Kill attribution (`_last_hit_by` on enemy) already tracks which weapon dealt the killing blow.

### 1.3 Scope

- **7 base weapons** only (knife, holywater, lightning, bible, firestaff, frostaura, boomerang)
- Evolved weapons do NOT have separate mastery (kills with evolved weapons count toward both parent weapons)
- 4 mastery tiers per weapon
- Persistent across sessions via SaveManager

---

## 2. Mastery Tiers and Thresholds

### 2.1 Tier Definitions

| Tier | Name | Kill Threshold | Damage Bonus | Visual Indicator |
|---|---|---|---|---|
| 0 | Novice | 0 | +0% | Gray badge |
| 1 | Apprentice | 50 | +2% | Bronze badge |
| 2 | Adept | 200 | +4% | Silver badge |
| 3 | Expert | 500 | +6% | Gold badge |
| 4 | Master | 1000 | +8% | Diamond badge (animated glow) |

**Why these thresholds**:
- 50 kills: Achievable in 1-2 runs with focused weapon use (~90 kills per run with primary weapon). First milestone feels attainable.
- 200 kills: Achievable in 3-4 runs. Requires deliberate weapon use across multiple sessions.
- 500 kills: Achievable in 8-10 runs. A medium-term commitment.
- 1000 kills: Achievable in 15-20 runs. A long-term "mastery" goal that takes weeks of casual play.

### 2.2 Kill Rate Estimation

Based on average Normal mode runs:
- Total kills per run: ~180
- Primary weapon kills: ~90 (player typically focuses upgrades on 1-2 weapons)
- Secondary weapon kills: ~60
- Third weapon kills: ~30

| Weapon Usage Pattern | Kills/Run | Runs to Tier 1 (50) | Runs to Tier 4 (1000) |
|---|---|---|---|
| Primary weapon (focused) | 90 | ~1 | ~11 |
| Secondary weapon | 60 | ~1 | ~17 |
| Rarely used weapon | 30 | ~2 | ~33 |

This means a player who always uses the same primary weapon will master it in ~11 runs, while rarely-used weapons take ~33 runs. The asymmetry is intentional -- mastery encourages weapon variety but does not mandate it.

---

## 3. Damage Bonus Design

### 3.1 Bonus Structure

Mastery damage bonus is **additive with shop weaponDmg bonus** and **multiplicative with character passive**.

```
Final Damage = Base Damage x (1 + shop_bonus + mastery_bonus) x character_passive
```

**Example**: Mage with knife, shop weapondmg T4 (15%), knife mastery Tier 3 (6%):
```
Final Damage = Base x (1 + 0.15 + 0.06) x 1.20
            = Base x 1.21 x 1.20
            = Base x 1.452
```

A 45% total bonus from permanent upgrades after ~15 runs of investment. This is meaningful but not dominant.

### 3.2 Balance Analysis

| Scenario | Shop Bonus | Mastery Bonus | Character Passive | Total Multiplier |
|---|---|---|---|---|
| New player (no upgrades) | 0% | 0% | 1.0x | 1.00x |
| Shop T4, no mastery | 15% | 0% | 1.0x | 1.15x |
| Shop T4, Tier 4 mastery | 15% | 8% | 1.0x | 1.23x |
| Mage + Shop T4 + Tier 4 mastery | 15% | 8% | 1.20x | 1.48x |
| Ranger crit build + Tier 4 mastery | 15% | 8% | 1.23x (crit) | 1.51x |

**Maximum total multiplier**: 1.51x (Ranger with full shop and mastery). This is well within balance tolerance -- a 51% permanent damage increase after 15+ runs is a fair reward for long-term investment.

### 3.3 Per-Weapon Mastery Bonus Application

The mastery bonus applies **only to kills attributed to the mastered weapon type**. This is enforced by the existing `_last_hit_by` system on enemies.

The damage bonus is applied in `weapon_controller.gd` or `player.gd` when calculating `dmg_bonus`:

```gdscript
# Pseudocode for mastery bonus application
var mastery_bonus: float = SaveManager.get_weapon_mastery_bonus(weapon_id)
dmg_bonus += mastery_bonus
```

This means:
- Knife mastery bonus applies when knife projectiles deal damage
- Holywater mastery bonus applies when holywater orbs deal damage
- Lightning mastery bonus applies when lightning strikes deal damage
- FrostAura mastery bonus applies when aura ticks deal damage
- Boomerang mastery bonus applies when boomerang hits deal damage

---

## 4. Evolved Weapon Kill Attribution

### 4.1 Design Decision

Evolved weapons do NOT have their own mastery track. Instead, kills with an evolved weapon count toward **both parent weapons**.

**Example**: Player evolves knife + firestaff into fireknife. Kills with fireknife count toward both knife mastery AND firestaff mastery.

### 4.2 Rationale

1. **Avoids mastery dead-ends**: If evolved weapons had separate mastery, the 9 evolved weapons would dilute the kill pool (7 base + 9 evolved = 16 tracks). With only ~90 primary kills per run, reaching Tier 4 on any evolved weapon would take 30+ runs.
2. **Rewards the evolution investment**: Evolving a weapon should feel like a mastery accelerator, not a mastery reset.
3. **Simpler UI**: 7 mastery tracks instead of 16. Easier to display and understand.

### 4.3 Implementation

In `enemy.gd`, when a kill is attributed to an evolved weapon, the kill is counted for both parent weapons:

```gdscript
# Pseudocode for kill attribution in enemy.die()
var weapon_id: String = _last_hit_by  # e.g., "fireknife"
var mastery_weapon: String = weapon_id

# Check if evolved weapon -- map to parent weapons
var evolved_parents: Dictionary = {
    "thunderholywater": ["holywater", "lightning"],
    "fireknife": ["knife", "firestaff"],
    "holydomain": ["bible", "holywater"],
    "blizzard": ["frostaura", "lightning"],
    "frostknife": ["knife", "frostaura"],
    "flamebible": ["bible", "firestaff"],
    "thunderang": ["boomerang", "lightning"],
    "blazerang": ["boomerang", "firestaff"],
    "sentineltotem": ["bible", "boomerang"],
}

if evolved_parents.has(weapon_id):
    for parent_id: String in evolved_parents[weapon_id]:
        SaveManager.add_weapon_kill(parent_id)
else:
    SaveManager.add_weapon_kill(weapon_id)
```

---

## 5. Persistence Design

### 5.1 SaveManager Extension

**File**: `scripts/autoload/save_manager.gd`

New variables:

```gdscript
# Weapon mastery kill counts (base weapons only)
var weapon_kills: Dictionary = {}  # weapon_id -> kill count
```

New constants:

```gdscript
# Mastery tier thresholds
const MASTERY_THRESHOLDS: Array[int] = [0, 50, 200, 500, 1000]
const MASTERY_BONUSES: Array[float] = [0.0, 0.02, 0.04, 0.06, 0.08]
const BASE_WEAPONS: Array[String] = ["knife", "holywater", "lightning", "bible", "firestaff", "frostaura", "boomerang"]
```

New functions:

```gdscript
func add_weapon_kill(weapon_id: String) -> void:
    if weapon_id in BASE_WEAPONS:
        weapon_kills[weapon_id] = weapon_kills.get(weapon_id, 0) + 1


func get_weapon_kill_count(weapon_id: String) -> int:
    return weapon_kills.get(weapon_id, 0)


func get_weapon_mastery_tier(weapon_id: String) -> int:
    var kills: int = get_weapon_kill_count(weapon_id)
    var tier: int = 0
    for i in range(MASTERY_THRESHOLDS.size() - 1, -1, -1):
        if kills >= MASTERY_THRESHOLDS[i]:
            tier = i
            break
    return tier


func get_weapon_mastery_bonus(weapon_id: String) -> float:
    var tier: int = get_weapon_mastery_tier(weapon_id)
    if tier < MASTERY_BONUSES.size():
        return MASTERY_BONUSES[tier]
    return 0.0
```

### 5.2 Save/Load Integration

**Save** (in `save()` function):
```gdscript
for weapon_id in weapon_kills:
    config.set_value("mastery", weapon_id, weapon_kills[weapon_id])
```

**Load** (in `load_save()` function):
```gdscript
for weapon_id: String in BASE_WEAPONS:
    weapon_kills[weapon_id] = config.get_value("mastery", weapon_id, 0)
```

### 5.3 Initialization

In `_init_data()`, add:
```gdscript
for weapon_id: String in BASE_WEAPONS:
    weapon_kills[weapon_id] = 0
```

In `reset_save()`, add:
```gdscript
weapon_kills.clear()
for weapon_id: String in BASE_WEAPONS:
    weapon_kills[weapon_id] = 0
```

---

## 6. Kill Attribution Integration

### 6.1 Where to Record Kills

Kill attribution happens in `enemy.gd` `_handle_kill_rewards()`. The `_last_hit_by` variable already tracks which weapon dealt the final blow.

**Current flow**:
1. `enemy.take_damage(amount, source, was_crit)` sets `_last_hit_by = source`
2. `enemy.die()` calls `_handle_kill_rewards()`
3. `_handle_kill_rewards()` calls `GameManager.register_kill()`

**Extended flow** (adding mastery):
1. (same)
2. (same)
3. `_handle_kill_rewards()` calls `GameManager.register_kill()` AND `SaveManager.add_weapon_kill(_last_hit_by)` (with evolved weapon mapping)

### 6.2 Implementation in enemy.gd

In `_handle_kill_rewards()`, after the existing `GameManager.register_kill()` call:

```gdscript
# Weapon mastery kill attribution
if SaveManager and _last_hit_by != "":
    var evolved_parents: Dictionary = {
        "thunderholywater": ["holywater", "lightning"],
        "fireknife": ["knife", "firestaff"],
        "holydomain": ["bible", "holywater"],
        "blizzard": ["frostaura", "lightning"],
        "frostknife": ["knife", "frostaura"],
        "flamebible": ["bible", "firestaff"],
        "thunderang": ["boomerang", "lightning"],
        "blazerang": ["boomerang", "firestaff"],
        "sentineltotem": ["bible", "boomerang"],
    }
    if evolved_parents.has(_last_hit_by):
        for parent_id: String in evolved_parents[_last_hit_by]:
            SaveManager.add_weapon_kill(parent_id)
    else:
        SaveManager.add_weapon_kill(_last_hit_by)
```

### 6.3 When _last_hit_by is Empty

If an enemy dies from burn damage (firestaff DOT), `_last_hit_by` may be "firestaff" (set when burn was applied). If an enemy dies from frostaura shatter, `_last_hit_by` is "frostaura". These cases are already handled correctly.

If an enemy dies from splitter child explosion or other indirect damage, `_last_hit_by` may be empty. In this case, no mastery kill is recorded. This is acceptable -- these edge cases are rare and do not significantly impact mastery progress.

---

## 7. Damage Bonus Application

### 7.1 Where to Apply Mastery Bonus

The mastery damage bonus should be applied in the same place where the shop `weapondmg` bonus is applied. Based on current code, weapon damage is calculated in `weapon_controller.gd` or `player.gd`.

The cleanest integration point is in `player.gd` where `dmg_bonus` is computed:

```gdscript
# Current (simplified)
var dmg_bonus: float = 1.0
if SaveManager:
    dmg_bonus += SaveManager.get_weapon_dmg_bonus()
# Character passive
if selected_character == "mage":
    dmg_bonus *= 1.20
```

**New** (adding mastery):
```gdscript
var dmg_bonus: float = 1.0
if SaveManager:
    dmg_bonus += SaveManager.get_weapon_dmg_bonus()
# Mastery bonus is applied per-weapon in weapon_controller.gd
```

The mastery bonus is weapon-specific, so it must be applied in `weapon_controller.gd` or in the individual weapon fire functions, not as a global multiplier. The recommended approach:

**In weapon_controller.gd**, when computing damage for a specific weapon:

```gdscript
func _get_weapon_damage(weapon_id: String, base_damage: float) -> float:
    var dmg: float = base_damage
    # Shop bonus (additive)
    if SaveManager:
        dmg *= (1.0 + SaveManager.get_weapon_dmg_bonus())
    # Mastery bonus (additive with shop)
    if SaveManager:
        dmg *= (1.0 + SaveManager.get_weapon_mastery_bonus(weapon_id))
    # Character passive (multiplicative)
    if GameManager.selected_character == "mage":
        dmg *= 1.20
    return dmg
```

### 7.2 Impact on DPS Rankings

With mastery Tier 4 (+8%) on a single weapon:

| Weapon | Current Lv3 DPS | With T4 Shop (15%) | With T4 Shop + Mastery (23%) | Delta from Mastery |
|---|---|---|---|---|
| Knife | 6.00 | 6.90 | 7.38 | +7.0% |
| HolyWater | 6.00 | 6.90 | 7.38 | +7.0% |
| Lightning | 7.50 | 8.63 | 9.23 | +6.9% |
| Bible | 6.00 | 6.90 | 7.38 | +7.0% |
| FireStaff | 6.67 | 7.67 | 8.21 | +7.0% |
| FrostAura | 2.00 | 2.30 | 2.46 | +7.0% |
| Boomerang | 7.50 | 8.63 | 9.23 | +6.9% |

The mastery bonus is a flat ~7% increase over the shop-only build. This is noticeable but does not change the DPS ranking order. The relative balance between weapons is preserved.

---

## 8. UI Display Design

### 8.1 Shop Screen Integration

Add a "Weapon Mastery" section below the existing shop upgrades in the shop screen. This shows a compact grid of 7 weapon entries.

**Layout** (ASCII mockup):
```
=== WEAPON MASTERY ===

[Knife]       Apprentice (52/200)    +2% DMG   [=========---]
[Holy Water]  Novice (12/50)         +0% DMG   [==----------]
[Lightning]   Expert (623/1000)      +6% DMG   [=============]
[Bible]       Adept (204/500)        +4% DMG   [======-------]
[Fire Staff]  Adept (312/500)        +4% DMG   [========-----]
[Frost Aura]  Novice (38/50)         +0% DMG   [============-]
[Boomerang]   Master (1023/1000)     +8% DMG   [=============] Diamond!
```

Each row shows:
1. Weapon name
2. Current tier name
3. Kill progress (current/next threshold)
4. Current bonus percentage
5. Progress bar (visual fill toward next tier)

### 8.2 Implementation Notes

- The mastery section is a separate VBoxContainer added to the shop scene's ScrollContainer
- Weapon icon colors match the upgrade_pool.gd weapon color definitions
- Tier badge colors: Gray (#808080), Bronze (#CD7F32), Silver (#C0C0C0), Gold (#FFD700), Diamond (#B9F2FF)
- Tier 4 (Master) has a subtle pulsing animation on the progress bar to indicate completion
- Progress bar uses the ColorRect pixel art style (consistent with the rest of the UI)

### 8.3 In-Run HUD Integration

When the player picks up a weapon, the HUD weapon slot shows the mastery tier as a small badge:

```
[Knife] [Lv2] [*]   <-- Bronze star for Apprentice tier
```

Tier badges: No badge (Novice), * (Apprentice), ** (Adept), *** (Expert), Diamond icon (Master).

This is a v1.0.2 stretch goal. The minimum viable display is the shop screen section.

---

## 9. Achievement Integration

### 9.1 New Achievements

Add 2 new achievements for weapon mastery:

| ID | Name | Description | Condition | Reward |
|---|---|---|---|---|
| mastery_first | First Steps | Reach Apprentice tier on any weapon | Any weapon >= 50 kills | 30 SF |
| mastery_all | True Master | Reach Master tier on all 7 weapons | All 7 weapons >= 1000 kills | 500 SF |

### 9.2 Achievement Checking

These are checked in `SaveManager.check_quests_and_achievements()` at the end of each run:

```gdscript
# Mastery achievements
var max_tier: int = 0
var all_master: bool = true
for weapon_id: String in BASE_WEAPONS:
    var tier: int = get_weapon_mastery_tier(weapon_id)
    if tier > max_tier:
        max_tier = tier
    if tier < 4:
        all_master = false
_check_achievement("mastery_first", max_tier >= 1)
_check_achievement("mastery_all", all_master)
```

### 9.3 Total Mastery Cost

To reach Master on all 7 weapons: 7 x 1000 = 7000 total kills.
At ~180 kills per run (assuming even distribution), this takes ~39 runs.
With focused weapon use, it takes ~15-20 runs per weapon, ~78 runs total for all 7.

The `mastery_all` achievement (500 SF reward) is designed as a long-term goal that takes 1-2 months of casual play.

---

## 10. Implementation Scope

### 10.1 File Changes

| File | Change | Lines |
|---|---|---|
| `scripts/autoload/save_manager.gd` | Add mastery variables, constants, functions, save/load | ~50 |
| `scripts/enemy.gd` | Add mastery kill attribution in `_handle_kill_rewards()` | ~15 |
| `scripts/weapon_controller.gd` | Add mastery bonus to damage calculation | ~5 |
| `scripts/shop.gd` | Add mastery display section | ~60 |
| `test/unit/test_save_manager.gd` | Add mastery tests | ~40 |
| `test/unit/test_mastery.gd` | New mastery system tests | ~80 |
| **Total** | | **~250** |

### 10.2 Test Plan

| Test | Description |
|---|---|
| test_mastery_init | All 7 weapons start at 0 kills, Tier 0 |
| test_mastery_kill_counting | add_weapon_kill increments count |
| test_mastery_tier_progression | 50 kills = Tier 1, 200 = Tier 2, etc. |
| test_mastery_bonus_values | Each tier returns correct bonus (0/2/4/6/8%) |
| test_mastery_evolved_attribution | fireknife kill counts for knife AND firestaff |
| test_mastery_save_load | Mastery persists across save/load |
| test_mastery_reset | reset_save clears all mastery |
| test_mastery_unknown_weapon | Non-base weapon IDs are ignored |
| test_mastery_achievements | mastery_first and mastery_all trigger correctly |

---

## 11. Decision Record

| Decision | Why | Alternative Considered |
|---|---|---|
| 4 tiers (not 3 or 5) | 4 tiers provides granularity without excessive grind. 3 tiers would feel too coarse. 5 tiers would make Tier 5 unreachable for casual players. | 5 tiers with 2000-kill max (too grindy for demo scope) |
| Kill thresholds: 50/200/500/1000 | Exponential curve (2x, 2.5x, 2x) provides regular early milestones and a meaningful long-term goal. | Linear (250/500/750/1000) -- too slow for first milestone; Quadratic (50/250/1000/4000) -- last tier too extreme |
| Additive with shop bonus | Simplest formula. Multiplicative would create a 1.15 * 1.08 = 1.242x bonus, which is only marginally different from additive 1.23x. | Multiplicative (more complex for negligible difference) |
| Evolved weapons credit both parents | Avoids mastery dead-ends with evolved weapons. Rewards evolution investment. | Separate evolved mastery tracks (16 total tracks, too diluted) |
| No mastery for evolved weapons | Keeps system simple (7 tracks) and focused on base weapons. | Evolved mastery as endgame goal (too many tracks, dilutes progression) |
| Mastery bonus is weapon-specific | Prevents "master one weapon, bonus applies to all" loophole. Each mastery must be earned independently. | Global mastery bonus based on total kills (reduces incentive to try new weapons) |
| UI in shop screen (not separate) | Shop is the meta-progression hub. Adding mastery there keeps all permanent upgrades in one place. | Separate mastery screen (more navigation, less cohesive) |

---

## 12. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Mastery grind feels tedious | Medium | Medium | Tier 1 at 50 kills is achievable in 1 run. Regular early milestones prevent grind fatigue. |
| Mastery bonus unbalances Hard mode | Low | Medium | Maximum bonus is +8%, additive with shop +15%. Total 23% increase after 20+ runs. Hard mode's 1.5x enemy HP scaling easily absorbs this. |
| Kill attribution edge cases | Medium | Low | Burn kills, shatter kills, and splitter deaths may not attribute correctly. These are rare edge cases that minimally affect mastery progress. |
| Save file bloat | Very Low | Low | 7 integers added to ConfigFile. Negligible storage impact. |
| Players optimize around one weapon | Medium | Low | This is actually a desired behavior -- mastery encourages weapon loyalty, creating "main weapon" identity. |

---

## 13. Success Criteria

1. 7 base weapons track kills independently and persistently
2. 4 mastery tiers unlock at 50/200/500/1000 kills
3. Mastery damage bonus (+0/2/4/6/8%) applies correctly per-weapon
4. Evolved weapon kills credit both parent weapons
5. Mastery progress visible in shop screen
6. 2 new achievements (mastery_first, mastery_all) trigger correctly
7. All existing tests pass (zero regressions)
8. New mastery tests pass (~80 assertions)
9. Mastery system adds no more than 250 lines of code
