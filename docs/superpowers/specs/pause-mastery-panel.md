# Pause Menu Mastery Panel Spec

**Author**: Designer Agent
**Date**: 2026-04-17
**Round**: R26
**Status**: Design Spec
**Priority**: P1 HIGH
**Context**: hud_mastery_panel.gd (122 lines, R25) handles badge creation and tier-up flash. The pause menu mastery panel is the last missing UI surface for weapon mastery. Currently pressing Escape during gameplay does nothing -- the game has no pause state outside the upgrade panel. This spec defines the pause overlay with embedded mastery information, plus a new `build_pause_panel()` function in hud_mastery_panel.gd.

---

## 1. Design Overview

When the player presses Escape during active gameplay (not during upgrade selection, not during game over), the game pauses and shows a centered overlay containing:

1. **Status header** -- current timer, wave, gold, level
2. **Weapon mastery section** -- 7 base weapons with tier/progress bar/kill count/bonus
3. **Action buttons** -- Resume and Quit to title

The mastery panel reuses `hud_mastery_panel.gd` by adding a `build_pause_panel()` function that returns a Control node. The pause/unpause trigger lives in `hud.gd` `_input()`.

**Why now**: The mastery backend (SaveManager) and badge/toast subsystem are deployed. The only missing piece is the "detailed progress view" that players need to understand their mastery standing. Without it, mastery progress is invisible except for the tiny 6x6 badge on weapon slots and momentary tier-up toasts.

---

## 2. Pause Trigger Design

### 2.1 Input Binding

Pressing Escape toggles pause. This is handled in `hud.gd` `_input()`:

```
Current _input() handles:
- KEY_1/2/3 for upgrade selection (when UpgradePanel visible)
- KEY_R for reroll (when UpgradePanel visible)
- KEY_Q for retreat (endless mode)
```

New case added to `_input()`:

| Key | Condition | Action |
|---|---|---|
| KEY_ESCAPE | UpgradePanel NOT visible, game NOT over, game NOT paused | Pause + show overlay |
| KEY_ESCAPE | Pause overlay IS visible | Resume + hide overlay |
| KEY_ESCAPE | UpgradePanel IS visible | Do nothing (upgrade panel has priority) |

### 2.2 Pause State

The pause uses Godot's built-in `get_tree().paused = true` (same mechanism as upgrade panel). The pause overlay's process_mode is set to `PROCESS_MODE_ALWAYS` so it remains interactive while paused.

### 2.3 Process Mode Requirements

| Node | process_mode | Reason |
|---|---|---|
| hud.gd (CanvasLayer) | PROCESS_MODE_ALWAYS (already set in _ready) | Needs to receive _input during pause |
| PausePanel (Panel) | PROCESS_MODE_ALWAYS | Button clicks must work while paused |
| Mastery progress bars | N/A (static on creation) | No per-frame updates needed |

---

## 3. Pause Overlay Layout

### 3.1 Dimensions

| Property | Value | Rationale |
|---|---|---|
| Panel width | 320px | Fits 7 weapon rows with 80px progress bar + text comfortably |
| Panel height | 480px | Header 60px + divider 4px + section header 20px + 7 weapons x 40px = 280px + buttons 60px + padding ~56px |
| Position | Center of viewport | Anchors PRESET_CENTER |
| Background | Color(0.05, 0.05, 0.1, 0.92) | Semi-transparent dark, nearly opaque for readability |
| Border | 2px solid Color(1.0, 0.84, 0.0) | Gold border consistent with mastery theme |
| Corner radius | Not applicable (ColorRect pixel art style) | Consistent with project visual style |

### 3.2 ASCII Layout

```
+==========================================+
|                PAUSED                     |
|                                           |
|  Time: 03:42    Wave: 3/5  Gold: 47      |
|  Level: 7       Character: Warrior        |
|                                           |
|  --- WEAPON MASTERY ---                   |
|                                           |
|  [icon] Knife       Apprentice  52/200   |
|         [=---------]  +2% DMG            |
|                                           |
|  [icon] Holy Water  Adept       204/500  |
|         [=====-----]  +4% DMG            |
|                                           |
|  [icon] Lightning   Expert      623/1000 |
|         [========--]  +6% DMG            |
|                                           |
|  [icon] Bible       Novice       12/50   |
|         [==--------]  +0% DMG            |
|                                           |
|  [icon] Fire Staff  Adept       312/500  |
|         [======----]  +4% DMG            |
|                                           |
|  [icon] Frost Aura  Novice       38/50   |
|         [=========-]  +0% DMG            |
|                                           |
|  [icon] Boomerang   Master      1023     |
|         [==========]  +8% DMG            |
|         *** DIAMOND ***                   |
|                                           |
|    [ Resume ]        [ Quit ]             |
+==========================================+
```

### 3.3 Node Tree

```
PausePanel (PanelContainer, PRESET_CENTER, PROCESS_MODE_ALWAYS)
  +-- VBoxContainer (main column)
       +-- Label "PAUSED" (36px, gold, centered)
       +-- HBoxContainer (status row 1: Timer, Wave, Gold)
       |    +-- Label TimerLabel
       |    +-- Label WaveLabel
       |    +-- Label GoldLabel
       +-- HBoxContainer (status row 2: Level, Character)
       |    +-- Label LevelLabel
       |    +-- Label CharacterLabel
       +-- ColorRect (divider line, 280x2, gold)
       +-- Label "--- WEAPON MASTERY ---" (14px, gold, centered)
       +-- VBoxContainer (weapon rows, 7 children)
       |    +-- HBoxContainer (weapon row 1: Knife)
       |    |    +-- ColorRect (icon, 12x12, weapon color)
       |    |    +-- VBoxContainer (name + tier row, bar + bonus row)
       |    |         +-- HBoxContainer (name, tier, kills)
       |    |         |    +-- Label (weapon name, 12px, white)
       |    |         |    +-- Label (tier name, 12px, tier color)
       |    |         |    +-- Label (kill count, 12px, white)
       |    |         +-- HBoxContainer (progress bar, bonus text)
       |    |              +-- ColorRect (bar bg, 80x4, dark)
       |    |              +-- ColorRect (bar fill, 80*ratio x4, tier color)
       |    |              +-- Label (bonus text, 10px, tier color)
       |    +-- ... (6 more weapon rows)
       +-- Label (diamond indicator, Master weapons only)
       +-- HBoxContainer (buttons)
            +-- Button "Resume"
            +-- Button "Quit"
```

---

## 4. Weapon Row Element Specifications

### 4.1 Per-Row Elements

Each weapon row is 40px tall and contains:

| Element | Type | Size | Font Size | Color | Position |
|---|---|---|---|---|---|
| Weapon icon | ColorRect | 12x12 | -- | Weapon primary color | Left-aligned, vertical center |
| Weapon name | Label | auto | 12px | Color.WHITE (0.95, 0.95, 0.95) | After icon, 4px gap |
| Tier name | Label | auto | 12px | Tier color (bronze/silver/gold/diamond) | After name, 4px gap |
| Kill count | Label | auto | 12px | Color.WHITE | Right-aligned in row |
| Progress bar bg | ColorRect | 80x4 | -- | Color(0.15, 0.15, 0.2) | Below name/tier row |
| Progress bar fill | ColorRect | 80*ratio x4 | -- | Tier color, alpha 0.8 | Inside bg |
| Bonus text | Label | auto | 10px | Tier color | After progress bar, 8px gap |

### 4.2 Weapon Icon Colors

Same colors used in upgrade cards and mastery badges:

| weapon_id | Display Name | Icon Color |
|---|---|---|
| knife | Knife | Color(0.75, 0.75, 0.8) |
| holywater | Holy Water | Color(0.3, 0.5, 1.0) |
| lightning | Lightning | Color(1.0, 1.0, 0.3) |
| bible | Bible | Color(0.9, 0.85, 0.7) |
| firestaff | Fire Staff | Color(1.0, 0.4, 0.1) |
| frostaura | Frost Aura | Color(0.5, 0.8, 1.0) |
| boomerang | Boomerang | Color(0.6, 0.4, 0.2) |

### 4.3 Progress Bar Fill Calculation

```
var current_kills: int = SaveManager.get_weapon_kill_count(weapon_id)
var tier: int = SaveManager.get_weapon_mastery_tier(weapon_id)

# Next threshold (for progress within current tier)
var lower_threshold: int = MASTERY_THRESHOLDS[tier]
var upper_threshold: int = MASTERY_THRESHOLDS[tier + 1] if tier < 4 else MASTERY_THRESHOLDS[4]

if tier == 4:
    fill_ratio = 1.0  # Master: full bar
else:
    fill_ratio = clampf(float(current_kills - lower_threshold) / float(upper_threshold - lower_threshold), 0.0, 1.0)

var fill_width: float = 80.0 * fill_ratio
```

**Why tier-relative progress**: Showing total kills / 1000 for a Novice weapon (e.g., 12/1000) would show a nearly empty bar for most of the game. Tier-relative progress (e.g., 12/50 for Novice) gives meaningful visual feedback at every tier. When a player reaches Apprentice at 50 kills, the progress bar resets to 0 and starts filling toward 200.

### 4.4 Kill Count Display

| Tier | Display Format | Example |
|---|---|---|
| 0 (Novice) | "{kills}/{next_threshold}" | "12/50" |
| 1 (Apprentice) | "{kills}/{next_threshold}" | "52/200" |
| 2 (Adept) | "{kills}/{next_threshold}" | "204/500" |
| 3 (Expert) | "{kills}/{next_threshold}" | "623/1000" |
| 4 (Master) | "{kills}" | "1023" |

**Why no "/1000" for Master**: Master is the maximum tier. Showing "/1000" implies there is further progress to make. Displaying just the kill count communicates completion clearly.

### 4.5 Bonus Text Format

| Tier | Text | Color |
|---|---|---|
| 0 | "+0% DMG" | Color(0.5, 0.5, 0.5) (gray) |
| 1 | "+2% DMG" | MASTERY_TIER_COLORS[1] (bronze) |
| 2 | "+4% DMG" | MASTERY_TIER_COLORS[2] (silver) |
| 3 | "+6% DMG" | MASTERY_TIER_COLORS[3] (gold) |
| 4 | "+8% DMG" | MASTERY_TIER_COLORS[4] (diamond) |

### 4.6 Master Row Special Treatment

When a weapon is at tier 4 (Master):

1. Progress bar is full (80px fill width) with a 2px outer glow:
   - ColorRect at 84x6 px, offset (-2, -1) from bar, alpha 0.3, diamond color
2. Kill count shows plain number (no denominator)
3. A label "*** DIAMOND ***" appears below the weapon rows section, 10px font, diamond color

---

## 5. Status Header Content

### 5.1 Data Sources

| Label | Data Source | Format |
|---|---|---|
| Timer | GameManager.elapsed_time | "Time: {mm:ss}" via GameManager.format_time() |
| Wave | GameManager.current_wave, WAVE_DEFS.size() | "Wave: {n}/{total}" |
| Gold | GameManager.gold | "Gold: {n}" |
| Level | GameManager.player_level | "Level: {n}" |
| Character | GameManager.selected_character | "Character: {name}" |

### 5.2 Character Name Mapping

| selected_character | Display Name |
|---|---|
| "warrior" | "Warrior" |
| "mage" | "Mage" |
| "ranger" | "Ranger" |

---

## 6. Action Buttons

### 6.1 Resume Button

| Property | Value |
|---|---|
| Text | "Resume" |
| Size | 120x32 px |
| Position | Left side of bottom HBoxContainer |
| Action | `get_tree().paused = false`, hide overlay |
| Shortcut | Escape key (same trigger) |

### 6.2 Quit Button

| Property | Value |
|---|---|
| Text | "Quit" |
| Size | 120x32 px |
| Position | Right side of bottom HBoxContainer |
| Action | `get_tree().paused = false`, change scene to main.tscn |
| Shortcut | None (intentional -- prevent accidental quit) |

### 6.3 Button Styling

Both buttons use the project's pixel art style:

| Property | Value |
|---|---|
| Background | Color(0.15, 0.15, 0.2) |
| Border | 1px, Color(0.3, 0.3, 0.35) |
| Text color | Color(0.9, 0.9, 0.9) |
| Hover background | Color(0.2, 0.2, 0.3) |
| Hover border | Color(1.0, 0.84, 0.0) gold |
| Font size | 14px |

---

## 7. hud_mastery_panel.gd Extension

### 7.1 New Public Function

Add `build_pause_panel()` to hud_mastery_panel.gd:

```
func build_pause_panel() -> Control:
    # Creates and returns a PanelContainer containing the full pause overlay.
    # Reads data from SaveManager.weapon_kills and GameManager.
    # The returned node must be added to the CanvasLayer by hud.gd.
    # Approximately 45 lines.
```

### 7.2 Helper Functions

| Function | Purpose | Lines |
|---|---|---|
| `_build_status_header() -> HBoxContainer` | Creates timer/wave/gold/level row | ~12 |
| `_build_weapon_row(weapon_id: String) -> HBoxContainer` | Creates one weapon's icon/name/tier/bar | ~18 |
| `_build_action_buttons() -> HBoxContainer` | Creates resume/quit buttons | ~10 |

### 7.3 hud_mastery_panel.gd Line Budget

| Existing code | 122 lines |
|---|---|
| build_pause_panel() + helpers | ~45 lines |
| New constants (icon colors, label formats) | ~12 lines |
| **Total after** | **~179 lines** |

This is within the 500-line limit for the module (it is a RefCounted, not a scene script, so the 500-line guideline is relaxed but we keep it under 200).

---

## 8. hud.gd Integration

### 8.1 Changes to _input()

Add Escape key handling to the existing `_input()` function. Insert after the upgrade panel handling:

```
# After upgrade panel key handling:
if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
    if $UpgradePanel.visible or GameManager.is_game_over:
        return  # Do nothing during upgrade or game over
    _toggle_pause()
```

### 8.2 Pause State Management

```
var _pause_panel: Control = null

func _toggle_pause() -> void:
    if get_tree().paused and _pause_panel != null:
        # Resume
        get_tree().paused = false
        _pause_panel.queue_free()
        _pause_panel = null
    elif not get_tree().paused:
        # Pause
        get_tree().paused = true
        _pause_panel = _mastery_panel.build_pause_panel()
        add_child(_pause_panel)
        # Connect resume/quit buttons
        _pause_panel.get_node("VBox/Buttons/ResumeBtn").pressed.connect(_toggle_pause)
        _pause_panel.get_node("VBox/Buttons/QuitBtn").pressed.connect(_on_quit_to_title)
```

### 8.3 Quit Handler

```
func _on_quit_to_title() -> void:
    get_tree().paused = false
    if _pause_panel:
        _pause_panel.queue_free()
        _pause_panel = null
    get_tree().change_scene_to_file("res://scenes/main.tscn")
```

### 8.4 hud.gd Line Budget

| Current | 413 lines |
|---|---|
| New pause code (_toggle_pause + _on_quit_to_title + _input change + _pause_panel var) | ~25 lines |
| **Total after** | **~438 lines** |

This is within the 500-line limit with 62 lines of headroom.

---

## 9. Interaction Edge Cases

### 9.1 Pause During Upgrade Panel

The upgrade panel already sets `get_tree().paused = true`. Pressing Escape during the upgrade panel should NOT show the pause overlay. The guard `if $UpgradePanel.visible` prevents this.

### 9.2 Pause During Boss Warning

Boss warning label is visible for 2.5 seconds. Pause overlay covers it. This is acceptable -- the player chose to pause, and boss warnings repeat periodically.

### 9.3 Pause During Active Skills

Skills with ongoing effects (Elemental Burst, Arrow Rain, Shield Bash) continue their visual state but the game is frozen. When resumed, effects continue from where they paused. No special handling needed -- Godot's pause system naturally freezes timers and tweens that are not in PROCESS_MODE_ALWAYS.

### 9.4 Pause During Toast Display

The toast system uses `PROCESS_MODE_ALWAYS` tweens (per hud_toast.gd line 95). This means a toast that was mid-animation when paused will continue animating behind the pause overlay. The pause overlay is opaque enough (alpha 0.92) that this is not visually distracting.

### 9.5 Rapid Escape Presses

If the player presses Escape twice very quickly, the `_toggle_pause()` function is re-entrant. The guard `if get_tree().paused and _pause_panel != null` ensures the second press resumes immediately. No race condition is possible because Godot processes input sequentially.

---

## 10. Test Cases

| Case | Verification | Priority |
|---|---|---|
| Escape pauses the game | `get_tree().paused == true`, `_pause_panel != null` | P0 |
| Escape resumes the game | `get_tree().paused == false`, `_pause_panel == null` | P0 |
| No pause during upgrade panel | Escape when UpgradePanel visible does nothing | P0 |
| No pause during game over | Escape when is_game_over does nothing | P1 |
| Mastery panel shows 7 weapons | VBoxContainer has 7 weapon row children | P1 |
| Progress bar width correct | Fill width = 80 * (kills - lower) / (upper - lower) | P1 |
| Master row shows no denominator | Kill count label is "1023" not "1023/1000" | P2 |
| Master row has diamond indicator | "*** DIAMOND ***" label visible | P2 |
| Tier colors match badge colors | Row tier name color == MASTERY_TIER_COLORS[tier] | P1 |
| Resume button unpauses | Clicking Resume calls _toggle_pause (resume path) | P0 |
| Quit button changes scene | Clicking Quit loads main.tscn | P0 |
| Status header shows correct data | Timer/Wave/Gold/Level match GameManager values | P2 |
| Weapon order matches BASE_WEAPONS | Rows appear in knife/holywater/lightning/bible/firestaff/frostaura/boomerang order | P2 |
| Pause panel freed on resume | `_pause_panel == null` and no orphan nodes after resume | P1 |
| build_pause_panel returns Control | `build_pause_panel() is Control` == true | P1 |
| hud.gd stays under 500 lines | Line count check after integration | P0 |
| hud_mastery_panel.gd stays under 200 lines | Line count check after build_pause_panel addition | P1 |
| All 1813+ tests pass | Zero regressions | P0 |

---

## 11. Decision Record

| Decision | Why | Alternative Considered |
|---|---|---|
| Escape toggles pause (not just opens) | Industry standard. Vampire Survivors, Brotato, Holocure all use Escape for pause toggle | Separate open/close keys (adds cognitive load) |
| Mastery panel built inside hud_mastery_panel.gd | Mastery data and tier colors already live there. Keeps mastery logic cohesive | Build in hud.gd (would add 40+ lines to hud.gd, pushing toward 500 limit) |
| Tier-relative progress bar | Total kills / 1000 shows nearly empty bars for most of the game. Tier-relative shows meaningful progress at every tier | Total progress only (12/1000 = 1.2% fill -- demoralizing) |
| Status header included | When paused, players want to see "how am I doing" at a glance. Timer, wave, gold, level are the four key status metrics | Mastery section only (player would need to unpause to check timer) |
| Quit button has no keyboard shortcut | Prevents accidental quit during combat. Button click is intentional enough | KEY_Q for quit (conflicts with existing retreat key in endless mode) |
| Panel created on demand, freed on resume | No persistent overhead. Clean lifecycle | Keep panel hidden and show/hide (wastes memory when not paused) |
| No pause during upgrade panel | Upgrade panel already pauses. Showing a second overlay would be confusing and block upgrade selection | Allow pause during upgrade (overlapping overlays, UX mess) |
| MASTERY_THRESHOLDS used for progress calc | Already defined in SaveManager as [0, 50, 200, 500, 1000]. No duplication needed | Hard-code thresholds in panel (fragile, must keep in sync) |
| Diamond indicator below weapon rows | One shared label rather than per-row indicators. Cleaner for multiple Master weapons | Per-row diamond label (wastes vertical space) |

---

## 12. Implementation Checklist

### Phase 1: Extend hud_mastery_panel.gd (Programmer Agent)

- [ ] Add `build_pause_panel() -> Control` function (~45 lines)
- [ ] Add helper functions: `_build_status_header()`, `_build_weapon_row()`, `_build_action_buttons()` (~40 lines)
- [ ] Add icon color constants (Dictionary or const array, ~12 lines)
- [ ] Verify total < 200 lines

### Phase 2: Integrate pause into hud.gd (Programmer Agent)

- [ ] Add `var _pause_panel: Control = null` to member section
- [ ] Add Escape handling to `_input()` (~5 lines)
- [ ] Add `_toggle_pause()` function (~12 lines)
- [ ] Add `_on_quit_to_title()` function (~8 lines)
- [ ] Verify total < 450 lines

### Phase 3: Testing (QA Agent)

- [ ] New test file: `test/unit/test_pause_mastery_panel.gd` with 18 test cases from Section 10
- [ ] All 1813+ existing tests pass
- [ ] Target: ~60 lines of test code
