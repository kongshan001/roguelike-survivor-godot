# Game Experience Review -- Complete Player Journey Analysis

**Author**: Designer Agent
**Date**: 2026-04-17
**Round**: R18
**Status**: Design Review
**Scope**: Analysis of the complete player experience curve from first launch to long-term engagement

---

## 1. Executive Summary

This review analyzes the game experience across four time horizons: (1) first 30 seconds (tutorial impact), (2) 1-3 minutes (rhythm and pacing), (3) 5+ minutes (depth and differentiation), and (4) repeat play motivation (meta-progression). The game delivers a strong core loop with 100% H5 feature parity, but exhibits three systemic gaps: (a) the first 30 seconds lack ceremony and emotional hook, (b) the mid-game (1-3 min) suffers from flat power scaling between weapon Lv2 and evolution, and (c) the endgame lacks a compelling "one more run" driver beyond achievements.

**Overall Experience Score: 82/100**

---

## 2. First 30 Seconds -- Tutorial and First Impressions

### 2.1 Current Flow

```
Launch -> Title Screen -> Character Select -> Difficulty Select -> (Weapon Select for Mage) -> Arena
```

The player enters the arena at time 0. With v1.0.1 tutorial system, the experience is:

| Time | Event | Tutorial Step | Emotional State |
|---|---|---|---|
| 0.0s | Arena loads, player appears | -- | Curiosity / uncertainty |
| 0.0-2.0s | No enemies yet, player stationary | Waiting for Step 1 trigger | Mild confusion ("what do I do?") |
| 2.0s | Tutorial bubble: "WASD move" | Step 1 | Relief ("oh, I move") |
| 2.0-5.0s | Player experiments with movement | Step 1 active | Engagement |
| ~5.0s | First zombie spawns (Wave 1, 2.0s interval) | -- | Mild tension |
| ~7.0s | Zombie enters 200px range | Step 2: "Space dash" | Learning |
| ~8.0s | Weapon auto-fires, first kill | Step 3: "Weapon auto-attacks, collect XP gems" | Reward ("cool, it shoots!") |
| ~15s | Player picks up first XP gem | -- | Satisfying (gem flies to player) |
| ~25s | Level up triggers | Step 4: "Choose upgrade card or press 1/2/3" | Decision moment |
| ~40s | Skill cooldown completes | Step 5: "Press E for skill" | Discovery |

### 2.2 Analysis

**Strengths**:
- Tutorial covers all 3 core interactions (move, dash, upgrade) within 60 seconds
- Step 3 is well-timed: weapon auto-fires before tutorial explains it, creating a "discovery then explanation" arc
- XP gem fly-to-player animation provides immediate visual reward

**Weaknesses**:

1. **No ceremony on arena entry**: The player materializes in a blank arena with no fanfare. VS shows a character select animation. Brotato shows a wave countdown. Our game just... starts. The 2-second stationary wait before Step 1 triggers feels dead.

2. **Wave 1 is too passive**: Only zombies (speed 40, the slowest enemy) spawn at 2.0s intervals. In the first 30 seconds, the player sees 3-4 zombies. There is no urgency, no threat, no excitement. VS's first 10 seconds already have 10+ enemies on screen creating visual energy.

3. **No "wow" moment**: The first 30 seconds are purely instructional. There is no spectacle -- no explosion, no screen shake, no dramatic enemy entrance. The first screen shake only occurs on the first kill (intensity 2.0, 0.08s), which is barely perceptible.

### 2.3 Recommendations

| Issue | Fix | Priority | Version |
|---|---|---|---|
| No ceremony on entry | Add a 1-second "3-2-1 GO" countdown before gameplay starts | P2 | v1.0.2 |
| Wave 1 too passive | Reduce Wave 1 spawn interval from 2.0s to 1.5s, or add a "rush" of 3 zombies at t=3s | P3 | v1.1.0 |
| No "wow" moment | First kill should have exaggerated screen shake (4.0, 0.15s) and a damage number popup | P2 | v1.0.2 |
| Tutorial bubble aesthetic | Tutorial bubbles use plain PanelContainer. Add a pulsing glow border to draw attention. | P3 | v1.1.0 |

---

## 3. Minutes 1-3 -- Rhythm and Pacing

### 3.1 Current Flow

| Time | Wave | Player State | Key Events |
|---|---|---|---|
| 0:00-1:00 | Wave 1 (Opening) | 1 weapon (Lv1), learning movement | First level-up at ~25s, second at ~45s |
| 1:00-1:03 | Intermission | 1-2 weapons (Lv1-2) | 3-second pause, wave banner |
| 1:03-2:00 | Wave 2 (Swarm) | 2 weapons (Lv1-2), 1 passive | Bats add speed pressure |
| 2:00-2:03 | Intermission | ~Lv5, possibly Lv3 weapon | 3-second pause |
| 2:03-3:00 | Wave 3 (Darkness) | 2-3 weapons, 2 passives | Skeleton (ranged) + Ghost (phasing) add complexity |

### 3.2 Upgrade Frequency Analysis

Using EXP_TABLE: [0, 8, 12, 18, 24, 32, 42, 55, 70, 88, 108, 132, 160, 195, 240]

| Level | XP Needed | Cumulative XP | Approx. Time to Reach (Normal) | Weapons Owned | Passives Owned |
|---|---|---|---|---|---|
| 2 | 8 | 8 | ~15s | 1 | 0 |
| 3 | 12 | 20 | ~30s | 1 | 0 |
| 4 | 18 | 38 | ~50s | 1-2 | 0-1 |
| 5 | 24 | 62 | ~1:10 | 2 | 0-1 |
| 6 | 32 | 94 | ~1:30 | 2 | 1 |
| 7 | 42 | 136 | ~2:00 | 2-3 | 1-2 |
| 8 | 55 | 191 | ~2:30 | 3 | 2 |
| 9 | 70 | 261 | ~3:00 | 3 | 2-3 |

**Key observation**: The player gets their first upgrade at ~15s (good), second at ~30s (good), but then the gap stretches. By 1:30 they have 2 weapons and 1 passive. This means for the entire Wave 2 (1:03-2:00), they have only 2 weapons, one of which is still Lv1.

### 3.3 The "Flat Middle" Problem

Between levels 4-7 (roughly 50s to 2:00), the player is upgrading existing weapons from Lv1 to Lv2 and collecting 1-2 passives. Each Lv2 upgrade is a marginal +1 count or +0.6 damage. There is no "wow" upgrade moment until:
- Lv3 weapon quality change (requires 3 upgrades of the same weapon, typically achieved at ~2:00-2:30)
- Evolution (requires TWO weapons at Lv3, typically achieved at ~3:30-4:00)

This creates a ~90-second stretch (1:00-2:30) where each level-up feels like a minor stat bump rather than a meaningful power spike.

### 3.4 Wave Transition Pacing

The 3-second intermissions between waves serve their purpose (breathing room, pickup collection), but the current implementation lacks ceremony:

- Wave 1 -> 2: Minor (just adds bats, no visual change)
- Wave 2 -> 3: Moderate (adds skeleton + ghost, ranged threat)
- Wave 3 -> 4: Major (all 7 enemy types + elite)
- Wave 4 -> 5: Climactic (Boss spawn + warning)

The v1.0.1 wave banner spec (wave-transition-refinement.md) addresses this with animated banners and intermission overlays. This is the right fix.

### 3.5 Recommendations

| Issue | Fix | Priority | Version |
|---|---|---|---|
| Flat Lv1->Lv2 upgrades | Lv2 upgrades could include a minor behavioral change (e.g., knife Lv2 = +1 ricochet target instead of +1 count) | P3 | v1.1.0 (design change, affects balance) |
| Upgrade frequency too slow at mid-game | Consider reducing XP requirements for levels 6-8 by 10% (32->29, 42->38, 55->50) | P2 | v1.0.2 (requires balance retest) |
| No power spike before Lv3 | Add "weapon affinity" bonus: at weapon Lv2, gain a small passive boost (+5% damage with that weapon type) | P3 | v1.1.0 |
| Wave 3 adds too many threats simultaneously | Stagger skeleton (Wave 3 start) and ghost (Wave 3, t+20s) introductions | P2 | v1.0.2 |

---

## 4. Minutes 3-5 -- Depth and Differentiation

### 4.1 Current Flow

| Time | Wave | Player State | Key Events |
|---|---|---|---|
| 3:00-3:03 | Intermission | 3 weapons (one Lv3), 2-3 passives | Pre-boss preparation |
| 3:03-4:00 | Wave 4 (Elite) | 3-4 weapons, Lv3 effects active | Elite skeleton + splitter + fire_slime |
| 4:00-4:03 | Intermission | ~Lv9-10, evolution possible | Boss warning at ~3:45 (T-15s) |
| 4:03-5:00 | Wave 5 (Boss) | Evolved weapon(s), full build | Boss fight at maximum pressure |

### 4.2 Weapon Evolution Timing

Evolution requires two weapons at Lv3. Analysis of when this typically occurs:

| Scenario | First Lv3 Weapon | Second Lv3 Weapon | Evolution Available |
|---|---|---|---|
| Early focus (upgrade same weapon) | ~1:30 (Lv5-6) | ~2:30 (Lv8-9) | ~2:30-2:45 |
| Spread (upgrade 3 weapons evenly) | ~2:00 (Lv7) | ~3:30 (Lv11) | ~3:30 |
| Mage (weapon select, optimize) | ~1:20 (Lv4-5) | ~2:15 (Lv7-8) | ~2:15-2:30 |

**Observation**: The earliest possible evolution is ~2:15 (focused Mage). The latest is ~3:30 (spread upgrades). The Boss spawns at ~4:03. This means the player typically has 30-90 seconds with an evolved weapon before the Boss fight. This feels appropriate -- enough time to feel the power spike, not enough to get bored.

### 4.3 Character Differentiation Assessment

| Aspect | Mage | Warrior | Ranger |
|---|---|---|---|
| Starting weapon | Player choice (7 options) | Knife (fixed) | Holy Water (fixed) |
| HP | 8 (standard) | 12 (+50%) | 6 (-25%) |
| Speed | 160 (standard) | 140 (-12.5%) | 190 (+19%) |
| Passive | +20% weapon damage | +1 armor | +12% crit (Keen Eye) |
| Skill | AoE freeze + damage (20s) | Dash stun (15s) | Arrow rain (18s) |
| Play style | Artillery/caster | Melee/tank | Glass cannon |
| Difficulty curve | Smooth (adaptable via weapon choice) | Forgiving early, struggles with speed in late waves | Punishing early, excels in late waves with crit stacking |

**Assessment**: The three characters have distinct numerical profiles and skill identities. However, the in-run experience does not diverge significantly after weapon selection. By mid-game (Lv7+), all three characters have similar weapon pools (3-4 weapons), similar passive stacks, and similar upgrade paths. The character-exclusive passives (10 per character) from character-upgrade-paths.md are designed to address this, and their effectiveness should be validated after v1.0.1 implementation.

### 4.4 The Boss Fight Experience

Boss spawns at ~4:03 with 200 HP (Normal). With an evolved weapon (DPS ~15-25), the expected kill time is:

| Build | DPS vs Boss | Kill Time | Verdict |
|---|---|---|---|
| Single evolved + 2 base | ~20 | ~10s | Good -- feels powerful |
| No evolution (spread upgrades) | ~12 | ~17s | Challenging but doable |
| Mage + 2 evolved | ~35 | ~6s | Fast -- feels dominant |
| Hard mode, single evolved | ~15 | ~24s | Long -- may feel grindy |

The boss fight's 3-phase pattern (charge -> spin -> barrage) creates distinct visual moments. Screen shake on boss spawn (8.0, 0.3s) provides strong ceremony. The boss warning countdown (15s) builds anticipation effectively.

**Potential issue**: In Hard mode, 24 seconds of sustained boss fighting while 70 enemies swarm creates an extremely high-pressure situation. This is by design (Hard should be Hard), but Ranger (4.5 effective HP) may find this nearly impossible without perfect dash usage.

### 4.5 Recommendations

| Issue | Fix | Priority | Version |
|---|---|---|---|
| Mid-game builds converge | Ensure character-exclusive passives appear with high weight in upgrade pool (30% of options) | P1 | v1.0.2 (verify with QA) |
| Hard mode Ranger near-impossible during boss | Consider adding "boss arena clears nearby enemies" effect to give breathing room | P3 | v1.1.0 (design change) |
| Evolution timing feels late for spread builders | Add "evolution hint" UI element showing which weapons are close to Lv3 | P2 | v1.0.2 |
| No visual reward for evolution | Add golden particle burst on weapon evolution, similar to level-up effect | P2 | v1.0.2 |

---

## 5. Repeat Play Motivation -- Meta-Progression Analysis

### 5.1 Current Meta Systems

| System | Scope | Persistence | Motivation Type |
|---|---|---|---|
| Shop | 6 upgrades x 3 levels | Permanent (ConfigFile) | Power fantasy |
| Quests | 14 challenges | Per-run completion | Goal-directed |
| Achievements | 27 milestones | Permanent | Collection / completion |
| Soul Fragments | 30% gold conversion | Permanent -> shop | Grind progression |
| Character variety | 3 characters | Per-run choice | Replay variety |
| Difficulty modes | 4 modes | Per-run choice | Challenge seeking |
| Endless mode | Unlimited survival | Per-run performance | Score chasing |

### 5.2 Economy Cycle Analysis

Average gold per 5-minute run (Normal mode):
- Kill gold: 180 kills * 3 = 540
- Combo bonus: ~30 gold (30 kills at combo >= 5)
- Victory bonus: 50
- Chest purchases: -40 (2 chests at 20 each)
- **Net gold per run**: ~580
- **Soul fragments per run**: 580 * 0.30 = 174

Shop total cost (all 6 upgrades maxed): 875 gold equivalent
**Runs to max shop**: 875 / 174 = ~5 runs

**Assessment**: 5 runs to max the shop is too fast for long-term engagement. VS takes 20-50 runs to feel "complete". However, this is a demo-scale project, and 5 runs is appropriate for the scope. The real retention question is: what happens after the shop is maxed?

### 5.3 The "Post-Shop" Engagement Gap

After ~5 runs, the player has:
- Maxed shop upgrades
- Completed most quests (14 quests across 5 runs is achievable)
- Unlocked maybe 15-20/27 achievements
- Played all 3 characters
- Tried all 4 difficulty modes

At this point, the remaining engagement hooks are:
1. Achievement completion (27 total, ~7-12 remaining)
2. Endless mode personal best
3. Trying different weapon/build combinations

These are weaker hooks than VS's character unlock cascade (30+ characters) or H5's daily events.

### 5.4 Endless Mode as Retention Driver

Endless mode's cycle-based scaling (HP +30%, speed +10%, spawn rate +10% per cycle) creates a natural difficulty ramp:

| Cycle | Time | Enemy HP Mul | Boss HP | Expected Survival |
|---|---|---|---|---|
| 1 | 0-5 min | 1.0x | 200 | Easy (same as Normal) |
| 2 | 5-10 min | 1.3x | 300 | Moderate |
| 3 | 10-15 min | 1.6x | 450 | Hard |
| 4 | 15-20 min | 1.9x | 675 | Very Hard |
| 5 | 20-25 min | 2.2x | 1013 | Extreme |

Most builds will fail around Cycle 3-4 (10-20 minutes). This provides a meaningful endurance challenge but lacks the "discovery" motivation. Each endless run plays similarly because the enemy pool and weapon pool do not change.

### 5.5 Recommendations

| Issue | Fix | Impact | Priority | Version |
|---|---|---|---|---|
| Shop maxes too quickly (5 runs) | Add Tier 4 shop upgrades (cost 160 each, requires Tier 3). Total cost: 875 + 960 = 1835 = ~10 runs | Doubles shop grind | P2 | v1.0.2 |
| No discovery motivation in endless | Add rare enemy variants in Cycle 3+ (e.g., golden zombie = 10x gold, crystal skeleton = 5x XP) | Adds surprise | P3 | v1.1.0 |
| Achievement-only endgame | Implement Weapon Mastery system (v1.0.2 roadmap). Gives per-weapon grind targets | Adds long-term goal | P1 | v1.0.2 |
| No competitive element | Implement Daily Challenge (v1.1.0 roadmap). Seeded RNG, daily conditions | Adds social motivation | P2 | v1.1.0 |
| Build variety limited by small weapon pool | Consider adding 2-3 new base weapons in v1.1.0 (poison dart, energy shield, gravity well) | Expands build space | P3 | v1.1.0 |

---

## 6. Friction Point Summary (Prioritized)

| # | Friction Point | Severity | Phase Affected | Fix | Version |
|---|---|---|---|---|---|
| F1 | No ceremony on arena entry (flat start) | Medium | 0-30s | Countdown animation | v1.0.2 |
| F2 | First kill lacks impact (weak screen shake) | Low | 0-30s | Exaggerated first-kill shake | v1.0.2 |
| F3 | Lv1->Lv2 upgrades feel flat (+stat only) | Medium | 1-3 min | Minor behavioral change at Lv2 | v1.1.0 |
| F4 | Upgrade frequency slows at mid-game | Medium | 1-3 min | Reduce XP curve for levels 6-8 | v1.0.2 |
| F5 | Wave 3 introduces two threats simultaneously | Low | 2-3 min | Stagger skeleton/ghost introduction | v1.0.2 |
| F6 | Builds converge across characters | Medium | 3-5 min | Verify character passive weight in pool | v1.0.2 |
| F7 | No evolution hint UI | Low | 3-5 min | Show weapon proximity to Lv3 | v1.0.2 |
| F8 | Evolution lacks visual spectacle | Low | 3-5 min | Golden particle burst effect | v1.0.2 |
| F9 | Shop maxes in ~5 runs (too fast) | Medium | Meta | Add Tier 4 upgrades | v1.0.2 |
| F10 | No discovery hook in endless mode | Medium | Meta | Rare enemy variants | v1.1.0 |
| F11 | No competitive/social feature | Low | Meta | Daily challenge | v1.1.0 |

---

## 7. Experience Curve Visualization

```
Emotional Intensity
    ^
    |                                          Boss
    |                                         fight
    |                                     ___/--\
    |                     Evolution    ___/       \
    |                    power spike__/            \
    |        Lv3      /                            \
    |      quality  /                               \
    |     change  /   <-- "Flat Middle" -->          \
    |     /      /     (1:00 - 2:30)                  \
    |   /       /                                      \
    | /  Level  \                                      Endless
    |/   ups     \                                    scaling
    +---+----+----+----+----+----+----+----+----+----+------>
    0s  30s  1m   1:30  2m   2:30  3m   4m   5m   7m   10m
         W1       W2         W3         W4   W5/Boss
```

**Key insight**: The "flat middle" between 1:00 and 2:30 is the weakest point of the experience curve. Every other segment has a clear hook (tutorial, wave changes, Lv3 quality change, evolution, boss). The flat middle relies on marginal +stat upgrades to maintain engagement, which is insufficient.

---

## 8. Design Decisions

| Decision | Why | Alternative Considered |
|---|---|---|
| Focus v1.0.2 fixes on F1, F4, F7, F8, F9 | These are the highest-severity items that can be addressed without balance overhaul | Address F3 first (requires weapon system redesign, too risky for patch) |
| Stagger wave 3 threats rather than redesign wave system | Minimal implementation (enemy_spawner timing change) while preserving wave structure | Redesign wave 3 to be longer (changes 300s total, cascading balance issues) |
| Shop Tier 4 as retention fix rather than new game mode | Extends existing system rather than building new one. Cost: ~30 lines in save_manager.gd | Add new game mode (cost: 500+ lines, high regression risk) |
| Weapon Mastery (from v1.0.2 roadmap) addresses meta-progression gap | Per-weapon kill tracking gives 7 grind targets (7 base weapons x 4 mastery tiers = 28 milestones) | More achievements (already have 27, diminishing returns) |
| Do NOT increase XP curve across the board | Current curve is balanced for H5 parity. Targeted reduction at levels 6-8 preserves early pace | Global XP multiplier (too blunt, affects all phases) |

---

## 9. Conclusion

The game delivers a complete and functional survivor experience with strong feature parity to the H5 reference project. The v1.0.1 tutorial system addresses the most critical onboarding gap. The remaining experience issues fall into two categories:

1. **Polish gaps** (ceremony, visual feedback, animation) -- addressed in v1.0.2 roadmap
2. **Depth gaps** (mid-game pacing, meta-progression longevity) -- addressed in v1.0.2 (shop Tier 4, weapon mastery) and v1.1.0 (daily challenge, new content)

The experience curve's weakest point is the "flat middle" (1:00-2:30) where upgrades feel incremental. This is a structural constraint of the Lv3 + evolution system (meaningful power spikes require investment, which takes time). The recommended mitigation is targeted XP curve reduction at levels 6-8, which accelerates the player toward their Lv3 quality change and creates a more engaging mid-game rhythm.
