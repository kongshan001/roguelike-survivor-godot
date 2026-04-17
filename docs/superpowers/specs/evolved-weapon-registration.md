# Evolved Weapon Registration Spec: frostvortex, holyshockwave, thunderbeam

**Author**: Designer Agent
**Date**: 2026-04-17
**Round**: R23
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

## 5. Decision Record

| Decision | Why | Alternative Considered |
|---|---|---|
| Phase A+B now, C+D later | Registration is low-risk, adds recipe discovery, and unblocks future work. Full behavior requires 3 new scripts + 95 lines in weapon_fire.gd | Wait for full implementation (delays recipe discovery for another version) |
| Register all 3 simultaneously | All 3 have complete specs in evolution-expansion.md. Partial registration would be inconsistent | Register only the most impactful one (inconsistent player experience) |
| No fallback behavior for unhandled types | Adding a "warning" log or placeholder attack would be misleading. Silent match fallthrough is the cleanest approach | Show a "coming soon" toast (immersion-breaking) |
| New sprites at 20x20 (same as other evolved weapons) | Consistent with fireknife/frostknife/thunderang sprite sizes | 32x32 (too large for a weapon slot) |

---

## 6. Test Cases

| Case | Verification | Priority |
|---|---|---|
| frostvortex recipe recognized | `weapon_registry.check_evolution_available({"knife": 3, "frostaura": 3})` returns frostvortex | P1 |
| holyshockwave recipe recognized | Same pattern for holywater + firestaff | P1 |
| thunderbeam recipe recognized | Same pattern for lightning + knife | P1 |
| UpgradePool returns frostvortex data | `UpgradePool._weapons["frostvortex"]` has correct damage/cooldown/type | P1 |
| No duplicate registration | Each weapon registered exactly once, no overwrite issues | P2 |
| Existing 9 evolutions unaffected | All existing evolution recipes still work | P0 |
| EVOLUTION_RECIPES count is 12 | Array size is 12 (9 old + 3 new) | P2 |
