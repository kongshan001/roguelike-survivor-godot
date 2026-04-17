# Evolved Weapon Hit Particle Dual-Color Mix Spec -- v1.0.3

**Created**: 2026-04-17 (R24, Art Agent)
**Status**: Design complete, awaiting Programmer Agent implementation
**Replaces**: Unified gold Color(1.0, 0.84, 0.0) placeholder in hit_feedback.gd

## Overview

Evolved weapons currently share a single gold particle color. This spec defines per-weapon dual-color particle mixes that combine the weapon's base identity color with its evolution signature color, producing distinctive hit feedback for each evolved weapon.

## Dual-Color Particle Table

| Evolved Weapon | Color A (base identity) | Color B (evolution signature) | Mix Ratio (A:B) | Particle Shape Override |
|----------------|------------------------|-------------------------------|-----------------|------------------------|
| fireknife | Color(0.75, 0.75, 0.8) silver-white | Color(1.0, 0.55, 0.0) dark orange | 1:2 | same as knife (1x3 horizontal) |
| frostknife | Color(0.75, 0.75, 0.8) silver-white | Color(0.53, 0.87, 1.0) ice blue | 1:2 | same as knife (1x3 horizontal) |
| thunderang | Color(0.6, 0.4, 0.2) brown | Color(1.0, 0.84, 0.0) electric gold | 1:2 | same as boomerang (1x3 horizontal) |
| blazerang | Color(0.6, 0.4, 0.2) brown | Color(1.0, 0.27, 0.0) blaze red | 1:2 | same as boomerang (1x3 horizontal) |
| thunderholywater | Color(0.3, 0.5, 1.0) blue | Color(1.0, 0.84, 0.0) lightning gold | 2:1 | same as holywater (3x3 square) |
| holydomain | Color(0.3, 0.5, 1.0) blue | Color(1.0, 0.84, 0.0) holy gold | 1:1 | same as holywater (3x3 square) |
| blizzard | Color(1.0, 1.0, 1.0) ice white | Color(0.53, 0.87, 1.0) ice blue | 1:2 | same as frostaura (2x2 diamond) |
| flamebible | Color(0.9, 0.85, 0.7) warm white | Color(1.0, 0.27, 0.0) flame red | 1:2 | same as bible (2x2 cross) |
| sentineltotem | Color(0.7, 0.6, 0.2) gold-brown | Color(1.0, 0.84, 0.0) gold crown | 1:1 | same as bible (2x2 cross) |
| frostvortex | Color(0.75, 0.75, 0.8) knife silver-white | Color(0.53, 0.87, 1.0) ice blue | 1:2 | same as knife (1x3 horizontal) |
| holyshockwave | Color(0.3, 0.5, 1.0) holy water blue | Color(1.0, 0.27, 0.0) fire orange | 1:1 | same as holywater (3x3 square) |
| thunderbeam | Color(1.0, 1.0, 0.3) lightning yellow | Color(0.3, 0.5, 1.0) electric blue | 1:2 | same as lightning (1x3 horizontal) |

## Color Derivation Logic

- **Color A (base identity)**: Taken from the base weapon's existing particle color in WEAPON_COLORS. This ensures visual continuity -- evolved fireknife particles still have some silver-white from the base knife.
- **Color B (evolution signature)**: Taken from the evolved weapon's primary color in the art-log.md evolution table. This is the "upgrade glow" that makes the particle feel evolved.
- **Mix Ratio**: Determines how many of the 3 (normal) or 5 (crit) particles get each color.
  - 1:2 means 1 particle Color A, 2 particles Color B (normal: 1+2=3; crit: 2+3=5)
  - 2:1 means 2 particles Color A, 1 particle Color B
  - 1:1 means equal split (normal: 1+2=3, with rounding; crit: 2+3=5, with rounding)

## Implementation Guide (for Programmer Agent)

### Changes to hit_feedback.gd

Replace the single-color evolved entries in WEAPON_COLORS with a new dictionary EVOLVED_DUAL_COLORS:

```gdscript
# Replace lines 47-56 in WEAPON_COLORS:
# Remove evolved entries from WEAPON_COLORS (they will use dual-color logic)

# Add new dual-color dictionary:
const EVOLVED_DUAL_COLORS: Dictionary = {
    "fireknife": {"a": Color(0.75, 0.75, 0.8), "b": Color(1.0, 0.55, 0.0), "ratio": 0.33},
    "frostknife": {"a": Color(0.75, 0.75, 0.8), "b": Color(0.53, 0.87, 1.0), "ratio": 0.33},
    "thunderang": {"a": Color(0.6, 0.4, 0.2), "b": Color(1.0, 0.84, 0.0), "ratio": 0.33},
    "blazerang": {"a": Color(0.6, 0.4, 0.2), "b": Color(1.0, 0.27, 0.0), "ratio": 0.33},
    "thunderholywater": {"a": Color(0.3, 0.5, 1.0), "b": Color(1.0, 0.84, 0.0), "ratio": 0.67},
    "holydomain": {"a": Color(0.3, 0.5, 1.0), "b": Color(1.0, 0.84, 0.0), "ratio": 0.50},
    "blizzard": {"a": Color(1.0, 1.0, 1.0), "b": Color(0.53, 0.87, 1.0), "ratio": 0.33},
    "flamebible": {"a": Color(0.9, 0.85, 0.7), "b": Color(1.0, 0.27, 0.0), "ratio": 0.33},
    "sentineltotem": {"a": Color(0.7, 0.6, 0.2), "b": Color(1.0, 0.84, 0.0), "ratio": 0.50},
    "frostvortex": {"a": Color(0.75, 0.75, 0.8), "b": Color(0.53, 0.87, 1.0), "ratio": 0.33},
    "holyshockwave": {"a": Color(0.3, 0.5, 1.0), "b": Color(1.0, 0.27, 0.0), "ratio": 0.50},
    "thunderbeam": {"a": Color(1.0, 1.0, 0.3), "b": Color(0.3, 0.5, 1.0), "ratio": 0.33},
}
```

### Modified _spawn_particles Logic

In `_spawn_particles()`, for evolved weapons, assign color per-particle:

```gdscript
func _spawn_particles(arena: Node2D, pos: Vector2, source: String, was_crit: bool) -> void:
    var count: int = PARTICLE_COUNT_CRIT if was_crit else PARTICLE_COUNT_NORMAL
    var lifetime: float = PARTICLE_LIFETIME_CRIT if was_crit else PARTICLE_LIFETIME_NORMAL
    var speed_min: float = PARTICLE_SPEED_CRIT_MIN if was_crit else PARTICLE_SPEED_MIN
    var speed_max: float = PARTICLE_SPEED_CRIT_MAX if was_crit else PARTICLE_SPEED_MAX

    # Determine if dual-color
    var dual: Dictionary = EVOLVED_DUAL_COLORS.get(source, {})
    var is_dual: bool = not dual.is_empty()

    for i in range(count):
        if _active_particles >= MAX_PARTICLES:
            break
        var rect: ColorRect = _get_particle(arena)
        if not rect:
            break
        rect.visible = true
        rect.size = PARTICLE_SIZE

        # Color selection: dual-color mix or single color
        var color: Color
        if was_crit:
            color = DMG_COLOR_CRIT  # Crit always gold (unchanged)
        elif is_dual:
            color = dual.b if randf() > dual.ratio else dual.a
        else:
            color = WEAPON_COLORS.get(source, Color.WHITE)

        rect.color = color
        rect.global_position = pos - PARTICLE_SIZE * 0.5
        _active_particles += 1

        var angle: float = randf() * TAU
        var speed: float = randf_range(speed_min, speed_max)
        var vel: Vector2 = Vector2(cos(angle), sin(angle)) * speed * lifetime
        var target_pos: Vector2 = rect.global_position + vel

        var tween: Tween = arena.create_tween()
        tween.tween_property(rect, "global_position", target_pos, lifetime)
        tween.parallel().tween_property(rect, "color:a", 0.0, lifetime)
        tween.tween_callback(_return_particle.bind(rect))
```

Key change: `color = dual.b if randf() > dual.ratio else dual.a` -- each particle independently picks Color A or Color B based on the ratio. This creates a natural color mix rather than alternating.

### Crit Behavior Unchanged

Crit particles remain unified gold Color(1.0, 0.84, 0.0) as per R20 design. Dual-color is for normal hits only. This preserves the clear visual distinction: normal hits = weapon-colored, crit hits = gold.

## Design Decisions

1. **Dual-color instead of blended color**: Using two discrete colors per particle (rather than blending into a single intermediate color) preserves the identity of both the base weapon and the evolution. The visual effect at 2-3px particle size is a "sparkle mix" rather than a muddy blend.

2. **ratio field as probability, not fixed count**: Using `randf() > ratio` means each particle independently chooses Color A or B. This produces organic-looking distributions rather than rigid alternation. For a 1:2 ratio (ratio=0.33), approximately 1 in 3 particles gets Color A.

3. **Color A = base weapon color for continuity**: Players who upgrade knife to fireknife will see familiar silver-white sparks mixed with new orange sparks. The base weapon identity is preserved as a visual anchor.

4. **Blizzard uses white + ice blue (not blue + blue)**: The base weapon for blizzard is a new design (not derived from an existing base weapon), so Color A uses the blizzard's own secondary color (ice white) and Color B uses its primary (ice blue). This maintains the blue/white ice palette.

5. **SentinelTotem uses gold-brown + gold**: The totem is a fusion weapon (bible + boomerang). Color A is the totem's own body color (gold-brown) and Color B is its crown gold. Both are warm gold tones, creating a cohesive golden hit effect that distinguishes it from the fire-based red/gold weapons.

6. **No particle count increase**: Evolved weapons use the same 3/5 particle counts as base weapons. The dual-color mix creates visual richness without increasing particle budget. This respects the MAX_PARTICLES=60 cap.

7. **FrostVortex uses knife silver-white + ice blue (R28)**: The frostvortex recipe is knife + frostaura. Color A is knife's silver-white Color(0.75, 0.75, 0.8), Color B is ice blue Color(0.53, 0.87, 1.0). This maintains visual continuity with frostknife (same Color A and B), reinforcing the ice-knife weapon family. Ratio 1:2 (0.33) emphasizes the ice blue evolution identity.

8. **HolyShockwave uses holy water blue + fire orange (R28)**: The holyshockwave recipe is holywater + firestaff. Color A is holywater's blue Color(0.3, 0.5, 1.0), Color B is firestaff's fire orange Color(1.0, 0.27, 0.0). Color B uses fire orange rather than the weapon's own gold primary because gold Color(1.0, 0.84, 0.0) would be visually indistinguishable from thunderbeam's electric yellow in 2x2 particle size. The blue+orange combination creates strong warm-cool contrast. Ratio 1:1 (0.50) gives equal weight to both recipe components.

9. **ThunderBeam uses lightning yellow + electric blue (R28)**: The thunderbeam recipe is lightning + knife. Color A is lightning's yellow Color(1.0, 1.0, 0.3), Color B is electric blue Color(0.3, 0.5, 1.0). Color B uses electric blue rather than knife's silver-white because: (a) silver-white + yellow lacks visual contrast, (b) electric blue is the signature color of the beam's edge glow (v1.1.0-weapon-vfx.md Section 4.4), (c) yellow+blue is the classic lightning visual language. Ratio 1:2 (0.33) emphasizes the electric blue evolution identity.

## QA Test Suggestions

1. Verify each evolved weapon produces 2 distinct particle colors (not single gold)
2. Verify crit particles remain gold (unchanged behavior)
3. Verify WEAPON_COLORS still works for base weapons (no regression)
4. Verify MAX_PARTICLES=60 cap still respected with dual-color particles
5. Verify rate limiting still functions correctly
6. Verify frostvortex particles are silver-white + ice blue mix (not gold)
7. Verify holyshockwave particles are blue + fire orange mix (not gold)
8. Verify thunderbeam particles are yellow + electric blue mix (not gold)
