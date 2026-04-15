# Achievement/Quest UI Display Design Spec

**Author**: Designer Agent
**Date**: 2026-04-16
**Priority**: P1 HIGH
**Status**: Design Complete
**Backend Reference**: `scripts/autoload/save_manager.gd` (14 quests, 27 achievements, fully functional)

---

## 1. Design Overview

The quest and achievement system backend is fully implemented in `save_manager.gd` -- 14 quests and 27 achievements with detection, reward distribution, and persistence. However, players currently have zero visibility into this system: no in-game notifications, no menu pages, no game-over summary. This spec defines three UI layers to surface quest/achievement content: (1) real-time HUD toast notifications during gameplay, (2) a main menu quest/achievement listing page, and (3) a game-over summary of run-specific completions.

**Why this design**: Quest and achievement visibility is the single highest-impact UX improvement for retention. In Vampire Survivors, the achievement popup is a core dopamine loop. In Brotato, the quest list drives players to try new strategies. Our backend is complete -- adding the display layer is high value, low implementation risk.

---

## 2. Backend Inventory (For Reference)

### 2.1 Quests (14 total) -- `SaveManager.QUESTS`

| ID | Name | Description | Reward |
|---|---|---|---|
| warrior_30 | Warrior's Path | Kill 30 enemies as Warrior | 50 |
| ranger_30 | Precision | Kill 30 enemies as Ranger | 50 |
| hard_survive | Fearless | Survive 2 min on Hard | 100 |
| hard_boss | Hard Conqueror | Kill Boss on Hard | 200 |
| kill_50 | Slayer | Kill 50 enemies in one run | 75 |
| kill_100 | Century | Kill 100 enemies in one run | 150 |
| kill_boss | Dragon Slayer | Kill a Boss | 100 |
| no_damage | Perfect Dodge | No damage for 1 minute | 120 |
| combo_20 | Combo Master | Reach 20 combo | 100 |
| combo_50 | Combo King | Reach 50 combo | 200 |
| endless_5min | Endless Journey | Survive 5 min Endless | 150 |
| endless_10min | Immortal Legend | Survive 10 min Endless | 300 |
| endless_boss3 | Triple Dragon | Kill 3 Bosses Endless | 400 |
| endless_kill200 | Endless Slayer | Kill 200 Endless | 250 |

### 2.2 Achievements (27 total) -- `SaveManager.ACHIEVEMENTS`

| Category | Count | Example IDs |
|---|---|---|
| Milestone | 5 | total_kills_100, total_kills_500, total_kills_2000, games_10, games_50 |
| Survival | 3 | survive_3min, survive_5min, survive_hard_5min |
| Character | 1 | all_chars |
| Kill/Challenge | 8 | boss_kill, hard_boss_kill, no_damage_survive, kill_100_single, ... |
| Evolution/Synergy | 4 | evolve_weapon, synergy_first, all_evolved, all_synergies |
| Shop | 3 | shop_first, shop_single_max, shop_max_all |
| Quest | 2 | quests_half, quests_all |
| Hidden | 2 | fast_boss, pacifist_1min |

### 2.3 Available Signals (Already Implemented)

```gdscript
# In save_manager.gd:
signal soul_fragments_changed(amount: int)
signal achievement_unlocked(achievement_id: String)
signal quest_completed(quest_id: String)
```

These signals are emitted when a quest/achievement is first completed. They are currently connected to nothing in the game scene.

---

## 3. Layer 1: HUD Toast Notifications

### 3.1 Overview

Real-time notifications that appear in the top-right corner of the HUD when a quest or achievement is completed during gameplay. Maximum 2 visible at once, auto-dismiss after 2 seconds.

### 3.2 Wireframe

```
+--------------------------------------------------+--
| Timer: 03:42              [Quest Complete!]      |  <- top-right
| HP: 8/12                  Kill Boss              |     toast area
| Lv 5                      Reward: 100 Soul       |
| XP: [======--]                                   |
| Gold: 45                  [Achievement Unlocked!]|
| Combo: 12                 Dragon Slayer          |
|                           Reward: 50 Soul        |
+--------------------------------------------------+--
|                                                   |
|              (gameplay area)                      |
|                                                   |
+--------------------------------------------------+--
|                                                   |
```

### 3.3 Toast Specification

| Property | Value | Notes |
|---|---|---|
| Position | Top-right corner, 10px margin | Anchored to viewport top-right |
| Size | 220px wide, auto-height | Fits "Achievement Unlocked! Reward: XXXX Soul" |
| Max visible | 2 | Older toasts slide up and fade |
| Duration | 2.0 seconds | Then fade out over 0.3s |
| Animation | Slide in from right (0.2s), slide out right (0.3s) | Tween |
| Background | Semi-transparent dark panel `Color(0, 0, 0, 0.7)` | Rounded corners |
| Quest icon | Yellow border `#ffd54f` | Distinguish from achievements |
| Achievement icon | Purple border `#ce93d8` | Distinguish from quests |

### 3.4 Toast Content Layout

```
+--------------------------------------+
| [Icon]  Quest Complete!              |
|         Kill Boss                    |
|         Reward: 100 Soul             |
+--------------------------------------+

+--------------------------------------+
| [Icon]  Achievement Unlocked!        |
|         Dragon Slayer                |
|         Reward: 50 Soul              |
+--------------------------------------+
```

### 3.5 Node Structure (Add to hud.tscn)

```
HUD (CanvasLayer)
  +-- ... (existing nodes)
  +-- ToastContainer (VBoxContainer)  [NEW]
        anchor_left = 1.0, anchor_right = 1.0
        offset_left = -230, offset_right = -10
        offset_top = 10
        size_flags_horizontal = SIZE_SHRINK_END
        +-- Toast1 (PanelContainer)  [reusable, pooled]
        +-- Toast2 (PanelContainer)  [reusable, pooled]
```

### 3.6 Connection Logic

```gdscript
# In hud.gd _ready():
SaveManager.quest_completed.connect(_on_quest_completed)
SaveManager.achievement_unlocked.connect(_on_achievement_unlocked)

func _on_quest_completed(quest_id: String):
    var quest: Dictionary = _find_quest_by_id(quest_id)
    _show_toast("Quest Complete!", quest.name, quest.reward, Color(1.0, 0.84, 0.0))

func _on_achievement_unlocked(achievement_id: String):
    var ach: Dictionary = _find_achievement_by_id(achievement_id)
    _show_toast("Achievement!", ach.name, ach.reward, Color(0.81, 0.58, 0.85))

func _show_toast(title: String, name: String, reward: int, border_color: Color):
    # Get next available toast slot (or oldest)
    # Set labels: title, name, "Reward: %d Soul" % reward
    # Set border color
    # Play slide-in tween
    # Schedule auto-dismiss after 2.0s
```

### 3.7 Edge Cases

| Case | Handling |
|---|---|
| Multiple completions at once (game end) | Queue toasts, show max 2 at a time with 0.5s stagger |
| Game paused (upgrade panel) | Toasts still visible but don't animate until unpaused |
| Same quest completed twice | Signal only fires once per quest (save_manager prevents re-trigger) |
| SaveManager null (testing) | Guard with `if SaveManager:` check |

---

## 4. Layer 2: Main Menu Quest/Achievement Page

### 4.1 Overview

A new scene accessible from the main menu that shows all quests and achievements with their completion status, descriptions, and rewards.

### 4.2 Main Menu Changes

Add two new buttons to `main.tscn` between "Shop" and "Controls Hint":

```
+------------------------------------------+
|                                          |
|           Survivor Arena                 |
|                                          |
|          [Start Game]                    |
|          [Shop]                          |
|          [Quests]    <-- NEW             |
|          [Achievements]  <-- NEW         |
|       Soul Fragments: 150               |
|          WASD to move                    |
+------------------------------------------+
```

### 4.3 Quest List Page Wireframe

```
scenes/quest_list.tscn

+--------------------------------------------------+
|  < Back              Quests (7/14)               |
|                                                   |
|  +----------------------------------------------+|
|  | [x] Warrior's Path    Kill 30 as Warrior  50 ||
|  +----------------------------------------------+|
|  | [x] Precision         Kill 30 as Ranger   50 ||
|  +----------------------------------------------+|
|  | [ ] Fearless          Survive 2min Hard   100 ||
|  +----------------------------------------------+|
|  | [ ] Hard Conqueror    Kill Boss Hard      200 ||
|  +----------------------------------------------+|
|  | [x] Slayer            Kill 50 in one run   75 ||
|  +----------------------------------------------+|
|  | ... (scrollable)                              ||
|  +----------------------------------------------+|
|                                                   |
|  Completed: 7/14    Soul Earned: 525             |
+--------------------------------------------------+

[x] = completed (green check)
[ ] = not completed (gray box)
```

### 4.4 Achievement List Page Wireframe

```
scenes/achievement_list.tscn

+--------------------------------------------------+
|  < Back           Achievements (12/27)           |
|                                                   |
|  --- Milestone ---                                |
|  +----------------------------------------------+|
|  | [x] First Blood    100 kills total    30     ||
|  +----------------------------------------------+|
|  | [ ] Killing Spree  500 kills total    80     ||
|  +----------------------------------------------+|
|  | [ ] ???            ???                ???    ||  <- hidden
|  +----------------------------------------------+|
|                                                   |
|  --- Survival ---                                 |
|  +----------------------------------------------+|
|  | [x] Standing Firm  Survive 3min       30     ||
|  +----------------------------------------------+|
|  | ...                                          ||
|  +----------------------------------------------+|
|                                                   |
|  Completed: 12/27    Soul Earned: 780            |
+--------------------------------------------------+

Hidden achievements show "???" when not unlocked
```

### 4.5 List Item Specification

| Property | Quest Item | Achievement Item |
|---|---|---|
| Height | 40px | 40px |
| Width | Full container width - padding | Full container width - padding |
| Status icon | `[x]` green `#66bb6a` / `[ ]` gray `#757575` | Same |
| Name | Left-aligned, bold | Left-aligned, bold |
| Description | Center, normal weight | Center, normal weight |
| Reward | Right-aligned, gold `#ffd54f` | Right-aligned, gold `#ffd54f` |
| Background (completed) | `Color(0.15, 0.25, 0.15, 0.8)` | `Color(0.15, 0.15, 0.25, 0.8)` |
| Background (incomplete) | `Color(0.2, 0.2, 0.2, 0.5)` | `Color(0.2, 0.2, 0.2, 0.5)` |
| Hidden items | N/A (quests are never hidden) | Show "???" for name, desc, reward |

### 4.6 Achievement Categories (Section Headers)

| Category | Label | Count |
|---|---|---|
| Milestone | "--- Milestone ---" | 5 |
| Survival | "--- Survival ---" | 3 |
| Character | "--- Character ---" | 1 |
| Challenge | "--- Challenge ---" | 8 |
| Evolution | "--- Evolution/Synergy ---" | 4 |
| Shop | "--- Shop ---" | 3 |
| Quest | "--- Quest ---" | 2 |
| Hidden | "--- ???" (only show if any unlocked) | 2 |

### 4.7 Scene Structure

```
quest_list.tscn (Control, full screen)
  +-- Background (ColorRect, #1a1a2e)
  +-- Header (HBoxContainer)
  |     +-- BackButton (Button, "< Back")
  |     +-- TitleLabel (Label, "Quests (7/14)")
  +-- ScrollContainer
  |     +-- VBoxContainer
  |           +-- QuestItem1 (PanelContainer)
  |           |     +-- HBoxContainer
  |           |           +-- StatusLabel (Label, "[x]")
  |           |           +-- NameLabel (Label, "Warrior's Path")
  |           |           +-- DescLabel (Label, "Kill 30 as Warrior")
  |           |           +-- RewardLabel (Label, "50")
  |           +-- QuestItem2 ...
  +-- Footer (HBoxContainer)
        +-- CompletedLabel (Label, "Completed: 7/14")
        +-- SoulLabel (Label, "Soul Earned: 525")

achievement_list.tscn (same structure, with category headers)
```

### 4.8 Data Population

```gdscript
# In quest_list.gd _ready():
var completed_count: int = 0
var total_soul: int = 0
for quest: Dictionary in SaveManager.QUESTS:
    var is_done: bool = SaveManager.completed_quests.get(quest.id, false)
    if is_done:
        completed_count += 1
        total_soul += quest.reward
    _create_quest_item(quest, is_done)
FooterLabel.text = "Completed: %d/%d    Soul Earned: %d" % [completed_count, SaveManager.QUESTS.size(), total_soul]
```

### 4.9 Navigation Flow

```
main.tscn
  |
  +-- "Quests" button -> change_scene("res://scenes/quest_list.tscn")
  |     quest_list.tscn
  |       "< Back" -> change_scene("res://scenes/main.tscn")
  |
  +-- "Achievements" button -> change_scene("res://scenes/achievement_list.tscn")
        achievement_list.tscn
          "< Back" -> change_scene("res://scenes/main.tscn")
```

---

## 5. Layer 3: Game Over Summary

### 5.1 Overview

After each run, the game over screen shows which quests and achievements were completed during that specific run. This provides immediate positive feedback and encourages "one more run."

### 5.2 Wireframe

```
scenes/game_over_screen.tscn (expanded)

+--------------------------------------------------+
|  GAME OVER                                        |
|                                                   |
|  Time: 03:42                                      |
|  Enemies Killed: 87                               |
|  Level: 8                                         |
|  Score: 1450                                      |
|  Gold: 145 -> Soul Fragments: 65                  |
|                                                   |
|  --- This Run ---                                 |
|  Quests Completed: 2                              |
|    [x] Kill Boss           +100 Soul             |
|    [x] Combo Master        +100 Soul             |
|                                                   |
|  Achievements Unlocked: 1                         |
|    [x] Boss Hunter         +50 Soul              |
|                                                   |
|  [Restart]          [Menu]                        |
+--------------------------------------------------+
```

### 5.3 Specification

| Element | Font Size | Color | Notes |
|---|---|---|---|
| Section header "--- This Run ---" | 14px | `#ffd54f` (gold) | Only shown if any quests/achievements completed |
| Quest item line | 12px | `#66bb6a` (green) | "[x] QuestName    +XX Soul" |
| Achievement item line | 12px | `#ce93d8` (purple) | "[x] AchName    +XX Soul" |
| "No new completions" | 12px | `#757575` (gray) | Shown if nothing completed this run |
| Max items shown | 5 | | If more, show "... and X more" |

### 5.4 Tracking Run-Specific Completions

```gdscript
# In hud.gd or game_over_screen.gd:
var _run_quests: Array[String] = []
var _run_achievements: Array[String] = []

# Connect to signals at game start
func _on_quest_completed(quest_id: String):
    _run_quests.append(quest_id)

func _on_achievement_unlocked(achievement_id: String):
    _run_achievements.append(achievement_id)

# Pass to game_over_screen via GameManager meta
func _on_player_died():
    GameManager.set_meta("run_quests", _run_quests)
    GameManager.set_meta("run_achievements", _run_achievements)
```

```gdscript
# In game_over_screen.gd _ready():
var run_quests: Array = GameManager.get_meta("run_quests", [])
var run_achievements: Array = GameManager.get_meta("run_achievements", [])

if run_quests.size() + run_achievements.size() > 0:
    $VBox/RunSection.visible = true
    for qid in run_quests:
        # Find quest name and reward, add to list
        pass
    for aid in run_achievements:
        # Find achievement name and reward, add to list
        pass
else:
    $VBox/RunSection.visible = true
    $VBox/RunSection/NoneLabel.visible = true
```

### 5.5 Node Additions to game_over_screen.tscn

```
VBoxContainer (existing)
  +-- ... (existing labels)
  +-- RunSection (VBoxContainer)  [NEW]
        +-- SectionHeader (Label, "--- This Run ---")
        +-- QuestsLabel (Label, "Quests Completed: X")
        +-- QuestList (VBoxContainer)  [dynamic items]
        +-- Spacer (Control, min height 5px)
        +-- AchievementsLabel (Label, "Achievements Unlocked: X")
        +-- AchievementList (VBoxContainer)  [dynamic items]
        +-- NoneLabel (Label, "No new completions", hidden by default)
  +-- ... (existing buttons)
```

---

## 6. Complete File Change Map

### 6.1 New Files

| File | Purpose | Estimated Size |
|---|---|---|
| `scenes/quest_list.tscn` | Quest listing page scene | ~80 lines |
| `scripts/quest_list.gd` | Quest page logic | ~60 lines |
| `scenes/achievement_list.tscn` | Achievement listing page scene | ~120 lines |
| `scripts/achievement_list.gd` | Achievement page logic | ~80 lines |

### 6.2 Modified Files

| File | Change | Scope |
|---|---|---|
| `scenes/main.tscn` | Add "Quests" and "Achievements" buttons | 2 nodes |
| `scripts/title_screen.gd` | Connect new button signals | ~6 lines |
| `scenes/hud.tscn` | Add ToastContainer, 2 pooled toast panels | ~30 lines scene |
| `scripts/hud.gd` | Toast notification logic, run completion tracking | ~80 lines |
| `scenes/game_over_screen.tscn` | Add RunSection with dynamic lists | ~20 lines scene |
| `scripts/game_over_screen.gd` | Display run-specific completions | ~40 lines |

### 6.3 No Changes Needed

| File | Reason |
|---|---|
| `save_manager.gd` | Backend fully complete; signals already emit |
| `game_manager.gd` | No new state needed |

---

## 7. Color Palette Reference

| Purpose | Color | Hex | Godot Color |
|---|---|---|---|
| Quest border/indicator | Gold | `#ffd54f` | `Color(1.0, 0.84, 0.31)` |
| Achievement border/indicator | Purple | `#ce93d8` | `Color(0.81, 0.58, 0.85)` |
| Completed item background | Dark green | `rgba(15,25,15,0.8)` | `Color(0.15, 0.25, 0.15, 0.8)` |
| Incomplete item background | Dark gray | `rgba(20,20,20,0.5)` | `Color(0.2, 0.2, 0.2, 0.5)` |
| Check mark | Green | `#66bb6a` | `Color(0.4, 0.73, 0.42)` |
| Empty box | Gray | `#757575` | `Color(0.46, 0.46, 0.46)` |
| Reward text | Gold | `#ffd54f` | `Color(1.0, 0.84, 0.31)` |
| Toast background | Semi-transparent black | `rgba(0,0,0,0.7)` | `Color(0, 0, 0, 0.7)` |
| Section header | Gold | `#ffd54f` | `Color(1.0, 0.84, 0.31)` |
| Page background | Dark navy | `#1a1a2e` | `Color(0.1, 0.1, 0.18)` |

---

## 8. Interaction Design Details

### 8.1 Keyboard Navigation

| Context | Key | Action |
|---|---|---|
| Quest/Achievement list | Escape / Backspace | Return to main menu |
| Quest/Achievement list | Up/Down arrows | Scroll through list |
| HUD (during game) | No key interaction | Toasts are purely visual |
| Game over screen | No key interaction | Quest list is static display |

### 8.2 Animation Timing

| Animation | Duration | Easing | Notes |
|---|---|---|---|
| Toast slide-in from right | 0.2s | Ease-Out | `Tween.EASE_OUT` |
| Toast display hold | 2.0s | -- | Static |
| Toast slide-out to right | 0.3s | Ease-In | `Tween.EASE_IN` |
| Toast fade overlap | 0.1s | -- | When 2nd toast pushes 1st |
| Quest list page appear | 0.15s | Ease-Out | Scale from 0.95 to 1.0 |

### 8.3 Scroll Behavior (Quest/Achievement List)

- ScrollContainer with vertical scroll
- Touch/mouse drag scrolling
- No momentum/inertia (simple scroll)
- Items are 40px height each
- Total height: 14 quests * 40px = 560px (fits most screens without scroll)
- Total height: 27 achievements * 40px + 8 headers * 30px = 1320px (requires scroll)

---

## 9. Design Decisions Log

| Decision | Why | Alternative Considered |
|---|---|---|
| Toast max 2 visible | More than 2 is visually cluttered during action | Unlimited stack (too noisy) |
| 2-second toast duration | Long enough to read, short enough to not block view | 3s (lingers too long) |
| Separate quest/achievement pages | Different data sets; combined page would be too long | Tabbed single page (adds complexity) |
| Show hidden achievements as "???" | Preserves discovery without spoiling | Hide completely (player doesn't know to aim for them) |
| Max 5 items on game over | Prevents very long game over screens for completionist runs | Show all (could be 10+ items) |
| Track completions via GameManager meta | Simple, no new autoload needed | Dedicated completion tracker (over-engineering) |
| Quest page sorted by completion | Completed first feels rewarding | Original order (harder to see progress) |
| No progress bars on quests | Quests are binary (done/not done) -- no partial progress | Progress bars (would require reworking check logic) |
| Category headers in achievement list | 27 items need grouping for scanability | Flat list (overwhelming) |
| Yellow border for quests, purple for achievements | Consistent with difficulty mode colors and distinct from each other | Same color for both (confusing) |
