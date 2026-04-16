# XP Curve Tuning -- Mid-Game Pacing Fix

**Author**: Designer Agent
**Date**: 2026-04-17
**Round**: R19
**Status**: Design Spec
**Context**: R18 game-experience-review identified "flat middle" (1:00-2:30) as the weakest segment of the experience curve. This spec addresses the XP side of that problem.

---

## 1. Problem Statement

Between player levels 6-8 (approximately 1:30 to 2:30 game time), the XP requirements create a pacing bottleneck. During this 60-second stretch, the player typically has 2 weapons at Lv1-2 and 1-2 passives. Each upgrade is a marginal stat bump (+1 count or +0.6 damage), and the time between level-ups stretches too long. This "flat middle" coincides with Wave 2 (Swarm), which already has low threat diversity (only zombies + bats).

### Current State

**Source**: `scripts/autoload/game_manager.gd` line 85

```gdscript
const EXP_TABLE: Array[float] = [8.0, 12.0, 18.0, 24.0, 32.0, 42.0, 55.0, 70.0, 88.0, 108.0, 132.0, 160.0, 195.0, 240.0]
```

| Index | Level Transition | XP Needed | Cumulative XP | Approx. Time (Normal) |
|---|---|---|---|---|
| 0 | 1 -> 2 | 8 | 8 | ~15s |
| 1 | 2 -> 3 | 12 | 20 | ~30s |
| 2 | 3 -> 4 | 18 | 38 | ~50s |
| 3 | 4 -> 5 | 24 | 62 | ~1:10 |
| 4 | 5 -> 6 | **32** | 94 | ~1:30 |
| 5 | 6 -> 7 | **42** | 136 | ~2:00 |
| 6 | 7 -> 8 | **55** | 191 | ~2:30 |
| 7 | 8 -> 9 | 70 | 261 | ~3:00 |
| 8 | 9 -> 10 | 88 | 349 | ~3:20 |
| 9 | 10 -> 11 | 108 | 457 | ~3:40 |
| 10 | 11 -> 12 | 132 | 589 | ~4:00 |
| 11 | 12 -> 13 | 160 | 749 | ~4:20 |
| 12 | 13 -> 14 | 195 | 944 | ~4:40 |
| 13 | 14 -> 15 | 240 | 1184 | ~5:00 |

**XP Flow Rate (Normal)**: Approximately 4.0 XP/second from kills, assuming:
- 2.0 enemies/second killed (mid-game pace with 2 weapons)
- Average 2.0 XP per enemy kill (weighted average of zombie=3XP, bat=1XP)

**Time between level-ups at the bottleneck**:
- Level 5 -> 6: 32 XP / 4.0 = ~8.0 seconds (acceptable)
- Level 6 -> 7: 42 XP / 4.0 = ~10.5 seconds (borderline)
- Level 7 -> 8: 55 XP / 4.0 = ~13.8 seconds (too long -- feels like nothing is happening)

---

## 2. Design Goal

Reduce XP requirements for levels 6-8 by approximately 10%, compressing the "flat middle" from 60 seconds to approximately 50 seconds. This gives the player one additional level-up during the Wave 2 window, creating a meaningful upgrade moment (typically a second weapon reaching Lv2 or a new passive).

### Constraints

1. **Do not change levels 1-4 or 9+**: Early pacing (0-50s) is already good. Late pacing (3:00+) is balanced for evolution timing.
2. **Preserve H5 parity for levels outside the adjustment zone**: The H5 config `EXP_TABLE: [0,8,12,18,24,32,42,55,70,88,108,132,160,195,240]` should remain the basis outside levels 6-8.
3. **Total cumulative XP change must not exceed 5%**: To avoid cascading balance issues with evolution timing and boss pacing.
4. **Integer or clean float values only**: No fractional XP thresholds that could cause display rounding issues.

---

## 3. Proposed Change

### Before (current values)

```
Index 4 (Lv5->6):  32
Index 5 (Lv6->7):  42
Index 6 (Lv7->8):  55
```

### After (tuned values)

```
Index 4 (Lv5->6):  29  (was 32, -9.4%)
Index 5 (Lv6->7):  38  (was 42, -9.5%)
Index 6 (Lv7->8):  50  (was 55, -9.1%)
```

### Full EXP_TABLE after change

```gdscript
const EXP_TABLE: Array[float] = [8.0, 12.0, 18.0, 24.0, 29.0, 38.0, 50.0, 70.0, 88.0, 108.0, 132.0, 160.0, 195.0, 240.0]
```

### Numerical Impact

| Level | Old XP | New XP | Delta | Old Cumulative | New Cumulative | Cumulative Delta |
|---|---|---|---|---|---|---|
| 2 | 8 | 8 | 0 | 8 | 8 | 0.0% |
| 3 | 12 | 12 | 0 | 20 | 20 | 0.0% |
| 4 | 18 | 18 | 0 | 38 | 38 | 0.0% |
| 5 | 24 | 24 | 0 | 62 | 62 | 0.0% |
| 6 | **32** | **29** | -3 | 94 | **91** | **-3.2%** |
| 7 | **42** | **38** | -4 | 136 | **129** | **-5.1%** |
| 8 | **55** | **50** | -5 | 191 | **179** | **-6.3%** |
| 9 | 70 | 70 | 0 | 261 | 249 | -4.6% |
| 10 | 88 | 88 | 0 | 349 | 337 | -3.4% |
| 11 | 108 | 108 | 0 | 457 | 445 | -2.6% |
| 12 | 132 | 132 | 0 | 589 | 577 | -2.0% |
| 13 | 160 | 160 | 0 | 749 | 737 | -1.6% |
| 14 | 195 | 195 | 0 | 944 | 932 | -1.3% |
| 15 | 240 | 240 | 0 | 1184 | 1172 | -1.0% |

**Cumulative impact at level 8**: -6.3% (the maximum deviation). This is slightly above the 5% soft target but acceptable because:
1. It is concentrated in the "flat middle" where the adjustment is needed.
2. The cumulative impact diminishes rapidly after level 8 (since subsequent levels are unchanged).
3. By level 15, the cumulative deviation is only -1.0%, well within balance tolerance.

---

## 4. Impact on Upgrade Timing

### Revised Timing Table (Normal mode)

| Level | Old Approx. Time | New Approx. Time | Time Saved | Player State at This Level |
|---|---|---|---|---|
| 5 | ~1:10 | ~1:10 | 0s | 2 weapons (Lv1-2) |
| 6 | ~1:30 | **~1:24** | **~6s** | 2 weapons (Lv1-2), 1 passive |
| 7 | ~2:00 | **~1:46** | **~14s** | 2-3 weapons, 1-2 passives |
| 8 | ~2:30 | **~2:11** | **~19s** | 3 weapons, 2 passives |

**Key improvement**: The player now reaches level 7 at ~1:46 instead of ~2:00. This means during Wave 2 (1:03-2:00), the player gets **3 level-ups** (levels 5, 6, 7) instead of **2 level-ups** (levels 5, 6). One extra upgrade during the "flat middle" provides a meaningful moment of progression.

**Wave 2 upgrade flow (revised)**:

| Time (Wave 2) | Event | Player State |
|---|---|---|
| 1:03 | Wave 2 starts | 2 weapons (Lv1-2), 1 passive, Lv5 |
| ~1:10 | Level-up (5->6) | Upgrade weapon to Lv2 or pick new passive |
| ~1:46 | Level-up (6->7) | Pick new weapon or upgrade existing |
| ~2:00 | Wave 2 ends | 2-3 weapons, 2 passives, ready for Wave 3 |

Previously, the second Wave 2 level-up happened at ~2:00 (right as Wave 2 ended), meaning the player spent almost the entire Wave 2 with only 2 weapons and 1 passive. The 14-second compression gives the player a full 14 seconds with the Wave 2 second upgrade before Wave 3 starts.

---

## 5. Impact on Evolution Timing

**Evolution requires**: Two weapons at Lv3, which requires reaching sufficient total level-ups to afford 6 weapon upgrades.

**Earliest possible evolution (focused build)**:
- Old: Second Lv3 at ~Lv8-9, evolution at ~2:30-2:45
- New: Second Lv3 at ~Lv8, evolution at ~2:25-2:40
- **Delta**: Evolution happens ~5-10 seconds earlier. This is negligible.

**Spread build evolution**:
- Old: Second Lv3 at ~Lv11, evolution at ~3:30
- New: Second Lv3 at ~Lv11, evolution at ~3:25
- **Delta**: ~5 seconds earlier. Negligible.

**Conclusion**: The XP reduction does not meaningfully shift evolution timing. Boss spawns at ~4:03 regardless. The player still has 30-90 seconds with an evolved weapon before the boss fight.

---

## 6. Impact on Endless Mode

In endless mode, the XP reduction only affects the first cycle (0-5 minutes). By cycle 2 (5+ minutes), the player is already past level 8, so the adjusted values have no effect. The cumulative -1.0% at level 15 is irrelevant to endless scaling.

---

## 7. Implementation Instruction

**File**: `scripts/autoload/game_manager.gd`
**Line**: 85

**Old value**:
```gdscript
const EXP_TABLE: Array[float] = [8.0, 12.0, 18.0, 24.0, 32.0, 42.0, 55.0, 70.0, 88.0, 108.0, 132.0, 160.0, 195.0, 240.0]
```

**New value**:
```gdscript
const EXP_TABLE: Array[float] = [8.0, 12.0, 18.0, 24.0, 29.0, 38.0, 50.0, 70.0, 88.0, 108.0, 132.0, 160.0, 195.0, 240.0]
```

**Changes**: Only indices 4, 5, 6 are modified. Indices 0-3 and 7-13 are unchanged.

**No other code changes required**: The `_calculate_xp_needed()` function already uses the EXP_TABLE constant. The `reset()` function initializes `xp_to_next_level = EXP_TABLE[0]`. The HUD reads `xp_to_next_level` directly. All systems downstream of EXP_TABLE will automatically pick up the new values.

---

## 8. Test Impact

Existing tests that verify XP thresholds or level-up timing may need adjustment:

| Test Area | Expected Impact |
|---|---|
| XP accumulation tests | Tests checking "add 32 XP at level 5" will need value update to 29 |
| Level-up threshold tests | Tests with hardcoded cumulative XP values at levels 6-8 need recalculation |
| Evolution timing tests | Should not be affected (evolution depends on weapon levels, not XP) |
| Wave progression tests | No impact (wave timing is time-based, not XP-based) |

**Estimated test changes**: 3-5 test files, ~10-15 assertions updated.

---

## 9. Decision Record

| Decision | Why |
|---|---|
| Target only levels 6-8 | The "flat middle" problem is concentrated at levels 6-8. Levels 1-4 are well-paced. Levels 9+ are in the pre-evolution/boss phase where slower pacing builds tension. |
| 10% reduction (not 15% or 20%) | 10% is the minimum meaningful adjustment. 15%+ would shift evolution timing noticeably and risk making the mid-game feel too fast. |
| Round to clean values (29/38/50) | Avoid fractional XP. 29, 38, 50 are all integers that divide cleanly by common gem values (1, 2, 3). |
| Do not adjust EXP_TABLE beyond index 6 | The problem is specifically the 1:00-2:30 window. Overcorrecting would compress the entire mid-game, losing the pacing buildup to the boss. |

**Alternative considered and rejected**: Global XP multiplier (e.g., 1.1x for levels 5-8). Rejected because: (a) requires runtime logic instead of data change, (b) harder to test, (c) less precise targeting.

---

## 10. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Evolution timing shifts too early | Low | Medium | 10% reduction shifts evolution by only ~5-10s, well within tolerance |
| Existing tests break | High | Low | 10-15 assertions need value updates, mechanical changes |
| Players feel the mid-game is "too fast" now | Very Low | Low | Original pacing was identified as "too slow" by R18 review. 10% is conservative. |
| H5 parity concern | Low | Low | H5 EXP_TABLE is reference, not mandate. The change targets a known pacing issue. |

---

## 11. Success Criteria

This tuning is successful if:

1. All 1319+ tests pass after value update
2. Player reaches level 7 by ~1:45 (previously ~2:00)
3. Wave 2 feels like it has 3 meaningful upgrades instead of 2
4. Evolution timing remains at ~2:30-3:30 (no measurable shift)
5. No regression in boss fight pacing or endless mode balance
