# Firebomb Weapon Design Spec

**Author**: Designer Agent
**Date**: 2026-04-18
**Round**: R35
**Status**: Design Spec -- Awaiting Implementation
**Priority**: P1 HIGH (v1.2.0 Phase B)
**Parent Spec**: `docs/superpowers/specs/necromancer-design.md` Sections 4-4.6
**Prerequisite**: Audio system Phase A should be evaluated first; this spec assumes Phase A is complete or in progress

---

## 1. Design Overview

The Firebomb is the 8th base weapon, introducing the "throwing" archetype. It throws an incendiary flask in a parabolic arc toward the nearest enemy, creating a persistent fire pool at the landing point. This fills the "point AoE" niche -- a fixed damage zone that enemies walk through -- which does not exist in the current weapon roster. Unlike frostaura (follows player) or firestaff (directional cone), the firebomb creates a remote hazard that enables area denial gameplay.

**Weapon ecosystem positioning**:

| Weapon | Fire Pattern | Target Selection | AoE Shape | Persistence |
|--------|-------------|-----------------|-----------|-------------|
| knife | Linear projectile | Nearest enemy | Single target | Instant |
| holywater | Orbit circles | Self-centered | Circular orbit | Persistent |
| lightning | Random strike | Random in range | Point + chain | Instant |
| bible | Expanding orbit | Self-centered | Circular orbit | Persistent |
| firestaff | Forward cone | Aim direction | 80-degree cone | Instant + burn |
| frostaura | Persistent aura | Self-centered | Circle (80px) | Persistent |
| boomerang | Arc + return | Nearest enemy | Path + contact | Temporary |
| **firebomb** | **Parabolic throw** | **Nearest enemy** | **Circle at landing** | **2s fire pool** |

---

## 2. Pre-requisite Research

### 2.1 Genre Analysis Summary

Research file: `docs/superpowers/specs/brainstorm/necromancer-firebomb-brainstorm.md`

**Key findings**: Throwing + persistent pool is underused in the genre. VS has Axe (arc, no pool) and Hellfire (burn zone, evolve-only). Brotato has instant grenades. H5 has no throwing weapon. The firebomb combines parabolic throw with persistent DoT pool, filling an untapped niche. Area denial is a proven mechanic (VS Garlic/Soul Eater) that rewards positioning.

Three concepts were evaluated in R33 brainstorm: (A) Thrown Flask (parabolic + pool), (B) Molotov Chain (bouncing), (C) Napalm Stream (continuous spray). Concept A was selected because it is the only option introducing a genuinely new weapon behavior. B reduces player agency; C conflicts with auto-attack philosophy.

### 2.2 DPS Baseline (from R18 Balance Analysis)

| Weapon | Lv1 DPS | Lv3 DPS | Type |
|--------|---------|---------|------|
| Knife | 2.86 | 6.00 | Single-target |
| HolyWater | 1.50 | 6.00 | Orbit |
| Lightning | 2.50 | 7.50 | Random |
| Bible | 1.00 | 6.00 | Orbit |
| FireStaff | 2.00 | 6.67 | Cone + burn |
| FrostAura | 1.00 | 2.00 | Aura (CC) |
| Boomerang | 1.67 | 7.50 | Boomerang |

**Target**: Lv1 ~4.8, Lv3 ~19.0. Multi-target premium via pool area coverage.

---

## 3. Base Weapon Constants

### 3.1 Core Attributes

| Attribute | Value | Unit | Notes |
|-----------|-------|------|-------|
| weapon_name | "火焰瓶" | string | Display name |
| weapon_id | "firebomb" | string | |
| weapon_type | "throwing" | string | New type, to be added to weapon_data.gd |
| damage | 3.0 | HP | Per tick in fire pool |
| cooldown | 2.5 | seconds | Time between throws |
| aoe_radius | 50.0 | pixels | Fire pool radius at landing point |
| projectile_speed | 250.0 | px/s | Horizontal travel speed of thrown flask |
| projectile_range | 300.0 | pixels | Max throw distance |
| description | "抛物线投掷，落点持续灼烧" | string | |
| color | Color(0.90, 0.40, 0.10) | Color | Orange-red (#E6661A) |
| projectile_size | 6.0 | pixels | Flask visual size |

### 3.2 Throwing-Specific Constants

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| FIREBOMB_THROW_HEIGHT | 80.0 | pixels | Peak of parabolic arc above start |
| FIREBOMB_POOL_DURATION | 2.0 | seconds | Fire pool persists for 2 seconds |
| FIREBOMB_POOL_TICK_INTERVAL | 0.5 | seconds | Damage ticks every 0.5s |
| FIREBOMB_POOL_DAMAGE | 3.0 | HP/tick | Same as weapon damage |
| FIREBOMB_BURN_DPS | 1.5 | DPS | Burn effect after leaving pool |
| FIREBOMB_BURN_DURATION | 1.5 | seconds | Shorter than firestaff (2.0s) |
| FIREBOMB_MAX_POOLS | 3 | count | Maximum simultaneous pools (performance cap) |

---

## 4. Level Scaling

### 4.1 Per-Level Breakdown

| Level | Flasks | Pool Radius | Cooldown | Pool Duration | DPS (single target) | Notes |
|-------|--------|-------------|----------|---------------|---------------------|-------|
| Lv1 | 1 | 50px | 2.5s | 2.0s | ~6.0 | 3.0 x 4 ticks / 2.5s CD |
| Lv2 | 2 (spread 40px) | 60px | 2.0s | 2.0s | ~12.0 | Double coverage, faster |
| Lv3 | 2 | 70px | 1.5s | 2.0s + 1.5s ground | ~18.0 (+ burn) | Burning ground lingers |

### 4.2 Lv3 Quality Change: Burning Ground

When the fire pool expires at Lv3, the area becomes "burning ground" for an additional 1.5 seconds. Enemies on burning ground take 1.5 DPS and are slowed by 20%.

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| FIREBOMB_LV3_GROUND_DURATION | 1.5 | seconds | Burning ground lingers after pool |
| FIREBOMB_LV3_GROUND_DPS | 1.5 | DPS | Lower than pool DPS |
| FIREBOMB_LV3_GROUND_SLOW | 0.20 | fraction | 20% slow on burning ground |

**Why burning ground instead of other Lv3 effects**:
- Fire staff Lv3 already has Searing Burst (death explosion). Burning ground is a different mechanic (zone persistence, not kill-triggered).
- The ground effect creates overlapping zones when multiple pools expire, rewarding players who pre-position throws.
- 20% slow on burning ground synergizes with frostaura's stronger slow, creating a "fire + ice" CC combo.

### 4.3 DPS Balance Analysis

**Single target (enemy stands in pool entire duration)**:
- Lv1: 3.0 x 4 ticks / 2.5s = 4.8 DPS (below mid-tier)
- Lv2: 3.0 x 4 ticks x 2 flasks / 2.0s = 12.0 DPS (competitive)
- Lv3: 3.0 x 4 ticks x 2 flasks / 1.5s + 1.5 x 3 ticks x 2 / 1.5s = 16.0 + 3.0 = 19.0 DPS

**Multi-target (3 enemies in 50px pool)**:
- Lv1: 4.8 x 3 = 14.4 effective DPS (strong for Lv1)
- Lv2: 12.0 x 3 = 36.0 effective DPS (strong for Lv2)
- Lv3: 19.0 x 3 = 57.0 effective DPS (very strong for Lv3)

**Comparison with existing weapons**:

| Weapon | Lv1 DPS (single) | Lv3 DPS (single) | Multi-target Premium |
|--------|-------------------|-------------------|---------------------|
| Knife | 2.86 | 6.00 | None (single target) |
| FireStaff | 2.00 | 6.67 | Cone hits 2-3 targets |
| FrostAura | 1.00 | 2.00 | Aura hits all in range |
| **Firebomb** | **4.8** | **19.0** | **3x multiplier in pool** |

**Assessment**: Firebomb's single-target DPS at Lv1 (4.8) is moderate -- below boomerang (1.67 x hit rate) and knife (2.86), but its multi-target potential (3x in dense groups) makes it situationally powerful. At Lv3, 19.0 single-target DPS is the highest of all base weapons, balanced by the requirement that enemies stand in the pool for the full duration.

---

## 5. Evolution: Thunderbomb (thunderbomb)

### 5.1 Evolution Recipe

**firebomb + lightning = thunderbomb**

This recipe is consistent with the H5 evolution pattern where fire-element weapons combine with lightning to create thunder-variant weapons (firestaff + lightning in various recipes, firestaff having multiple fire-themed evolutions).

**weapon_registry.gd addition**:

```gdscript
{"a": "firebomb", "b": "lightning", "result": "thunderbomb"},
```

### 5.2 Thunderbomb Constants

| Attribute | Value | Unit | Notes |
|-----------|-------|------|-------|
| weapon_name | "雷暴瓶" | string | |
| weapon_id | "thunderbomb" | string | |
| weapon_type | "throwing" | string | Same base type |
| damage | 5.0 | HP/tick | 67% increase over base |
| cooldown | 1.2 | seconds | Faster than base Lv3 (1.5s) |
| aoe_radius | 80.0 | pixels | Larger area (vs 70px Lv3) |
| projectile_range | 400.0 | pixels | Longer throw |
| is_evolved | true | bool | |

### 5.3 Thunderbolt Additional Effects

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| THUNDERBOMB_POOL_DURATION | 3.0 | seconds | Longer than base (2.0s) |
| THUNDERBOMB_CHAIN_CHANCE | 0.30 | fraction | 30% per tick to chain |
| THUNDERBOMB_CHAIN_COUNT | 2 | count | Chains to 2 nearby enemies |
| THUNDERBOMB_CHAIN_DAMAGE | 8.0 | HP | Per chain hit |
| THUNDERBOMB_CHAIN_RANGE | 100.0 | pixels | Chain lightning range |
| THUNDERBOMB_POOL_SLOW | 0.40 | fraction | 40% slow replaces burn |
| THUNDERBOMB_FLASK_COUNT | 2 | count | Same as Lv3 |

### 5.4 Thunderbomb DPS Estimate

- Direct pool: 5.0 x 6 ticks / 1.2s CD = 25.0 DPS (single target)
- Chain lightning: 30% x 8.0 x 2 chains x 6 ticks / 1.2s = 24.0 DPS (spread across targets)
- Total single target: ~25.0 DPS
- Total multi-target (3 enemies, chains hit): ~49.0 DPS

**Comparison with evolved weapons** (from R18 balance analysis):

| Rank | Weapon | DPS | Tier |
|------|--------|-----|------|
| 1 | thunderang | 25.0 | A |
| 2 | fireknife | 20.0 | A |
| 2 | flamebible | 20.0 | A |
| 4 | blazerang | 18.75 | A |
| 5 | frostknife | 16.7 | B |
| 6 | blizzard | 14.0 | B |
| -- | **thunderbomb** | **25.0 / 49.0** | **A** |
| 7 | thunderholywater | 11.25 | B |
| 8 | holydomain | 10.0 | B |
| 9 | sentineltotem | 9.4 | C |

**Assessment**: Thunderbomb's single-target DPS (25.0) matches thunderang at rank 1. Multi-target DPS (49.0) is the highest in the game, but requires enemies to be clustered near the pool. Chain lightning originates from the pool (not from enemies), creating a "lightning tower" effect that rewards strategic flask placement. 40% slow replaces burn, differentiating thunderbomb from the base firebomb's burn DOT.

---

## 6. weapon_data.gd New Fields

Add after existing fields in `scripts/data/weapon_data.gd`:

```gdscript
# Throwing (firebomb/thunderbomb)
@export var throw_height: float = 80.0
@export var pool_duration: float = 2.0
@export var pool_tick_interval: float = 0.5
@export var pool_slow_pct: float = 0.0
@export var chain_on_pool: bool = false   # Thunderbolt chain lightning
@export var chain_chance: float = 0.0
@export var chain_count: int = 0
@export var chain_damage: float = 0.0
@export var chain_range: float = 100.0
```

Note: `burn_dps` and `burn_duration` already exist (used by firestaff). Update weapon_type comment to: `"projectile", "orbit", "lightning", "aoe", "cone", "aura", "boomerang", "throwing"`

---

## 7. upgrade_pool.gd Registration

### 7.1 Firebomb Base Weapon

Add to `_register_base_weapons()` after the boomerang entry (line 75):

```gdscript
# 8. Firebomb
var fb := WeaponData.new()
fb.weapon_name = "火焰瓶"; fb.weapon_id = "firebomb"; fb.weapon_type = "throwing"
fb.damage = 3.0; fb.cooldown = 2.5; fb.aoe_radius = 50.0
fb.projectile_speed = 250.0; fb.projectile_range = 300.0
fb.throw_height = 80.0; fb.pool_duration = 2.0; fb.pool_tick_interval = 0.5
fb.burn_dps = 1.5; fb.burn_duration = 1.5
fb.description = "抛物线投掷，落点持续灼烧"
fb.color = Color(0.90, 0.40, 0.10); fb.projectile_size = 6.0
register_weapon("firebomb", fb)
```

### 7.2 Thunderbomb Evolved Weapon

Add to `_register_evolved_weapons()` after the last evolved weapon:

```gdscript
# 13. Thunderbomb (firebomb + lightning)
var tb := WeaponData.new()
tb.weapon_name = "雷暴瓶"; tb.weapon_id = "thunderbomb"; tb.weapon_type = "throwing"
tb.damage = 5.0; tb.cooldown = 1.2; tb.aoe_radius = 80.0
tb.projectile_speed = 300.0; tb.projectile_range = 400.0
tb.throw_height = 80.0; tb.pool_duration = 3.0; tb.pool_tick_interval = 0.5
tb.pool_slow_pct = 0.40
tb.chain_on_pool = true; tb.chain_chance = 0.30
tb.chain_count = 2; tb.chain_damage = 8.0; tb.chain_range = 100.0
tb.is_evolved = true
tb.description = "电火池+链式闪电"
tb.color = Color(0.50, 0.70, 1.00); tb.projectile_size = 8.0
register_weapon("thunderbomb", tb)
```

---

## 8. weapon_registry.gd Addition

Add to `EVOLUTION_RECIPES` array:

```gdscript
{"a": "firebomb", "b": "lightning", "result": "thunderbomb"},
```

This brings the total evolution recipe count from 12 to 13.

---

## 9. Implementation Notes

### 9.1 New Scripts

| Script | Lines | Purpose |
|--------|-------|---------|
| `scripts/weapons/thrown_flask.gd` | ~60 | Parabolic arc projectile (Area2D, moves along arc, creates pool on landing) |
| `scripts/weapons/fire_pool.gd` | ~50 | Persistent AoE zone (Area2D, ticks damage, applies burn/slow, auto-despawns) |

### 9.2 Parabolic Arc Math

The arc is cosmetic. The flask travels toward the target at `projectile_speed` horizontally, with a visual Y-offset peaking at `throw_height`.

**Simplified approach** (recommended): Use a lerp on Y position:
- `t_norm = elapsed / total_time` (0 to 1)
- `y_offset = -throw_height * 4.0 * t_norm * (1.0 - t_norm)` (parabolic peak at midpoint)

**Targeting**: Same as knife -- nearest enemy within `projectile_range` (300px). If none, throw in player's facing direction at max range.

### 9.3 Fire Pool Lifecycle

1. Flask reaches target position -> instantiate fire_pool at landing point
2. Fire pool Area2D monitors overlapping enemies
3. Every `pool_tick_interval` (0.5s), deal `damage` to all enemies in pool
4. Apply burn (`burn_dps`, `burn_duration`) to enemies in pool
5. After `pool_duration` (2.0s), pool expires
6. At Lv3: spawn burning_ground at same position (1.5s, 1.5 DPS, 20% slow)
7. Max simultaneous pools: `FIREBOMB_MAX_POOLS = 3` (oldest pool removed if exceeded)

### 9.4 Thunderbolt Chain Lightning

At each pool tick, if `chain_on_pool = true`, roll `randf() < chain_chance` (30%). If true, find up to `chain_count` (2) enemies within `chain_range` (100px) of pool center, deal `chain_damage` (8.0) to each, and draw lightning visual (reuse `weapon_effects.gd` `create_lightning_effect()`).

---

## 10. Synergy Compatibility

The firebomb interacts with existing synergy systems:

| Synergy | Firebomb Interaction | Notes |
|---------|---------------------|-------|
| firestaff_armor ("熔岩法杖") | Does NOT trigger -- firebomb is not "firestaff" | Intentional isolation |
| firestaff_luckycoin ("炼金烈焰") | Does NOT trigger -- firebomb is not "firestaff" | Intentional isolation |
| magnet_maxhp ("命运齿轮") | Pool tick kills generate gems -> 2% heal chance | Passive synergy, no code change |
| crit_boots ("风之锋刃") | Pool tick CAN crit if player has crit passive -> spawns knife | Uses _last_hit_by system |
| Necromancer kill scaling | Pool tick kills count toward Necromancer passive | Uses _last_hit_by = "firebomb" |

**New synergy opportunities (v1.3.0 consideration)**:

| Potential Synergy | Ingredients | Effect | Priority |
|-------------------|------------|--------|----------|
| firebomb_magnet | firebomb + magnet | Pool attracts XP gems within 30px | P2 |
| firebomb_crit | firebomb + crit | Pool ticks can crit | P2 |
| firebomb_armor | firebomb + armor | Pool radius +20px, burn +1s | P2 |

These are recorded for future planning and should NOT be implemented in v1.2.0.

---

## 11. Mastery Integration

The firebomb must be added to the weapon mastery system (defined in `docs/superpowers/specs/weapon-mastery.md`).

### 11.1 save_manager.gd Changes

**BASE_WEAPONS array** (add "firebomb"):
```gdscript
const BASE_WEAPONS: Array = ["knife", "holywater", "lightning", "bible", "firestaff", "frostaura", "boomerang", "firebomb"]
```

**Evolved parents mapping** (add thunderbomb):
```gdscript
# thunderbomb -> firebomb + lightning
"thunderbomb": ["firebomb", "lightning"]
```

### 11.2 Mastery Progression

Same as other weapons (4 tiers: 50/200/500/1000 kills):

| Tier | Name | Kill Threshold | Damage Bonus |
|------|------|---------------|-------------|
| 0 | Novice | 0 | +0% |
| 1 | Apprentice | 50 | +2% |
| 2 | Adept | 200 | +4% |
| 3 | Expert | 500 | +6% |
| 4 | Master | 1000 | +8% |

Thunderbomb kills count toward both firebomb and lightning mastery.

---

## 12. Achievement Updates

| Achievement | Change | Priority |
|-------------|--------|----------|
| all_evolutions | Add "evo_thunderbomb" part | P1 |
| evo_thunderbomb | New hidden: check for thunderbomb in evolutions array | P1 |
| mastery_all | "firebomb" automatically included via BASE_WEAPONS | P0 |

The `all_evolutions` achievement parts array grows from 12 to 13 entries.

---

## 13. Test Cases

### 13.1 Firebomb Base Weapon Tests (~10 tests)

| Test | Verification | Priority |
|------|-------------|----------|
| test_firebomb_registered | firebomb in upgrade_pool._weapons | P0 |
| test_firebomb_weapon_type | weapon_type = "throwing" | P0 |
| test_firebomb_base_damage | Damage = 3.0/tick | P0 |
| test_firebomb_cooldown | CD = 2.5s | P0 |
| test_firebomb_pool_duration | Pool lasts 2.0s | P1 |
| test_firebomb_pool_radius | Pool radius = 50px | P1 |
| test_firebomb_throw_height | Throw height = 80px | P1 |
| test_firebomb_mastery_in_base_weapons | "firebomb" in BASE_WEAPONS array | P0 |
| test_firebomb_mastery_tracking | Kills tracked in weapon_kills | P1 |
| test_firebomb_pool_max_count | Max 3 simultaneous pools | P2 |

### 13.2 Firebomb Evolution Tests (~5 tests)

| Test | Verification | Priority |
|------|-------------|----------|
| test_thunderbomb_recipe | firebomb + lightning = thunderbomb in EVOLUTION_RECIPES | P0 |
| test_thunderbomb_damage | Damage = 5.0/tick | P0 |
| test_thunderbomb_chain_chance | Chain chance = 0.30 | P1 |
| test_thunderbomb_is_evolved | is_evolved = true | P0 |
| test_thunderbomb_pool_duration | Pool lasts 3.0s | P1 |

### 13.3 Lv3 Quality Change Tests (~5 tests)

| Test | Verification | Priority |
|------|-------------|----------|
| test_firebomb_lv3_burning_ground | Ground persists 1.5s after pool expires | P1 |
| test_firebomb_lv3_ground_dps | Ground deals 1.5 DPS | P1 |
| test_firebomb_lv3_ground_slow | Ground applies 20% slow | P1 |
| test_firebomb_lv3_two_flasks | Lv3 throws 2 flasks | P0 |
| test_firebomb_lv3_pool_radius | Pool radius = 70px | P1 |

---

## 14. Numerical Summary Tables

### 14.1 Firebomb Constants (Complete)

| Constant | Value | Unit | Notes |
|----------|-------|------|-------|
| FIREBOMB_WEAPON_ID | "firebomb" | string | |
| FIREBOMB_WEAPON_TYPE | "throwing" | string | New type |
| FIREBOMB_BASE_DAMAGE | 3.0 | HP/tick | |
| FIREBOMB_COOLDOWN | 2.5 | seconds | |
| FIREBOMB_RADIUS | 50.0 | px | |
| FIREBOMB_SPEED | 250.0 | px/s | |
| FIREBOMB_RANGE | 300.0 | px | |
| FIREBOMB_THROW_HEIGHT | 80.0 | px | |
| FIREBOMB_POOL_DURATION | 2.0 | seconds | |
| FIREBOMB_TICK_INTERVAL | 0.5 | seconds | |
| FIREBOMB_BURN_DPS | 1.5 | DPS | |
| FIREBOMB_BURN_DURATION | 1.5 | seconds | |
| FIREBOMB_MAX_POOLS | 3 | count | |
| FIREBOMB_LV3_GROUND_DURATION | 1.5 | seconds | |
| FIREBOMB_LV3_GROUND_DPS | 1.5 | DPS | |
| FIREBOMB_LV3_GROUND_SLOW | 0.20 | fraction | |

### 14.2 Thunderbomb Constants (Complete)

| Constant | Value | Unit | Notes |
|----------|-------|------|-------|
| THUNDERBOMB_WEAPON_ID | "thunderbomb" | string | |
| THUNDERBOMB_DAMAGE | 5.0 | HP/tick | |
| THUNDERBOMB_COOLDOWN | 1.2 | seconds | |
| THUNDERBOMB_RADIUS | 80.0 | px | |
| THUNDERBOMB_SPEED | 300.0 | px/s | |
| THUNDERBOMB_RANGE | 400.0 | px | |
| THUNDERBOMB_POOL_DURATION | 3.0 | seconds | |
| THUNDERBOMB_CHAIN_CHANCE | 0.30 | fraction | |
| THUNDERBOMB_CHAIN_COUNT | 2 | count | |
| THUNDERBOMB_CHAIN_DAMAGE | 8.0 | HP | |
| THUNDERBOMB_CHAIN_RANGE | 100.0 | px | |
| THUNDERBOMB_POOL_SLOW | 0.40 | fraction | |
| THUNDERBOMB_FLASK_COUNT | 2 | count | |

---

## 15. File Change Budget

| File | Action | Lines | New/Modified |
|------|--------|-------|-------------|
| scripts/data/weapon_data.gd | Add throwing fields | +10 | Modified |
| scripts/autoload/upgrade_pool.gd | Register firebomb + thunderbomb | +20 | Modified |
| scripts/weapons/weapon_registry.gd | Add firebomb+lightning=thunderbomb | +1 | Modified |
| scripts/weapons/thrown_flask.gd | Parabolic arc projectile | ~60 | New |
| scripts/weapons/fire_pool.gd | Persistent AoE zone | ~50 | New |
| scripts/autoload/save_manager.gd | Add firebomb to BASE_WEAPONS + thunderbomb parents | +5 | Modified |
| scripts/weapons/weapon_fire.gd | Add "throwing" match branch | ~15 | Modified |
| scripts/weapon_controller.gd | Add firebomb cooldown handling | ~5 | Modified |
| **Total** | | **~166** | |

---

## 16. Decision Records

| Decision | Why | Alternative Considered |
|----------|-----|----------------------|
| New weapon type "throwing" (not sub-type) | Throwing = one-way parabolic arc + landing AoE pool. Boomerang returns; projectile is linear. Separate types keep code clean | Sub-type of projectile (parabolic arc doesn't fit linear model), reuse boomerang with no-return flag (hacky) |
| Base DPS = 6.0 at Lv1 | Area weapons should have lower per-target DPS than single-target weapons because they hit multiple enemies. 6.0 is moderate -- not too weak to feel useless | 8.0 DPS (competitive with ranged -- wrong for area weapon), 4.0 DPS (too weak) |
| Lv3 quality change = burning ground | Different from firestaff's Searing Burst (kill-triggered explosion). Burning ground is zone persistence, rewarding pre-positioning. 20% slow synergizes with frostaura | Larger pool only (boring), more flasks (too similar to Lv2 scaling) |
| Evolution recipe = firebomb + lightning | Thematically consistent: fire pool + electricity = electric pool. Uses lightning (common evolution ingredient, appears in 4 recipes) | firebomb + firestaff (both fire -- thematically redundant), firebomb + frostaura (fire + ice is not a standard combo) |
| Chain lightning from pool (not from enemies) | Creates a "lightning tower" effect unique among weapons. Pool-centered chains reward strategic flask placement in dense areas | Chain from each enemy (too chaotic), single target burst (boring evolution) |
| Max 3 simultaneous pools | Performance safety. At Lv3 with 2 flasks/throw and 1.5s CD, the player generates ~1.3 pools/second. 3 pools covers ~2.3s of throwing, which is sufficient for combat | Unlimited pools (memory/rendering risk with high CD reduction builds), 5 pools (generous but unnecessary) |
| Thunderbomb 40% slow (replaces burn) | Differentiates from base firebomb (which uses burn). Thunderbomb is electric-themed, slow represents "electric stun" | Keep burn on thunderbomb (no differentiation from base), add freeze (overlaps with frost weapons) |

---

*Spec generated by Designer Agent R35 on 2026-04-18*
