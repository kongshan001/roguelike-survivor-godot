# Character Upgrade Path Differentiation + Weapon Quality-Change Design Spec

**Author**: Designer Agent
**Date**: 2026-04-16
**Priority**: P1 HIGH
**Status**: Design Complete
**Brainstorm**: `docs/superpowers/specs/brainstorm/character-upgrade-paths-brainstorm.md`
**Research**: `docs/superpowers/specs/research/character-upgrade-paths-research.md`

---

## 1. Design Overview

This spec introduces two complementary systems to deepen character identity and weapon progression:

**System A -- Character Exclusive Passives**: Each of the 3 characters (Mage, Warrior, Ranger) gains access to 10 character-specific passive choices organized into 2 thematic paths of 5 each. These passives appear in the standard upgrade pool alongside shared passives, but are only offered if the player's character matches. Paths are not mutually exclusive -- the player may mix and match freely across both paths within a single run.

**System B -- Weapon Quality-Change at Lv3**: Each of the 7 base weapons gains a unique special effect at Lv3 (max level) that fundamentally changes how the weapon behaves, beyond the quantitative +count/+damage/+pierce upgrades at Lv1-Lv2. This makes weapon level-up more exciting and creates strategic decisions about which weapon to max first.

**Why these two together**: Character passives provide the WHO (character identity), weapon quality-changes provide the WHAT (build diversity). Together they create a 3-dimensional decision space: which character, which character passives to pick, which weapons to max.

---

## 2. Character Exclusive Passives

### 2.1 Design Principles

1. **Each passive is small but thematic**: No single passive is build-defining alone, but combining 3-5 passives from one path creates a distinct playstyle.
2. **No path commitment**: Players can freely mix Mana Flow and Elementalist passives on the same Mage run. The "paths" are thematic groupings, not mutually exclusive branches.
3. **Stack with shared passives**: Character passives are additive with the existing 7 shared passives. A Mage with 3 shared passives + 3 character passives has 6 passive slots total.
4. **Max 1 stack each**: Each character passive can only be taken once (unlike shared passives which stack up to 3x).
5. **Do not gate evolution**: Character passives enhance weapons but are never required for evolution recipes.

### 2.2 Integration with Upgrade Pool

The upgrade_pool.gd `get_random_upgrades()` function currently returns 3 options from: new weapons, weapon upgrades, shared passives. Character exclusive passives are added as a 4th category:

```
Upgrade categories (in priority order):
1. Evolution (guaranteed if available)
2. New weapon / Weapon upgrade
3. Shared passive
4. Character exclusive passive (NEW)
```

Character passives use type `"character_passive"` and include a `"character"` field. The upgrade pool filters by `GameManager.selected_character`.

### 2.3 Mage Exclusive Passives

The Mage has two thematic paths:

**Path A: Mana Flow** -- Focuses on area-of-effect scaling, cooldown reduction, and mana sustain. Rewards players who favor orbit/aura/cone weapons and frequent skill usage.

| # | Passive ID | Name | Effect | Numeric Value | Notes |
|---|---|---|---|---|---|
| 1 | `mage_aoe_radius` | Arcane Expansion | All weapon AoE/orbit/cone radius +15% | +15% radius multiplier | Applies to orbit_radius, aoe_radius, cone_range |
| 2 | `mage_cooldown_reduce` | Flow State | Weapon cooldowns reduced by 8% | cooldown * 0.92 | Stacks multiplicatively with weapon level CD reduction |
| 3 | `mage_regen_aura` | Mana Siphon | Regenerate 1 HP per 8 seconds while a weapon is on cooldown | 1 HP / 8s | Triggers when ANY weapon timer is > 0 |
| 4 | `mage_freeze_extend` | Hypothermia | Freeze duration on enemies +0.5s | +0.5s freeze duration | Applies to frostaura freeze and elemental_burst freeze |
| 5 | `mage_skill_cd_reduce` | Arcane Resonance | Skill cooldown reduced by 3s | -3.0s from MAGE_SKILL_COOLDOWN | New cooldown = 17s (down from 20s) |

**Path B: Elementalist** -- Focuses on raw damage, status effect stacking, and burst potential. Rewards players who favor projectile/lightning weapons and aggressive play.

| # | Passive ID | Name | Effect | Numeric Value | Notes |
|---|---|---|---|---|---|
| 1 | `mage_burn_boost` | Inferno | Burn DPS +50% | burn_dps * 1.5 | Applies to firestaff and all evolved weapons with burn |
| 2 | `mage_crit_to_burn` | Combustion | Critical hits apply burn (1.5 DPS, 2s) | 1.5 burn_dps, 2.0s duration | Adds burn to ANY weapon that crits, even non-fire weapons |
| 3 | `mage_chain_bonus` | Overcharge | Lightning chain count +1 | chain_count + 1 | Applies to base lightning and all evolved lightning weapons |
| 4 | `mage_damage_scale` | Elemental Mastery | All weapon damage +8% | damage_bonus += 0.08 | Stacks additively with Mage's base 0.20 and shop upgrades |
| 5 | `mage_skill_damage` | Power Surge | Skill damage +30% | skill_damage * 1.30 | Elemental Burst deals 19.5 damage (up from 15) |

### 2.4 Warrior Exclusive Passives

**Path A: Titan** -- Focuses on survivability, armor stacking, and sustain. Rewards players who want to absorb damage and outlast enemies.

| # | Passive ID | Name | Effect | Numeric Value | Notes |
|---|---|---|---|---|---|
| 1 | `warrior_armor_mastery` | Iron Skin | Gain +2 armor | armor += 2 | Stacks with shared armor passive and Iron Will |
| 2 | `warrior_hp_regen_boost` | Battle Heal | HP regeneration +50% | regen_amount * 1.5 | Stacks with shared regen passive |
| 3 | `warrior_max_hp_boost` | Vitality Surge | Max HP +4 | max_health += 4, heal 4 | Larger HP pool, more room for Iron Will threshold |
| 4 | `warrior_damage_reduction` | Thick Skin | All incoming damage reduced by 10% (before armor) | damage * 0.90 before armor | Applied before armor subtraction, multiplicative |
| 5 | `warrior_skill_stun_extend` | Concussive Force | Shield Charge stun +1s | stun_duration + 1.0s | New stun = 3s (up from 2s) |

**Path B: Berserker** -- Focuses on damage amplification at low HP, attack speed, and aggressive trade patterns. Rewards risk-taking players.

| # | Passive ID | Name | Effect | Numeric Value | Notes |
|---|---|---|---|---|---|
| 1 | `warrior_low_hp_damage` | Blood Rage | +25% weapon damage when HP < 50% | damage_bonus += 0.25 when HP < 50% | Stacks additively with base damage_bonus |
| 2 | `warrior_attack_speed` | Flurry | Weapon cooldowns reduced by 12% | cooldown * 0.88 | Stacks multiplicatively with level-based CD reduction |
| 3 | `warrior_crit_on_low` | Desperate Strike | +15% crit chance when HP < 30% | crit_chance += 0.15 when HP < 30% | Stacks with shared crit passive and Keen Eye |
| 4 | `warrior_kill_heal` | Bloodthirst | Killing an enemy heals 0.5 HP (10s internal CD) | 0.5 HP, 10s CD | Triggers on any weapon kill attributed to player |
| 5 | `warrior_dash_damage` | Impact Wave | Dash deals 3 damage to enemies within 30px of dash endpoint | 3.0 damage, 30px radius | Triggers on normal Space dash, not just Shield Charge |

### 2.5 Ranger Exclusive Passives

**Path A: Marksman** -- Focuses on projectile count, pierce, and range. Rewards players who want to blanket the screen with projectiles.

| # | Passive ID | Name | Effect | Numeric Value | Notes |
|---|---|---|---|---|---|
| 1 | `ranger_pierce_bonus` | Penetrating Shots | All projectile pierce +1 | pierce + 1 | Applies to knife, boomerang, and all evolved projectiles |
| 2 | `ranger_projectile_speed` | Swift Arrows | Projectile speed +20% | projectile_speed * 1.20 | Faster projectiles = less dodging by enemies |
| 3 | `ranger_extra_projectile` | Multishot | +1 projectile on all projectile-type weapons | projectile_count + 1 | Applies to knife, boomerang, and evolved projectile weapons |
| 4 | `ranger_range_boost` | Longshot | Weapon range +25% | projectile_range * 1.25 | Applies to lightning range, boomerang max_dist |
| 5 | `ranger_boomerang_speed` | Aero Dynamics | Boomerang curvature reduced by 30% (straighter flight) | boomerang_curvature * 0.70 | Straighter boomerangs cover more linear distance |

**Path B: Assassin** -- Focuses on critical hits, burst damage, and precision. Rewards players who want to maximize per-hit impact.

| # | Passive ID | Name | Effect | Numeric Value | Notes |
|---|---|---|---|---|---|
| 1 | `ranger_crit_boost` | Eagle Eye | +12% crit chance | crit_chance += 0.12 | Stacks with shared crit passive and Keen Eye |
| 2 | `ranger_crit_damage` | Lethal Blow | Crit damage multiplier +0.5 | crit_damage_mul += 0.5 | New crit multiplier = 2.5x (base 2.0 + 0.5) |
| 3 | `ranger_keen_eye_enhance` | Piercing Gaze | Keen Eye triggers every 4th hit instead of 5th | RANGER_PASSIVE_HIT_COUNT = 4 | Ranger passive becomes 25% more frequent |
| 4 | `ranger_crit_chain` | Chain Reaction | Critical hits deal 50% of crit damage to all enemies within 40px of target | 0.5 * crit_damage, 40px radius | AoE splashes on every crit |
| 5 | `ranger_skill_crit` | Rain of Death | Arrow Rain arrows can crit (using standard crit_chance) | crit_chance applies to each arrow | With 10% base crit, ~1-2 arrows crit per rain |

---

## 3. Weapon Quality-Change at Lv3

### 3.1 Design Principles

1. **Lv3 unlocks one new behavior**: Not a stat boost, but a functional change that creates new tactical options.
2. **Thematically consistent**: The quality-change extends the weapon's existing identity, not a random new mechanic.
3. **No new weapon types**: Quality-changes modify existing weapon_fire.gd behavior, not new weapon_type strings.
4. **Balanced power level**: The quality-change should be roughly equivalent to +30-50% effective DPS, but delivered through utility rather than raw damage.

### 3.2 Quality-Change Definitions

#### Holy Water (Lv3): Frost Blessing

**Effect**: Orbit blades apply 0.5s freeze on contact (15% chance per hit per blade).

| Constant | Value | Unit | Notes |
|---|---|---|---|
| `HOLYWATER_LV3_FREEZE_CHANCE` | 0.15 | fraction | Per orbit blade hit |
| `HOLYWATER_LV3_FREEZE_DURATION` | 0.5 | seconds | Brief freeze, enough to interrupt attacks |

**Why this**: Holy Water is an orbit weapon that constantly hits nearby enemies. Adding freeze makes it a crowd-control tool, rewarding players who stay in the center of enemy groups. The 15% chance per blade means at Lv3 (3 blades) with ~3 hits/second/blade, you get roughly 1 freeze per second on a target.

**Implementation**: In `spin_blade.gd` `_on_body_entered()`, if weapon is "holywater" and level >= 3, roll `randf() < 0.15` and call `body.apply_freeze(0.5)`.

---

#### Knife (Lv3): Ricochet

**Effect**: Knife projectiles bounce to 1 additional nearby enemy after hitting their primary target.

| Constant | Value | Unit | Notes |
|---|---|---|---|
| `KNIFE_LV3_RICOCHET_COUNT` | 1 | count | Number of bounces after primary hit |
| `KNIFE_LV3_RICOCHET_RANGE` | 100.0 | pixels | Range to search for bounce target |
| `KNIFE_LV3_RICOCHET_DAMAGE_MUL` | 0.5 | multiplier | Bounce deals 50% of original damage |

**Why this**: Knife is a single-target projectile weapon. Ricochet gives it limited multi-target capability without making it as powerful as the evolved fireknife/frostknife (which have pierce + count). The 0.5x damage on bounce ensures it is a bonus, not a replacement for area weapons.

**Implementation**: In `projectile.gd` `_on_body_entered()`, if `weapon_id == "knife"` and the projectile was fired at weapon level >= 3, after dealing damage to primary target, find nearest enemy within 100px and spawn a new projectile toward them with 0.5x damage.

---

#### Lightning (Lv3): Chain On Kill

**Effect**: When lightning kills an enemy, an additional lightning bolt strikes a random enemy within 200px of the killed target (dealing 50% damage).

| Constant | Value | Unit | Notes |
|---|---|---|---|
| `LIGHTNING_LV3_CHAIN_ON_KILL_RANGE` | 200.0 | pixels | Range for bonus bolt target search |
| `LIGHTNING_LV3_CHAIN_ON_KILL_DAMAGE_MUL` | 0.5 | multiplier | Bonus bolt deals 50% of base lightning damage |

**Why this**: Lightning is a single-target burst weapon. Chain-on-kill creates a cascading effect during swarms, rewarding the player for targeting weak enemies first. At 50% damage, the bonus bolt cannot itself trigger another chain (preventing infinite loops). This is distinct from the existing chain_count upgrade (which chains to nearby enemies simultaneously).

**Implementation**: In `enemy.gd` `die()`, if `_last_hit_by == "lightning"`, emit a signal. `weapon_controller.gd` listens and fires a bonus lightning bolt at a random enemy within 200px of the killed enemy's position.

---

#### Bible (Lv3): Expanding Aura

**Effect**: The orbit periodically emits a 60px damage pulse every 2 seconds, dealing 1.5 damage to all enemies within 60px of the player.

| Constant | Value | Unit | Notes |
|---|---|---|---|
| `BIBLE_LV3_PULSE_INTERVAL` | 2.0 | seconds | Time between pulses |
| `BIBLE_LV3_PULSE_RADIUS` | 60.0 | pixels | Pulse radius centered on player |
| `BIBLE_LV3_PULSE_DAMAGE` | 1.5 | HP | Damage per pulse hit |

**Why this**: Bible is a wide-orbit weapon that grazes enemies at the edge of its radius. The pulse gives it consistent close-range damage, making it useful even when no enemies are at orbit range. 1.5 damage every 2 seconds = 0.75 bonus DPS, roughly a 30% boost to Bible's base DPS (2.0 DPS at Lv3).

**Implementation**: In `weapon_controller.gd`, track a `_bible_pulse_timer` for the bible weapon. When bible is Lv3 and timer expires, deal 1.5 damage to all enemies within 60px.

---

#### Fire Staff (Lv3): Searing Flames

**Effect**: Cone attack ignites the ground on hit, creating a 40px burn zone at each hit enemy's position that lasts 2 seconds and deals 1.0 DPS.

| Constant | Value | Unit | Notes |
|---|---|---|---|
| `FIRESTAFF_LV3_BURN_ZONE_RADIUS` | 40.0 | pixels | Radius of burn zone |
| `FIRESTAFF_LV3_BURN_ZONE_DPS` | 1.0 | HP/s | Damage per second in zone |
| `FIRESTAFF_LV3_BURN_ZONE_DURATION` | 2.0 | seconds | Zone lifetime |

**Why this**: Fire Staff is a directional cone weapon with existing burn effects (Lv3 already adds burn in weapon_fire.gd). Searing Flames adds area denial -- enemies that walk through the burn zone take damage even after the cone attack ends. 1.0 DPS is lower than the weapon's own burn (2.0 DPS from BURN_DPS), so the zone is supplementary, not primary.

**Implementation**: On cone hit, if firestaff is Lv3, spawn a persistent Area2D at the hit enemy's position. Area2D has 40px radius, lasts 2s, deals 1.0 DPS to enemies inside. Can be a simple ColorRect-based zone.

---

#### Frost Aura (Lv3): Shatter

**Effect**: When a frozen enemy dies, it shatters, dealing 2.0 damage to all enemies within 50px.

| Constant | Value | Unit | Notes |
|---|---|---|---|
| `FROSTAURA_LV3_SHATTER_RADIUS` | 50.0 | pixels | Shatter damage radius |
| `FROSTAURA_LV3_SHATTER_DAMAGE` | 2.0 | HP | Damage to nearby enemies |

**Why this**: Frost Aura is a crowd-control weapon (slow + occasional freeze). Shatter turns frozen enemies into area weapons, creating chain reactions when multiple enemies are frozen and one dies. At Lv3, freeze_pct is 8% per tick, so multiple enemies are often frozen simultaneously in swarms.

**Implementation**: In `enemy.gd` `die()`, if enemy is currently frozen and player has frostaura at Lv3, deal 2.0 damage to all enemies within 50px of the dying enemy.

---

#### Boomerang (Lv3): Homing Tweak

**Effect**: Boomerang tracking angle increased by 50% (curvature bonus), making it significantly more likely to hit enemies on the return path.

| Constant | Value | Unit | Notes |
|---|---|---|---|
| `BOOMERANG_LV3_TRACK_ANGLE_BONUS` | 0.5 | multiplier | Track angle * 1.5 at Lv3 |

**Why this**: Boomerang's current Lv3 upgrade adds +2 projectiles and +2 pierce via standard scaling. The homing tweak ensures that these extra boomerangs actually HIT enemies rather than flying past. Base track angle is 0.52 rad (30 degrees); at Lv3 it becomes 0.78 rad (45 degrees) -- a meaningful increase in homing capability that is noticeable but not overpowered.

**Implementation**: In `weapon_fire.gd` `fire_boomerang()`, when computing `track_angle` for non-evolved boomerang at level 3, multiply the final track_angle by `BOOMERANG_LV3_TRACK_ANGLE_BONUS + 1.0` (i.e., 1.5).

---

### 3.3 Quality-Change Summary Table

| Weapon | Lv3 Effect | Type | DPS Impact | Implementation Location |
|---|---|---|---|---|
| holywater | Frost Blessing (15% freeze/blade hit) | CC | ~10% (interrupt value) | spin_blade.gd |
| knife | Ricochet (1 bounce, 50% dmg) | Multi-target | ~25% vs 2 enemies | projectile.gd |
| lightning | Chain On Kill (50% dmg to nearby) | Cascade | ~15% during swarms | enemy.gd die() |
| bible | Expanding Aura (1.5 dmg / 2s pulse) | AoE | +0.75 DPS (~30%) | weapon_controller.gd |
| firestaff | Searing Flames (burn zone) | Area denial | ~20% vs grouped | weapon_fire.gd cone |
| frostaura | Shatter (2.0 dmg on frozen kill) | Chain reaction | ~15% vs frozen groups | enemy.gd die() |
| boomerang | Homing Tweak (50% more tracking) | Accuracy | ~20% more hits | weapon_fire.gd boom |

---

## 4. Numerical Constants Summary

### 4.1 Character Passive Constants

These constants should be defined in a new data file `scripts/data/character_passive_data.gd` or added to `scripts/data/skill_data.gd`.

#### Mage -- Mana Flow Path

```gdscript
const MAGE_AOE_RADIUS_BONUS: float = 0.15        # +15% radius
const MAGE_COOLDOWN_REDUCTION: float = 0.92       # 8% CD reduction
const MAGE_REGEN_AURA_AMOUNT: float = 1.0         # 1 HP
const MAGE_REGEN_AURA_INTERVAL: float = 8.0       # seconds
const MAGE_FREEZE_EXTEND: float = 0.5             # +0.5s freeze
const MAGE_SKILL_CD_REDUCTION: float = 3.0        # -3s from skill CD
```

#### Mage -- Elementalist Path

```gdscript
const MAGE_BURN_BOOST: float = 1.5                # 50% more burn DPS
const MAGE_CRIT_BURN_DPS: float = 1.5             # crit burn DPS
const MAGE_CRIT_BURN_DURATION: float = 2.0        # crit burn duration
const MAGE_CHAIN_BONUS: int = 1                    # +1 chain
const MAGE_DAMAGE_SCALE: float = 0.08             # +8% damage
const MAGE_SKILL_DAMAGE_BOOST: float = 1.30       # +30% skill damage
```

#### Warrior -- Titan Path

```gdscript
const WARRIOR_ARMOR_MASTERY: int = 2              # +2 armor
const WARRIOR_HP_REGEN_BOOST: float = 1.5         # 50% more regen
const WARRIOR_MAX_HP_BOOST: float = 4.0           # +4 max HP
const WARRIOR_DAMAGE_REDUCTION: float = 0.90       # 10% damage reduction
const WARRIOR_SKILL_STUN_EXTEND: float = 1.0      # +1s stun
```

#### Warrior -- Berserker Path

```gdscript
const WARRIOR_LOW_HP_DAMAGE: float = 0.25         # +25% dmg when HP < 50%
const WARRIOR_LOW_HP_THRESHOLD: float = 0.50      # 50% HP threshold
const WARRIOR_ATTACK_SPEED: float = 0.88          # 12% CD reduction
const WARRIOR_CRIT_ON_LOW: float = 0.15           # +15% crit when HP < 30%
const WARRIOR_CRIT_ON_LOW_THRESHOLD: float = 0.30 # 30% HP threshold
const WARRIOR_KILL_HEAL: float = 0.5              # HP healed on kill
const WARRIOR_KILL_HEAL_CD: float = 10.0          # internal CD
const WARRIOR_DASH_DAMAGE: float = 3.0            # dash damage
const WARRIOR_DASH_RANGE: float = 30.0            # dash damage radius
```

#### Ranger -- Marksman Path

```gdscript
const RANGER_PIERCE_BONUS: int = 1                # +1 pierce
const RANGER_PROJECTILE_SPEED: float = 1.20       # +20% speed
const RANGER_EXTRA_PROJECTILE: int = 1            # +1 projectile
const RANGER_RANGE_BOOST: float = 1.25            # +25% range
const RANGER_BOOMERANG_CURVATURE: float = 0.70    # 30% less curvature
```

#### Ranger -- Assassin Path

```gdscript
const RANGER_CRIT_BOOST: float = 0.12             # +12% crit
const RANGER_CRIT_DAMAGE_BONUS: float = 0.5       # +0.5 crit multiplier
const RANGER_KEEN_EYE_OVERRIDE: int = 4           # every 4th hit instead of 5th
const RANGER_CRIT_CHAIN_RANGE: float = 40.0       # AoE splash range
const RANGER_CRIT_CHAIN_DAMAGE_MUL: float = 0.5   # 50% of crit damage
const RANGER_SKILL_CAN_CRIT: bool = true           # arrow rain can crit
```

### 4.2 Weapon Lv3 Quality-Change Constants

These constants should be added to `scripts/weapons/weapon_fire.gd` or a new `scripts/data/weapon_qc_data.gd`.

```gdscript
# Holy Water Lv3: Frost Blessing
const HOLYWATER_LV3_FREEZE_CHANCE: float = 0.15
const HOLYWATER_LV3_FREEZE_DURATION: float = 0.5

# Knife Lv3: Ricochet
const KNIFE_LV3_RICOCHET_COUNT: int = 1
const KNIFE_LV3_RICOCHET_RANGE: float = 100.0
const KNIFE_LV3_RICOCHET_DAMAGE_MUL: float = 0.5

# Lightning Lv3: Chain On Kill
const LIGHTNING_LV3_COK_RANGE: float = 200.0
const LIGHTNING_LV3_COK_DAMAGE_MUL: float = 0.5

# Bible Lv3: Expanding Aura
const BIBLE_LV3_PULSE_INTERVAL: float = 2.0
const BIBLE_LV3_PULSE_RADIUS: float = 60.0
const BIBLE_LV3_PULSE_DAMAGE: float = 1.5

# Fire Staff Lv3: Searing Flames
const FIRESTAFF_LV3_ZONE_RADIUS: float = 40.0
const FIRESTAFF_LV3_ZONE_DPS: float = 1.0
const FIRESTAFF_LV3_ZONE_DURATION: float = 2.0

# Frost Aura Lv3: Shatter
const FROSTAURA_LV3_SHATTER_RADIUS: float = 50.0
const FROSTAURA_LV3_SHATTER_DAMAGE: float = 2.0

# Boomerang Lv3: Homing Tweak
const BOOMERANG_LV3_TRACK_ANGLE_MUL: float = 1.5
```

---

## 5. Upgrade Pool Integration

### 5.1 Character Passive Registration

Character passives are registered in `upgrade_pool.gd` alongside shared passives, with an additional `"character"` field for filtering.

```gdscript
# In _ensure_initialized(), after shared passives:
_character_passives = {
    # Mage -- Mana Flow
    "mage_aoe_radius": {"name": "Arcane Expansion", "description": "AoE radius +15%",
        "icon_color": Color(0.3, 0.5, 1.0), "max_stack": 1, "character": "mage"},
    "mage_cooldown_reduce": {"name": "Flow State", "description": "Weapon CD -8%",
        "icon_color": Color(0.3, 0.5, 1.0), "max_stack": 1, "character": "mage"},
    # ... (all 10 mage passives, 10 warrior passives, 10 ranger passives)
}
```

### 5.2 Upgrade Selection Logic

In `get_random_upgrades()`, after shared passives, add character passives:

```gdscript
# Character exclusive passives
for passive_id in _character_passives:
    var p: Dictionary = _character_passives[passive_id]
    if p.get("character", "") != GameManager.selected_character:
        continue  # Skip passives for other characters
    var current_stacks: int = owned_passives.get(passive_id, 0)
    if current_stacks < p.get("max_stack", 1):
        options.append({
            "type": "character_passive",
            "id": passive_id,
            "name": p.name,
            "description": p.description,
            "icon_color": p.icon_color,
        })
```

### 5.3 Passive Application in player.gd

Add a new match section in `apply_passive()`:

```gdscript
# After the existing match block for shared passives:
match passive_id:
    # Mage -- Mana Flow
    "mage_aoe_radius":
        _aoe_radius_bonus = 0.15
    "mage_cooldown_reduce":
        _cooldown_multiplier *= 0.92
    "mage_regen_aura":
        _mana_regen_enabled = true
    "mage_freeze_extend":
        _freeze_duration_bonus += 0.5
    "mage_skill_cd_reduce":
        skill_cooldown_max -= 3.0
    # Mage -- Elementalist
    "mage_burn_boost":
        _burn_dps_multiplier = 1.5
    "mage_crit_to_burn":
        _crit_applies_burn = true
    "mage_chain_bonus":
        _chain_bonus += 1
    "mage_damage_scale":
        damage_bonus += 0.08
    "mage_skill_damage":
        _skill_damage_multiplier *= 1.30
    # ... (warrior, ranger passives similarly)
```

---

## 6. Balance Analysis

### 6.1 Character Passive Power Budget

Each path provides roughly equivalent total power if all 5 passives are collected:

| Character | Path | Total Power (all 5) | Primary Stat Enhanced |
|---|---|---|---|
| Mage | Mana Flow | ~40% more AOE/sustain | Radius + CD + Regen + Freeze + Skill CD |
| Mage | Elementalist | ~45% more damage/burst | Burn + CritBurn + Chain + Damage + SkillDmg |
| Warrior | Titan | ~60% more survivability | Armor + Regen + HP + Reduction + Stun |
| Warrior | Berserker | ~50% more DPS (conditional) | LowHP Dmg + Speed + Crit + KillHeal + DashDmg |
| Ranger | Marksman | ~45% more coverage | Pierce + Speed + Projectile + Range + Homing |
| Ranger | Assassin | ~55% more crit/burst | CritRate + CritDmg + KeenEye + Chain + SkillCrit |

**Assessment**: Titan path is the strongest defensively (60% survivability), Berserker is situationally strong (requires low HP). This is intentional -- Titan is safer, Berserker is higher ceiling. Mage and Ranger paths are balanced between the two options per character.

### 6.2 Interaction with Shared Passives

| Interaction | Effect | Risk |
|---|---|---|
| Warrior + armor (shared) + warrior_armor_mastery (Titan 1) | +3 armor from shared + 2 from exclusive = 5 total | High armor makes Warrior very tanky, but this requires 4 passive slots (3 shared + 1 exclusive) |
| Ranger + crit (shared x3) + ranger_crit_boost (Assassin 1) | +24% + 12% = 36% crit chance | High but requires 4 passive slots |
| Mage + mage_damage_scale + base damage_bonus + shop weaponDmg | 0.20 + 0.08 + shop = up to 0.38 | Multiplicative with mana_attunement (0.10), total ~1.42x |
| Warrior + boots_regen synergy + warrior_hp_regen_boost | Shared regen * 1.5 (Titan 2) * 2.0 (synergy when moving) = 3x base regen | Very high regen, but requires 2 passives + synergy + moving |

**Assessment**: Combinations are powerful but require significant passive investment (3-4 slots out of ~10 total picks in a 5-minute run). This is the intended design -- specializing in one dimension means sacrificing others.

### 6.3 Weapon Lv3 Quality-Change Balance

| Weapon | Lv3 Bonus DPS | Lv1-2 DPS Range | Relative Boost |
|---|---|---|---|
| holywater | ~0.3 DPS (freeze interrupt value) | 3.0 DPS (3 blades) | ~10% |
| knife | ~1.5 DPS (ricochet vs 2nd target) | 4.3 DPS (3 knives) | ~25% (situational) |
| lightning | ~1.0 DPS (chain on kill during swarm) | 7.0 DPS (2 bolts + 1 chain) | ~15% (situational) |
| bible | +0.75 DPS (pulse) | 2.5 DPS (1 orbit) | +30% |
| firestaff | ~1.5 DPS (burn zone vs grouped) | 5.0 DPS (cone + burn) | ~20% (situational) |
| frostaura | ~1.0 DPS (shatter during swarm) | 1.5 DPS (aura) | ~15% (situational) |
| boomerang | ~1.5 DPS (more hits from homing) | 5.0 DPS (3 boomerangs) | ~20% (accuracy) |

**Assessment**: Bible's +30% is the highest relative boost, compensating for its low base DPS. Knife and firestaff bonuses are situational (require 2+ enemies or grouped enemies). All bonuses are within the target 15-30% range.

### 6.4 Experience Economy Analysis

H5 EXP_TABLE: [8, 12, 18, 24, 32, 42, 55, 70, 88, 108, 132, 160, 195, 240]

Total XP for 14 levels: 1174 XP
Average XP per kill (Normal): ~3 XP base (zombie=3, bat=1, skeleton=5)
Average kills per 5-minute run: ~80-120
Total XP earned in a run: ~240-360 XP (enough for 7-9 levels)

With 3 weapon slots (max), each weapon can be upgraded to Lv3 with 2 level-ups (Lv1->Lv2->Lv3 = 2 weapon upgrades). That uses ~6 of the 7-9 level-ups for weapon acquisition + upgrade.

Remaining ~1-3 level-ups go to passives. Players will typically get 3-5 passive picks per run:
- 2-3 shared passives
- 1-2 character exclusive passives

This means players will NOT collect all 10 character passives in a single run. They will pick 1-2 that define their build direction. This is the intended behavior -- the 10 passive pool creates variety across multiple runs.

---

## 7. Design Decisions Log

| # | Decision | Why | Alternative Considered |
|---|---|---|---|
| 1 | 10 character passives (2 paths x 5) instead of 1 path | Two paths create meaningful build variety per character; one path is too linear | 1 path x 8 passives (deeper but no choice), 3 paths x 3 passives (more branches but shallow) |
| 2 | No path commitment (free mix) | 5-minute runs are too short for irreversible decisions; free mixing rewards experimentation | Commit at level 5 (rejected -- too rigid, creates analysis paralysis) |
| 3 | Max 1 stack per character passive | Character passives are stronger than shared passives (which stack 3x); 1 stack keeps them special | Allow 2 stacks (too powerful -- a 2-stack mage_burn_boost would be 2.25x burn DPS) |
| 4 | Character passives appear alongside shared passives | Keeps the upgrade flow simple -- player always sees 3 options, some happen to be character-exclusive | Separate "character passive" slot in upgrade UI (adds UI complexity for minimal gain) |
| 5 | Quality-change at Lv3 instead of Lv2 | Lv2 is too early (player has not committed to the weapon yet); Lv3 is the max, making it a capstone | Lv2 quality-change (too early to appreciate), Lv3 stat boost only (missed opportunity for excitement) |
| 6 | Weapon quality-changes are per-weapon, not per-character | Keeps weapon system independent of character system; any character benefits from any weapon's Lv3 | Character-specific weapon quality-changes (7 weapons x 3 characters = 21 unique effects, too many to balance) |
| 7 | Knife ricochet (1 bounce, 50% dmg) not pierce | Ricochet is thematically distinct from pierce (bounces to NEARBY, pierce goes THROUGH). Creates a new targeting pattern, not just "more pierce" | +1 pierce (boring -- just more of the same stat) |
| 8 | Frost Aura shatter triggers on frozen enemy death | Creates a chain reaction mechanic that rewards the Frost Aura's freeze-playstyle | Shatter on freeze application (too frequent, would be overpowered) |
| 9 | Boomerang homing boost instead of new behavior | Boomerang already has 5 parameters that scale with level. A homing boost is the most impactful improvement that does not add new mechanics | Burn trail (overlaps with firestaff), split on return (complex implementation) |
| 10 | Warrior dash damage (3 dmg) on normal Space dash | Gives the Warrior's universal dash a combat purpose, making the dash key feel offensive rather than purely evasive | Dash damage only on Shield Charge (skill) -- too infrequent (15s CD) to be satisfying |

---

## 8. Future Enhancements (Out of Scope)

1. **Character-specific evolution variants** -- When a Mage evolves knife+firestaff, they could get a different evolved weapon than when a Warrior does. High impact, very high scope.
2. **Path mastery bonus** -- Collecting all 5 passives from one path grants a small bonus (e.g., all Mana Flow passives = +5% skill damage). Rewards commitment.
3. **Weapon mastery system** -- Track kills per weapon during a run; at 50 kills, unlock a weapon-specific buff. Requires kill attribution system.
4. **Character level system** -- After enough XP, character level (separate from weapon level) increases, unlocking stronger versions of character passives.
5. **Quality-change visual feedback** -- Each weapon Lv3 quality-change should have a unique visual indicator (color shift, particle effect, size pulse) to make the upgrade feel dramatic.
