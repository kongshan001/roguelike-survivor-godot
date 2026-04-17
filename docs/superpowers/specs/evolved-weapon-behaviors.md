# Evolved Weapon Firing Behaviors -- Phase C Design

**Author**: Designer Agent
**Date**: 2026-04-17
**Round**: R28 (updated from R26/R27)
**Status**: Design Spec -- Firing Parameters Finalized
**Priority**: P1 HIGH (v1.1.0 Phase C+D target)
**Context**: Phase A+B (registration) for frostvortex/holyshockwave/thunderbeam is complete or pending in v1.0.3. The weapons are registered in upgrade_pool.gd and weapon_registry.gd, and their WeaponData fields exist in weapon_data.gd. However, weapon_controller.gd has no match cases for "spiral", "pulse", or "beam" types, so the weapons are owned but silent. This spec defines the firing behaviors needed for Phase C (weapon_controller + weapon_fire logic) and Phase D (new script files), plus Phase E (synergy integration).

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
4. Synergy integration in Phase E

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

```gdscript
# New state variable:
var _spiral_instance: Node2D = null

# New match case in _fire_weapon():
"spiral":
    _spiral_instance = wf.update_spiral(weapon_id, data, player, dmg_bonus, _spiral_instance)
```

### 2.4 weapon_fire.gd Changes

New function:

```gdscript
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

```gdscript
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

```gdscript
# Per enemy, per blade: track last hit time
# Dictionary: enemy RID -> last_hit_time
# If current_time - last_hit_time < HIT_COOLDOWN: skip
```

#### Status Effects

On hit, apply slow and freeze:

```gdscript
if data.slow_pct > 0 and enemy.has_method("apply_slow"):
    enemy.apply_slow(data.slow_pct)
if data.freeze_pct > 0 and enemy.has_method("apply_freeze"):
    enemy.apply_freeze(data.freeze_pct * delta)  # delta-normalized like aura
```

**Integration note**: The existing `enemy.apply_slow()` and `enemy.apply_freeze()` methods already exist in `scripts/enemy.gd`. The spiral_blade.gd script should call them directly, following the same pattern as `update_aura()` in weapon_fire.gd (lines 331-334). The freeze duration is delta-normalized to convert the per-second probability into a per-frame probability, matching the established convention.

#### Keen Eye Crit Integration

The spiral should support the Ranger's Keen Eye passive (guaranteed crit every 5 hits), consistent with how other weapon types handle it:

```gdscript
# In hit callback, before applying damage:
var keen_crit: bool = false
if _controller and _controller.has_method("notify_weapon_hit"):
    keen_crit = _controller.notify_weapon_hit(_player)
var hit_damage: float = data.damage * dmg_bonus
if keen_crit:
    hit_damage *= _player.crit_damage_mul
enemy.take_damage(hit_damage, weapon_id, keen_crit)
```

This requires passing a controller reference and player reference to spiral_blade.gd during setup.

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

Periodically emits an expanding ring of holy fire centered on the player. The ring grows from radius 0 to max_radius over expand_time seconds, damaging and burning all enemies it passes through. The pulse is a discrete periodic event (every cooldown seconds), unlike aura which is continuous.

**Lifecycle**: Timer-based (weapon_controller timer). Each pulse creates a temporary expanding ring that auto-destroys after expansion completes.

### 3.2 Implementation Architecture

The pulse behavior is simpler than spiral because it is a discrete event (fire and forget). It can be implemented entirely within `weapon_fire.gd` as a new function, using a child ColorRect + Area2D that expands and then frees itself.

**New file**: `scripts/weapons/pulse_ring.gd` (~45 lines) -- lightweight expanding ring effect.

### 3.3 weapon_controller.gd Changes

```gdscript
# No new state variable needed (pulse is fire-and-forget)

# New match case in _fire_weapon():
"pulse":
    wf.fire_pulse(data, player, dmg_bonus)
```

### 3.4 weapon_fire.gd Changes

New function:

```gdscript
func fire_pulse(data: WeaponData, player: CharacterBody2D, dmg_bonus: float) -> void:
    # Create pulse ring, set up expansion tween, apply damage to enemies in ring path
    # ~30 lines
```

### 3.5 pulse_ring.gd Behavior Specification

#### Node Structure

```
PulseRing (Node2D)
  +-- ColorRect "CenterBurst" (8x8, white, fades over 0.1s)
  +-- ColorRect "Segment0" (3x3, gold) x 16
  +-- Area2D "RingArea" (collision_layer=Layer3)
       +-- CollisionShape2D (circle, radius grows with expansion)
```

#### Expansion Logic

```gdscript
# Created at player position
# Tween: scale from 0 to max_radius over expand_time
# At each frame during expansion, check Area2D for overlapping enemies
# Apply damage + burn to each enemy once (track hit set)
# After expand_time: queue_free()
```

#### Hit Detection and Damage Application

```gdscript
# During expansion, scan Area2D.get_overlapping_bodies() each frame
# Track hit enemies in a Set (Dictionary keyed by enemy RID)
# For each newly overlapping enemy:
#   1. Apply damage: data.damage * dmg_bonus
#   2. Apply burn: data.burn_dps for data.burn_duration
#   3. Add to hit set (prevent re-damage during same pulse)
# The hit set ensures each enemy takes exactly 1 pulse hit per pulse event
```

**Keen Eye Crit Integration**:

```gdscript
# In damage application:
var keen_crit: bool = false
if _controller and _controller.has_method("notify_weapon_hit"):
    keen_crit = _controller.notify_weapon_hit(_player)
var pulse_damage: float = data.damage * dmg_bonus
if keen_crit:
    pulse_damage *= _player.crit_damage_mul
enemy.take_damage(pulse_damage, data.weapon_id, keen_crit)
```

#### Burn Application

The pulse applies burn using the same pattern as cone (firestaff) in weapon_fire.gd:

```gdscript
if data.burn_dps > 0.0 and enemy.has_method("apply_burn"):
    enemy.apply_burn(data.burn_dps, data.burn_duration)
```

This reuses the existing `enemy.apply_burn(dps, duration)` method directly. No new burn mechanics are needed.

#### Screen Shake

Each pulse triggers a screen shake:

```gdscript
# In fire_pulse(), after creating the ring:
# Use existing weapon_effects.gd or direct camera access:
var camera: Camera2D = _get_camera(player)
if camera and camera.has_method("apply_shake"):
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

### 3.7 DPS Analysis

- Pulses per wave (57s): 57 / 2.5 = 22.8 pulses
- Raw DPS: 12.0 / 2.5 = 4.8 DPS
- With burn: 4.8 + (2.0 x 2.0 / 2.5) = 6.4 DPS
- With Resonance synergy (dense waves): cooldown reduces to ~1.5s, DPS scales to ~10.0
- Guaranteed hit on all enemies in range (no targeting needed)

---

## 4. Thunder Beam -- Beam Type

### 4.1 Attack Pattern Description

Fires a long-range penetrating lightning beam toward the nearest enemy. The beam is active for beam_active_duration seconds every cooldown second cycle (40% uptime). During the active phase, the beam damages all enemies along its path every beam_tick_interval seconds (3 ticks per activation). After the beam hits, chain lightning strikes chain_count additional nearby enemies.

**Lifecycle**: Timer-based. Each cycle creates a beam line that persists for beam_active_duration, then is destroyed.

### 4.2 Implementation Architecture

The beam requires a persistent line entity with periodic tick damage. This is more complex than projectile but simpler than spiral.

**New file**: `scripts/weapons/beam_line.gd` (~50 lines) -- persistent beam line with tick timer.

### 4.3 weapon_controller.gd Changes

```gdscript
# No new persistent state variable (beam is created and self-manages)

# New match case in _fire_weapon():
"beam":
    wf.fire_beam(data, player, dmg_bonus)
```

### 4.4 weapon_fire.gd Changes

New function:

```gdscript
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
  +-- ColorRect "BeamCore" (projectile_range x 2, electric yellow)
  +-- ColorRect "CenterLine" (projectile_range x 1, white)
  +-- ColorRect "EdgeGlowL" (projectile_range x 1, electric blue)
  +-- ColorRect "EdgeGlowR" (projectile_range x 1, electric blue)
  +-- ColorRect "StartPoint" (3x3, white)
  +-- ColorRect "EndPoint" (3x3, white)
  +-- Area2D "BeamArea" (collision_layer=Layer3)
  |    +-- CollisionShape2D (RectangleShape2D, beam_width x projectile_range)
  +-- Timer "TickTimer" (beam_tick_interval, loops)
```

#### Direction Calculation

```gdscript
# In fire_beam():
var enemies := _get_enemies(player, data.projectile_range)
if enemies.is_empty():
    return  # No target -> no beam fired
var target: Node2D = enemies[0]  # Nearest enemy
var direction: Vector2 = (target.global_position - player.global_position).normalized()
```

**Important**: The beam targets the nearest enemy at the moment of firing. Once fired, the beam direction is locked for the entire active_duration. The beam does NOT track the enemy. This prevents the beam from "snapping" to different targets mid-activation and creates a consistent, predictable damage pattern.

#### Beam Creation

```gdscript
# Position at player
# Rotation toward direction
# Length = data.projectile_range (1200.0 px)
# Visual: ColorRect 2px wide, data.color
# Collision: 12px wide (data.beam_width)
```

#### Tick Damage Logic

```gdscript
# Timer fires every beam_tick_interval (0.3s)
# On tick: scan Area2D.get_overlapping_bodies()
# For each enemy in overlap:
#   - Check hit_set to prevent re-hitting same enemy same tick
#   - Apply damage (data.damage * dmg_bonus)
#   - Add to hit_set
# After beam_active_duration: apply chain lightning, then queue_free()
```

**Keen Eye Crit Integration**:

```gdscript
# On first tick only (or every tick? Design decision):
# Keen Eye counter increments per weapon hit, not per enemy.
# For beam, each tick that hits at least 1 enemy counts as 1 weapon hit.
# On tick: if enemies_hit > 0:
#   keen_crit = _controller.notify_weapon_hit(_player)
# If keen_crit: apply crit damage to ALL enemies in this tick
var keen_crit: bool = false
if enemies_hit_this_tick > 0 and _controller and _controller.has_method("notify_weapon_hit"):
    keen_crit = _controller.notify_weapon_hit(_player)
var tick_damage: float = data.damage * dmg_bonus
if keen_crit:
    tick_damage *= _player.crit_damage_mul
```

#### Chain Lightning

After the beam expires (beam_active_duration ends):

```gdscript
# Find enemies hit by the beam (from hit_set accumulated during ticks)
# Select the last hit enemy (or the enemy closest to beam endpoint)
# Find up to chain_count (2) enemies within chain_range (120.0 px) of that enemy
# For each chain target:
#   - Apply chain_damage (6.0 * dmg_bonus)
#   - Create lightning visual effect (reuse weapon_effects.gd create_lightning_effect)
# Chain targets cannot be enemies already hit by the beam (prevents double damage)
```

**Chain targeting algorithm**:

```gdscript
# 1. Get list of all enemies in arena (or within 200px of beam endpoint)
# 2. Filter out enemies already in beam hit_set
# 3. Sort remaining by distance from last_hit_enemy
# 4. Take first chain_count (2) enemies
# 5. Apply chain_damage to each
# 6. Create visual lightning line from last_hit_enemy to each chain target
```

This algorithm is simple and deterministic. No random selection needed.

#### Visual Sparks

During beam active phase, spawn random spark particles along the beam:

```gdscript
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

### 4.7 DPS Analysis

- Single target: 4.0 x 3 ticks / 2.5s = 4.8 DPS
- With chains (2 x 6.0): +4.8 DPS against groups = 9.6 multi-target DPS
- Positional dependency: enemies must be in a line for full beam DPS
- Highest multi-target DPS of the 3 new weapons, but requires favorable positioning

---

## 5. Synergy Design -- Phase E

### 5.1 Synergy System Integration

The 3 new synergies (Frostbite Loop, Resonance, Overcharge) are **intrinsic weapon synergies** -- they are built into the weapon behavior scripts themselves. Unlike the 18 existing synergies in `synergy_manager.gd` (which are weapon+passive or passive+passive combinations detected at the synergy level), these synergies are **self-contained within each weapon's behavior**.

**Why intrinsic rather than SynergyManager**:
1. Each synergy triggers from internal weapon state (freeze event, kill event, beam active state), not from weapon+passive combinations
2. The SynergyManager pattern requires a passive ingredient; these synergies have no prerequisite beyond owning the evolved weapon
3. The behavior scripts already have direct access to the state needed (hit tracking, timer state)
4. No cross-file coordination needed -- each synergy is self-contained

**SynergyManager registration**: These synergies do NOT need entries in SYNERGY_DEFINITIONS. They are weapon-internal behaviors. However, if a future design adds external triggers (e.g., "freeze from any source accelerates frostvortex"), the pattern would change.

### 5.2 Frostbite Loop (frostvortex synergy)

**Effect**: When a frostvortex blade freezes an enemy, all blades briefly accelerate (expand_speed x1.5 for 0.5s), creating a cascading freeze effect on clustered enemies.

**Implementation**: Entirely within `spiral_blade.gd`.

```gdscript
# In _process, after normal expand_speed:
var effective_expand_speed: float = data.spiral_expand_speed
if _accel_timer > 0.0:
    effective_expand_speed *= FROSTVORTEX_SYNERGY_ACCEL_MUL
    _accel_timer -= delta

if _current_radius < data.spiral_max_radius:
    _current_radius += effective_expand_speed * delta
else:
    _current_radius = data.spiral_min_radius  # Reset cycle

# In hit callback, after freeze application:
if freeze_triggered:
    if not _synergy_icd.has(enemy_rid) or (current_time - _synergy_icd[enemy_rid]) >= FROSTVORTEX_SYNERGY_ICD:
        _accel_timer = FROSTVORTEX_SYNERGY_ACCEL_DUR
        _synergy_icd[enemy_rid] = current_time
```

**ICD tracking**: Uses a Dictionary keyed by enemy RID (same pattern as hit cooldown). Maximum tracked enemies capped at 50 to prevent memory growth (oldest entries pruned when cap exceeded).

| Synergy Constant | Value | Notes |
|---|---|---|
| FROSTVORTEX_SYNERGY_ACCEL_MUL | 1.5 | Speed multiplier on freeze trigger |
| FROSTVORTEX_SYNERGY_ACCEL_DUR | 0.5s | Duration of acceleration burst |
| FROSTVORTEX_SYNERGY_ICD | 1.0s | Internal cooldown per enemy |
| FROSTVORTEX_SYNERGY_MAX_TRACKED | 50 | Maximum tracked enemy RIDs |

**Player experience**: When a blade freezes an enemy (8% chance per hit), all blades visibly accelerate outward for 0.5 seconds. In dense clusters, multiple freezes can chain together, creating a satisfying "power surge" moment where the vortex spins faster and faster.

### 5.3 Resonance (holyshockwave synergy)

**Effect**: Each enemy killed by holyshockwave reduces the pulse cooldown by 0.3 seconds (minimum cooldown 1.5s). Creates a snowball effect during dense waves.

**Implementation**: Requires coordination between `pulse_ring.gd` (damage source) and `weapon_controller.gd` (timer management).

**Integration path via enemy._last_hit_by**:

The existing enemy.gd tracks `_last_hit_by` (set in `take_damage()`, read in `die()`). When a pulse kills an enemy, `_last_hit_by` will be `"holyshockwave"`. The kill callback flows through `loot.handle_kill_rewards()`.

```gdscript
# Step 1: pulse_ring.gd applies damage with weapon_id
enemy.take_damage(pulse_damage, "holyshockwave", keen_crit)

# Step 2: When enemy dies, _last_hit_by == "holyshockwave"
# The weapon_controller needs to detect this.

# Step 3: Option A -- Signal approach
# In enemy.die(), if _last_hit_by == "holyshockwave":
#   emit_signal("killed_by_pulse")

# Step 3: Option B -- Poll approach (simpler, no signal overhead)
# In weapon_controller._physics_process(), track holyshockwave cooldown:
# After _fire_weapon("holyshockwave", ...), check kill delta
```

**Recommended approach: weapon_timer direct modification**:

The simplest integration is for `pulse_ring.gd` to hold a reference to the weapon_controller's `_weapon_timers` dictionary. When a pulse kills an enemy (detected by checking `enemy.hp <= 0` after damage), the ring directly modifies the timer:

```gdscript
# In pulse_ring.gd, during damage application:
enemy.take_damage(pulse_damage, "holyshockwave", keen_crit)
if not is_instance_valid(enemy) or enemy.hp <= 0:
    # Enemy killed by this pulse
    if _weapon_timers and _weapon_timers.has("holyshockwave"):
        _weapon_timers["holyshockwave"] -= 0.3
        _weapon_timers["holyshockwave"] = maxf(_weapon_timers["holyshockwave"], 1.5)
```

**Why direct timer modification**: The weapon_controller._weapon_timers dictionary already holds the cooldown countdown. Reducing it directly is the simplest integration with zero cross-file coordination. The pulse_ring already receives the data needed at creation time.

**Timing consideration**: The pulse creates the ring, the ring applies damage, enemies may die from that damage. If the ring modifies _weapon_timers, the next _physics_process cycle in weapon_controller will see the reduced timer and fire the next pulse sooner.

| Synergy Constant | Value | Notes |
|---|---|---|
| HOLYSHOCKWAVE_SYNERGY_CD_REDUCTION | 0.3s | Cooldown reduction per kill |
| HOLYSHOCKWAVE_SYNERGY_MIN_COOLDOWN | 1.5s | Cannot reduce below 1.5s |

**Player experience**: During Wave 4-5 with 50+ enemies, each pulse might kill 3-4 enemies. Each kill reduces the next pulse cooldown by 0.3s (from 2.5s base). After 3 kills: 2.5 - 0.9 = 1.6s. After 4 kills: 2.5 - 1.2 = 1.3s -> clamped to 1.5s. This creates an accelerating "heartbeat" pattern where pulses fire faster and faster during dense waves, then slow back down during lulls.

### 5.4 Overcharge (thunderbeam synergy)

**Effect**: While beam is active, player gains +15% movement speed. Encourages aggressive positioning -- running alongside the beam to sweep it across more enemies.

**Implementation**: In `beam_line.gd`, modify player speed on creation and cleanup.

**Player speed system integration**:

The player.gd uses `speed_multiplier` (additive with base move_speed). Current stacking:
- Base: 160.0 (player.move_speed)
- speedboots passive: +0.15 per stack to speed_multiplier
- Overcharge: +0.15 to speed_multiplier during beam active

```gdscript
# In beam_line.gd _ready():
if is_instance_valid(_player) and "speed_multiplier" in _player:
    _player.speed_multiplier += 0.15

# In beam_line.gd queue_free() or cleanup:
if is_instance_valid(_player) and "speed_multiplier" in _player:
    _player.speed_multiplier -= 0.15
```

**Safety check**: Always verify `is_instance_valid(_player)` before modifying speed, since the player could die during beam activation (beam persists briefly after player death in edge cases).

**Stacking with speedboots**: Overcharge stacks additively with speedboots. A player with 3x speedboots (0.45) and Overcharge active would have speed_multiplier = 1.45. This is acceptable -- the speed bonus is temporary (1.0s every 2.5s cycle = 40% uptime).

| Synergy Constant | Value | Notes |
|---|---|---|
| THUNDERBEAM_SYNERGY_SPEED_BONUS | 0.15 | +15% movement speed (additive with speed_multiplier) |
| THUNDERBEAM_SYNERGY_ONLY_WHEN_ACTIVE | true | Only during beam firing |

**Player experience**: When the beam fires, the player suddenly feels faster. The natural response is to strafe sideways, sweeping the beam across a wider area of enemies. When the beam deactivates, the speed returns to normal. This creates a rhythmic "burst of aggression" pattern every 2.5 seconds.

---

## 6. Implementation Line Estimates

| Phase | Content | New Lines | Modified Lines | Total Changed |
|---|---|---|---|---|
| Phase C | weapon_controller.gd match cases + state vars | ~12 | ~5 | ~17 |
| Phase C | weapon_fire.gd: update_spiral + fire_pulse + fire_beam | ~90 | ~0 | ~90 |
| Phase D | spiral_blade.gd (new file) | ~55 | ~0 | ~55 |
| Phase D | pulse_ring.gd (new file) | ~45 | ~0 | ~45 |
| Phase D | beam_line.gd (new file) | ~50 | ~0 | ~50 |
| Phase E | Frostbite Loop (in spiral_blade.gd) | ~10 | ~0 | ~10 |
| Phase E | Resonance (in pulse_ring.gd) | ~8 | ~0 | ~8 |
| Phase E | Overcharge (in beam_line.gd) | ~6 | ~0 | ~6 |
| **Total** | | **~276** | **~5** | **~281** |

Plus testing: ~40 lines of new tests per weapon = ~120 lines. Plus ~15 lines of synergy tests = ~135 total test lines.

### weapon_fire.gd Line Budget

| Current | ~366 lines |
|---|---|
| New functions (update_spiral + fire_pulse + fire_beam + chain helpers) | ~90 lines |
| New constants (3 beam constants) | ~3 lines |
| **Total after** | **~459 lines** |

This is within the 500-line limit with 41 lines of headroom. If additional helper functions are needed, consider extracting to module files (like weapon_boomerang_fire.gd pattern).

### weapon_controller.gd Line Budget

| Current | ~137 lines |
|---|---|
| New state var (_spiral_instance) + match cases | ~11 lines |
| **Total after** | **~148 lines** |

Healthy with 352 lines of headroom.

---

## 7. Integration Checklist

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
- [ ] Handle spiral position tracking in `_process()` (like orbit)
- [ ] Add `_spiral_instance` cleanup in `remove_weapon_instances()`

### Phase D: New Script Files

- [ ] Create `scripts/weapons/spiral_blade.gd` (~55 lines)
  - [ ] Setup: create 6 ColorRect blades + hub + Area2D
  - [ ] _process: follow player, expand/rotate blades
  - [ ] Hit callback: apply damage + slow + freeze with per-blade ICD
  - [ ] Keen Eye crit integration
- [ ] Create `scripts/weapons/pulse_ring.gd` (~45 lines)
  - [ ] Setup: create 16 segment ColorRects + center burst + Area2D
  - [ ] Tween: expand from 0 to max_radius
  - [ ] Hit scan: damage + burn each frame, track hit set
  - [ ] Screen shake on creation
  - [ ] Auto-destroy after expansion
- [ ] Create `scripts/weapons/beam_line.gd` (~50 lines)
  - [ ] Setup: create beam visuals + Area2D + TickTimer
  - [ ] Tick timer: damage overlapping enemies, track hit set
  - [ ] Chain lightning on expiration
  - [ ] Spark particles during activation
  - [ ] Auto-destroy after active_duration

### Phase E: Synergy Integration

- [ ] Frostbite Loop: freeze event -> blade acceleration (in spiral_blade.gd, ~10 lines)
- [ ] Resonance: holyshockwave kill -> cooldown reduction (in pulse_ring.gd via _weapon_timers, ~8 lines)
- [ ] Overcharge: beam active -> speed bonus (in beam_line.gd + player.speed_multiplier, ~6 lines)

---

## 8. Decision Record

| Decision | Why | Alternative Considered |
|---|---|---|
| Dedicated script per weapon type (spiral_blade/pulse_ring/beam_line) | Each behavior has unique lifecycle and state management. Mixing them into weapon_fire.gd would push it past 500 lines | All in weapon_fire.gd (simpler file management but violates line limit) |
| spiral uses persistent instance (like orbit) | Spiral is always active and follows player. Creating/destroying each frame would be wasteful | Fire-and-forget with timer recreation (wasteful, flickering) |
| pulse uses fire-and-forget (like projectile) | Pulse is a discrete event with defined lifetime. No persistent state needed | Persistent pulse instance (unnecessary complexity) |
| beam uses self-managing node (like boomerang) | Beam has internal tick timer and auto-destroys. Simpler than managing tick state in weapon_controller | weapon_controller manages beam ticks (couples beam logic to controller) |
| Hit cooldown per blade per enemy (spiral) | Without it, a blade sweeping through a cluster would deal damage every frame (3.0 x 60 = 180 DPS). 0.5s ICD gives ~6 DPS per blade | No ICD (broken DPS), global ICD per enemy (kills multi-blade value) |
| Chain lightning after beam expires (not during) | Chains on expiration keeps the beam phase focused on direct damage, and the chain phase creates a satisfying "explosion" at the end | Chains during beam ticks (noisy, hard to balance, overlaps with tick damage) |
| Resonance via direct timer modification | pulse_ring holds reference to _weapon_timers, reduces cooldown directly on kill. Simplest integration, zero cross-file coordination | Signal approach (adds signal overhead, enemy already has the data); enemy death callback (requires modifying enemy.gd for weapon-specific logic) |
| Frostbite Loop internal to spiral_blade.gd | Self-contained within the spiral script. No external coordination needed | Event system through SynergyManager (overkill for a simple speed boost) |
| Overcharge via speed_modifier modification | player.gd already has speed_multiplier as additive modifier. Adding 0.15 during beam active is safe and stackable with speedboots | Create separate speed_bonus variable (redundant with existing speed_multiplier) |
| Beam direction locked on fire (no tracking) | Prevents beam from "snapping" between targets mid-activation. Creates consistent, predictable damage pattern. Player can position to sweep manually | Beam tracks nearest enemy (unpredictable, can waste DPS if enemy moves) |
| Keen Eye crit integration for all 3 weapons | Consistent with existing weapon types. Each weapon hit should increment the Ranger's Keen Eye counter | Skip Keen Eye for evolved weapons (inconsistent, penalizes Ranger builds) |
| Synergies are weapon-intrinsic (not in SynergyManager) | Each synergy triggers from internal weapon state, not from weapon+passive combinations. No passive ingredient required. Self-contained in behavior scripts | Register in SynergyManager (requires adding passive prerequisite, changes synergy detection flow) |
| Pulse hit set prevents re-damage per pulse event | Without it, enemies in the ring's path for multiple frames would take 12.0 damage per frame (720 DPS). Hit set ensures exactly 1 pulse hit per pulse event | No hit set (broken), global hit tracking (more complex, unnecessary) |
| Chain excludes beam-hit enemies | Prevents double damage (beam tick + chain lightning on same enemy). Chain should hit new targets, rewarding wide enemy distribution | Allow chains on beam-hit enemies (double damage potential too high, ~20 DPS on single target) |

---

## 9. Balance Assessment

### 9.1 Three-Weapon DPS Comparison

| Weapon | Raw DPS | Effective DPS | Utility | Best Scenario | Tier |
|---|---|---|---|---|---|
| frostvortex (spiral) | ~6.0 | ~8.0 | Slow + Freeze + Frostbite Loop | Dense clustered enemies near player | B |
| holyshockwave (pulse) | 4.8 | 6.4 + burn (10.0 w/ Resonance) | Guaranteed AoE + Burn + Resonance scaling | Dense waves (Wave 4-5) | B |
| thunderbeam (beam) | 4.8 (single) | 9.6 (multi) | Long range + Chain + Overcharge speed | Enemies lined up in one direction | B |

### 9.2 Comparison with Existing Evolved Weapons

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

### 9.3 Synergy Power Scaling

| Synergy | Base DPS | Synergized DPS | Scaling Factor | Condition |
|---|---|---|---|---|
| Frostbite Loop | ~8.0 | ~10.0 (accel effect) | 1.25x | Freeze triggers in clusters |
| Resonance | 6.4 | 10.0 | 1.56x | 3+ kills per pulse (dense waves) |
| Overcharge | 4.8-9.6 | 4.8-9.6 (no DPS change) | 1.0x (utility only) | Positioning tool |

Resonance has the highest scaling potential but requires dense enemy waves. Overcharge provides no direct DPS boost but enables better positioning. Frostbite Loop is a moderate boost that rewards cluster engagement.

---

## 10. Test Cases

| Case | Verification | Priority |
|---|---|---|
| spiral_blade creates 6 blades | Blade count matches WeaponData.spiral_blade_count | P1 |
| spiral follows player position | spiral_blade.global_position == player.global_position | P1 |
| spiral radius expands and resets | Radius goes min -> max -> min cyclically | P1 |
| spiral applies slow on hit | Enemy speed reduced by slow_pct | P2 |
| spiral applies freeze on hit | 8% chance, Frostbite Loop accelerates blades | P2 |
| spiral applies damage with Keen Eye | notify_weapon_hit increments counter | P2 |
| pulse ring expands from 0 to max | Tween scales ring from 0 to 200px in 0.3s | P1 |
| pulse damages all enemies in ring path | All enemies between 0 and 200px radius take 12.0 damage | P0 |
| pulse hit set prevents re-damage | Each enemy takes exactly 1 hit per pulse event | P0 |
| pulse applies burn | Enemies hit have burn_dps=2.0 for 2.0 seconds | P1 |
| pulse triggers screen shake | Camera shake with intensity 2.0, duration 0.1s | P2 |
| beam fires toward nearest enemy | Beam direction points at closest enemy in range | P1 |
| beam direction locked after fire | Beam does not track enemy movement after firing | P1 |
| beam ticks 3 times per activation | 3 ticks in 1.0s at 0.3s intervals | P1 |
| beam chain lightning hits 2 enemies | After beam expires, 2 nearby enemies take 6.0 chain damage | P1 |
| beam chain excludes beam-hit enemies | Chain targets are different from beam-hit targets | P1 |
| beam self-destructs after active_duration | queue_free() called after 1.0s | P1 |
| Overcharge speed bonus applied during beam | player.speed_multiplier += 0.15 while beam active | P2 |
| Overcharge speed bonus removed on beam end | player.speed_multiplier -= 0.15 on queue_free | P2 |
| Resonance cooldown reduction | holyshockwave kill reduces next cooldown by 0.3s | P2 |
| Resonance minimum cooldown enforced | Timer cannot go below 1.5s | P1 |
| Frostbite Loop acceleration | Freeze event triggers expand_speed x1.5 for 0.5s | P2 |
| Frostbite Loop ICD per enemy | Same enemy cannot trigger acceleration more than once per 1.0s | P2 |
| No damage when no enemies in range | beam/pulse do nothing if no enemies found | P1 |
| weapon_fire.gd stays under 500 lines | Line count verification after all additions | P0 |
| weapon_controller.gd stays under 500 lines | Line count verification | P0 |

---

## 11. Change Log

| Round | Changes |
|---|---|
| R26 | Initial design: 3 weapon behaviors, architecture, numerical tables |
| R27 | Added weapon VFX spec reference (v1.1.0-weapon-vfx.md) |
| R28 | **Firing parameters finalized**: Added Keen Eye crit integration for all 3 weapons, beam direction lock decision, pulse hit set mechanics, chain exclusion rules. **Synergy design detailed**: Frostbite Loop ICD tracking with max cap, Resonance direct timer modification approach, Overcharge speed_multiplier integration path. **Line estimates updated**: Phase E synergy lines added (~24 lines), total ~281 implementation lines. **Test cases expanded**: Added 8 new test cases for edge cases. **Decision record expanded**: 13 decisions documented with alternatives. |
