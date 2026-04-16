# Skill VFX Specification

**Author**: Art Agent
**Date**: 2026-04-16
**Source**: `docs/superpowers/specs/character-skills.md` Section 7
**Related**: `scripts/skill_effects.gd` (to be created by Programmer Agent)

---

## 1. Overview

This document defines the complete visual effects (VFX) specification for the three character active skills: Elemental Burst (Mage), Shield Charge (Warrior), and Arrow Rain (Ranger). Each skill has distinct VFX elements that communicate its mechanics to the player through color, shape, animation, and screen shake.

All effects use ColorRect-based rendering (fallback-compatible) with planned Sprite2D upgrades. Effects follow the time-decay alpha pattern established in `art-log.md`.

---

## 2. Mage -- Elemental Burst VFX

### 2.1 Expanding Ring

| Attribute | Value | Notes |
|-----------|-------|-------|
| Shape | Circle (ColorRect scaling) | Centered on player position |
| Initial Radius | 0 px | Starts invisible at player center |
| Final Radius | 150 px | Matches `MAGE_SKILL_RADIUS` |
| Expand Duration | 0.2 s | Matches `MAGE_SKILL_EXPAND_TIME` |
| Color | Color(0.3, 0.5, 1.0) | Blue-white arcane energy |
| Alpha Start | 0.8 | Fully visible at cast |
| Alpha End | 0.0 | Fades out completely |
| Alpha Decay | Linear interpolation over 0.2s | `alpha = 0.8 * (1.0 - t / expand_time)` |
| Line Width | 3 px | Circle stroke width |
| Fill | None (ring only) | Transparent interior |

#### Animation Timeline

```
t=0.00s  [CAST]   Ring appears at radius 0, alpha 0.8
t=0.05s           Radius=37.5px, alpha=0.6
t=0.10s           Radius=75px,  alpha=0.4
t=0.15s           Radius=112.5px, alpha=0.2
t=0.20s           Radius=150px, alpha=0.0  [VFX END]
```

#### Implementation Notes
- Use a single ColorRect node with a script that scales it from 0x0 to 300x300 (150px radius = 300px diameter)
- Set `position = player_pos - size/2` each frame to keep centered
- Modulate alpha via `self_modulate.a`
- Z-index: above enemies, below HUD (z=5)

### 2.2 Enemy Freeze Modulate

| Attribute | Value | Notes |
|-----------|-------|-------|
| Target | All enemies within 150px radius | Area2D overlap check |
| Modulate Color | Color(0.5, 0.7, 1.0) | Blue tint overlay |
| Duration | 1.5 s | Matches `MAGE_SKILL_FREEZE_DURATION` |
| Transition In | Instant | Apply immediately on hit |
| Transition Out | 0.3 s fade | Smooth return to normal at end |

#### Color Rationale
- Blue tint Color(0.5, 0.7, 1.0) is a muted ice-blue that overlays the enemy's native color
- The tint is applied via `modulate` property, so enemy sprites remain visible underneath
- The 0.3s fade-out prevents jarring color pop when freeze expires

### 2.3 Screen Shake

| Attribute | Value | Notes |
|-----------|-------|-------|
| Intensity | 4.0 | Strongest skill shake (matches `MAGE_SKILL_SCREENSHAKE`) |
| Duration | 0.15 s | Short burst (matches `MAGE_SKILL_SCREENSHAKE_DUR`) |
| Decay Rate | intensity / duration = 26.67/s | Linear decay |
| Direction | Random Vector2(-1,1) normalized | Per-frame random |
| Apply To | Camera2D.offset | Per existing shake system |

### 2.4 ColorRect Fallback

If no Sprite2D assets are available:
- Ring: Draw using `draw_circle()` in `_draw()` with the specified color and alpha
- Freeze tint: Apply directly to enemy `modulate` property

---

## 3. Warrior -- Shield Charge VFX

### 3.1 Afterimage Trail (3 Red Ghosts)

| Attribute | Value | Notes |
|-----------|-------|-------|
| Count | 3 afterimages | Spaced along dash path |
| Size | 32x32 ColorRect | Same as player sprite |
| Shape | Rectangle (no rounded corners) | Simple rectangular ghost |
| Color | Color(0.9, 0.2, 0.1) | Bright red (warrior's combat color) |
| Alpha Pattern | 0.4 / 0.3 / 0.2 | First=most opaque, Last=most transparent |
| Spacing | Equal intervals along 160px dash | 40px apart (160 / 4 intervals) |
| Lifetime | 0.3 s each | Fade out over 0.3s |
| Alpha Decay | Linear from start alpha to 0 | `alpha = start_alpha * (1.0 - t / 0.3)` |

#### Afterimage Placement

```
Player start ──(40px)── Ghost1 ──(40px)── Ghost2 ──(40px)── Ghost3 ──(40px)── Player end
   alpha=0.4           alpha=0.3           alpha=0.2         (player at new pos)
```

#### Implementation Notes
- Create 3 ColorRect nodes at dash start position
- Each ghost positioned at: `start_pos + direction * (i+1) * 40`
- Each ghost runs independent alpha decay timer
- Ghosts use `z_index = -1` (behind player)

### 3.2 Stun Stars on Enemies

| Attribute | Value | Notes |
|-----------|-------|-------|
| Shape | Small rotating squares (6x6 px) | Represents stun stars |
| Count | 3 per enemy | Orbiting enemy head |
| Color | Color(1.0, 1.0, 0.0) | Yellow -- classic stun indicator |
| Orbit Radius | 8 px from enemy center top | Float above enemy sprite |
| Rotation Speed | 360 degrees / 1.5s = 240 deg/s | Continuous rotation |
| Duration | 2.0 s | Matches `WARRIOR_SKILL_STUN_DURATION` |
| Fade Out | 0.3 s at end of stun | Alpha decay |
| Position Offset | `enemy_pos + Vector2(0, -12)` | Above enemy sprite |

#### Star Animation

```
3 stars evenly spaced (120 degrees apart) orbiting enemy top:
  Star1 at angle theta
  Star2 at angle theta + 120
  Star3 at angle theta + 240

  theta increases by 240 deg/s (6.283 rad / 1.5s)

  Each star position:
    x = center_x + cos(theta + i * 2.094) * 8
    y = center_y + sin(theta + i * 2.094) * 8
```

#### Implementation Notes
- Create a Node2D "stun_indicator" parented to the stunned enemy
- Add 3 ColorRect children (6x6 each) positioned by orbit formula
- Rotate parent Node2D, children orbit naturally
- Queue free after stun duration + fade

### 3.3 Screen Shake

| Attribute | Value | Notes |
|-----------|-------|-------|
| Intensity | 3.0 | Medium-strong (matches `WARRIOR_SKILL_SCREENSHAKE`) |
| Duration | 0.1 s | Short impact burst (matches `WARRIOR_SKILL_SCREENSHAKE_DUR`) |
| Decay Rate | 30.0/s | Linear decay |
| Direction | Random Vector2(-1,1) normalized | Per-frame random |

### 3.4 ColorRect Fallback

- Afterimages: 3 ColorRect nodes with warrior_red color and alpha decay
- Stun stars: 3 ColorRect (6x6) nodes in orbiting parent

---

## 4. Ranger -- Arrow Rain VFX

### 4.1 Warning Circle (Target Indicator)

| Attribute | Value | Notes |
|-----------|-------|-------|
| Shape | Circle outline | Centered on target position |
| Radius | 100 px | Matches `RANGER_SKILL_RADIUS` |
| Duration | 0.3 s | Matches `RANGER_SKILL_WARNING_TIME` |
| Color | Color(1.0, 0.85, 0.0, 0.3) | Yellow, semi-transparent |
| Fill | Solid semi-transparent | Color(1.0, 0.85, 0.0, 0.15) interior |
| Outline Width | 2 px | Ring border |
| Pulse Animation | Alpha oscillates 0.15-0.35 | 2 pulses over 0.3s to draw attention |

#### Warning Timeline

```
t=0.00s  [APPEAR]  Yellow circle fades in at target, alpha=0.3
t=0.075s          Alpha peaks at 0.35 (pulse 1)
t=0.15s           Alpha dips to 0.15
t=0.225s          Alpha peaks at 0.35 (pulse 2)
t=0.30s           [ARROWS START] Warning circle disappears
```

#### Implementation Notes
- Single ColorRect node drawn as circle via `_draw()`
- Alpha pulse: `alpha = 0.25 + 0.1 * sin(t * 4 * PI / warn_time)`
- Z-index: above ground, below enemies (z=2)

### 4.2 Arrow Rain (12 Arrows)

| Attribute | Value | Notes |
|-----------|-------|-------|
| Arrow Count | 12 | Matches `RANGER_SKILL_ARROW_COUNT` |
| Arrow Shape | 4x12 ColorRect | Thin vertical rectangle |
| Arrow Color | Color(0.9, 0.9, 0.8) | Off-white (bone/wood color) |
| Arrow Tip | Top 2 rows filled Color(1.0, 1.0, 1.0) | White tip |
| Fall Area | 100px radius circle | Evenly distributed |
| Fall Duration | 0.5 s | Matches `RANGER_SKILL_FALL_DURATION` |
| Fall Pattern | Staggered -- arrows drop 2-3 at a time | Not all 12 simultaneously |
| Stagger Timing | 4 waves of 3 arrows each | Wave at t=0, 0.12, 0.25, 0.38 |

#### Arrow Distribution

12 arrows distributed evenly within 100px radius circle:

```
Inner ring (radius 30px): 3 arrows, 120 degrees apart
Middle ring (radius 60px): 4 arrows, 90 degrees apart
Outer ring (radius 90px): 5 arrows, 72 degrees apart

Arrow positions (angle from center):
  Inner:  0, 120, 240 degrees
  Middle: 45, 135, 225, 315 degrees
  Outer:  18, 90, 162, 234, 306 degrees
```

#### Arrow Fall Animation

```
Each arrow starts 200px above target (off-screen top):
  start_y = target_y - 200
  end_y = target_y (ground level)

  Duration per arrow: 0.2s (fast drop)
  Easing: ease_in (accelerating, simulating gravity)

  Arrow alpha: starts at 0.5, becomes 1.0 on impact
```

#### Implementation Notes
- Pre-calculate 12 landing positions at skill activation
- Create 12 ColorRect nodes (4x12 each) at off-screen positions
- Animate each arrow's y position toward landing position
- On landing, trigger flash effect and apply damage

### 4.3 Impact Flash

| Attribute | Value | Notes |
|-----------|-------|-------|
| Shape | Small expanding circle | At each arrow landing point |
| Initial Size | 4x4 px | Same as arrow width |
| Max Size | 12x12 px | Brief bright flash |
| Duration | 0.1 s per flash | Very short |
| Color | Color(1.0, 1.0, 0.8) | Warm white flash |
| Alpha Start | 0.9 | Bright |
| Alpha End | 0.0 | Fades out |
| Trigger | On each arrow landing | Individual per arrow |

#### Flash Timeline (per arrow)

```
t=landing  [FLASH]  White circle appears at 4x4, alpha=0.9
t+0.05s            Circle expands to 8x8, alpha=0.5
t+0.10s            Circle at 12x12, alpha=0.0 [FLASH END]
```

### 4.4 Screen Shake

| Attribute | Value | Notes |
|-----------|-------|-------|
| Intensity | 2.0 | Weakest skill shake (matches `RANGER_SKILL_SCREENSHAKE`) |
| Duration | 0.08 s | Very short burst (matches `RANGER_SKILL_SCREENSHAKE_DUR`) |
| Trigger | First arrow impact only | Not per-arrow |
| Decay Rate | 25.0/s | Linear decay |

### 4.5 ColorRect Fallback

- Warning circle: ColorRect drawn as circle via `_draw()`
- Arrows: 12 ColorRect nodes (4x12) with off-white color
- Impact flash: ColorRect nodes with white color and alpha decay

---

## 5. Screen Shake Comparison

| Skill | Intensity | Duration | Decay Rate | Feel |
|-------|-----------|----------|------------|------|
| Elemental Burst | 4.0 | 0.15s | 26.67/s | Heavy explosion |
| Shield Charge | 3.0 | 0.1s | 30.0/s | Impact punch |
| Arrow Rain | 2.0 | 0.08s | 25.0/s | Rapid barrage |

Reference: existing shake values from `art-log.md`:
- Damage shake: 3.0, decay 5.0/s
- Combo shake (>=20): 7.0, decay 5.0/s

All skill shakes use faster decay rates than the ambient damage shake, giving them a snappier, more intentional feel.

---

## 6. Skill Icon Sprites (HUD)

### 6.1 Skill Icon Specifications

| Character | Shape | Size | Color | Key Label |
|-----------|-------|------|-------|-----------|
| Mage | Circle | 24x24 | Color(0.2, 0.4, 0.9) blue | "E" white text |
| Warrior | Square with notch | 24x24 | Color(0.8, 0.2, 0.2) red | "E" white text |
| Ranger | Diamond | 24x24 | Color(0.2, 0.7, 0.3) green | "E" white text |

### 6.2 HUD Skill Button Layout

```
+----------------------------------+
|         (Game Area)              |
|                                  |
|                                  |
|              [HP] [XP] [Gold]   |
|              [Dash CD bar]      |
|              [SKILL icon]        |  <-- 24x24 icon
|              (E) cooldown       |  <-- key label + CD text
+----------------------------------+
```

### 6.3 Cooldown Overlay

| State | Visual | Color |
|-------|--------|-------|
| Ready | Gold border, full opacity | Color(1.0, 0.85, 0.3) border |
| Cooldown | Dark overlay, radial wipe | Color(0, 0, 0, 0.6) overlay |
| Activating | Brief flash, scale pulse 1.0 -> 1.2 -> 1.0 | White flash 0.1s |

---

## 7. VFX Color Summary Table

| VFX Element | Primary Color | Secondary Color | Alpha Range | Duration |
|-------------|--------------|----------------|-------------|----------|
| Burst Ring | Color(0.3, 0.5, 1.0) | -- | 0.8 -> 0.0 | 0.2s |
| Freeze Tint | Color(0.5, 0.7, 1.0) | -- | 1.0 -> 0.0 (last 0.3s) | 1.5s |
| Charge Afterimage | Color(0.9, 0.2, 0.1) | -- | 0.4/0.3/0.2 -> 0.0 | 0.3s |
| Stun Stars | Color(1.0, 1.0, 0.0) | -- | 1.0 -> 0.0 (last 0.3s) | 2.0s |
| Warning Circle | Color(1.0, 0.85, 0.0) | -- | 0.15-0.35 pulse | 0.3s |
| Arrows | Color(0.9, 0.9, 0.8) | Color(1.0, 1.0, 1.0) tip | 0.5 -> 1.0 | 0.5s |
| Impact Flash | Color(1.0, 1.0, 0.8) | -- | 0.9 -> 0.0 | 0.1s |

---

## 8. Performance Considerations

1. **Particle Limits**: Each skill creates a bounded number of VFX nodes:
   - Elemental Burst: 1 ring + N freeze modulates (enemies)
   - Shield Charge: 3 afterimages + 3 stun stars per enemy
   - Arrow Rain: 1 warning circle + 12 arrows + 12 flash effects

2. **Node Lifecycle**: All VFX nodes must be `queue_free()`'d after their animation completes. Maximum total VFX lifetime per skill activation is 2.0s (stun duration).

3. **Object Pooling**: For Arrow Rain, consider pooling the 12 arrow ColorRects to reduce allocation overhead when the skill is used repeatedly.

4. **Z-Index Layering**:
   - Warning circle: z=2 (above ground, below enemies)
   - Ring / afterimages / arrows: z=5 (above enemies, below HUD)
   - Stun stars: z=10 (above everything in game world)
   - Impact flash: z=6 (above arrows)

5. **No Texture Dependencies**: All VFX described here can be implemented with ColorRect alone. Sprite2D assets (from `assets/sprites/effects/` and `assets/sprites/skills/`) are optional enhancements.

---

## 9. Design Decisions Log

**Note**: This VFX spec was authored by the Art Agent based on the Designer Agent's skill definitions in `character-skills.md`. This log section was added during R9 designer review to ensure all visual values have traceable sources.

| Decision | Why | Value Source |
|---|---|---|
| Ring expansion radius = 150px | Matches `MAGE_SKILL_RADIUS` in character-skills.md Section 2.1 | character-skills.md |
| Ring expansion time = 0.2s | Matches `MAGE_SKILL_EXPAND_TIME` in character-skills.md Section 2.1 | character-skills.md |
| Freeze tint duration = 1.5s | Matches `MAGE_SKILL_FREEZE_DURATION` in character-skills.md Section 2.1 | character-skills.md |
| Burst screenshake = 4.0 / 0.15s | Matches `MAGE_SKILL_SCREENSHAKE` / `MAGE_SKILL_SCREENSHAKE_DUR` | character-skills.md |
| Charge dash distance = 160px | Matches `WARRIOR_SKILL_DISTANCE` | character-skills.md |
| Stun duration = 2.0s | Matches `WARRIOR_SKILL_STUN_DURATION` | character-skills.md |
| Charge screenshake = 3.0 / 0.1s | Matches `WARRIOR_SKILL_SCREENSHAKE` / `WARRIOR_SKILL_SCREENSHAKE_DUR` | character-skills.md |
| Arrow count = 12 | Matches `RANGER_SKILL_ARROW_COUNT` | character-skills.md |
| Warning time = 0.3s | Matches `RANGER_SKILL_WARNING_TIME` | character-skills.md |
| Rain radius = 100px | Matches `RANGER_SKILL_RADIUS` | character-skills.md |
| Arrow size = 4x12 px | Matches `RANGER_SKILL_ARROW_SIZE` for width | character-skills.md |
| Rain screenshake = 2.0 / 0.08s | Matches `RANGER_SKILL_SCREENSHAKE` / `RANGER_SKILL_SCREENSHAKE_DUR` | character-skills.md |
| Freeze tint Color(0.5, 0.7, 1.0) | Muted ice-blue that overlays enemy native color without obscuring it | Art Agent decision |
| Afterimage alpha 0.4/0.3/0.2 | Graduated opacity creates depth illusion with only 3 ghost nodes | Art Agent decision |
| Stun star orbit radius = 8px | Fits within 14-18px enemy sprite boundary without overlapping | Art Agent decision |
| All shake decay rates = intensity/duration | Linear decay matches art-log.md shake system convention | art-log.md |
| All VFX use ColorRect only | Project convention (art-log.md): pixel-art style, no texture dependencies | art-log.md |
| Z-index values (2, 5, 6, 10) | Layered to prevent visual overlap conflicts; matches art-log.md layer convention | art-log.md |
