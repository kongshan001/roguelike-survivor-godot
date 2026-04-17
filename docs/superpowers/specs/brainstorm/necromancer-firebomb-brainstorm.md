# Necromancer + Firebomb Brainstorm

**Date**: 2026-04-18
**Round**: R33
**Topic**: 4th character design alternatives + 8th weapon type alternatives

---

## 1. Character Concepts (5 proposals)

### Concept A: Necromancer (Kill Scaler) -- SELECTED

- Core: Every 100 kills = +2% damage. Skill damage scales with kills.
- Passive: Kill-based damage scaling
- Skill: Death Pulse (kill-based AoE)
- Starting weapon: frostaura
- Pros: Unique "momentum" playstyle, high skill expression, rewards aggressive play
- Cons: Weak early game, complex balance, Endless mode scaling risk
- Feasibility: Implementation ~150 lines. Balance: Medium difficulty (cap needed). Player understanding: High (kill counter visible).

### Concept B: Alchemist (Potion Mix)

- Core: Collecting XP gems fills "potion meter". Activate to create random buff zone.
- Passive: Potion effects last longer
- Skill: Throw potion that creates random buff/debuff zone
- Starting weapon: knife
- Pros: Randomness adds replayability, visually distinct
- Cons: Randomness can feel unfair, "random buff" is hard to balance, overlaps with chest system
- Feasibility: Implementation ~250 lines (random effect table). Balance: High difficulty. Player understanding: Medium.

### Concept C: Paladin (Holy Warrior)

- Core: Consecration aura that damages enemies and heals player simultaneously.
- Passive: Heal on kill (1 HP per 50 kills)
- Skill: Consecration field (large heal + damage zone)
- Starting weapon: bible
- Pros: Tank-healer hybrid, simple to understand
- Cons: Overlaps with Warrior (tank) and frostaura (aura), heal mechanic may be too strong in Endless
- Feasibility: Implementation ~120 lines. Balance: Medium. Player understanding: Very high.

### Concept D: Shadow (Stealth Assassin)

- Core: Periodically becomes invisible. Next attack from stealth deals 3x damage.
- Passive: 10% dodge chance
- Skill: Shadow step (teleport + invisibility + damage burst)
- Starting weapon: knife
- Pros: High skill ceiling, "ninja" fantasy, dodge adds variety
- Cons: Stealth system is complex to implement (enemy AI changes), 3x burst damage hard to balance
- Feasibility: Implementation ~300 lines (AI changes + stealth system). Balance: High difficulty. Player understanding: Medium.

### Concept E: Elementalist (Switching Stances)

- Core: Press Q to cycle between Fire/Ice/Lightning stances. Each stance buffs different weapons.
- Passive: Stance-switching gives 2s of dual-element bonus
- Skill: Element burst (effect depends on current stance)
- Starting weapon: firestaff
- Pros: Extreme versatility, high mastery ceiling
- Cons: Q key cycling adds input complexity, 3 stances = 3x balance work, overlaps with Mage (element theme)
- Feasibility: Implementation ~400 lines (3 stance systems). Balance: Very high difficulty. Player understanding: Low (hard to explain in tooltip).

### Concept Selection

**Selected: Concept A (Necromancer)**

| Criteria | A | B | C | D | E |
|----------|---|---|---|---|---|
| Uniqueness vs existing 3 chars | 5 | 4 | 2 | 4 | 3 |
| Implementation simplicity | 4 | 2 | 4 | 1 | 1 |
| Balance predictability | 3 | 2 | 3 | 2 | 1 |
| Player understanding | 4 | 3 | 5 | 3 | 2 |
| Replay value | 5 | 4 | 3 | 4 | 4 |
| **Total** | **21** | **15** | **17** | **14** | **11** |

Concept A scores highest because: (1) kill-scaling is genuinely unique in the genre, (2) implementation is straightforward (~150 lines), (3) the kill counter is a natural progression metric players already understand.

---

## 2. Firebomb Weapon Concepts (3 proposals)

### Concept A: Thrown Flask (Parabolic Arc + Fire Pool) -- SELECTED

- Attack: Throw flask in parabolic arc, creates fire pool at landing point
- Evolution: firebomb + lightning = thunderbomb (electric pool + chain lightning)
- Pros: New "throwing" weapon type, area denial, visually distinct arc
- Cons: Parabolic math needed, pool persistence requires new script
- DPS model: Tick-based damage in persistent zone

### Concept B: Molotov Chain (Bouncing Throw)

- Attack: Throw flask that bounces 3 times, each bounce creates a small fire pool
- Evolution: firebomb + lightning = chain lightning between pools
- Pros: Chain bouncing is visually exciting, covers wide area
- Cons: Bounce physics complex, hard to predict landing points, player has no control over bounce targets
- Rejected: Player agency is too low -- the weapon decides where pools appear

### Concept C: Napalm Stream (Continuous Spray)

- Attack: Hold to spray napalm in a cone, enemies caught take continuous damage
- Evolution: firebomb + lightning = electrified spray with stun
- Pros: Continuous damage feels powerful, directional control
- Cons: Overlaps with firestaff (cone fire), "hold to attack" conflicts with auto-attack philosophy
- Rejected: Auto-attack is the game's core identity -- manual spray breaks the paradigm

### Concept Selection

**Selected: Concept A (Thrown Flask)**

Concept A is the only option that introduces a genuinely new weapon behavior (parabolic throw + persistent pool). Concept B reduces player agency. Concept C conflicts with the auto-attack system and overlaps with firestaff.

---

## 3. Feasibility Assessment

### Necromancer Implementation

| Component | Lines | Risk | Dependencies |
|-----------|-------|------|-------------|
| character_select.gd | +7 | Low | Sprite asset |
| player.gd (kill bonus) | +15 | Low | None |
| skill_effects.gd (death pulse) | +30 | Medium | None |
| hud.gd (skill icon) | +2 | Low | None |
| save_manager.gd (achievements) | +8 | Low | None |
| **Total** | **~62** | | |

### Firebomb Implementation

| Component | Lines | Risk | Dependencies |
|-----------|-------|------|-------------|
| upgrade_pool.gd (registration) | +30 | Low | None |
| weapon_registry.gd (evolution) | +1 | Low | None |
| weapon_data.gd (new fields) | +8 | Low | None |
| thrown_flask.gd (new script) | ~60 | Medium | Parabolic math |
| fire_pool.gd (new script) | ~50 | Medium | Area tick damage |
| save_manager.gd (mastery) | +5 | Low | None |
| **Total** | **~154** | | |

### Combined Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| Kill-scaling too strong in Endless | Medium | Hard cap at +20% (1000 kills) |
| Death Pulse one-shots elites at high kills | Low | Intentional -- "power moment" design |
| Firebomb pool performance (many pools) | Low | Max 3 simultaneous pools, auto-cleanup |
| Parabolic arc feels inaccurate | Medium | Generous landing radius, auto-targeting nearest enemy |
| Necromancer early game too weak | Low | Frostaura provides crowd control during ramp |

---

*Brainstorm completed R33*
