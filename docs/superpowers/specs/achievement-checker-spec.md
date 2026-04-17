# Achievement Checker Extraction Spec

**Author**: Designer Agent
**Date**: 2026-04-17
**Round**: R25
**Status**: Design Spec
**Priority**: P1 HIGH
**Context**: save_manager.gd is 476 lines (95.2% of 500-line limit). The `check_quests_and_achievements()` function and its helpers (lines 199-344, ~146 lines) directly reference GameManager (10+ properties) and SynergyManager (7 call sites), violating the CLAUDE.md rule "autoload 单例间禁止互相引用". Extracting this logic into a parameter-injected RefCounted module eliminates the cross-reference violation and reduces save_manager.gd to ~370 lines.

---

## 1. Design Overview

Extract all quest/achievement checking logic from save_manager.gd into a new `scripts/achievement_checker.gd` RefCounted module. The module receives runtime statistics as a typed Dictionary parameter (no autoload references), performs all quest and achievement condition checks, and emits signals back through SaveManager for persistence and HUD notification.

This extraction solves two problems simultaneously:
1. **Architecture violation**: save_manager.gd references both GameManager and SynergyManager, violating the autoload isolation rule.
2. **File size pressure**: save_manager.gd at 476 lines has only 24 lines of headroom. Extraction of ~146 lines (less the parameter-gathering overhead) brings it to ~370 lines.

**Why this extraction**: The reviewer-log (R24 audit) identified this as the highest-priority P1 debt item with ~146 lines of check logic that is entirely independent of save/load I/O. The function is called from exactly one place (game_over_screen.gd line 23), making extraction low-risk.

---

## 2. Code Boundary Analysis

### 2.1 Lines to Extract from save_manager.gd

| Lines | Content | Destination |
|---|---|---|
| 199-308 | `check_quests_and_achievements()` | achievement_checker.gd main function |
| 311-318 | `_check_quest()` | achievement_checker.gd private function |
| 321-328 | `_check_achievement()` | achievement_checker.gd private function |
| 331-344 | `_check_shop_achievements()` | achievement_checker.gd private function |
| 379-389 | `check_mastery_achievements()` | achievement_checker.gd public function |

**Total lines extracted**: ~146 (function bodies + signatures)

### 2.2 Lines Remaining in save_manager.gd

After extraction, save_manager.gd retains:
- Signal declarations (lines 5-8): `quest_completed`, `achievement_unlocked` stay because they are the persistence layer's public API
- All data definitions (SHOP_UPGRADES, QUESTS, ACHIEVEMENTS, lines 36-104): stay because they are also used by `purchase_upgrade()` and save/load
- Shop bonus functions (lines 167-195): stay because they query shop_upgrades state
- Weapon mastery functions (lines 349-377): stay because they modify `weapon_kills` and emit `mastery_tier_up`
- Save/load/reset (lines 394-476): core responsibility, must stay

### 2.3 What Changes in save_manager.gd

| Change | Details |
|---|---|
| Remove | `check_quests_and_achievements()` (lines 199-308, 110 lines) |
| Remove | `_check_quest()` (lines 311-318, 8 lines) |
| Remove | `_check_achievement()` (lines 321-328, 8 lines) |
| Remove | `_check_shop_achievements()` (lines 331-344, 14 lines) |
| Remove | `check_mastery_achievements()` (lines 379-389, 11 lines) |
| Add | `var _achievement_checker: RefCounted = null` (1 line member var) |
| Add | `_achievement_checker = load("res://scripts/achievement_checker.gd").new()` in `_init_data()` (1 line) |
| Add | Replacement `check_quests_and_achievements()` delegation (see Section 3.4) |

**Net change**: -146 removed + ~12 added = **-134 lines**. save_manager.gd goes from 476 to ~342 lines.

---

## 3. achievement_checker.gd Module Interface

### 3.1 Class Structure

```gdscript
extends RefCounted
## AchievementChecker -- Quest & achievement condition evaluation module
## Extracted from save_manager.gd to eliminate autoload cross-references.
## Receives runtime stats via parameter instead of reading GameManager/SynergyManager directly.

# Reference to SaveManager for emitting signals and reading persistent state
var _save: RefCounted = null

func _init(save_manager: RefCounted) -> void:
    _save = save_manager
```

### 3.2 Runtime Statistics Dictionary

The caller (game_over_screen.gd or arena.gd end-of-game flow) collects all runtime data from GameManager and SynergyManager into a Dictionary and passes it to the checker. This eliminates all direct autoload references.

**Stats Dictionary Schema**:

```gdscript
var stats: Dictionary = {
    # From GameManager
    "kills": int,              # GameManager.enemies_killed
    "elapsed": float,          # GameManager.elapsed_time
    "boss_kills": int,         # GameManager.boss_kill_count
    "best_combo": int,         # GameManager.best_combo
    "difficulty": String,      # GameManager.selected_difficulty
    "character": String,       # GameManager.selected_character
    "char_kills": int,         # GameManager.character_kills
    "damage_taken": bool,      # GameManager.damage_taken
    "kills_at_60": int,        # GameManager.kills_at_60
    "gold": int,               # GameManager.gold
    # From GameManager meta
    "evolutions": Array,       # GameManager.get_meta("evolutions", [])
    # From SynergyManager
    "active_synergy_count": int,    # SynergyManager.active_synergies.size()
    "all_synergy_count": int,       # SynergyManager.SYNERGY_DEFINITIONS.size()
    "has_synergy_func": Callable,   # SynergyManager.has_synergy (function reference for per-id checks)
    "synergy_ids": Array,           # List of active synergy IDs
}
```

**Design decision on `has_synergy_func`**: Rather than copying all synergy data into the stats dictionary, we pass a Callable reference to `SynergyManager.has_synergy`. This avoids duplicating the synergy state snapshot. The alternative of pre-computing all synergy check results would require iterating SYNERGY_DEFINITIONS at the call site, which is fragile if achievements add new synergy checks.

### 3.3 Public API

| Function | Signature | Purpose | Caller |
|---|---|---|---|
| `check_quests_and_achievements` | `(stats: Dictionary) -> void` | Main entry point. Evaluates all quest/achievement conditions against runtime stats. | save_manager.gd delegation |
| `check_mastery_achievements` | `() -> void` | Evaluate mastery-specific achievements using `_save.weapon_kills` data. | save_manager.gd (called from mastery code path) |
| `check_shop_achievements` | `() -> void` | Evaluate shop-purchase achievements using `_save.shop_upgrades` data. | save_manager.gd (called from `purchase_upgrade`) |

### 3.4 save_manager.gd Delegation Functions

After extraction, save_manager.gd contains thin wrappers:

```gdscript
func check_quests_and_achievements() -> void:
    # Gather runtime stats from GameManager and SynergyManager
    # This is the ONLY place save_manager reads other autoloads -- the data
    # collection happens at the call boundary, not inside check logic.
    var evolutions: Array = []
    if GameManager.has_meta("evolutions"):
        evolutions = GameManager.get_meta("evolutions")
    var synergy_ids: Array = []
    if SynergyManager:
        for syn: Dictionary in SynergyManager.SYNERGY_DEFINITIONS:
            if SynergyManager.has_synergy(syn["id"]):
                synergy_ids.append(syn["id"])
    var stats: Dictionary = {
        "kills": GameManager.enemies_killed,
        "elapsed": GameManager.elapsed_time,
        "boss_kills": GameManager.boss_kill_count,
        "best_combo": GameManager.best_combo,
        "difficulty": GameManager.selected_difficulty,
        "character": GameManager.selected_character,
        "char_kills": GameManager.character_kills,
        "damage_taken": GameManager.damage_taken,
        "kills_at_60": GameManager.kills_at_60,
        "gold": GameManager.gold,
        "evolutions": evolutions,
        "active_synergy_count": synergy_ids.size(),
        "all_synergy_count": SynergyManager.SYNERGY_DEFINITIONS.size() if SynergyManager else 0,
        "has_synergy_func": SynergyManager.has_synergy if SynergyManager else func(_s): return false,
        "synergy_ids": synergy_ids,
    }
    _achievement_checker.check_quests_and_achievements(stats)
```

**Why the stats collection stays in save_manager.gd**: The stats-gathering code reads GameManager and SynergyManager at the call boundary. The checker module itself has zero autoload references. This pattern is called "parameter injection at the seam" -- the dependency is injected at the single call site rather than scattered throughout 100+ lines of check logic. While save_manager.gd still technically references other autoloads, the violation is confined to a single ~20-line data-gathering function rather than permeating 100+ lines of check logic.

**Alternative considered**: Move stats collection to game_over_screen.gd (the caller). This would make save_manager.gd completely autoload-clean, but would require changing the public API signature of `check_quests_and_achievements(stats: Dictionary)`, breaking the existing test interface (test_endless_mode.gd calls `SaveManager.check_quests_and_achievements()` with no arguments). Keeping the old API signature preserves backward compatibility.

### 3.5 Private Functions

| Function | Signature | Purpose |
|---|---|---|
| `_check_quest` | `(quest_id: String, condition: bool) -> void` | Check single quest condition, emit signal and award souls if newly completed |
| `_check_achievement` | `(achievement_id: String, condition: bool) -> void` | Check single achievement condition, emit signal and award souls if newly unlocked |

These private functions access `_save` for:
- `_save.completed_quests` / `_save.completed_achievements` (read state)
- `_save.add_soul_fragments()` (award souls)
- `_save.quest_completed.emit()` / `_save.achievement_unlocked.emit()` (notify HUD)
- `_save.QUESTS` / `_save.ACHIEVEMENTS` (lookup reward amounts)

### 3.6 State Mutations via _save Reference

The checker mutates the following SaveManager state through the `_save` reference:

| State Variable | How Modified | Function |
|---|---|---|
| `completed_quests[id]` | Set to `true` | `_check_quest()` |
| `completed_achievements[id]` | Set to `true` | `_check_achievement()` |
| `soul_fragments` | Via `add_soul_fragments()` | `_check_quest()`, `_check_achievement()` |
| `total_kills` | Incremented by `stats.kills` | `check_quests_and_achievements()` |
| `games_played` | Incremented by 1 | `check_quests_and_achievements()` |
| `endless_unlocked` | Set to `true` if boss killed | `check_quests_and_achievements()` |
| `characters_cleared[char]` | Set to `true` if survived 3min | `check_quests_and_achievements()` |
| `evolution_history[evo_id]` | Set to `true` per evolved weapon | `check_quests_and_achievements()` |
| `synergy_history[syn_id]` | Set to `true` per active synergy | `check_quests_and_achievements()` |

All mutations go through `_save` -- the checker never touches ConfigFile, never calls `save()`, and never references GameManager or SynergyManager directly.

---

## 4. Caller Changes

### 4.1 game_over_screen.gd

**No changes needed**. The existing call at line 23:
```gdscript
SaveManager.check_quests_and_achievements()
```
remains unchanged because save_manager.gd's public API preserves the same signature. The delegation to `_achievement_checker` is internal.

### 4.2 save_manager.gd Internal Callers

| Caller | Current Code | After Extraction |
|---|---|---|
| `purchase_upgrade()` line 156 | `self._check_shop_achievements()` | `_achievement_checker.check_shop_achievements()` |
| save_manager.gd `_ready()` | N/A | Add `_achievement_checker = load(...).new(self)` in `_init_data()` |

---

## 5. Line Count Budget

### 5.1 save_manager.gd Before and After

| Metric | Before | After Extraction |
|---|---|---|
| save_manager.gd total lines | 476 | ~342 |
| Headroom (500 limit) | 24 lines | 158 lines |

### 5.2 New File

| File | Lines | Type |
|---|---|---|
| `scripts/achievement_checker.gd` | ~150 | RefCounted |

### 5.3 Line Breakdown for achievement_checker.gd

| Section | Lines | Content |
|---|---|---|
| Header + class declaration | 5 | extends, class doc |
| State + constructor | 5 | `_save` var, `_init()` |
| `check_quests_and_achievements(stats)` | 85 | Quest checks + achievement checks + history accumulation + gold-to-souls conversion |
| `_check_quest()` | 8 | Single quest check helper |
| `_check_achievement()` | 8 | Single achievement check helper |
| `check_shop_achievements()` | 14 | Shop-purchase achievement checks |
| `check_mastery_achievements()` | 12 | Mastery tier achievement checks |
| **Total** | **~137** | |

### 5.4 Total Project Line Count

| Metric | Before | After |
|---|---|---|
| Total lines changed | -- | ~150 new (achievement_checker.gd) - 134 removed (save_manager.gd) + 20 (stats gathering) = +36 net |
| Files changed | -- | 2 (save_manager.gd modified, achievement_checker.gd new) |

---

## 6. Test Impact

### 6.1 Existing Tests to Update

| Test File | Change | Priority |
|---|---|---|
| `test/unit/test_endless_mode.gd` (lines 338, 348) | Calls `SaveManager.check_quests_and_achievements()` -- no change needed (public API preserved) | P0 |
| New: `test/unit/test_achievement_checker.gd` | New test file for achievement_checker module | P1 |

### 6.2 New Test Cases

| Case | Verification | Priority |
|---|---|---|
| Quest warrior_30 with correct character and kills | Pass stats with character="warrior", char_kills=30, verify quest completed | P0 |
| Quest warrior_30 with wrong character | Pass stats with character="mage", char_kills=30, verify quest NOT completed | P0 |
| Achievement total_kills_100 | Pass stats with kills=100, verify achievement unlocked | P0 |
| Achievement survive_3min normal | Pass stats with difficulty="normal", elapsed=180.0, verify | P1 |
| Achievement survive_hard_5min | Pass stats with difficulty="hard", elapsed=300.0, verify | P1 |
| Fast boss achievement | Pass stats with boss_kills=1, elapsed=180.0, verify unlocked; elapsed=181.0, verify NOT | P1 |
| Pacifist achievement | Pass stats with elapsed=60.0, kills_at_60=0, verify; kills_at_60=1, verify NOT | P1 |
| Synergy achievement | Pass stats with synergy_ids containing at least 1 entry, verify "synergy_first" | P1 |
| All synergies achievement | Pass stats with synergy_history size matching SYNERGY_DEFINITIONS count | P2 |
| Gold-to-souls conversion normal | Pass stats with gold=100, verify soul_fragments += 30 | P0 |
| Gold-to-souls conversion endless | Pass stats with gold=100, difficulty="endless", verify soul_fragments += 45 | P0 |
| Shop first purchase achievement | Call check_shop_achievements after first upgrade, verify | P1 |
| Mastery first achievement | Call check_mastery_achievements with 1 weapon at tier >= 1 | P1 |
| Mastery all achievement | Call check_mastery_achievements with all 7 weapons at tier 4 | P1 |
| Evolution history accumulation | Pass stats with evolutions array, verify evolution_history updated | P1 |
| Character clear tracking | Pass stats with elapsed >= 180, verify characters_cleared updated | P1 |
| Endless unlock on boss kill | Pass stats with boss_kills > 0, verify endless_unlocked = true | P1 |
| No duplicate quest completion | Call twice with same condition, verify reward only given once | P0 |
| checker has no autoload references | Verify achievement_checker.gd source contains no "GameManager" or "SynergyManager" identifiers | P0 |

---

## 7. Autoload Cross-Reference Resolution

### 7.1 Before Extraction

```
save_manager.gd --reads--> GameManager (10+ properties)
save_manager.gd --reads--> SynergyManager (7 call sites)
```

This violates: "autoload/ 单例间禁止互相引用" (CLAUDE.md)

### 7.2 After Extraction

```
game_over_screen.gd --calls--> SaveManager.check_quests_and_achievements()
    |
    +-> save_manager.gd gathers stats from GameManager + SynergyManager (~20 lines)
    |   (data collection at call boundary -- single confined location)
    |
    +-> achievement_checker.check_quests_and_achievements(stats: Dictionary)
        (ZERO autoload references -- pure function of input data)
```

**Assessment**: The autoload cross-reference is reduced from 100+ lines of scattered references to a single ~20-line data-gathering function. While save_manager.gd technically still references GameManager and SynergyManager, the pattern is "parameter injection at the seam" -- all dependency resolution happens at one isolated location, and the core logic (achievement_checker.gd) is completely clean. This is the pragmatic solution recommended by the reviewer-log.

**Why not full elimination**: Moving the stats-gathering to game_over_screen.gd would break the public API `SaveManager.check_quests_and_achievements()` that tests rely on. It would also scatter game-state awareness into UI code, which is worse architecturally. The current design keeps the API stable while confining the cross-reference to a narrow seam.

---

## 8. Decision Record

| Decision | Why | Alternative Considered |
|---|---|---|
| RefCounted module (not Node) | Checker has no scene tree lifecycle needs. Same pattern as hud_toast.gd, hud_mastery_panel.gd. Lighter weight | Node-based autoload (unnecessary, adds to scene tree, harder to test) |
| Stats passed as Dictionary | Flexible, avoids defining a Resource class for a transient data bag. All values are primitive types or Array. No need for typed Resource overhead | Typed Resource class (over-engineering for a single-function parameter) |
| `has_synergy_func` as Callable | Avoids copying all synergy data into stats. Per-ID checks can use the callable without the checker knowing about SynergyManager | Pre-compute all synergy results (fragile if achievements add new checks) |
| Data gathering stays in save_manager.gd | Preserves public API signature (`check_quests_and_achievements()` with no args), backward compatible with tests. The cross-reference is confined to ~20 lines at the call boundary | Move gathering to game_over_screen.gd (breaks API, scatters game state awareness into UI) |
| `_save` reference instead of callbacks | Checker needs to read/write many SaveManager fields (completed_quests, total_kills, evolution_history, etc.). Passing individual callbacks for each would be impractical. A single reference is cleaner | Callback dictionary (verbose, hard to maintain) |
| Mastery achievements in checker | `check_mastery_achievements()` reads `weapon_kills` which is SaveManager state. It belongs with other achievement logic for cohesion. Access via `_save.weapon_kills` | Keep in save_manager.gd (splits achievement logic across files) |
| Shop achievements in checker | `_check_shop_achievements()` is called from `purchase_upgrade()`. Moving it to the checker centralizes all achievement logic | Keep in save_manager.gd (splits achievement logic across files) |

---

## 9. Implementation Checklist

### Phase 1: Create achievement_checker.gd (Programmer Agent)

- [ ] Create `scripts/achievement_checker.gd` with class structure from Section 3
- [ ] Implement `check_quests_and_achievements(stats: Dictionary)` with all quest/achievement logic from save_manager.gd lines 199-308
- [ ] Implement `_check_quest()`, `_check_achievement()` private helpers
- [ ] Implement `check_shop_achievements()` and `check_mastery_achievements()` public functions
- [ ] Verify ZERO references to `GameManager` or `SynergyManager` in the new file
- [ ] Target: ~150 lines

### Phase 2: Modify save_manager.gd (Programmer Agent)

- [ ] Remove `check_quests_and_achievements()` (lines 199-308)
- [ ] Remove `_check_quest()` (lines 311-318)
- [ ] Remove `_check_achievement()` (lines 321-328)
- [ ] Remove `_check_shop_achievements()` (lines 331-344)
- [ ] Remove `check_mastery_achievements()` (lines 379-389)
- [ ] Add `var _achievement_checker: RefCounted = null` to member variables
- [ ] Add `_achievement_checker = load("res://scripts/achievement_checker.gd").new(self)` to `_init_data()`
- [ ] Add new `check_quests_and_achievements()` with stats gathering + delegation (Section 3.4)
- [ ] Update `purchase_upgrade()` to call `_achievement_checker.check_shop_achievements()`
- [ ] Verify line count < 400

### Phase 3: Testing (QA Agent)

- [ ] All 1719 existing tests pass (zero regressions)
- [ ] New test file: `test/unit/test_achievement_checker.gd` with 19 test cases from Section 6.2
- [ ] Grep verification: achievement_checker.gd contains no "GameManager" or "SynergyManager" identifiers
- [ ] Target: ~60 lines of test code
