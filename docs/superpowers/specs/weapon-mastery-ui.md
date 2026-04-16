# Weapon Mastery UI Design

**Author**: Designer Agent
**Date**: 2026-04-17
**Round**: R20
**Status**: Design Spec
**Context**: R19 designed the weapon mastery system (7 weapons x 4 tiers, kill-tracking, damage bonuses). This spec defines how mastery is displayed to the player across HUD, toast notifications, and pause menu. Must integrate with existing hud.gd (410 lines) without exceeding the 500-line file limit.

---

## 1. Design Overview

Weapon mastery UI has three display surfaces:

1. **HUD Weapon Slot Badges** -- minimal per-weapon tier indicator visible during gameplay
2. **Mastery Level-Up Toast** -- notification when a weapon reaches a new mastery tier
3. **Pause Menu Mastery Panel** -- detailed mastery progress view when the game is paused

The shop screen mastery display (Section 8.1 of weapon-mastery.md) is already designed and not duplicated here.

---

## 2. HUD Weapon Slot Badges

### 2.1 Badge Position

Each weapon slot in the HUD shows a small tier indicator at the bottom-right corner of the slot icon.

**Current HUD layout** (from hud.tscn):
- HealthBar: top-left (20, 20) to (220, 36)
- XPBar: top-left (20, 60) to (220, 72)
- GoldLabel: top-left (20, 96) to (220, 112)
- TimerLabel: top-right (1100, 20) to (1260, 40)
- WaveLabel: top-right (1100, 88) to (1260, 108)

**Weapon slots are not yet implemented in the HUD**. When they are added (per H5 HUD_WEAPONS spec), mastery badges attach to each slot.

**Badge dimensions**:

| Property | Value | Rationale |
|---|---|---|
| Badge size | 6x6 px | Small enough not to obscure the weapon icon (32x32 slot) |
| Position | Bottom-right of slot, offset (-7, -7) | Sits in the corner, partially overlapping the slot border |
| Shape | Filled circle (ColorRect with rounded corner simulation) | In pixel art style, a 2x2 or 3x3 solid ColorRect suffices |

### 2.2 Badge Colors by Tier

| Tier | Badge Color | Godot Color | Visual |
|---|---|---|---|
| 0 (Novice) | None (badge hidden) | -- | No badge for unranked weapons |
| 1 (Apprentice) | Bronze | Color(0.8, 0.5, 0.2) | Small bronze dot |
| 2 (Adept) | Silver | Color(0.75, 0.75, 0.78) | Small silver dot |
| 3 (Expert) | Gold | Color(1.0, 0.84, 0.0) | Small gold dot |
| 4 (Master) | Diamond + pulse | Color(0.73, 0.95, 1.0) | Diamond dot with 1.5s alpha pulse animation |

**Color source**: Tier badge colors match the weapon-mastery.md spec Section 2.1 (Gray/Bronze/Silver/Gold/Diamond).

**Master pulse animation**:
```
t=0.0s: alpha = 0.6
t=0.75s: alpha = 1.0
t=1.5s: alpha = 0.6 (loop)
```

### 2.3 Implementation Notes

- Badge is a ColorRect child of each weapon slot Control
- Badge visibility updates when: (a) weapon is added to inventory, (b) mastery tier changes
- Badge reads tier from `SaveManager.get_weapon_mastery_tier(weapon_id)`
- Since mastery is persistent and rarely changes in-run, badge only needs to update at weapon pickup and at mastery level-up

---

## 3. Mastery Level-Up Toast

### 3.1 Trigger Condition

When `SaveManager.add_weapon_kill()` detects a tier threshold crossing (kills >= threshold for next tier), it emits a signal:

```gdscript
# In save_manager.gd (pseudocode for design reference only)
signal mastery_tier_up(weapon_id: String, new_tier: int)

func add_weapon_kill(weapon_id: String) -> void:
    var old_tier: int = get_weapon_mastery_tier(weapon_id)
    weapon_kills[weapon_id] = weapon_kills.get(weapon_id, 0) + 1
    var new_tier: int = get_weapon_mastery_tier(weapon_id)
    if new_tier > old_tier:
        mastery_tier_up.emit(weapon_id, new_tier)
```

### 3.2 Toast Design

When the signal fires, the HUD displays a special mastery toast via the existing `_toast` system (hud_toast.gd).

**Toast content**:

| Tier | Toast Text | Toast Color |
|---|---|---|
| 1 (Apprentice) | "Knife Mastery: Apprentice!" | Color(0.8, 0.5, 0.2) (bronze) |
| 2 (Adept) | "Knife Mastery: Adept!" | Color(0.75, 0.75, 0.78) (silver) |
| 3 (Expert) | "Knife Mastery: Expert!" | Color(1.0, 0.84, 0.0) (gold) |
| 4 (Master) | "Knife Mastery: MASTER!" | Color(0.73, 0.95, 1.0) (diamond) |

**Master tier toast enhancement**: When reaching Master (tier 4), the toast additionally:
- Uses `font_size = 15` (standard is 13)
- Adds a "+" bonus text: "Knife Mastery: MASTER! +8% DMG"
- Stays visible for 3.0 seconds (standard is 2.0)

### 3.3 Mastery Tier-Up Screen Effect

For tier 3 (Expert) and tier 4 (Master), a brief screen-wide visual flash reinforces the achievement:

| Tier | Screen Effect | Duration |
|---|---|---|
| 1-2 | None (toast only) | -- |
| 3 (Expert) | Brief golden border glow on the weapon slot | 0.5s |
| 4 (Master) | Screen-wide diamond flash (light blue overlay, alpha 0.15 -> 0.0) | 0.4s |

**Screen flash implementation**:
```gdscript
# In hud.gd (pseudocode)
var _mastery_flash: ColorRect = null  # lazy-created full-screen overlay

func _on_mastery_tier_up(weapon_id: String, new_tier: int) -> void:
    var weapon_name: String = _get_weapon_display_name(weapon_id)
    var tier_names: Array = ["", "Apprentice", "Adept", "Expert", "MASTER"]
    var tier_colors: Array = [Color.WHITE, Color(0.8,0.5,0.2), Color(0.75,0.75,0.78), Color(1.0,0.84,0.0), Color(0.73,0.95,1.0)]
    var text: String = "%s Mastery: %s" % [weapon_name, tier_names[new_tier]]
    if new_tier == 4:
        text += " +8%% DMG"
    _toast.show_toast(text, tier_colors[new_tier])

    # Screen flash for tier 3+
    if new_tier >= 3:
        _show_mastery_flash(tier_colors[new_tier])
```

---

## 4. Pause Menu Mastery Panel

### 4.1 Panel Trigger

When the player presses Escape (or the pause button), the game pauses and shows a pause overlay. The mastery panel is a section within this overlay.

**Current pause state**: The game pauses during the upgrade panel (UpgradePanel.visible = true) but there is no dedicated pause menu. The mastery panel is designed for the future pause menu, which should be implemented as part of the HUD polish effort.

### 4.2 Panel Layout

```
+==================================+
|           PAUSED                  |
|                                   |
|  Timer: 03:42   Wave: 3/5        |
|  Gold: 47       Level: 7         |
|                                   |
|  --- WEAPON MASTERY ---          |
|                                   |
|  [Knife]     Apprentice  52/200  |
|              [=-------] +2% DMG  |
|                                   |
|  [HolyWater] Adept       204/500 |
|              [====----] +4% DMG  |
|                                   |
|  [Lightning] Expert      623/1000|
|              [======--] +6% DMG  |
|                                   |
|  [Bible]     Novice       12/50  |
|              [==------] +0% DMG  |
|                                   |
|  [FireStaff] Adept       312/500 |
|              [=====---] +4% DMG  |
|                                   |
|  [FrostAura] Novice       38/50  |
|              [========] +0% DMG  |
|              (almost there!)      |
|                                   |
|  [Boomerang] Master      1023    |
|              [========] +8% DMG  |
|              *** DIAMOND ***      |
|                                   |
|  [Resume]          [Quit]         |
+==================================+
```

### 4.3 Panel Element Specifications

**Section header**: "--- WEAPON MASTERY ---"
- Font size: 14px
- Color: Color(1.0, 0.84, 0.0) (gold)
- Horizontal alignment: center

**Each weapon row** (7 rows, VBoxContainer):
- Height: 36px per weapon (7 weapons = 252px total)
- Weapon icon: 12x12 ColorRect, weapon's primary color
- Weapon name: 12px font, white
- Tier name: 12px font, tier color (bronze/silver/gold/diamond)
- Kill progress: "current/next_threshold" or "1000" for Master
- Progress bar: 80px wide, 4px tall ColorRect
  - Background: Color(0.15, 0.15, 0.2) (dark)
  - Fill: tier color at alpha 0.8
  - Master (complete): full bar with diamond pulse
- Bonus text: "+X% DMG", tier color

**Progress bar fill calculation**:
```
fill_ratio = clamp(current_kills / next_threshold, 0.0, 1.0)
bar_width = 80.0 * fill_ratio
```

**Master row special treatment**:
- Kill count shows as "1000" (no "/1000" suffix)
- Progress bar is full and has a subtle 2px outer glow (ColorRect at 84x6, alpha 0.3, diamond color)
- Text "*** DIAMOND ***" below the row in diamond color, 10px font

### 4.4 Panel Dimensions

| Property | Value |
|---|---|
| Panel width | 300px |
| Panel height | 420px (header 60px + 7 weapons x 36px + footer 108px) |
| Position | Center of viewport |
| Background | Color(0.05, 0.05, 0.1, 0.9) (semi-transparent dark) |
| Border | 2px, Color(1.0, 0.84, 0.0) (gold) |

---

## 5. Integration with Existing HUD

### 5.1 hud.gd Code Budget

Current hud.gd is 410 lines. The mastery UI additions should not push it past 500 lines. Recommended implementation strategy:

**New file**: `scripts/hud_mastery_panel.gd` (RefCounted, similar to hud_toast.gd and hud_skill_button.gd)
- Contains mastery panel creation and update logic
- ~80 lines

**Changes to hud.gd**:
- Connect `SaveManager.mastery_tier_up` signal in `_ready()`: +2 lines
- Add `_on_mastery_tier_up()` handler: +10 lines
- Lazy-create mastery flash overlay: +15 lines
- Total: ~27 lines added, bringing hud.gd to ~437 lines (within 500 limit)

### 5.2 Signal Flow

```
SaveManager.add_weapon_kill()
  -> detects tier up
  -> emits mastery_tier_up(weapon_id, new_tier)
  -> hud.gd receives signal
  -> _toast.show_toast() for notification
  -> _show_mastery_flash() for tier 3+ screen effect
  -> (future) update weapon slot badge
```

### 5.3 Mastery Panel on Pause

The pause menu itself needs implementation (currently no dedicated pause screen). The mastery panel is designed as a child of the future pause overlay. When implemented:

1. Pressing Escape sets `get_tree().paused = true` and shows a `PausePanel` node
2. `PausePanel` contains resume/quit buttons and a `MasterySection`
3. `MasterySection` is built by `hud_mastery_panel.gd`
4. Data reads directly from `SaveManager.weapon_kills` and `SaveManager.get_weapon_mastery_tier()`

### 5.4 Performance Considerations

- Mastery panel is created on demand (when pause menu opens), not in `_ready()`
- Panel is freed when pause menu closes
- Badge updates are event-driven (only on tier change), not per-frame
- Toast uses the existing toast queue system (max 2 visible, stagger 0.5s)
- Screen flash is a single ColorRect with Tween, auto-freed after 0.4s

---

## 6. Weapon Display Names

For toast notifications and the mastery panel, each weapon needs a display-friendly name. These should match the upgrade_pool.gd weapon names:

| weapon_id | Display Name | Icon Color |
|---|---|---|
| knife | Knife | Color(0.75, 0.75, 0.8) silver |
| holywater | Holy Water | Color(0.3, 0.5, 1.0) blue |
| lightning | Lightning | Color(1.0, 1.0, 0.3) yellow |
| bible | Bible | Color(0.9, 0.85, 0.7) cream |
| firestaff | Fire Staff | Color(1.0, 0.4, 0.1) orange |
| frostaura | Frost Aura | Color(0.5, 0.8, 1.0) ice blue |
| boomerang | Boomerang | Color(0.6, 0.4, 0.2) brown |

---

## 7. Implementation Scope

### 7.1 File Changes

| File | Change | Lines |
|---|---|---|
| `scripts/autoload/save_manager.gd` | Add `mastery_tier_up` signal, emit in `add_weapon_kill()` | ~8 |
| `scripts/hud.gd` | Connect signal, add handler, mastery flash | ~27 |
| `scripts/hud_mastery_panel.gd` | New file: pause menu mastery panel builder | ~80 |
| **Total** | | **~115** |

### 7.2 Dependency on Other Systems

| Dependency | Status | Impact |
|---|---|---|
| Weapon mastery backend (SaveManager) | Designed in R19, not yet implemented | Mastery UI requires backend |
| HUD weapon slots | Not yet implemented | Badges attach to slots |
| Pause menu | Not yet implemented | Mastery panel lives in pause menu |
| Toast system (hud_toast.gd) | Implemented and working | Mastery toasts use existing system |

**Recommendation**: Implement mastery backend first (R19 spec), then mastery UI badges alongside weapon slots, and mastery panel alongside pause menu. The toast notification can be implemented independently as soon as the backend is ready.

---

## 8. Decision Record

| Decision | Why | Alternative Considered |
|---|---|---|
| Badge in bottom-right of weapon slot | Most natural position for a status indicator, does not interfere with weapon icon | Top-right (conflicts with level indicator) |
| No badge for Novice (tier 0) | Novice means "no mastery earned", showing a gray badge would add visual noise for no information | Gray badge (adds clutter for 7 identical gray dots) |
| Tier-up toast uses existing toast system | Consistent look and feel, no new UI infrastructure needed | Dedicated mastery popup (more visual weight but inconsistent with other notifications) |
| Screen flash only for tier 3+ | Lower tiers are frequent (50 kills, 200 kills), flash would be annoying if triggered too often. Expert (500) and Master (1000) are rare enough to warrant celebration | Flash for all tiers (too frequent, diminishes impact) |
| Mastery panel in separate file | hud.gd is at 410 lines, adding 80+ lines for panel logic would exceed 500-line limit | Inline in hud.gd (file too long) |
| Panel reads data directly from SaveManager | Mastery data is persistent and does not change during a paused run. No caching needed | Cache data on panel open (unnecessary complexity) |
| Master row shows "1000" not "1000/1000" | Master is the maximum tier. Showing "/1000" implies there is more to progress. "1000" with a full bar communicates completion clearly | "1000/1000" (redundant, implies further progress possible) |

---

## 9. Success Criteria

1. Each weapon slot displays a tier-colored badge (bronze/silver/gold/diamond) when the player owns that weapon
2. Novice weapons show no badge
3. Toast notification fires when any weapon crosses a mastery threshold
4. Master tier toast includes "+8% DMG" text and stays visible for 3 seconds
5. Expert and Master tier-ups trigger a brief screen flash
6. Pause menu shows all 7 weapons with name, tier, progress bar, and bonus
7. Master weapons have diamond pulse animation and "*** DIAMOND ***" label
8. hud.gd remains under 500 lines after all changes
9. All existing tests pass
