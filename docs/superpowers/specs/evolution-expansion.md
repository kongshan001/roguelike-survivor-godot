# Evolution Expansion Design Spec (4 New Evolutions)

**Author**: Designer Agent
**Date**: 2026-04-16
**Priority**: P1 HIGH (R9)
**Status**: Design Complete
**Related Specs**: `docs/superpowers/specs/phase4-weapon-evolution-design.md`, `scripts/weapons/weapon_registry.gd`, `scripts/autoload/upgrade_pool.gd`

---

## 1. Design Overview

The current evolution system has 8 evolved weapons covering 4 weapon types: projectile (2), orbit (3), aura (1), boomerang (2). This spec adds **4 new evolved weapons** (evolutions 9-12) with **4 entirely new weapon types** not present in any existing weapon: **spiral**, **sentinel**, **pulse**, and **beam**. Each new evolution combines 2 base weapons at Lv3, consistent with the existing dual-weapon evolution system.

The goal is to increase build diversity and introduce novel attack patterns. The current 8 evolutions cover "enhanced versions of existing types." The new 4 evolutions introduce fundamentally new attack behaviors that cannot be achieved by any base weapon, creating genuinely new gameplay moments.

**Why new weapon types instead of more of the same**: The existing evolution pool already has multiple orbit/projectile/boomerang variants. Adding more would dilute the identity of each type. New types (spiral trajectories, autonomous turrets, expanding shockwaves, penetrating lasers) create distinct combat experiences that reward specific build paths.

**Research basis**: Vampire Survivors introduced "special" weapons like Laurel (shield pulse) and Atlantis (spiral fork). Brotato uses stationary turrets. These are proven concepts that add tactical variety.

---

## 2. Research Summary

### 2.1 Genre Analysis for New Weapon Types

| Game | Novel Mechanic | Applicability |
|---|---|---|
| **Vampire Survivors** | Laurel (periodic shield pulse that expands outward, knocking back enemies) | Pulse type -- expanding damage ring |
| **Brotato** | Turrets / stationary allies that auto-fire | Sentinel type -- autonomous turret |
| **Holocure** | Spiral weapons (Mumei's feathers rotate outward) | Spiral type -- expanding spiral projectile |
| **Magic Survival** | Beam weapons (continuous laser in one direction) | Beam type -- penetrating line damage |

### 2.2 Gap Analysis

| New Type | Current System Coverage | Gap |
|---|---|---|
| spiral | No base weapon has expanding spiral motion | Fully new |
| sentinel | No autonomous entity exists; all weapons fire from player | Fully new |
| pulse | Closest is aura (continuous), pulse is periodic + expanding | New behavior pattern |
| beam | Closest is cone (short range fan); beam is long-range narrow line | New range/shape profile |

---

## 3. Brainstorm (3-5 Options -> Convergence)

### 3.1 Options Considered

| Option | Core Idea | Weapon Type | Tech Cost | Balance Risk | Player Appeal |
|---|---|---|---|---|---|
| A. Frost Vortex | knife + frostaura -> spinning ice blades that expand outward in spiral | spiral | Medium (new trajectory math) | Low (fixed pattern) | High (visually spectacular) |
| B. Sentinel Totem | bible + boomerang -> stationary turret that auto-fires at enemies | sentinel | Medium (new entity lifecycle) | Medium (turret positioning) | High (auto-pilot fantasy) |
| C. Shockwave | holywater + firestaff -> periodic expanding damage ring from player | pulse | Low (radius expansion over time) | Low (simple AoE) | Medium (satisfying pulse feel) |
| D. Arcane Beam | lightning + knife -> long-range penetrating laser line | beam | Low (line raycast/check) | Medium (high single-target DPS) | High (laser fantasy) |
| E. Meteor Strike | firestaff + boomerang -> targeted AoE that rains fire from above | aoe (not new type) | High (targeting system) | High (overlap with arrow rain skill) | Medium |

### 3.2 Feasibility Assessment

| Option | Tech Cost (1-5) | Balance Difficulty (1-5) | Understanding Cost (1-5) | Score (lower=better) |
|---|---|---|---|---|
| A. Frost Vortex | 3 | 2 | 1 | 6 |
| B. Sentinel Totem | 3 | 3 | 2 | 8 |
| C. Shockwave | 2 | 2 | 1 | 5 |
| D. Arcane Beam | 2 | 3 | 1 | 6 |
| E. Meteor Strike | 4 | 4 | 2 | 10 (rejected) |

### 3.3 Convergence

Selected: **A + B + C + D** (all four novel types). Option E rejected because (1) "aoe" is not a new weapon type and would overlap with the Ranger's Arrow Rain skill, (2) high tech cost for targeting system.

---

## 4. Evolution Recipes (4 New)

| # | Ingredient A | Ingredient B | Result Weapon | Chinese Name | New Type | Core Mechanic |
|---|---|---|---|---|---|---|
| 9 | knife | frostaura | frostvortex | 霜刃旋涡 | spiral | Expanding spiral of ice blades |
| 10 | bible | boomerang | sentineltotem | 守护图腾 | sentinel | Stationary turret, auto-fires |
| 11 | holywater | firestaff | holyshockwave | 圣焰冲击 | pulse | Periodic expanding damage ring |
| 12 | lightning | knife | thunderbeam | 雷霆射线 | beam | Long-range penetrating laser |

**Ingredient coverage check**: Each base weapon appears in at least one new recipe:
- knife: frostvortex (A) + thunderbeam (D) -- already used in fireknife, frostknife
- frostaura: frostvortex (A) -- already used in blizzard, frostknife
- bible: sentineltotem (B) -- already used in holydomain, flamebible
- boomerang: sentineltotem (B) -- already used in thunderang, blazerang
- holywater: holyshockwave (C) -- already used in thunderholywater, holydomain
- firestaff: holyshockwave (C) -- already used in fireknife, flamebible, blazerang
- lightning: thunderbeam (D) -- already used in thunderholywater, blizzard, thunderang

All 7 base weapons are used. Some weapons now have 4+ evolution paths (knife: fireknife, frostknife, frostvortex, thunderbeam = 4 paths). This is intentional -- knife is the most common starting weapon and having many evolution outlets increases build flexibility.

---

## 5. Evolved Weapon Definitions

### 5.1 Frost Vortex (frostvortex) -- Spiral Type

**Description**: A spinning vortex of ice blades that expands outward from the player in a spiral pattern. Each blade damages and slows enemies. The vortex periodically resets to the player's position.

**Visual**: 6 small blue-white ColorRect blades (5x12 px) arranged in a spiral, rotating and expanding outward from the player. Blades leave a faint blue trail (Color 0.3, 0.7, 1.0 with low alpha). When the spiral reaches max radius, blades converge back to player and restart.

#### Numerical Constants

| Constant Name | Value | Unit | Source | Notes |
|---|---|---|---|---|
| `FROSTVORTEX_WEAPON_ID` | `"frostvortex"` | string | New | |
| `FROSTVORTEX_WEAPON_NAME` | `"霜刃旋涡"` | string | New | |
| `FROSTVORTEX_WEAPON_TYPE` | `"spiral"` | string | New type | |
| `FROSTVORTEX_DAMAGE` | 3.0 | HP | New (between knife 2.0 and fireknife 3.0) | Per blade hit |
| `FROSTVORTEX_BLADE_COUNT` | 6 | count | New (more than orbit count of 3-4) | |
| `FROSTVORTEX_COOLDOWN` | 999.0 | seconds | New (always active, like orbit/aura) | |
| `FROSTVORTEX_MIN_RADIUS` | 20.0 | pixels | New | Start close to player |
| `FROSTVORTEX_MAX_RADIUS` | 180.0 | pixels | New (larger than holydomain orbit 130) | |
| `FROSTVORTEX_EXPAND_SPEED` | 60.0 | px/s | New | Time to max: 180/60 = 3.0s |
| `FROSTVORTEX_ROTATION_SPEED` | 4.0 | rad/s | New (faster than orbit 3.0-4.0) | |
| `FROSTVORTEX_SLOW_PCT` | 0.4 | fraction | Same as frostknife slow | |
| `FROSTVORTEX_FREEZE_PCT` | 0.08 | fraction | Same as frostaura Lv3 freeze | |
| `FROSTVORTEX_BLADE_SIZE` | 5.0 | px width | New | 5x12 rectangular blade |
| `FROSTVORTEX_COLOR` | `Color(0.3, 0.7, 1.0)` | Color | New (ice blue) | |
| `FROSTVORTEX_IS_EVOLVED` | true | bool | -- | |
| `FROSTVORTEX_DESCRIPTION` | `"螺旋冰刃扩散+减速"` | string | -- | |

#### Level Scaling (Evolved weapons are max_level=1, no further upgrade)

No level scaling. Fixed values above.

#### Synergy: Frostbite Loop

**Synergy Name**: Frostbite Loop
**Effect**: When a frostvortex blade freezes an enemy, all blades briefly accelerate (expand_speed x1.5 for 0.5s), creating a cascading freeze effect on clustered enemies.
**Trigger**: Enemy frozen by frostvortex.
**Internal Cooldown**: 1.0s per enemy (prevents perpetual acceleration).

| Synergy Constant | Value | Notes |
|---|---|---|
| `FROSTVORTEX_SYNERGY_ACCEL_MUL` | 1.5 | Speed multiplier on freeze trigger |
| `FROSTVORTEX_SYNERGY_ACCEL_DUR` | 0.5s | Duration of acceleration burst |
| `FROSTVORTEX_SYNERGY_ICD` | 1.0s | Internal cooldown per enemy |

**Why this synergy**: The spiral pattern naturally clusters hits on grouped enemies. When one enemy freezes, the acceleration causes the blades to reach other enemies faster, potentially triggering a chain reaction. This rewards positioning the vortex near enemy clusters.

---

### 5.2 Sentinel Totem (sentineltotem) -- Sentinel Type

**Description**: Summons a stationary totem at a strategic position that auto-fires projectiles at nearby enemies. The totem has a limited lifespan and repositions near the player when it expires. This is the first "autonomous entity" weapon -- the player does not directly control it.

**Visual**: A 16x16 ColorRect totem (golden-brown, Color 0.7, 0.6, 0.2) that appears near the player. Small white projectiles (3x3) fire from the totem toward enemies. A faint circular indicator shows its attack range.

#### Numerical Constants

| Constant Name | Value | Unit | Source | Notes |
|---|---|---|---|---|
| `SENTINELTOTEM_WEAPON_ID` | `"sentineltotem"` | string | New | |
| `SENTINELTOTEM_WEAPON_NAME` | `"守护图腾"` | string | New | |
| `SENTINELTOTEM_WEAPON_TYPE` | `"sentinel"` | string | New type | |
| `SENTINELTOTEM_DAMAGE` | 2.5 | HP | New (slightly less than knife 3.0 per hit) | Per totem projectile |
| `SENTINELTOTEM_COOLDOWN` | 999.0 | seconds | New (always active) | |
| `SENTINELTOTEM_FIRE_RATE` | 0.8 | seconds | New (between knife 0.7 and boomerang 1.8) | Time between totem shots |
| `SENTINELTOTEM_RANGE` | 250.0 | pixels | New (between projectile range 500 and cone range 100) | Attack range from totem |
| `SENTINELTOTEM_LIFETIME` | 8.0 | seconds | New | Duration before repositioning |
| `SENTINELTOTEM_TOTEM_COUNT` | 2 | count | New | Simultaneous totems |
| `SENTINELTOTEM_PROJECTILE_SPEED` | 280.0 | px/s | New (slightly slower than knife 350) | |
| `SENTINELTOTEM_PROJECTILE_SIZE` | 3.0 | px | New | Small projectiles |
| `SENTINELTOTEM_SPAWN_OFFSET` | 100.0 | pixels | New | Distance from player when placed |
| `SENTINELTOTEM_COLOR` | `Color(0.7, 0.6, 0.2)` | Color | New (golden-brown totem) | |
| `SENTINELTOTEM_PROJ_COLOR` | `Color(0.9, 0.85, 0.5)` | Color | New (golden projectile) | |
| `SENTINELTOTEM_IS_EVOLVED` | true | bool | -- | |
| `SENTINELTOTEM_DESCRIPTION` | `"自动炮台图腾+定向射击"` | string | -- | |

#### Totem Behavior

1. **Placement**: Totems are placed at player position + 100px in the direction of the nearest enemy cluster. If no enemies exist, placed to the right of the player.
2. **Reposition**: After 8 seconds, the totem dissolves and re-appears at a new optimal position near the player's current location.
3. **Targeting**: Each totem independently targets the closest enemy within its 250px range. Fires one projectile every 0.8s.
4. **Max count**: 2 totems active simultaneously. If a new totem is placed while 2 exist, the oldest one is removed.
5. **Persistence**: Totems are NOT removed on weapon removal (since evolved weapons cannot be removed). They persist until their lifetime expires.

#### Synergy: Overwatch

**Synergy Name**: Overwatch
**Effect**: When an enemy is damaged by a sentinel totem projectile, the enemy takes 10% increased damage from ALL sources for 2 seconds. This debuff stacks up to 2 times (20% max).
**Trigger**: Enemy hit by sentinel totem projectile.

| Synergy Constant | Value | Notes |
|---|---|---|
| `SENTINELTOTEM_SYNERGY_VULN_PCT` | 0.10 | +10% damage taken |
| `SENTINELTOTEM_SYNERGY_VULN_DUR` | 2.0s | Duration of vulnerability |
| `SENTINELTOTEM_SYNERGY_VULN_MAX_STACKS` | 2 | Maximum stacks |

**Why this synergy**: The sentinel totem is a supplementary DPS source, not a primary one. The vulnerability debuff makes it a force multiplier for all other weapons. Players benefit most by placing totems near enemy clusters while their primary weapons (projectiles, boomerangs, etc.) deal the buffed damage. This rewards strategic positioning.

---

### 5.3 Holy Shockwave (holyshockwave) -- Pulse Type

**Description**: Periodically emits an expanding ring of holy fire centered on the player. The ring expands outward, damaging and briefly burning all enemies it passes through. Unlike aura (continuous damage), pulse is a discrete periodic event with strong visual impact.

**Visual**: An expanding circle (ring, no fill) that grows from 0 to max radius over 0.3 seconds. Color transitions from bright gold (Color 1.0, 0.85, 0.3) at center to orange-red (Color 1.0, 0.4, 0.1) at max radius. Screen shake 2.0 intensity on each pulse.

#### Numerical Constants

| Constant Name | Value | Unit | Source | Notes |
|---|---|---|---|---|
| `HOLYSHOCKWAVE_WEAPON_ID` | `"holyshockwave"` | string | New | |
| `HOLYSHOCKWAVE_WEAPON_NAME` | `"圣焰冲击"` | string | New | |
| `HOLYSHOCKWAVE_WEAPON_TYPE` | `"pulse"` | string | New type | |
| `HOLYSHOCKWAVE_DAMAGE` | 8.0 | HP | New (highest single-hit evolved weapon; justifies long cooldown) | Per pulse |
| `HOLYSHOCKWAVE_COOLDOWN` | 3.0 | seconds | New (periodic, not continuous) | |
| `HOLYSHOCKWAVE_MAX_RADIUS` | 200.0 | pixels | New (larger than blizzard aura 160) | |
| `HOLYSHOCKWAVE_EXPAND_TIME` | 0.3 | seconds | New | Ring expansion duration |
| `HOLYSHOCKWAVE_RING_WIDTH` | 12.0 | pixels | New | Thickness of expanding ring |
| `HOLYSHOCKWAVE_BURN_DPS` | 2.0 | HP/s | Same as BURN_DPS in weapon_fire.gd:14 | Consistent with firestaff burn |
| `HOLYSHOCKWAVE_BURN_DURATION` | 2.0 | seconds | Same as BURN_DURATION in weapon_fire.gd:15 | |
| `HOLYSHOCKWAVE_COLOR_CENTER` | `Color(1.0, 0.85, 0.3)` | Color | New (gold) | |
| `HOLYSHOCKWAVE_COLOR_EDGE` | `Color(1.0, 0.4, 0.1)` | Color | New (orange-red) | |
| `HOLYSHOCKWAVE_SCREENSHAKE` | 2.0 | intensity | New (same as hurt shake) | |
| `HOLYSHOCKWAVE_SCREENSHAKE_DUR` | 0.1 | seconds | New | |
| `HOLYSHOCKWAVE_IS_EVOLVED` | true | bool | -- | |
| `HOLYSHOCKWAVE_DESCRIPTION` | `"周期性圣焰脉冲+燃烧"` | string | -- | |

#### DPS Analysis

- Damage per pulse: 8.0 HP
- Pulses per 57-second wave: 57 / 3.0 = 19 pulses
- Raw DPS: 8.0 / 3.0 = 2.67 DPS (lower than blizzard's 3.0 aura DPS)
- Effective DPS including burn: 2.67 + (2.0 * 2.0 / 3.0) = 2.67 + 1.33 = 4.0 DPS
- This is balanced because the pulse has guaranteed hit on all enemies in range (no targeting needed)

#### Synergy: Resonance

**Synergy Name**: Resonance
**Effect**: Each enemy killed by holyshockwave reduces the pulse cooldown by 0.3 seconds (minimum cooldown 1.5s). Creates a snowball effect during dense waves.
**Trigger**: Enemy killed by holyshockwave damage (direct hit or burn tick).

| Synergy Constant | Value | Notes |
|---|---|---|
| `HOLYSHOCKWAVE_SYNERGY_CD_REDUCTION` | 0.3s | Cooldown reduction per kill |
| `HOLYSHOCKWAVE_SYNERGY_MIN_COOLDOWN` | 1.5s | Cannot go below 1.5s |

**Why this synergy**: The pulse weapon is naturally strongest against dense enemy clusters. The resonance mechanic rewards this strength -- more kills mean faster pulses mean more kills. The 1.5s minimum prevents the pulse from becoming a continuous damage source. During a dense wave (Wave 4-5 with 50+ enemies), the player might get 3-4 kills per pulse, reducing cooldown from 3.0s to ~1.8-2.1s, which feels powerful but not broken.

---

### 5.4 Thunder Beam (thunderbeam) -- Beam Type

**Description**: Fires a long-range penetrating lightning beam in the direction of the nearest enemy. The beam damages all enemies along its path and has a chance to chain lightning to nearby enemies. This is the only weapon with unlimited range (limited only by arena boundaries).

**Visual**: A thin bright yellow-white line (2px wide) extending from the player to the arena edge in the targeting direction. Lightning sparks (small ColorRect flickers) appear along the beam. Color: Color(1.0, 1.0, 0.4) with occasional white flashes.

#### Numerical Constants

| Constant Name | Value | Unit | Source | Notes |
|---|---|---|---|---|
| `THUNDERBEAM_WEAPON_ID` | `"thunderbeam"` | string | New | |
| `THUNDERBEAM_WEAPON_NAME` | `"雷霆射线"` | string | New | |
| `THUNDERBEAM_WEAPON_TYPE` | `"beam"` | string | New type | |
| `THUNDERBEAM_DAMAGE` | 4.0 | HP | New (per-tick damage) | Damages every 0.3s while beam is active |
| `THUNDERBEAM_COOLDOWN` | 2.5 | seconds | New (between lightning 2.0 and boomerang 1.8) | |
| `THUNDERBEAM_ACTIVE_DURATION` | 1.0 | seconds | New | Beam fires for 1.0s, then 1.5s pause |
| `THUNDERBEAM_TICK_INTERVAL` | 0.3 | seconds | New | Damage applied every 0.3s |
| `THUNDERBEAM_WIDTH` | 12.0 | pixels | New (wider than visual 2px to allow hit detection) | Collision width |
| `THUNDERBEAM_CHAIN_COUNT` | 2 | count | New (same as thunderang chains) | Lightning chains after beam hits |
| `THUNDERBEAM_CHAIN_DAMAGE` | 6.0 | HP | New | Chain lightning damage |
| `THUNDERBEAM_CHAIN_RANGE` | 120.0 | pixels | New | Chain targeting range |
| `THUNDERBEAM_RANGE` | 1200.0 | pixels | New (effectively unlimited; arena is 2500-3000 wide) | |
| `THUNDERBEAM_COLOR` | `Color(1.0, 1.0, 0.4)` | Color | New (electric yellow) | |
| `THUNDERBEAM_SPARK_COLOR` | `Color(1.0, 1.0, 1.0)` | Color | New (white sparks) | |
| `THUNDERBEAM_IS_EVOLVED` | true | bool | -- | |
| `THUNDERBEAM_DESCRIPTION` | `"穿透闪电射线+连锁电击"` | string | -- | |

#### DPS Analysis

- Beam active 1.0s every 2.5s cycle = 40% uptime
- Tick damage: 4.0 HP every 0.3s = 3 ticks per activation = 12.0 HP per activation
- DPS: 12.0 / 2.5 = 4.8 DPS (against single target)
- With chain lightning (2 chains, 6.0 each): +12.0 / 2.5 = 4.8 additional DPS against groups
- Total multi-target DPS: ~9.6 DPS -- highest of any evolved weapon, but requires enemies to be lined up
- Balance justification: The beam only fires in one direction. Against spread-out enemies, effective DPS is much lower. The high single-target DPS rewards positioning.

#### Synergy: Overcharge

**Synergy Name**: Overcharge
**Effect**: While the beam is active, the player's movement speed increases by 15%. This encourages aggressive positioning -- running alongside the beam to sweep it across more enemies.
**Trigger**: Thunder beam active_duration > 0.

| Synergy Constant | Value | Notes |
|---|---|---|
| `THUNDERBEAM_SYNERGY_SPEED_BONUS` | 0.15 | +15% movement speed |
| `THUNDERBEAM_SYNERGY_ONLY_WHEN_ACTIVE` | true | Only during beam firing |

**Why this synergy**: The beam fires in a fixed direction for 1.0 seconds. Without movement, it only hits enemies in a narrow line. The speed bonus encourages the player to strafe while the beam is active, effectively "sweeping" the beam across a wider area. This transforms the beam from a static damage source into an active positioning tool. The 15% bonus matches the speedboots passive (not stacking -- additive with player speed).

---

## 6. WeaponData.gd Additions

Four new fields needed to support the new weapon types:

```
# Spiral (frostvortex)
@export var spiral_blade_count: int = 6
@export var spiral_min_radius: float = 20.0
@export var spiral_max_radius: float = 180.0
@export var spiral_expand_speed: float = 60.0

# Sentinel (sentineltotem)
@export var sentinel_fire_rate: float = 0.8
@export var sentinel_range: float = 250.0
@export var sentinel_lifetime: float = 8.0
@export var sentinel_count: int = 2

# Pulse (holyshockwave)
@export var pulse_max_radius: float = 200.0
@export var pulse_expand_time: float = 0.3
@export var pulse_ring_width: float = 12.0

# Beam (thunderbeam)
@export var beam_active_duration: float = 1.0
@export var beam_tick_interval: float = 0.3
@export var beam_width: float = 12.0
```

---

## 7. weapon_controller.gd Integration

The weapon_controller `_fire_weapon()` match statement needs 4 new cases:

```gdscript
# In _fire_weapon(), add to match data.weapon_type:
"spiral":
    _spiral_instance = wf.update_spiral(weapon_id, data, player, dmg_bonus, _spiral_instance)
"sentinel":
    _sentinel_instances = wf.update_sentinel(weapon_id, data, player, dmg_bonus, _sentinel_instances)
"pulse":
    wf.fire_pulse(weapon_id, data, player, dmg_bonus, _weapon_timers)
"beam":
    wf.fire_beam(data, player, dmg_bonus)
```

New state variables in weapon_controller.gd:

```gdscript
var _spiral_instance: Node2D = null
var _sentinel_instances: Array = []
```

---

## 8. Registration in upgrade_pool.gd

### 8.1 New Evolved Weapons (add to `_register_evolved_weapons()`)

```gdscript
# 9. Frost Vortex (knife + frostaura)
var fv := WeaponData.new()
fv.weapon_name = "霜刃旋涡"; fv.weapon_id = "frostvortex"; fv.weapon_type = "spiral"
fv.damage = 3.0; fv.cooldown = 999.0; fv.spiral_blade_count = 6
fv.spiral_min_radius = 20.0; fv.spiral_max_radius = 180.0; fv.spiral_expand_speed = 60.0
fv.slow_pct = 0.4; fv.freeze_pct = 0.08; fv.color = Color(0.3, 0.7, 1.0)
fv.projectile_size = 5.0; fv.is_evolved = true
fv.description = "螺旋冰刃扩散+减速"
register_weapon("frostvortex", fv)

# 10. Sentinel Totem (bible + boomerang)
var st := WeaponData.new()
st.weapon_name = "守护图腾"; st.weapon_id = "sentineltotem"; st.weapon_type = "sentinel"
st.damage = 2.5; st.cooldown = 999.0; st.sentinel_fire_rate = 0.8
st.sentinel_range = 250.0; st.sentinel_lifetime = 8.0; st.sentinel_count = 2
st.projectile_speed = 280.0; st.projectile_size = 3.0; st.color = Color(0.7, 0.6, 0.2)
st.is_evolved = true; st.description = "自动炮台图腾+定向射击"
register_weapon("sentineltotem", st)

# 11. Holy Shockwave (holywater + firestaff)
var hs := WeaponData.new()
hs.weapon_name = "圣焰冲击"; hs.weapon_id = "holyshockwave"; hs.weapon_type = "pulse"
hs.damage = 8.0; hs.cooldown = 3.0; hs.pulse_max_radius = 200.0
hs.pulse_expand_time = 0.3; hs.pulse_ring_width = 12.0
hs.burn_dps = 2.0; hs.burn_duration = 2.0; hs.color = Color(1.0, 0.85, 0.3)
hs.is_evolved = true; hs.description = "周期性圣焰脉冲+燃烧"
register_weapon("holyshockwave", hs)

# 12. Thunder Beam (lightning + knife)
var tb := WeaponData.new()
tb.weapon_name = "雷霆射线"; tb.weapon_id = "thunderbeam"; tb.weapon_type = "beam"
tb.damage = 4.0; tb.cooldown = 2.5; tb.beam_active_duration = 1.0
tb.beam_tick_interval = 0.3; tb.beam_width = 12.0; tb.chain_count = 2
tb.projectile_range = 1200.0; tb.color = Color(1.0, 1.0, 0.4)
tb.is_evolved = true; tb.description = "穿透闪电射线+连锁电击"
register_weapon("thunderbeam", tb)
```

### 8.2 New Evolution Recipes (add to weapon_registry.gd)

Add 4 entries to `EVOLUTION_RECIPES`:

```gdscript
{"a": "knife", "b": "frostaura", "result": "frostvortex"},
{"a": "bible", "b": "boomerang", "result": "sentineltotem"},
{"a": "holywater", "b": "firestaff", "result": "holyshockwave"},
{"a": "lightning", "b": "knife", "result": "thunderbeam"},
```

---

## 9. Complete Evolution Recipe Table (Updated: 12 Total)

| # | Ingredient A | Ingredient B | Result | Chinese | Type | Description |
|---|---|---|---|---|---|---|
| 1 | holywater | lightning | thunderholywater | 雷暴圣水 | orbit | 旋转+链式闪电 |
| 2 | knife | firestaff | fireknife | 火焰飞刀 | projectile | 燃烧穿透飞刀 |
| 3 | bible | holywater | holydomain | 圣光领域 | orbit | 超大范围+圣光脉冲 |
| 4 | frostaura | lightning | blizzard | 暴风雪 | aura | 大范围暴风雪+闪电链 |
| 5 | knife | frostaura | frostknife | 冰霜飞刀 | projectile | 减速穿透飞刀 |
| 6 | bible | firestaff | flamebible | 烈焰经文 | orbit | 旋转灼烧+火焰脉冲 |
| 7 | boomerang | lightning | thunderang | 雷霆回旋 | boomerang | 追踪+闪电链 |
| 8 | boomerang | firestaff | blazerang | 烈焰回旋 | boomerang | 追踪+火焰轨迹 |
| **9** | **knife** | **frostaura** | **frostvortex** | **霜刃旋涡** | **spiral** | **螺旋冰刃扩散+减速** |
| **10** | **bible** | **boomerang** | **sentineltotem** | **守护图腾** | **sentinel** | **自动炮台图腾+定向射击** |
| **11** | **holywater** | **firestaff** | **holyshockwave** | **圣焰冲击** | **pulse** | **周期性圣焰脉冲+燃烧** |
| **12** | **lightning** | **knife** | **thunderbeam** | **雷霆射线** | **beam** | **穿透闪电射线+连锁电击** |

---

## 10. Balance Analysis

### 10.1 DPS Comparison (Single Target, Lv1)

| Evolved Weapon | Raw DPS | Effective DPS (with effects) | Condition |
|---|---|---|---|
| thunderholywater (orbit) | 4.5 | 4.5 | Always active |
| fireknife (projectile) | 30.0 | 30.0 + burn | High fire rate, requires targeting |
| holydomain (orbit) | 10.0 | 10.0 + pulse | Always active |
| blizzard (aura) | 3.0 | 3.0 + slow + freeze + lightning | Always active |
| frostknife (projectile) | 20.8 | 20.8 + slow | High fire rate |
| flamebible (orbit) | 5.0 | 5.0 + burn + pulse | Always active |
| thunderang (boomerang) | 35.0 | 35.0 + chain | Periodic, requires boomerang return |
| blazerang (boomerang) | 22.5 | 22.5 + burn trail | Periodic |
| **frostvortex (spiral)** | **~6.0** | **6.0 + slow + freeze** | Always active, expanding pattern |
| **sentineltotem (sentinel)** | **6.25** | **6.25 + vuln debuff** | 2 totems x 2.5 @ 0.8s rate |
| **holyshockwave (pulse)** | **2.67** | **4.0 + burn** | Periodic, guaranteed hit AoE |
| **thunderbeam (beam)** | **4.8** | **4.8 + chain (9.6 multi-target)** | Single direction, 40% uptime |

### 10.2 Design Intent per Type

| Type | Role | Strength | Weakness |
|---|---|---|---|
| spiral | Area control | Wide coverage, slow+freeze utility | Low raw DPS, predictable pattern |
| sentinel | Supplementary DPS | Autonomous, vulnerability debuff | Low individual damage, needs repositioning |
| pulse | Burst AoE | High single-hit, guaranteed contact, burn | Low sustained DPS, long cooldown |
| beam | Directional DPS | Highest multi-target potential, long range | Single direction, enemies must be lined up |

### 10.3 Ingredient Overlap Analysis

Some base weapons now have many evolution paths:
- **knife**: 4 paths (fireknife, frostknife, frostvortex, thunderbeam) -- knife is the most flexible base weapon
- **lightning**: 4 paths (thunderholywater, blizzard, thunderang, thunderbeam) -- lightning equally flexible
- **firestaff**: 4 paths (fireknife, flamebible, blazerang, holyshockwave)
- **frostaura**: 3 paths (blizzard, frostknife, frostvortex)
- **holywater**: 3 paths (thunderholywater, holydomain, holyshockwave)
- **bible**: 3 paths (holydomain, flamebible, sentineltotem)
- **boomerang**: 3 paths (thunderang, blazerang, sentineltotem)

This is balanced -- the player can only hold 2 weapons simultaneously for evolution, so having many paths per weapon increases flexibility without power creep. The player still needs to choose which specific evolution to pursue based on their current build.

---

## 11. Visual Specification

### 11.1 Frost Vortex

| Element | Shape | Size | Color | Animation |
|---|---|---|---|---|
| Blade | Rectangle | 5x12 | Color(0.3, 0.7, 1.0) | Spiral outward, 6 blades at 60-degree offsets |
| Trail | Fading line | -- | Color(0.3, 0.7, 1.0, 0.2) | Alpha decay 0.3s |

### 11.2 Sentinel Totem

| Element | Shape | Size | Color | Animation |
|---|---|---|---|---|
| Totem body | Square | 16x16 | Color(0.7, 0.6, 0.2) | Static, pulse alpha on fire |
| Range indicator | Circle outline | radius=250 | Color(0.7, 0.6, 0.2, 0.1) | Faint, always visible |
| Projectile | Square | 3x3 | Color(0.9, 0.85, 0.5) | Moves toward target enemy |

### 11.3 Holy Shockwave

| Element | Shape | Size | Color | Animation |
|---|---|---|---|---|
| Expanding ring | Circle outline | 0 -> 200px radius | Gold->Orange gradient | Expand over 0.3s |
| Ring width | -- | 12px | -- | Fixed thickness during expansion |
| Screen shake | -- | -- | -- | 2.0 intensity for 0.1s |

### 11.4 Thunder Beam

| Element | Shape | Size | Color | Animation |
|---|---|---|---|---|
| Beam line | Thin line | 2px visual, 12px collision | Color(1.0, 1.0, 0.4) | Static during 1.0s active |
| Sparks | Small rects | 2x2 | Color(1.0, 1.0, 1.0) | Random flicker along beam |
| Chain lightning | Jagged line | -- | Color(0.5, 0.8, 1.0) | Same as existing lightning effect |

---

## 12. Implementation Touch Points

### 12.1 Files to Create

| File | Purpose |
|---|---|
| `scripts/weapons/spiral_blade.gd` | Spiral blade behavior (expanding rotation, damage on contact) |
| `scripts/weapons/sentinel.gd` | Sentinel totem behavior (targeting, projectile firing, lifetime) |
| `scripts/weapons/pulse_ring.gd` | Expanding pulse ring (radius growth, damage on overlap, burn application) |
| `scripts/weapons/beam_line.gd` | Beam behavior (directional line, periodic tick damage, chain lightning) |

### 12.2 Files to Modify

| File | Change | Scope |
|---|---|---|
| `scripts/data/weapon_data.gd` | Add 4 new export groups (spiral, sentinel, pulse, beam fields) | ~16 lines |
| `scripts/autoload/upgrade_pool.gd` | Add 4 new evolved weapon registrations in `_register_evolved_weapons()` | ~40 lines |
| `scripts/weapons/weapon_registry.gd` | Add 4 new entries to `EVOLUTION_RECIPES` array | 4 lines |
| `scripts/weapon_controller.gd` | Add `_spiral_instance`, `_sentinel_instances` state vars. Add 4 new cases to match statement. | ~20 lines |
| `scripts/weapons/weapon_fire.gd` | Add `update_spiral()`, `update_sentinel()`, `fire_pulse()`, `fire_beam()` functions | ~120 lines |

### 12.3 New Signals

| Signal | Emitter | Listener | Purpose |
|---|---|---|---|
| `enemy_vulnerability_applied(enemy, stacks)` | sentinel projectile | weapon_controller | Track vulnerability debuff for damage bonus |

---

## 13. Design Decisions Log

| Decision | Why | Alternative Considered |
|---|---|---|
| 4 new weapon types (spiral, sentinel, pulse, beam) instead of reusing existing types | Current evolution pool already has multiple variants of projectile/orbit/boomerang. New types create genuinely new gameplay experiences rather than "more of the same." | More orbit/projectile/boomerang variants (boring, dilutes type identity) |
| Spiral: expanding radius with periodic reset | Creates a "breathing" attack pattern that covers near and far enemies alternately. The 3s cycle (expand to 180px at 60px/s, then reset) provides a clear rhythm. | Constant-radius spiral (like orbit, redundant with existing orbit weapons) |
| Sentinel: 2 totems with 8s lifetime, auto-reposition | 2 totems provide coverage without overwhelming the screen. 8s lifetime + auto-reposition keeps them relevant as the player moves. No manual placement (too complex for WASD controls). | Permanent turrets (too strong, clutter screen), player-placed turrets (requires targeting system), 1 totem (too weak) |
| Pulse: 8.0 damage, 3.0s cooldown | Highest single-hit damage of any weapon. Justified by the long cooldown and the fact that it's a discrete event (not continuous like aura). 8.0 damage + burn = meaningful burst without overshadowing sustained DPS weapons. | Lower damage, faster cooldown (becomes similar to aura), higher damage, slower cooldown (too infrequent to feel relevant) |
| Beam: 4.0 damage per tick, 1.0s active / 1.5s pause | The beam's strength is multi-target line damage, not single-target burst. 4.0 per tick with 0.3s interval means 3 ticks = 12.0 per activation, which is strong against grouped enemies. The 40% uptime prevents it from being a constant death ray. | Continuous beam (too strong, no rhythm), higher damage per tick (overtuned for multi-target) |
| Frost Vortex: knife + frostaura | Combines knife's rapid fire theme with frostaura's slow/freeze utility. The spiral pattern visually represents "knives spinning in an icy vortex." | knife + lightning (would create another lightning variant, overlaps with thunderang) |
| Sentinel Totem: bible + boomerang | Bible is the "holy guardian" weapon. Boomerang is the "returning projectile." A stationary turret that fires projectiles at enemies thematically combines "holy guardian" (positioning, protection) with "returning projectile" (autonomous targeting). | bible + firestaff (overlap with flamebible), boomerang + frostaura (overlap with frostknife) |
| Holy Shockwave: holywater + firestaff | Holywater is the "holy water" element. Firestaff is the "fire" element. The combination creates "holy fire" -- a pulse of divine flame that burns enemies. The pulse mechanic (periodic expansion) is thematically similar to water ripples. | holywater + lightning (overlap with thunderholywater), firestaff + knife (overlap with fireknife) |
| Thunder Beam: lightning + knife | Lightning is the "electric" element. Knife is the "penetrating projectile." The combination creates a "penetrating lightning beam" that pierces through enemies in a line. The beam inherits lightning's chain effect and knife's penetration theme. | lightning + boomerang (overlap with thunderang), lightning + bible (overlap with thunderholywater) |
| No level scaling for evolved weapons | Consistent with existing design: evolved weapons are max_level=1. Adding level scaling for new evolutions would create inconsistency. | Level-scaled evolutions (would require reworking the entire evolution system) |
| Synergies are inherent to each weapon, not passive-dependent | The 4 new synergies (Frostbite Loop, Overwatch, Resonance, Overcharge) are built into the evolved weapon behavior. They do not require passive items. This simplifies the integration -- no new synergy_manager entries needed. | Passive-dependent synergies (would add complexity to synergy_manager.gd, requires new synergy definitions) |
| knife has 4 evolution paths | knife is the most accessible weapon (starting weapon for Warrior, early pick for all characters). Having many evolution paths increases build diversity and reduces the chance of "dead-end" weapons. Limiting knife to 2 paths would make it a poor late-game choice. | Limit each weapon to 2 evolution paths (reduces flexibility, some weapons become dead ends) |

---

## 14. Future Enhancements (Out of Scope)

1. **Spiral weapon level scaling** -- If future design allows evolved weapon upgrades, frostvortex could gain more blades (+2 per level) and faster expand speed.
2. **Sentinel totem type variants** -- Fire totem (burn), Ice totem (slow), Lightning totem (chain) as alternative sentinel weapons.
3. **Pulse combo with dash** -- Holy shockwave pulse triggered on dash for active-skill synergy.
4. **Beam rotation** -- Thunder beam slowly sweeps in an arc instead of firing in a fixed direction.
5. **Cross-evolution synergies** -- frostvortex + blizzard = "absolute zero" (freeze all enemies in spiral path); thunderbeam + thunderang = "thunderstorm" (beam calls down lightning strikes along its path).
