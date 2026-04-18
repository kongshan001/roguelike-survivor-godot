# Necromancer Death Pulse VFX Specification

**Author**: Art Agent
**Date**: 2026-04-18
**Round**: R35
**Source**: `docs/superpowers/specs/necromancer-design.md` Section 3.4
**Related Code**: `scripts/skill_effects.gd` lines 266-310, `scripts/data/skill_data.gd`
**Parent Spec**: `docs/superpowers/specs/skill-vfx-spec.md`

---

## 1. Overview

This document defines the complete visual effects (VFX) specification for the Necromancer's active skill "Death Pulse" (death_pulse). Death Pulse is a centered AoE attack that scales with total kills, featuring an expanding dark ring, tick-based damage, and screen shake. The visual design follows the established conventions from `skill-vfx-spec.md` for Mage/Warrior/Ranger skills.

All effects use ColorRect-based rendering with Tween animation, consistent with existing skill VFX in `skill_effects.gd`.

---

## 2. Death Pulse VFX Elements

### 2.1 Expanding Dark Ring

The primary visual: a dark purple ring expanding from the Necromancer's position, representing necrotic energy radiating outward.

| Attribute | Value | Notes |
|-----------|-------|-------|
| Shape | Circle (ColorRect scaling) | Centered on player position at cast time |
| Initial Size | 0x0 px | Starts invisible at player center |
| Final Size | 240x240 px | Diameter = `NECROMANCER_SKILL_RADIUS * 2` = 120 * 2 |
| Expand Duration | 0.9 s | `NECROMANCER_SKILL_TICK_INTERVAL * NECROMANCER_SKILL_TICKS` = 0.3 * 3 |
| Color | Color(0.40, 0.15, 0.55) | Dark purple -- necrotic/death energy |
| Alpha Start | 0.7 | Slightly lower than Mage's 0.8, darker feel |
| Alpha End | 0.0 | Fades out completely |
| Alpha Decay | Linear interpolation over expand_time | `alpha = 0.7 * (1.0 - t / expand_time)` |
| Z-Index | 10 | Above enemies, below HUD |
| Ring Position Update | `position = center_pos - size/2` each Tween frame | Keeps ring centered during expansion |

#### Animation Timeline

```
t=0.00s  [CAST]   Dark ring appears at size 0x0, alpha=0.7
                   Screen shake fires (intensity 3.0)
                   Tick 1 damage applies immediately

t=0.15s           Size=80x80 px, alpha=0.58
                   Ring clearly visible, expanding

t=0.30s           Size=120x120 px, alpha=0.47
                   Tick 2 damage applies (0.3s interval)
                   Ring covers medium range

t=0.45s           Size=160x160 px, alpha=0.35
                   Ring reaches outer area

t=0.60s           Size=200x200 px, alpha=0.23
                   Tick 3 damage applies (0.6s = tick_idx 2)
                   Ring nearly at full radius

t=0.75s           Size=220x220 px, alpha=0.12
                   Ring fading, enemies in outer range hit

t=0.90s           Size=240x240 px, alpha=0.0  [VFX END]
                   Ring fully expanded and invisible
                   ColorRect queue_free'd
```

#### Color Rationale

- Color(0.40, 0.15, 0.55) is a **dark purple** that sits between the Necromancer's character color Color(0.27, 0.13, 0.40) and a brighter purple. It communicates "death/necrotic energy" without being as bright as the Bat enemy's Color(0.67, 0.28, 0.74).
- The purple is distinct from:
  - Mage Elemental Burst: Color(0.3, 0.5, 1.0) blue
  - Warrior Shield Charge: Color(0.9, 0.2, 0.1) red
  - Ranger Arrow Rain: Color(0.9, 0.9, 0.8) off-white arrows
- Alpha 0.7 (vs Mage's 0.8) gives the ring a more "sinister/absorbing" quality rather than "bright/explosive"

#### Comparison with Existing Implementation

The current `skill_effects.gd` death_pulse() function (line 266) uses:

```gdscript
ring.color = Color(0.5, 0.3, 0.7, 0.6)
```

This R35 spec refines it to:

```gdscript
ring.color = Color(0.40, 0.15, 0.55, 0.7)
```

| Attribute | Current Code | R35 Spec | Change Rationale |
|-----------|-------------|----------|-----------------|
| RGB | (0.5, 0.3, 0.7) | (0.40, 0.15, 0.55) | Darker, more necrotic; closer to Necromancer's character color |
| Alpha start | 0.6 | 0.7 | More visible at cast moment; still below Mage's 0.8 |
| Alpha decay | Linear | Linear | No change; proven pattern |

### 2.2 Tick Damage Visual Feedback

Damage is applied in 3 ticks over the expansion duration. Each tick should have a subtle visual indicator on hit enemies.

| Attribute | Value | Notes |
|-----------|-------|-------|
| Tick Count | 3 | Matches `NECROMANCER_SKILL_TICKS` |
| Tick Interval | 0.3 s | Matches `NECROMANCER_SKILL_TICK_INTERVAL` |
| Tick Timing | t=0.0s, t=0.3s, t=0.6s | Evenly spaced during ring expansion |
| Enemy Flash | Brief purple modulate | On each tick, affected enemies flash |
| Flash Color | Color(0.5, 0.2, 0.7, 0.4) | Light purple tint, semi-transparent |
| Flash Duration | 0.1 s per tick | Very brief, just enough to register |
| Flash Apply | Via `modulate` property on enemy | Same pattern as Mage freeze tint |

#### Tick Visual Timeline

```
t=0.0s   [TICK 1] All enemies within current ring radius flash purple 0.1s
t=0.3s   [TICK 2] All enemies within current ring radius flash purple 0.1s
t=0.6s   [TICK 3] All enemies within current ring radius flash purple 0.1s
```

Note: The current implementation (`_death_pulse_tick`) damages all enemies within the **full radius** on every tick. The visual spec above recommends ticking at the expanding ring's current edge, but the gameplay implementation uses the full radius. Programmer should match the visual to whichever behavior is canonical.

### 2.3 Screen Shake

| Attribute | Value | Notes |
|-----------|-------|-------|
| Intensity | 3.0 | Matches `NECROMANCER_SKILL_SCREENSHAKE` |
| Duration | 0.12 s | Matches `NECROMANCER_SKILL_SCREENSHAKE_DUR` |
| Decay Rate | 25.0/s | Linear decay (intensity / duration) |
| Direction | Random Vector2(-1, 1) normalized | Per-frame random |
| Apply To | Camera2D.offset | Per existing shake system |
| Trigger | On cast (t=0) | Single burst at start |

#### Screen Shake Comparison Across Skills

| Skill | Intensity | Duration | Decay Rate | Feel |
|-------|-----------|----------|------------|------|
| Mage Elemental Burst | 4.0 | 0.15s | 26.67/s | Heavy explosion |
| Warrior Shield Charge | 3.0 | 0.1s | 30.0/s | Impact punch |
| Ranger Arrow Rain | 2.0 | 0.08s | 25.0/s | Rapid barrage |
| **Necromancer Death Pulse** | **3.0** | **0.12s** | **25.0/s** | **Dark pulse** |

Design rationale: Death Pulse shake matches Warrior's intensity (3.0) but with slightly longer duration (0.12s vs 0.1s), creating a "wave ripple" feel rather than a sharp "impact". This differentiates it from the Warrior's punch-like shake while maintaining the same raw strength.

---

## 3. Ring Expansion Mechanics Detail

### 3.1 Godot Implementation Reference

The ring is implemented as a ColorRect node that scales from 0x0 to 240x240 over 0.9 seconds.

```gdscript
# From skill_effects.gd death_pulse() -- current implementation pattern
var ring: ColorRect = ColorRect.new()
ring.size = Vector2(0, 0)
ring.position = pos - Vector2(0, 0)
ring.color = Color(0.40, 0.15, 0.55, 0.7)  # R35 refined color
ring.z_index = 10
arena.call_deferred("add_child", ring)

var expand_time: float = NECROMANCER_SKILL_TICK_INTERVAL * float(NECROMANCER_SKILL_TICKS)
var tween: Tween = arena.create_tween()
tween.tween_property(ring, "size", Vector2(NECROMANCER_SKILL_RADIUS * 2.0, NECROMANCER_SKILL_RADIUS * 2.0), expand_time)
tween.parallel().tween_property(ring, "position", pos - Vector2(NECROMANCER_SKILL_RADIUS, NECROMANCER_SKILL_RADIUS), expand_time)
tween.parallel().tween_property(ring, "color:a", 0.0, expand_time)
tween.tween_callback(ring.queue_free)
```

### 3.2 Damage Tick Integration

```gdscript
# Tick-based damage (3 ticks over 0.9s)
for tick_idx in range(NECROMANCER_SKILL_TICKS):
    var tick_delay: float = NECROMANCER_SKILL_TICK_INTERVAL * float(tick_idx)
    var tick_tween: Tween = arena.create_tween()
    tick_tween.tween_interval(tick_delay)
    tick_tween.tween_callback(_death_pulse_tick.bind(arena, pos, dmg))
```

Each `_death_pulse_tick` damages all enemies within `NECROMANCER_SKILL_RADIUS` (120px) of the center position. Damage per tick = total_damage / NECROMANCER_SKILL_TICKS.

### 3.3 ColorRect Fallback

If no Sprite2D assets are available:
- Ring: Single ColorRect with dark purple color and alpha decay via Tween
- Enemy flash: Apply modulate tint to enemy nodes directly
- Screen shake: Camera2D.offset randomization (existing system)

---

## 4. VFX Color Summary

| VFX Element | Primary Color | Alpha Range | Duration | Z-Index |
|-------------|--------------|-------------|----------|---------|
| Dark Ring | Color(0.40, 0.15, 0.55) | 0.7 -> 0.0 | 0.9s | 10 |
| Enemy Tick Flash | Color(0.5, 0.2, 0.7) | 0.4 -> 0.0 | 0.1s per tick | -- |

### 4.1 Necromancer Character Color Context

| Element | Color | Hex |
|---------|-------|-----|
| Character theme | Color(0.27, 0.13, 0.40) | #442266 |
| Death Pulse ring | Color(0.40, 0.15, 0.55) | #6626A0 |
| Enemy tick flash | Color(0.5, 0.2, 0.7) | #8033B3 |
| Skill icon (HUD) | Color(0.27, 0.13, 0.40) | #442266 |

The Death Pulse colors form a **lighter gradient** from the character's deep purple theme, ensuring visual coherence while being bright enough to be visible during gameplay.

---

## 5. Performance Considerations

1. **Node Count**: Each Death Pulse activation creates exactly 1 ColorRect (ring). Tick damage is applied via existing `_get_enemies_in_radius` helper without additional visual nodes. Maximum 1 VFX node per activation.

2. **Node Lifecycle**: The ring ColorRect is `queue_free()`'d after 0.9s (expand_time). No persistent nodes remain after skill activation.

3. **Tick Tween Creation**: 3 Tick Tweens are created per activation. Each has a single interval + callback. Minimal overhead.

4. **Comparison with Other Skills**:
   - Mage Burst: 1 ring + N freeze modulates
   - Warrior Charge: 3 afterimages + 3 stun stars per enemy
   - Arrow Rain: 1 warning + 12 arrows + 12 flashes
   - **Death Pulse**: 1 ring (fewest VFX nodes of all 4 skills)

5. **Damage Calculation**: Kill-scaled damage is computed once at cast time, not per tick. Each tick applies a flat fraction (total_damage / tick_count).

---

## 6. Design Decisions Log

| Decision | Why | Alternative Considered |
|----------|-----|----------------------|
| Ring color (0.40, 0.15, 0.55) darker than code's (0.5, 0.3, 0.7) | Darker purple is more "necrotic/death", closer to character theme, distinct from Mage's bright blue ring | Keep current code color (too bright, feels "magical" not "necrotic") |
| Alpha 0.7 (vs Mage's 0.8) | Death energy should feel absorbing/dark rather than explosive/bright. Lower alpha creates a more ominous visual | Same alpha as Mage (would look too bright for a death-themed skill) |
| Single ring (no inner effects) | Death Pulse is the simplest VFX of all 4 skills (1 node). Performance-conscious for a 25s cooldown skill that may be used in dense enemy scenarios | Multiple concentric rings (more visually rich but adds nodes and complexity for a skill with 25s CD) |
| No ring edge glow | ColorRect cannot produce edge glow without Shader. Pixel art style favors simple solid fills. The alpha decay already provides sufficient visual interest | Add a brighter outer edge ColorRect (doubles node count for minimal visual gain) |
| Screen shake 3.0/0.12s | Matches Warrior intensity but longer duration, creating a "wave" rather than "impact". The Necromancer's theme is sustained pressure, not burst impact | 5.0/0.12s matching designer spec (too strong -- designer spec was aspirational; 3.0 matches the canonical `NECROMANCER_SKILL_SCREENSHAKE` in SkillData) |
| Tick flash via modulate | Same pattern as Mage freeze tint. Consistent code style. Easy to test. | Separate ColorRect overlay per enemy (more nodes, harder to manage lifecycle) |

---

## 7. Skill Icon Specification

### 7.1 Death Pulse HUD Icon

| Attribute | Value | Notes |
|-----------|-------|-------|
| Shape | Circle with inner skull silhouette | Round = AoE centered on self |
| Size | 24x24 px | Matches other skill icons |
| Icon Color | Color(0.27, 0.13, 0.40) | Deep purple, character theme color |
| Inner Detail | Simplified skull (2 eye sockets + jaw line) | Optional -- may use simple circle if pixel size is limiting |
| Border | Color(1.0, 0.84, 0.0) gold when ready | Matches SKILL_READY_COLOR |
| Cooldown Overlay | Color(0, 0, 0, 0.6) dark | Same as other skills |
| Key Label | "E" white text | Same as other skills |

### 7.2 Skill Icon File

| File | Path | Status |
|------|------|--------|
| death_pulse.png | `assets/sprites/skills/death_pulse.png` | Needs creation (24x24) |

Suggested addition to `tools/generate_sprites.py`:

```python
def gen_death_pulse():
    """24x24 Necromancer skill icon: purple circle with death energy rays."""
    img, d, p = new_img(24, 24)
    # Outer circle - deep purple
    _fill_circle(d, 12, 12, 10, p['necromancer'])  # #442266
    # Inner glow ring
    _draw_outline_circle(d, 12, 12, 7, p.get('knight_accent', (0x88, 0x44, 0xBB)))  # #8844BB lighter purple
    # Center dark core
    _fill_circle(d, 12, 12, 4, p['dark_outline'])  # #1A1A2E
    # 4 cardinal direction energy lines (2px each)
    for dx, dy in [(0, -1), (0, 1), (-1, 0), (1, 0)]:
        for i in range(2):
            px, py = 12 + dx * (5 + i), 12 + dy * (5 + i)
            d.point((px, py), fill=p.get('knight_accent', (0x88, 0x44, 0xBB)))
    # White center sparkle
    d.point((12, 12), fill=(255, 255, 255))
    save_img(img, 'skills/death_pulse.png')
```

---

## 8. Integration Notes for Programmer Agent

### 8.1 Files to Modify

| File | Change | Priority |
|------|--------|----------|
| `scripts/skill_effects.gd` line 278 | Change ring color from Color(0.5, 0.3, 0.7, 0.6) to Color(0.40, 0.15, 0.55, 0.7) | P2 (visual refinement) |
| `scripts/skill_effects.gd` death_pulse() | Add enemy tick flash modulate on each _death_pulse_tick | P2 (visual enhancement) |
| `tools/generate_sprites.py` | Add gen_death_pulse() function for skill icon | P2 |
| `scripts/hud_skill_button.gd` | Add necromancer icon_color match case | P1 (character select requires) |

### 8.2 Signal Connections

Death Pulse is already connected via `player_skill.gd` line 82:

```gdscript
"death_pulse":
    _player.skill_effects_node.death_pulse(_player, _player.damage_bonus)
```

No additional signal connections needed for VFX.

---

*Spec generated by Art Agent R35 on 2026-04-18*
*Parent spec: `docs/superpowers/specs/skill-vfx-spec.md`*
*Character design: `docs/superpowers/specs/necromancer-design.md` Section 3.4*
