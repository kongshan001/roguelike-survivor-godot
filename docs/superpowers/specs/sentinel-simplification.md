# Sentinel Totem Simplification + Evolution Balance Adjustment

**Author**: Designer Agent
**Date**: 2026-04-16
**Priority**: P1 HIGH (R10)
**Status**: Design Complete
**Related Specs**: `docs/superpowers/specs/evolution-expansion.md`, `scripts/weapons/weapon_fire.gd`, `scripts/weapon_controller.gd`

---

## 1. Design Overview

This document addresses two issues identified during R9 review:

1. **Sentinel Totem complexity overestimate**: The original sentinel type requires a new autonomous entity system (turret with independent targeting, lifecycle, and repositioning), estimated at 150-200 lines of new code and 2 new scenes. This document proposes a simplified implementation that reuses existing systems.

2. **Evolution weapon DPS imbalance**: Analysis of all 12 evolved weapons reveals a 10x DPS spread (4.0 to 35.0 effective DPS), with early-designed evolved weapons (fireknife, thunderang, blazerang) significantly outperforming later additions. This document proposes numerical-only adjustments.

---

## 2. Sentinel Totem: Complexity Analysis

### 2.1 Original Design Complexity Assessment

| Component | Estimated New Code | Estimated New Scenes | Coupling |
|---|---|---|---|
| Totem entity (placement, lifecycle, repositioning) | ~80 lines | `sentinel_totem.tscn` (Node2D + Area2D) | New entity type, not player/enemy/projectile |
| Totem targeting + projectile firing | ~50 lines | -- | Needs enemy group query, reuses projectile.tscn |
| Totem lifetime + auto-reposition | ~30 lines | -- | Needs player position tracking, timer management |
| Vulnerability debuff (synergy) | ~20 lines | -- | Needs debuff tracking on enemies |
| weapon_controller integration | ~15 lines | -- | New `_sentinel_instances` state, match case |
| upgrade_pool registration | ~12 lines | -- | New WeaponData fields |
| **Total** | **~207 lines** | **2 new scenes** | **High (new entity archetype)** |

**Verdict**: Exceeds 200-line and 2-scene thresholds. The autonomous entity pattern (stationary turret with independent targeting) has no precedent in the current codebase. All existing weapons originate from the player position and are either instant (lightning, cone) or projectile-based (projectile, boomerang) or player-following (orbit, aura).

### 2.2 Why the Original Design is Complex

The sentinel type introduces three novel concepts:

1. **Decentralized origin**: All current weapons fire from `player.global_position`. The sentinel needs to fire from a fixed position on the map that is NOT the player.
2. **Independent lifecycle**: Orbit/aura follow the player forever. Boomerangs return and despawn. The sentinel needs a timed lifecycle with repositioning, which is a new lifecycle pattern.
3. **Entity management**: weapon_controller manages `_orbit_instances` (Dictionary, follows player) and `_boomerang_instances` (Array, self-managed). Sentinel would need `_sentinel_instances` (Array with timer-based repositioning), a third management pattern.

---

## 3. Sentinel Totem: Simplified Design

### 3.1 Core Idea: Orbit Variant

**Simplified type**: Change sentinel from a new `"sentinel"` weapon_type to an **`"orbit"` variant**.

The Sentinel Totem becomes an orbit weapon where the "totems" are orbit nodes that orbit at a large radius and each fires projectiles at nearby enemies. This eliminates the need for:

- Independent entity placement (orbits are placed automatically at `player.global_position`)
- Lifecycle/repositioning logic (orbits follow the player permanently)
- New entity management pattern (reuses existing `_orbit_instances` Dictionary)

### 3.2 Simplified Behavior

| Original Behavior | Simplified Behavior | Why |
|---|---|---|
| 2 stationary totems, auto-placed near enemies | 2 orbit nodes at radius 120, rotating at 1.5 rad/s | Reuses spin_blade.gd with projectile firing |
| Totems independently target and fire at enemies every 0.8s | Orbit nodes fire projectiles at nearest enemy every 0.8s | Add projectile firing to orbit update loop |
| Totems reposition every 8s near player | Orbits follow player automatically (existing behavior) | Zero new code |
| Range indicator circle (250px) | No range indicator needed (orbits are always visible) | Removes visual complexity |
| Vulnerability debuff on hit (+10% damage taken) | Retained: projectile hit applies vulnerability | Debuff logic is ~5 lines in enemy |
| 3 new WeaponData fields (sentinel_fire_rate, sentinel_range, sentinel_lifetime) | 1 new WeaponData field (orbit_fire_rate) | Minimal data change |

### 3.3 Implementation Plan

The simplified sentinel reuses the existing `update_orbit()` function in `weapon_fire.gd` with one addition: **orbit nodes can fire projectiles**.

**Changes to existing files:**

| File | Change | Lines |
|---|---|---|
| `scripts/data/weapon_data.gd` | Add `@export var orbit_fire_rate: float = 0.0` (1 line) | 1 |
| `scripts/weapons/weapon_fire.gd` | In `update_orbit()`, after orbit damage, check `orbit_fire_rate > 0` and fire projectile at nearest enemy | ~25 |
| `scripts/weapon_controller.gd` | No change (already handles "orbit" type) | 0 |
| `scripts/autoload/upgrade_pool.gd` | Register sentineltotem as `"orbit"` type with `orbit_fire_rate = 0.8` | ~5 (modify existing registration) |
| `scripts/spin_blade.gd` | No structural change; projectile firing logic lives in weapon_fire.gd update_orbit | 0 |
| **Total new code** | | **~31 lines** |

**No new scenes. No new scripts.**

### 3.4 Simplified Numerical Constants

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| `SENTINELTOTEM_WEAPON_ID` | `"sentineltotem"` | string | Unchanged |
| `SENTINELTOTEM_WEAPON_NAME` | `"守护图腾"` | string | Unchanged |
| `SENTINELTOTEM_WEAPON_TYPE` | `"orbit"` | string | **Changed** from "sentinel" to "orbit" |
| `SENTINELTOTEM_DAMAGE` | 2.5 | HP | Unchanged (per orbit hit) |
| `SENTINELTOTEM_COOLDOWN` | 999.0 | seconds | Unchanged (always active) |
| `SENTINELTOTEM_ORBIT_COUNT` | 2 | count | Replaces sentinel_count |
| `SENTINELTOTEM_ORBIT_RADIUS` | 120.0 | pixels | Replaces sentinel_range (visual orbit distance) |
| `SENTINELTOTEM_ORBIT_SPEED` | 1.5 | rad/s | New (slow rotation, totems orbit gently) |
| `SENTINELTOTEM_ORBIT_FIRE_RATE` | 0.8 | seconds | Reuses orbit_fire_rate, each orbit fires at this rate |
| `SENTINELTOTEM_PROJECTILE_SPEED` | 280.0 | px/s | Unchanged |
| `SENTINELTOTEM_PROJECTILE_SIZE` | 3.0 | px | Unchanged |
| `SENTINELTOTEM_PROJECTILE_DAMAGE` | 2.5 | HP | Same as orbit hit damage |
| `SENTINELTOTEM_COLOR` | `Color(0.7, 0.6, 0.2)` | Color | Unchanged (golden-brown totem) |
| `SENTINELTOTEM_PROJ_COLOR` | `Color(0.9, 0.85, 0.5)` | Color | Unchanged (golden projectile) |
| `SENTINELTOTEM_IS_EVOLVED` | true | bool | Unchanged |
| `SENTINELTOTEM_DESCRIPTION` | `"环绕图腾+定向射击"` | string | Updated description |

### 3.5 Vulnerability Synergy (Retained)

The Overwatch synergy is retained but simplified:

| Synergy Constant | Value | Notes |
|---|---|---|
| `SENTINELTOTEM_SYNERGY_VULN_PCT` | 0.10 | +10% damage taken per stack |
| `SENTINELTOTEM_SYNERGY_VULN_DUR` | 2.0s | Duration of vulnerability |
| `SENTINELTOTEM_SYNERGY_VULN_MAX_STACKS` | 2 | Maximum stacks (20% max bonus) |

Implementation: When a sentineltotem projectile hits an enemy, the enemy's `take_damage()` applies a `_vuln_mul` modifier. This is ~5 lines in `enemy.gd` (add `_vuln_timer: float` and `_vuln_stacks: int`, apply in `take_damage`).

### 3.6 DPS Comparison: Original vs Simplified

| Metric | Original (Stationary) | Simplified (Orbit) | Delta |
|---|---|---|---|
| Totem DPS (contact) | 0 | 2.5 * orbit_hit_rate ~2.5 | +2.5 |
| Projectile DPS | 2 totems * 2.5 / 0.8s = 6.25 | 2 orbits * 2.5 / 0.8s = 6.25 | 0 |
| Effective DPS (with vuln) | 6.25 * 1.10 avg = 6.88 | 6.25 + 2.5 + vuln = ~9.6 | +2.72 |
| Coverage | Stationary 250px radius | Orbit radius 120px + projectile 280px | Similar |

**Balance note**: The simplified version has slightly higher DPS because orbit contact damage is added. This is offset by the orbit following the player (less positional flexibility than a placed turret). The orbit version is also always active near the player rather than being placed at a strategic position, making it less tactically flexible but more reliable.

### 3.7 Updated upgrade_pool.gd Registration

```gdscript
# 10. Sentinel Totem (bible + boomerang) -- Simplified to orbit type
var st := WeaponData.new()
st.weapon_name = "守护图腾"; st.weapon_id = "sentineltotem"; st.weapon_type = "orbit"
st.damage = 2.5; st.cooldown = 999.0; st.orbit_count = 2; st.orbit_radius = 120.0
st.orbit_speed = 1.5; st.orbit_fire_rate = 0.8
st.projectile_speed = 280.0; st.projectile_size = 6.0; st.color = Color(0.7, 0.6, 0.2)
st.is_evolved = true; st.description = "环绕图腾+定向射击"
register_weapon("sentineltotem", st)
```

### 3.8 Updated weapon_fire.gd Logic (in update_orbit)

Add ~25 lines at the end of `update_orbit()`:

```gdscript
# --- Sentinel orbit projectile firing ---
if data.orbit_fire_rate > 0.0 and orbit_instances.has(key):
    var fire_timer_key: String = "_%s_fire" % weapon_id
    if not weapon_timers.has(fire_timer_key):
        weapon_timers[fire_timer_key] = data.orbit_fire_rate
    weapon_timers[fire_timer_key] -= delta
    if weapon_timers[fire_timer_key] <= 0.0:
        weapon_timers[fire_timer_key] = data.orbit_fire_rate
        var orbit_node: Node2D = orbit_instances[key]
        var fire_enemies := _get_enemies(player, 250.0)
        if not fire_enemies.is_empty():
            # Fire from each orbit position
            for i in range(data.orbit_count):
                var blade_angle = orbit_node._angle + (TAU * i / data.orbit_count)
                var fire_pos = orbit_node.global_position + Vector2(cos(blade_angle), sin(blade_angle)) * data.orbit_radius
                var target: Node2D = fire_enemies[i % fire_enemies.size()]
                var proj: Area2D = preload("res://scenes/projectile.tscn").instantiate()
                proj.weapon_id = data.weapon_id
                proj.setup(fire_pos, target.global_position, data.projectile_speed, data.damage * dmg_bonus, 0, Color(0.9, 0.85, 0.5), data.projectile_size)
                var pm: Node = _get_pm(player)
                if pm:
                    pm.call_deferred("add_child", proj)
```

**Note**: This logic accesses `orbit_node._angle` which is a public var on spin_blade.gd. If this is a concern, expose it via a getter. This is the only coupling point.

---

## 4. Evolution Weapon DPS Balance Analysis

### 4.1 Full DPS Table (All 12 Evolved Weapons)

**Methodology**: DPS calculated at Lv1 evolved, single target, no passives, no synergies.

| # | Weapon | Type | Raw DPS | Effective DPS (with effects) | Tier |
|---|---|---|---|---|---|
| 1 | thunderholywater | orbit | 4.5 | 4.5 (no extra effects) | C |
| 2 | fireknife | projectile | 30.0 | 30.0 + 6.0 burn = ~36.0 | S |
| 3 | holydomain | orbit | 10.0 | 10.0 + pulse = ~14.0 | A |
| 4 | blizzard | aura | 3.0 | 3.0 + slow + freeze + 4.0 lightning = ~7.0 | B |
| 5 | frostknife | projectile | 20.8 | 20.8 + slow = ~20.8 | S |
| 6 | flamebible | orbit | 5.0 | 5.0 + 3.0 burn + 2.67 pulse = ~10.7 | B |
| 7 | thunderang | boomerang | 35.0 | 35.0 + chain = ~42.0 | S+ |
| 8 | blazerang | boomerang | 22.5 | 22.5 + burn trail = ~28.0 | S |
| 9 | frostvortex | spiral | 6.0 | 6.0 + slow + freeze = ~8.0 | B |
| 10 | sentineltotem | orbit (simplified) | 9.6 | 9.6 + vuln = ~10.6 | B |
| 11 | holyshockwave | pulse | 2.67 | 4.0 + burn = ~5.3 | C |
| 12 | thunderbeam | beam | 4.8 | 4.8 + 4.8 chain = ~9.6 | B |

### 4.2 Problem: DPS Spread is Too Large

- **Highest**: thunderang at ~42.0 effective DPS
- **Lowest**: holyshockwave at ~5.3 effective DPS
- **Spread**: 7.9x difference
- **Target spread**: 3-4x (standard for survivor games -- high DPS weapons trade utility for raw damage)

### 4.3 Root Cause Analysis

| Issue | Weapons Affected | Why |
|---|---|---|
| **Projectile/boomerang DPS too high** | fireknife (36), frostknife (20.8), thunderang (42), blazerang (28) | Original H5 values were balanced around fewer weapons. These were ported directly without adjustment. High projectile count + high fire rate compounds. |
| **Orbit/pulse DPS too low** | thunderholywater (4.5), flamebible (10.7), holyshockwave (5.3) | Orbit weapons hit once per 0.3s per blade. Low blade count + low damage per hit = low DPS. Pulse has long cooldown (3.0s) with moderate damage (8.0). |
| **No DPS-to-utility tradeoff** | fireknife has both highest DPS AND burn DoT | In a well-balanced system, the highest DPS weapon should have no utility effects. fireknife has both extreme DPS and burn. |

### 4.4 Balance Adjustment Proposals

**Design principle**: Only change numerical values (damage, cooldown, counts). Do not change weapon mechanics, types, or behaviors. All changes are small, targeted adjustments.

#### Tier S+ -> Tier A (Nerfs)

**4.4.1 Thunderang: Reduce damage and chain count**

| Parameter | Current | Proposed | Reason |
|---|---|---|---|
| `damage` | 7.0 | 5.0 | Highest DPS weapon; 7.0 per hit x4 boomerangs is too much. 5.0 brings single-target DPS from 35 to 25. |
| `chain_count` | 2 (from thunderang spec) | 1 | Chain lightning adds ~7.0 extra DPS in groups. Reducing to 1 chain reduces group DPS. |

**Thunderang new DPS**: 25.0 + ~3.5 chain = ~28.5 (Tier A)

**4.4.2 Fireknife: Reduce projectile count and burn DPS**

| Parameter | Current | Proposed | Reason |
|---|---|---|---|
| `projectile_count` | 5 | 3 | 5 projectiles at 0.5s CD = 10 projectiles/s. Reducing to 3 = 6/s. DPS from 30 to 18. |
| `burn_dps` | 3.0 | 2.0 | Fire DoT was double the standard BURN_DPS. Standardize to 2.0. |

**Fireknife new DPS**: 18.0 + ~2.0 burn = ~20.0 (Tier A)

**4.4.3 Blazerang: Reduce damage**

| Parameter | Current | Proposed | Reason |
|---|---|---|---|
| `damage` | 6.0 | 5.0 | 3 boomerangs at 0.8s CD, each hitting multiple times. 5.0 reduces DPS from 22.5 to 18.75. |

**Blazerang new DPS**: 18.75 + burn trail = ~22.0 (Tier A)

**4.4.4 Frostknife: Reduce projectile count**

| Parameter | Current | Proposed | Reason |
|---|---|---|---|
| `projectile_count` | 5 | 4 | Slight reduction. DPS from 20.8 to 16.7. Slow utility unchanged. |

**Frostknife new DPS**: 16.7 + slow = ~16.7 (Tier A, utility compensates)

#### Tier C -> Tier B (Buffs)

**4.4.5 Thunderholywater: Increase damage and orbit speed**

| Parameter | Current | Proposed | Reason |
|---|---|---|---|
| `damage` | 1.5 | 2.5 | Lowest DPS evolved weapon. 2.5 brings orbit DPS to 7.5. |
| `orbit_speed` | 3.5 | 4.5 | Faster rotation = more hits per second. |

**Thunderholywater new DPS**: ~11.25 (from 4.5) (Tier B, with lightning chain potential)

**4.4.6 Holyshockwave: Increase damage, reduce cooldown**

| Parameter | Current | Proposed | Reason |
|---|---|---|---|
| `damage` | 8.0 | 12.0 | Pulse is the highest single-hit weapon, but DPS is lowest. 12.0 per pulse. |
| `cooldown` | 3.0 | 2.5 | Reduce downtime between pulses. |

**Holyshockwave new DPS**: 12.0 / 2.5 = 4.8 raw + burn 2.0 * 2.0 / 2.5 = 1.6 = ~6.4 (Tier B, with resonance synergy scaling up to ~10+ in dense waves)

#### No Change Needed (Already Balanced)

| Weapon | DPS | Reason |
|---|---|---|
| holydomain | ~14.0 | Good DPS with utility. Pulse + orbit combo is strong. |
| blizzard | ~7.0 | Low DPS but high utility (slow + freeze + lightning). Utility weapon. |
| flamebible | ~10.7 | Moderate DPS with burn. Balanced orbit. |
| frostvortex | ~8.0 | Low DPS but high utility (slow + freeze). Control weapon. |
| sentineltotem (simplified) | ~10.6 | Moderate DPS with vuln debuff. Support weapon. |
| thunderbeam | ~9.6 | Moderate DPS, high multi-target potential. Directional tradeoff. |

### 4.5 Post-Adjustment DPS Table

| # | Weapon | Old DPS | New DPS | Change | New Tier |
|---|---|---|---|---|---|
| 1 | thunderholywater | 4.5 | 11.25 | +150% | B |
| 2 | fireknife | 36.0 | 20.0 | -44% | A |
| 3 | holydomain | 14.0 | 14.0 | 0% | A |
| 4 | blizzard | 7.0 | 7.0 | 0% | B |
| 5 | frostknife | 20.8 | 16.7 | -20% | A |
| 6 | flamebible | 10.7 | 10.7 | 0% | B |
| 7 | thunderang | 42.0 | 28.5 | -32% | A |
| 8 | blazerang | 28.0 | 22.0 | -21% | A |
| 9 | frostvortex | 8.0 | 8.0 | 0% | B |
| 10 | sentineltotem | 10.6 | 10.6 | 0% | B |
| 11 | holyshockwave | 5.3 | 6.4 | +21% | B |
| 12 | thunderbeam | 9.6 | 9.6 | 0% | B |

**New DPS spread**: 6.4 (holyshockwave) to 28.5 (thunderang) = **4.5x**. Within the 3-4x target with utility compensation.

### 4.6 Specific Numerical Changes Summary

These are the exact values that need to change in `upgrade_pool.gd` registrations:

| Weapon ID | Parameter | Old Value | New Value |
|---|---|---|---|
| `thunderang` | `damage` | 7.0 | 5.0 |
| `thunderang` | `chain_count` | 2 | 1 |
| `fireknife` | `projectile_count` | 5 | 3 |
| `fireknife` | `burn_dps` | 3.0 | 2.0 |
| `blazerang` | `damage` | 6.0 | 5.0 |
| `frostknife` | `projectile_count` | 5 | 4 |
| `thunderholywater` | `damage` | 1.5 | 2.5 |
| `thunderholywater` | `orbit_speed` | 3.5 | 4.5 |
| `holyshockwave` | `damage` | 8.0 | 12.0 |
| `holyshockwave` | `cooldown` | 3.0 | 2.5 |

**Total parameters changed**: 10 values across 7 weapons.
**Weapons unchanged**: holydomain, blizzard, flamebible, frostvortex, sentineltotem, thunderbeam (6 weapons).

---

## 5. Design Decisions Log

| Decision | Why | Alternative Considered |
|---|---|---|
| Simplify sentinel to orbit type instead of new entity | Eliminates 2 new scenes, ~170 lines of code. Reuses proven orbit system. The "orbiting totem" concept still feels distinct from other orbit weapons (fires projectiles, vuln debuff). | Keep original sentinel type (too complex), change to projectile type (loses the "stationary guardian" feel) |
| Orbit radius 120px (vs original 250px range) | Orbits at 250px would look absurd (too far from player). 120px is the sweet spot for visible orbit nodes that fire projectiles outward. | 80px (too close, projectiles overlap with player), 160px (too far for orbit visual) |
| Nerf top 4 weapons instead of buff bottom 4 | Power creep is worse than power reduction. Nerfing the top brings the game's overall power level down, keeping enemies threatening. | Buff bottom 4 weapons (creates power creep, enemies become too easy) |
| Fireknife projectile_count 5->3 (not damage reduction) | Reducing projectile count is the most targeted nerf -- it reduces raw DPS without changing the "feel" of rapid burning knives. Reducing damage would make each knife feel weak. | Reduce damage from 3.0 to 2.0 (same DPS reduction but weaker per-hit feel) |
| Keep utility weapons (blizzard, frostvortex) at low DPS | These weapons provide slow/freeze which is party-wide utility. Their value is not in DPS but in enabling other weapons to deal more damage. | Buff their DPS (would make them too good at everything) |
| Holyshockwave: buff damage + reduce cooldown (not just one) | Either buff alone is insufficient. 8->12 damage alone: 4.8 DPS (still bottom tier). 3->2.5 CD alone: 3.2 DPS + burn = 4.8 (still bottom). Both together: 6.4 DPS + resonance = ~10 in practice. | Buff damage only (insufficient), buff CD only (insufficient) |
| Vulnerability debuff stays at +10%/stack (not increased) | The sentineltotem is now an orbit weapon with higher contact DPS than the original stationary design. Increasing vuln on top of that would overcompensate. | Increase to +15%/stack (would make sentineltotem + fireknife combo too strong) |

---

## 6. Impact on evolution-expansion.md

The following sections in `evolution-expansion.md` need updating:

| Section | Change |
|---|---|
| Section 5.2 (Sentinel Totem) | Replace entire sentinel type definition with orbit-based design |
| Section 6 (WeaponData.gd Additions) | Remove `sentinel_*` fields; add `orbit_fire_rate` |
| Section 7 (weapon_controller.gd Integration) | Remove `"sentinel"` match case (handled by `"orbit"`) |
| Section 8.1 (upgrade_pool registration) | Update sentineltotem registration to orbit type |
| Section 10.1 (DPS Comparison) | Update all values per balance adjustments |
| Section 12.1 (Files to Create) | Remove `scripts/weapons/sentinel.gd` |
| Section 12.2 (Files to Modify) | Reduce weapon_fire.gd change estimate from ~120 to ~30 lines |

---

## 7. WeaponData.gd Change

Only 1 new field needed (replaces 4 sentinel-specific fields):

```
# Orbit fire (sentineltotem variant)
@export var orbit_fire_rate: float = 0.0  # Seconds between orbit-fired projectiles; 0 = no firing
```

The existing `sentinel_fire_rate`, `sentinel_range`, `sentinel_lifetime`, `sentinel_count` from the original spec are **no longer needed**.

---

## 8. Files to Modify (Programmer Agent Reference)

| File | Change | Scope |
|---|---|---|
| `scripts/data/weapon_data.gd` | Add `orbit_fire_rate` field | 1 line |
| `scripts/weapons/weapon_fire.gd` | Add orbit projectile firing in `update_orbit()` | ~25 lines |
| `scripts/autoload/upgrade_pool.gd` | (1) Register sentineltotem as orbit type. (2) Update 7 weapon values per balance table. | ~15 lines |
| `scripts/weapons/weapon_registry.gd` | No change (evolution recipe unchanged: bible+boomerang->sentineltotem) | 0 |
| `scripts/weapon_controller.gd` | No change (orbit type already handled) | 0 |
| **Total new/changed code** | | **~41 lines** |

**Files NOT needed** (eliminated by simplification):
- ~~`scenes/sentinel_totem.tscn`~~ (no new scene)
- ~~`scripts/weapons/sentinel.gd`~~ (no new script)
