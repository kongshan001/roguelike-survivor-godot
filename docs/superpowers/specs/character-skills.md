# Character Active Skills Design Spec

**Author**: Designer Agent
**Date**: 2026-04-16
**Priority**: P2 HIGH
**Status**: Design Complete
**Brainstorm**: `docs/superpowers/specs/brainstorm/character-skills-brainstorm.md`
**Competitive Reference**: `docs/superpowers/specs/research/competitive-analysis.md` (Section 3.1, Gap: Character Differentiation)

---

## 1. Design Overview

Currently, the 3 characters (Mage, Warrior, Ranger) differ only in stat distribution (HP/speed/damage_bonus), starting weapon, and one passive modifier (warrior +1 armor, ranger +10% crit, mage +20% damage). This is below genre standard -- HoloCure gives each character a unique active skill, Brotato gives each dramatically different mechanics, and even Vampire Survivors differentiates via starting weapon + stat bonus.

This spec adds **1 active skill + 1 passive trait** per character. The active skill is triggered by pressing **E key** (or tapping a UI button on the HUD). Skills have cooldowns (15-25 seconds) so they complement but do not replace the auto-attack weapon system. The passive trait is always-on and stacks with existing character bonuses.

**Why this design**: HoloCure's character-specific active ability is the genre's best practice for character differentiation. A single cooldown-based ability per character creates a "power moment" that breaks the auto-attack monotony without requiring a new resource system. The passive trait provides a subtle always-on differentiator that rewards mastery of each character's play pattern.

---

## 2. Skill Definitions

### 2.1 Mage -- Elemental Burst

**Description**: The Mage unleashes a burst of arcane energy centered on their position, dealing damage and briefly freezing all enemies in a large radius. A quintessential "nuke" ability for when enemies surround the player.

**Activation**: Press E key. Immediate effect, no cast time.

**Visual**: Expanding ring of blue-white energy (ColorRect circle, grows from player size to full radius over 0.2s). Frozen enemies tint blue for the freeze duration. Screen shake intensity 4.0 for 0.15s.

#### Numerical Constants

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| `MAGE_SKILL_ID` | `"elemental_burst"` | string | |
| `MAGE_SKILL_COOLDOWN` | 20.0 | seconds | Long cooldown, powerful effect |
| `MAGE_SKILL_DAMAGE` | 15.0 | HP | Raw damage before damage_bonus |
| `MAGE_SKILL_RADIUS` | 150.0 | pixels | AoE radius centered on player |
| `MAGE_SKILL_FREEZE_DURATION` | 1.5 | seconds | Enemies frozen in place |
| `MAGE_SKILL_EXPAND_TIME` | 0.2 | seconds | Visual expansion duration |
| `MAGE_SKILL_SCREENSHAKE` | 4.0 | intensity | |
| `MAGE_SKILL_SCREENSHAKE_DUR` | 0.15 | seconds | |

#### Passive Trait: Mana Attunement

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| `MAGE_PASSIVE_ID` | `"mana_attunement"` | string | |
| `MAGE_PASSIVE_DAMAGE_BONUS` | 0.10 | multiplier | +10% weapon damage while skill is off cooldown |

**Behavior**: While the Mage's Elemental Burst is on cooldown (i.e., has been used and is recharging), all weapon damage is increased by 10%. This creates an interesting decision: save the burst for emergencies and keep the damage bonus, or use it immediately for burst damage and lose the bonus during cooldown. The bonus applies to all weapon types (projectile, orbit, lightning, cone, aura, boomerang).

**Why this passive**: It rewards strategic skill usage. A player who never uses the skill gets +10% damage permanently, which is good but misses the burst utility. A player who spams the skill on cooldown gets powerful bursts but sacrifices sustained DPS during recharge. The optimal play is to hold the skill until surrounded, maximizing both the burst value and the sustained bonus uptime.

---

### 2.2 Warrior -- Shield Charge

**Description**: The Warrior dashes forward in the current movement direction, damaging and stunning all enemies in their path. The dash is longer and more powerful than the regular Space dash, but has a much longer cooldown.

**Activation**: Press E key. Dash direction = current movement direction. If stationary, dashes in the direction the player last moved.

**Visual**: Red streak trail (3 afterimages, larger than normal dash). Enemies hit flash white for 0.1s, then show stun stars (small spinning ColorRect) for stun duration. Screen shake intensity 3.0 for 0.1s.

#### Numerical Constants

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| `WARRIOR_SKILL_ID` | `"shield_charge"` | string | |
| `WARRIOR_SKILL_COOLDOWN` | 15.0 | seconds | Shorter cooldown than Mage; more frequent use |
| `WARRIOR_SKILL_DAMAGE` | 10.0 | HP | Lower raw damage than Mage burst |
| `WARRIOR_SKILL_DISTANCE` | 160.0 | pixels | Dash distance (vs 80px for normal dash) |
| `WARRIOR_SKILL_DURATION` | 0.25 | seconds | Dash movement duration |
| `WARRIOR_SKILL_WIDTH` | 40.0 | pixels | Collision width of charge path |
| `WARRIOR_SKILL_STUN_DURATION` | 2.0 | seconds | Enemies stunned (cannot move/attack) |
| `WARRIOR_SKILL_SCREENSHAKE` | 3.0 | intensity | |
| `WARRIOR_SKILL_SCREENSHAKE_DUR` | 0.1 | seconds | |

#### Passive Trait: Iron Will

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| `WARRIOR_PASSIVE_ID` | `"iron_will"` | string | |
| `WARRIOR_PASSIVE_ARMOR_BONUS` | 3 | armor | Temporary armor when low HP |
| `WARRIOR_PASSIVE_HP_THRESHOLD` | 0.30 | fraction | Triggers at HP <= 30% |
| `WARRIOR_PASSIVE_DURATION` | 3.0 | seconds | Armor bonus lasts 3 seconds |
| `WARRIOR_PASSIVE_COOLDOWN` | 30.0 | seconds | Cannot re-trigger for 30s after expiring |

**Behavior**: When the Warrior's current HP drops to or below 30% of max HP, gain +3 armor for 3 seconds. This can only trigger once every 30 seconds. The armor stacks with existing armor stat and the armor_maxhp synergy.

**Why this passive**: It reinforces the Warrior's tank identity. At low HP, the Warrior becomes temporarily harder to kill, creating a "last stand" feel. The 30-second cooldown prevents abuse -- it is a safety net, not a permanent buff. The +3 armor on a character that starts with +1 armor (and can stack more via passive items) means the Warrior can briefly become nearly invulnerable, which fits the fantasy.

---

### 2.3 Ranger -- Arrow Rain

**Description**: The Ranger calls down a rain of arrows in a targeted area around the densest enemy cluster. Multiple arrows fall over the area, each dealing damage individually.

**Activation**: Press E key. Automatically targets the nearest enemy cluster (center of mass of the 5 closest enemies within 300px range). If no enemies are in range, targets 200px ahead of the player's facing direction.

**Visual**: Yellow warning circle appears on target area for 0.3s, then 12 arrows rain down over 0.5s. Each arrow is a small white ColorRect (4x12 pixels) falling from above. Impact creates small white flash. Screen shake intensity 2.0 for 0.08s on first impact.

#### Numerical Constants

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| `RANGER_SKILL_ID` | `"arrow_rain"` | string | |
| `RANGER_SKILL_COOLDOWN` | 18.0 | seconds | |
| `RANGER_SKILL_DAMAGE_PER_ARROW` | 5.0 | HP | Per arrow; total potential = 60 |
| `RANGER_SKILL_ARROW_COUNT` | 12 | count | Number of arrows in the rain |
| `RANGER_SKILL_RADIUS` | 100.0 | pixels | Radius of the rain area |
| `RANGER_SKILL_TARGET_RANGE` | 300.0 | pixels | Range to search for enemy clusters |
| `RANGER_SKILL_FALL_DURATION` | 0.5 | seconds | Duration of arrow fall |
| `RANGER_SKILL_ARROW_SIZE` | 4.0 | pixels | Arrow width (4x12 rect) |
| `RANGER_SKILL_WARNING_TIME` | 0.3 | seconds | Yellow circle shown before arrows |
| `RANGER_SKILL_SCREENSHAKE` | 2.0 | intensity | |
| `RANGER_SKILL_SCREENSHAKE_DUR` | 0.08 | seconds | |

#### Passive Trait: Keen Eye

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| `RANGER_PASSIVE_ID` | `"keen_eye"` | string | |
| `RANGER_PASSIVE_HIT_COUNT` | 5 | hits | Every Nth weapon hit |
| `RANGER_PASSIVE_GUARANTEED_CRIT` | true | boolean | Nth hit is always a crit |

**Behavior**: Every 5th weapon hit (from any weapon) is guaranteed to be a critical hit, regardless of the player's crit_chance stat. This counter persists across weapon swaps and is independent of the crit_chance stat. The 5th hit uses the standard crit damage multiplier (2.0x base, modified by luckycoin).

**Why this passive**: It rewards the Ranger's fast-attack playstyle. The Ranger starts with holywater (orbit weapon that hits frequently) and has the highest move speed, meaning the Ranger is always in range to hit things. A guaranteed crit every 5 hits synergizes with rapid-fire weapons (knife, holywater) more than slow weapons (lightning), which matches the Ranger's intended weapon preferences. With crit_chance items, the Ranger can reach extremely high effective crit rates (10% base + 24% from 3x crit rings + ~20% from keen eye = ~54% effective crit rate).

---

## 3. Skill System Architecture

### 3.1 Input Mapping

| Input Action | Key | Notes |
|---|---|---|
| `skill` | E | Triggers character active skill |

This must be added to the Godot Input Map in Project Settings.

### 3.2 HUD Skill Button

A skill button is displayed on the HUD, bottom-right corner, showing the skill icon and a cooldown overlay.

```
+------------------------------------------------------------------+
|                                                                  |
|                        (Game Area)                                |
|                                                                  |
|                                                                  |
|                                                                  |
|                                              [HP] [XP] [Gold]   |
|                                              [Dash CD bar]      |
|                                              [SKILL icon]        |
|                                              (E) cooldown       |
+------------------------------------------------------------------+
```

#### Skill Button Constants

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| `SKILL_BUTTON_SIZE` | 48 | pixels | Square button |
| `SKILL_BUTTON_POSITION` | bottom-right | anchor | Offset: -60px right, -80px up from bottom |
| `SKILL_COOLDOWN_COLOR` | Color(0, 0, 0, 0.6) | Color | Dark overlay during cooldown |
| `SKILL_READY_COLOR` | Color(1, 0.85, 0.3) | Color | Gold border when ready |

### 3.3 State Machine

```
+-----------+
| READY     |  (skill usable, HUD shows gold border)
+-----------+
     |
     | E key pressed AND character matches skill owner
     v
+-----------+
| CASTING   |  (skill effect fires, cooldown starts)
+-----------+
     |
     | Skill effect completes (instant for burst/charge, 0.5s for arrow rain)
     v
+-----------+
| COOLDOWN  |  (timer counting down, HUD shows dark overlay)
+-----------+
     |
     | cooldown_timer <= 0
     v
+-----------+
| READY     |
+-----------+
```

---

## 4. Integration Map

### 4.1 Files to Modify

| File | Change | Scope |
|---|---|---|
| `scripts/player.gd` | Add skill state machine (skill_id, skill_cooldown, skill_timer, passive tracking). Add `_process_skill_input()`, `_activate_skill()`, `_update_skill_cooldown()`. Add keen_eye hit counter for Ranger. Add iron_will trigger for Warrior. Add mana_attunement damage multiplier for Mage. | ~80 lines |
| `scripts/weapon_controller.gd` | Apply mana_attunement damage bonus to `_fire_weapon()`. Increment keen_eye counter on each weapon hit. | ~15 lines |
| `scripts/hud.gd` | Add skill button (TextureButton or ColorRect), cooldown overlay, key label. Connect to skill state signals. | ~40 lines |
| `scenes/hud.tscn` | Add SkillButton node | Scene edit |
| `project.godot` | Add "skill" input action mapped to E key | Config edit |

### 4.2 New Files

| File | Purpose |
|---|---|
| `scripts/skill_effects.gd` | Skill visual effects: elemental_burst ring expansion, shield_charge trail/stun, arrow_rain projectiles. Purely visual + Area2D damage detection. |
| `scripts/data/skill_data.gd` | Resource class for skill definitions (skill_id, name, cooldown, damage, radius, duration, description) |

### 4.3 New Signals

| Signal | Emitter | Listener | Purpose |
|---|---|---|---|
| `skill_activated(skill_id: String)` | Player | HUD | Show skill animation on HUD |
| `skill_cooldown_changed(current: float, max: float)` | Player | HUD | Update cooldown overlay |
| `skill_ready(skill_id: String)` | Player | HUD | Flash gold border |

### 4.4 skill_data.gd Resource Definition

```gdscript
class_name SkillData
extends Resource

@export var skill_id: String = ""
@export var skill_name: String = ""
@export var description: String = ""
@export var cooldown: float = 20.0
@export var damage: float = 10.0
@export var radius: float = 100.0
@export var duration: float = 0.0
@export var color: Color = Color.WHITE
@export var icon_color: Color = Color.WHITE
```

---

## 5. Skill Data Table

### 5.1 Complete Skill Definitions

| Character | Skill ID | Skill Name | Cooldown | Damage | Radius/Range | Duration | Target |
|---|---|---|---|---|---|---|---|
| Mage | `elemental_burst` | Elemental Burst | 20s | 15 | 150px AoE | Freeze 1.5s | Self-centered |
| Warrior | `shield_charge` | Shield Charge | 15s | 10 | 160px path | Stun 2.0s | Directional |
| Ranger | `arrow_rain` | Arrow Rain | 18s | 5x12=60 max | 100px AoE | 0.5s fall | Nearest cluster |

### 5.2 Complete Passive Definitions

| Character | Passive ID | Passive Name | Effect | Condition |
|---|---|---|---|---|
| Mage | `mana_attunement` | Mana Attunement | +10% weapon damage | While skill on cooldown |
| Warrior | `iron_will` | Iron Will | +3 armor for 3s | HP <= 30%, 30s internal CD |
| Ranger | `keen_eye` | Keen Eye | Guaranteed crit on every 5th hit | Always active |

### 5.3 DPS Impact Analysis

| Character | Auto-Attack DPS (Lv1, single weapon) | Skill DPS Contribution | Total DPS Change |
|---|---|---|---|
| Mage | ~6.7 (holywater orbit, ~10 dmg / 1.5s) | 15 dmg / 20s = 0.75 DPS | +11% burst, +10% sustained from passive |
| Warrior | ~6.7 (knife, ~10 dmg / 1.5s) | 10 dmg / 15s = 0.67 DPS | +10% burst |
| Ranger | ~6.7 (holywater orbit) | 60 max / 18s = 3.3 DPS | +49% burst (requires enemy cluster) |

**Balance note**: Ranger's arrow rain has the highest potential DPS contribution but requires enemy clustering (rare in early game, common in Wave 4-5). Mage's burst is consistent AoE regardless of enemy positioning. Warrior's charge is a utility skill (stun) more than a damage skill.

---

## 6. Balance Analysis

### 6.1 Cooldown vs Weapon Cycle

At Lv1, weapons fire every 1.5s. Over a 20-second skill cooldown:
- ~13 weapon activations
- Mage: 13 hits + 1 burst (15 dmg) + 10% passive bonus = effectively ~14.3 weapon activations worth of value
- Warrior: 13 hits + 1 charge (10 dmg + 2s stun on hit enemies) = stun prevents ~2 enemy attacks on Warrior
- Ranger: 13 hits + 1 arrow rain (up to 60 dmg if all 12 arrows hit) = high ceiling but situational

### 6.2 Skill vs Dash Interaction

The existing dash system (Space key, 2.5s cooldown, 80px distance) is a universal mechanic. The new skill system (E key, 15-20s cooldown) is character-specific.

- Warrior's Shield Charge is a different action from dash: longer distance (160 vs 80), damages enemies, stuns, but much longer cooldown (15s vs 2.5s). The Warrior can still use the normal dash.
- No key conflict: Space = dash, E = skill. Both can be used independently.

### 6.3 Passive Balance

| Passive | Power Level | When Active | Interaction with Items |
|---|---|---|---|
| Mana Attunement (+10% dmg) | Moderate | ~80% uptime if used optimally | Stacks multiplicatively with damage_bonus, weapon levels |
| Iron Will (+3 armor) | Strong (situational) | Only at low HP | Stacks with armor items, armor_maxhp synergy doubles it |
| Keen Eye (guaranteed crit/5 hits) | Moderate | Always | Independent of crit_chance; adds ~20% effective crit rate for fast weapons |

---

## 7. Visual Specification

### 7.1 Skill Icons (ColorRect in HUD)

| Character | Icon Shape | Icon Color | Key Label |
|---|---|---|---|
| Mage | 24x24 circle | Color(0.2, 0.4, 0.9) (blue) | "E" white text |
| Warrior | 24x24 square with notch | Color(0.8, 0.2, 0.2) (red) | "E" white text |
| Ranger | 24x24 diamond | Color(0.2, 0.7, 0.3) (green) | "E" white text |

### 7.2 Skill VFX

| Skill | VFX Elements | Colors | Duration |
|---|---|---|---|
| Elemental Burst | Expanding circle (0->150px radius), enemy tint blue | Circle: Color(0.3, 0.5, 1.0, fading from 0.8 to 0.0) | 0.2s expand |
| Shield Charge | 3 red afterimages (32x32 ColorRect), stun stars on hit enemies | Afterimage: Color(0.9, 0.2, 0.1, 0.4), Stars: Color(1, 1, 0) | 0.25s dash |
| Arrow Rain | Yellow warning circle, 12 white arrows (4x12 ColorRect) falling | Warning: Color(1, 0.85, 0, 0.3), Arrows: Color(0.9, 0.9, 0.8) | 0.3s warn + 0.5s rain |

---

## 8. Design Decisions Log

| Decision | Why | Alternative Considered |
|---|---|---|
| Single E key for all characters | Simple, no key mapping per character | Different keys per character (confusing, wastes keys) |
| 15-20s cooldown range | Skills are impactful "power moments" but not spammable; fits within wave durations (57s per wave means ~3-4 uses per wave) | 5s cooldown (too spammable, loses impact), 60s cooldown (too rare, players forget they have it) |
| Mage: self-centered AoE | Simplest targeting, no cursor needed | Targeted AoE (requires cursor tracking, adds input complexity) |
| Warrior: directional dash | Intuitive -- dashes where you move | Omnidirectional stun (less skill expression) |
| Ranger: auto-target cluster | Removes need for targeting while rewarding positioning | Manual targeting (overlaps with WASP movement controls) |
| Passive: always-on, no activation | Subtle, always felt, no additional UI or key | Toggle passives (more UI complexity, harder to understand) |
| Skill damage does NOT scale with weapon levels | Keeps skills balanced as a fixed "utility power" rather than a scaling DPS source | Scaling with weapon level (harder to balance, power creep) |
| Skill damage IS modified by damage_bonus (Mage +20%, shop upgrades) | Character damage stat should matter; shop investment should benefit skills | Pure flat damage (Mage's damage_bonus becomes irrelevant for skills) |

---

## 9. Future Enhancements (Out of Scope)

1. **Skill upgrades via passive items** -- e.g., magnet passive reduces skill cooldown by 10% per stack
2. **Character-specific skill evolution** -- At character level 10, skill upgrades (Mage burst leaves burn zone, Warrior charge leaves shockwave, Ranger rain adds lightning arrows)
3. **Skill synergy with weapons** -- e.g., using Arrow Rain while owning boomerang adds homing arrows
4. **Skill cooldown reduction stat** -- A new passive item type that reduces skill cooldown
5. **Ultimate skills** -- A second, longer-cooldown ability (60s) per character for even bigger power moments
