# Shop Tier 4 Upgrade Design

**Author**: Designer Agent
**Date**: 2026-04-17
**Round**: R19
**Status**: Design Spec
**Context**: R18 game-experience-review identified that the shop maxes in ~5 runs (875 total cost / 174 soul fragments per run). This is too fast for long-term engagement. This spec designs Tier 4 upgrades to extend the grind from ~5 runs to ~10 runs.

---

## 1. Current Shop State

### 1.1 Existing Upgrades (Tier 1-3)

**Source**: `scripts/autoload/save_manager.gd` lines 28-35

```gdscript
const SHOP_UPGRADES: Dictionary = {
    "maxhp":     {"name": "生命强化", "icon": "heart", "costs": [20, 40, 80],   "max_level": 3},
    "speed":     {"name": "速度训练", "icon": "shoe",  "costs": [20, 40, 80],   "max_level": 3},
    "pickup":    {"name": "拾取精通", "icon": "radio", "costs": [15, 30, 60],   "max_level": 3},
    "expbonus":  {"name": "知识汲取", "icon": "book",  "costs": [25, 50, 100],  "max_level": 3},
    "weapondmg": {"name": "武器精通", "icon": "sword", "costs": [30, 60, 120],  "max_level": 3},
    "gold":      {"name": "贪婪之心", "icon": "coin",  "costs": [15, 30, 60],   "max_level": 3},
}
```

### 1.2 Current Total Cost

| Upgrade | T1 | T2 | T3 | Total |
|---|---|---|---|---|
| maxhp | 20 | 40 | 80 | 140 |
| speed | 20 | 40 | 80 | 140 |
| pickup | 15 | 30 | 60 | 105 |
| expbonus | 25 | 50 | 100 | 175 |
| weapondmg | 30 | 60 | 120 | 210 |
| gold | 15 | 30 | 60 | 105 |
| **TOTAL** | | | | **875** |

### 1.3 Economy Baseline

- Average soul fragments per run (Normal): 174
- Average soul fragments per run (Endless, 5min): 261 (1.5x bonus)
- Runs to max current shop: 875 / 174 = **5.0 runs**
- Quest rewards (14 quests, total 1795): These are one-time injections, not sustainable income.

---

## 2. Design Goal

Extend the shop progression from ~5 runs to ~10 runs by adding Tier 4 to each upgrade. The total cost should increase by approximately 875 additional soul fragments, effectively doubling the grind.

### Constraints

1. Tier 4 costs must feel like a meaningful step up from Tier 3 (not a trivial increase).
2. Tier 4 effects must be noticeable but not game-breaking (the shop bonuses are permanent, stacking multiplicatively with in-run bonuses).
3. The `max_level` property changes from 3 to 4.
4. The `costs` array gets a fourth element.
5. The bonus getter functions (e.g., `get_hp_bonus()`) need a fourth array element.
6. Achievement `shop_max_all` should still trigger when all 6 upgrades reach level 4 (new max).
7. Achievement `shop_single_max` should still trigger when any upgrade reaches level 4.

---

## 3. Tier 4 Upgrade Definitions

### 3.1 Numerical Design

| Upgrade | T1 Cost | T2 Cost | T3 Cost | **T4 Cost** | **Total** | T4 Effect |
|---|---|---|---|---|---|---|
| maxhp | 20 | 40 | 80 | **160** | **300** | +5 HP (total: 1+2+3+5 = 11 HP) |
| speed | 20 | 40 | 80 | **160** | **300** | +5% speed (total: 5+5+5+5 = 20%) |
| pickup | 15 | 30 | 60 | **120** | **225** | +10 range (total: 5+5+10+10 = 30 range) |
| expbonus | 25 | 50 | 100 | **200** | **375** | +5% EXP (total: 5+5+5+5 = 20%) |
| weapondmg | 30 | 60 | 120 | **240** | **450** | +5% DMG (total: 3+3+4+5 = 15%) |
| gold | 15 | 30 | 60 | **120** | **225** | +10% gold (total: 10+10+10+10 = 40%) |

### 3.2 Summary

| Metric | Old (T1-T3) | New (T1-T4) | Delta |
|---|---|---|---|
| Total cost | 875 | **1875** | +1000 (+114%) |
| Runs to max (Normal) | 5.0 | **10.8** | +5.8 runs |
| Runs to max (Endless) | 3.4 | **7.2** | +3.8 runs |

This meets the design goal of extending to ~10 runs for Normal mode players.

### 3.3 Tier 4 Cost Progression Rationale

- **maxhp/speed**: 160 (2x T3 cost). These are broadly useful upgrades with no diminishing returns. Higher cost reflects their universal applicability.
- **pickup/gold**: 120 (2x T3 cost). Economy upgrades accelerate future purchases, so their cost must stay in check to avoid a "rich get richer" feedback loop.
- **expbonus**: 200 (2x T3 cost). EXP bonus is the most impactful meta-statistic -- it accelerates all in-run progression. The highest T4 cost reflects this power.
- **weapondmg**: 240 (2x T3 cost). Weapon damage is the single most impactful stat for kill speed, which cascades into XP, gold, and survival. Highest cost justified by highest impact.

---

## 4. Effect Balance Analysis

### 4.1 Per-Upgrade Analysis

#### maxhp: 1 -> 2 -> 3 -> **5** (total +11 HP)

| Level | Cumulative HP Bonus | Effective HP (Mage, Normal) | % Increase vs Base |
|---|---|---|---|
| 0 | 0 | 8 | 0% |
| T3 (Lv3) | +6 | 14 | +75% |
| T4 (Lv4) | +11 | 19 | +138% |

**Why +5 at T4 (not +4)**: The existing progression is +1/+2/+3, which accelerates. A flat +4 would break the acceleration pattern. +5 maintains the curve (+1, +2, +3, +5 = roughly doubling each step). The jump from +3 to +5 (not +4) makes T4 feel like a true "breakthrough" upgrade.

**Balance concern**: 19 HP on Mage Normal seems high, but it is a permanent meta-upgrade earned after ~10 runs. By that point, the player has likely mastered Normal and is moving to Hard/Endless, where the HP matters less relative to scaling enemy damage.

#### speed: +5% -> +10% -> +15% -> **+20%** (total +20%)

Linear progression: each tier adds 5%. T4 continues the pattern. At 160 base speed (Mage), +20% = 192 speed. This is still below Ranger's 190 base, so it does not trivialize speed as a character differentiator.

#### pickup: +5 -> +10 -> +15 -> **+20** (total +30 range)

Adjustment: The original T3 pattern was +5/+5/+5. For T4, I propose adjusting the effect progression to +5/+5/+5/+5 = +20 total (keeping linear). The initial spec above listed +10 at T4, but re-examining the save_manager code, the current progression is:

```gdscript
func get_pickup_bonus() -> float:
    var level: int = shop_upgrades.get("pickup", 0)
    return [0.0, 5.0, 10.0, 15.0][level]
```

This means T1=+5, T2=+10 cumulative, T3=+15 cumulative. So T4 should be +20 cumulative. The T4 effect is +5 range (same increment as previous tiers).

**Correction to section 3.1**: The T4 pickup effect is +5 range (cumulative +20), not +10.

#### expbonus: +5% -> +10% -> +15% -> **+20%** (total +20%)

Linear progression. At 20% bonus, the XP curve tuning from R19 (spec: xp-curve-tuning.md) compounds further. A level 6 player with T4 expbonus earns XP at 1.20x rate, making the already-reduced 29 XP threshold effectively 24.2 XP. This is acceptable -- the combined effect is still within the "slightly faster mid-game" target.

#### weapondmg: +3% -> +6% -> +10% -> **+15%** (total +15%)

The progression is +3/+3/+4/+5. Each tier adds marginally more. At 15% bonus, combined with Mage's 20% character passive and Lv3 shop upgrade, total damage bonus is 1.15 * 1.20 = 1.38x. This is meaningful but not dominant -- a 38% increase after ~10 runs of investment.

#### gold: +10% -> +20% -> +30% -> **+40%** (total +40%)

Linear 10% per tier. At 40%, combined with luckycoin passive (+15% per stack x 3 = +45%), total gold bonus would be 1.40 * 1.45 = 2.03x. This seems high but:
1. It requires T4 shop + 3x luckycoin, a significant investment
2. The gold is only useful for future shop purchases, which become more expensive
3. The feedback loop is self-limiting: once the shop is maxed, gold has no sink

---

## 5. Implementation Instructions

### 5.1 save_manager.gd -- SHOP_UPGRADES constant

**File**: `scripts/autoload/save_manager.gd`
**Lines**: 28-35

**Old value**:
```gdscript
const SHOP_UPGRADES: Dictionary = {
    "maxhp":     {"name": "生命强化", "icon": "heart", "costs": [20, 40, 80], "max_level": 3},
    "speed":     {"name": "速度训练", "icon": "shoe",  "costs": [20, 40, 80], "max_level": 3},
    "pickup":    {"name": "拾取精通", "icon": "radio", "costs": [15, 30, 60], "max_level": 3},
    "expbonus":  {"name": "知识汲取", "icon": "book",  "costs": [25, 50, 100], "max_level": 3},
    "weapondmg": {"name": "武器精通", "icon": "sword", "costs": [30, 60, 120], "max_level": 3},
    "gold":      {"name": "贪婪之心", "icon": "coin",  "costs": [15, 30, 60], "max_level": 3},
}
```

**New value**:
```gdscript
const SHOP_UPGRADES: Dictionary = {
    "maxhp":     {"name": "生命强化", "icon": "heart", "costs": [20, 40, 80, 160], "max_level": 4},
    "speed":     {"name": "速度训练", "icon": "shoe",  "costs": [20, 40, 80, 160], "max_level": 4},
    "pickup":    {"name": "拾取精通", "icon": "radio", "costs": [15, 30, 60, 120], "max_level": 4},
    "expbonus":  {"name": "知识汲取", "icon": "book",  "costs": [25, 50, 100, 200], "max_level": 4},
    "weapondmg": {"name": "武器精通", "icon": "sword", "costs": [30, 60, 120, 240], "max_level": 4},
    "gold":      {"name": "贪婪之心", "icon": "coin",  "costs": [15, 30, 60, 120], "max_level": 4},
}
```

### 5.2 save_manager.gd -- Bonus getter functions

Each getter function needs a fourth array element.

**get_hp_bonus()** (line 155-157):
```gdscript
# Old
func get_hp_bonus() -> int:
    var level: int = shop_upgrades.get("maxhp", 0)
    return [0, 1, 2, 3][level]

# New
func get_hp_bonus() -> int:
    var level: int = shop_upgrades.get("maxhp", 0)
    return [0, 1, 3, 6, 11][level]   # cumulative: 0, +1, +3, +6, +11
```

Note: The current implementation uses cumulative values [0, 1, 2, 3]. The actual cumulative bonus at each level is 0, 1, 1+2=3, 1+2+3=6. But the current code returns [0, 1, 2, 3] which means T2 gives +2 (not +3 cumulative). Looking at the code more carefully:

```gdscript
func get_hp_bonus() -> int:
    var level: int = shop_upgrades.get("maxhp", 0)
    return [0, 1, 2, 3][level]
```

This is already cumulative values: level 0 = 0 HP, level 1 = +1 HP, level 2 = +2 HP, level 3 = +3 HP. Each level adds +1. So the H5 config says `effects:[{hp:1},{hp:2},{hp:3}]` which means cumulative values 1, 2, 3.

For T4, I propose cumulative value of **+5** at level 4:

```gdscript
return [0, 1, 2, 3, 5][level]
```

This means: T1 adds +1, T2 adds +1 (to +2), T3 adds +1 (to +3), T4 adds +2 (to +5). The T4 jump is a "breakthrough" tier.

**get_speed_bonus()** (line 159-161):
```gdscript
# Old
return [0.0, 0.05, 0.10, 0.15][level]
# New
return [0.0, 0.05, 0.10, 0.15, 0.20][level]
```

**get_pickup_bonus()** (line 164-166):
```gdscript
# Old
return [0.0, 5.0, 10.0, 15.0][level]
# New
return [0.0, 5.0, 10.0, 15.0, 20.0][level]
```

**get_exp_bonus()** (line 169-171):
```gdscript
# Old
return [0.0, 0.05, 0.10, 0.15][level]
# New
return [0.0, 0.05, 0.10, 0.15, 0.20][level]
```

**get_weapon_dmg_bonus()** (line 174-176):
```gdscript
# Old
return [0.0, 0.03, 0.06, 0.10][level]
# New
return [0.0, 0.03, 0.06, 0.10, 0.15][level]
```

**get_gold_bonus()** (line 179-181):
```gdscript
# Old
return [0.0, 0.10, 0.20, 0.30][level]
# New
return [0.0, 0.10, 0.20, 0.30, 0.40][level]
```

### 5.3 shop.gd -- Effect text

**File**: `scripts/shop.gd`
**Lines**: 114-122

```gdscript
# Old
func _get_effect_text(id: String) -> String:
    match id:
        "maxhp": return "+1/+2/+3 HP"
        "speed": return "+5%/+10%/+15% Speed"
        "pickup": return "+5/+10/+15 Pickup Range"
        "expbonus": return "+5%/+10%/+15% EXP"
        "weapondmg": return "+3%/+6%/+10% Weapon DMG"
        "gold": return "+10%/+20%/+30% Gold"
        _: return ""

# New
func _get_effect_text(id: String) -> String:
    match id:
        "maxhp": return "+1/+2/+3/+5 HP"
        "speed": return "+5%/+10%/+15%/+20% Speed"
        "pickup": return "+5/+10/+15/+20 Pickup Range"
        "expbonus": return "+5%/+10%/+15%/+20% EXP"
        "weapondmg": return "+3%/+6%/+10%/+15% Weapon DMG"
        "gold": return "+10%/+20%/+30%/+40% Gold"
        _: return ""
```

### 5.4 Achievement adjustment

The `shop_max_all` achievement (line 327) checks if all upgrades are at max level. Since `max_level` changes from 3 to 4, this achievement will now require Tier 4 on all upgrades. This is the intended behavior -- the achievement should reflect full completion of the new shop.

The `shop_single_max` achievement (line 321) will now trigger at level 4 instead of level 3. Players who already have level 3 on an upgrade will not lose their achievement, but the "true max" is now level 4.

**No code changes needed for achievements** -- they already compare against `max_level`, which will be updated in SHOP_UPGRADES.

### 5.5 Save compatibility

Existing saves with shop_upgrades at level 3 will continue to work. The `get_upgrade_cost()` function returns `costs[level]` where level is the current level. If a player has level 3 and `costs` now has a fourth element at index 3, the cost will be correctly returned as the T4 cost.

**No migration needed** -- the ConfigFile save format is `shop/<id> = <level>`. Level 3 is still valid. Level 4 is the new max.

---

## 6. Balance Impact Summary

### 6.1 Power Progression Over Runs

| Run # | Soul Fragments Available | Likely Upgrades | Power Level |
|---|---|---|---|
| 1 | 174 | 1-2 T1 upgrades | Baseline |
| 2 | 348 | 2-3 T1 + 1 T2 | +5% |
| 3 | 522 | T1 complete, 1-2 T2 | +10% |
| 4 | 696 | T2 nearly complete | +15% |
| 5 | 875 | T3 starting | +20% |
| 6-7 | 1223 | T3 progressing | +25% |
| 8 | 1392 | T3 complete, T4 starting | +30% |
| 9-10 | 1740 | T4 progressing | +35% |
| 11 | 1914 | T4 complete | **+40%** |

This creates a much more satisfying progression curve. Each run feels like a meaningful step forward, rather than the current cliff (all T3 by run 5, then nothing).

### 6.2 Interaction with Weapon Mastery (v1.0.2)

The shop T4 and weapon mastery system are designed to be complementary:

- **Shop upgrades**: Broad, passive bonuses that apply to all weapons and all runs
- **Weapon mastery**: Narrow, active bonuses that apply to specific weapons

A player with T4 shop + Master-tier boomerang mastery would have:
- Weapon DMG: 1.15 (shop) * 1.06 (mastery) = 1.22x
- HP: +5 (shop)
- Speed: +20% (shop)
- EXP: +20% (shop)
- Gold: +40% (shop)

This is a ~22% damage increase from permanent upgrades, which is substantial but not overwhelming. The player still needs skill to beat Hard mode.

---

## 7. Decision Record

| Decision | Why |
|---|---|
| Add T4 to all 6 upgrades (not selective) | Uniform T4 keeps the shop feeling complete. Selective T4 would make some upgrades feel "abandoned." |
| Cost = 2x T3 for all upgrades | Simple, predictable cost curve. Players can estimate T4 cost from T3. |
| HP T4 = +5 (not +4) | Creates a "breakthrough" feel at T4. +4 would be boringly linear. |
| Linear progression for speed/pickup/exp/gold | These stats have linear value perception (each +5% feels the same). |
| Accelerating progression for weapondmg (+3/+4/+5) | Damage is the most impactful stat. Higher T4 cost and effect makes it the "premium" upgrade. |
| max_level changes to 4 (not adding new upgrade IDs) | Extends existing structure rather than adding new entries. Simpler implementation, no save migration. |

**Alternative considered and rejected**: Add 4 new upgrade types (e.g., "crit bonus", "dash cooldown", "shield", "combo bonus") instead of Tier 4. Rejected because: (a) new upgrade types require new getter functions, new UI rows, new balance analysis; (b) 6 upgrades x 4 tiers is already 24 purchase decisions, which is plenty for a demo-scale game; (c) new types would need new art assets for icons.

---

## 8. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| T4 makes Normal too easy | Low | Low | Normal is already "easy" after 5 runs. T4 extends the grind for completionists, not difficulty-seekers. |
| Gold economy inflation from T4 gold bonus | Medium | Medium | At T4 gold (+40%), soul fragment income increases by ~40%, accelerating later T4 purchases. This is a mild positive feedback loop, but self-limiting (shop maxes eventually). |
| Save file incompatibility | Very Low | Medium | Level 3 saves work unchanged. Level 4 is additive. |
| Achievement "shop_max_all" becomes too hard | Low | Low | 10 runs is achievable within a week of casual play. Achievement reward (300 SF) partially offsets the cost. |

---

## 9. Success Criteria

1. All existing tests pass after SHOP_UPGRADES change
2. Total shop cost increases from 875 to 1875 (+114%)
3. Runs to max shop increases from ~5 to ~10 (Normal mode)
4. Each T4 effect is noticeable but not dominant (< 50% increase over T3)
5. Save compatibility preserved (level 3 saves load correctly)
6. shop_max_all achievement triggers at new max_level = 4
