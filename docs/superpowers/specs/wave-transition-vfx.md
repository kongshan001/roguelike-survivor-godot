# Wave Transition VFX Specification

**Author**: Art Agent (R9)
**Date**: 2026-04-16
**Related**: `scripts/autoload/game_manager.gd` (WaveState, WAVE_DEFS, wave_started/wave_completed signals), `scripts/hud.gd` (_on_wave_started, _on_wave_completed, _on_boss_warning)

---

## 1. Overview

This document defines the visual effects for wave transitions in the 5-wave system. Three VFX elements are specified:

1. **Wave Start Banner** -- screen-center horizontal banner showing "Wave N: Name", 2s total
2. **Wave Complete Indicator** -- green checkmark icon + text, 1.5s
3. **Boss Warning Enhancement** -- red flashing background behind existing BossWarningLabel

All effects use ColorRect fallback compatible with existing HUD implementation.

---

## 2. Wave Start Banner

### 2.1 Layout

```
+-------- viewport center (y=0) --------+
|                                         |
|  +------ 600x80 banner ------+          |
|  |  gradient bg (wave color)  |         |
|  |                            |         |
|  |   "Wave 1: Opening"        |  <- Label, white, 28px font
|  |                            |         |
|  +----------------------------+         |
|                                         |
+-----------------------------------------+

Animation timeline:
  0.0s - 0.3s : slide in from top (y: -120 -> 0), ease-out
  0.3s - 1.8s : hold at center
  1.8s - 2.3s : slide out upward (y: 0 -> -120), ease-in
  2.3s         : queue_free()
```

### 2.2 Banner Dimensions

| Property | Value | Notes |
|----------|-------|-------|
| Width | 600 px | centered on viewport |
| Height | 80 px | approximately 10% of 800px viewport |
| Corner radius | 4 px | soft pixel-art corners |
| Z-index | 100 | above all game elements |

### 2.3 Wave Color Scheme

Each wave has a unique banner gradient color, sourced from `WAVE_DEFS[].color` in `game_manager.gd`.

| Wave | Name | Banner Gradient Color | Gradient Direction | Label Text |
|------|------|----------------------|--------------------|------------|
| 1 | Opening | Color(0.30, 0.69, 0.31) green | vertical, top->bottom: wave_color alpha 0.9 -> 0.5 | "Wave 1: Opening" |
| 2 | Swarm | Color(1.0, 0.84, 0.31) yellow | same gradient | "Wave 2: Swarm" |
| 3 | Darkness | Color(1.0, 0.57, 0.0) orange | same gradient | "Wave 3: Darkness" |
| 4 | Elite | Color(0.94, 0.33, 0.31) red | same gradient | "Wave 4: Elite" |
| 5 | Boss | Color(1.0, 0.09, 0.17) deep red | same gradient | "Wave 5: Boss" |

### 2.4 Color Constants Table

| Constant | Type | Value | Usage |
|----------|------|-------|-------|
| BANNER_WIDTH | int | 600 | Banner ColorRect width |
| BANNER_HEIGHT | int | 80 | Banner ColorRect height |
| BANNER_SLIDE_DURATION | float | 0.3 | Slide in/out time |
| BANNER_HOLD_DURATION | float | 1.5 | Hold at center time |
| BANNER_TOTAL_DURATION | float | 2.3 | Total banner display time |
| BANNER_SLIDE_DISTANCE | float | 120.0 | Slide travel distance (px) |
| BANNER_FONT_SIZE | int | 28 | Wave label font size |
| BANNER_LABEL_COLOR | Color | Color(1.0, 1.0, 1.0) | White text |
| BANNER_OUTLINE_COLOR | Color | Color(0.102, 0.102, 0.18) | #1A1A2E dark outline (2px border) |
| BANNER_OUTLINE_WIDTH | int | 2 | Outline border thickness |
| BANNER_Z_INDEX | int | 100 | Above game elements |

### 2.5 Banner Structure (Node Tree)

```
WaveBanner (ColorRect, 600x80, anchored center)
  +-- Background (ColorRect, 596x76, centered, wave color gradient)
  +-- OutlineTop (ColorRect, 600x2, #1A1A2E)
  +-- OutlineBottom (ColorRect, 600x2, #1A1A2E)
  +-- OutlineLeft (ColorRect, 2x80, #1A1A2E)
  +-- OutlineRight (ColorRect, 2x80, #1A1A2E)
  +-- WaveLabel (Label, "Wave N: Name", white, 28px, centered)
```

### 2.6 ColorRect Fallback

When `wave_banner.png` is not available, the banner is constructed from ColorRect nodes:

```
Background ColorRect:
  - size: 600x80
  - color: wave_color with alpha gradient
  - Implementation: single ColorRect with modulate alpha animation

Outline ColorRects (4 sides):
  - color: Color(0.102, 0.102, 0.18)  #1A1A2E
  - 2px thick border

WaveLabel:
  - Label node
  - text: "Wave %d: %s" % [wave, wave_name]
  - font_color: Color(1.0, 1.0, 1.0) white
  - font_size: 28
```

### 2.7 Integration Points

| Signal | Handler Location | Action |
|--------|-----------------|--------|
| `GameManager.wave_started(wave, wave_name)` | `hud.gd` | Create WaveBanner, animate slide-in/hold/slide-out |
| `GameManager.wave_completed(wave)` | `hud.gd` | Show WaveComplete indicator |
| `GameManager.boss_warning()` | `hud.gd` | Enhance BossWarningLabel with flashing background |

### 2.8 Endless Mode Cycle Prefix

When `current_cycle > 1`, the wave_name is prefixed with "C%d " (e.g., "C2 Opening"). The banner label automatically reflects this via the `wave_name` parameter from the signal.

---

## 3. Wave Complete Indicator

### 3.1 Layout

```
  +---- 40x40 ----+
  |                |
  |   green V / checkmark icon
  |                |
  +----------------+
       +-- Label: "Wave Complete!"
       |   Color(0.3, 0.69, 0.31) green text, 20px font
```

### 3.2 Animation Timeline

```
  0.0s - 0.15s : scale 0.0 -> 1.2 (pop in), ease-out
  0.15s - 0.3s : scale 1.2 -> 1.0 (settle), ease-in-out
  0.3s - 1.2s  : hold with gentle alpha pulse (1.0 -> 0.85 -> 1.0, 2 cycles)
  1.2s - 1.5s  : fade out alpha 1.0 -> 0.0
  1.5s          : queue_free()
```

### 3.3 Color Constants Table

| Constant | Type | Value | Usage |
|----------|------|-------|-------|
| COMPLETE_ICON_SIZE | int | 40 | Checkmark icon size |
| COMPLETE_ICON_COLOR | Color | Color(0.3, 0.69, 0.31) | Green #4CAF50 |
| COMPLETE_LABEL_COLOR | Color | Color(0.3, 0.69, 0.31) | Green text |
| COMPLETE_LABEL_FONT_SIZE | int | 20 | Font size |
| COMPLETE_TOTAL_DURATION | float | 1.5 | Total display time |
| COMPLETE_POP_DURATION | float | 0.15 | Pop-in scale time |
| COMPLETE_SETTLE_DURATION | float | 0.15 | Scale settle time |

### 3.4 Checkmark Icon Design (40x40)

The checkmark is drawn as a ColorRect-based V shape:

```
Pixel layout (40x40 canvas, each cell is ~2x2 real pixels):

        ##
         ##
          ##
           ##
            ##
           ##
          ##
         ##
        ##

Stroke: 4px wide diagonal lines forming a checkmark V
Color: Color(0.3, 0.69, 0.31) #4DB04F
Outline: Color(0.102, 0.102, 0.18) #1A1A2E, 2px
Background: transparent
```

### 3.5 ColorRect Fallback

```
WaveCompleteIcon (ColorRect, 40x40, transparent):
  - Use _draw() to render green checkmark strokes
  - Or use pre-generated wave_complete.png sprite

WaveCompleteLabel (Label):
  - text: "Wave Complete!"
  - font_color: Color(0.3, 0.69, 0.31)
  - font_size: 20
```

---

## 4. Boss Warning Enhancement

### 4.1 Current State

The current `BossWarningLabel` in `hud.gd` (line 103-110) is a plain Label:
- Text: skull emoji + "Boss 即将来袭!"
- Color: Color(1.0, 0.1, 0.1) red
- Duration: 2.5s then hidden

### 4.2 Enhancement: Flashing Red Background

Add a full-width red background ColorRect behind the BossWarningLabel that pulses between alpha 0.3 and 0.7.

### 4.3 Layout

```
+-- viewport width ---- x 60px -- anchor top center --+
|  [Red Flash BG ColorRect, alpha pulsing 0.3 <-> 0.7] |
|                                                        |
|      "Boss 即将来袭!" (existing Label, red text)        |
|                                                        |
+-------------------------------------------------------+
```

### 4.4 Color Constants Table

| Constant | Type | Value | Usage |
|----------|------|-------|-------|
| BOSS_FLASH_BG_COLOR | Color | Color(0.8, 0.1, 0.1) | Deep red background |
| BOSS_FLASH_ALPHA_MIN | float | 0.3 | Minimum flash alpha |
| BOSS_FLASH_ALPHA_MAX | float | 0.7 | Maximum flash alpha |
| BOSS_FLASH_CYCLE_TIME | float | 0.4 | One full pulse cycle (seconds) |
| BOSS_WARNING_DURATION | float | 2.5 | Total warning display time (existing) |
| BOSS_FLASH_BG_HEIGHT | int | 60 | Flash background height |
| BOSS_FLASH_BG_WIDTH_RATIO | float | 1.0 | Full viewport width |

### 4.5 Animation

```
Alpha pulse formula:
  t = fmod(elapsed, BOSS_FLASH_CYCLE_TIME)
  if t < BOSS_FLASH_CYCLE_TIME / 2:
    alpha = BOSS_FLASH_ALPHA_MIN + (BOSS_FLASH_ALPHA_MAX - BOSS_FLASH_ALPHA_MIN) * (t / (BOSS_FLASH_CYCLE_TIME / 2))
  else:
    alpha = BOSS_FLASH_ALPHA_MAX - (BOSS_FLASH_ALPHA_MAX - BOSS_FLASH_ALPHA_MIN) * ((t - BOSS_FLASH_CYCLE_TIME / 2) / (BOSS_FLASH_CYCLE_TIME / 2))

Timeline:
  0.0s - 2.5s : alpha pulse between 0.3 and 0.7 (approx 6 full cycles)
  2.5s         : background hidden along with label
```

### 4.6 Node Structure Addition

```
BossWarningBG (ColorRect, full-width x 60px)
  - anchor_top: true
  - color: Color(0.8, 0.1, 0.1, 0.3)
  - z_index: behind BossWarningLabel

BossWarningLabel (existing Label)
  - no changes to text/color
  - z_index: above BossWarningBG
```

### 4.7 ColorRect Fallback

The flashing background is purely ColorRect-based. No PNG asset needed.

```
BossWarningBG implementation:
  var bg = ColorRect.new()
  bg.name = "BossWarningBG"
  bg.color = Color(0.8, 0.1, 0.1, 0.3)
  bg.set_anchors_preset(Control.PRESET_CENTER_TOP)
  bg.offset_left = -viewport_width / 2
  bg.offset_right = viewport_width / 2
  bg.offset_top = 0
  bg.offset_bottom = 60

  In _process():
    if bg.visible:
      var t = fmod(Time.get_ticks_msec() / 1000.0, 0.4)
      bg.color.a = 0.3 + 0.4 * abs(sin(t * PI / 0.4))
```

---

## 5. Sprite Assets Required

### 5.1 New PNG Sprites

| Asset | Size | Path | Fallback |
|-------|------|------|----------|
| Wave Banner (5 colors) | 600x80 each | `assets/sprites/ui/wave_banner_w1.png` through `wave_banner_w5.png` | ColorRect with wave_color |
| Wave Complete Checkmark | 40x40 | `assets/sprites/ui/wave_complete.png` | ColorRect _draw() checkmark |
| Fire Slime (32x32 variant) | 32x32 | `assets/sprites/enemies/fire_slime.png` | ColorRect Color(1.0, 0.4, 0.133) |

### 5.2 Existing Sprites Referenced

| Asset | Path | Usage |
|-------|------|-------|
| wave_transition.png | `assets/sprites/ui/wave_transition.png` | Background gradient for banner (1280x80) |
| boss_warning.png | `assets/sprites/ui/boss_warning.png` | Boss skull icon (24x24) |

---

## 6. Design Decisions

### 6.1 Banner Slide Animation

- **Decision**: Top-to-center-to-top slide, 0.3s in + 1.5s hold + 0.5s out = 2.3s total
- **Why**: Matches the quick rhythm of wave transitions. 1.5s hold is long enough to read the wave name but short enough to not obstruct gameplay. Ease-out on entry gives a satisfying "landing" feel.
- **Alternative rejected**: Fade in/out (too passive, lacks impact for wave transitions)

### 6.2 Per-Wave Color Scheme

- **Decision**: Each wave uses its WAVE_DEFS color for the banner gradient
- **Why**: Color coding reinforces wave identity. Green=safe opening, yellow=swarming, orange=darkness, red=elite danger, deep red=boss. Colors already defined in game_manager.gd WAVE_DEFS.
- **Alternative rejected**: Single color for all waves (loses wave identity cue)

### 6.3 Boss Warning Flash Background

- **Decision**: Full-width red ColorRect with alpha pulsing 0.3-0.7, 0.4s cycle
- **Why**: Current text-only warning is easy to miss during intense gameplay. Pulsing red background creates urgency without being obnoxious. Alpha range (0.3-0.7) is visible but does not fully obscure game view.
- **Alternative rejected**: Screen shake (already used for damage/combos, would desensitize), full-screen red flash (too aggressive)

### 6.4 Wave Complete Green Checkmark

- **Decision**: 40x40 green checkmark icon + "Wave Complete!" text, pop-in animation
- **Why**: Green checkmark is universally understood as "completed". Pop-in animation provides satisfying feedback. 1.5s duration matches intermission pacing.
- **Alternative rejected**: Full-screen overlay (blocks gameplay), no visual feedback (unsatisfying)

---

## 7. Integration Map

### Files to Modify (by Programmer Agent)

| File | Changes |
|------|---------|
| `scripts/hud.gd` | Add `_on_wave_started` banner creation, `_on_wave_completed` checkmark creation, `_on_boss_warning` flash BG creation |
| `scenes/hud.tscn` | Add BossWarningBG ColorRect node |

### New Files (by Programmer Agent)

| File | Content |
|------|---------|
| None | All VFX built from ColorRect + Label in hud.gd |

### Signal Connections (existing, no changes needed)

| Signal | Already Connected | Handler |
|--------|------------------|---------|
| `GameManager.wave_started` | Yes (hud.gd:29) | `_on_wave_started` (enhance) |
| `GameManager.wave_completed` | Yes (hud.gd:30) | `_on_wave_completed` (enhance) |
| `GameManager.boss_warning` | Yes (hud.gd:28) | `_on_boss_warning` (enhance) |
