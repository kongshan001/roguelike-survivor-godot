# Hit Feedback System Design

**Author**: Designer Agent
**Date**: 2026-04-17
**Round**: R20
**Status**: Design Spec
**Context**: R19 Art Agent competitive research identified two high-value visual effects from Vampire Survivors (projectile trails) and HoloCure (hit particle bursts). This spec designs the full hit feedback system including hit particles, damage numbers, crit visuals, and weapon-differentiated effects, with performance constraints for 30+ simultaneous enemies.

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
| 4 | Weapon-type differentiation | P3 | Varies by weapon |

---

## 2. Hit Particle Burst

### 2.1 Design Reference

From Art R19 competitive research (art-log.md, Section 4.3):
> HoloCure: Every attack hit produces 3-5 small particles scattering in all directions. This enhances the "every hit has feedback" gamefeel.

Our adaptation uses 3 particles per hit (reduced from HoloCure's 5 to account for higher enemy counts).

### 2.2 Particle Parameters

| Parameter | Value | Rationale |
|---|---|---|
| Particle count | 3 | Sufficient for feedback, minimal performance cost |
| Particle size | 2x2 px | Pixel art style, consistent with other effects (XP gems are 4px) |
| Particle shape | Square ColorRect | Matches project's ColorRect visual style |
| Emission point | Enemy global_position | Centered on the hit target |
| Emission direction | Random 360 degrees | Full radial scatter |
| Emission speed | 40-60 px/s (random per particle) | Slow enough to not obscure gameplay |
| Lifetime | 0.15 seconds | Extremely brief, prevents accumulation |
| Alpha curve | 1.0 -> 0.0 linear over lifetime | Clean fade-out |
| Scale curve | None (constant 2x2) | Simplicity, pixel art does not need scale variation |
| Color | Weapon primary color | Matches weapon identity (see Section 6) |

### 2.3 Frequency Limiting

Different weapon types have vastly different hit rates. Without limiting, a fully-upgraded knife (3 projectiles, 0.5s cooldown) producing 3 particles per hit could generate ~18 particles/second just from one weapon.

**Rate limits by weapon type**:

| Weapon Type | Hit Pattern | Rate Limit | Rationale |
|---|---|---|---|
| Projectile (Knife) | Multi-projectile, frequent | 1 burst per 0.1s | Prevents particle explosion from rapid fire |
| Orbit (HolyWater, Bible) | Continuous contact | 1 burst per 0.15s | Orbits hit many enemies simultaneously |
| Lightning | Single strike, 2s cooldown | 1 burst per strike (no limit) | Infrequent enough to not need limiting |
| Cone (FireStaff) | Area sweep | 1 burst per 0.1s | Covers multiple enemies per tick |
| Aura (FrostAura) | Continuous range | 1 burst per 0.15s | Constant area damage, high target count |
| Boomerang | Piercing, passes through | 1 burst per 0.1s | Can hit 2-3 enemies per pass |

**Implementation**: Each weapon maintains a `_last_hit_particle_time: float` timestamp. Before spawning particles, check `elapsed_time - _last_hit_particle_time >= RATE_LIMIT`.

### 2.4 Particle Pooling

To avoid constant Node creation/destruction, particles should be pooled:

| Parameter | Value |
|---|---|
| Pool size | 60 particles (covers ~20 simultaneous hit effects at 3 particles each) |
| Pool warm-up | Created lazily, max 60 ColorRect nodes |
| Reuse strategy | When pool is exhausted, skip particle creation (silent drop) |
| Pool parent | Arena node (not HUD, since particles exist in game world space) |

**Why 60**: At peak combat (Wave 5, 30+ enemies), assuming 5-8 simultaneous hit sources with 0.1s rate limiting, the maximum concurrent active particles is approximately 3 particles x 8 sources x (0.15s lifetime / 0.1s interval) = ~36 particles. 60 provides 67% headroom.

---

## 3. Damage Number Popup

### 3.1 Design

When an enemy takes damage, a floating number appears at the enemy's position and drifts upward.

### 3.2 Damage Number Parameters

| Parameter | Value | Rationale |
|---|---|---|
| Font size (normal hit) | 10px | Readable but not dominant |
| Font size (crit hit) | 14px | Visually distinct from normal |
| Color (normal hit) | Color(1.0, 1.0, 1.0) white | Clean, high contrast on dark background |
| Color (crit hit) | Color(1.0, 0.84, 0.0) gold | Instantly recognizable as "better" |
| Starting position | Enemy.global_position + Vector2(randf_range(-4, 4), -8) | Slightly random x-offset prevents stacking; above the enemy |
| Movement | Drift upward 30px over 0.6s | Slow upward drift, readable |
| Alpha curve | 1.0 for 0.4s, then 1.0 -> 0.0 over 0.2s | Stays readable, then fades |
| Scale curve | None for normal hits | Simplicity |
| Number format | Integer only, rounded | "5" not "5.3", pixel art games use whole numbers |

### 3.3 Damage Number Pooling

| Parameter | Value |
|---|---|
| Pool size | 20 labels (covers ~15 simultaneous damage numbers with headroom) |
| Pool warm-up | Created lazily |
| Reuse strategy | When exhausted, skip (oldest numbers are likely fading anyway) |
| Pool parent | Arena node |

**Why 20**: Most damage numbers last 0.6s. At peak combat with 8 simultaneous damage sources, 8 x 0.6s = ~5 concurrent numbers (with rate limiting). 20 provides 4x headroom for burst scenarios.

### 3.4 Damage Number Rate Limiting

Damage numbers share the same rate limit as hit particles per weapon. This means:

- If a weapon's hit particles are rate-limited to 0.1s, its damage numbers are also limited to 0.1s
- A single damage number is shown per burst, representing the total damage dealt in that burst window
- For multi-hit weapons (e.g., knife with 3 projectiles hitting the same enemy), the damage number shows the individual hit value (not summed)

**Exception**: Lightning always shows its damage number (no rate limit, since it hits infrequently).

---

## 4. Critical Hit Special Visual

### 4.1 Visual Elements

When a hit is a critical hit (`was_crit == true`), three additional visual effects trigger:

| Effect | Parameter | Value |
|---|---|---|
| **Damage number enlargement** | font_size | 14px (vs 10px normal) |
| **Damage number color** | Color | Color(1.0, 0.84, 0.0) gold |
| **Damage number shake** | Horizontal oscillation | +-2px, 3 cycles over 0.2s, then drift upward |
| **Hit particle count** | count | 5 (vs 3 normal) |
| **Hit particle color** | Color | Color(1.0, 0.84, 0.0) gold (overriding weapon color) |
| **Hit particle speed** | speed | 60-80 px/s (faster than normal) |
| **Hit particle lifetime** | lifetime | 0.2s (longer than normal) |

### 4.2 Crit Shake Animation Detail

The damage number performs a brief horizontal shake before drifting upward:

```
t=0.00s: position.x = start_x - 2
t=0.03s: position.x = start_x + 2
t=0.06s: position.x = start_x - 2
t=0.09s: position.x = start_x + 2
t=0.12s: position.x = start_x - 1
t=0.15s: position.x = start_x (settle)
t=0.15s-0.75s: drift upward 30px, alpha 1.0 -> 0.0 over last 0.2s
```

This creates a brief "impact" shake before the number floats up, making crits feel weightier.

### 4.3 Why These Specific Values

- **14px font**: 40% larger than normal (10px). Noticeable but not overwhelming. VS and HoloCure both use ~50% enlargement for crits; we use 40% to stay within pixel art scale.
- **Gold color**: Universally associated with "valuable/better" in games. Consistent with the game's gold reward color (GoldLabel, coin drops).
- **5 particles (crit) vs 3 (normal)**: 67% more particles creates a visible "burst" without doubling. The gold color further differentiates.
- **60-80 px/s crit speed**: Faster scatter communicates higher energy/impact.
- **Horizontal shake**: A micro-animation that takes 0.15s. Long enough to perceive, short enough to not delay the upward drift. This is inspired by VS crit numbers which have a brief "pop" before floating.

---

## 5. Performance Constraints

### 5.1 Global Limits

| Resource | Max Budget | Rationale |
|---|---|---|
| Active hit particles | 60 | Pool size limit |
| Active damage numbers | 20 | Pool size limit |
| Particle creation rate | 30 bursts/s (across all weapons) | Prevents frame time spikes from Node creation |
| Memory per particle | ~200 bytes (ColorRect + Tween) | 60 particles = ~12KB, negligible |
| Memory per damage number | ~300 bytes (Label + Tween) | 20 numbers = ~6KB, negligible |

### 5.2 Frame Budget

At 60 FPS target:
- Particle creation: 0.5ms max (3 ColorRect instantiations per burst, from pool)
- Tween creation: 0.3ms max (3 particle tweens + 1 number tween per burst)
- Total per-frame hit feedback cost: ~1ms at peak combat
- This is within the 16ms frame budget (6.25% of a 60 FPS frame)

### 5.3 Graceful Degradation

When pools are exhausted:
1. Hit particles: Skip creation silently. No visual artifact.
2. Damage numbers: Skip creation silently. Player still sees hit flash on enemy sprite.
3. Priority: Crit damage numbers have priority over normal damage numbers. If pool has only 1 slot, crit gets it.

**Implementation**: Pool returns `null` when exhausted. Caller checks and skips.

---

## 6. Weapon-Differentiated Feedback

### 6.1 Weapon Particle Colors

Each weapon type uses its primary color for hit particles. This creates visual variety and helps players identify which weapon is dealing damage.

| Weapon | Particle Color | Godot Color | Rationale |
|---|---|---|---|
| Knife | Silver-white | Color(0.75, 0.75, 0.8) | Sharp, metallic feel |
| HolyWater | Blue | Color(0.3, 0.5, 1.0) | Water/magic identity |
| Lightning | Yellow | Color(1.0, 1.0, 0.3) | Electric identity |
| Bible | Cream | Color(0.9, 0.85, 0.7) | Holy/divine identity |
| FireStaff | Orange-red | Color(1.0, 0.4, 0.1) | Fire identity |
| FrostAura | Ice blue | Color(0.5, 0.8, 1.0) | Ice identity |
| Boomerang | Brown | Color(0.6, 0.4, 0.2) | Wood/earthy identity |

**Color source**: Matches the weapon color definitions in art-log.md Section "Weapon Colors".

### 6.2 Weapon-Specific Particle Behaviors

Beyond color, some weapons have differentiated particle patterns:

| Weapon | Differentiation | Detail |
|---|---|---|
| Lightning | Directional burst | Particles scatter in a cone away from the strike point (not 360 random), matching lightning's "striking down" direction |
| FireStaff | Lingering ember | 1 of 3 particles has a 0.3s lifetime (others 0.15s) and orange->dark-red color shift, simulating an ember |
| FrostAura | Slow scatter | Particles move at 20-30 px/s (slower than standard 40-60), simulating ice crystals drifting |
| Boomerang | Arc trajectory | Particles scatter perpendicular to boomerang's flight direction (not random 360) |

These differentiations are P3 (polish). The baseline implementation uses identical behavior for all weapons (360 random, same speed) with only color varying.

### 6.3 Evolved Weapon Particles

Evolved weapons use a blend of their parent weapon colors:

| Evolved Weapon | Particle Color | Blend |
|---|---|---|
| thunderholywater | Color(0.65, 0.75, 0.65) | Blue + Yellow blend |
| fireknife | Color(0.88, 0.58, 0.45) | Silver + Orange blend |
| holydomain | Color(0.6, 0.68, 0.85) | Cream + Blue blend |
| blizzard | Color(0.75, 0.9, 0.65) | Ice Blue + Yellow blend |
| frostknife | Color(0.63, 0.78, 0.9) | Silver + Ice Blue blend |
| flamebible | Color(0.95, 0.63, 0.4) | Cream + Orange blend |
| thunderang | Color(0.8, 0.7, 0.25) | Brown + Yellow blend |
| blazerang | Color(0.8, 0.4, 0.15) | Brown + Orange blend |

**Simplification for P2 implementation**: All evolved weapons can use gold particles (Color(1.0, 0.84, 0.0)) as a generic "evolved" indicator. The color blending is a P3 polish pass.

---

## 7. Integration Points

### 7.1 Where to Trigger Hit Feedback

Hit feedback is triggered in `enemy.gd` `take_damage()`:

**Current code** (line 201-213):
```gdscript
func take_damage(amount: float, source: String = "", was_crit: bool = false):
    if not is_alive:
        return
    if source != "":
        _last_hit_by = source
    _was_crit = was_crit
    current_hp -= amount
    # Play hit feedback (flash + shake) via death effects module
    var sprite_node: Sprite2D = $Sprite as Sprite2D
    if sprite_node and is_instance_valid(sprite_node):
        _get_death_effects().play_hit_feedback(self, sprite_node)
    if current_hp <= 0:
        die()
```

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

### 7.2 Hit Feedback Module

**New file**: `scripts/hit_feedback.gd` (RefCounted, similar to enemy_death_effects.gd)

This module encapsulates:
- Particle pool management
- Damage number pool management
- Rate limiting per weapon
- Weapon color lookup
- Crit vs normal differentiation

**Estimated size**: ~120 lines

### 7.3 Implementation Scope

| File | Change | Lines |
|---|---|---|
| `scripts/hit_feedback.gd` | New file: particle pool, damage number pool, rate limiting | ~120 |
| `scripts/enemy.gd` | Add `_spawn_hit_feedback()` call in `take_damage()` | ~5 |
| `scripts/arena.gd` | Add particle/number pool node containers | ~10 |
| **Total** | | **~135** |

---

## 8. Projectile Trail Effect

### 8.1 Design Reference

From Art R19 competitive research (art-log.md, Section 4.1):
> VS: Projectile weapons leave brief semi-transparent afterimages during flight.

### 8.2 Trail Parameters

| Parameter | Value | Rationale |
|---|---|---|
| Afterimage count | 2 per projectile | Lightweight, two dots convey motion |
| Afterimage spacing | 8px behind projectile | Spaced along the velocity vector's reverse direction |
| Afterimage color | Projectile color | Same as the projectile itself |
| Afterimage alpha | 0.3 (first), 0.15 (second) | Quick fade, subtle |
| Afterimage lifetime | 0.15s | Extremely brief |
| Spawn frequency | Every 3 physics frames | Not every frame, saves performance |
| Applicable weapons | Knife, Boomerang (and evolved variants) | Only projectile-type weapons need trails |

### 8.3 Implementation Note

Trails are spawned in `projectile.gd` `_physics_process()`:
```gdscript
# Pseudocode
var _trail_counter: int = 0

func _physics_process(delta: float) -> void:
    _trail_counter += 1
    if _trail_counter % 3 == 0:
        _spawn_trail_afterimage()
```

Each afterimage is a small ColorRect (4x4 px) placed at the projectile's previous position, auto-freed after 0.15s.

**Estimated lines**: ~20 in projectile.gd

---

## 9. Combined Effect Priority

All hit feedback effects ranked by implementation priority:

| Priority | Effect | Player Impact | Lines | Status |
|---|---|---|---|---|
| P2-A | Hit particle burst (3 particles, weapon color) | HIGH -- core gamefeel | ~60 | Must-have |
| P2-B | Damage number popup (white, drift up) | HIGH -- information | ~40 | Must-have |
| P2-C | Crit visual (gold, 14px, shake, 5 particles) | MEDIUM -- excitement | ~30 | Should-have |
| P2-D | Projectile trail (knife/boomerang) | LOW -- polish | ~20 | Nice-to-have |
| P3-A | Weapon-specific particle behaviors | LOW -- variety | ~30 | Polish |
| P3-B | Evolved weapon color blends | LOW -- variety | ~10 | Polish |

**Minimum viable hit feedback**: P2-A + P2-B + P2-C (damage numbers with crit differentiation). This provides the core gamefeel improvement with ~130 lines.

---

## 10. Decision Record

| Decision | Why | Alternative Considered |
|---|---|---|
| 3 particles per hit (not 5-8) | Our game has 30+ simultaneous enemies vs HoloCure's ~15. 3 particles per hit with 0.1s rate limit = max ~30 particles on screen at once, well within budget | 5 particles (HoloCure standard) -- too many at our enemy density |
| ColorRect particles (not GPUParticles2D) | Consistent with project's "code-driven visuals" approach. GPUParticles2D requires .tscn configuration, ProcessMaterial, and is overkill for 3 particles | GPUParticles2D (more polished but heavier setup, inconsistent with project style) |
| 2x2 pixel particle size | Matches the pixel art aesthetic. Larger particles (4x4) would be too chunky for a "subtle burst" feel | 4x4 (too large for burst effect) |
| 0.15s particle lifetime | Brief enough to not accumulate during rapid combat, long enough to be perceptible | 0.3s (too long, particles would stack) |
| Damage number integer format | Pixel art games traditionally use whole numbers. Decimal damage creates "floaty" feeling. Our damage values are already mostly integers (knife=3, boomerang=5, etc.) | One decimal place (unnecessary precision for our damage ranges) |
| 10px normal / 14px crit font size | 10px is readable without dominating. 14px is noticeably larger. The 4px difference is clear in pixel art | 8px/12px (too small for normal), 12px/16px (too large for crit) |
| Gold for crit (not red) | Gold universally means "valuable/rewarding" in games. Red means "danger/damage" which would confuse the meaning. VS uses gold for crits, confirming this convention | Red (wrong connotation for player-initiated damage) |
| Pooled particles and numbers | Avoids GC pressure from constant create/destroy cycles in combat | On-demand creation (simpler but causes frame hitches in sustained combat) |
| Rate limiting per weapon (not global) | Global rate limit would cause weapons to "steal" each other's feedback slots. Per-weapon ensures each weapon always produces some feedback | Global limit (simpler but causes feedback starvation for multi-weapon builds) |
| Weapon color for particles (not enemy color) | The particle communicates "this weapon hit," not "this enemy was hit." Player cares about which weapon is performing | Enemy color (would be visually confusing with same-colored enemies) |

---

## 11. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Performance hit on low-end devices | Low | Medium | Pool size limits, rate limiting, graceful degradation when pools exhausted |
| Too many particles in late-game | Medium | Low | Rate limiting per weapon (0.1s) ensures max ~30 simultaneous particles |
| Damage numbers overlap and become unreadable | Medium | Low | Random x-offset (-4 to +4px) and staggered rate limiting reduce overlap |
| Visual noise detracts from gameplay | Low | Medium | Small particle size (2x2) and brief lifetime (0.15s) keep effects subtle |
| Crit shake causes motion sickness | Very Low | Low | Shake is only +-2px for 0.15s, well below comfort threshold |

---

## 12. Success Criteria

1. Every weapon hit produces 3 colored particles at the impact point
2. Particles match weapon color (7 distinct colors)
3. Particles fade and disappear within 0.15 seconds
4. Damage number shows rounded damage value at enemy position
5. Normal hits show white 10px number, crits show gold 14px number with shake
6. Crits produce 5 gold particles (vs 3 weapon-colored for normal hits)
7. No more than 60 active particles on screen at any time
8. No more than 20 active damage numbers on screen at any time
9. Pool exhaustion does not cause errors or frame drops
10. Hit feedback module is under 150 lines
11. All existing 1398+ tests pass
