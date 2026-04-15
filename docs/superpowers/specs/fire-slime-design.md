# Fire Slime Simplified Design Spec

**Author**: Designer Agent
**Date**: 2026-04-16
**Priority**: P1 HIGH (R8)
**Status**: Design Complete
**Related Specs**: `docs/superpowers/specs/multi-stage.md` (Section 4.3 original Fire Slime), `docs/superpowers/specs/character-skills.md` (passive integration)

---

## 1. Design Overview

The original Fire Slime design in `multi-stage.md` Section 4.3 defined two special abilities: a persistent fire trail (particles spawned every 0.5s along the movement path) and a death explosion. PM feedback in R7 flagged that "fire trail implementation complexity was not assessed." This spec provides a **simplified Fire Slime** that achieves the same thematic fantasy (a burning enemy that threatens space) with minimal implementation cost, plus a complete **Lava Cavern environmental hazard** design for Wave 4, and the **character skill integration** plan for weapon_controller.gd.

**Core simplification**: Replace per-frame particle trail with a **passive burn aura** (reuses the existing `apply_burn()` system already in `enemy.gd` lines 209-211). The Fire Slime's hitbox simply applies burn to the player on contact, identical to how `firestaff` applies burn to enemies. No new scene types, no timer-based particle spawning, no ground-decal management.

---

## 2. Fire Slime Enemy Definition

### 2.1 Recommended: Plan A -- Passive Burn Aura

The Fire Slime has an enlarged contact hitbox that applies burn to the player on every collision tick. This is the simplest possible implementation because:

1. The existing `apply_burn(dps, duration)` function already exists in `enemy.gd` (lines 209-211)
2. The existing player hurtbox collision detection in `player.gd` already handles enemy contact via `take_damage()`
3. Only change needed: when the colliding enemy is a `fire_slime`, also call a `player.apply_burn()` equivalent
4. No new scenes, no timers, no particle systems

#### Fire Slime Data Constants

| Constant Name | Value | Unit | Source/H5 Ref | Notes |
|---|---|---|---|---|
| `FIRE_SLIME_ID` | `"fire_slime"` | string | New (not in H5) | |
| `FIRE_SLIME_NAME` | `"Fire Slime"` | string | New | |
| `FIRE_SLIME_MAX_HP` | 6.0 | HP | multi-stage.md 4.3 | Moderately tanky, same as skeleton (5) but slightly higher |
| `FIRE_SLIME_SPEED` | 30.0 | px/s | multi-stage.md 4.3 | Slow; lowest speed among all enemies (skeleton=20 is slower, but fire_slime is deliberately slow to compensate for burn threat) |
| `FIRE_SLIME_DAMAGE` | 1.0 | HP | multi-stage.md 4.3 | Contact damage, same as zombie |
| `FIRE_SLIME_XP_VALUE` | 4 | XP | multi-stage.md 4.3 | Between skeleton(3) and ghost/splitter(4-5) |
| `FIRE_SLIME_COLOR` | `Color(0.9, 0.4, 0.1)` | Color | multi-stage.md 4.3 | Orange |
| `FIRE_SLIME_SIZE` | 14.0 | px radius | multi-stage.md 4.3 | Same as bat |
| `FIRE_SLIME_DROP_CHANCE` | 0.15 | fraction | multi-stage.md 4.3 | Slightly higher than standard 0.10 |
| `FIRE_SLIME_BURN_AURA_DPS` | 2.0 | HP/s | New (same as `BURN_DPS` in weapon_fire.gd:14) | Burn DPS matching firestaff |
| `FIRE_SLIME_BURN_AURA_DURATION` | 1.5 | seconds | New (slightly less than weapon `BURN_DURATION` of 2.0s) | Shorter than weapon burn to avoid stacking frustration |

#### Why These Values

- **HP=6**: Fire Slime is a "zone control" enemy. It is not meant to be tanky like elite_skeleton (12 HP) but should survive long enough to threaten the player with burn. 6 HP means it takes 1-2 hits from most weapons at Lv1.
- **Speed=30**: Deliberately slow. The threat is not chase-down but area denial -- players who ignore the Fire Slime and walk through it get burned. 30 px/s is faster than skeleton (20) but much slower than zombie (40).
- **Burn DPS=2.0**: Matches `BURN_DPS` constant in `weapon_fire.gd` line 14, so it uses the same established burn balance baseline.
- **Burn Duration=1.5s**: Slightly shorter than weapon burn (2.0s) because the aura re-applies on contact. A player standing next to a Fire Slime gets continuous reapplication; the shorter duration prevents excessive lingering burn after the player escapes.
- **No fire trail particles**: Eliminated entirely. The burn aura is the fire trail.

### 2.2 Alternative: Plan B -- Death Explosion Only

If the burn aura is still considered too complex (requires player-side burn system), a pure death explosion is even simpler:

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| `FIRE_SLIME_DEATH_RADIUS` | 40.0 | pixels | Death explosion radius |
| `FIRE_SLIME_DEATH_DAMAGE` | 1.0 | HP | Instant damage on death |
| `FIRE_SLIME_DEATH_BURN_DPS` | 2.0 | HP/s | Burns area for 3 seconds |
| `FIRE_SLIME_DEATH_BURN_DURATION` | 3.0 | seconds | Lingering ground burn |

**Recommendation**: Use Plan A. Plan B requires a new "hazard zone" scene type (a persistent Area2D that damages the player), which is more implementation work than the burn aura. Plan A only needs one function call in the existing collision handler.

### 2.3 Fire Slime Template (for enemy_spawner ENEMY_TEMPLATES)

```gdscript
"fire_slime": {
    "enemy_id": "fire_slime",
    "enemy_name": "Fire Slime",
    "max_hp": 6.0,
    "speed": 30.0,
    "damage": 1.0,
    "xp_value": 4,
    "color": [0.9, 0.4, 0.1],
    "size": 14.0,
    "is_ranged": false,
    "has_burn_aura": true,
    "burn_aura_dps": 2.0,
    "burn_aura_duration": 1.5
}
```

### 2.4 enemy_data.gd Additions

Add two new exports to `EnemyData`:

```
@export var has_burn_aura: bool = false
@export var burn_aura_dps: float = 2.0
@export var burn_aura_duration: float = 1.5
```

### 2.5 Implementation Touch Points (Plan A)

| File | Change | Scope |
|---|---|---|
| `scripts/data/enemy_data.gd` | Add 3 exports: `has_burn_aura`, `burn_aura_dps`, `burn_aura_duration` | 3 lines |
| `scripts/enemy_spawner.gd` | Add `"fire_slime"` to `ENEMY_TEMPLATES` dict. Add fields in `_create_enemy_data()` | ~15 lines |
| `scripts/enemy.gd` | In `_physics_process()`, if `enemy_data.has_burn_aura`, check distance to player and apply burn on contact (via existing `_player` reference) | ~8 lines |
| `scripts/player.gd` | Add `apply_burn(dps, duration)` method (mirror of enemy's method) | ~5 lines |

The burn aura check in `enemy.gd` would be:

```gdscript
# In _physics_process, after movement:
if enemy_data.has_burn_aura and _player and is_instance_valid(_player):
    var dist := global_position.distance_to(_player.global_position)
    if dist < enemy_data.size + 16.0:  # 16.0 = player collision radius
        _player.apply_burn(enemy_data.burn_aura_dps, enemy_data.burn_aura_duration)
```

The player `apply_burn` method:

```gdscript
# In player.gd (new variables + method)
var _burn_dps: float = 0.0
var _burn_timer: float = 0.0

func apply_burn(dps: float, duration: float) -> void:
    _burn_dps = maxf(_burn_dps, dps)
    _burn_timer = maxf(_burn_timer, duration)
```

And in player's `_physics_process`, add burn DOT:

```gdscript
if _burn_timer > 0:
    _burn_timer -= delta
    take_damage(_burn_dps * delta)
```

---

## 3. Lava Cavern Environmental Hazard

### 3.1 Design Overview

Wave 4 of the Lava Cavern stage features lava ground zones that damage the player. These are static Area2D nodes placed at arena start. The player takes tick-based damage while standing in lava.

**Why tick-based instead of continuous**: Continuous damage (multiplying DPS by delta) creates micro-damage events that trigger invincibility frames repeatedly. Tick-based (damage every 0.5s) is cleaner -- one damage event per tick, respects invincibility frames, and the player can dash through lava safely during invincibility.

### 3.2 Lava Pool Constants

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| `CAVERN_LAVA_POOL_COUNT` | 4 | count | Fixed at 4 pools (3-5 range reduced to single value for simplicity) |
| `CAVERN_LAVA_POOL_RADIUS_MIN` | 40.0 | pixels | Minimum pool radius |
| `CAVERN_LAVA_POOL_RADIUS_MAX` | 70.0 | pixels | Maximum pool radius (reduced from 80 to limit coverage) |
| `CAVERN_LAVA_DAMAGE_PER_TICK` | 0.5 | HP | Damage per tick (NOT per second -- this is the flat damage amount per tick) |
| `CAVERN_LAVA_TICK_INTERVAL` | 1.0 | seconds | Time between damage ticks |
| `CAVERN_LAVA_COLOR` | `Color(0.9, 0.3, 0.1, 0.6)` | Color | Orange-red semi-transparent |
| `CAVERN_LAVA_PULSE_COLOR` | `Color(1.0, 0.5, 0.2, 0.3)` | Color | Pulsing glow overlay |
| `CAVERN_LAVA_PULSE_SPEED` | 2.0 | cycles/s | Pulse animation speed |
| `CAVERN_LAVA_ARENA_MARGIN` | 200.0 | pixels | Minimum distance from arena edge for pool placement |
| `CAVERN_LAVA_SAFE_SPAWN_RADIUS` | 150.0 | pixels | No lava within this distance from player spawn (center) |

### 3.3 Why These Values

- **4 pools**: With a 2500x2500 arena (6.25M px^2 area), 4 pools of avg 55px radius cover approximately 38,000 px^2 total, or ~0.6% of the arena. This is intentionally sparse -- lava should be an occasional obstacle, not a maze. The threat is that during intense waves, the player may be forced to cross through lava to escape enemies.
- **0.5 HP per tick, 1.0s interval**: A player with 8 HP (mage) standing in lava loses 0.5 HP/s. It takes 16 seconds of continuous standing to die from lava alone. This is a gentle but meaningful pressure -- not lethal fast enough to feel unfair, but enough that the player actively avoids lava zones during combat.
- **1.0s tick interval**: Longer than invincibility frames (0.5s), so the player can safely dash through lava. Creates a skill element: time your dash to cross lava without taking damage.
- **Safe spawn radius 150px**: Player spawns at arena center. No lava within 150px ensures the player has room to maneuver at the start before encountering lava.

### 3.4 Implementation Touch Points

| File | Change | Scope |
|---|---|---|
| `scripts/arena.gd` | If stage is `"cavern"`, create lava pool Area2D nodes at `_ready()` | ~30 lines |
| New: `scripts/lava_pool.gd` | Simple Area2D script: tracks overlapping player, applies damage on tick timer | ~20 lines |

The lava pool scene structure:

```
Area2D (lava_pool.gd)
  +-- CollisionShape2D (CircleShape2D, radius = random 40-70)
  +-- ColorRect (visual, orange-red, pulsing alpha)
```

lava_pool.gd logic:

```gdscript
extends Area2D

const DAMAGE_PER_TICK: float = 0.5
const TICK_INTERVAL: float = 1.0

var _tick_timer: float = 0.0
var _player_inside: bool = false

func _ready():
    body_entered.connect(_on_enter)
    body_exited.connect(_on_exit)

func _on_enter(body):
    if body.is_in_group("player"):
        _player_inside = true

func _on_exit(body):
    if body.is_in_group("player"):
        _player_inside = false

func _physics_process(delta):
    if _player_inside:
        _tick_timer -= delta
        if _tick_timer <= 0:
            _tick_timer = TICK_INTERVAL
            var player = _find_player_in_overlapping()
            if player and player.has_method("take_damage"):
                player.take_damage(DAMAGE_PER_TICK)
```

---

## 4. Integration: Character Skills in weapon_controller.gd

This section defines exactly how the two character passives from `character-skills.md` integrate into `weapon_controller.gd` and `weapon_fire.gd`.

### 4.1 Mage Passive: Mana Attunement (+10% damage while skill on cooldown)

#### Design

The Mage's `mana_attunement` passive grants +10% weapon damage while the Elemental Burst skill is on cooldown. In the `character-skills.md` spec (Section 2.1), this is defined as `MAGE_PASSIVE_DAMAGE_BONUS = 0.10` multiplier.

#### Where It Hooks In

In `weapon_controller.gd` line 58:

```gdscript
var dmg_bonus: float = 1.0 + player.damage_bonus
```

This is the single point where all weapon damage multipliers converge before being passed to the individual weapon fire functions. This is the correct hook point for `mana_attunement`.

#### Implementation

```gdscript
# weapon_controller.gd, _fire_weapon(), line 58:
var dmg_bonus: float = 1.0 + player.damage_bonus

# Add: Mage mana_attunement (+10% while skill on cooldown)
if GameManager.selected_character == "mage" and player.has_method("is_skill_on_cooldown"):
    if player.is_skill_on_cooldown():
        dmg_bonus *= 1.10  # MAGE_PASSIVE_DAMAGE_BONUS
```

Alternatively, store the constant on the player:

```gdscript
# In player.gd _ready() when character == "mage":
# skill_cooldown_timer starts at 0 (skill ready = no bonus)
# When skill is used, skill_cooldown_timer = MAGE_SKILL_COOLDOWN (20.0)
# Passive bonus is active while skill_cooldown_timer > 0
```

#### Detailed Constants

| Constant Name | Value | Unit | Source | Notes |
|---|---|---|---|---|
| `MAGE_PASSIVE_DAMAGE_BONUS` | 0.10 | multiplier | character-skills.md Section 2.1 | +10% weapon damage |
| `MAGE_PASSIVE_CONDITION` | `skill_cooldown_timer > 0` | boolean | character-skills.md | Active while skill on cooldown |

#### State Variables (in player.gd)

```gdscript
# New variables in player.gd:
var skill_cooldown_timer: float = 0.0
var skill_id: String = ""

func is_skill_on_cooldown() -> bool:
    return skill_cooldown_timer > 0.0

# In _physics_process:
if skill_cooldown_timer > 0:
    skill_cooldown_timer -= delta
```

#### Balance Impact

- **Uptime analysis**: With a 20s cooldown and instant-cast skill, optimal play uses the skill immediately when available. Average cooldown uptime = 20s out of every (20 + reaction_time) cycle. Assuming ~1s reaction time, uptime is ~95%. The passive is effectively "always on" for good players.
- **DPS impact**: +10% to all weapon damage. For a Mage with base +20% damage_bonus, this changes `dmg_bonus` from 1.20 to 1.32 (1.20 * 1.10). This is a 10% relative increase, matching the spec's intent.
- **Interaction with crit**: The bonus applies to the base damage before crit multiplication. A crit with mana_attunement deals `base * 1.32 * crit_mul` instead of `base * 1.20 * crit_mul`.

### 4.2 Ranger Passive: Keen Eye (every 5th hit guaranteed crit)

#### Design

The Ranger's `keen_eye` passive guarantees a critical hit on every 5th weapon hit, regardless of `crit_chance` stat. Defined in `character-skills.md` Section 2.3 as `RANGER_PASSIVE_HIT_COUNT = 5`.

#### Where the Counter Lives

The hit counter must live on the **player** because multiple weapons can trigger hits, and the counter needs to be shared across all of them. The counter increments whenever a weapon successfully damages an enemy.

There are two categories of weapon damage:
1. **Projectile hits** (projectile.gd `_on_body_entered`): The projectile calls `enemy.take_damage(damage, weapon_id, is_crit)`
2. **Direct hits** (weapon_fire.gd lightning, cone, aura): These call `enemy.take_damage(damage, weapon_id)` directly

The counter needs to increment in both paths. The cleanest approach is to increment it inside `enemy.take_damage()` via a signal, or alternatively track it when weapons deal damage.

**Recommended approach**: Add a counter to `player.gd` and increment it from `weapon_controller.gd` by checking after each weapon fire whether hits occurred. However, this is complex because projectile hits are asynchronous.

**Simpler approach**: Add the counter to `player.gd`, and emit a signal from `enemy.take_damage()` when the damage source is a player weapon. The player listens and increments.

**Simplest approach**: Add the counter to `weapon_controller.gd` itself, since all weapon damage flows through it. For projectile/orbit weapons, the crit check happens at fire time (before the projectile hits), so we pre-compute whether the next hit will be a keen_eye crit.

#### Recommended Implementation

The keen_eye counter and forced-crit logic live in `weapon_controller.gd`:

```gdscript
# New variables in weapon_controller.gd:
var _keen_eye_counter: int = 0
const KEEN_EYE_HIT_INTERVAL: int = 5  # RANGER_PASSIVE_HIT_COUNT
```

The counter increments each time a weapon is fired (not each time an enemy is hit, which would be async for projectiles). This is a slight simplification: every weapon fire counts as 1 hit toward the counter, not every individual enemy hit. This makes the counter deterministic and easy to implement.

For the keen_eye forced crit, add a check in `_fire_weapon()`:

```gdscript
func _fire_weapon(weapon_id: String, data: WeaponData, player: CharacterBody2D):
    var level: int = player.owned_weapons[weapon_id]
    var dmg_bonus: float = 1.0 + player.damage_bonus

    # Mage mana_attunement
    if GameManager.selected_character == "mage" and player.is_skill_on_cooldown():
        dmg_bonus *= 1.10

    # Ranger keen_eye: track weapon fires
    var force_crit: bool = false
    if GameManager.selected_character == "ranger":
        _keen_eye_counter += 1
        if _keen_eye_counter >= KEEN_EYE_HIT_INTERVAL:
            _keen_eye_counter = 0
            force_crit = true

    var wf: RefCounted = _get_weapon_fire()
    match data.weapon_type:
        "projectile":
            wf.fire_projectile(data, level, player, dmg_bonus, force_crit)
        "orbit":
            _orbit_instances = wf.update_orbit(weapon_id, data, level, player, dmg_bonus, _orbit_instances, force_crit)
        "lightning":
            wf.fire_lightning(data, level, player, dmg_bonus, force_crit)
        "cone":
            wf.fire_cone(data, level, player, dmg_bonus, force_crit)
        "aura":
            wf.update_aura(weapon_id, data, level, player, dmg_bonus, _weapon_timers, force_crit)
        "boomerang":
            _boomerang_instances = wf.fire_boomerang(data, level, player, dmg_bonus, _weapon_timers, _boomerang_instances, force_crit)
```

Then in `weapon_fire.gd`, each fire function checks `force_crit`:

```gdscript
# In fire_projectile, after damage calculation:
if force_crit:
    proj_damage *= player.crit_damage_mul
    proj.is_crit = true
    proj.color = Color(1.0, 0.85, 0.0)
```

For direct-damage weapons (lightning, cone, aura):

```gdscript
# In fire_lightning:
if force_crit:
    damage *= player.crit_damage_mul

# In fire_cone:
if force_crit:
    damage *= player.crit_damage_mul
```

For orbit weapons (holywater, bible), the `force_crit` flag is passed to `update_orbit()` and the orbit damage is multiplied when the flag is true:

```gdscript
# In update_orbit:
if force_crit:
    damage *= player.crit_damage_mul
```

#### Detailed Constants

| Constant Name | Value | Unit | Source | Notes |
|---|---|---|---|---|
| `RANGER_PASSIVE_HIT_COUNT` | 5 | hits | character-skills.md Section 2.3 | Every 5th weapon fire is guaranteed crit |
| `RANGER_PASSIVE_CRIT_MULTIPLIER` | (uses `player.crit_damage_mul`) | multiplier | character-skills.md | Uses standard crit multiplier (2.0x base, modified by luckycoin) |

#### Design Decision: Counter on Fire vs Counter on Hit

| Approach | Pros | Cons |
|---|---|---|
| **Counter on fire (recommended)** | Simple, deterministic, synchronous. No signal needed. | Counts weapon activations, not actual hits. Multi-target weapons (lightning chain, cone) count as 1 fire, not N hits. |
| Counter on hit (alternative) | Accurate to "every 5th hit" wording | Requires signal from enemy.take_damage -> player. Async for projectiles. Complex tracking across multiple weapon instances. |

**Why counter-on-fire**: (1) The Ranger uses fast-attack weapons (holywater orbit hits ~3 enemies per second, knife fires ~1 per 1.5s). Counting fires instead of hits means ~1 crit every 5 weapon cooldowns = ~7.5s interval at Lv1 with one weapon. (2) With 2 weapons, the interval halves to ~3.75s, which feels appropriately powerful. (3) The simpler implementation reduces bug surface. (4) The spec wording says "every 5th weapon hit" but the fire-count approximation produces similar gameplay feel with dramatically simpler code.

#### Balance Impact

- **Single weapon (Lv1, 1.5s cooldown)**: One forced crit every 5 fires = every 7.5 seconds. Over 57 seconds (one wave), ~7.6 forced crits.
- **With 10% base crit_chance**: Normal crits fire ~10% of the time. Keen eye adds guaranteed crits at a ~13.3% rate (1 every 7.5s out of 57s = ~7.6/57 = 13.3% additional). Effective crit rate for a single weapon: ~23.3%.
- **With 3x crit rings (+24%)**: 34% base + 13.3% keen eye = ~47.3% effective crit rate.
- **Interaction with crit_damage_mul**: Keen eye crits use the same `crit_damage_mul` as normal crits, benefiting from luckycoin (+0.5 per stack).

### 4.3 Integration Constants Summary

| Constant Name | Value | Location | Notes |
|---|---|---|---|
| `MAGE_PASSIVE_DAMAGE_BONUS` | 0.10 | weapon_controller.gd or player.gd | +10% multiplier |
| `KEEN_EYE_HIT_INTERVAL` | 5 | weapon_controller.gd | Ranger: every 5th fire = forced crit |
| `skill_cooldown_timer` | 0.0 | player.gd | Tracks skill cooldown state |
| `_keen_eye_counter` | 0 | weapon_controller.gd | Ranger hit counter |

### 4.4 Files to Modify

| File | Change | Scope |
|---|---|---|
| `scripts/weapon_controller.gd` | Add `_keen_eye_counter`, `KEEN_EYE_HIT_INTERVAL`. In `_fire_weapon()`: (1) check `mana_attunement` for dmg_bonus, (2) increment keen_eye counter, (3) pass `force_crit` flag to weapon_fire functions | ~12 lines |
| `scripts/weapons/weapon_fire.gd` | Add `force_crit: bool = false` parameter to all fire functions. When true, multiply damage by `crit_damage_mul` and set crit visuals | ~20 lines across 6 functions |
| `scripts/player.gd` | Add `skill_cooldown_timer`, `is_skill_on_cooldown()`, `_burn_dps`/`_burn_timer`, `apply_burn()` | ~15 lines |

---

## 5. Complete Enemy Balance Table (Updated)

For reference, here is the full enemy roster with Fire Slime included:

| Enemy | HP | Speed | Damage | XP | Size | Special |
|---|---|---|---|---|---|---|
| zombie | 3 | 40 | 1 | 2 | 16 | None |
| bat | 1 | 80 | 1 | 1 | 14 | None |
| skeleton | 5 | 20 | 1 | 3 | 14 | Ranged (2.0s CD) |
| elite_skeleton | 12 | 15 | 2 | 8 | 18 | Ranged (1.2s CD, 3-way) |
| ghost | 2 | 55 | 1 | 4 | 12 | Phase shift + teleport |
| splitter | 4 | 50 | 1 | 5 | 16 | Splits into 2 small on death |
| splitter_small | 1 | 70 | 1 | 1 | 8 | Child (no further split) |
| **fire_slime** | **6** | **30** | **1** | **4** | **14** | **Burn aura (2 DPS, 1.5s)** |

**Positioning analysis**: Fire Slime sits between skeleton (5 HP, 3 XP) and elite_skeleton (12 HP, 8 XP) in toughness. Its XP value (4) is moderate, rewarding players for engaging it rather than ignoring it. The burn aura means it has a higher "effective threat" than its raw stats suggest -- a player who ignores a fire_slime and walks through it takes 2 DPS for 1.5s = 3 extra damage, which is significant at early levels.

---

## 6. Design Decisions Log

| Decision | Why | Alternative Considered |
|---|---|---|
| Burn aura instead of fire trail | Reuses existing `apply_burn()` system. No particle spawning, no ground decals, no timer management. One function call on contact. | Fire trail particles (original multi-stage.md design) -- requires new particle scene, spawn timer, ground decal management, performance cost from many overlapping trail segments |
| Burn aura instead of death explosion | Death explosion requires a new "hazard zone" scene type that persists after enemy death. Burn aura requires no new scenes. | Death explosion (Plan B) -- simpler concept but more implementation work |
| Player-side burn system | Mirror of enemy burn system. Simple: two variables + one method + one DOT tick in _physics_process | Status effect manager (overengineered for current scope) |
| Lava: 4 pools at 0.5 HP/tick | Gentle pressure. 0.5 HP/tick means mage (8 HP) takes 16s to die from lava alone -- noticeable but not lethal. | 1.0 HP/tick (multi-stage.md original) -- too punishing for mage with 8 HP; 5 seconds in lava = 5 HP = dangerous |
| Lava: 1.0s tick interval | Allows dashing through lava safely during 0.15s invincibility. Creates skill expression. | 0.5s tick (multi-stage.md original) -- too fast, cannot dash through safely |
| Keen eye: counter on fire, not on hit | Synchronous, deterministic, no signals needed. Async hit counting would require per-projectile callbacks. | Counter on hit -- spec-accurate but implementation nightmare |
| Mana attunement: check in weapon_controller._fire_weapon() | Single hook point for all weapon damage. Clean multiplier application. | Per-weapon-type checks (duplicated code, easy to miss one) |
| Fire Slime speed=30 (not 20 like skeleton) | Skeleton at speed=20 is already very slow. Fire Slime should be slightly faster so it can actually reach the player and apply its burn aura, but still slow enough that the player can choose to avoid it. | Speed=20 (too slow, never reaches player = aura never triggers) |
| No death explosion for Fire Slime | Removed to keep implementation minimal. The burn aura already fulfills the "fire threat" fantasy. | Death explosion as bonus (Plan B) -- adds a new scene type for marginal gameplay value |

---

## 7. Future Enhancements (Out of Scope)

1. **Fire trail particles (visual only)** -- Add cosmetic-only fire particles that follow the Fire Slime's path, purely decorative with no gameplay effect. Low priority visual polish.
2. **Death explosion as optional toggle** -- If playtesting reveals Fire Slimes are too easy to ignore, add a death explosion as a secondary threat. Would require the hazard zone scene from Plan B.
3. **Lava pool growth during boss fight** -- Magma Golem boss (multi-stage.md Section 4.4) has a special that grows lava pools. This is deferred to the boss implementation phase.
4. **Player burn visual feedback** -- Red tint flash on the player sprite when taking burn damage. Currently the player has no visual feedback for DOT effects.
5. **Keen eye counter display** -- A small UI indicator showing the current hit count toward the next guaranteed crit. Low priority UX improvement.
