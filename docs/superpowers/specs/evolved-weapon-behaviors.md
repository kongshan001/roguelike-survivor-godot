# Evolved Weapon Firing Behaviors -- Phase C Design

**Author**: Designer Agent
**Date**: 2026-04-17
**Round**: R26
**Status**: Design Spec
**Priority**: P2 LOW (v1.1.0 target)
**Context**: Phase A+B (registration) for frostvortex/holyshockwave/thunderbeam is complete or pending in v1.0.3. The weapons are registered in upgrade_pool.gd and weapon_registry.gd, and their WeaponData fields exist in weapon_data.gd. However, weapon_controller.gd has no match cases for "spiral", "pulse", or "beam" types, so the weapons are owned but silent. This spec defines the firing behaviors needed for Phase C (weapon_controller + weapon_fire logic) and Phase D (new script files).

---

## 1. Design Overview

Three new weapon behaviors must be implemented:

| Weapon | Type | Core Behavior | Reference |
|---|---|---|---|
| frostvortex | spiral | 6 ice blades spiral outward from player, always active | Holocure spiral weapons |
| holyshockwave | pulse | Periodic expanding damage ring from player center | Vampire Survivors Laurel |
| thunderbeam | beam | Long-range penetrating laser toward nearest enemy | Magic Survival beam |

Each requires:
1. A new match case in `weapon_controller.gd` `_fire_weapon()`
2. A new function in `weapon_fire.gd` (or a new module file for spiral/beam which are complex)
3. State management in `weapon_controller.gd` for persistent instances

---

## 2. Frost Vortex -- Spiral Type

### 2.1 Attack Pattern Description

Six ice blades spiral outward from the player in an expanding vortex pattern. The blades are evenly spaced (60 degrees apart) and continuously rotate around the player while expanding from min radius to max radius. When max radius is reached, the blades converge back to the player and restart. The vortex is always active (cooldown 999.0).

**Lifecycle**: Create once -> update position/rotation per frame -> no destroy/recreate cycle.

### 2.2 Implementation Architecture

Because the spiral behavior is complex (expanding radius, continuous rotation, per-blade collision), it is best implemented as a dedicated script similar to `spin_blade.gd` (used for orbit weapons).

**New file**: `scripts/weapons/spiral_blade.gd` (~55 lines)

The script extends Node2D and manages 6 child ColorRect blades. It handles:
- Radius expansion from min to max
- Rotation at constant angular speed
- Per-blade collision detection via Area2D
- Reset cycle (max -> min radius)
- Slow and freeze application on hit

### 2.3 weapon_controller.gd Changes

```
# New state variable:
var _spiral_instance: Node2D = null

# New match case in _fire_weapon():
"spiral":
    _spiral_instance = wf.update_spiral(weapon_id, data, player, dmg_bonus, _spiral_instance)
```

### 2.4 weapon_fire.gd Changes

New function:

```
func update_spiral(weapon_id: String, data: WeaponData, player: CharacterBody2D, dmg_bonus: float, spiral_instance: Node2D) -> Node2D:
    # If instance exists and is valid, update position only.
    # If not, create a new SpiralBlade node and set it up.
    # Returns the spiral instance for storage in _spiral_instance.
    # ~25 lines
```

### 2.5 spiral_blade.gd Behavior Specification

#### Node Structure

```
SpiralBlade (Node2D)
  +-- Area2D (collision detection, Layer3=Projectiles)
  |    +-- CollisionShape2D (circle, radius 5.0)
  +-- ColorRect x 6 (blades, 5x12 px each)
```

#### Constants (defined in spiral_blade.gd)

| Constant | Value | Purpose |
|---|---|---|
| BLADE_WIDTH | 5.0 | Visual blade width |
| BLADE_HEIGHT | 12.0 | Visual blade height |
| ROTATION_SPEED | 4.0 | Radians per second (from evolution-expansion.md) |
| HIT_COOLDOWN | 0.5 | Seconds between hits on the same enemy per blade |

#### Per-Frame Update Logic

```
func _process(delta):
    global_position = _player_pos  # Follow player

    _angle += ROTATION_SPEED * delta

    if _current_radius < data.spiral_max_radius:
        _current_radius += data.spiral_expand_speed * delta
    else:
        _current_radius = data.spiral_min_radius  # Reset cycle

    for i in range(data.spiral_blade_count):
        var blade_angle: float = _angle + (TAU * i / data.spiral_blade_count)
        blades[i].position = Vector2(cos(blade_angle), sin(blade_angle)) * _current_radius
```

#### Hit Detection

The Area2D body_entered signal triggers damage. Each blade has an independent hit cooldown per enemy to prevent rapid re-hitting:

```
# Per enemy, per blade: track last hit time
# Dictionary: enemy RID -> last_hit_time
# If current_time - last_hit_time < HIT_COOLDOWN: skip
```

#### Status Effects

On hit, apply slow and freeze:

```
if data.slow_pct > 0 and enemy.has_method("apply_slow"):
    enemy.apply_slow(data.slow_pct)
if data.freeze_pct > 0 and enemy.has_method("apply_freeze"):
    enemy.apply_freeze(data.freeze_pct * delta)  # delta-normalized like aura
```

#### Synergy: Frostbite Loop

When a blade freeze triggers, all blades accelerate briefly:

```
# In _process, after normal expand_speed:
if _accel_timer > 0:
    _current_radius += data.spiral_expand_speed * 0.5 * delta  # +50% speed
    _accel_timer -= delta

# On freeze event:
_accel_timer = 0.5  # 0.5 second burst
```

ICD per enemy: 1.0 second (tracked in a Dictionary keyed by enemy RID).

### 2.6 Numerical Summary

| Parameter | Value | Source |
|---|---|---|
| blade_count | 6 | WeaponData.spiral_blade_count |
| min_radius | 20.0 px | WeaponData.spiral_min_radius |
| max_radius | 180.0 px | WeaponData.spiral_max_radius |
| expand_speed | 60.0 px/s | WeaponData.spiral_expand_speed |
| rotation_speed | 4.0 rad/s | Hard-coded in spiral_blade.gd |
| damage | 3.0 HP per hit | WeaponData.damage |
| hit_cooldown | 0.5 s per enemy per blade | Hard-coded in spiral_blade.gd |
| slow_pct | 0.4 | WeaponData.slow_pct |
| freeze_pct | 0.08 | WeaponData.freeze_pct |
| blade_visual | 5x12 px, Color(0.3, 0.7, 1.0) | WeaponData.color, WeaponData.projectile_size |
| cycle_time | 180/60 = 3.0 seconds | Calculated from max_radius / expand_speed |
| synergy_accel_mul | 1.5x | evolution-expansion.md 5.1 |
| synergy_accel_dur | 0.5 s | evolution-expansion.md 5.1 |
| synergy_icd | 1.0 s per enemy | evolution-expansion.md 5.1 |

### 2.7 DPS Analysis

- In dense enemy cluster: ~6 blades x 3.0 dmg x 0.33 hits/s/blade (contact frequency) = ~6.0 DPS
- Slow utility: 40% movement speed reduction on all enemies near player
- Freeze utility: 8% chance per hit, can cascade via Frostbite Loop synergy
- Effective value: ~8.0 DPS equivalent (utility-adjusted)

---

## 3. Holy Shockwave -- Pulse Type

### 3.1 Attack Pattern Description

Periodically emits an expanding ring of holy fire centered on the player. The ring grows from radius 0 to max_radius over 0.3 seconds, damaging and burning all enemies it passes through. The pulse is a discrete periodic event (every 2.5 seconds), unlike aura which is continuous.

**Lifecycle**: Timer-based. Each pulse creates a temporary expanding ring that auto-destroys after expansion completes.

### 3.2 Implementation Architecture

The pulse behavior is simpler than spiral because it is a discrete event (fire and forget). It can be implemented entirely within `weapon_fire.gd` as a new function, using a child ColorRect + Area2D that expands and then frees itself.

**No new script file needed** for the pulse ring if implemented as a lightweight tween-driven effect. However, for cleanliness and to avoid weapon_fire.gd exceeding 500 lines, a small module is recommended.

**New file**: `scripts/weapons/pulse_ring.gd` (~45 lines) -- lightweight expanding ring effect.

### 3.3 weapon_controller.gd Changes

```
# No new state variable needed (pulse is fire-and-forget)

# New match case in _fire_weapon():
"pulse":
    wf.fire_pulse(data, player, dmg_bonus)
```

### 3.4 weapon_fire.gd Changes

New function:

```
func fire_pulse(data: WeaponData, player: CharacterBody2D, dmg_bonus: float) -> void:
    # Create pulse ring, set up expansion tween, apply damage to enemies in ring path
    # ~30 lines
```

### 3.5 pulse_ring.gd Behavior Specification

#### Node Structure

```
PulseRing (Node2D)
  +-- ColorRect (ring visual, hollow circle approximation)
  +-- Area2D (collision, monitors body entry during expansion)
  +-- CollisionShape2D (circle, radius grows with expansion)
```

#### Expansion Logic

```
# Created at player position
# Tween: scale from 0 to max_radius over expand_time
# At each frame during expansion, check Area2D for overlapping enemies
# Apply damage + burn to each enemy once (track hit set)
# After expand_time: queue_free()
```

#### Visual

The ring is drawn as a hollow circle (ColorRect with inner transparency). For pixel art simplicity, use a series of small ColorRect segments around the circumference:

```
# Approximation: 16 segments forming a circle outline
# Each segment: 2x2 ColorRect at angle i/16 * TAU
# Radius grows via tween, segments reposition each frame
```

Alternatively, a single large ColorRect with circular masking can be used if Godot's StyleBoxFlat supports it. The simpler approach is preferred.

#### Ring Color

- Center color: Color(1.0, 0.85, 0.3) -- gold
- Edge color: Color(1.0, 0.4, 0.1) -- orange-red
- Transition: lerp from center to edge based on current_radius / max_radius

#### Screen Shake

Each pulse triggers a screen shake:

```
# In fire_pulse(), after creating the ring:
var pm: Node = _get_pm(player)
if pm and pm.has_node("../Camera2D"):
    var camera: Camera2D = pm.get_node("../Camera2D")
    camera.apply_shake(2.0, 0.1)  # intensity 2.0, duration 0.1s
```

If the camera shake API is not available, use the existing weapon_effects.gd pattern.

### 3.6 Numerical Summary

| Parameter | Value | Source |
|---|---|---|
| damage | 12.0 HP per pulse | WeaponData.damage (R10 buffed) |
| cooldown | 2.5 s | WeaponData.cooldown (R10 reduced) |
| max_radius | 200.0 px | WeaponData.pulse_max_radius |
| expand_time | 0.3 s | WeaponData.pulse_expand_time |
| ring_width | 12.0 px | WeaponData.pulse_ring_width |
| expansion_speed | 667 px/s | Calculated: 200 / 0.3 |
| burn_dps | 2.0 HP/s | WeaponData.burn_dps |
| burn_duration | 2.0 s | WeaponData.burn_duration |
| color_center | Color(1.0, 0.85, 0.3) | WeaponData.color |
| color_edge | Color(1.0, 0.4, 0.1) | evolution-expansion.md 5.3 |
| screen_shake_intensity | 2.0 | evolution-expansion.md 5.3 |
| screen_shake_duration | 0.1 s | evolution-expansion.md 5.3 |
| synergy_cd_reduction | 0.3 s per kill | evolution-expansion.md 5.3 |
| synergy_min_cooldown | 1.5 s | evolution-expansion.md 5.3 |

### 3.7 DPS Analysis

- Pulses per wave (57s): 57 / 2.5 = 22.8 pulses
- Raw DPS: 12.0 / 2.5 = 4.8 DPS
- With burn: 4.8 + (2.0 x 2.0 / 2.5) = 6.4 DPS
- With Resonance synergy (dense waves): cooldown reduces to ~1.5s, DPS scales to ~10.0
- Guaranteed hit on all enemies in range (no targeting needed)

### 3.8 Synergy: Resonance

Each enemy killed by holyshockwave reduces pulse cooldown by 0.3 seconds. Implementation:

```
# In weapon_controller.gd, when enemy dies from holyshockwave damage:
# Reduce _weapon_timers["holyshockwave"] by 0.3
# Clamp to minimum 1.5 seconds remaining

# Detection: enemy.take_damage passes weapon_id.
# In enemy.die(), check if killing_weapon == "holyshockwave".
# If so, emit signal or call back to weapon_controller.
```

This requires coordination with enemy.gd's kill tracking. The simplest approach is to check the weapon_id in the death callback, similar to how mastery kill attribution works.

---

## 4. Thunder Beam -- Beam Type

### 4.1 Attack Pattern Description

Fires a long-range penetrating lightning beam toward the nearest enemy. The beam is active for 1.0 second every 2.5 second cycle (40% uptime). During the active phase, the beam damages all enemies along its path every 0.3 seconds (3 ticks per activation). After the beam hits, chain lightning strikes 2 additional nearby enemies.

**Lifecycle**: Timer-based. Each cycle creates a beam line that persists for beam_active_duration, then is destroyed.

### 4.2 Implementation Architecture

The beam requires a persistent line entity with periodic tick damage. This is more complex than projectile but simpler than spiral.

**New file**: `scripts/weapons/beam_line.gd` (~50 lines) -- persistent beam line with tick timer.

### 4.3 weapon_controller.gd Changes

```
# No new persistent state variable (beam is created and self-manages)

# But we need to track whether beam is currently active to prevent stacking:
# Use _weapon_timers with a special key

# New match case in _fire_weapon():
"beam":
    wf.fire_beam(data, player, dmg_bonus)
```

### 4.4 weapon_fire.gd Changes

New function:

```
func fire_beam(data: WeaponData, player: CharacterBody2D, dmg_bonus: float) -> void:
    # Find nearest enemy, calculate direction
    # Create beam line from player in that direction
    # Beam line handles its own tick damage and lifetime
    # After beam expires, apply chain lightning
    # ~35 lines
```

### 4.5 beam_line.gd Behavior Specification

#### Node Structure

```
BeamLine (Node2D)
  +-- ColorRect (visual beam line, 2px wide x range long)
  +-- Area2D (collision detection, Layer3=Projectiles)
  |    +-- CollisionShape2D (rectangle, 12px wide x range long)
  +-- Timer (tick_timer, 0.3s interval, loops)
```

#### Direction Calculation

```
# In fire_beam():
var enemies := _get_enemies(player, data.projectile_range)
if enemies.is_empty():
    return
var target: Node2D = enemies[0]  # Nearest enemy
var direction: Vector2 = (target.global_position - player.global_position).normalized()
```

#### Beam Creation

```
# Position at player
# Rotation toward direction
# Length = data.projectile_range (1200.0 px)
# Visual: ColorRect 2px wide, data.color
# Collision: 12px wide (data.beam_width)
```

#### Tick Damage Logic

```
# Timer fires every beam_tick_interval (0.3s)
# On tick: scan Area2D.get_overlapping_bodies()
# For each enemy in overlap:
#   - Apply damage (data.damage * dmg_bonus)
#   - Track in hit_set (prevent re-hit same enemy same tick)
# After beam_active_duration: apply chain lightning, then queue_free()
```

#### Chain Lightning

After the beam expires (beam_active_duration ends):

```
# Find enemies hit by the beam
# Select up to chain_count (2) enemies near the last hit target
# For each chain target:
#   - Apply chain_damage (6.0 * dmg_bonus)
#   - Create lightning visual effect (reuse weapon_effects.gd create_lightning_effect)
# Chain range: 120.0 px from hit enemy
```

#### Visual Sparks

During beam active phase, spawn random spark particles along the beam:

```
# Every 0.1s, spawn a 2x2 ColorRect at random position along beam
# Color: Color(1.0, 1.0, 1.0) white
# Lifetime: 0.15s, fade out
# This creates a flickering electric effect
```

### 4.6 Numerical Summary

| Parameter | Value | Source |
|---|---|---|
| damage (per tick) | 4.0 HP | WeaponData.damage |
| cooldown | 2.5 s | WeaponData.cooldown |
| beam_active_duration | 1.0 s | WeaponData.beam_active_duration |
| beam_tick_interval | 0.3 s | WeaponData.beam_tick_interval |
| ticks_per_activation | 3 (1.0 / 0.3 = 3.33, floored) | Calculated |
| beam_width (collision) | 12.0 px | WeaponData.beam_width |
| beam_visual_width | 2.0 px | Hard-coded in beam_line.gd |
| projectile_range | 1200.0 px | WeaponData.projectile_range |
| chain_count | 2 | WeaponData.chain_count |
| chain_damage | 6.0 HP | THUNDERBEAM_CHAIN_DAMAGE (weapon_fire.gd const) |
| chain_range | 120.0 px | THUNDERBEAM_CHAIN_RANGE (weapon_fire.gd const) |
| color | Color(1.0, 1.0, 0.4) | WeaponData.color |
| spark_color | Color(1.0, 1.0, 1.0) | THUNDERBEAM_SPARK_COLOR |
| spark_interval | 0.1 s | Hard-coded in beam_line.gd |
| spark_lifetime | 0.15 s | Hard-coded in beam_line.gd |
| uptime | 40% (1.0s on, 1.5s off) | Calculated |
| synergy_speed_bonus | +15% movement speed | evolution-expansion.md 5.4 |
| synergy_only_when_active | true | evolution-expansion.md 5.4 |

### 4.7 DPS Analysis

- Single target: 4.0 x 3 ticks / 2.5s = 4.8 DPS
- With chains (2 x 6.0): +4.8 DPS against groups = 9.6 multi-target DPS
- Positional dependency: enemies must be in a line for full beam DPS
- Highest multi-target DPS of the 3 new weapons, but requires favorable positioning

### 4.8 Synergy: Overcharge

While beam is active, player gains +15% movement speed:

```
# In beam_line.gd _ready():
# Apply speed buff to player
# In queue_free() / cleanup:
# Remove speed buff

# Implementation:
# player.speed_bonus += 0.15 on beam start
# player.speed_bonus -= 0.15 on beam end
```

Requires `speed_bonus` property on player (may need to check if it exists). If not, add a simple additive modifier.

---

## 5. Implementation Line Estimates

| Phase | Content | New Lines | Modified Lines | Total Changed |
|---|---|---|---|---|
| Phase C | weapon_controller.gd match cases + state vars | ~12 | ~5 | ~17 |
| Phase C | weapon_fire.gd: update_spiral + fire_pulse + fire_beam | ~90 | ~0 | ~90 |
| Phase D | spiral_blade.gd (new file) | ~55 | ~0 | ~55 |
| Phase D | pulse_ring.gd (new file) | ~45 | ~0 | ~45 |
| Phase D | beam_line.gd (new file) | ~50 | ~0 | ~50 |
| **Total** | | **~252** | **~5** | **~257** |

Plus testing: ~40 lines of new tests per weapon = ~120 lines.

### weapon_fire.gd Line Budget

| Current | ~366 lines |
|---|---|
| New functions (update_spiral + fire_pulse + fire_beam + chain helpers) | ~90 lines |
| New constants (3 beam constants) | ~3 lines |
| **Total after** | **~459 lines** |

This is within the 500-line limit with 41 lines of headroom. If additional helper functions are needed, consider extracting to module files (like weapon_boomerang_fire.gd pattern).

---

## 6. Integration Checklist

### Phase C: weapon_controller.gd + weapon_fire.gd

- [ ] Add `_spiral_instance: Node2D = null` to weapon_controller.gd member variables
- [ ] Add 3 match cases in `_fire_weapon()`:
  - `"spiral": _spiral_instance = wf.update_spiral(...)`
  - `"pulse": wf.fire_pulse(...)`
  - `"beam": wf.fire_beam(...)`
- [ ] Add `update_spiral()` in weapon_fire.gd (~25 lines)
- [ ] Add `fire_pulse()` in weapon_fire.gd (~30 lines)
- [ ] Add `fire_beam()` in weapon_fire.gd (~35 lines)
- [ ] Add beam constants (THUNDERBEAM_CHAIN_DAMAGE, THUNDERBEAM_CHAIN_RANGE, THUNDERBEAM_SPARK_COLOR)
- [ ] Handle spiral in `_process()` for position tracking (like orbit)

### Phase D: New Script Files

- [ ] Create `scripts/weapons/spiral_blade.gd` (~55 lines)
- [ ] Create `scripts/weapons/pulse_ring.gd` (~45 lines)
- [ ] Create `scripts/weapons/beam_line.gd` (~50 lines)
- [ ] Add 3 new sprite PNGs via `tools/generate_sprites.py` update

### Phase E: Synergy Integration

- [ ] Frostbite Loop: freeze event -> blade acceleration (in spiral_blade.gd)
- [ ] Resonance: holyshockwave kill -> cooldown reduction (in weapon_controller.gd or enemy death callback)
- [ ] Overcharge: beam active -> speed bonus (in beam_line.gd + player.gd)

---

## 7. Decision Record

| Decision | Why | Alternative Considered |
|---|---|---|
| Dedicated script per weapon type (spiral_blade/pulse_ring/beam_line) | Each behavior has unique lifecycle and state management. Mixing them into weapon_fire.gd would push it past 500 lines | All in weapon_fire.gd (simpler file management but violates line limit) |
| spiral uses persistent instance (like orbit) | Spiral is always active and follows player. Creating/destroying each frame would be wasteful | Fire-and-forget with timer recreation (wasteful, flickering) |
| pulse uses fire-and-forget (like projectile) | Pulse is a discrete event with defined lifetime. No persistent state needed | Persistent pulse instance (unnecessary complexity) |
| beam uses self-managing node (like boomerang) | Beam has internal tick timer and auto-destroys. Simpler than managing tick state in weapon_controller | weapon_controller manages beam ticks (couples beam logic to controller) |
| Hit cooldown per blade per enemy (spiral) | Without it, a blade sweeping through a cluster would deal damage every frame (3.0 x 60 = 180 DPS). 0.5s ICD gives ~6 DPS per blade | No ICD (broken DPS), global ICD per enemy (kills multi-blade value) |
| Chain lightning after beam expires (not during) | Chains on expiration keeps the beam phase focused on direct damage, and the chain phase creates a satisfying "explosion" at the end | Chains during beam ticks (noisy, hard to balance, overlaps with tick damage) |
| Resonance synergy via death callback | Enemy already tracks killing_weapon for mastery. Adding a weapon-specific cooldown reduction is a minimal extension | Signal-based approach (adds signal overhead, enemy already has the data) |
| Frostbite Loop uses accel timer in spiral_blade.gd | Self-contained within the spiral script. No external coordination needed | Event system through SynergyManager (overkill for a simple speed boost) |

---

## 8. Balance Assessment

### 8.1 Three-Weapon DPS Comparison

| Weapon | Raw DPS | Effective DPS | Utility | Best Scenario | Tier |
|---|---|---|---|---|---|
| frostvortex (spiral) | ~6.0 | ~8.0 | Slow + Freeze + Frostbite Loop | Dense clustered enemies near player | B |
| holyshockwave (pulse) | 4.8 | 6.4 + burn (10.0 w/ Resonance) | Guaranteed AoE + Burn + Resonance scaling | Dense waves (Wave 4-5) | B |
| thunderbeam (beam) | 4.8 (single) | 9.6 (multi) | Long range + Chain + Overcharge speed | Enemies lined up in one direction | B |

### 8.2 Comparison with Existing Evolved Weapons

| Weapon | DPS | Tier | Role |
|---|---|---|---|
| fireknife | 20.0 | A | High DPS projectile |
| thunderang | 28.5 | A | Multi-target DPS |
| blazerang | 18.0 | A | Chasing DPS |
| holydomain | 12.0 | B | Area control |
| blizzard | 10.0 + lightning | B | Slow + AoE |
| thunderholywater | 11.25 | B | Orbit + chain |
| flamebible | 8.0 + burn | B | Orbit + burn |
| frostknife | 12.0 + slow | B | Projectile + control |
| sentineltotem | 6.25 + vuln | B | Support DPS |
| **frostvortex** | **~8.0** | **B** | **Crowd control** |
| **holyshockwave** | **6.4-10.0** | **B** | **Guaranteed AoE** |
| **thunderbeam** | **4.8-9.6** | **B** | **Long-range DPS** |

**Conclusion**: All 3 new weapons sit in the B-tier range. They are utility-focused rather than raw DPS monsters. This is intentional and balanced. Players choosing these evolutions trade DPS for unique capabilities (slow/freeze, guaranteed AoE, long-range penetration).

---

## 9. Test Cases

| Case | Verification | Priority |
|---|---|---|
| spiral_blade creates 6 blades | Blade count matches WeaponData.spiral_blade_count | P1 |
| spiral follows player position | spiral_blade.global_position == player.global_position | P1 |
| spiral radius expands and resets | Radius goes min -> max -> min cyclically | P1 |
| spiral applies slow on hit | Enemy speed reduced by slow_pct | P2 |
| spiral applies freeze on hit | 8% chance, Frostbite Loop accelerates blades | P2 |
| pulse ring expands from 0 to max | Tween scales ring from 0 to 200px in 0.3s | P1 |
| pulse damages all enemies in ring path | All enemies between 0 and 200px radius take 12.0 damage | P0 |
| pulse applies burn | Enemies hit have burn_dps=2.0 for 2.0 seconds | P1 |
| pulse triggers screen shake | Camera shake with intensity 2.0, duration 0.1s | P2 |
| beam fires toward nearest enemy | Beam direction points at closest enemy in range | P1 |
| beam ticks 3 times per activation | 3 ticks in 1.0s at 0.3s intervals | P1 |
| beam chain lightning hits 2 enemies | After beam expires, 2 nearby enemies take 6.0 chain damage | P1 |
| beam self-destructs after active_duration | queue_free() called after 1.0s | P1 |
| Overcharge speed bonus applied during beam | player.speed_bonus += 0.15 while beam active | P2 |
| Resonance cooldown reduction | holyshockwave kill reduces next cooldown by 0.3s | P2 |
| No damage when no enemies in range | beam/pulse do nothing if no enemies found | P1 |
| weapon_fire.gd stays under 500 lines | Line count verification after all additions | P0 |
| weapon_controller.gd stays under 500 lines | Line count verification | P0 |
