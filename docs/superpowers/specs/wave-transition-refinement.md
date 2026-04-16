# Wave Transition Refinement Design Spec

**Author**: Designer Agent
**Date**: 2026-04-17
**Round**: R17
**Status**: Design Spec
**Priority**: P1
**Related**: `docs/superpowers/specs/wave-transition-vfx.md` (Art R9 banner spec), `scripts/hud.gd` (wave display system), `scripts/autoload/game_manager.gd` (WaveState, WAVE_DEFS)
**Friction Point**: R16 friction point 5 -- "wave transitions lack visual buffer"

---

## 1. Design Overview

Current wave transitions consist of: (a) a simple toast notification ("Wave N: Name") when a wave starts, (b) a progress bar at the top of the screen, (c) a "Next wave in X..." countdown during 3-second intermissions. There is no visual ceremony to the transition -- players can easily miss that a new wave has begun, and the intermission feels like dead time rather than a strategic pause.

This spec designs three wave transition improvements:

1. **Wave Start Banner** -- An animated slide-in banner showing wave number, name, and enemy type preview. Already partially specified in `wave-transition-vfx.md`; this spec adds the enemy preview element and connects it to the existing banner framework.
2. **Boss Wave Special Warning** -- Enhanced red flashing + screen shake that activates during Boss wave, building on the existing `boss_warning` signal and BossWarningBG from the Art spec.
3. **Wave Intermission Overlay** -- A countdown display with a safety indicator showing that no new enemies spawn during the break, giving players a moment to reposition and collect pickups.

**Why these three elements**: Vampire Survivors uses a simple wave timer but no transition effects. Brotato uses explicit wave boundaries with a shop between waves. HoloCure uses dramatic wave-start announcements. Our game falls between -- we have 3-second intermissions but waste them as dead time. Adding ceremony to the intermission makes it a strategic resource (time to collect gems, reposition) while the wave-start banner provides the "stage 1 clear" satisfaction loop.

---

## 2. Wave Start Banner Enhancement

### 2.1 Current State

The existing banner spec (`wave-transition-vfx.md`) defines:
- 600x80 ColorRect banner
- Slide-in from top (0.3s ease-out) -> hold (1.5s) -> slide-out (0.5s ease-in)
- Wave-specific gradient color from WAVE_DEFS
- Text: "Wave N: Name"

This spec adds one element to the existing banner: **enemy type preview icons**.

### 2.2 Enemy Preview Design

Below the wave name text, display small colored squares representing the enemy types that appear in this wave. Each square uses the enemy's characteristic color from ENEMY_TYPES.

**Layout**:

```
+------------------- 600x100 banner -------------------+
|  [gradient bg in wave color]                          |
|                                                       |
|  "Wave 3: Darkness"            <- Label, 28px, white  |
|  [green][purple][gray][lightgray]  <- enemy preview   |
|   zombie  bat  skeleton  ghost    <- tiny labels       |
|                                                       |
+------------------------------------------------------+
```

### 2.3 Banner Dimensions (Updated)

| Property | Previous Value | New Value | Reason |
|---|---|---|---|
| Height | 80px | 100px | Accommodate enemy preview row |
| All other dimensions | Unchanged | Unchanged | Width, slide distance, timing all remain |

### 2.4 Enemy Preview Constants

| Constant Name | Value | Unit | Source | Notes |
|---|---|---|---|---|
| `BANNER_ENEMY_ICON_SIZE` | 12.0 | px | Design | Size of each enemy color square |
| `BANNER_ENEMY_ICON_GAP` | 6.0 | px | Design | Horizontal gap between icons |
| `BANNER_ENEMY_ICON_Y_OFFSET` | 58.0 | px | Design | Y position relative to banner top |
| `BANNER_ENEMY_FONT_SIZE` | 9 | int | Design | Font size for enemy name labels |
| `BANNER_ENEMY_MAX_SHOW` | 5 | int | Design | Max enemy types shown (avoids overflow) |
| `BANNER_ENEMY_COLORS` | Dictionary | | H5 ENEMY_TYPES | Color mapping per enemy type |

### 2.5 Enemy Color Mapping

| Enemy Type | Color | Source |
|---|---|---|
| zombie | Color(0.30, 0.69, 0.31) green | H5 ENEMY_TYPES.zombie.color |
| bat | Color(0.67, 0.29, 0.74) purple | H5 ENEMY_TYPES.bat.color |
| skeleton | Color(0.88, 0.88, 0.88) light gray | H5 ENEMY_TYPES.skeleton.color |
| elite_skeleton | Color(0.72, 0.11, 0.11) dark red | H5 ENEMY_TYPES.elite_skeleton.color |
| ghost | Color(0.69, 0.74, 0.77) pale blue-gray | H5 ENEMY_TYPES.ghost.color |
| splitter | Color(0.0, 0.54, 0.48) teal | H5 ENEMY_TYPES.splitter.color |
| fire_slime | Color(1.0, 0.4, 0.13) orange | H5 ENEMY_TYPES (fire_slime variant) |
| boss | Color(0.96, 0.26, 0.21) bright red | H5 ENEMY_TYPES.boss.color |

### 2.6 Banner Node Structure (Updated)

```
WaveBanner (ColorRect, 600x100, anchored center)
  +-- Background (ColorRect, 596x96, centered, wave color)
  +-- OutlineTop/Bottom/Left/Right (ColorRect borders, 2px)
  +-- WaveLabel (Label, "Wave N: Name", white, 28px, centered)
  +-- EnemyPreviewContainer (HBoxContainer, centered, Y=58)
       +-- EnemyIcon (ColorRect, 12x12, enemy color) [per enemy type]
       +-- EnemyName (Label, enemy name, 9px, white) [per enemy type]
```

### 2.7 Wave-Specific Preview Content

| Wave | Name | Enemies Shown | Preview Colors |
|---|---|---|---|
| 1 | Opening | zombie (1) | green |
| 2 | Swarm | zombie, bat (2) | green, purple |
| 3 | Darkness | zombie, bat, skeleton, ghost (4) | green, purple, gray, pale |
| 4 | Elite | zombie, bat, skeleton, ghost, elite_skeleton, splitter, fire_slime (7 -> show 5) | green, purple, gray, pale, dark red (+ overflow "..." for 2 more) |
| 5 | Boss | [same as wave 4] + boss skull icon | [same as wave 4] |

**Overflow rule**: When enemy count exceeds `BANNER_ENEMY_MAX_SHOW` (5), show the first 4 types + a "+N more" label in place of the 5th icon. This prevents the banner from overflowing with tiny icons.

### 2.8 Integration with Existing Code

The banner is triggered by `GameManager.wave_started(wave: int, wave_name: String)`. The signal already fires in `hud.gd` line 329. The enhancement requires:

1. Reading `WAVE_DEFS[wave-1].enemies` to get the enemy list
2. Mapping enemy type strings to colors
3. Creating the ColorRect icons within the banner

**No new signals needed**. The existing `wave_started` signal carries sufficient data.

---

## 3. Boss Wave Special Warning

### 3.1 Current State

When Boss wave approaches (15 seconds before), `GameManager.boss_warning` fires and `hud.gd` displays a red text label for 2.5 seconds. The Art spec (`wave-transition-vfx.md` Section 4) adds a flashing red background behind the label.

### 3.2 Enhancement: Screen Shake + Banner Color Override

For Boss wave specifically, add two enhancements beyond the standard wave banner:

**3.2.1 Boss Banner Special Treatment**

When Wave 5 (Boss wave) starts, the banner uses:
- Deep red gradient (already defined: WAVE_DEFS[4].color = [1.0, 0.09, 0.17])
- Additional pulsing border (red outline pulses between alpha 0.5 and 1.0, 0.3s cycle)
- Skull icon (ColorRect 16x16, Color(1.0, 0.09, 0.17)) positioned before the wave label text
- Boss name in label: "Wave 5: BOSS" (uppercase, larger font 32px instead of 28px)

**3.2.2 Screen Shake on Boss Wave Start**

When `wave_started` fires for wave 5, trigger a strong screen shake via the existing `arena.gd` shake system.

| Constant Name | Value | Unit | Source | Notes |
|---|---|---|---|---|
| `BOSS_WAVE_SHAKE_INTENSITY` | 8.0 | intensity | H5 SCREEN_SHAKE.boss | Same as existing boss kill shake |
| `BOSS_WAVE_SHAKE_DURATION` | 0.3 | seconds | H5 SCREEN_SHAKE.boss | |
| `BOSS_BANNER_PULSE_SPEED` | 0.3 | seconds | Design | One full pulse cycle |
| `BOSS_BANNER_PULSE_MIN_ALPHA` | 0.5 | fraction | Design | Minimum border alpha |
| `BOSS_BANNER_PULSE_MAX_ALPHA` | 1.0 | fraction | Design | Maximum border alpha |
| `BOSS_BANNER_FONT_SIZE` | 32 | int | Design | Larger than standard 28px |
| `BOSS_BANNER_SKULL_SIZE` | 16.0 | px | Design | Skull icon dimensions |
| `BOSS_BANNER_SKULL_COLOR` | Color(1.0, 0.09, 0.17) | Color | WAVE_DEFS[4] | Deep red |

**3.2.3 Enhanced Boss Warning (Pre-Boss)**

The existing 15-second pre-boss warning gets two additions:

1. **Warning text update**: Change from "Boss 即将来袭！" to "Wave 5: BOSS -- 15s" with countdown. Update every second. This connects the warning to the wave system, giving players a concrete time reference.
2. **Progressive intensity**: The red flash background starts at alpha 0.2 and ramps to 0.7 over the 15 seconds. This creates a rising sense of urgency.

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| `BOSS_WARNING_COUNTDOWN` | true | bool | Show countdown in warning text |
| `BOSS_WARNING_RAMP_START_ALPHA` | 0.2 | fraction | Initial flash alpha |
| `BOSS_WARNING_RAMP_END_ALPHA` | 0.7 | fraction | Final flash alpha at boss spawn |
| `BOSS_WARNING_TOTAL_TIME` | 15.0 | seconds | Existing BOSS_WARNING_TIME |

### 3.3 Boss Warning Animation Timeline

```
T-15s: boss_warning signal fires
  - BossWarningLabel: "Wave 5: BOSS -- 15s" (updated each second)
  - BossWarningBG: alpha starts at 0.2, linearly ramps to 0.7 over 15s
  - Flash cycle: 0.4s (from wave-transition-vfx.md)

T-0s: Boss spawns (wave_started fires for wave 5)
  - BossWarningLabel/BG: hidden
  - Wave banner appears with Boss special treatment
  - Screen shake: intensity 8.0, duration 0.3s
  - Banner: pulsing red border, skull icon, "BOSS" uppercase 32px

T+2.3s: Banner slides out
  - Boss fight continues normally
```

---

## 4. Wave Intermission Overlay

### 4.1 Design Overview

During the 3-second intermission between waves, display a centered overlay that shows:

1. **Countdown timer**: Large number (3, 2, 1) counting down
2. **Next wave preview**: Wave name and enemy types
3. **Safety indicator**: A green shield icon indicating "no new enemies spawn"

This gives the intermission strategic value -- players know they have a brief safe window to collect pickups and reposition.

### 4.2 Layout

```
+------------------------------------------------------------------+
|                         (Game continues)                           |
|                                                                    |
|              +------ 400x120 overlay ------+                       |
|              |                               |                      |
|              |        "3"                    |  <- Large countdown |
|              |                               |                      |
|              |  "Next: Wave 3 Darkness"      |  <- Wave name        |
|              |  [green][purple][gray][pale]   |  <- Enemy preview    |
|              |  [shield] Safe to collect!     |  <- Safety note      |
|              |                               |                      |
|              +-------------------------------+                      |
|                                                                    |
+------------------------------------------------------------------+
```

### 4.3 Constants

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| `INTERMISSION_OVERLAY_WIDTH` | 400.0 | px | Overlay width |
| `INTERMISSION_OVERLAY_HEIGHT` | 120.0 | px | Overlay height |
| `INTERMISSION_BG_COLOR` | Color(0, 0, 0, 0.5) | Color | Semi-transparent black |
| `INTERMISSION_COUNTDOWN_FONT_SIZE` | 48 | int | Large countdown number |
| `INTERMISSION_COUNTDOWN_COLOR` | Color(1, 0.85, 0.3) | Color | Gold countdown text |
| `INTERMISSION_WAVE_FONT_SIZE` | 16 | int | Wave name text |
| `INTERMISSION_WAVE_COLOR` | Color(0.9, 0.9, 0.9) | Color | Light gray wave name |
| `INTERMISSION_SAFETY_COLOR` | Color(0.3, 0.69, 0.31) | Color | Green safety text |
| `INTERMISSION_SAFETY_ICON_SIZE` | 12.0 | px | Shield icon size |
| `INTERMISSION_FADE_IN_TIME` | 0.2 | seconds | Overlay fade-in |
| `INTERMISSION_FADE_OUT_TIME` | 0.3 | seconds | Overlay fade-out before wave starts |

### 4.4 Animation Timeline

```
Wave N ends:
  0.0s: wave_completed signal fires
  0.0s: Overlay fades in (alpha 0 -> 1, 0.2s)
  0.2s: Overlay fully visible, countdown starts at "3"
  1.0s: Countdown updates to "2"
  2.0s: Countdown updates to "1"
  2.7s: Overlay fades out (alpha 1 -> 0, 0.3s)
  3.0s: Overlay hidden, wave_started fires, banner appears
```

### 4.5 Safety Indicator Design

The safety indicator is a small green shield icon (ColorRect triangle) with text "Safe to collect!" in green. This communicates to new players that the intermission is a safe window, addressing R16 friction point 5 (players may not understand why enemies stop spawning).

```
Shield icon (12x14 ColorRect triangle):
    /\
   /  \
  /    \
 /______\
  green, pointing up

Text: "Safe to collect!" (12px, green)
```

### 4.6 Integration Points

| Signal | Handler | Action |
|---|---|---|
| `GameManager.wave_completed(wave)` | `hud.gd` | Create intermission overlay with next wave preview |
| `GameManager.wave_started(wave, wave_name)` | `hud.gd` | Destroy overlay, create wave banner |

The overlay reads `WAVE_DEFS[next_wave - 1]` to preview the upcoming wave's enemy types. This data is already available in the WAVE_DEFS constant array.

### 4.7 Edge Cases

| Case | Behavior |
|---|---|
| Wave 5 -> Victory (non-endless) | No intermission overlay; victory_achieved signal fires instead |
| Wave 5 -> Wave 1 (endless cycle) | Overlay shows "C2 Wave 1: Opening" with cycle prefix |
| Intermission during paused (upgrade panel) | Overlay is hidden behind upgrade panel; countdown continues |

---

## 5. Complete Animation Sequence (Per Wave)

### Normal Wave Transition (Wave 1 -> 2 -> 3 -> 4)

```
[Active gameplay in Wave N]
  |
  +-- Wave N timer expires
  |     |
  |     +-- wave_completed(N) fires
  |     |     +-- Intermission overlay fades in (0.2s)
  |     |     +-- Countdown: 3... 2... 1...
  |     |     +-- Next wave preview shown
  |     |
  |     +-- 3.0s intermission passes
  |           |
  |           +-- wave_started(N+1, name) fires
  |                 +-- Intermission overlay fades out (0.3s)
  |                 +-- Wave banner slides in from top (0.3s)
  |                 +-- Banner shows wave name + enemy preview
  |                 +-- Banner holds (1.5s)
  |                 +-- Banner slides out (0.5s)
  |
  +-- [Active gameplay in Wave N+1]
```

### Boss Wave Transition (Wave 4 -> 5)

```
[Active gameplay in Wave 4]
  |
  +-- T-15s: boss_warning fires
  |     +-- BossWarningLabel: "Wave 5: BOSS -- 15s" (countdown)
  |     +-- BossWarningBG: red flash, alpha ramping 0.2 -> 0.7
  |
  +-- Wave 4 timer expires
  |     +-- wave_completed(4) fires
  |     +-- Intermission overlay (same as above)
  |
  +-- wave_started(5, "Boss") fires
        +-- Boss warning hidden
        +-- Boss banner: pulsing red border, skull icon, "BOSS" 32px
        +-- Screen shake: intensity 8.0, 0.3s
        +-- Boss spawns and charges at player
```

---

## 6. Numerical Constants Summary

### 6.1 Banner Enhancement

| Constant | Value | File | Notes |
|---|---|---|---|
| BANNER_ENEMY_ICON_SIZE | 12.0 | hud.gd or banner script | Enemy preview icon size |
| BANNER_ENEMY_ICON_GAP | 6.0 | hud.gd or banner script | Gap between icons |
| BANNER_ENEMY_ICON_Y_OFFSET | 58.0 | hud.gd or banner script | Y position in banner |
| BANNER_ENEMY_FONT_SIZE | 9 | hud.gd or banner script | Enemy name label size |
| BANNER_ENEMY_MAX_SHOW | 5 | hud.gd or banner script | Max icons before overflow |
| BANNER_HEIGHT | 100 | wave-transition-vfx.md | Updated from 80 |

### 6.2 Boss Special

| Constant | Value | File | Notes |
|---|---|---|---|
| BOSS_WAVE_SHAKE_INTENSITY | 8.0 | hud.gd | Via arena.shake_screen |
| BOSS_WAVE_SHAKE_DURATION | 0.3 | hud.gd | |
| BOSS_BANNER_PULSE_SPEED | 0.3 | hud.gd or banner script | |
| BOSS_BANNER_FONT_SIZE | 32 | hud.gd or banner script | Larger than standard |
| BOSS_BANNER_SKULL_SIZE | 16.0 | hud.gd or banner script | |
| BOSS_BANNER_SKULL_COLOR | Color(1.0, 0.09, 0.17) | hud.gd or banner script | |
| BOSS_WARNING_RAMP_START | 0.2 | hud.gd | Initial flash alpha |
| BOSS_WARNING_RAMP_END | 0.7 | hud.gd | Final flash alpha |

### 6.3 Intermission Overlay

| Constant | Value | File | Notes |
|---|---|---|---|
| INTERMISSION_OVERLAY_WIDTH | 400.0 | hud.gd | |
| INTERMISSION_OVERLAY_HEIGHT | 120.0 | hud.gd | |
| INTERMISSION_BG_COLOR | Color(0, 0, 0, 0.5) | hud.gd | Semi-transparent |
| INTERMISSION_COUNTDOWN_FONT | 48 | hud.gd | Large countdown |
| INTERMISSION_COUNTDOWN_COLOR | Color(1, 0.85, 0.3) | hud.gd | Gold |
| INTERMISSION_SAFETY_COLOR | Color(0.3, 0.69, 0.31) | hud.gd | Green |
| INTERMISSION_FADE_IN | 0.2 | hud.gd | |
| INTERMISSION_FADE_OUT | 0.3 | hud.gd | |

---

## 7. Integration Map

### 7.1 Files to Modify

| File | Changes | Est. Lines |
|---|---|---|
| `scripts/hud.gd` | Enhance `_on_wave_started` to create banner with enemy preview. Enhance `_on_wave_completed` to create intermission overlay. Enhance `_on_boss_warning` with countdown and alpha ramp. Add boss wave screen shake trigger. | ~80 |
| `scenes/hud.tscn` | No changes (all elements created dynamically in code) | 0 |

### 7.2 New Files

| File | Content | Est. Lines |
|---|---|---|
| None | All elements built from ColorRect + Label + Tween in hud.gd | 0 |

### 7.3 Signals Used (all existing)

| Signal | Source | Current Handler | Enhancement |
|---|---|---|---|
| `wave_started(wave, wave_name)` | game_manager.gd | `_on_wave_started` (line 329) | Add enemy preview, boss shake |
| `wave_completed(wave)` | game_manager.gd | `_on_wave_completed` (line 333) | Add intermission overlay |
| `boss_warning()` | game_manager.gd | `_on_boss_warning` (line 93) | Add countdown, alpha ramp |

### 7.4 External Dependencies

| Dependency | Location | Status |
|---|---|---|
| `arena.gd shake_screen()` | arena.gd | Already exists |
| `WAVE_DEFS[].enemies` | game_manager.gd line 32-48 | Already exists |
| `WAVE_DEFS[].color` | game_manager.gd line 32-48 | Already exists |
| ENEMY_TYPES color mapping | H5 config.js | Needs local constant |

---

## 8. Design Decisions

| Decision | Why | Alternative Considered |
|---|---|---|
| Enemy preview as colored squares | Minimal implementation (ColorRect), no sprite dependency, instantly recognizable at 12x12px. Colors already defined in H5 config. | Actual enemy sprites in banner (requires loading textures, sizing, may not render at 12px) |
| BANNER_ENEMY_MAX_SHOW = 5 | Wave 4/5 have 7 enemy types. Showing all 7 at 12px + 6px gap = 126px, which overflows the banner. 5 icons + "+2" label stays within bounds. | Show all types (overflow), use smaller icons (hard to see at < 12px) |
| Intermission overlay at 400x120 | Large enough to show countdown + preview + safety note. Small enough to not obscure gameplay (30% of 1280px width). | Full-screen overlay (too intrusive), no overlay (current dead time) |
| Boss screen shake uses existing system | arena.gd already has shake_screen(intensity, duration). No new infrastructure needed. | Custom shake pattern (unnecessary complexity) |
| Boss warning countdown shows seconds | R16 friction: players see "Boss incoming" but have no time reference. Showing "15s... 14s... 13s" creates urgency and gives players time to prepare. | Static text for 15s (no countdown = players ignore it after a few seconds) |
| Intermission safety indicator | New players may not understand the intermission mechanic. "Safe to collect!" teaches them to use the pause strategically. | No explanation (players waste the intermission window) |
| All elements built from ColorRect + Label | No PNG dependencies. Works with existing pixel art style. Matches wave-transition-vfx.md ColorRect fallback approach. | Load sprite assets for each element (Art dependency, file I/O, slower) |

---

## 9. Test Case Suggestions

| Test Case | Verification | Priority |
|---|---|---|
| Banner shows enemy icons for Wave 2 | Verify HBoxContainer has 2 ColorRect children (zombie green, bat purple) | P0 |
| Banner overflow at 7 enemies | Wave 4 shows 4 icons + "+3 more" label | P0 |
| Boss wave banner has pulsing border | Verify outline alpha oscillates between 0.5 and 1.0 | P1 |
| Boss wave screen shake fires | Verify shake_screen called with intensity=8.0, duration=0.3 | P1 |
| Intermission overlay countdown | Verify countdown displays 3, 2, 1 at correct times | P0 |
| Intermission safety text visible | Verify green "Safe to collect!" label exists in overlay | P2 |
| Boss warning countdown updates | Verify text changes from "15s" to "14s" each second | P1 |
| Boss warning alpha ramps | Verify BG alpha at T-15 is 0.2 and at T-0 is 0.7 | P2 |
| Endless cycle wave preview | Verify C2 Wave 1 shows correct cycle-prefixed text | P2 |
| Victory wave has no intermission | Verify no overlay appears when wave 5 completes in non-endless | P1 |
