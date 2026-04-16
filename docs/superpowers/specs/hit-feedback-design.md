# Hit Feedback System Design

**Author**: Designer Agent
**Date**: 2026-04-17
**Round**: R21 (refined from R20)
**Status**: Design Spec
**Context**: R20 defined the hit feedback system with weapon-differentiated parameters. R21 refines all 7 weapon types with precise per-particle velocity vectors, spread angles, crit parameters, and exact rate-limit values for direct implementation.

---

## 1. Design Overview

Hit feedback is the collection of visual effects triggered when a weapon attack damages an enemy. It serves two purposes:

1. **Gamefeel**: "Every hit has weight" -- even small, rapid hits produce a micro-response
2. **Information**: Damage numbers communicate how much damage was dealt, and crits are instantly recognizable

The system consists of four layers:

| Layer | Effect | Priority | Trigger |
|---|---|---|---|
| 1 | Hit particle burst | P2 | Every hit (frequency-limited) |
| 2 | Damage number popup | P2 | Every hit (frequency-limited) |
| 3 | Critical hit special effect | P2 | Crit hits only |
| 4 | Weapon-type differentiation | P2 | Varies by weapon |

---

## 2. Hit Particle Burst -- Universal Parameters

### 2.1 Base Parameters

| Parameter | Value | Rationale |
|---|---|---|
| Particle count (normal) | 3 | Sufficient for feedback, minimal performance cost |
| Particle count (crit) | 5 | 67% more creates visible burst |
| Particle shape | Square ColorRect | Matches project's pixel visual style |
| Emission point | Enemy.global_position | Centered on the hit target |

### 2.2 Particle Lifetime and Fade

| Parameter | Normal | Crit | Rationale |
|---|---|---|---|
| Lifetime | 0.15s | 0.20s | Brief enough to not accumulate |
| Alpha curve | 1.0 -> 0.0 linear | 1.0 -> 0.0 linear | Clean fade-out |
| Scale curve | Constant (no scale) | Constant (no scale) | Simplicity, pixel art |

### 2.3 Particle Pooling

| Parameter | Value |
|---|---|
| Pool size | 60 ColorRect nodes |
| Reuse strategy | Silent drop when exhausted |
| Pool parent | Arena node (game world space) |

**Why 60**: 3 particles x 8 simultaneous hit sources x (0.15s / 0.1s interval) = ~36 peak. 60 provides 67% headroom.

---

## 3. Weapon-Differentiated Particle Parameters (R21 Precision)

Each weapon type has unique particle velocity, spread angle, size, and behavior. All velocity values are specified as (vx, vy) components in px/s, where positive x = right, positive y = down.

### 3.1 Knife (Projectile)

**Source data**: projectile_speed=350, projectile_size=5, color=Color(0.75, 0.75, 0.8), cooldown=0.7s

| Parameter | Normal Hit | Crit Hit | Rationale |
|---|---|---|---|
| Particle count | 3 | 5 | -- |
| Particle size | 2x2 px | 3x3 px | Crit particles slightly larger |
| Particle color | Color(0.75, 0.75, 0.8) silver | Color(1.0, 0.84, 0.0) gold | -- |
| Spread angle | -30 deg to +30 deg (60 deg horizontal cone) | -45 deg to +45 deg (90 deg horizontal cone) | Knives scatter horizontally along impact direction |
| Velocity magnitude | 45 px/s (random: 35-55 px/s) | 65 px/s (random: 55-75 px/s) | Faster for crits |
| Velocity x-component | velocity * cos(random_angle_in_cone) | velocity * cos(random_angle_in_cone) | -- |
| Velocity y-component | velocity * sin(random_angle_in_cone) | velocity * sin(random_angle_in_cone) | -- |
| Rate limit | 100 ms | 100 ms | Fast-firing weapon needs strict limit |
| Direction basis | Impact direction (projectile.velocity.normalized()) | Same | -- |

**Why -30 to +30 deg**: Knives travel at 350 px/s and hit frequently. A narrow horizontal scatter creates a "blade slash" visual without cluttering the screen during rapid fire.

**Exact velocity generation pseudocode**:
```
base_angle = impact_direction.angle()
for each particle:
    angle_offset = randf_range(-30, 30) * DEG_TO_RAD  # or -45 to 45 for crit
    speed = randf_range(35, 55)  # or 55-75 for crit
    vx = speed * cos(base_angle + angle_offset)
    vy = speed * sin(base_angle + angle_offset)
```

### 3.2 Holy Water (Orbit)

**Source data**: orbit_speed=3.0, projectile_size=8, color=Color(0.3, 0.5, 1.0), cooldown=1.0s

| Parameter | Normal Hit | Crit Hit | Rationale |
|---|---|---|---|
| Particle count | 3 | 5 | -- |
| Particle size | 2x2 px | 3x3 px | -- |
| Particle color | Color(0.3, 0.5, 1.0) blue | Color(1.0, 0.84, 0.0) gold | -- |
| Spread angle | Full 360 deg (radial) | Full 360 deg (radial) | Orbit weapons hit from all directions |
| Velocity magnitude | 50 px/s (random: 40-60 px/s) | 70 px/s (random: 60-80 px/s) | Moderate scatter speed |
| Velocity x-component | velocity * cos(random_0_to_TAU) | velocity * cos(random_0_to_TAU) | -- |
| Velocity y-component | velocity * sin(random_0_to_TAU) | velocity * sin(random_0_to_TAU) | -- |
| Rate limit | 150 ms | 150 ms | Orbits hit many enemies simultaneously |
| Direction basis | N/A (full radial) | N/A | -- |

**Why 360 deg radial**: Holy water orbits rotate around the player and hit enemies from any direction. Radial scatter looks natural regardless of the orbit blade's position.

### 3.3 Lightning (Instant Strike)

**Source data**: cooldown=2.0s, range=300, color=Color(1.0, 1.0, 0.3)

| Parameter | Normal Hit | Crit Hit | Rationale |
|---|---|---|---|
| Particle count | 3 | 5 | -- |
| Particle size | 2x2 px | 3x3 px | -- |
| Particle color | Color(1.0, 1.0, 0.3) yellow | Color(1.0, 0.84, 0.0) gold | -- |
| Spread angle | -60 deg to +60 deg downward cone (120 deg) | -90 deg to +90 deg (180 deg half-plane) | Lightning strikes from above |
| Velocity magnitude | 55 px/s (random: 45-65 px/s) | 75 px/s (random: 65-85 px/s) | Fast scatter for electric feel |
| Velocity x-component | velocity * cos(random_angle_in_cone) | velocity * cos(random_angle_in_cone) | -- |
| Velocity y-component | abs(velocity * sin(random_angle_in_cone)) -- always positive (downward) | Same | Particles scatter downward |
| Rate limit | 0 ms (no limit) | 0 ms (no limit) | Lightning hits infrequently (2s cooldown) |
| Direction basis | Downward cone (angle base = PI/2 = straight down) | Same | Simulates "striking from sky" |

**Why downward cone**: Lightning visually comes from above. Particles scattering downward reinforces the "bolt from the sky" directionality. The 120-degree cone provides visual variety while maintaining the directional cue.

**Exact velocity generation pseudocode**:
```
base_angle = PI / 2  # straight down
for each particle:
    angle_offset = randf_range(-60, 60) * DEG_TO_RAD  # or -90 to 90 for crit
    speed = randf_range(45, 65)  # or 65-85 for crit
    actual_angle = base_angle + angle_offset
    vx = speed * cos(actual_angle)
    vy = abs(speed * sin(actual_angle))  # always scatter downward
```

### 3.4 Bible (Orbit)

**Source data**: orbit_speed=3.0, orbit_radius=80, projectile_size=20, color=Color(0.9, 0.85, 0.7), cooldown=1.0s

| Parameter | Normal Hit | Crit Hit | Rationale |
|---|---|---|---|
| Particle count | 3 | 5 | -- |
| Particle size | 2x2 px | 3x3 px | -- |
| Particle color | Color(0.9, 0.85, 0.7) cream | Color(1.0, 0.84, 0.0) gold | -- |
| Spread angle | Full 360 deg (radial) | Full 360 deg (radial) | Same as holy water -- orbit weapon |
| Velocity magnitude | 40 px/s (random: 30-50 px/s) | 60 px/s (random: 50-70 px/s) | Slightly slower than holy water (larger hit area) |
| Velocity x-component | velocity * cos(random_0_to_TAU) | velocity * cos(random_0_to_TAU) | -- |
| Velocity y-component | velocity * sin(random_0_to_TAU) | velocity * sin(random_0_to_TAU) | -- |
| Rate limit | 150 ms | 150 ms | Large orbit radius contacts many enemies |
| Direction basis | N/A (full radial) | N/A | -- |

**Why 40 px/s (slower than holy water)**: Bible's orbit radius is 80px (vs holy water's 50px) and the projectile size is 20px (vs 8px). The larger visual footprint means slower particles create a calmer, "holy" feel rather than energetic splash.

### 3.5 Fire Staff (Cone)

**Source data**: cooldown=1.5s, cone_angle=80, cone_range=100, color=Color(1.0, 0.4, 0.1)

| Parameter | Normal Hit | Crit Hit | Rationale |
|---|---|---|---|
| Particle count | 3 | 5 | -- |
| Particle size | 2x2 px (particle 1-2), 3x3 px (particle 3: ember) | 4x4 px (all uniform) | -- |
| Particle color | Color(1.0, 0.4, 0.1) orange-red (particles 1-2), Color(1.0, 0.2, 0.05) dark red (particle 3: ember) | Color(1.0, 0.84, 0.0) gold | -- |
| Spread angle | -45 deg to +45 deg (90 deg cone) | -60 deg to +60 deg (120 deg cone) | Matches fire cone visual |
| Velocity magnitude | 50 px/s (random: 40-60 px/s) | 70 px/s (random: 60-80 px/s) | -- |
| Velocity x-component | velocity * cos(random_angle_in_cone) | velocity * cos(random_angle_in_cone) | -- |
| Velocity y-component | velocity * sin(random_angle_in_cone) | velocity * sin(random_angle_in_cone) | -- |
| Rate limit | 100 ms | 100 ms | Cone can hit multiple enemies per tick |
| Direction basis | Player facing direction (player_dir from fire_cone) | Same | -- |
| Special: ember particle (3rd) | Lifetime 0.30s (vs 0.15s), color shifts orange->dark-red over lifetime | N/A (crit uses uniform gold) | Simulates lingering ember |

**Why ember particle**: The 3rd normal-hit particle has an extended 0.30s lifetime and shifts from orange to dark-red. This simulates a fire ember drifting away, reinforcing the fire weapon's identity. On crit, all 5 particles are uniform gold for instant readability.

**Ember color shift**:
```
t=0.00s: Color(1.0, 0.4, 0.1, 1.0)  -- orange-red
t=0.15s: Color(0.8, 0.2, 0.05, 0.7) -- dark red, partially transparent
t=0.30s: Color(0.5, 0.1, 0.02, 0.0) -- very dark red, fully transparent
```

### 3.6 Frost Aura (Aura)

**Source data**: cooldown=0 (continuous), aoe_radius=80, slow=0.3, color=Color(0.5, 0.8, 1.0)

| Parameter | Normal Hit | Crit Hit | Rationale |
|---|---|---|---|
| Particle count | 3 | 5 | -- |
| Particle size | 2x2 px | 3x3 px | -- |
| Particle color | Color(0.5, 0.8, 1.0) ice blue | Color(1.0, 0.84, 0.0) gold | -- |
| Spread angle | Full 360 deg (radial) | Full 360 deg (radial) | Aura hits all directions |
| Velocity magnitude | 25 px/s (random: 20-30 px/s) | 45 px/s (random: 35-55 px/s) | Very slow -- ice crystals drifting |
| Velocity x-component | velocity * cos(random_0_to_TAU) | velocity * cos(random_0_to_TAU) | -- |
| Velocity y-component | velocity * sin(random_0_to_TAU) | velocity * sin(random_0_to_TAU) | -- |
| Rate limit | 150 ms | 150 ms | Continuous aura damage needs strict limit |
| Direction basis | N/A (full radial) | N/A | -- |

**Why 25 px/s (slowest)**: Frost aura is the calmest weapon. Slow-drifting ice crystal particles reinforce the "freezing cold" feel. Even at crit, the 45 px/s is slower than most weapons' normal speed. This is a deliberate contrast with the fast-scatter knife and lightning particles.

### 3.7 Boomerang (Boomerang)

**Source data**: speed=280, cooldown=1.8, projectile_size=8, color=Color(0.6, 0.4, 0.2), return_speed=320

| Parameter | Normal Hit | Crit Hit | Rationale |
|---|---|---|---|
| Particle count | 3 | 5 | -- |
| Particle size | 2x2 px | 3x3 px | -- |
| Particle color | Color(0.6, 0.4, 0.2) brown | Color(1.0, 0.84, 0.0) gold | -- |
| Spread angle | Perpendicular to flight direction: -45 deg to +45 deg (90 deg arc) | Full 360 deg (radial) | -- |
| Velocity magnitude | 50 px/s (random: 40-60 px/s) | 70 px/s (random: 60-80 px/s) | -- |
| Velocity x-component | velocity * cos(perpendicular_base + random_offset) | velocity * cos(random_0_to_TAU) | -- |
| Velocity y-component | velocity * sin(perpendicular_base + random_offset) | velocity * sin(random_0_to_TAU) | -- |
| Rate limit | 100 ms | 100 ms | Boomerang can pierce multiple enemies |
| Direction basis | Perpendicular to boomerang's current direction vector | N/A (radial for crit) | -- |

**Why perpendicular scatter**: Boomerangs fly in a curved path. Particles scattering perpendicular to the flight direction creates a "splinter burst" that follows the boomerang's trajectory, visually communicating the curved flight path. On crit, the burst becomes radial (full scatter) for dramatic emphasis.

**Exact velocity generation pseudocode**:
```
# Normal hit:
flight_angle = boomerang.direction.angle()
perpendicular_angle = flight_angle + PI / 2  # 90 degrees offset
for each particle:
    angle_offset = randf_range(-45, 45) * DEG_TO_RAD
    speed = randf_range(40, 60)
    actual_angle = perpendicular_angle + angle_offset
    vx = speed * cos(actual_angle)
    vy = speed * sin(actual_angle)

# Crit hit: full radial
for each particle:
    angle = randf() * TAU
    speed = randf_range(60, 80)
    vx = speed * cos(angle)
    vy = speed * sin(angle)
```

---

## 4. Weapon Particle Parameter Summary Table

**All 7 weapons -- normal hit values for quick reference**:

| Weapon | Spread | Speed Range | Rate Limit | Particle Color | Special |
|---|---|---|---|---|---|
| Knife | -30 to +30 deg (impact dir) | 35-55 px/s | 100 ms | Color(0.75, 0.75, 0.8) | Horizontal scatter |
| HolyWater | 360 deg radial | 40-60 px/s | 150 ms | Color(0.3, 0.5, 1.0) | Full radial |
| Lightning | -60 to +60 deg (downward) | 45-65 px/s | 0 ms | Color(1.0, 1.0, 0.3) | Downward cone, no rate limit |
| Bible | 360 deg radial | 30-50 px/s | 150 ms | Color(0.9, 0.85, 0.7) | Slow radial |
| FireStaff | -45 to +45 deg (facing dir) | 40-60 px/s | 100 ms | Color(1.0, 0.4, 0.1) | Ember particle (0.3s) |
| FrostAura | 360 deg radial | 20-30 px/s | 150 ms | Color(0.5, 0.8, 1.0) | Very slow drift |
| Boomerang | -45 to +45 deg (perpendicular) | 40-60 px/s | 100 ms | Color(0.6, 0.4, 0.2) | Perpendicular scatter |

**All 7 weapons -- crit hit values for quick reference**:

| Weapon | Spread | Speed Range | Count | Particle Color | Special |
|---|---|---|---|---|---|
| Knife | -45 to +45 deg | 55-75 px/s | 5 | Color(1.0, 0.84, 0.0) gold | Wider cone |
| HolyWater | 360 deg radial | 60-80 px/s | 5 | gold | Faster radial |
| Lightning | -90 to +90 deg | 65-85 px/s | 5 | gold | Half-plane |
| Bible | 360 deg radial | 50-70 px/s | 5 | gold | Faster radial |
| FireStaff | -60 to +60 deg | 60-80 px/s | 5 | gold (uniform) | No ember on crit |
| FrostAura | 360 deg radial | 35-55 px/s | 5 | gold | Faster but still slow |
| Boomerang | 360 deg radial | 60-80 px/s | 5 | gold | Radial (not perpendicular) |

---

## 5. Damage Number Popup

### 5.1 Damage Number Parameters (Normal Hit)

| Parameter | Exact Value | Rationale |
|---|---|---|
| Font | Default Godot Label font | No custom font needed |
| Font size | 10 px | Readable but not dominant |
| Color | Color(1.0, 1.0, 1.0) white | High contrast on dark background |
| Starting position | Enemy.global_position + Vector2(randf_range(-4, 4), -10) | Random x-offset prevents stacking; -10px above enemy center |
| Upward drift | 30 px total over 0.6s | velocity_y = -50 px/s (constant) for 0.6s |
| Alpha hold | 1.0 for first 0.4s | Stays readable |
| Alpha fade | 1.0 -> 0.0 linear over last 0.2s | Quick fade |
| Number format | str(int(round(damage))) | "5" not "5.3" |

**Upward drift velocity calculation**: 30 px / 0.6s = 50 px/s. Implemented as constant velocity of -50 px/s on the y-axis.

### 5.2 Damage Number Parameters (Crit Hit)

| Parameter | Exact Value | Rationale |
|---|---|---|
| Font size | 14 px | 40% larger than normal -- clearly different |
| Color | Color(1.0, 0.84, 0.0) gold | "Valuable" connotation |
| Starting position | Same as normal (enemy.global_position + Vector2(randf_range(-4, 4), -10)) | -- |
| Shake phase | 0.0s to 0.15s: horizontal oscillation +-2px | -- |
| Shake pattern | [-2, +2, -2, +2, -1, 0] at 0.025s intervals (6 steps over 0.15s) | -- |
| Upward drift | 30 px over 0.45s (0.15s to 0.60s) | velocity_y = -66.7 px/s during drift phase |
| Alpha hold | 1.0 from 0.15s to 0.40s | Readable after shake settles |
| Alpha fade | 1.0 -> 0.0 linear over 0.20s (0.40s to 0.60s) | -- |
| Total lifetime | 0.60s (0.15s shake + 0.45s drift) | -- |

**Shake phase precise timing**:

| Time | x_offset |
|---|---|
| 0.000s | -2 px |
| 0.025s | +2 px |
| 0.050s | -2 px |
| 0.075s | +2 px |
| 0.100s | -1 px |
| 0.125s | 0 px |
| 0.150s | drift upward begins (shake complete) |

### 5.3 Damage Number Pooling

| Parameter | Value |
|---|---|
| Pool size | 20 Label nodes |
| Reuse strategy | Silent drop when exhausted |
| Pool parent | Arena node |
| Priority | Crit numbers get pool priority over normal numbers |

---

## 6. Evolved Weapon Particles (P3 Reference)

Evolved weapons use blended colors from their parent weapons. These are P3 polish -- P2 implementation uses gold Color(1.0, 0.84, 0.0) for all evolved weapons.

**P3 color blend table** (for future implementation):

| Evolved Weapon | Parent A | Parent B | Blended Particle Color |
|---|---|---|---|
| thunderholywater | HolyWater blue | Lightning yellow | Color(0.65, 0.75, 0.65) |
| fireknife | Knife silver | FireStaff orange | Color(0.88, 0.58, 0.45) |
| holydomain | Bible cream | HolyWater blue | Color(0.6, 0.68, 0.85) |
| blizzard | FrostAura ice | Lightning yellow | Color(0.75, 0.9, 0.65) |
| frostknife | Knife silver | FrostAura ice | Color(0.63, 0.78, 0.9) |
| flamebible | Bible cream | FireStaff orange | Color(0.95, 0.63, 0.4) |
| thunderang | Boomerang brown | Lightning yellow | Color(0.8, 0.7, 0.25) |
| blazerang | Boomerang brown | FireStaff orange | Color(0.8, 0.4, 0.15) |

---

## 7. Performance Constraints

### 7.1 Global Limits

| Resource | Max Budget | Rationale |
|---|---|---|
| Active hit particles | 60 | Pool size limit |
| Active damage numbers | 20 | Pool size limit |
| Particle creation rate | 30 bursts/s (across all weapons) | Prevents frame time spikes |

### 7.2 Frame Budget

At 60 FPS target:
- Particle creation: 0.5ms max (3 ColorRect instantiations per burst, from pool)
- Tween creation: 0.3ms max (3 particle tweens + 1 number tween per burst)
- Total per-frame hit feedback cost: ~1ms at peak combat (6.25% of 16ms frame)

### 7.3 Graceful Degradation

When pools are exhausted:
1. Hit particles: Skip creation silently. No visual artifact.
2. Damage numbers: Crit numbers have priority over normal numbers.
3. If pool has 1 slot, crit gets it.

---

## 8. Rate Limit Summary

| Weapon Type | Rate Limit (ms) | Calculation |
|---|---|---|
| Projectile (Knife) | 100 ms | Knife fires every 700ms with 1-3 projectiles. 100ms limit = max 7 bursts/sec |
| Orbit (HolyWater) | 150 ms | Orbits contact continuously. 150ms = max 6.7 bursts/sec |
| Lightning | 0 ms (no limit) | Fires every 2s. Even with chain+Lv3 bolts, max ~3 hits per firing |
| Orbit (Bible) | 150 ms | Same as holy water -- continuous contact |
| Cone (FireStaff) | 100 ms | Fires every 1.5s but hits multiple enemies per tick |
| Aura (FrostAura) | 150 ms | Continuous area damage. Strict limit essential |
| Boomerang | 100 ms | Can pierce multiple enemies per pass |

**Maximum theoretical particles per second**: 7 weapons x 3 particles x (1000/100) = 210 particles/sec. With 0.15s lifetime, max concurrent = 210 x 0.15 = ~32 particles. Well within 60 pool limit.

**Worst case**: Lightning (no limit) + 6 other weapons at 100ms. Lightning hits 3 targets x 3 particles = 9 per 2s. Other 6 weapons at 100ms rate limit = 6 x 3 x 10 = 180/sec. Total = 189 particles/sec x 0.15s = ~28 concurrent. Still within 60 pool.

---

## 9. Integration Points

### 9.1 Where to Trigger Hit Feedback

Hit feedback is triggered in `enemy.gd` `take_damage()`:

**Extended flow** (adding particles and damage numbers):
```gdscript
func take_damage(amount: float, source: String = "", was_crit: bool = false):
    if not is_alive:
        return
    if source != "":
        _last_hit_by = source
    _was_crit = was_crit
    current_hp -= amount
    var sprite_node: Sprite2D = $Sprite as Sprite2D
    if sprite_node and is_instance_valid(sprite_node):
        _get_death_effects().play_hit_feedback(self, sprite_node)
    # NEW: Hit particles + damage number
    _spawn_hit_feedback(amount, source, was_crit)
    if current_hp <= 0:
        die()
```

### 9.2 Hit Feedback Module

**New file**: `scripts/hit_feedback.gd` (RefCounted, similar to enemy_death_effects.gd)

This module encapsulates:
- Particle pool management
- Damage number pool management
- Rate limiting per weapon (using Dictionary of timestamps)
- Weapon parameter lookup (7 weapon configs)
- Crit vs normal differentiation

**Estimated size**: ~150 lines

### 9.3 Implementation Scope

| File | Change | Lines |
|---|---|---|
| `scripts/hit_feedback.gd` | New file: particle pool, damage number pool, rate limiting, weapon configs | ~150 |
| `scripts/enemy.gd` | Add `_spawn_hit_feedback()` call in `take_damage()` | ~5 |
| `scripts/arena.gd` | Add particle/number pool node containers | ~10 |
| **Total** | | **~165** |

---

## 10. Decision Record

| Decision | Why | Alternative Considered |
|---|---|---|
| Per-weapon velocity vectors (not uniform 40-60 px/s) | Each weapon has distinct attack pattern (projectile/orbit/instant/cone/aura/boomerang). Matching particle behavior to weapon type reinforces weapon identity | Uniform speed for all weapons (loses weapon differentiation) |
| Knife: -30 to +30 deg narrow cone | Knife fires rapidly (700ms cooldown). Narrow scatter prevents visual noise during rapid fire | Wider cone (clutters screen with frequent hits) |
| Lightning: downward cone, no rate limit | Lightning strikes from above visually. 2s cooldown means infrequent hits, no rate limit needed | Radial scatter (loses directional cue), rate limit (unnecessary for 2s cooldown weapon) |
| FrostAura: 20-30 px/s slowest | Ice crystals drift slowly, reinforcing the "cold/calming" feel. Speed is the differentiator from energetic weapons | Same speed as others (loses the frost identity) |
| Boomerang: perpendicular scatter | Boomerang's curved flight path creates a unique visual opportunity. Perpendicular scatter follows the arc | Radial scatter (loses the flight-path connection) |
| FireStaff: ember particle (3rd particle has 0.3s lifetime) | The lingering ember is a unique visual signature. One longer-lived particle among three creates visual rhythm | All particles same lifetime (loses fire identity) |
| 10px normal / 14px crit font size | 10px readable without dominating. 14px 40% larger, clearly different. 4px difference is visible in pixel art | 8px/12px (too small for normal), 12px/16px (too large for crit) |
| Damage number upward drift: -50 px/s for 0.6s (30px total) | 30px drift keeps the number near the enemy (visible in combat) while moving enough to not overlap with subsequent numbers | 50px drift (number flies too far from action), 15px drift (overlaps with next hit) |
| Crit shake: +-2px at 0.025s intervals | 6-step shake over 0.15s is brief enough to not delay the upward drift (total lifetime still 0.6s) but creates perceptible "impact" | Longer shake (delays number readability), larger +-4px (too jittery for pixel art) |
| Rate limit: 100ms for projectile/cone/boomerang, 150ms for orbit/aura, 0ms for lightning | Projectile weapons hit 1 target at a time (fast). Orbit/aura hit many simultaneously (need stricter limit). Lightning hits infrequently (no limit needed) | Global 100ms for all (starves orbit/aura of feedback), global 150ms (knife feedback too sparse) |

---

## 11. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Performance hit on low-end devices | Low | Medium | Pool size limits, rate limiting, graceful degradation |
| Too many particles in late-game | Medium | Low | Rate limiting per weapon ensures max ~32 concurrent particles |
| Damage numbers overlap | Medium | Low | Random x-offset (-4 to +4px) + rate limiting reduce overlap |
| Visual noise from rapid-fire weapons | Low | Medium | Knife's narrow cone (-30 to +30 deg) reduces spread area |
| Perpendicular scatter on boomerang looks wrong | Low | Low | Fall back to radial scatter if playtesting reveals confusion |

---

## 12. Success Criteria

1. Every weapon hit produces colored particles at the impact point
2. Each weapon has distinct particle behavior (7 unique patterns)
3. Particles fade and disappear within 0.15-0.20 seconds
4. Damage number shows rounded damage value at enemy position
5. Normal hits show white 10px number drifting up 30px over 0.6s
6. Crits show gold 14px number with +-2px shake for 0.15s, then drift up
7. Crits produce 5 gold particles vs 3 weapon-colored for normal hits
8. No more than 60 active particles on screen at any time
9. No more than 20 active damage numbers on screen at any time
10. Pool exhaustion does not cause errors or frame drops
11. Hit feedback module is under 200 lines
12. All existing 1520+ tests pass
