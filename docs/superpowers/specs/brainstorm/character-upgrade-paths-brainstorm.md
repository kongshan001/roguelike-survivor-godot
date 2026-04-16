# Brainstorm: Character Upgrade Path Differentiation

**Author**: Designer Agent
**Date**: 2026-04-16
**Related Research**: `docs/superpowers/specs/research/character-upgrade-paths-research.md`

---

## 1. Problem Statement

Current upgrade system:
- 3 characters share the same 7 passive items (speedboots, armor, magnet, crit, maxhp, regen, luckycoin)
- Weapon upgrades are purely quantitative (+count, +damage, +pierce)
- No character-exclusive choices during a run
- Each character plays almost identically after the first 2 minutes once they pick up shared passives

Goal: Create character-specific upgrade paths that meaningfully differentiate playstyle within a single run, while keeping the shared pool as the backbone.

---

## 2. Innovation Proposals

### Proposal A: Dual-Path Exclusive Passives (SELECTED)

**Core Idea**: Each character has 2 thematic "paths" with 3-5 exclusive passives each. When the player levels up, character-exclusive passives appear alongside shared pool options. Each path passive is only available if the character matches. Paths are not mutually exclusive -- the player can mix and match.

**Structure**:
- Mage: Mana Flow (AOE + sustain) vs Elementalist (single-target + status stacking)
- Warrior: Titan (tank + sustain) vs Berserker (risk/reward + speed)
- Ranger: Marksman (projectiles + pierce) vs Assassin (crit + burst)

**Integration**: New `"character_passive"` type in upgrade_pool, filtered by `GameManager.selected_character`.

**Feasibility**:
| Dimension | Score | Reason |
|---|---|---|
| Technical cost | Low | Add new passive entries to upgrade_pool.gd, add match cases to player.gd apply_passive() |
| Balance difficulty | Medium | 30 new passives (3 chars x 2 paths x 5 passives) need tuning; but each is small scope |
| Player understanding | Medium | Needs clear UI labeling ("Mage Exclusive") but concept is intuitive |

---

### Proposal B: Path Commitment System

**Core Idea**: At character level 5, the player commits to one of two paths. The chosen path unlocks a chain of 5 exclusive passives that appear in subsequent level-ups. The unchosen path becomes permanently unavailable for that run.

**Problem**: Too rigid. A wrong choice at level 5 cannot be corrected. Creates analysis paralysis for new players.

**Feasibility**:
| Dimension | Score | Reason |
|---|---|---|
| Technical cost | Medium | Need a "path selection" UI event + state tracking |
| Balance difficulty | High | Two separate balance trees per character, must be equally viable |
| Player understanding | Low | "Which path do I pick?" with no prior experience is frustrating |

**Verdict**: Rejected. Too rigid for a 5-minute game session. Better to let players freely pick from both paths.

---

### Proposal C: Weapon Mastery Specialization

**Core Idea**: Instead of character passives, each weapon type has a "mastery" passive chain. When you use a weapon enough (e.g., 50 kills with knife), you unlock knife-exclusive passives. Characters start with affinity toward certain weapon types.

**Problem**: Kill-tracking during a run adds complexity. Our 5-minute runs may not provide enough kills for mastery to feel meaningful. Also does not differentiate characters directly.

**Feasibility**:
| Dimension | Score | Reason |
|---|---|---|
| Technical cost | High | Kill attribution tracking per weapon, mastery thresholds, state persistence |
| Balance difficulty | High | 7 weapon types x mastery chain = 7 balance trees |
| Player understanding | Low | Hidden mechanic, hard to communicate |

**Verdict**: Rejected. Too complex for the current system. Could be a future enhancement.

---

### Proposal D: Quality-Change Weapon Levels at Lv3

**Core Idea**: Instead of character-specific passives, make each weapon's Lv3 upgrade a dramatic behavior change rather than a stat boost. For example: Holy Water Lv3 adds freeze on hit; Knife Lv3 adds ricochet; Lightning Lv3 adds chain-on-kill.

**Problem**: This is orthogonal to character differentiation (all characters benefit equally). Should be designed as a companion feature, not a replacement.

**Feasibility**:
| Dimension | Score | Reason |
|---|---|---|
| Technical cost | Medium | Each weapon type needs custom Lv3 behavior in weapon_fire.gd |
| Balance difficulty | Medium | 7 base weapons x 1 behavior each |
| Player understanding | High | "My weapon got a cool new ability at max level!" is universally understood |

**Verdict**: Selected as companion feature alongside Proposal A.

---

### Proposal E: Character-Specific Evolution Variants

**Core Idea**: When a Warrior evolves knife+firestaff, they get a different evolved weapon than when a Mage does. Same recipe, different result based on character.

**Problem**: Requires 3x evolution variants for each recipe. 8 recipes x 3 characters = 24 evolved weapons. Too many to balance and implement.

**Feasibility**:
| Dimension | Score | Reason |
|---|---|---|
| Technical cost | Very High | 24 new evolved weapons, each needing unique behavior |
| Balance difficulty | Very High | 24-way balance matrix |
| Player understanding | Medium | "Same recipe gives different result" is confusing |

**Verdict**: Rejected. Scope explosion. Could revisit for 1-2 high-profile evolutions in future.

---

## 3. Convergence

**Selected**: Proposal A (Dual-Path Exclusive Passives) + Proposal D (Quality-Change Weapon Lv3)

**Rationale**:
- Proposal A provides the character differentiation we need without being too rigid (no path commitment)
- Proposal D adds excitement to the existing weapon level-up system without requiring new systems
- Together they create two axes of differentiation: WHO you play (character passives) and WHAT you use (weapon quality-change)

**Not selected but preserved**:
- Proposal C (Weapon Mastery) -- future enhancement for longer sessions or endless mode
- Proposal E (Character Evolutions) -- could be revisited for 2-3 signature evolutions

---

## 4. Feasibility Assessment Summary

| Proposal | Tech Cost | Balance Risk | Player UX | Verdict |
|---|---|---|---|---|
| A: Dual-Path Exclusive Passives | Low | Medium | Medium | SELECTED |
| B: Path Commitment | Medium | High | Low | Rejected |
| C: Weapon Mastery | High | High | Low | Future |
| D: Quality-Change Lv3 | Medium | Medium | High | SELECTED (companion) |
| E: Character Evolutions | Very High | Very High | Medium | Rejected |
