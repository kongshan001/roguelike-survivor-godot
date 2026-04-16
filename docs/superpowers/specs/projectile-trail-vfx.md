# Projectile Trail VFX Design

**Author**: Designer Agent
**Date**: 2026-04-17
**Round**: R21 (refined from R20)
**Status**: Design Spec
**Context**: R20 defined the projectile trail system with per-weapon colors and behaviors. R21 provides exact trail generation intervals (in milliseconds), alpha decay curves (per-frame values), size decay curves, evolved-vs-base weapon parameter differences, and precise object pool sizes for direct implementation.

---

## 1. System Overview

### 1.1 Concept

Projectile trails are semi-transparent ColorRect afterimages left behind by moving projectiles (knives, boomerangs, evolved weapon projectiles). Each trail segment is placed at the projectile's previous position at fixed intervals, fading out over its lifetime.

### 1.2 Design Goals

1. **Enhance motion perception**: Trails communicate projectile speed and direction at a glance.
2. **Weapon differentiation**: Each weapon type has a unique trail color and behavior.
3. **Performance-safe**: Object pool with hard cap. Trails are lightweight ColorRect nodes.
4. **No new PNG required**: Trails are pure ColorRect with modulate color and alpha decay.

### 1.3 Applicable Weapons

| Weapon | Type | Has Projectile | Trail | Speed (px/s) | Reason |
|--------|------|---------------|-------|--------------|--------|
| Knife | Projectile | Yes | **Yes** | 350 | Classic trail for throwing knives |
| Holy Water | Orbit | No (orbit) | No | -- | Orbits rotate in place |
| Lightning | Instant | No (Line2D) | No | -- | Instant strike, no traveling |
| Bible | Orbit | No (orbit) | No | -- | Same as Holy Water |
| Fire Staff | Cone | No (instant) | No | -- | Instant area effect |
| Frost Aura | Aura | No (continuous) | No | -- | Continuous radius effect |
| Boomerang | Boomerang | Yes | **Yes** | 280 | Trail enhances curved flight path |
| FireKnife (evolved) | Projectile | Yes | **Yes** | 400 | Fire trail is signature visual |
| FrostKnife (evolved) | Projectile | Yes | **Yes** | 380 | Ice trail for visual identity |
| Thunderang (evolved) | Boomerang | Yes | **Yes** | 280 | Electric trail |
| Blazerang (evolved) | Boomerang | Yes | **Yes** | 280 | Fire trail |

**Total trail-enabled weapons**: 6 (2 base + 4 evolved)

**Speed source**: All speeds from `upgrade_pool.gd` weapon registrations and `weapon_boomerang_fire.gd` BOOMERANG_SPEED constant.

---

## 2. Trail Generation Interval

### 2.1 Interval Definition

Trail segments are spawned at fixed time intervals, not frame intervals, to ensure consistent behavior regardless of framerate.

| Weapon | Speed (px/s) | Generation Interval | Gap Between Segments | Rationale |
|--------|-------------|---------------------|---------------------|-----------|
| Knife | 350 | 50 ms (0.050s) | 17.5 px | Fast projectile, frequent segments |
| Boomerang | 280 | 60 ms (0.060s) | 16.8 px | Medium speed, medium interval |
| FireKnife | 400 | 40 ms (0.040s) | 16.0 px | Fastest projectile, dense trail for fire effect |
| FrostKnife | 380 | 45 ms (0.045s) | 17.1 px | Fast, slightly denser than knife |
| Thunderang | 280 | 60 ms (0.060s) | 16.8 px | Same speed as base boomerang |
| Blazerang | 280 | 50 ms (0.050s) | 14.0 px | Slightly denser than Thunderang (fire lingers) |

**Gap calculation**: interval_seconds x speed_px_per_sec = gap_px. Target gap is ~15-18 px for visual continuity.

### 2.2 Interval to Frames Conversion (60 FPS)

| Weapon | Interval (ms) | Frames Between Spawns | Implementation Counter |
|--------|--------------|----------------------|----------------------|
| Knife | 50 ms | 3 frames | `_trail_timer += 1; if _trail_timer >= 3` |
| Boomerang | 60 ms | 4 frames | `_trail_timer += 1; if _trail_timer >= 4` |
| FireKnife | 40 ms | 2 frames | `_trail_timer += 1; if _trail_timer >= 2` |
| FrostKnife | 45 ms | 3 frames | `_trail_timer += 1; if _trail_timer >= 3` |
| Thunderang | 60 ms | 4 frames | `_trail_timer += 1; if _trail_timer >= 4` |
| Blazerang | 50 ms | 3 frames | `_trail_timer += 1; if _trail_timer >= 3` |

**Why timer-based (delta accumulation) is preferred over frame counting**: Delta accumulation handles variable framerates correctly. However, at 60 FPS the frame counts above are the practical implementation. The code should use `delta` accumulation for robustness:

```gdscript
var _trail_timer: float = 0.0

func _physics_process(delta: float) -> void:
    _trail_timer += delta
    var interval: float = _get_trail_interval()
    if _trail_timer >= interval:
        _trail_timer -= interval
        _spawn_trail_segment()
```

---

## 3. Alpha Decay Curves

### 3.1 Universal Alpha Decay Formula

Each trail segment's alpha follows a linear decay from `alpha_start` to 0.0 over its lifetime.

```
current_alpha = alpha_start * (1.0 - (elapsed / lifetime))
```

### 3.2 Per-Weapon Alpha Parameters

| Weapon | Alpha Start | Lifetime | Alpha at 33% life | Alpha at 66% life | Alpha at 100% life |
|--------|------------|----------|-------------------|-------------------|-------------------|
| Knife | 0.30 | 0.12s | 0.20 | 0.10 | 0.00 |
| Boomerang | 0.25 | 0.18s | 0.17 | 0.08 | 0.00 |
| FireKnife | 0.40 | 0.20s | 0.27 | 0.13 | 0.00 |
| FrostKnife | 0.35 | 0.18s | 0.23 | 0.12 | 0.00 |
| Thunderang | 0.30 | 0.15s | 0.20 | 0.10 | 0.00 |
| Blazerang | 0.40 | 0.22s | 0.27 | 0.13 | 0.00 |

**Per-frame alpha values (at 60 FPS)**:

**Knife (lifetime 0.12s = ~7 frames)**:

| Frame | Elapsed (s) | Alpha |
|-------|------------|-------|
| 0 | 0.000 | 0.300 |
| 1 | 0.017 | 0.258 |
| 2 | 0.033 | 0.217 |
| 3 | 0.050 | 0.175 |
| 4 | 0.067 | 0.133 |
| 5 | 0.083 | 0.092 |
| 6 | 0.100 | 0.050 |
| 7 | 0.117 | 0.008 |

**Boomerang (lifetime 0.18s = ~11 frames)**:

| Frame | Elapsed (s) | Alpha |
|-------|------------|-------|
| 0 | 0.000 | 0.250 |
| 1 | 0.017 | 0.227 |
| 2 | 0.033 | 0.204 |
| 3 | 0.050 | 0.181 |
| 4 | 0.067 | 0.158 |
| 5 | 0.083 | 0.135 |
| 6 | 0.100 | 0.112 |
| 7 | 0.117 | 0.088 |
| 8 | 0.133 | 0.065 |
| 9 | 0.150 | 0.042 |
| 10 | 0.167 | 0.019 |

**FireKnife (lifetime 0.20s = ~12 frames)**:

| Frame | Elapsed (s) | Alpha |
|-------|------------|-------|
| 0 | 0.000 | 0.400 |
| 1 | 0.017 | 0.365 |
| 2 | 0.033 | 0.330 |
| 3 | 0.050 | 0.295 |
| 4 | 0.067 | 0.260 |
| 5 | 0.083 | 0.225 |
| 6 | 0.100 | 0.190 |
| 7 | 0.117 | 0.155 |
| 8 | 0.133 | 0.120 |
| 9 | 0.150 | 0.085 |
| 10 | 0.167 | 0.050 |
| 11 | 0.183 | 0.015 |

**FrostKnife (lifetime 0.18s = ~11 frames)**:

| Frame | Elapsed (s) | Alpha |
|-------|------------|-------|
| 0 | 0.000 | 0.350 |
| 1 | 0.017 | 0.319 |
| 2 | 0.033 | 0.287 |
| 3 | 0.050 | 0.256 |
| 4 | 0.067 | 0.225 |
| 5 | 0.083 | 0.193 |
| 6 | 0.100 | 0.162 |
| 7 | 0.117 | 0.131 |
| 8 | 0.133 | 0.099 |
| 9 | 0.150 | 0.068 |
| 10 | 0.167 | 0.037 |

**Thunderang (lifetime 0.15s = ~9 frames, with alpha flicker)**:

| Frame | Elapsed (s) | Base Alpha | Flicker (+-0.08) | Effective Range |
|-------|------------|------------|-------------------|-----------------|
| 0 | 0.000 | 0.300 | +-0.08 | 0.22 - 0.38 |
| 1 | 0.017 | 0.267 | +-0.08 | 0.19 - 0.35 |
| 2 | 0.033 | 0.233 | +-0.08 | 0.15 - 0.31 |
| 3 | 0.050 | 0.200 | +-0.08 | 0.12 - 0.28 |
| 4 | 0.067 | 0.167 | +-0.08 | 0.09 - 0.25 |
| 5 | 0.083 | 0.133 | +-0.08 | 0.05 - 0.21 |
| 6 | 0.100 | 0.100 | +-0.08 | 0.02 - 0.18 |
| 7 | 0.117 | 0.067 | +-0.08 | 0.00 - 0.15 |
| 8 | 0.133 | 0.033 | +-0.08 | 0.00 - 0.11 |

**Flicker implementation**: Each frame, add `randf_range(-0.08, 0.08)` to the base alpha, clamped to [0.0, 1.0]. This creates the electric "stuttering" visual.

**Blazerang (lifetime 0.22s = ~13 frames)**:

| Frame | Elapsed (s) | Alpha |
|-------|------------|-------|
| 0 | 0.000 | 0.400 |
| 1 | 0.017 | 0.370 |
| 2 | 0.033 | 0.340 |
| 3 | 0.050 | 0.310 |
| 4 | 0.067 | 0.280 |
| 5 | 0.083 | 0.250 |
| 6 | 0.100 | 0.220 |
| 7 | 0.117 | 0.190 |
| 8 | 0.133 | 0.155 |
| 9 | 0.150 | 0.125 |
| 10 | 0.167 | 0.095 |
| 11 | 0.183 | 0.065 |
| 12 | 0.200 | 0.035 |

---

## 4. Size Decay Curves

### 4.1 Size Decay Formula

Most weapons use no size decay (constant size). Two weapons have special size curves:

- **FireKnife**: Shrinks from 1.0x to 0.7x over lifetime (flame dwindling)
- **FrostKnife**: Shrinks from 1.0x to 0.5x over lifetime (ice dissolving)
- **Blazerang**: Grows from 1.0x to 1.2x over lifetime (fire spreading)

```
current_scale = scale_start + (scale_end - scale_start) * (elapsed / lifetime)
```

### 4.2 Per-Weapon Size Parameters

| Weapon | Trail Size (px) | Scale Start | Scale End | Size at 50% life | Constant Size? |
|--------|----------------|-------------|-----------|-----------------|----------------|
| Knife | 5x7 | 1.0 | 1.0 | 5x7 | Yes (constant) |
| Boomerang | 8x8 | 1.0 | 1.0 | 8x8 | Yes (constant) |
| FireKnife | 7x9 | 1.0 | 0.7 | 5x6 | Shrink (flame dwindles) |
| FrostKnife | 7x9 | 1.0 | 0.5 | 4x5 | Aggressive shrink (ice dissolves) |
| Thunderang | 9x9 | 1.0 | 1.0 | 9x9 | Yes (constant, flicker handles differentiation) |
| Blazerang | 9x9 | 1.0 | 1.2 | 10x10 | Expand (fire spreads) |

### 4.3 Per-Frame Scale Values (Weapons with Size Decay)

**FireKnife (lifetime 0.20s = ~12 frames)**:

| Frame | Elapsed (s) | Scale | Effective Size |
|-------|------------|-------|---------------|
| 0 | 0.000 | 1.00 | 7x9 |
| 1 | 0.017 | 0.975 | 7x9 |
| 2 | 0.033 | 0.950 | 7x9 |
| 3 | 0.050 | 0.925 | 6x8 |
| 4 | 0.067 | 0.900 | 6x8 |
| 5 | 0.083 | 0.875 | 6x8 |
| 6 | 0.100 | 0.850 | 6x8 |
| 7 | 0.117 | 0.825 | 6x7 |
| 8 | 0.133 | 0.800 | 6x7 |
| 9 | 0.150 | 0.775 | 5x7 |
| 10 | 0.167 | 0.750 | 5x7 |
| 11 | 0.183 | 0.725 | 5x7 |

**FrostKnife (lifetime 0.18s = ~11 frames)**:

| Frame | Elapsed (s) | Scale | Effective Size |
|-------|------------|-------|---------------|
| 0 | 0.000 | 1.00 | 7x9 |
| 1 | 0.017 | 0.972 | 7x9 |
| 2 | 0.033 | 0.944 | 7x8 |
| 3 | 0.050 | 0.917 | 6x8 |
| 4 | 0.067 | 0.889 | 6x8 |
| 5 | 0.083 | 0.861 | 6x8 |
| 6 | 0.100 | 0.833 | 6x8 |
| 7 | 0.117 | 0.806 | 6x7 |
| 8 | 0.133 | 0.778 | 5x7 |
| 9 | 0.150 | 0.750 | 5x7 |
| 10 | 0.167 | 0.722 | 5x6 |

**Blazerang (lifetime 0.22s = ~13 frames)**:

| Frame | Elapsed (s) | Scale | Effective Size |
|-------|------------|-------|---------------|
| 0 | 0.000 | 1.00 | 9x9 |
| 1 | 0.017 | 1.015 | 9x9 |
| 2 | 0.033 | 1.030 | 9x9 |
| 3 | 0.050 | 1.045 | 9x9 |
| 4 | 0.067 | 1.061 | 10x10 |
| 5 | 0.083 | 1.076 | 10x10 |
| 6 | 0.100 | 1.091 | 10x10 |
| 7 | 0.117 | 1.106 | 10x10 |
| 8 | 0.133 | 1.121 | 10x10 |
| 9 | 0.150 | 1.136 | 10x10 |
| 10 | 0.167 | 1.152 | 10x11 |
| 11 | 0.183 | 1.167 | 10x11 |
| 12 | 0.200 | 1.182 | 11x11 |

---

## 5. Evolved vs Base Weapon Differences

### 5.1 Parameter Comparison Table

| Parameter | Knife (base) | FireKnife (evolved) | FrostKnife (evolved) | Difference Type |
|-----------|-------------|--------------------|--------------------|----------------|
| Trail color | Color(0.75, 0.75, 0.8) silver | Color(1.0, 0.4, 0.1) orange-red | Color(0.4, 0.8, 1.0) ice blue | Color |
| Trail size | 5x7 | 7x9 | 7x9 | Larger (evolved) |
| Alpha start | 0.30 | 0.40 | 0.35 | Higher (more visible) |
| Lifetime | 0.12s | 0.20s | 0.18s | Longer (fire/ice lingers) |
| Gen interval | 50 ms | 40 ms | 45 ms | Denser (faster projectile) |
| Scale decay | None (constant) | Shrink to 0.7x | Shrink to 0.5x | Evolved has decay |
| Spark particles | No | 1 per segment (2x2 orange) | No | FireKnife extra |

| Parameter | Boomerang (base) | Thunderang (evolved) | Blazerang (evolved) | Difference Type |
|-----------|-----------------|---------------------|--------------------|----------------|
| Trail color | Color(0.6, 0.4, 0.2) brown | Color(1.0, 0.84, 0.0) gold | Color(1.0, 0.27, 0.0) blaze red | Color |
| Trail size | 8x8 | 9x9 | 9x9 | Larger (evolved) |
| Alpha start | 0.25 | 0.30 | 0.40 | Higher (evolved) |
| Lifetime | 0.18s | 0.15s | 0.22s | Varied by element |
| Gen interval | 60 ms | 60 ms | 50 ms | Blazerang denser |
| Alpha flicker | No | Yes (+-0.08) | No | Thunderang unique |
| Scale decay | None (constant) | None (constant) | Expand to 1.2x | Blazerang unique |
| Spark particles | No | No | 1 per segment (2x2 red) | Blazerang extra |

### 5.2 Design Philosophy for Evolved Differences

1. **Evolved trails are always more visible**: Higher alpha start (0.35-0.40 vs 0.25-0.30) and larger size (7x9 or 9x9 vs 5x7 or 8x8).
2. **Evolved trails last longer**: 0.15-0.22s vs 0.12-0.18s. The player earns these weapons and their visual impact should match the power boost.
3. **Each evolved weapon has a unique behavior**: FireKnife shrinks + sparks, FrostKnife aggressively shrinks, Thunderang flickers, Blazerang expands + sparks.
4. **Base weapons are subtle**: Knife and Boomerang trails use their base colors and constant size. They communicate motion without demanding attention.

---

## 6. Object Pool Specification

### 6.1 Pool Size Calculation

**Maximum active trail segments per weapon**:

| Weapon | Segments per Projectile | Max Active Projectiles | Max Segments | Calculation |
|--------|------------------------|----------------------|-------------|-------------|
| Knife | ceil(0.12 / 0.05) = 3 | 3 (Lv3) | 9 | 3 seg x 3 proj |
| Boomerang | ceil(0.18 / 0.06) = 3 | 3 (Lv3) | 9 | 3 seg x 3 bmrg |
| FireKnife | ceil(0.20 / 0.04) = 5 | 3 (fixed count) | 15 | 5 seg x 3 proj |
| FrostKnife | ceil(0.18 / 0.045) = 4 | 4 (fixed count) | 16 | 4 seg x 4 proj |
| Thunderang | ceil(0.15 / 0.06) = 3 | 4 (fixed count) | 12 | 3 seg x 4 bmrg |
| Blazerang | ceil(0.22 / 0.05) = 5 | 3 (fixed count) | 15 | 5 seg x 3 bmrg |

**Segments per projectile formula**: `ceil(lifetime / interval)` -- each segment lives for the full lifetime, and new ones spawn at each interval.

**Total theoretical maximum**: 9 + 9 + 15 + 16 + 12 + 15 = **76 segments**

However, this assumes all 6 weapons are active simultaneously with all projectiles in flight. In practice:
- The player can have at most 6 weapons
- 2 of those are typically orbit/instant/aura types (no trails)
- Realistic max is 3-4 trail-enabled weapons active simultaneously

**Realistic peak**: 3 weapons x ~12 segments avg = ~36 segments

### 6.2 Pool Size

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| Pool size | **80 ColorRect nodes** | Theoretical max 76 + 4 headroom = 80 |
| Pool warm-up | Lazy (created on first request) | Avoids startup cost |
| Max active | Tracked counter, hard cap at 80 | Prevents runaway allocation |
| Overflow behavior | Cull oldest active segment | Maintains visual consistency |

### 6.3 Pool Node Structure

Each pool node is a ColorRect with these properties set per spawn:

```gdscript
var rect := ColorRect.new()
rect.visible = false
rect.z_index = -1  # Behind projectiles and enemies
```

**Why z_index = -1**: Trails should appear behind the projectile and all game entities, not in front.

### 6.4 Pool Recycling

When a trail segment's lifetime expires:
1. Set `rect.visible = false`
2. Return to pool (push to `_pool` array)

When pool is exhausted (all 80 active):
1. Find the segment with the oldest spawn time
2. Force-recycle it (instant fade)
3. Use the recycled node for the new segment

---

## 7. Trail Color Reference

| Weapon | Trail Color (RGB) | Alpha Start | Hex | Source |
|--------|-------------------|-------------|-----|--------|
| Knife | Color(0.75, 0.75, 0.8) | 0.30 | #C0C0CC | Knife weapon color from upgrade_pool.gd |
| Boomerang | Color(0.6, 0.4, 0.2) | 0.25 | #996633 | Boomerang weapon color from upgrade_pool.gd |
| FireKnife | Color(1.0, 0.4, 0.1) | 0.40 | #FF6619 | Fire + knife blend |
| FrostKnife | Color(0.4, 0.8, 1.0) | 0.35 | #66CCFF | Frost + knife blend |
| Thunderang | Color(1.0, 0.84, 0.0) | 0.30 | #FFD700 | Lightning gold |
| Blazerang | Color(1.0, 0.27, 0.0) | 0.40 | #FF4500 | Blaze red-orange |

### 7.1 Trail Shape Reference

| Weapon | Trail Size (px) | Rotation | Scale Decay | Special |
|--------|----------------|----------|-------------|---------|
| Knife | 5x7 | Matches projectile direction | None | -- |
| Boomerang | 8x8 | Matches flight direction | None | -- |
| FireKnife | 7x9 | Matches projectile direction | 1.0 -> 0.7 (shrink) | +1 spark per segment |
| FrostKnife | 7x9 | Matches + 45 deg offset | 1.0 -> 0.5 (aggressive shrink) | -- |
| Thunderang | 9x9 | Matches flight direction | None | Alpha flicker +-0.08 |
| Blazerang | 9x9 | Matches flight direction | 1.0 -> 1.2 (expand) | +1 spark per segment |

### 7.2 Spark Particle Specification (FireKnife, Blazerang)

FireKnife and Blazerang spawn one additional 2x2 spark particle per trail segment.

| Parameter | FireKnife Spark | Blazerang Spark |
|-----------|----------------|-----------------|
| Size | 2x2 px | 2x2 px |
| Color | Color(1.0, 0.6, 0.2) orange | Color(1.0, 0.3, 0.1) red |
| Alpha start | 0.5 | 0.5 |
| Lifetime | 0.10s | 0.10s |
| Position | Trail segment position + random(-3, 3, -3, 3) | Trail segment position + random(-4, 4, -4, 4) |
| Velocity | Random 360 deg, 10-20 px/s | Random 360 deg, 10-20 px/s |

**Sparks are pooled separately**: 20 spark particles max (2 weapons x ~5 segments x 1 spark each + headroom). Sparks use the same pool system.

---

## 8. Implementation Scope

### 8.1 File Changes

| File | Change | Lines |
|------|--------|-------|
| New: `scripts/effects/projectile_trail_pool.gd` | Object pool + spawn + fade logic | ~90 |
| `scripts/projectile.gd` | Add trail spawning in _physics_process | ~20 |
| `scripts/weapons/boomerang.gd` | Add trail spawning in _physics_process | ~20 |
| `scripts/arena.tscn` | Add ProjectileTrailPool node | ~3 |
| `test/unit/test_projectile_trail.gd` | Pool capacity, spawn, cull tests | ~40 |
| **Total** | | **~173** |

### 8.2 Integration Points

| Weapon | Script | Trail Config ID | Notes |
|--------|--------|----------------|-------|
| Knife | `projectile.gd` | "knife" | Silver trail, 50ms interval |
| Boomerang | `boomerang.gd` | "boomerang" | Brown trail, 60ms interval |
| FireKnife | `projectile.gd` | "fireknife" | Orange-red fire trail, 40ms, shrink + sparks |
| FrostKnife | `projectile.gd` | "frostknife" | Ice blue trail, 45ms, aggressive shrink |
| Thunderang | `boomerang.gd` | "thunderang" | Gold trail, 60ms, alpha flicker |
| Blazerang | `boomerang.gd` | "blazerang" | Red trail, 50ms, expand + sparks |

### 8.3 Trail Config Data Structure

```gdscript
# In projectile_trail_pool.gd or a separate trail_config.gd

const TRAIL_CONFIGS: Dictionary = {
    "knife": {
        "color": Color(0.75, 0.75, 0.8),
        "size": Vector2(5, 7),
        "alpha_start": 0.30,
        "lifetime": 0.12,
        "interval": 0.050,
        "scale_start": 1.0,
        "scale_end": 1.0,
        "flicker": 0.0,
        "spark": false,
    },
    "boomerang": {
        "color": Color(0.6, 0.4, 0.2),
        "size": Vector2(8, 8),
        "alpha_start": 0.25,
        "lifetime": 0.18,
        "interval": 0.060,
        "scale_start": 1.0,
        "scale_end": 1.0,
        "flicker": 0.0,
        "spark": false,
    },
    "fireknife": {
        "color": Color(1.0, 0.4, 0.1),
        "size": Vector2(7, 9),
        "alpha_start": 0.40,
        "lifetime": 0.20,
        "interval": 0.040,
        "scale_start": 1.0,
        "scale_end": 0.7,
        "flicker": 0.0,
        "spark": true,
        "spark_color": Color(1.0, 0.6, 0.2),
    },
    "frostknife": {
        "color": Color(0.4, 0.8, 1.0),
        "size": Vector2(7, 9),
        "alpha_start": 0.35,
        "lifetime": 0.18,
        "interval": 0.045,
        "scale_start": 1.0,
        "scale_end": 0.5,
        "flicker": 0.0,
        "spark": false,
    },
    "thunderang": {
        "color": Color(1.0, 0.84, 0.0),
        "size": Vector2(9, 9),
        "alpha_start": 0.30,
        "lifetime": 0.15,
        "interval": 0.060,
        "scale_start": 1.0,
        "scale_end": 1.0,
        "flicker": 0.08,
        "spark": false,
    },
    "blazerang": {
        "color": Color(1.0, 0.27, 0.0),
        "size": Vector2(9, 9),
        "alpha_start": 0.40,
        "lifetime": 0.22,
        "interval": 0.050,
        "scale_start": 1.0,
        "scale_end": 1.2,
        "flicker": 0.0,
        "spark": true,
        "spark_color": Color(1.0, 0.3, 0.1),
    },
}
```

### 8.4 Trail Disable Toggle

```gdscript
# In game_manager.gd or arena.gd
var trails_enabled: bool = true  # Set to false for performance profiling
```

When `trails_enabled == false`, `ProjectileTrailPool.spawn()` is a no-op.

---

## 9. Performance Budget

### 9.1 Resource Usage

| Metric | Typical | Peak | Max Pool |
|--------|---------|------|----------|
| Active trail segments | ~20 | ~40 | 80 |
| Active spark particles | ~6 | ~12 | 20 |
| Per-frame updates | ~20 (alpha + position) | ~40 | 80 |
| Memory per segment | ~200 bytes (ColorRect) | -- | 80 x 200 = 16 KB |
| Memory per spark | ~200 bytes | -- | 20 x 200 = 4 KB |
| Total memory | ~4 KB | ~8 KB | 20 KB |

### 9.2 Culling Strategy

| Scenario | Action |
|----------|--------|
| Pool exhausted (80 active segments) | Cull oldest active segment |
| Trail segment lifetime expired | Return to pool |
| Projectile destroyed/freed | Accelerate all its segments (lifetime -> 0.03s) |
| `trails_enabled == false` | `spawn()` returns immediately, no allocation |

### 9.3 Frame Budget

At 60 FPS:
- Trail segment update: ~40 x (alpha calc + modulate set) = negligible
- Spark update: ~12 x (alpha calc + modulate set) = negligible
- Total trail cost: < 0.3ms per frame, well within 16ms frame budget

---

## 10. Decision Record

| Decision | Why | Alternative Considered |
|----------|-----|----------------------|
| Timer-based intervals (not frame-based) | Frame-based breaks at variable framerates. Timer using delta accumulation is robust. | Frame counter (simpler but wrong at 30fps or 144fps) |
| Per-weapon intervals (not universal 50ms) | Different projectile speeds need different intervals to maintain ~15-18px gaps. Knife at 350px/s needs 50ms; FireKnife at 400px/s needs 40ms to maintain similar gap density. | Universal 50ms (gaps would be inconsistent: knife 17.5px vs fireknife 20px) |
| Linear alpha decay (not ease-out) | Linear is simpler, predictable, and pixel art benefits from straightforward visual transitions. Ease-out would make trails linger too long at low alpha. | Ease-out quadratic (trails would ghost at low alpha) |
| FireKnife shrink + Blazerang expand (opposite curves) | Fire "dies down" (shrinks), while spreading fire "grows" (expands). These opposite behaviors distinguish two fire-themed weapons at a glance. | Same curve for both (harder to distinguish) |
| Thunderang alpha flicker +-0.08 | +-0.08 creates visible stuttering without causing the trail to fully disappear at peak flicker (alpha never drops below 0.0 due to clamping). | +-0.15 (too much variation, trail disappears), +-0.04 (too subtle) |
| Pool size 80 (not 50 or 120) | 50 is too tight for theoretical max 76. 120 wastes 40 nodes. 80 covers max + 5% headroom. | 50 (pool exhaustion during heavy combat), 120 (wasteful) |
| Separate spark pool of 20 | Sparks are independent from trail segments (different size, shorter lifetime). Separate pool prevents trail segments from being consumed by sparks. | Shared pool (sparks could starve trail segments) |
| ColorRect z_index = -1 | Trails behind projectiles and enemies. If trails were in front, they would obscure the projectile visual. | z_index = 0 (overlaps with entities, confusing) |

---

## 11. Success Criteria

1. All 6 trail-enabled weapons display distinct trail effects during flight
2. Knife trail is subtle silver, boomerang trail is subtle brown
3. Evolved weapon trails are visibly more prominent than base weapon trails
4. FireKnife trail shrinks and produces orange sparks
5. FrostKnife trail aggressively shrinks to 0.5x
6. Thunderang trail has visible alpha flicker (electric instability)
7. Blazerang trail expands and produces red sparks
8. No more than 80 active trail segments at any time
9. Trail effects do not cause frame drops (< 0.5ms per frame)
10. `trails_enabled = false` completely disables all trail effects
11. All existing 1520+ tests pass
12. Pool exhaustion is handled gracefully (cull oldest, no errors)
