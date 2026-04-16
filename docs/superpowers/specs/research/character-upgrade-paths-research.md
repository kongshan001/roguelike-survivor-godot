# Research: Character Upgrade Path Differentiation

**Author**: Designer Agent
**Date**: 2026-04-16
**Scope**: Analyze how genre leaders implement character-specific upgrade paths and weapon quality-change levels.

---

## 1. Research Questions

1. How do genre leaders create character-specific upgrade trees within a shared weapon/item pool?
2. What is the standard approach to weapon "quality-change" levels (where weapons gain new behaviors, not just stat boosts)?
3. How many passive choices per character are typical, and how do they gate progression?

---

## 2. Game-by-Game Analysis

### 2.1 Vampire Survivors

**Character Upgrade Paths**
- VS does NOT have character-specific upgrade trees. All characters share the same passive item pool and weapon pool.
- Character differentiation comes from: (a) starting weapon, (b) passive stat bonus (+X% might, +Y area, etc.), (c) number of max weapons.
- The "arcana" system (added post-launch) lets players pick global modifiers that affect all characters, but some arcana pair better with specific characters.
- Key takeaway: VS relies on weapon/evolution diversity, not character-specific upgrades.

**Weapon Level-Up**
- Weapons have 8 levels. Levels 1-7 are +count/+damage/+area/+speed (quantitative).
- Level 8 is often a small quality change (e.g., Whip Lv8 gains +25% damage; Holy Water Lv8 doubles duration).
- Evolution (not level-up) is the primary quality-change mechanism -- evolved weapons gain entirely new behaviors.

### 2.2 Brotato

**Character Upgrade Paths**
- Brotato characters have dramatically different base stats and constraints, but share the same item pool.
- Some characters have unique mechanics that interact with specific items: "Crazy" benefits from random items, "One Armed" stacks weapons higher.
- No character-specific item trees -- the differentiation is in which items are worth buying for each character.
- Key takeaway: Brotato achieves differentiation through stat constraints and economy, not exclusive upgrade paths.

**Weapon Level-Up**
- Weapons have 4 tiers (Common/Uncommon/Rare/Epic). Higher tiers are purely stat upgrades.
- No quality-change levels -- a Common Knife and an Epic Knife behave identically, just with different numbers.

### 2.3 HoloCure

**Character Upgrade Paths**
- Each character has a unique main weapon that levels up independently.
- Characters share the common item/stamp pool, but stamps interact differently with each character's unique weapon.
- No character-exclusive passive choices during leveling.
- Key takeaway: HoloCure differentiates through the unique weapon + stamp interactions, not character-specific passives.

**Weapon Level-Up**
- Weapons have 7 levels. Level 1-6 are stat boosts.
- Level 7 is often a minor behavior change (slight AoE increase, extra projectile, etc.).
- Stamp evolution is the main quality-change mechanism.

### 2.4 Soulstone Survivors

**Character Upgrade Paths**
- Each character class has unique skills that can be unlocked during a run.
- The upgrade pool includes both shared weapons AND class-specific skill upgrades.
- This is the closest genre analogue to "character-specific upgrade trees."
- Key takeaway: Mixing shared + exclusive upgrades in the same pool works well when exclusive options are clearly marked.

---

## 3. Key Findings

| Finding | Source | Applicability |
|---|---|---|
| Character-specific passives in the upgrade pool are rare in genre | VS, Brotato, HoloCure | We can pioneer this feature to differentiate our small roster |
| Quality-change weapon levels (not just stat boosts) exist but are usually minor | VS (Lv8), HoloCure (Lv7) | We can make Lv3 our "quality-change" level with a more dramatic effect |
| Exclusive upgrades work best when clearly marked and thematically coherent | Soulstone Survivors | Character-exclusive passives should have visual branding (color/icon) |
| 3-5 choices per path is the sweet spot for meaningful branching without overwhelming | Genre average | Our 3-char, 3-5 passives per path fits perfectly |
| Path choices should interact with but not be required for evolution | VS evolution system | Paths enhance weapons but should not gate evolution |

---

## 4. Conclusion

The genre does NOT have a strong precedent for character-specific upgrade paths within a shared pool. VS and Brotato rely on starting conditions; HoloCure relies on unique weapons. Only Soulstone Survivors uses class-specific skill upgrades during a run.

This represents an **innovation opportunity** for our project. With only 3 characters (vs 30-60 in competitors), character-specific passive paths can dramatically increase per-character depth without adding new characters.

For weapon quality-change levels: VS and HoloCure use their max weapon level (Lv7-8) for minor behavior changes. Since our weapons cap at Lv3, we should make Lv3 the "quality-change" level with a more impactful transformation (new status effect, behavior modifier, or area change) -- proportionally scaled to our shorter level range.

---

## 5. References

- Vampire Survivors (poncle, 2022) -- weapon evolution system, character stat bonuses
- Brotato (Blobfish, 2023) -- character stat constraints, shared item pool
- HoloCure (KayAnimate, 2023) -- unique character weapons, stamp system
- Soulstone Survivors (Game Smithing, 2022) -- class-specific skill upgrades
- H5 Project -- `/Users/ks_128/Documents/h5_demo/src/core/config.js` CHARACTERS, WEAPONS, PASSIVES
