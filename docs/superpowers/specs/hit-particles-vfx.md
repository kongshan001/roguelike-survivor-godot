# Hit Particles VFX Design

**Author**: Art Agent
**Date**: 2026-04-17
**Round**: R20
**Status**: Design Spec
**Context**: R19 competitive analysis (HoloCure hit particle burst) identified hit feedback as a P2 visual enhancement for v1.0.2. This spec defines weapon-differentiated hit particle effects using ColorRect (no new PNG assets required).

---

## 1. System Overview

### 1.1 Concept

Hit particles are small ColorRect-based particles spawned at the point of impact when a weapon hits an enemy. Each weapon type has a unique particle shape, color, and behavior to provide differentiated combat feedback.

### 1.2 Design Goals

1. **Differentiated weapon identity**: Each weapon produces visually distinct hit particles, reinforcing the weapon's elemental theme.
2. **Performance-safe**: Maximum 100 simultaneous particles on screen. Auto-culling enforced.
3. **ColorRect-only**: No new PNG assets. All particles are small ColorRect nodes with size/color/alpha controlled by Tween.
4. **Crit vs normal distinction**: Critical hits produce more particles with a gold flash and screen micro-shake.

### 1.3 Trigger Rules

| Condition | Trigger | Frequency Limit |
|-----------|---------|-----------------|
| Projectile hits enemy (knife, holywater orb, boomerang) | On `_on_body_entered` | Per-hit (no limit, projectile frequency is inherently bounded) |
| Lightning strikes | On `_fire_lightning` completion | Per-strike |
| Cone damage (firestaff) | On `_fire_cone` enemy detection | 0.1s cooldown per target |
| Aura tick (frostaura) | On aura damage tick | 0.2s cooldown per target |
| Bible orbit contact | On spin_blade contact | 0.15s cooldown per target |
| Critical hit (any weapon) | On damage with was_crit=true | Same as weapon + additional crit particles |

---

## 2. Normal Hit Particles (Per-Weapon)

### 2.1 Universal Parameters

All normal hit particles share these base parameters:

| Parameter | Value | Notes |
|-----------|-------|-------|
| Particle count | 3 | Lightweight, avoids visual clutter |
| Particle size | 2x2 px ColorRect | Extremely small, subtle feedback |
| Lifetime | 0.15s | Brief flash |
| Alpha decay | 1.0 -> 0.0 | Linear over lifetime |
| Spread | 360 degrees random | Full circle scatter |
| Speed | 40-60 px/s | Slow, non-distracting |
| Node type | ColorRect (code-spawned) | No PNG needed |

### 2.2 Weapon-Specific Differentiation

Each weapon type overrides the base parameters with unique values:

#### Knife (飞刀) -- Red Arc Particles

| Parameter | Value | Notes |
|-----------|-------|-------|
| Shape | 1x3 px horizontal ColorRect | Simulates a slash mark |
| Color | Color(0.95, 0.25, 0.25) #F24040 red | Warm red, distinct from blood |
| Count | 3 | Standard |
| Spread | 90-degree cone in attack direction | Directional slash |
| Speed | 50-70 px/s | Slightly faster for slash feel |
| Rotation | Random -30 to +30 degrees | Slight angle variation |
| Lifetime | 0.12s | Shorter, snappier |

**Visual description**: Three thin red horizontal streaks fly outward from the hit point in a narrow cone along the knife's travel direction. Creates a "slashing" feel.

#### Holy Water (圣水) -- Blue Ring Particles

| Parameter | Value | Notes |
|-----------|-------|-------|
| Shape | 3x3 px square ColorRect | Blocky splash |
| Color | Color(0.3, 0.5, 1.0) #4D80FF blue | Matches holy_water.png |
| Count | 3 | Standard |
| Spread | 360 degrees | Full splash |
| Speed | 30-45 px/s | Slow, heavy liquid |
| Scale decay | 1.0 -> 0.3 | Shrink as well as fade |
| Lifetime | 0.18s | Slightly longer, liquid |

**Visual description**: Three small blue squares scatter in all directions from the orbit contact point, shrinking and fading. Simulates a splash of holy water.

#### Lightning (闪电) -- Blue Jagged Particles

| Parameter | Value | Notes |
|-----------|-------|-------|
| Shape | 1x2 px vertical ColorRect | Tiny spark |
| Color | Color(1.0, 1.0, 0.3) #FFFF4D bright yellow | Lightning yellow |
| Count | 4 | Extra spark for lightning |
| Spread | 360 degrees | Full scatter |
| Speed | 60-90 px/s | Fast electric sparks |
| Flash alpha | Blinks 1.0 -> 0.3 -> 0.8 -> 0.0 | Stuttering decay |
| Lifetime | 0.10s | Very short, electric |

**Visual description**: Four tiny bright yellow vertical streaks scatter rapidly from the lightning strike point, stuttering in opacity as they disappear. Creates an "electric spark" feel.

#### Bible (圣经) -- White Cross Particles

| Parameter | Value | Notes |
|-----------|-------|-------|
| Shape | 2x2 px cross (two overlapping 1x2 + 2x1 ColorRect) | Tiny cross shape |
| Color | Color(0.95, 0.92, 0.85) #F2EBD9 warm white | Matches bible.png parchment |
| Count | 2 | Fewer, calmer |
| Spread | 360 degrees | Full scatter |
| Speed | 25-35 px/s | Slow, reverent |
| Lifetime | 0.20s | Longer, lingering |
| Rotation | 0 or 90 degrees only | Aligned crosses |

**Visual description**: Two small white crosses gently scatter outward from the orbit contact point, slowly fading. Peaceful, divine feel contrasting the violence of combat.

#### Fire Staff (火法) -- Orange Fire Particles

| Parameter | Value | Notes |
|-----------|-------|-------|
| Shape | 2x3 px vertical ColorRect | Flame tongue shape |
| Color | Color(1.0, 0.45, 0.1) #FF7319 orange | Fire orange |
| Count | 4 | More particles for fire |
| Spread | Upper 180 degrees (upward bias) | Fire rises |
| Speed | 35-55 px/s upward, 20-30 px/s horizontal | Fire drift |
| Gravity | -40 px/s^2 (upward) | Float upward |
| Lifetime | 0.25s | Longer, fire lingers |

**Visual description**: Four small orange flame tongues drift upward and outward from the cone impact point, simulating sparks flying off a fire. Upward bias creates "rising heat" feel.

#### Frost Aura (冰霜) -- Ice Blue Diamond Particles

| Parameter | Value | Notes |
|-----------|-------|-------|
| Shape | 2x2 px rotated 45 degrees (diamond) | Ice crystal |
| Color | Color(0.55, 0.85, 1.0) #8DD9FF ice blue | Frost aura color |
| Count | 2 | Minimal, aura is ambient |
| Spread | 360 degrees | Full scatter |
| Speed | 15-25 px/s | Very slow, crystalline |
| Scale decay | 1.0 -> 0.0 | Shrink to nothing |
| Lifetime | 0.30s | Longest, icy persistence |
| Rotation | Fixed 45 degrees | Diamond orientation |

**Visual description**: Two tiny ice-blue diamonds slowly drift outward from the aura contact point, gradually shrinking to nothing. Slow and crystalline, matching the aura's ambient nature.

#### Boomerang (回旋镖) -- Brown Streak Particles

| Parameter | Value | Notes |
|-----------|-------|-------|
| Shape | 1x3 px horizontal ColorRect | Motion streak |
| Color | Color(0.6, 0.4, 0.2) #996633 brown | Matches boomerang.png |
| Count | 3 | Standard |
| Spread | 120-degree cone in travel direction | Behind the boomerang |
| Speed | 40-55 px/s | Moderate |
| Lifetime | 0.12s | Short, streak |
| Rotation | Perpendicular to travel direction | Streak follows path |

**Visual description**: Three thin brown streaks trail behind the boomerang's path as it hits enemies, creating a "slicing trail" effect.

---

## 3. Critical Hit Particles

### 3.1 Enhanced Parameters

Critical hits override the normal hit particles with enhanced values:

| Parameter | Normal | Critical | Notes |
|-----------|--------|----------|-------|
| Particle count | 3 | 5 | More visual impact |
| Particle size | 2x2 px | 3x3 px | 50% larger |
| Particle color | Weapon primary | Color(1.0, 0.85, 0.0) #FFD700 gold | Gold regardless of weapon |
| Speed | 40-60 px/s | 60-90 px/s | Faster burst |
| Lifetime | 0.15s | 0.20s | Longer visibility |
| Screen shake | None | 1.5 strength, 0.05s | Micro-shake on crit |

### 3.2 Crit Gold Particles

| Parameter | Value |
|-----------|-------|
| Shape | 3x3 px ColorRect |
| Color | Color(1.0, 0.85, 0.0) gold |
| Count | 5 |
| Spread | 360 degrees |
| Speed | 60-90 px/s |
| Alpha decay | 1.0 -> 0.0, 0.20s |
| Scale decay | 1.0 -> 0.5, 0.20s |
| Screen shake | Strength 1.5, decay 30.0/s |

**Visual description**: Five gold particles burst outward from the crit impact point, accompanied by a brief screen micro-shake. The gold color unifies all crit feedback across weapons (matching the crit damage number color).

### 3.3 Crit + Normal Layering

On a critical hit, BOTH the weapon-specific normal particles AND the gold crit particles spawn simultaneously. This creates a two-layer effect:

1. **Inner layer**: 3 weapon-colored particles (weapon identity)
2. **Outer layer**: 5 gold particles (crit celebration)

Total particles per crit: 8 (3 normal + 5 gold)

---

## 4. Performance Constraints

### 4.1 Global Particle Budget

| Constraint | Value | Enforcement |
|------------|-------|-------------|
| Max simultaneous particles | 100 | Hard cap. Oldest particles are culled first. |
| Particle pool | Pre-allocate 100 ColorRect nodes | Object pool pattern. Reuse instead of instantiate/free. |
| Spawn rate limit | Per weapon (see Section 2.2) | Prevents high-frequency weapons from flooding |
| Max particles per frame | 15 | If >15 spawn requests in one frame, skip the rest |

### 4.2 Object Pool Implementation

```gdscript
# Pseudocode for HitParticlePool
const MAX_PARTICLES: int = 100

var _pool: Array[ColorRect] = []
var _active: Array[Dictionary] = []  # {rect, velocity, lifetime, age}

func _ready() -> void:
    for i in MAX_PARTICLES:
        var rect := ColorRect.new()
        rect.visible = false
        add_child(rect)
        _pool.append(rect)

func spawn(pos: Vector2, color: Color, size: Vector2, velocity: Vector2, lifetime: float) -> void:
    if _pool.is_empty():
        # Cull oldest active particle
        _recycle_oldest()
    var rect: ColorRect = _pool.pop_back()
    rect.position = pos
    rect.size = size
    rect.color = color
    rect.visible = true
    _active.append({
        "rect": rect,
        "velocity": velocity,
        "lifetime": lifetime,
        "age": 0.0
    })

func _process(delta: float) -> void:
    var i: int = _active.size() - 1
    while i >= 0:
        var entry: Dictionary = _active[i]
        entry.age += delta
        if entry.age >= entry.lifetime:
            _recycle(i)
        else:
            var progress: float = entry.age / entry.lifetime
            entry.rect.position += entry.velocity * delta
            entry.rect.color.a = 1.0 - progress
        i -= 1
```

### 4.3 Performance Impact Estimate

| Scenario | Active Particles | Impact |
|----------|-----------------|--------|
| 1 enemy, 1 weapon | 3-5 | Negligible |
| 10 enemies, 1 weapon (normal) | ~15 | Low |
| 30 enemies, 2 weapons (late game) | ~40-60 | Moderate |
| 30 enemies, crit burst | ~80-100 (at cap) | Managed by cap |

---

## 5. ColorRect Fallback (No PNG Required)

All hit particles are implemented as ColorRect nodes created in code. No PNG sprites are needed. Each particle is a small ColorRect with:
- `color` set to weapon-specific color
- `size` set to 2x2 or 3x3 pixels
- Position, alpha, and scale controlled by Tween or manual _process

### 5.1 Color Reference Table

| Weapon | Normal Particle Color | Hex | Source |
|--------|----------------------|-----|--------|
| Knife | Color(0.95, 0.25, 0.25) | #F24040 | Red, warm slash |
| Holy Water | Color(0.3, 0.5, 1.0) | #4D80FF | holy_water.png blue |
| Lightning | Color(1.0, 1.0, 0.3) | #FFFF4D | Lightning yellow |
| Bible | Color(0.95, 0.92, 0.85) | #F2EBD9 | bible.png parchment |
| Fire Staff | Color(1.0, 0.45, 0.1) | #FF7319 | Fire orange |
| Frost Aura | Color(0.55, 0.85, 1.0) | #8DD9FF | Frost aura ice blue |
| Boomerang | Color(0.6, 0.4, 0.2) | #996633 | boomerang.png brown |
| Critical (all) | Color(1.0, 0.85, 0.0) | #FFD700 | Gold, crit universal |

### 5.2 Shape Reference Table

| Weapon | Particle Shape | Size (px) | Unique Behavior |
|--------|---------------|-----------|-----------------|
| Knife | Horizontal streak | 1x3 | Directional cone, slash angle |
| Holy Water | Square splash | 3x3 | Shrink + fade |
| Lightning | Vertical spark | 1x2 | Stuttering alpha (flash) |
| Bible | Cross (two rects) | 2x2 composite | Slow, aligned rotation |
| Fire Staff | Vertical flame | 2x3 | Upward drift, gravity |
| Frost Aura | Diamond (rotated) | 2x2 | Very slow, shrink to zero |
| Boomerang | Horizontal streak | 1x3 | Trail direction, perpendicular |
| Critical | Square | 3x3 | Gold, faster, + screen shake |

---

## 6. Implementation Scope

### 6.1 File Changes

| File | Change | Lines |
|------|--------|-------|
| New: `scripts/effects/hit_particle_pool.gd` | Object pool + spawn logic | ~80 |
| `scripts/weapon_effects.gd` | Trigger hit particles on weapon hit | ~25 |
| `scripts/arena.tscn` | Add HitParticlePool node | ~3 |
| `test/unit/test_hit_particles.gd` | Pool capacity, spawn, cull tests | ~40 |
| **Total** | | **~148** |

### 6.2 Integration Points

Each weapon type calls `HitParticlePool.spawn_weapon_hit(weapon_id, position, direction)`:

| Weapon | Call Location | Notes |
|--------|--------------|-------|
| Knife (projectile) | `projectile.gd _on_body_entered` | Direction = projectile velocity direction |
| Holy Water (orbit) | `spin_blade.gd` contact check | Direction = orbit tangential |
| Lightning | `weapon_effects.gd _fire_lightning` | Direction = from player to target |
| Bible (orbit) | `spin_blade.gd` contact check | Direction = orbit tangential |
| Fire Staff (cone) | `weapon_effects.gd _fire_cone` | Direction = cone center angle |
| Frost Aura | `weapon_effects.gd _fire_aura` tick | Direction = random |
| Boomerang | `boomerang.gd` hit detection | Direction = boomerang velocity direction |
| Critical | Any weapon `take_damage(was_crit=true)` | Layered on top of normal |

---

## 7. Decision Record

| Decision | Why | Alternative Considered |
|----------|-----|----------------------|
| ColorRect instead of GPUParticles2D | Consistent with project pixel art approach. No ProcessMaterial configuration needed. Object pool has predictable performance. | GPUParticles2D (too heavy for 100+ simultaneous, overkill for 2px particles) |
| 3 particles per normal hit | HoloCure uses 5-8 but has fewer enemies. Our game can have 30+ enemies simultaneously. 3 is the sweet spot between feedback and performance. | 1 (too subtle), 5 (too many in dense combat) |
| 100 global particle cap | At 30 enemies x 2 weapons x 3 particles = 180 theoretical max. 100 cap prevents worst-case scenarios while preserving visual density. | 50 (too aggressive culling), 200 (performance risk) |
| Weapon-specific particle shapes | Differentiated shapes (streak/splash/spark/cross/flame/diamond) reinforce weapon identity even at 2px size. | Uniform squares (simpler but loses weapon differentiation) |
| Gold color for all crit particles | Gold is the universal "special" color in the project (coins, achievements, mastery Master tier). Unified crit color creates consistent "critical hit!" signal. | Weapon-colored crits (less distinct from normal hits) |
| Pre-allocated object pool | Avoids per-frame malloc/free overhead. ColorRect nodes are reused. | Dynamic spawn/queue_free (GC pressure under heavy combat) |
| Per-weapon frequency limits | Prevents aura/lightning (continuous damage) from flooding the particle system. | Global rate limit (would unfairly throttle burst weapons like knife) |
