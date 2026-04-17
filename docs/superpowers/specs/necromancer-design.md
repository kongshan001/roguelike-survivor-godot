# Necromancer Character + Firebomb Weapon Design Spec

**Author**: Designer Agent
**Date**: 2026-04-18
**Round**: R33
**Status**: Design Spec -- Awaiting Implementation
**Priority**: P1 HIGH (v1.2.0 Phase B)
**Prerequisite**: Audio system spec (v1.2.0 Phase A) should be evaluated first for implementation sequencing

---

## 1. Executive Summary

This spec defines two new content additions for v1.2.0 Phase B: (1) a 4th playable character "Necromancer" with unique kill-scaling mechanics, and (2) a new throwing weapon "Firebomb" with an evolution path. The Necromancer introduces a "death snowball" playstyle where power grows with each kill, differentiating from the existing Mage (flat damage bonus), Warrior (defensive), and Ranger (crit-based) archetypes. The Firebomb adds the "point AoE" weapon archetype that currently does not exist in the weapon roster, complementing firestaff (directional cone) and frostaura (persistent aura).

---

## 2. Pre-requisite Research

### 2.1 Genre Character Differentiation Analysis

| Game | Character Count | Differentiation Axis | Kill-Scaling Mechanic | Reference Value |
|------|----------------|---------------------|----------------------|-----------------|
| Vampire Survivors | 40+ | Starting weapon + stat bonus | Some chars have bonus XP/growth rate | **MEDIUM** -- starting weapon is primary differentiator |
| Brotato | 60+ | Dramatically different mechanics | Some chars gain stats per wave survived | **HIGH** -- mechanical diversity is core appeal |
| HoloCure | 20+ | Unique active skill + stats | Some chars power up with viewer count | **HIGH** -- active skill is the key differentiator |
| Magic Survival | 10+ | Stat distribution + starting weapon | None | **LOW** -- minimal differentiation |

**Key findings**:
1. **Kill-scaling is underused in the genre**: Most survivor games use flat stat bonuses or equipment-based scaling. A character whose power directly scales with kills creates a unique "momentum" playstyle that is immediately distinguishable.
2. **Active skill differentiation is proven**: HoloCure and our existing 3 characters demonstrate that a unique active skill is the strongest differentiator. The Necromancer's "Death Pulse" scales with total kills, which no existing character does.
3. **Risk of power creep**: Kill-scaling can become oppressive in late-game (Endless mode). A hard cap (20% damage bonus from passive, damage ceiling on skill) is essential.

### 2.2 Existing Character Stat Baseline

| Character | HP | Speed | Pickup Range | Passive | Skill | Role |
|-----------|-----|-------|-------------|---------|-------|------|
| Mage | 8 | 160 | 35 | +20% weapon damage | Elemental Burst (AoE freeze) | Balanced DPS |
| Warrior | 12 | 140 | 35 | +1 armor | Shield Charge (dash stun) | Tank |
| Ranger | 6 | 190 | 35 | +10% crit | Arrow Rain (targeted AoE) | Glass cannon |
| **Necromancer** | **7** | **150** | **45** | **Kill scaling dmg** | **Death Pulse (kill-based AoE)** | **Momentum scaler** |

**Source**: H5 config.js CHARACTERS, character-skills.md, character_select.gd

---

## 3. Necromancer Character Design

### 3.1 Base Attributes

| Attribute | Value | Unit | Comparison | Design Rationale |
|-----------|-------|------|-----------|------------------|
| character_id | `"necromancer"` | string | -- | |
| character_name | `"necromancer"` (display: "死灵法师") | string | -- | |
| max_hp | 7.0 | HP | Mage=8, Ranger=6, Warrior=12 | Second lowest. Lower than Mage because kill-scaling passive compensates survivability through faster kills |
| move_speed | 150.0 | px/s | Mage=160, Ranger=190, Warrior=140 | Between Warrior(140) and Mage(160). Slow enough to feel "heavy/dark" but not crippled |
| pickup_range | 45.0 | px | All others=35 | **+29% vs baseline**. Larger pickup range is the Necromancer's "quality of life" advantage, representing soul absorption. Compensates for below-average speed |
| start_weapon | `"frostaura"` | weapon_id | Mage=choose, Warrior=knife, Ranger=holywater | Frostaura is a control-oriented starting weapon, buying time for kill count to accumulate |
| passive_ability | `"kill_bonus"` | string | -- | New passive type. Not "dmg_bonus", "armor_bonus", or "crit_bonus" |
| color | Color(0.27, 0.13, 0.40) | Color | Dark purple (#442266) | Matches elite_knight/dark magic theme. Distinct from Mage blue, Warrior red, Ranger green |

**Character select display data**:

```gdscript
{
    "id": "necromancer",
    "name": "死灵法师",
    "sprite": "res://assets/sprites/characters/necromancer.png",
    "hp": 7,
    "speed": 150,
    "desc": "击杀越多，伤害越高",
    "ability": "每百杀+2%伤害",
    "color": Color(0.27, 0.13, 0.40),
}
```

**Sprite asset**: New `assets/sprites/characters/necromancer.png` needed (32x32, dark purple hood + pale skin + staff). To be generated via `tools/generate_sprites.py`.

### 3.2 Starting Weapon: Frostaura

The Necromancer starts with frostaura (already implemented as a weapon type). No new weapon code needed.

| Level | Behavior | Source |
|-------|----------|--------|
| Lv1 | 1.0 DPS, 30% slow, 80px radius | upgrade_pool.gd line 65-68 |
| Lv2 | 1.5 DPS, 35% slow, 95px radius | Existing scaling |
| Lv3 | 2.0 DPS, 40% slow, 110px radius + 15% freeze chance + shatter on freeze death | Existing Lv3 quality change |

**Why frostaura as starting weapon**: The Necromancer's core identity is "kill-scaling momentum". Early game, before kills accumulate, the character is weak. Frostaura's crowd control (slow + freeze) keeps enemies at bay while the kill count builds. It is also thematically fitting -- frost and death are thematically linked. No other starting weapon provides this "defensive ramp" pattern.

**Evolution path from frostaura**: frostaura + lightning = blizzard (already exists). This means the Necromancer naturally progresses toward the strongest AoE control weapon in the game, reinforcing the "death zone" fantasy.

### 3.3 Passive: Death's Bounty (Kill Scaling)

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| NECRO_PASSIVE_ID | `"kill_bonus"` | string | Matches passive_ability field |
| NECRO_KILLS_PER_BONUS | 100 | kills | Every 100 kills = +2% damage |
| NECRO_DAMAGE_BONUS_PER_TIER | 0.02 | multiplier | +2% per 100 kills |
| NECRO_MAX_DAMAGE_BONUS | 0.20 | multiplier | Cap at +20% (1000 kills) |
| NECRO_MAX_KILL_TIERS | 10 | tiers | 100/200/300/.../1000 = 10 tiers |

**Behavior**: Every 100 enemies killed during the current run, all weapon damage increases by 2%. The bonus is additive with the shop weapondmg bonus and mastery bonus, then multiplied by character passive.

**Damage formula integration**:

```
Final = Base x (1 + shop_bonus + mastery_bonus + necro_kill_bonus) x character_passive
```

Where:
- `shop_bonus` = SaveManager.shop_weapon_dmg_bonus() (max +15%)
- `mastery_bonus` = SaveManager.get_weapon_mastery_bonus(weapon_id) (max +8%)
- `necro_kill_bonus` = floor(GameManager.kills / 100) x 0.02, capped at 0.20
- `character_passive` = 1.0 for Necromancer (no flat damage bonus like Mage's +20%)

**Why the Necromancer does NOT have the Mage's +20% flat bonus**: The kill-scaling passive replaces the flat bonus entirely. If the Necromancer had both, at 1000 kills the total bonus would be (1 + 0.15 + 0.08 + 0.20) x 1.20 = 1.71x, which is excessive. Without the flat bonus, the maximum is (1 + 0.15 + 0.08 + 0.20) x 1.0 = 1.43x, which is below Mage's (1 + 0.15 + 0.08) x 1.20 = 1.48x. The Necromancer trades raw power ceiling for the momentum experience.

**Kill count progression milestones**:

| Kills | Bonus | Cumulative | Wave Context (Normal) |
|-------|-------|-----------|----------------------|
| 0 | +0% | 1.00x | Start of game |
| 100 | +2% | 1.02x | ~1:00 (early Wave 2) |
| 200 | +4% | 1.04x | ~1:45 (mid Wave 2) |
| 300 | +6% | 1.06x | ~2:30 (Wave 3 start) |
| 500 | +10% | 1.10x | ~3:30 (Wave 4 start) |
| 700 | +14% | 1.14x | ~4:00 (Boss wave) |
| 1000 | +20% | 1.20x | Only achievable in Endless mode (~6:00+) |

**Normal mode analysis**: A typical Normal run (300 seconds) produces approximately 300-500 kills. The Necromancer reaches +6% to +10% damage bonus in a standard game. This is below Mage's flat +20%, which is intentional -- the Necromancer's advantage comes from the active skill, not the passive.

**Endless mode scaling**: In Endless mode (10+ minutes), kill counts can exceed 1000. The hard cap at +20% prevents runaway scaling. At cap, the Necromancer's passive matches Mage's flat bonus, but without the multiplicative 1.20x character passive, the Necromancer is still slightly behind Mage in raw DPS (1.43x vs 1.48x with all bonuses).

### 3.4 Active Skill: Death Pulse

**Description**: The Necromancer releases a pulse of necrotic energy that damages all enemies within range. The pulse damage increases based on the total number of enemies killed during the current run.

**Activation**: Press E key. Immediate effect, no cast time.

**Visual**: Dark purple ring expanding from player position (ColorRect circle, grows from 0 to full radius over 0.25s). Enemies hit briefly flash purple for 0.1s. Screen shake intensity 5.0 for 0.12s (stronger than Mage burst's 4.0, representing death energy).

#### Skill Constants

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| NECRO_SKILL_ID | `"death_pulse"` | string | |
| NECRO_SKILL_COOLDOWN | 25.0 | seconds | Longest CD of all 4 characters (Mage=20, Warrior=15, Ranger=18) |
| NECRO_SKILL_BASE_DAMAGE | 8.0 | HP | Base damage before kill scaling |
| NECRO_SKILL_KILL_BONUS_RATE | 0.05 | multiplier | +5% base damage per enemy killed this run |
| NECRO_SKILL_KILL_BONUS_CAP | 30.0 | HP | Maximum bonus damage from kills (600 kills x 5% x 8.0 = 240, but capped at 30.0) |
| NECRO_SKILL_MAX_DAMAGE | 38.0 | HP | 8.0 base + 30.0 bonus cap |
| NECRO_SKILL_RADIUS | 120.0 | pixels | AoE radius centered on player |
| NECRO_SKILL_EXPAND_TIME | 0.25 | seconds | Visual expansion duration |
| NECRO_SKILL_SCREENSHAKE | 5.0 | intensity | |
| NECRO_SKILL_SCREENSHAKE_DUR | 0.12 | seconds | |

**Damage formula**:

```
kill_bonus = min(GameManager.kills * 0.05 * NECRO_SKILL_BASE_DAMAGE, NECRO_SKILL_KILL_BONUS_CAP)
total_damage = NECRO_SKILL_BASE_DAMAGE + kill_bonus
```

**Skill damage at key milestones**:

| Kills | Kill Bonus | Total Damage | Comparison |
|-------|-----------|-------------|------------|
| 0 | 0.0 | 8.0 | Lower than Mage's Elemental Burst (15.0) |
| 50 | 2.0 | 10.0 | Still below Mage |
| 100 | 4.0 | 12.0 | Approaching Mage |
| 200 | 8.0 | 16.0 | Surpasses Mage |
| 300 | 12.0 | 20.0 | Strong mid-game nuke |
| 500 | 20.0 | 28.0 | Very powerful |
| 600+ | 30.0 (cap) | 38.0 | Maximum power |

**Why 5% per kill with 30 HP cap**: At 100 kills (typical end of Wave 2), the skill deals 12.0 damage, which is below Mage's 15.0. This ensures the Necromancer's skill starts weaker and requires investment (time + kills) to surpass other characters. The 600-kill cap (30.0 bonus) means the skill never exceeds 38.0 total, keeping it in the "strong but not broken" range -- Elite Skeleton has 12 HP, so at 200+ kills the skill one-shots elites, which feels powerful but fair.

**Why the skill counts total kills, not the passive's 100-kill tiers**: Using total kills (not tier-based) makes the scaling feel smooth and continuous. Every kill matters. The passive's 100-kill tiers are for the always-on bonus; the skill uses raw count for its one-time burst.

**Interaction with damage_bonus**: Death Pulse damage is affected by the Necromancer's passive kill bonus and shop mastery bonuses, following the standard damage formula:

```
final_damage = total_damage x (1 + shop_bonus + mastery_bonus + necro_kill_bonus)
```

At 500 kills with full shop T4 and mastery Tier 4:
```
final_damage = 28.0 x (1 + 0.15 + 0.08 + 0.10) = 28.0 x 1.33 = 37.24 HP
```

This is enough to one-shot Elite Skeletons (12 HP in Normal, 18 HP in Hard) with significant overkill, which is the intended "power moment" for the Necromancer at this stage.

### 3.5 Passive Trait: Soul Harvest

In addition to the kill-scaling damage bonus, the Necromancer has a secondary passive trait that provides a subtle always-on utility.

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| NECRO_TRAIT_ID | `"soul_harvest"` | string | |
| NECRO_TRAIT_PICKUP_RANGE_BONUS | 10.0 | pixels | Added to base pickup range |
| NECRO_TRAIT_GEM_HEAL_CHANCE | 0.01 | fraction | 1% chance per gem pickup to heal 1 HP |

**Behavior**: The Necromancer has a base pickup range of 45.0 (vs 35.0 for other characters). Additionally, each XP gem pickup has a 1% chance to heal 1 HP. This does not stack with the magnet_maxhp synergy (which provides 2% gem heal chance); instead, the chances are independent and both can trigger.

**Why Soul Harvest as a secondary trait**: The Necromancer has the second-lowest HP (7.0) and no flat damage bonus. The extended pickup range and minor gem healing provide passive survivability that rewards the "stay in the fight" playstyle. With 300+ kills producing 300+ gems, the expected healing is ~3 HP per game, which is modest but meaningful.

### 3.6 Character Differentiation Analysis

| Dimension | Mage | Warrior | Ranger | Necromancer |
|-----------|------|---------|--------|-------------|
| **Primary stat** | Damage | HP/Armor | Speed/Crit | Pickup Range |
| **HP tier** | 2nd (8) | 1st (12) | 4th (6) | 3rd (7) |
| **Speed tier** | 2nd (160) | 4th (140) | 1st (190) | 3rd (150) |
| **Starting weapon** | Choose | knife (projectile) | holywater (orbit) | frostaura (aura) |
| **Passive type** | Flat damage (+20%) | Flat armor (+1) | Crit-based (+10%) | Kill-scaling (+2%/100kills) |
| **Skill pattern** | Centered AoE burst | Directional dash | Targeted rain | Centered AoE (scaling) |
| **Skill scaling** | None (fixed 15.0) | None (fixed 10.0) | None (fixed 5.0x12) | Kill-based (8.0-38.0) |
| **Power curve** | Flat (always +20%) | Flat (always +armor) | Flat (crit variance) | **Ramping** (0% to +20%) |
| **Best difficulty** | Hard (flat bonus scales well) | Easy/Normal (tank forgiving) | Normal (speed + crit) | Normal/Endless (more kills = more power) |
| **Weakness** | No mobility tools | Low speed, no range | Fragile, requires positioning | Weak early game, skill-dependent |

**Key differentiator**: The Necromancer is the only character with a **ramping power curve**. Mage, Warrior, and Ranger all have flat bonuses that are equally strong at minute 0 and minute 5. The Necromancer starts below average but can exceed Mage's bonus by endgame (if 1000+ kills are achieved). This creates a unique "investment and payoff" loop.

---

## 4. Firebomb Weapon Design

### 4.1 Overview

The Firebomb is a new base weapon (8th type) that introduces the "throwing" archetype. It throws an incendiary flask in a parabolic arc toward the nearest enemy, creating a persistent fire pool at the landing point.

**Weapon type**: `"throwing"` (new type, to be added to weapon_data.gd)

**Positioning in weapon ecosystem**:

| Weapon | Fire Pattern | Target Selection | AoE Shape | Persistence |
|--------|-------------|-----------------|-----------|-------------|
| knife | Linear projectile | Nearest enemy | Single target | Instant |
| holywater | Orbit circles | Self-centered | Circular orbit | Persistent |
| lightning | Random strike | Random in range | Point + chain | Instant |
| bible | Expanding orbit | Self-centered | Circular orbit | Persistent |
| firestaff | Forward cone | Aim direction | 80-degree cone | Instant + burn |
| frostaura | Persistent aura | Self-centered | Circle (80px) | Persistent |
| boomerang | Arc + return | Nearest enemy | Path + contact | Temporary |
| **firebomb** | **Parabolic throw** | **Nearest enemy** | **Circle at landing** | **2s fire pool** |

**Unique niche**: The firebomb is the only weapon that creates a persistent hazard at a remote location. This is "point AoE" -- a fixed damage zone that enemies walk through, unlike frostaura (follows player) or firestaff (directional cone). The tactical value is area denial.

### 4.2 Base Weapon Constants

| Attribute | Value | Unit | Notes |
|-----------|-------|------|-------|
| weapon_name | `"火焰瓶"` | string | Display name |
| weapon_id | `"firebomb"` | string | |
| weapon_type | `"throwing"` | string | New type |
| damage | 3.0 | HP | Per tick in fire pool. Ticks every 0.5s = 6.0 DPS per target in pool |
| cooldown | 2.5 | seconds | Time between throws |
| aoe_radius | 50.0 | pixels | Fire pool radius at landing point |
| projectile_speed | 250.0 | px/s | Horizontal travel speed of thrown flask |
| projectile_range | 300.0 | pixels | Max throw distance |
| description | `"抛物线投掷，落点持续灼烧"` | string | |
| color | Color(0.90, 0.40, 0.10) | Color | Orange-red (#E6661A) |

**Throwing-specific constants**:

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| FIREBOMB_THROW_HEIGHT | 80.0 | pixels | Peak of parabolic arc above start |
| FIREBOMB_POOL_DURATION | 2.0 | seconds | Fire pool persists for 2 seconds |
| FIREBOMB_POOL_TICK_INTERVAL | 0.5 | seconds | Damage ticks every 0.5s |
| FIREBOMB_POOL_DAMAGE | 3.0 | HP/tick | Same as weapon damage |
| FIREBOMB_BURN_DPS | 1.5 | DPS | Burn effect after leaving pool |
| FIREBOMB_BURN_DURATION | 1.5 | seconds | Shorter than firestaff (2.0s) |

### 4.3 Level Scaling

| Level | Changes | Effective DPS | Notes |
|-------|---------|--------------|-------|
| Lv1 | 1 flask, 50px pool, 2.5s CD | ~6.0 (3.0x4 ticks/2.0s /2.5s CD) | Single target in pool |
| Lv2 | 2 flasks (spread 40px apart), 60px pool, 2.0s CD | ~12.0 | Doubled coverage, faster throws |
| Lv3 | 2 flasks, 70px pool, 1.5s CD, + burning ground | ~18.0 (+ burn) | Fire pools leave burning ground for 1.5s after pool expires (1.5 DPS) |

**Lv3 Quality Change: Burning Ground**: When the fire pool expires, the area becomes "burning ground" for an additional 1.5 seconds. Enemies on burning ground take 1.5 DPS and are slowed by 20%. This creates overlapping zones of denial.

### 4.4 Evolution: Thunderbomb (thunderbomb)

**Evolution recipe**: firebomb + lightning = thunderbomb

| Attribute | Value | Unit | Notes |
|-----------|-------|------|-------|
| weapon_name | `"雷暴瓶"` | string | |
| weapon_id | `"thunderbomb"` | string | |
| weapon_type | `"throwing"` | string | Same base type |
| damage | 5.0 | HP/tick | 67% increase over base |
| cooldown | 1.2 | seconds | Faster than base Lv3 |
| aoe_radius | 80.0 | pixels | Larger area |
| projectile_range | 400.0 | pixels | Longer throw |
| is_evolved | true | bool | |

**Thunderbomb additional effects**:

| Effect | Value | Notes |
|--------|-------|-------|
| Chain lightning on pool tick | 2 chains, 8.0 damage each | Every pool tick has 30% chance to fire chain lightning from the pool to nearby enemies |
| Shock field | Enemies in pool have 40% slow | Replaces fire pool's burn with electric stun effect |
| Pool duration | 3.0 seconds | Longer than base (2.0s) |

**Thunderbomb DPS estimate**:
- Direct pool: 5.0 x 6 ticks / 1.2s CD = 25.0 DPS (single target in pool)
- Chain lightning: 30% x 8.0 x 2 chains x 6 ticks / 1.2s = 24.0 DPS (spread across targets)
- Total: ~25.0 single target, ~49.0 multi-target with chains

This places thunderbomb in the A-tier (15-20+ DPS range), comparable to fireknife (20.0) and thunderang (28.5). The chain lightning makes it exceptional in dense waves but requires enemies to be clustered near the pool.

### 4.5 Evolution Registration

**weapon_registry.gd addition**:

```gdscript
{"a": "firebomb", "b": "lightning", "result": "thunderbomb"},
```

**upgrade_pool.gd additions**:
- firebomb base weapon registration (Lv1-3 scaling)
- thunderbomb evolved weapon registration

**weapon_data.gd additions**:
- Throwing-specific fields: `throw_height: float`, `pool_duration: float`, `pool_tick_interval: float`, `burn_dps: float`, `burn_duration: float`, `pool_slow_pct: float`, `chain_on_pool: bool`, `chain_count: int`, `chain_damage: float`, `chain_chance: float`

### 4.6 Implementation Notes

**New scripts needed**:
- `scripts/weapons/thrown_flask.gd` (~60 lines) -- parabolic arc projectile
- `scripts/weapons/fire_pool.gd` (~50 lines) -- persistent AoE zone with tick damage

**Parabolic arc implementation**: The flask uses a horizontal velocity (projectile_speed) and a computed vertical velocity to create a parabolic arc. The arc height is determined by FIREBOMB_THROW_HEIGHT. When the flask reaches the target position (or max range), it "lands" and creates a fire_pool instance.

**Targeting**: Same as knife -- targets the nearest enemy within projectile_range. If no enemies in range, throws in the player's facing direction at max range.

---

## 5. Integration Map

### 5.1 Character Select Scene

`character_select.gd` `_characters` array needs a 4th entry:

```gdscript
{
    "id": "necromancer",
    "name": "死灵法师",
    "sprite": "res://assets/sprites/characters/necromancer.png",
    "hp": 7,
    "speed": 150,
    "desc": "击杀越多，伤害越高",
    "ability": "每百杀+2%伤害",
    "color": Color(0.27, 0.13, 0.40),
}
```

Layout change: Currently 3 cards in HBoxContainer. With 4 cards, the layout should still work (4 x 200px = 800px, within typical viewport). If needed, reduce card width to 180px or add scrolling.

### 5.2 Player.gd Changes

- Add `necro_kill_bonus` calculation in `_physics_process` or wherever damage_bonus is computed
- Current damage_bonus path: `weapon_controller.gd line 64: var dmg_bonus = 1.0 + player.damage_bonus`
- For Necromancer: `dmg_bonus = 1.0 + player.damage_bonus + necro_kill_bonus`
- The `necro_kill_bonus` should be computed once per run (not every frame): `min(floor(GameManager.kills / 100.0) * 0.02, 0.20)`

### 5.3 Skill Effects

`skill_effects.gd` needs a new function for death_pulse:

```gdscript
func death_pulse(player: CharacterBody2D) -> void:
    var kills: int = GameManager.kills
    var kill_bonus: float = min(kills * 0.05 * 8.0, 30.0)
    var total_damage: float = 8.0 + kill_bonus
    # ... AoE damage application to all enemies within 120px of player
```

Estimated: ~30 lines in skill_effects.gd.

### 5.4 SaveManager Changes

- Add `chars_cleared["necromancer"]` support for "all characters cleared" achievement
- Achievement `all_chars` parts array: add `"char_necromancer"` with check `s.charId === 'necromancer' && s.elapsed >= 300`
- Mastery system: firebomb needs to be added to BASE_WEAPONS array

### 5.5 Achievement Updates

| Achievement | Change | Priority |
|-------------|--------|----------|
| `all_chars` | Add "char_necromancer" part | P1 |
| `char_necromancer` | New hidden: win with Necromancer | P1 |
| New quests | necromancer_30: kill 30 enemies as Necromancer | P2 |

### 5.6 Synergy Compatibility

The Necromancer can benefit from all existing synergies. Key interactions:

| Synergy | Necromancer Interaction | Notes |
|---------|------------------------|-------|
| frost_regen (frostaura + regen) | Frostaura is starting weapon, natural synergy | Strong interaction -- regen complements low HP |
| frostaura_luckycoin (frostaura + luckycoin) | Starting weapon + gold passive | Good economy synergy |
| knife_crit (knife + crit) | No special interaction | Works if knife is picked up |
| magnet_maxhp (magnet + maxhp) | 1% gem heal + 2% gem heal = independent rolls | Stacking survivability |

---

## 6. Numerical Summary Tables

### 6.1 Necromancer Constants

| Constant | Value | Unit | Notes |
|----------|-------|------|-------|
| NECRO_CHAR_ID | `"necromancer"` | string | |
| NECRO_MAX_HP | 7.0 | HP | |
| NECRO_MOVE_SPEED | 150.0 | px/s | |
| NECRO_PICKUP_RANGE | 45.0 | px | |
| NECRO_START_WEAPON | `"frostaura"` | string | |
| NECRO_PASSIVE_ABILITY | `"kill_bonus"` | string | |
| NECRO_KILLS_PER_TIER | 100 | kills | |
| NECRO_DMG_PER_TIER | 0.02 | multiplier | |
| NECRO_MAX_TIERS | 10 | tiers | |
| NECRO_MAX_DMG_BONUS | 0.20 | multiplier | |
| NECRO_SKILL_CD | 25.0 | seconds | |
| NECRO_SKILL_BASE_DMG | 8.0 | HP | |
| NECRO_SKILL_KILL_RATE | 0.05 | multiplier | |
| NECRO_SKILL_KILL_CAP | 30.0 | HP | |
| NECRO_SKILL_RADIUS | 120.0 | px | |
| NECRO_SKILL_EXPAND | 0.25 | seconds | |
| NECRO_SKILL_SHAKE | 5.0 | intensity | |
| NECRO_SKILL_SHAKE_DUR | 0.12 | seconds | |
| NECRO_GEM_HEAL_CHANCE | 0.01 | fraction | |

### 6.2 Firebomb Constants

| Constant | Value | Unit | Notes |
|----------|-------|------|-------|
| FIREBOMB_WEAPON_ID | `"firebomb"` | string | |
| FIREBOMB_WEAPON_TYPE | `"throwing"` | string | New type |
| FIREBOMB_BASE_DAMAGE | 3.0 | HP/tick | |
| FIREBOMB_COOLDOWN | 2.5 | seconds | |
| FIREBOMB_RADIUS | 50.0 | px | |
| FIREBOMB_SPEED | 250.0 | px/s | |
| FIREBOMB_RANGE | 300.0 | px | |
| FIREBOMB_THROW_HEIGHT | 80.0 | px | |
| FIREBOMB_POOL_DURATION | 2.0 | seconds | |
| FIREBOMB_TICK_INTERVAL | 0.5 | seconds | |
| FIREBOMB_BURN_DPS | 1.5 | DPS | |
| FIREBOMB_BURN_DURATION | 1.5 | seconds | |
| THUNDERBOMB_WEAPON_ID | `"thunderbomb"` | string | |
| THUNDERBOMB_DAMAGE | 5.0 | HP/tick | |
| THUNDERBOMB_COOLDOWN | 1.2 | seconds | |
| THUNDERBOMB_RADIUS | 80.0 | px | |
| THUNDERBOMB_CHAIN_CHANCE | 0.30 | fraction | |
| THUNDERBOMB_CHAIN_COUNT | 2 | count | |
| THUNDERBOMB_CHAIN_DAMAGE | 8.0 | HP | |
| THUNDERBOMB_POOL_DURATION | 3.0 | seconds | |

### 6.3 File Change Budget

| File | Action | Lines | New/Modified |
|------|--------|-------|-------------|
| scripts/character_select.gd | Add necromancer card | +7 | Modified |
| scripts/player.gd | Add necro_kill_bonus + pickup_range + gem_heal | +15 | Modified |
| scripts/skill_effects.gd | Add death_pulse function | +30 | Modified |
| scripts/hud.gd | Add necromancer skill icon color | +2 | Modified |
| scripts/autoload/upgrade_pool.gd | Register firebomb + thunderbomb | +30 | Modified |
| scripts/weapons/weapon_registry.gd | Add firebomb+lightning=thunderbomb | +1 | Modified |
| scripts/data/weapon_data.gd | Add throwing fields | +8 | Modified |
| scripts/weapons/thrown_flask.gd | Parabolic arc projectile | ~60 | New |
| scripts/weapons/fire_pool.gd | Persistent AoE zone | ~50 | New |
| scripts/autoload/save_manager.gd | Add necromancer achievement + firebomb mastery | +8 | Modified |
| tools/generate_sprites.py | Add necromancer sprite | +5 | Modified |
| assets/sprites/characters/necromancer.png | Character sprite | -- | New |
| **Total** | | **~216** | |

---

## 7. Test Cases

### 7.1 Necromancer Tests (~20 tests)

| Test | Verification | Priority |
|------|-------------|----------|
| test_necromancer_in_character_select | 4th card exists with correct data | P0 |
| test_necromancer_base_hp | HP = 7.0 | P0 |
| test_necromancer_base_speed | Speed = 150.0 | P0 |
| test_necromancer_pickup_range | Pickup range = 45.0 | P0 |
| test_necromancer_start_weapon | Start weapon = frostaura | P0 |
| test_necro_kill_bonus_0_kills | Bonus = 0% at 0 kills | P0 |
| test_necro_kill_bonus_100_kills | Bonus = +2% at 100 kills | P0 |
| test_necro_kill_bonus_500_kills | Bonus = +10% at 500 kills | P1 |
| test_necro_kill_bonus_1000_kills | Bonus = +20% at 1000 kills (cap) | P0 |
| test_necro_kill_bonus_2000_kills | Bonus = +20% at 2000 kills (still capped) | P1 |
| test_necro_kill_bonus_applies_to_weapons | Weapon damage increased | P0 |
| test_death_pulse_0_kills | Skill damage = 8.0 at 0 kills | P0 |
| test_death_pulse_200_kills | Skill damage = 16.0 at 200 kills | P1 |
| test_death_pulse_600_kills_capped | Skill damage = 38.0 at 600+ kills | P0 |
| test_death_pulse_cooldown | CD = 25.0s | P1 |
| test_death_pulse_radius | Radius = 120.0 | P1 |
| test_necro_gem_heal_chance | 1% heal chance triggers statistically | P2 |
| test_necromancer_achievement | char_necromancer achievement registers | P1 |
| test_all_chars_4_characters | all_chars achievement requires 4 characters | P1 |

### 7.2 Firebomb Tests (~15 tests)

| Test | Verification | Priority |
|------|-------------|----------|
| test_firebomb_registered | firebomb in upgrade_pool | P0 |
| test_firebomb_weapon_type | weapon_type = "throwing" | P0 |
| test_firebomb_base_damage | Damage = 3.0/tick | P0 |
| test_firebomb_cooldown | CD = 2.5s | P0 |
| test_firebomb_pool_duration | Pool lasts 2.0s | P1 |
| test_firebomb_thunderbomb_recipe | firebomb + lightning = thunderbomb | P0 |
| test_thunderbomb_damage | Damage = 5.0/tick | P0 |
| test_thunderbomb_chain_lightning | Chain triggers at 30% rate | P1 |
| test_firebomb_mastery_tracking | Kills tracked in weapon_kills | P1 |
| test_firebomb_mastery_in_base_weapons | "firebomb" in BASE_WEAPONS array | P0 |

---

## 8. Decision Records

| Decision | Why | Alternative Considered |
|----------|-----|----------------------|
| Necromancer HP = 7 (not 6 or 8) | 7 is between Ranger(6) and Mage(8), with kill-scaling compensating. 6 would make early game too punishing before kills accumulate; 8 would make late game too durable | HP=6 with higher kill scaling (too snowball), HP=8 with lower scaling (too similar to Mage) |
| Kill scaling rate = +2%/100 kills | At Normal run end (~400 kills) = +8%, below Mage's flat +20%. Players must invest in Endless to match Mage | +5%/100 kills (too strong -- +25% at 500 kills), +1%/100 kills (too weak -- barely noticeable) |
| Kill scaling cap = +20% | Prevents Endless mode runaway. Matches Mage's flat bonus as ceiling, ensuring Necromancer never strictly out-damages Mage's ceiling | No cap (Endless at 2000 kills = +40%, broken), +30% cap (too high, trivializes Endless) |
| Pickup range = 45 (vs baseline 35) | +29% pickup range is the Necromancer's "quality of life" advantage. Thematic (soul absorption). Compensates for below-average speed | Speed boost instead (overlaps with Ranger identity), HP regen instead (overlaps with regen passive) |
| Skill damage scales with raw kills (not tiers) | Every kill matters for skill damage, creating continuous feedback. Passive uses tiers (100 per tier) for simplicity, skill uses raw count for granularity | Both use tiers (skill damage steps feel jarring), both use raw (passive display becomes confusing) |
| Skill CD = 25s (longest of 4 chars) | Kill-scaling skill must be expensive to use, preventing spam of the most powerful burst in the game at high kill counts | 20s (same as Mage -- but Necromancer skill scales higher), 30s (too long, feels bad) |
| Firebomb weapon type = "throwing" | New weapon type to distinguish from boomerang (which returns). Throwing = one-way arc + landing AoE | Sub-type of "projectile" (parabolic arc doesn't fit linear projectile model), sub-type of "cone" (wrong shape) |
| Firebomb starting DPS = 6.0 (below average) | Below knife (6.0/2.86 at Lv1) and boomerang (1.67 at Lv1). Firebomb's value is in persistent area denial, not burst DPS. DPS increases when multiple enemies are in the pool | DPS = 8.0 (competitive with ranged weapons -- wrong for an area weapon), DPS = 4.0 (too weak to feel useful) |
| Thunderbomb chain lightning from pool | Creates unique "electric fire" theme that justifies the firebomb+lightning recipe. Chain lightning from a fixed point is a new behavior pattern | Chain from each enemy hit (too chaotic), single target burst (boring, doesn't feel like an evolution) |

---

## 9. v1.2.0 Phase A Audio System Assessment

### 9.1 Audio Spec Review

The audio system spec (`docs/superpowers/specs/v1.2.0-audio-system.md`) was designed in R32 and is comprehensive:

- **Architecture**: AudioManager autoload singleton with 4-bus layout (Master/BGM/SFX/UI)
- **Coverage**: 6 BGM tracks + 33 SFX across 5 categories
- **Implementation**: ~375 lines across 15+ files
- **Test suite**: 25 unit tests + 10 integration tests

### 9.2 Implementation Priority Assessment

| Factor | Score (1-5) | Assessment |
|--------|-------------|------------|
| Player impact | 5 | Audio is the single largest experience gap |
| Design completeness | 5 | Spec is fully detailed with exact file paths, constants, and code samples |
| Implementation risk | 2 | Low technical risk -- Godot audio APIs are well-documented |
| External dependency | 4 | **High risk** -- requires 39 audio files (6 BGM + 33 SFX). Placeholder via AudioStreamGenerator is viable |
| Test coverage plan | 5 | 35 tests defined in spec |
| **Overall priority** | **P0 HIGH** | Should be Phase A of v1.2.0, before character/weapon additions |

### 9.3 Recommendation

**Audio system should be Phase A (first) for v1.2.0.** Reasons:
1. It affects every gameplay scene and needs to be in place before new content (Necromancer needs skill SFX, firebomb needs throw/explosion SFX)
2. The spec is complete and can be handed to Programmer Agent immediately
3. Placeholder sounds (AudioStreamGenerator) allow full pipeline testing without external assets
4. Adding new content on top of audio is easier than retrofitting audio into existing content

**Sequencing**: Phase A (Audio) -> Phase B (Necromancer + Firebomb) -> Phase C (Leaderboard/Chaos)

---

*Spec generated by Designer Agent R33 on 2026-04-18*
