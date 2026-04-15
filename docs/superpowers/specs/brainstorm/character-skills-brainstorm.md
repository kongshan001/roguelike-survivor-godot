# Brainstorm: Character Active Skills

**Author**: Designer Agent
**Date**: 2026-04-16
**Scope**: Design active skills for Mage/Warrior/Ranger to break gameplay homogenization.

---

## Problem Statement

Current 3 characters (mage/warrior/ranger) differ only in stat distribution (HP/speed/damage_bonus), starting weapon, and one passive modifier (warrior: +1 armor, ranger: +10% crit, mage: +20% damage). Competitive analysis (see `research/competitive-analysis.md`) identifies this as a HIGH gap -- genre leaders like HoloCure give each character a unique active skill on a cooldown, creating dramatically different play experiences.

**Goal**: Add 1 active skill + 1 passive trait per character. Skills trigger via UI button / hotkey (E key). Skills have cooldowns that do not disrupt the auto-attack flow.

---

## Brainstorm Proposals

### Proposal 1: "Elemental Burst" Suite

Each character gets a themed burst ability:

- **Mage -- Arcane Explosion**: AoE burst centered on player position. Deals damage in a radius, brief freeze.
- **Warrior -- Shield Charge**: Dash forward, damaging and knocking back enemies in path. Defensive repositioning tool.
- **Ranger -- Arrow Rain**: Targeted AoE at cursor/nearest enemy cluster. Ranged damage zone.

**Pros**: Clean thematic alignment, each skill serves a different tactical role (defensive AoE / offensive dash / ranged zone).
**Cons**: "Targeted at cursor" requires new input mapping; risk of overshadowing existing weapons.

**Feasibility**:
| Dimension | Score (1-5) | Notes |
|---|---|---|
| Technical cost | 3 | AoE detection + dash mechanic + targeting system |
| Balance difficulty | 4 | Burst damage must not outpace weapon DPS |
| Player understanding | 2 | Simple: "press E, thing happens" |

---

### Proposal 2: "Stance Switch" Suite

Each character toggles between two modes:

- **Mage**: Flame stance (more damage) / Frost stance (more slow). Toggle on cooldown.
- **Warrior**: Offensive stance (+50% damage, -25% armor) / Defensive stance (+3 armor, -25% damage).
- **Ranger**: Rapid fire (double fire rate, half damage) / Power shot (half fire rate, double damage).

**Pros**: Adds a strategic layer; permanently changes the play feel.
**Cons**: Complex to balance two sets of modifiers per character; confusing for new players; requires ongoing UI display of current stance.

**Feasibility**:
| Dimension | Score (1-5) | Notes |
|---|---|---|
| Technical cost | 4 | Modifier system, UI state display |
| Balance difficulty | 5 | Two states per character = 6 balance points |
| Player understanding | 4 | "Which stance am I in?" confusion |

---

### Proposal 3: "Single Signature Move" Suite

Each character gets one powerful signature move:

- **Mage -- Meteor Strike**: After 0.5s cast delay, a meteor falls at player position, dealing massive AoE damage and leaving a burn zone for 3s.
- **Warrior -- War Cry**: Buff self and nearby allies: +50% damage, +2 armor for 5 seconds. Defensive and offensive combined.
- **Ranger -- Shadow Step**: Teleport 150px in movement direction, becoming invulnerable for 0.3s. Pure mobility/defensive.

**Pros**: Each ability is distinct and has clear use cases. Meteor is nuke, War Cry is sustain, Shadow Step is survival.
**Cons**: Mage meteor overlaps with existing firestaff cone; War Cry "allies" not relevant in single-player; Shadow Step overlaps with existing dash (Space).

**Feasibility**:
| Dimension | Score (1-5) | Notes |
|---|---|---|
| Technical cost | 3 | AoE + buff system + teleport |
| Balance difficulty | 3 | Long cooldowns keep them from dominating |
| Player understanding | 2 | One button, clear effect |

---

### Proposal 4: "Resource Builder" Suite

Skills generate a unique resource that enhances the character:

- **Mage -- Mana Surge**: Charge up over 1s, release to deal AoE proportional to charge time. Resource = mana bar.
- **Warrior -- Rage Counter**: Block next hit (0.5s window), if hit, counter-attack for 3x damage. Resource = rage stacks.
- **Ranger -- Focus Shot**: Next 3 weapon attacks have +100% crit. Resource = focus charges.

**Pros**: Adds a mini-game within each character; high skill ceiling.
**Cons**: Adds complexity; charge-up requires standing still (anti-fun in bullet-hell); block timing is punishing.

**Feasibility**:
| Dimension | Score (1-5) | Notes |
|---|---|---|
| Technical cost | 5 | New resource bars, charge mechanics, counter system |
| Balance difficulty | 5 | Skill-dependent power is hard to tune |
| Player understanding | 4 | "Charge/release" + "timing" + "charges" are all different |

---

### Proposal 5: "Summon / Pet" Suite

Each character summons a temporary companion:

- **Mage -- Ice Golem**: Summons a stationary golem that slows nearby enemies for 8s.
- **Warrior -- Phantom Shield**: Creates a rotating shield that blocks enemy projectiles for 5s.
- **Ranger -- Decoy**: Places a decoy that attracts enemies for 4s, then explodes.

**Pros**: Visually distinct, adds tactical depth (placement matters).
**Cons**: Summon AI is technically complex; performance concern with additional entities; overlap with orbit weapons (bible/holywater).

**Feasibility**:
| Dimension | Score (1-5) | Notes |
|---|---|---|
| Technical cost | 5 | AI, pathfinding, entity management |
| Balance difficulty | 4 | Duration + effect tuning |
| Player understanding | 3 | "Where did my golem go?" |

---

## Convergence: Selected Proposals

**Selected: Proposal 1 (Elemental Burst Suite) with elements from Proposal 3**

Rationale:
1. Thematic clarity: each character's skill matches their identity (Mage=AoE nuke, Warrior=charge, Ranger=arrow rain)
2. Simple input model: single keypress (E), immediate effect, cooldown-based
3. Does not conflict with existing dash (Space key) or auto-attack system
4. Moderate implementation cost -- reuses existing Area2D/projectile systems
5. Clear balance lever: cooldown duration is the primary tuning knob

**Final skill selection**:
- **Mage -- Elemental Burst**: Centered AoE explosion. Damages and freezes all enemies in radius.
- **Warrior -- Shield Charge**: Directional dash that damages and stuns enemies in path.
- **Ranger -- Arrow Rain**: Rains arrows in a targeted area around the nearest enemy cluster.

**Passive trait selection** (one per character, stacking with existing stat bonuses):
- **Mage -- Mana Attunement**: +10% weapon damage while skill is off cooldown (reward for NOT using skill immediately)
- **Warrior -- Iron Will**: When HP drops below 30%, gain +2 armor for 3 seconds (once per life or per 30s)
- **Ranger -- Keen Eye**: Every 5th weapon hit is a guaranteed crit (independent of crit_chance stat)

---

## Feasibility Summary

| Character | Skill | Technical | Balance | Understanding | Overall |
|---|---|---|---|---|---|
| Mage | Elemental Burst | Low (AoE Area2D) | Medium (damage tuning) | Low (press E, boom) | GO |
| Warrior | Shield Charge | Medium (directional dash + collision) | Medium (dash distance + stun) | Low (press E, charge) | GO |
| Ranger | Arrow Rain | Medium (multi-projectile spawn) | Medium (damage per arrow + count) | Low (press E, rain) | GO |

All three skills can reuse existing systems:
- Mage burst: reuse frostaura's Area2D detection
- Warrior charge: reuse player dash + enemy collision
- Ranger rain: reuse knife projectile spawning with modified trajectory
