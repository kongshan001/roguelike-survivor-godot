# Evolved Weapon Registration Spec: frostvortex, holyshockwave, thunderbeam

**Author**: Designer Agent
**Date**: 2026-04-17
**Round**: R23 (R24 updated with detailed numerical tables)
**Status**: Design Spec
**Priority**: P2 LOW
**Context**: 12 evolved weapons are defined in evolution-expansion.md (R9), but only 9 are registered in upgrade_pool.gd and weapon_registry.gd. The missing 3 (frostvortex/spiral, holyshockwave/pulse, thunderbeam/beam) have full numerical specs but no registration entries. This means players who build the correct dual-Lv3 combo for these 3 paths get no evolution reward. v1.0.3 roadmap item 4.4.

---

## 1. Gap Analysis

### 1.1 Current Registration State

| # | Weapon | Type | Registered in upgrade_pool.gd | Registered in weapon_registry.gd | Weapon Behavior in weapon_fire.gd |
|---|---|---|---|---|---|
| 1 | thunderholywater | orbit | YES (line 80) | YES (line 8) | YES (orbit) |
| 2 | fireknife | projectile | YES (line 87) | YES (line 9) | YES (projectile) |
| 3 | holydomain | orbit | YES (line 94) | YES (line 10) | YES (orbit) |
| 4 | blizzard | aura | YES (line 101) | YES (line 11) | YES (aura) |
| 5 | frostknife | projectile | YES (line 108) | YES (line 12) | YES (projectile) |
| 6 | flamebible | orbit | YES (line 116) | YES (line 13) | YES (orbit) |
| 7 | thunderang | boomerang | YES (line 124) | YES (line 14) | YES (boomerang) |
| 8 | blazerang | boomerang | YES (line 132) | YES (line 15) | YES (boomerang) |
| 9 | sentineltotem | orbit | YES (line 141) | YES (line 16) | YES (orbit with fire_rate) |
| 10 | **frostvortex** | **spiral** | **NO** | **NO** | **NO** (no "spiral" handler) |
| 11 | **holyshockwave** | **pulse** | **NO** | **NO** | **NO** (no "pulse" handler) |
| 12 | **thunderbeam** | **beam** | **NO** | **NO** | **NO** (no "beam" handler) |

### 1.2 What Happens When a Player Builds the Correct Combo

For frostvortex (knife + frostaura, both Lv3):
1. `weapon_registry.gd` iterates `EVOLUTION_RECIPES` -- no recipe matches `knife + frostaura`
2. `get_random_upgrades()` in upgrade_pool.gd never offers the "evolution" option
3. Player has two Lv3 weapons with no evolution path -- feels like a dead end

The same applies to holyshockwave (holywater + firestaff) and thunderbeam (lightning + knife).

### 1.3 Registration vs. Behavior

There are two distinct problems:
- **Registration** (easy): Adding entries to upgrade_pool.gd and weapon_registry.gd
- **Firing behavior** (hard): Adding "spiral", "pulse", "beam" match cases to weapon_controller.gd and implementing the corresponding functions in weapon_fire.gd

This spec covers registration only. Firing behavior requires new scripts (spiral_blade.gd, pulse_ring.gd, beam_line.gd) per evolution-expansion.md Section 12.1 and is out of scope for v1.0.3 -- it requires substantial Programmer Agent work (~95 lines in weapon_fire.gd + 3 new script files).

---

## 2. Registration Design

### 2.1 upgrade_pool.gd Additions

Three new evolved weapon registrations to add at the end of `_register_evolved_weapons()` (after line 148, before the closing of the function):

#### 10. Frost Vortex (knife + frostaura)

```gdscript
# 10. Frost Vortex (knife + frostaura) -- spiral type
var fv := WeaponData.new()
fv.weapon_name = "霜刃旋涡"; fv.weapon_id = "frostvortex"; fv.weapon_type = "spiral"
fv.damage = 3.0; fv.cooldown = 999.0; fv.spiral_blade_count = 6
fv.spiral_min_radius = 20.0; fv.spiral_max_radius = 180.0; fv.spiral_expand_speed = 60.0
fv.slow_pct = 0.4; fv.freeze_pct = 0.08; fv.color = Color(0.3, 0.7, 1.0)
fv.projectile_size = 5.0; fv.is_evolved = true
fv.description = "螺旋冰刃扩散+减速"
register_weapon("frostvortex", fv)
```

#### 11. Holy Shockwave (holywater + firestaff)

```gdscript
# 11. Holy Shockwave (holywater + firestaff) -- pulse type
var hs := WeaponData.new()
hs.weapon_name = "圣焰冲击"; hs.weapon_id = "holyshockwave"; hs.weapon_type = "pulse"
hs.damage = 12.0; hs.cooldown = 2.5; hs.pulse_max_radius = 200.0
hs.pulse_expand_time = 0.3; hs.pulse_ring_width = 12.0
hs.burn_dps = 2.0; hs.burn_duration = 2.0; hs.color = Color(1.0, 0.85, 0.3)
hs.is_evolved = true; hs.description = "周期性圣焰脉冲+燃烧"
register_weapon("holyshockwave", hs)
```

#### 12. Thunder Beam (lightning + knife)

```gdscript
# 12. Thunder Beam (lightning + knife) -- beam type
var tb := WeaponData.new()
tb.weapon_name = "雷霆射线"; tb.weapon_id = "thunderbeam"; tb.weapon_type = "beam"
tb.damage = 4.0; tb.cooldown = 2.5; tb.beam_active_duration = 1.0
tb.beam_tick_interval = 0.3; tb.beam_width = 12.0; tb.chain_count = 2
tb.projectile_range = 1200.0; tb.color = Color(1.0, 1.0, 0.4)
tb.is_evolved = true; tb.description = "穿透闪电射线+连锁电击"
register_weapon("thunderbeam", tb)
```

### 2.2 weapon_registry.gd Additions

Three new entries in `EVOLUTION_RECIPES` array (after line 16, before the closing `]`):

```gdscript
{"a": "knife", "b": "frostaura", "result": "frostvortex"},
{"a": "holywater", "b": "firestaff", "result": "holyshockwave"},
{"a": "lightning", "b": "knife", "result": "thunderbeam"},
```

### 2.3 WeaponData.gd Fields

These fields were defined in evolution-expansion.md Section 6 but need verification they exist in `scripts/data/weapon_data.gd`:

| Field Group | Fields | Required For |
|---|---|---|
| Spiral | `spiral_blade_count`, `spiral_min_radius`, `spiral_max_radius`, `spiral_expand_speed` | frostvortex |
| Orbit fire | `orbit_fire_rate` (already exists, used by sentineltotem) | N/A |
| Pulse | `pulse_max_radius`, `pulse_expand_time`, `pulse_ring_width` | holyshockwave |
| Beam | `beam_active_duration`, `beam_tick_interval`, `beam_width` | thunderbeam |

---

## 3. Firing Behavior Gap

### 3.1 What Needs to Happen for Full Functionality

Registration alone does not make the weapons fire. The weapon_controller.gd match statement (line 69) needs 3 new cases:

```gdscript
"spiral":
    # Needs: spiral_blade.gd (~50 lines), update_spiral() in weapon_fire.gd
    pass
"pulse":
    # Needs: pulse_ring.gd (~40 lines), fire_pulse() in weapon_fire.gd
    pass
"beam":
    # Needs: beam_line.gd (~50 lines), fire_beam() in weapon_fire.gd
    pass
```

### 3.2 Phased Implementation Plan

| Phase | Content | Lines | Risk | Priority |
|---|---|---|---|---|
| Phase A | Registration only (upgrade_pool + weapon_registry) | ~30 | None | v1.0.3 |
| Phase B | WeaponData.gd new fields | ~13 | None | v1.0.3 |
| Phase C | weapon_controller match cases + weapon_fire functions | ~95 | Low | v1.1.0 |
| Phase D | New scripts (spiral_blade.gd, pulse_ring.gd, beam_line.gd) | ~140 | Medium | v1.1.0 |
| Phase E | Sprite textures for 3 new weapons | ~0 (generate_sprites.py) | None | v1.1.0 |

**Phase A + B can be done in v1.0.3** (low risk, ~43 lines total). This ensures the evolution recipes are recognized and the weapon data objects exist, even if the firing behavior is not yet implemented.

**Phase C + D require substantial new code** (~235 lines) and should be scheduled for v1.1.0.

### 3.3 What Happens After Phase A+B (Registration Only)

After registration, if a player builds knife + frostaura both to Lv3:
1. `check_evolution_available()` finds the frostvortex recipe -- returns the recipe
2. `get_random_upgrades()` offers "evolution" option with frostvortex data
3. Player selects the evolution -- weapons are removed, frostvortex is added to `owned_weapons`
4. `weapon_controller._fire_weapon()` matches `data.weapon_type == "spiral"` -- **no case exists**
5. The match falls through with no action -- frostvortex is owned but does nothing

This is an improvement over the current state (evolution never offered at all), but the weapon will be silent until Phase C+D. The decision whether to ship Phase A+B alone or wait for Phase C+D is a Program Manager call.

**Recommendation**: Ship Phase A+B in v1.0.3. The registration ensures evolution recipes are discoverable. Players will see the evolution option appear, which teaches them the mechanic exists. The silent weapon is a known limitation documented in release notes. Full behavior follows in v1.1.0.

---

## 4. Sprite Asset Requirements

Three new weapon sprite PNGs are needed for the registered weapons:

| Weapon | Sprite Path | Palette Colors | Size |
|---|---|---|---|
| frostvortex | `assets/sprites/weapons/frostvortex.png` | ice_blue (0x88, 0xDD, 0xFF) + white (0xFF, 0xFF, 0xFF) | 20x20 |
| holyshockwave | `assets/sprites/weapons/holyshockwave.png` | gold (0xFF, 0xD7, 0x00) + fire_orange (0xFF, 0x45, 0x00) | 20x20 |
| thunderbeam | `assets/sprites/weapons/thunderbeam.png` | thunder_yellow (0xFF, 0xD7, 0x00) + elec_blue (0x4D, 0x80, 0xFF) | 20x20 |

These should be added to `tools/generate_sprites.py` as new generation functions. The palette colors already exist in the PALETTE dictionary.

---

## 5. Detailed Numerical Tables (R24 Update)

The following tables provide exhaustive numerical definitions for the 3 missing evolved weapons, consolidating values from evolution-expansion.md Sections 5.1/5.3/5.4 into a single registration-ready reference.

### 5.1 Frost Vortex (frostvortex) -- Complete Numerical Reference

**Attack Pattern**: 6 ice blades spiral outward from the player in an expanding vortex. Blades damage, slow, and can freeze enemies on contact. The vortex continuously expands from min to max radius, then resets to the player position and restarts. Always active (cooldown 999.0).

| Property | Value | Unit | Source | Rationale |
|---|---|---|---|---|
| `weapon_id` | `"frostvortex"` | string | evolution-expansion.md 5.1 | Unique identifier |
| `weapon_name` | `"霜刃旋涡"` | string | evolution-expansion.md 5.1 | Chinese display name |
| `weapon_type` | `"spiral"` | string | evolution-expansion.md 5.1 | New type -- expanding spiral trajectory |
| `damage` | 3.0 | HP | evolution-expansion.md 5.1 | Per blade contact. Between knife (2.0) and fireknife (3.0) -- spiral has more blades (6) so per-blade is lower |
| `cooldown` | 999.0 | seconds | evolution-expansion.md 5.1 | Always active, like orbit/aura weapons |
| `spiral_blade_count` | 6 | count | evolution-expansion.md 5.1 | More than orbit count (3-4) for visual density. 6 blades at 60-degree separation |
| `spiral_min_radius` | 20.0 | pixels | evolution-expansion.md 5.1 | Start close to player body |
| `spiral_max_radius` | 180.0 | pixels | evolution-expansion.md 5.1 | Larger than holydomain orbit (130). Covers significant screen area |
| `spiral_expand_speed` | 60.0 | px/s | evolution-expansion.md 5.1 | Time to max: 180/60 = 3.0s per cycle |
| `slow_pct` | 0.4 | fraction | evolution-expansion.md 5.1 | Same as frostknife slow. 40% movement speed reduction |
| `freeze_pct` | 0.08 | fraction | evolution-expansion.md 5.1 | Same as frostaura Lv3 freeze. 8% chance per hit |
| `projectile_size` | 5.0 | px width | evolution-expansion.md 5.1 | Blade visual size: 5x12 rectangular blade |
| `color` | `Color(0.3, 0.7, 1.0)` | Color | evolution-expansion.md 5.1 | Ice blue |
| `is_evolved` | true | bool | -- | Mark as evolution result |
| `description` | `"螺旋冰刃扩散+减速"` | string | -- | Upgrade card description |

**DPS Analysis**:
- Raw DPS: 6 blades x 3.0 dmg x ~0.33 hits/s (blade contact frequency in dense group) = ~6.0 DPS
- With slow+freeze utility: effective value ~8.0 DPS equivalent
- Synergy (Frostbite Loop): Freeze triggers accelerate blades 1.5x for 0.5s (ICD 1.0s/enemy)
- Tier: B (utility-focused, not raw DPS)

**Visual Specification**:
- Blade: Rectangle 5x12 px, Color(0.3, 0.7, 1.0)
- Trail: Fading line, Color(0.3, 0.7, 1.0, 0.2), alpha decay 0.3s
- Rotation: 4.0 rad/s (defined in evolution-expansion.md but not a WeaponData field -- set in weapon_fire.gd)

**Evolution Recipe**: knife (Lv3) + frostaura (Lv3) -> frostvortex

**Sprite Asset**: `assets/sprites/weapons/frostvortex.png`, 20x20 px, ice_blue + white

---

### 5.2 Holy Shockwave (holyshockwave) -- Complete Numerical Reference

**Attack Pattern**: Periodically emits an expanding ring of holy fire centered on the player. The ring expands from 0 to max radius over 0.3 seconds, damaging and burning all enemies it passes through. Screen shake accompanies each pulse. Unlike aura (continuous), pulse is a discrete periodic event.

| Property | Value | Unit | Source | Rationale |
|---|---|---|---|---|
| `weapon_id` | `"holyshockwave"` | string | evolution-expansion.md 5.3 | Unique identifier |
| `weapon_name` | `"圣焰冲击"` | string | evolution-expansion.md 5.3 | Chinese display name |
| `weapon_type` | `"pulse"` | string | evolution-expansion.md 5.3 | New type -- expanding damage ring |
| `damage` | 12.0 | HP | R10 buffed from 8.0 | Per pulse. Was lowest DPS evolved weapon at 8.0; 12.0 brings it to competitive level |
| `cooldown` | 2.5 | seconds | R10 reduced from 3.0 | Faster pulses increase DPS and feel more impactful |
| `pulse_max_radius` | 200.0 | pixels | evolution-expansion.md 5.3 | Larger than blizzard aura (160). Covers most of the screen center |
| `pulse_expand_time` | 0.3 | seconds | evolution-expansion.md 5.3 | Fast expansion -- 0-200px in 0.3s = 667 px/s expansion speed |
| `pulse_ring_width` | 12.0 | pixels | evolution-expansion.md 5.3 | Thickness of the expanding ring for hit detection and visual |
| `burn_dps` | 2.0 | HP/s | evolution-expansion.md 5.3 | Same as BURN_DPS in weapon_fire.gd. Consistent with firestaff burn |
| `burn_duration` | 2.0 | seconds | evolution-expansion.md 5.3 | Same as BURN_DURATION in weapon_fire.gd |
| `color` | `Color(1.0, 0.85, 0.3)` | Color | evolution-expansion.md 5.3 | Gold (center color). Edge transitions to Color(1.0, 0.4, 0.1) orange-red |
| `is_evolved` | true | bool | -- | Mark as evolution result |
| `description` | `"周期性圣焰脉冲+燃烧"` | string | -- | Upgrade card description |

**DPS Analysis**:
- Pulses per 57s wave: 57 / 2.5 = 22.8 pulses
- Raw DPS: 12.0 / 2.5 = 4.8 DPS
- Effective DPS with burn: 4.8 + (2.0 x 2.0 / 2.5) = 4.8 + 1.6 = 6.4 DPS
- With Resonance synergy (dense waves, ~3 kills/pulse): CD reduces to ~1.6s, DPS scales to ~10.0
- Guaranteed hit on all enemies in range (no targeting needed)
- Tier: B (lowest raw DPS, compensated by guaranteed AoE + Resonance scaling)

**Visual Specification**:
- Ring: Circle outline expanding 0 -> 200px radius, gold-to-orange gradient
- Ring width: 12px fixed during expansion
- Screen shake: 2.0 intensity for 0.1s per pulse
- Edge color: Color(1.0, 0.4, 0.1) orange-red

**Evolution Recipe**: holywater (Lv3) + firestaff (Lv3) -> holyshockwave

**Sprite Asset**: `assets/sprites/weapons/holyshockwave.png`, 20x20 px, gold + fire_orange

---

### 5.3 Thunder Beam (thunderbeam) -- Complete Numerical Reference

**Attack Pattern**: Fires a long-range penetrating lightning beam toward the nearest enemy. The beam damages all enemies along its path with periodic ticks and chains lightning to nearby enemies. Active for 1.0 seconds every 2.5 second cycle (40% uptime). The beam extends the full arena width in the target direction.

| Property | Value | Unit | Source | Rationale |
|---|---|---|---|---|
| `weapon_id` | `"thunderbeam"` | string | evolution-expansion.md 5.4 | Unique identifier |
| `weapon_name` | `"雷霆射线"` | string | evolution-expansion.md 5.4 | Chinese display name |
| `weapon_type` | `"beam"` | string | evolution-expansion.md 5.4 | New type -- long-range penetrating line |
| `damage` | 4.0 | HP | evolution-expansion.md 5.4 | Per tick. 3 ticks/activation = 12.0 per activation |
| `cooldown` | 2.5 | seconds | evolution-expansion.md 5.4 | Between lightning (2.0) and boomerang (1.8) |
| `beam_active_duration` | 1.0 | seconds | evolution-expansion.md 5.4 | Beam fires for 1.0s, then 1.5s pause = 40% uptime |
| `beam_tick_interval` | 0.3 | seconds | evolution-expansion.md 5.4 | 3 ticks per activation (1.0 / 0.3 = 3.33, floored to 3) |
| `beam_width` | 12.0 | pixels | evolution-expansion.md 5.4 | Collision width. Visual is 2px, collision is 12px for reliable hit detection |
| `chain_count` | 2 | count | evolution-expansion.md 5.4 | Lightning chains after beam hits. Same as thunderang chains |
| `projectile_range` | 1200.0 | pixels | evolution-expansion.md 5.4 | Effectively unlimited (arena is 2500-3000 wide). Limited to prevent off-screen computation |
| `color` | `Color(1.0, 1.0, 0.4)` | Color | evolution-expansion.md 5.4 | Electric yellow |
| `is_evolved` | true | bool | -- | Mark as evolution result |
| `description` | `"穿透闪电射线+连锁电击"` | string | -- | Upgrade card description |

**Additional Constants** (defined in weapon_fire.gd, not WeaponData):

| Constant | Value | Unit | Source | Rationale |
|---|---|---|---|---|
| `THUNDERBEAM_CHAIN_DAMAGE` | 6.0 | HP | evolution-expansion.md 5.4 | Chain lightning damage (separate from beam tick) |
| `THUNDERBEAM_CHAIN_RANGE` | 120.0 | pixels | evolution-expansion.md 5.4 | Chain targeting range from hit enemy |
| `THUNDERBEAM_VISUAL_WIDTH` | 2.0 | pixels | evolution-expansion.md 5.4 | Visual beam line width (vs 12px collision) |
| `THUNDERBEAM_SPARK_COLOR` | `Color(1.0, 1.0, 1.0)` | Color | evolution-expansion.md 5.4 | White sparks along beam |

**DPS Analysis**:
- Beam active 1.0s every 2.5s cycle = 40% uptime
- Tick damage: 4.0 HP every 0.3s = 3 ticks per activation = 12.0 HP per activation
- Single-target DPS: 12.0 / 2.5 = 4.8 DPS
- With chain lightning (2 chains, 6.0 each): +12.0 / 2.5 = +4.8 DPS against groups
- Total multi-target DPS: ~9.6 DPS
- Highest multi-target DPS of the 3 new weapons, but requires enemies lined up in beam direction
- Tier: B (positional dependency limits practical DPS)

**Synergy (Overcharge)**:
- While beam active: +15% movement speed
- Encourages strafing to sweep beam across enemies
- Speed bonus matches speedboots passive value

**Visual Specification**:
- Beam line: 2px visual (12px collision), Color(1.0, 1.0, 0.4) electric yellow
- Sparks: 2x2 ColorRect, Color(1.0, 1.0, 1.0) white, random flicker along beam
- Chain lightning: Jagged line, Color(0.5, 0.8, 1.0), same as existing lightning effect

**Evolution Recipe**: lightning (Lv3) + knife (Lv3) -> thunderbeam

**Sprite Asset**: `assets/sprites/weapons/thunderbeam.png`, 20x20 px, thunder_yellow + elec_blue

---

### 5.4 DPS Comparison of 3 New Weapons

| Weapon | Raw DPS | Effective DPS | Utility | Best Scenario |
|---|---|---|---|---|
| frostvortex (spiral) | ~6.0 | ~8.0 | Slow + Freeze | Dense clustered enemies near player |
| holyshockwave (pulse) | 4.8 | 6.4 + burn | Guaranteed AoE + Burn | Dense waves (Resonance scales to ~10.0) |
| thunderbeam (beam) | 4.8 (single) | 9.6 (multi) | Long range + Chain | Enemies lined up in one direction |

**Balance assessment**: All 3 weapons fall in the B-tier range (6.4-9.6 effective DPS), compared to A-tier existing weapons (fireknife 20.0, thunderang 28.5). This is intentional -- the 3 new weapons provide unique utility (slow/freeze, guaranteed AoE, long-range penetration) rather than raw DPS. They are situationally powerful rather than universally dominant.

---

### 5.5 WeaponData.gd Fields Verification

The following fields must exist in `scripts/data/weapon_data.gd` for these registrations to work:

| Field | Type | Default | Used By | Status |
|---|---|---|---|---|
| `spiral_blade_count` | int | 6 | frostvortex | Needs verification |
| `spiral_min_radius` | float | 20.0 | frostvortex | Needs verification |
| `spiral_max_radius` | float | 180.0 | frostvortex | Needs verification |
| `spiral_expand_speed` | float | 60.0 | frostvortex | Needs verification |
| `pulse_max_radius` | float | 200.0 | holyshockwave | Needs verification |
| `pulse_expand_time` | float | 0.3 | holyshockwave | Needs verification |
| `pulse_ring_width` | float | 12.0 | holyshockwave | Needs verification |
| `beam_active_duration` | float | 1.0 | thunderbeam | Needs verification |
| `beam_tick_interval` | float | 0.3 | thunderbeam | Needs verification |
| `beam_width` | float | 12.0 | thunderbeam | Needs verification |
| `orbit_fire_rate` | float | 0.0 | sentineltotem (already exists) | Confirmed in weapon_data.gd line 23 |
| `slow_pct` | float | 0.0 | frostvortex (already exists) | Confirmed in weapon_data.gd line 38 |
| `freeze_pct` | float | 0.0 | frostvortex (already exists) | Confirmed in weapon_data.gd line 39 |
| `burn_dps` | float | 0.0 | holyshockwave (already exists) | Confirmed in weapon_data.gd line 34 |
| `burn_duration` | float | 0.0 | holyshockwave (already exists) | Confirmed in weapon_data.gd line 35 |
| `chain_count` | int | 0 | thunderbeam (already exists) | Confirmed in weapon_data.gd line 26 |

**Fields needing addition**: 10 new fields (spiral: 4, pulse: 3, beam: 3). This matches the evolution-expansion.md Section 6 specification. Phase B of registration adds these ~13 lines to weapon_data.gd.

---

## 6. Decision Record

| Decision | Why | Alternative Considered |
|---|---|---|
| Phase A+B now, C+D later | Registration is low-risk, adds recipe discovery, and unblocks future work. Full behavior requires 3 new scripts + 95 lines in weapon_fire.gd | Wait for full implementation (delays recipe discovery for another version) |
| Register all 3 simultaneously | All 3 have complete specs in evolution-expansion.md. Partial registration would be inconsistent | Register only the most impactful one (inconsistent player experience) |
| No fallback behavior for unhandled types | Adding a "warning" log or placeholder attack would be misleading. Silent match fallthrough is the cleanest approach | Show a "coming soon" toast (immersion-breaking) |
| New sprites at 20x20 (same as other evolved weapons) | Consistent with fireknife/frostknife/thunderang sprite sizes | 32x32 (too large for a weapon slot) |
| R24: Detailed numerical tables consolidated from evolution-expansion.md | Registration requires a single source of truth. Previously values were scattered across evolution-expansion.md Sections 5.1/5.3/5.4 with no consolidated reference for the Programmer Agent to implement from | Keep values only in evolution-expansion.md (requires cross-referencing 3 sections during implementation) |
| R24: Added DPS comparison table | Programmer and QA Agents need to verify balance. A consolidated DPS table makes it possible to write balance assertions in tests | No DPS comparison (each weapon's DPS only in its own section, hard to compare) |

---

## 7. Test Cases

| Case | Verification | Priority |
|---|---|---|
| frostvortex recipe recognized | `weapon_registry.check_evolution_available({"knife": 3, "frostaura": 3})` returns frostvortex | P1 |
| holyshockwave recipe recognized | Same pattern for holywater + firestaff | P1 |
| thunderbeam recipe recognized | Same pattern for lightning + knife | P1 |
| UpgradePool returns frostvortex data | `UpgradePool._weapons["frostvortex"]` has correct damage/cooldown/type | P1 |
| No duplicate registration | Each weapon registered exactly once, no overwrite issues | P2 |
| Existing 9 evolutions unaffected | All existing evolution recipes still work | P0 |
| EVOLUTION_RECIPES count is 12 | Array size is 12 (9 old + 3 new) | P2 |
