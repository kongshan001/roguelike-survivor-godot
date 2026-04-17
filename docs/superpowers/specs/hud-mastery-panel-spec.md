# HUD Mastery Panel Extraction Spec

**Author**: Designer Agent
**Date**: 2026-04-17
**Round**: R24
**Status**: Design Spec
**Priority**: P1 HIGH
**Context**: hud.gd is 463 lines (92.6% of 500-line limit). The mastery badge code (lines 23-43 constants + lines 401-462 functions) accounts for ~82 lines and can be extracted into a RefCounted module following the hud_toast.gd / hud_skill_button.gd pattern. This extraction brings hud.gd to ~405 lines, providing headroom for the pause menu integration planned in v1.0.3.

---

## 1. Design Overview

Extract the mastery badge and flash code from hud.gd into a new `scripts/hud_mastery_panel.gd` RefCounted module. This follows the established pattern where hud.gd delegates subsystem logic to lightweight RefCounted objects (hud_toast.gd for toasts, hud_skill_button.gd for skill display). The extraction covers:

1. Mastery badge constants (7 constants + 2 arrays)
2. Badge creation and management functions (3 functions)
3. Mastery flash overlay (1 function)
4. Weapon display name lookup (1 function)

The signal handler `_on_mastery_tier_up()` remains in hud.gd because it bridges SaveManager signal to two subsystems (_toast and _mastery_panel), which is orchestration logic that belongs in the coordinator.

**Why extract now**: hud.gd at 463 lines has only 37 lines of headroom. The v1.0.3 pause menu mastery panel (weapon-mastery-ui.md Section 4) will add ~30 lines to hud.gd for pause/resume handling. Without extraction, hud.gd would exceed 500 lines. Extracting 82 lines of mastery code + adding 30 lines of pause code results in hud.gd at ~411 lines -- a sustainable position.

---

## 2. Code Boundary Analysis

### 2.1 Lines to Extract from hud.gd

| Lines | Content | Destination |
|---|---|---|
| 23-26 | `_mastery_badges` dict, `_mastery_flash` state, `MASTERY_BADGE_SIZE`, `MASTERY_FILL_SIZE`, `MASTERY_FILL_OFFSET` | hud_mastery_panel.gd member vars |
| 27-43 | `MASTERY_TIER_COLORS`, `MASTERY_TIER_BORDERS`, `MASTERY_TIER_NAMES` arrays | hud_mastery_panel.gd constants |
| 402-409 | `_get_weapon_display_name()` | hud_mastery_panel.gd public function |
| 411-419 | `_on_mastery_tier_up()` | **STAYS** in hud.gd (orchestration logic) |
| 421-436 | `_show_mastery_flash()` | hud_mastery_panel.gd public function |
| 438-462 | `_ensure_mastery_badge()`, `_start_badge_pulse()` | hud_mastery_panel.gd public functions |

**Total lines extracted**: ~82 (constants 21 lines + functions 61 lines)

### 2.2 Lines Remaining in hud.gd

After extraction, `_on_mastery_tier_up()` (lines 411-419) becomes:

```gdscript
func _on_mastery_tier_up(weapon_id: String, new_tier: int) -> void:
    _mastery_panel.on_tier_up(weapon_id, new_tier)
```

This is a 2-line delegation instead of the current 9-line handler. The handler calls `_mastery_panel` which internally manages the toast, flash, and badge update.

### 2.3 What Stays in hud.gd

| Lines | Content | Reason |
|---|---|---|
| 68-69 | `SaveManager.mastery_tier_up` signal connection | Signal wiring belongs in coordinator |
| Simplified `_on_mastery_tier_up` | 2-line delegation to `_mastery_panel` | Bridges SaveManager signal to subsystem |

**Net change to hud.gd**: -82 lines (extraction) + 2 lines (new delegation) = **-80 lines**. hud.gd goes from 463 to ~383 lines.

---

## 3. hud_mastery_panel.gd Module Interface

### 3.1 Class Structure

```gdscript
extends RefCounted
# HudMasteryPanel -- Mastery badge & flash subsystem extracted from hud.gd
# Manages weapon mastery badge creation, tier-up flash, and display name lookup.

# --- Mastery Badge Constants ---
const MASTERY_BADGE_SIZE: float = 6.0
const MASTERY_FILL_SIZE: float = 4.0
const MASTERY_FILL_OFFSET: float = 1.0
const MASTERY_TIER_COLORS: Array[Color] = [
    Color.TRANSPARENT,
    Color(0.80, 0.55, 0.35),  # Bronze
    Color(0.78, 0.78, 0.82),  # Silver
    Color(0.95, 0.82, 0.30),  # Gold
    Color(1.0, 0.85, 0.30),   # Diamond
]
const MASTERY_TIER_BORDERS: Array[Color] = [
    Color.TRANSPARENT,
    Color(0.50, 0.35, 0.20),  # Deep bronze
    Color(0.50, 0.50, 0.55),  # Deep silver
    Color(0.65, 0.55, 0.15),  # Deep gold
    Color(0.75, 0.60, 0.10),  # Deep diamond
]
const MASTERY_TIER_NAMES: Array[String] = ["Novice", "Apprentice", "Adept", "Expert", "Master"]

# --- State ---
var _mastery_badges: Dictionary = {}  # weapon_id -> {border: ColorRect, fill: ColorRect}
var _mastery_flash: ColorRect = null
var _toast: RefCounted = null          # Reference to hud_toast subsystem
var _canvas_layer: CanvasLayer = null  # Weak reference to hud.gd

func _init(canvas: CanvasLayer, toast: RefCounted) -> void:
    _canvas_layer = canvas
    _toast = toast
```

### 3.2 Public API

| Function | Signature | Purpose | Caller |
|---|---|---|---|
| `on_tier_up` | `(weapon_id: String, new_tier: int) -> void` | Handle mastery tier-up: show toast, flash, update badge | hud.gd `_on_mastery_tier_up` |
| `ensure_badge` | `(weapon_id: String, slot: Control) -> void` | Create mastery badge on weapon slot if not exists | hud.gd weapon slot setup |
| `get_weapon_display_name` | `(weapon_id: String) -> String` | Lookup weapon display name for toasts | hud_mastery_panel.gd internal |

### 3.3 Private Functions

| Function | Signature | Purpose |
|---|---|---|
| `_show_mastery_flash` | `(flash_color: Color) -> void` | Create/show full-screen tier-up flash overlay |
| `_start_badge_pulse` | `(badge: ColorRect) -> void` | Start diamond-tier pulsing animation |

### 3.4 on_tier_up() Implementation

```gdscript
func on_tier_up(weapon_id: String, new_tier: int) -> void:
    var weapon_name: String = get_weapon_display_name(weapon_id)
    var tier_color: Color = MASTERY_TIER_COLORS[new_tier]
    var text: String = "%s Mastery: %s" % [weapon_name, MASTERY_TIER_NAMES[new_tier]]
    if new_tier == 4:
        text += " +8% DMG"
    _toast.show_toast(text, tier_color)
    if new_tier >= 3:
        _show_mastery_flash(tier_color)
    # Update badge if one exists for this weapon
    if _mastery_badges.has(weapon_id):
        _update_badge_tier(weapon_id, new_tier)
```

This replaces the current hud.gd `_on_mastery_tier_up` (lines 411-419) and adds badge update logic that was missing from the original implementation.

---

## 4. hud.gd Integration Changes

### 4.1 Member Variable Changes

**Remove** (extracted to hud_mastery_panel.gd):
```gdscript
# REMOVE these from hud.gd:
var _mastery_badges: Dictionary = {}
var _mastery_flash: ColorRect = null
const MASTERY_BADGE_SIZE: float = 6.0
const MASTERY_FILL_SIZE: float = 4.0
const MASTERY_FILL_OFFSET: float = 1.0
const MASTERY_TIER_COLORS: Array[Color] = [...]
const MASTERY_TIER_BORDERS: Array[Color] = [...]
const MASTERY_TIER_NAMES: Array[String] = [...]
```

**Add** (new subsystem reference):
```gdscript
# ADD this to hud.gd member variables section:
var _mastery_panel: RefCounted = null
```

### 4.2 _ready() Changes

**Add** after `_toast` setup (after line 91):
```gdscript
_mastery_panel = load("res://scripts/hud_mastery_panel.gd").new(self, _toast)
```

### 4.3 _on_mastery_tier_up() Replacement

**Old** (9 lines in hud.gd):
```gdscript
func _on_mastery_tier_up(weapon_id: String, new_tier: int) -> void:
    var weapon_name: String = _get_weapon_display_name(weapon_id)
    var tier_color: Color = MASTERY_TIER_COLORS[new_tier]
    var text: String = "%s Mastery: %s" % [weapon_name, MASTERY_TIER_NAMES[new_tier]]
    if new_tier == 4:
        text += " +8% DMG"
    _toast.show_toast(text, tier_color)
    if new_tier >= 3:
        _show_mastery_flash(tier_color)
```

**New** (2 lines in hud.gd):
```gdscript
func _on_mastery_tier_up(weapon_id: String, new_tier: int) -> void:
    _mastery_panel.on_tier_up(weapon_id, new_tier)
```

### 4.4 Functions Removed from hud.gd

| Function | Lines | Reason |
|---|---|---|
| `_get_weapon_display_name()` | 402-409 | Moved to hud_mastery_panel.gd |
| `_show_mastery_flash()` | 421-436 | Moved to hud_mastery_panel.gd |
| `_ensure_mastery_badge()` | 438-456 | Moved to hud_mastery_panel.gd |
| `_start_badge_pulse()` | 458-462 | Moved to hud_mastery_panel.gd |

---

## 5. Line Count Budget

### 5.1 hud.gd Before and After

| Metric | Before | After Extraction | After Pause Menu (v1.0.3) |
|---|---|---|---|
| hud.gd total lines | 463 | ~383 | ~413 |
| Headroom (500 limit) | 37 lines | 117 lines | 87 lines |

### 5.2 New File

| File | Lines | Type |
|---|---|---|
| `scripts/hud_mastery_panel.gd` | ~95 | RefCounted (like hud_toast.gd's 116 lines) |

### 5.3 Total Project Line Count

| Metric | Before | After |
|---|---|---|
| Total lines changed | -- | ~95 new (hud_mastery_panel.gd) - 80 removed (hud.gd) = +15 net |
| Files changed | -- | 2 (hud.gd modified, hud_mastery_panel.gd new) |

---

## 6. Pause Menu Extension Point

### 6.1 Future Pause Integration

When the pause menu is implemented (v1.0.3, per weapon-mastery-ui.md Section 4), hud_mastery_panel.gd gains a new public function:

```gdscript
func build_pause_panel() -> Control:
    # Returns a Control containing the mastery section
    # for insertion into the pause overlay
    # ~40 lines of VBoxContainer/HBoxContainer construction
    pass
```

This function reads data directly from `SaveManager.weapon_kills` and `SaveManager.get_weapon_mastery_tier()`. The pause panel design is already specified in `weapon-mastery-ui.md` Section 4.2-4.3.

### 6.2 hud.gd Pause Handling (v1.0.3 Future)

```gdscript
# In hud.gd (future v1.0.3 implementation):
func _on_pause_toggled() -> void:
    var paused: bool = get_tree().paused
    if paused:
        _pause_panel = _mastery_panel.build_pause_panel()
        add_child(_pause_panel)
    else:
        if _pause_panel:
            _pause_panel.queue_free()
            _pause_panel = null
```

This adds ~10 lines to hud.gd. Combined with the extraction, hud.gd would be at ~393 lines -- well within limits.

---

## 7. Test Cases

| Case | Verification | Priority |
|---|---|---|
| Mastery badge created for tier 1+ weapon | `ensure_badge()` creates ColorRect child with correct tier color | P1 |
| No badge for tier 0 (Novice) | `ensure_badge()` creates badge but sets `visible = false` | P1 |
| Diamond badge pulses | `_start_badge_pulse()` creates looping tween on alpha | P1 |
| Tier-up toast shows correct text | `on_tier_up()` calls `_toast.show_toast()` with expected name+tier | P0 |
| Tier 3+ triggers screen flash | `on_tier_up()` with tier >= 3 calls `_show_mastery_flash()` | P1 |
| Tier 4 toast includes "+8% DMG" | `on_tier_up()` with tier 4 appends bonus text | P1 |
| Flash auto-hides after 0.4s | `_show_mastery_flash()` tween fades alpha to 0 and sets visible false | P2 |
| Weapon display name lookup | `get_weapon_display_name()` returns correct name for all 7 base weapons | P2 |
| Unknown weapon ID returns raw ID | `get_weapon_display_name("unknown")` returns "unknown" | P2 |
| hud.gd line count stays under 400 after extraction | Verify hud.gd < 400 lines | P0 |
| hud_mastery_panel.gd line count stays under 120 | Verify new file < 120 lines | P1 |
| Existing 1700 tests pass | Zero regressions after extraction | P0 |

---

## 8. Decision Record

| Decision | Why | Alternative Considered |
|---|---|---|
| Extract mastery code now (not later) | hud.gd at 463 lines has only 37 lines of headroom. Pause menu needs ~30 lines. Extraction before addition prevents a 500-line crisis | Delay extraction until pause menu is needed (would hit limit mid-feature) |
| RefCounted module (not Node) | Follows hud_toast.gd / hud_skill_button.gd pattern. No scene tree lifecycle needed. Lighter weight | Node-based module (unnecessary lifecycle overhead, would need add_child) |
| `on_tier_up()` includes badge update | The original hud.gd implementation was missing badge update on tier-up (badge was only created, never updated). This extraction fixes the gap | Keep badge update as separate hud.gd call (splits the tier-up logic across files) |
| Constants move to hud_mastery_panel.gd | All mastery-related constants travel with the module. hud.gd should have zero mastery-specific knowledge | Leave constants in hud.gd and pass them to module (fragile, defeats extraction purpose) |
| Signal handler stays in hud.gd | `_on_mastery_tier_up` is the bridge between SaveManager signal and the mastery subsystem. This orchestration belongs in the coordinator | Move signal connection into module (module would need SaveManager reference, creates coupling) |
| `_toast` passed via constructor | The mastery panel needs toast for tier-up notifications. Passing it avoids module loading hud_toast.gd independently | Module creates its own toast (redundant toast system, inconsistent) |

---

## 9. Implementation Checklist

### Phase 1: Create hud_mastery_panel.gd (Programmer Agent)

- [ ] Create `scripts/hud_mastery_panel.gd` with class structure from Section 3
- [ ] Implement `on_tier_up()`, `ensure_badge()`, `get_weapon_display_name()`, `_show_mastery_flash()`, `_start_badge_pulse()`
- [ ] Target: ~95 lines

### Phase 2: Modify hud.gd (Programmer Agent)

- [ ] Remove extracted constants (lines 23-43) and functions (lines 402-462)
- [ ] Add `var _mastery_panel: RefCounted = null` to member section
- [ ] Add `_mastery_panel = load(...).new(self, _toast)` to `_ready()` after toast setup
- [ ] Replace `_on_mastery_tier_up` body with 2-line delegation
- [ ] Verify line count < 400

### Phase 3: Testing (QA Agent)

- [ ] All 1700 existing tests pass
- [ ] New test file: `test/unit/test_hud_mastery_panel.gd` with 12 test cases from Section 7
- [ ] Target: ~50 lines of test code
