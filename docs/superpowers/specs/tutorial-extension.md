# Tutorial Extension: Steps 6-8 Design Spec

**Author**: Designer Agent
**Date**: 2026-04-17
**Round**: R23
**Status**: Design Spec
**Priority**: P2 MEDIUM
**Context**: Tutorial system has 5 steps (move/dash/weapon/upgrade/skill) implemented since R17. Steps 6-8 cover mid-game mechanics (evolution hints, combo system, synergy) that currently have no in-game explanation. v1.0.3 roadmap item 4.2.

---

## 1. Design Overview

Three new tutorial steps extend the existing TutorialManager to cover mid-game mechanics that confuse new players. Each step uses the same tooltip bubble system as steps 1-5. Steps 6-8 are designed as "discovery hints" -- triggered when the player first encounters the relevant mechanic, teaching by context rather than preemptively.

**Why these three**: Analysis of gameplay flow shows three key mid-game moments where players lack guidance: (1) having 2 weapons at Lv3 with no hint that evolution exists, (2) building a combo streak with no explanation of the bonus, (3) triggering a synergy with no feedback on what happened. These are the three highest-impact gaps in the current 5-step tutorial.

---

## 2. Step Definitions

### Step 6: Evolution Hint

| Property | Value |
|---|---|
| **Trigger condition** | Player has 2 weapons, both at level 2 or higher (`owned_weapons` has 2+ entries where value >= 2) |
| **Display content** | "Weapons evolve at Lv3! Check combinations when both are maxed." |
| **Position** | Top center of viewport (same as Step 3) |
| **Interaction** | Auto-dismiss after 4.0 seconds |
| **Timeout** | 4.0 seconds |
| **Condition check** | `SaveManager.tutorial_step < 6` |
| **Rationale** | Players who invest in 2 weapons should know evolution exists before they hit Lv3, creating anticipation. Trigger at Lv2 (not Lv3) because Lv3 is when evolution happens -- the hint should precede the event. |

### Step 7: Combo Bonus

| Property | Value |
|---|---|
| **Trigger condition** | `GameManager.combo_count >= 5` for the first time |
| **Display content** | "Combo kills give bonus XP! Keep killing to maintain your streak." |
| **Position** | Top center of viewport |
| **Interaction** | Auto-dismiss after 3.5 seconds |
| **Timeout** | 3.5 seconds |
| **Condition check** | `SaveManager.tutorial_step < 7` |
| **Rationale** | Combo >= 5 is when the XP bonus becomes noticeable (5 x 5% = 25% extra). Below 5, the bonus is marginal and not worth interrupting gameplay to explain. The combo counter is visible in the HUD but its significance is unclear to new players. |

### Step 8: Synergy Activation

| Property | Value |
|---|---|
| **Trigger condition** | `SynergyManager.active_synergies` count increases (new synergy triggers) |
| **Display content** | "Synergy activated! Some weapon+passive combos create powerful effects." |
| **Position** | Top center of viewport |
| **Interaction** | Auto-dismiss after 4.0 seconds |
| **Timeout** | 4.0 seconds |
| **Condition check** | `SaveManager.tutorial_step < 8` |
| **Rationale** | Synergies are the most opaque mechanic -- they activate silently with no HUD feedback. Players may not even notice the effect. This step confirms the mechanic exists and encourages exploring combinations. |

---

## 3. Numerical Constants Table

| Constant Name | Value | Unit | Source | Notes |
|---|---|---|---|---|
| `TUTORIAL_STEP6_TIMEOUT` | 4.0 | s | Design | Evolution hint display duration |
| `TUTORIAL_STEP7_TIMEOUT` | 3.5 | s | Design | Combo hint display duration |
| `TUTORIAL_STEP8_TIMEOUT` | 4.0 | s | Design | Synergy hint display duration |
| `TUTORIAL_STEP6_MIN_WEAPONS` | 2 | int | Design | Weapon count to trigger evolution hint |
| `TUTORIAL_STEP6_MIN_LEVEL` | 2 | int | Design | Minimum level for both weapons |
| `TUTORIAL_STEP7_COMBO_THRESHOLD` | 5 | int | Design (matches COMBO_EXP_RATE activation) | Combo count to trigger combo hint |
| `TUTORIAL_TOTAL_STEPS` | 8 | int | Updated from 5 | New total step count |

---

## 4. State Machine Extension

Current state machine ends at step 5. Extended state machine:

```
[5: Skill completed] (existing)
    |
    +-- (2 weapons, both >= Lv2) --> [Step 6: Evolution Hint]
    |
    +-- (4s timeout) --> [6: Evolution Hint completed]
    |
    +-- (combo_count >= 5) --> [Step 7: Combo Bonus]
    |
    +-- (3.5s timeout) --> [7: Combo Bonus completed]
    |
    +-- (new synergy triggers) --> [Step 8: Synergy]
    |
    +-- (4s timeout) --> [8: All complete, tutorial_completed = true]
```

**Backward compatibility**: Existing saves with `tutorial_step = 5` and `tutorial_completed = true` will skip steps 6-8 (the `tutorial_completed = true` check short-circuits all tutorial logic). This is correct behavior because players who already completed the old 5-step tutorial are experienced enough to not need mid-game hints.

**For existing saves with `tutorial_step = 5` but `tutorial_completed = false`**: These players will continue into steps 6-8 naturally. This edge case is handled correctly by the state machine.

---

## 5. Implementation Touch Points

### 5.1 Files to Modify

| File | Change | Lines |
|---|---|---|
| `scripts/tutorial_manager.gd` | Add 3 new step processing functions, update TUTORIAL_TOTAL_STEPS from 5 to 8, extend match statement in _physics_process(), add _prev_synergy_count state variable | ~40 lines |
| `scripts/autoload/save_manager.gd` | Update tutorial_completed condition from >= 5 to >= 8 (or use TUTORIAL_TOTAL_STEPS constant) | ~1 line (if using constant) |
| `test/unit/test_tutorial.gd` | Add 6 new test cases (3 trigger + 3 timeout/skip) | ~30 lines |

### 5.2 New State Variables in TutorialManager

```gdscript
# For Step 7: track combo count changes
var _step7_first_high_combo: bool = false

# For Step 8: track synergy count changes
var _prev_synergy_count: int = 0
```

### 5.3 Signal Dependencies

| Step | Trigger Mechanism | Implementation |
|---|---|---|
| 6 | Poll in _physics_process | Check `player.owned_weapons` size and values each frame |
| 7 | Poll in _physics_process | Check `GameManager.combo_count` each frame |
| 8 | Signal or poll | Connect to `SynergyManager` change, or poll `SynergyManager.active_synergies.size()` |

**Step 8 implementation detail**: SynergyManager does not currently emit a signal when a new synergy activates. Two options:

**Option A (recommended)**: Poll `SynergyManager.active_synergies.size()` in `_process_step_synergy()`. Low cost because this only runs while `_step == 7` (waiting for synergy trigger).

**Option B**: Add `synergy_activated(synergy_id: String)` signal to SynergyManager. More correct but requires modifying synergy_manager.gd.

Choosing Option A because: (1) the tutorial manager only polls during step 7, not continuously, (2) SynergyManager already has `active_synergies` as a public dictionary, (3) adding a signal to SynergyManager requires coordination with Programmer Agent for a purely tutorial-driven change.

### 5.4 SaveManager Compatibility

The `TUTORIAL_TOTAL_STEPS` constant must be updated to 8. All checks against `TUTORIAL_TOTAL_STEPS` in tutorial_manager.gd will automatically update:

- Line 39: `if SaveManager.tutorial_completed: _step = TUTORIAL_TOTAL_STEPS` -- works correctly
- Line 58: `if _step >= TUTORIAL_TOTAL_STEPS` -- works correctly
- Line 242: `if _step >= TUTORIAL_TOTAL_STEPS: SaveManager.tutorial_completed = true` -- works correctly

The `get_step_text()`, `get_step_timeout()`, and `get_dismiss_action()` public API functions need 3 new match cases each.

---

## 6. Public API Extensions

### 6.1 get_step_text() Additions

```gdscript
6:
    return "Weapons evolve at Lv3! Check combinations when both are maxed."
7:
    return "Combo kills give bonus XP! Keep killing to maintain your streak."
8:
    return "Synergy activated! Some weapon+passive combos create powerful effects."
```

### 6.2 get_step_timeout() Additions

```gdscript
6:
    return TUTORIAL_STEP6_TIMEOUT
7:
    return TUTORIAL_STEP7_TIMEOUT
8:
    return TUTORIAL_STEP8_TIMEOUT
```

### 6.3 get_dismiss_action() Additions

```gdscript
6:
    return "timeout"  # auto-dismiss only
7:
    return "timeout"  # auto-dismiss only
8:
    return "timeout"  # auto-dismiss only
```

---

## 7. Trigger Timing Analysis

When do these steps typically fire during a Normal mode game?

| Step | Expected Trigger Time | Game State |
|---|---|---|
| 6 (Evolution) | ~1:30 - 2:00 | Wave 2, 2 weapons at Lv2+ |
| 7 (Combo) | ~0:45 - 1:30 | Wave 1-2, first dense enemy group |
| 8 (Synergy) | ~1:30 - 3:00 | After first passive + weapon combo |

**Note**: Step 7 may trigger before Step 6 because combo >= 5 can occur as early as ~0:45 (first 5 kills in quick succession). This is acceptable because the tutorial is designed to teach by context -- each step stands alone.

**Step ordering is not guaranteed**: Unlike steps 1-5 (which follow a strict sequence), steps 6-8 are independent discovery hints. The player may encounter combo before having 2 weapons, or synergy before combo. The state machine enforces step 6 -> 7 -> 8 order, which means:

- If combo >= 5 triggers first (before 2 weapons at Lv2), step 7 waits until step 6 completes
- Step 6 will fire quickly (most players get a second weapon within 30 seconds)
- The delay is at most ~30 seconds and does not harm the learning experience

---

## 8. Decision Record

| Decision | Why | Alternative Considered |
|---|---|---|
| Steps 6-8 are sequential, not parallel | Simpler state machine, consistent with existing 5-step design, avoids multiple overlapping tooltips | Parallel triggers with priority queue (more complex, over-engineering for 3 hints) |
| Trigger Step 6 at Lv2 (not Lv3) | Hint should precede the event. Lv3 is when evolution happens; Lv2 is when the player is one upgrade away, creating anticipation | Trigger at Lv3 (too late, evolution already available with no forewarning) |
| Combo threshold is 5 (not 10 or 20) | At combo 5, the XP bonus is 25% -- noticeable but not game-changing. This is the earliest moment where the combo mechanic becomes meaningful | Threshold 10 (25% of players may not reach 10 combo in their first game) |
| All 3 steps use auto-dismiss timeout | Mid-game mechanics do not require player interaction to acknowledge. The tooltip is informational, not instructional | Require player to press a key (interrupts gameplay flow for no benefit) |
| Poll synergy count rather than signal | Lower implementation cost, tutorial manager only polls during step 7, no changes to SynergyManager needed | Add signal to SynergyManager (requires Programmer Agent coordination for a tutorial-only need) |
| TUTORIAL_TOTAL_STEPS updated to 8 | Clean extension. All existing checks use the constant, so updating it propagates automatically | Keep total at 5 and use a separate "extended tutorial" flag (adds unnecessary complexity) |

---

## 9. Test Cases

| Case | Verification | Priority |
|---|---|---|
| Step 6 triggers at 2 weapons Lv2 | `tutorial_step == 5`, player has 2 weapons at level 2, tooltip appears | P1 |
| Step 7 triggers at combo 5 | `tutorial_step == 6`, combo_count reaches 5, tooltip appears | P1 |
| Step 8 triggers at synergy | `tutorial_step == 7`, new synergy activates, tooltip appears | P1 |
| All 3 steps auto-dismiss | Each step times out and increments tutorial_step | P1 |
| Existing save backward compat | `tutorial_completed == true` skips all 8 steps | P0 |
| Step 6 does not trigger early | Only 1 weapon: no trigger. 2 weapons both Lv1: no trigger | P2 |
| get_step_text returns correct strings for steps 6-8 | Public API returns expected text | P2 |
| get_step_timeout returns correct values for steps 6-8 | Public API returns expected timeouts | P2 |
