# Projectile Trail VFX Design

**Author**: Art Agent
**Date**: 2026-04-17
**Round**: R20
**Status**: Design Spec
**Context**: R19 competitive analysis (Vampire Survivors projectile trail) identified trailing effects as a P2 visual enhancement for v1.0.2. This spec defines weapon-differentiated projectile trail effects using ColorRect (no new PNG assets required).

---

## 1. System Overview

### 1.1 Concept

Projectile trails are semi-transparent ColorRect afterimages left behind by moving projectiles (knives, boomerangs, evolved weapon projectiles). Each frame, a fading copy of the projectile is placed at its previous position, creating a motion trail effect.

### 1.2 Design Goals

1. **Enhance motion perception**: Trails communicate projectile speed and direction at a glance.
2. **Weapon differentiation**: Each weapon type has a unique trail color and behavior.
3. **Performance-safe**: Object pool with hard cap. Trails are lightweight ColorRect nodes.
4. **No new PNG required**: Trails are pure ColorRect with modulate color and alpha decay.

### 1.3 Applicable Weapons

Not all weapons benefit from trails. The following analysis determines which weapons should have trails:

| Weapon | Type | Has Projectile | Trail | Reason |
|--------|------|---------------|-------|--------|
| Knife | Projectile | Yes | **Yes** | Classic trail effect for throwing knives |
| Holy Water | Orbit | No (orbit) | No | Orbit blades rotate in place, no linear motion |
| Lightning | Instant | No (Line2D) | No | Lightning is instant, no traveling projectile |
| Bible | Orbit | No (orbit) | No | Same as Holy Water |
| Fire Staff | Cone | No (instant) | No | Cone is an instant area effect |
| Frost Aura | Aura | No (continuous) | No | Aura is a continuous radius effect |
| Boomerang | Boomerang | Yes | **Yes** | Trail enhances the curved flight path |
| FireKnife (evolved) | Projectile | Yes | **Yes** | Fire trail is the signature visual |
| FrostKnife (evolved) | Projectile | Yes | **Yes** | Ice trail for visual identity |
| Thunderang (evolved) | Boomerang | Yes | **Yes** | Electric trail |
| Blazerang (evolved) | Boomerang | Yes | **Yes** | Fire trail |

**Total trail-enabled weapons**: 6 (2 base + 4 evolved)

---

## 2. Trail Implementation

### 2.1 Method: ColorRect Fade-Out

The trail uses ColorRect nodes placed at the projectile's previous positions. Each trail segment is a small ColorRect that fades out over its lifetime.

**Why ColorRect over pre-generated sprites**:
- ColorRect allows dynamic color per weapon without separate PNG files
- Alpha decay is trivially implemented via `modulate.a`
- Object pool reuse is simpler with uniform ColorRect nodes
- Performance is predictable (no texture sampling)

### 2.2 Trail Parameters (Universal)

| Parameter | Value | Notes |
|-----------|-------|-------|
| Trail segments | 2 | Lightweight. More segments = more overhead for minimal gain at 16-20px |
| Segment spacing | Every 3 physics frames | ~0.05s at 60fps, creates ~8px gap at typical projectile speed |
| Segment size | Same as projectile display size | Knife: 6x8, Boomerang: 10x10, Evolved: 8x10 |
| Alpha start | 0.3 | Semi-transparent |
| Alpha end | 0.0 | Fully transparent |
| Lifetime | 0.15s | Quick fade |
| Color | Weapon primary color (semi-transparent) | See per-weapon colors below |

### 2.3 Trail Placement Logic

```gdscript
# In projectile.gd or boomerang.gd _physics_process()

var _trail_timer: int = 0
const TRAIL_INTERVAL: int = 3  # frames between trail segments
const MAX_TRAIL_SEGMENTS: int = 2

func _physics_process(delta: float) -> void:
    _trail_timer += 1
    if _trail_timer >= TRAIL_INTERVAL:
        _trail_timer = 0
        _spawn_trail_segment()

func _spawn_trail_segment() -> void:
    var trail_color: Color = _get_trail_color()
    ProjectileTrailPool.spawn(
        global_position,
        trail_color,
        _get_trail_size(),
        0.15  # lifetime
    )
```

---

## 3. Weapon-Specific Trail Design

### 3.1 Knife Trail

| Parameter | Value | Notes |
|-----------|-------|-------|
| Trail color | Color(0.75, 0.75, 0.8, 0.3) | Silver-white, matches knife.png |
| Trail size | 5x7 px | Slightly smaller than display knife |
| Trail shape | Rotated to match knife direction | trail_rect.rotation = projectile.rotation |
| Fade curve | Linear alpha 0.3 -> 0.0 | Clean fade |
| Lifetime | 0.12s | Quick, knife is fast |

**Visual description**: Two semi-transparent silver-white knife silhouettes trail behind the flying knife, matching its rotation. Creates a "throwing knife streak" effect.

### 3.2 Boomerang Trail

| Parameter | Value | Notes |
|-----------|-------|-------|
| Trail color | Color(0.6, 0.4, 0.2, 0.25) | Brown, matches boomerang.png |
| Trail size | 8x8 px | Slightly smaller than display boomerang |
| Trail shape | Rotated to match boomerang direction | Follows curved path |
| Fade curve | Linear alpha 0.25 -> 0.0 | Subtle, boomerang is already visually complex |
| Lifetime | 0.18s | Slightly longer, curved path needs more visibility |

**Visual description**: Two semi-transparent brown boomerang silhouettes follow the curved flight path, showing the boomerang's trajectory even after it turns. Helps the player track the return path.

### 3.3 FireKnife Trail (Evolved)

| Parameter | Value | Notes |
|-----------|-------|-------|
| Trail color | Color(1.0, 0.4, 0.1, 0.35) | Orange-red fire |
| Trail size | 7x9 px | Evolved weapon is larger |
| Trail shape | Rotated, with slight upward scale | Flame-like elongation |
| Fade curve | alpha 0.35 -> 0.0 + scale 1.0 -> 0.7 | Shrink + fade |
| Lifetime | 0.20s | Longer, fire lingers |
| Extra particles | 1 random 2x2 orange spark per trail segment | Fire sparkles |

**Visual description**: Orange-red fading silhouettes trail behind the fire knife, with occasional orange sparks. Creates a "flaming projectile" feel distinct from the base knife's silver trail.

### 3.4 FrostKnife Trail (Evolved)

| Parameter | Value | Notes |
|-----------|-------|-------|
| Trail color | Color(0.53, 0.87, 1.0, 0.3) | Ice blue |
| Trail size | 7x9 px | Same size as FireKnife |
| Trail shape | Rotated, 45-degree diamond offset | Icy crystalline feel |
| Fade curve | alpha 0.3 -> 0.0 + scale 1.0 -> 0.5 | Shrinks more aggressively |
| Lifetime | 0.18s | Medium |

**Visual description**: Ice-blue fading silhouettes trail behind the frost knife, shrinking more aggressively than fire. Creates a "freezing wake" effect. Visual cold/warm contrast with FireKnife.

### 3.5 Thunderang Trail (Evolved)

| Parameter | Value | Notes |
|-----------|-------|-------|
| Trail color | Color(1.0, 0.84, 0.0, 0.25) | Lightning gold |
| Trail size | 9x9 px | Evolved boomerang size |
| Trail shape | Rotated to match flight direction | Follows curved path |
| Fade curve | alpha 0.25 -> 0.0 with random alpha flicker | Electric stuttering |
| Lifetime | 0.15s | Standard |
| Alpha flicker | Random +-0.1 per frame | Electric instability |

**Visual description**: Gold semi-transparent silhouettes trail behind the thunderang, with random alpha flicker simulating electric instability. The flickering distinguishes it from a smooth fire trail.

### 3.6 Blazerang Trail (Evolved)

| Parameter | Value | Notes |
|-----------|-------|-------|
| Trail color | Color(1.0, 0.27, 0.0, 0.35) | Blaze red-orange |
| Trail size | 9x9 px | Same as Thunderang |
| Trail shape | Rotated, with slight expansion (scale 1.0 -> 1.2) | Growing flame |
| Fade curve | alpha 0.35 -> 0.0, scale 1.0 -> 1.2 | Expands as it fades |
| Lifetime | 0.22s | Longest, fire persists |
| Extra particles | 1 random 2x2 red spark per trail segment | Ember sparks |

**Visual description**: Red-orange expanding silhouettes trail behind the blazerang, growing slightly as they fade. Occasional red sparks. Creates a "burning trajectory" effect.

---

## 4. Performance Optimization

### 4.1 Object Pool

```gdscript
# ProjectileTrailPool singleton or Arena child node
const MAX_TRAIL_SEGMENTS: int = 80  # 6 weapons x ~3 active projectiles x 2 segments = ~36; 80 headroom

var _pool: Array[ColorRect] = []
var _active: Array[Dictionary] = []

func _ready() -> void:
    for i in MAX_TRAIL_SEGMENTS:
        var rect := ColorRect.new()
        rect.visible = false
        add_child(rect)
        _pool.append(rect)
```

### 4.2 Performance Budget

| Metric | Value | Calculation |
|--------|-------|-------------|
| Max active projectiles (typical) | ~10 | 3 knives + 2 boomerangs + 3 evolved projectiles + 2 reserve |
| Trail segments per projectile | 2 | Per spec |
| Total active trail segments | ~20 | 10 x 2 |
| Pool capacity | 80 | 4x typical for burst scenarios |
| Per-frame cost | ~20 ColorRect updates | Position + alpha only |

### 4.3 Culling Strategy

| Scenario | Action |
|----------|--------|
| Pool exhausted (80 active) | Cull oldest trail segment |
| Trail segment lifetime expired | Return to pool |
| Projectile destroyed/freed | All its trail segments accelerated to fade (lifetime -> 0.03s) |

### 4.4 Frame Budget

Trail update cost per frame: ~20 x (position update + alpha update) = negligible.
At 60fps, this is well within the frame budget. Even at 80 segments (max pool), the cost is ~80 simple arithmetic operations per frame.

---

## 5. ColorRect Fallback (No PNG Required)

All trail segments are ColorRect nodes. No PNG sprites needed.

### 5.1 Trail Color Reference Table

| Weapon | Trail Color | Alpha | Hex | Source |
|--------|------------|-------|-----|--------|
| Knife | Color(0.75, 0.75, 0.8) | 0.30 | #C0C0CC | knife.png silver |
| Boomerang | Color(0.6, 0.4, 0.2) | 0.25 | #996633 | boomerang.png brown |
| FireKnife | Color(1.0, 0.4, 0.1) | 0.35 | #FF6619 | Fire orange |
| FrostKnife | Color(0.53, 0.87, 1.0) | 0.30 | #88DDFF | Ice blue |
| Thunderang | Color(1.0, 0.84, 0.0) | 0.25 | #FFD700 | Lightning gold |
| Blazerang | Color(1.0, 0.27, 0.0) | 0.35 | #FF4500 | Blaze red |

### 5.2 Trail Shape Reference Table

| Weapon | Trail Size (px) | Rotation Match | Special |
|--------|----------------|----------------|---------|
| Knife | 5x7 | Yes (projectile direction) | None |
| Boomerang | 8x8 | Yes (flight direction) | None |
| FireKnife | 7x9 | Yes | + 1 spark particle per segment |
| FrostKnife | 7x9 | Yes + 45 degree offset | Aggressive shrink |
| Thunderang | 9x9 | Yes | Alpha flicker (random +-0.1) |
| Blazerang | 9x9 | Yes | Scale expansion 1.0 -> 1.2, + 1 spark |

---

## 6. Implementation Scope

### 6.1 File Changes

| File | Change | Lines |
|------|--------|-------|
| New: `scripts/effects/projectile_trail_pool.gd` | Object pool + spawn + fade logic | ~70 |
| `scripts/projectile.gd` | Add trail spawning in _physics_process | ~15 |
| `scripts/boomerang.gd` | Add trail spawning in _physics_process | ~15 |
| `scripts/arena.tscn` | Add ProjectileTrailPool node | ~3 |
| `test/unit/test_projectile_trail.gd` | Pool capacity, spawn, cull tests | ~35 |
| **Total** | | **~138** |

### 6.2 Integration Points

| Weapon | Script | Trail Color Getter | Notes |
|--------|--------|-------------------|-------|
| Knife | `projectile.gd` | Based on `weapon_id` == "knife" | Silver trail |
| Boomerang | `boomerang.gd` | Based on `weapon_id` == "boomerang" | Brown trail |
| FireKnife | `projectile.gd` | Based on `weapon_id` == "fireknife" | Orange-red fire trail |
| FrostKnife | `projectile.gd` | Based on `weapon_id` == "frostknife" | Ice blue trail |
| Thunderang | `boomerang.gd` | Based on `weapon_id` == "thunderang" | Gold flickering trail |
| Blazerang | `boomerang.gd` | Based on `weapon_id` == "blazerang" | Red expanding trail |

### 6.3 Trail Disable Toggle

For performance debugging, add a simple toggle:

```gdscript
# In game_manager.gd or arena.gd
var trails_enabled: bool = true  # Set to false for performance profiling
```

When `trails_enabled == false`, `ProjectileTrailPool.spawn()` is a no-op.

---

## 7. Decision Record

| Decision | Why | Alternative Considered |
|----------|-----|----------------------|
| ColorRect trail instead of pre-generated sprite | Dynamic color per weapon without separate PNGs. Alpha decay is trivial. Object pool reuse is simpler. | Pre-rendered trail sprite sheet (needs multiple PNGs, overkill for semi-transparent rectangles) |
| 2 trail segments | At 16-20px projectile size, 2 segments (8px spacing) is sufficient to convey motion. 3+ segments would overlap at typical speeds. | 1 segment (barely visible), 3 segments (performance cost with minimal visual gain) |
| 3-frame spacing | At 60fps, 3 frames = 0.05s. At knife speed (~200px/s), this creates ~10px gaps between segments. Visible but not cluttered. | Every frame (too many segments, pool exhaustion), 5+ frames (gaps too large, trail invisible) |
| Weapon-specific trail colors | Reinforces weapon identity. Silver/brown/fire/ice/gold/red each evoke the weapon's theme. | Uniform white trail (loses weapon differentiation) |
| Alpha flicker for Thunderang | Random alpha variation simulates electric instability, distinguishing electric trail from fire trail. Both are warm colors (gold vs red) so behavior difference is critical. | Uniform fade (indistinguishable from Blazerang at a glance) |
| Scale expansion for Blazerang | Fire "grows" as it spreads, even in a tiny 9x9 pixel trail. The expansion makes the Blazerang trail feel "hotter" than the Thunderang's stable-size flickering. | Same size as Thunderang (harder to distinguish) |
| Object pool of 80 | 6 weapons x ~3 active x 2 segments = 36 typical. 80 provides 2.2x headroom for burst scenarios. | 50 (tight, risk of culling during heavy combat), 150 (wasteful) |
| No trail for orbit/aura/instant weapons | Trails require linear motion. Orbit weapons (Holy Water, Bible) move in circles (trail would be a ring = confusing). Aura/instant weapons have no projectile to trail. | Universal trail (wasteful for non-linear weapons) |
