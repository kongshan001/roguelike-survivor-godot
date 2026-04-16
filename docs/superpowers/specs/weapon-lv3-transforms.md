# Weapon Lv3 Quality-Change Transforms -- Priority Sort + Implementation Spec

**Author**: Designer Agent
**Date**: 2026-04-16
**Priority**: P1 HIGH
**Status**: Design Complete
**Parent Spec**: `docs/superpowers/specs/character-upgrade-paths.md` Section 3

---

## 1. Design Overview

This spec takes the 7 weapon Lv3 quality-change effects defined in `character-upgrade-paths.md` Section 3 and provides: (a) a priority ranking based on implementation cost vs player experience value, and (b) detailed implementation specifications for the TOP 3 effects with precise file paths, function names, code modification points, and numerical constants.

The goal is to give the Programmer Agent a complete, actionable blueprint that requires zero additional design clarification.

---

## 2. Priority Ranking

### 2.1 Evaluation Criteria

Each effect is scored on three dimensions (1-5 scale):

- **Implementation Complexity** (lower = easier): Lines of new code, number of files touched, need for new scene/node types
- **Player Experience Value** (higher = better): How noticeable and satisfying the effect feels during gameplay
- **System Integration Risk** (lower = safer): Likelihood of breaking existing weapon behavior, synergy interactions, or evolution recipes

### 2.2 Scoring Matrix

| Rank | Weapon | Lv3 Effect | Impl. Complexity | XP Value | Integration Risk | Composite | Tier |
|---|---|---|---|---|---|---|---|
| 1 | Knife | Ricochet (1 bounce, 50% dmg) | 2 | 5 | 1 | **Best** | A |
| 2 | Frost Aura | Shatter (2.0 dmg on frozen kill) | 2 | 4 | 1 | **Best** | A |
| 3 | Boomerang | Homing Tweak (50% more tracking) | 1 | 3 | 1 | **Good** | A |
| 4 | Lightning | Chain On Kill (50% dmg bonus bolt) | 3 | 4 | 2 | Good | B |
| 5 | Bible | Expanding Aura (1.5 dmg / 2s pulse) | 3 | 3 | 2 | Good | B |
| 6 | Holy Water | Frost Blessing (15% freeze) | 3 | 3 | 2 | OK | B |
| 7 | Fire Staff | Searing Flames (burn zone) | 5 | 3 | 3 | Low | C |

### 2.3 Ranking Justification

**Tier A (Implement First)**:

1. **Knife Ricochet** -- Knife is the most common starting weapon (Mage default). Ricochet transforms it from pure single-target to limited multi-target, which is immediately noticeable in the first 30 seconds. Implementation is self-contained within `projectile.gd` `_on_body_entered()`. No new scenes, no signals, no external state. The projectile already knows its weapon_id and damage; we just need to spawn one additional projectile on primary hit.

2. **Frost Aura Shatter** -- Frost Aura is the only aura-type weapon. Shatter creates a satisfying chain-reaction mechanic that rewards the freeze playstyle. Implementation is in `enemy.gd` `die()`, which already has `_freeze_timer`, `_last_hit_by`, and enemy group queries via `get_tree().get_nodes_in_group("enemies")`. The player already owns frostaura, so we can check weapon level from player.owned_weapons. No new scenes, no signals, no external state.

3. **Boomerang Homing Tweak** -- Purely numerical change, the simplest possible implementation. One multiplication in `weapon_fire.gd` `fire_boomerang()` at the track_angle calculation. Zero new code paths, zero new scenes, zero risk. Lower XP value than the others (it is an accuracy buff, not a new mechanic), but the near-zero cost makes it an easy win.

**Tier B (Implement Second)**:

4. **Lightning Chain On Kill** -- Requires a signal or callback from `enemy.gd` `die()` back to `weapon_controller.gd` or `weapon_fire.gd`. The `_last_hit_by == "lightning"` check is trivial, but the bonus bolt requires calling `fire_lightning()` or creating a simplified bolt effect, which means weapon_controller needs to know about the kill event. Moderate integration risk.

5. **Bible Expanding Aura** -- Requires a new timer in `weapon_controller.gd` (or `weapon_fire.gd` `update_orbit()`) that pulses damage every 2s. The pulse logic itself is simple (query enemies within 60px, deal 1.5 damage), but it adds state that must be cleaned up when the weapon is removed or evolved. Moderate integration risk.

6. **Holy Water Frost Blessing** -- Requires modifying `spin_blade.gd` to pass weapon level through the setup chain and add a `randf()` roll in the per-blade hit logic. The `spin_blade.gd` currently does not know about weapon levels; this information must be threaded from `weapon_fire.gd` `update_orbit()` through `spin_blade.gd` `setup()`. Moderate integration cost.

**Tier C (Implement Last)**:

7. **Fire Staff Searing Flames** -- Requires creating a new persistent Area2D scene (burn zone) that ticks damage over time. This is the only effect that needs a brand-new scene type not currently in the codebase. While the individual logic is simple, it introduces a new entity lifecycle (spawn, tick, expire, cleanup) that must integrate with the ProjectileManager or arena. Highest implementation cost and integration risk.

---

## 3. TOP 1: Knife Lv3 Ricochet

### 3.1 Mechanic Definition

When a Knife projectile (weapon_id == "knife") hits its primary target, if the weapon is at Lv3, the projectile bounces to 1 additional nearby enemy within 100px, dealing 50% of the original damage.

### 3.2 Numerical Constants

| Constant Name | Value | Unit | File Location |
|---|---|---|---|
| `KNIFE_LV3_RICOCHET_COUNT` | 1 | count | `scripts/weapons/weapon_fire.gd` (add to top) |
| `KNIFE_LV3_RICOCHET_RANGE` | 100.0 | pixels | `scripts/weapons/weapon_fire.gd` (add to top) |
| `KNIFE_LV3_RICOCHET_DAMAGE_MUL` | 0.5 | multiplier | `scripts/weapons/weapon_fire.gd` (add to top) |
| `KNIFE_LV3_RICOCHET_SIZE` | 4.0 | pixels | `scripts/weapons/weapon_fire.gd` (add to top) |
| `KNIFE_LV3_RICOCHET_SPEED` | 300.0 | px/s | `scripts/weapons/weapon_fire.gd` (add to top) |
| `KNIFE_LV3_RICOCHET_LIFETIME` | 0.5 | seconds | `scripts/weapons/weapon_fire.gd` (add to top) |

### 3.3 Files to Modify

#### File 1: `scripts/weapons/weapon_fire.gd`

**Add constants** (after line 28, the existing `BOOMERANG_MAX_COUNT` constant):

```gdscript
# Knife Lv3: Ricochet
const KNIFE_LV3_RICOCHET_RANGE: float = 100.0
const KNIFE_LV3_RICOCHET_DAMAGE_MUL: float = 0.5
const KNIFE_LV3_RICOCHET_SPEED: float = 300.0
const KNIFE_LV3_RICOCHET_SIZE: float = 4.0
const KNIFE_LV3_RICOCHET_LIFETIME: float = 0.5
```

**Add new variable** (after line 29, alongside `var _controller`):

```gdscript
var _knife_weapon_level: int = 1  # Cached level for ricochet check
```

**Modify `fire_projectile()`** (lines 53-100):

At the start of the function (after line 55 `var damage: float = ...`), cache the weapon level for the projectile to use later:

```gdscript
if data.weapon_id == "knife":
    _knife_weapon_level = level
```

**Why here**: The `fire_projectile()` function already receives `level: int` and `data.weapon_id`. We cache it so that when `projectile.gd` fires its `_on_body_entered()` callback, the ricochet logic can check it. However, a cleaner approach is to pass the weapon level directly to the projectile. Since `projectile.gd` does not currently have a `weapon_level` field, the recommended approach is to add a small field to projectile.

#### File 2: `scripts/projectile.gd`

**Add new variable** (after line 18, alongside existing `var weapon_id: String = ""`):

```gdscript
var weapon_level: int = 1
```

**Modify `setup()`** signature (line 22) to accept weapon level:

This is not recommended because `setup()` is called from many places. Instead, set `weapon_level` as a separate property after setup, in `weapon_fire.gd` `fire_projectile()`.

**Modify `_on_body_entered()`** (lines 62-73):

After the existing damage logic (line 70 `_hit_enemies.append(body)`), before the `pierce <= 0` check, add ricochet logic:

```gdscript
func _on_body_entered(body: Node2D):
    if body.is_in_group("enemies") and body.has_method("take_damage") and not body in _hit_enemies:
        body.take_damage(damage, weapon_id, is_crit)
        # Apply status effects
        if burn_dps > 0.0 and burn_duration > 0.0 and body.has_method("apply_burn"):
            body.apply_burn(burn_dps, burn_duration)
        if slow_pct > 0.0 and body.has_method("apply_slow"):
            body.apply_slow(slow_pct)
        _hit_enemies.append(body)

        # Knife Lv3 Ricochet
        if weapon_id == "knife" and weapon_level >= 3:
            _spawn_ricochet(body)

        pierce -= 1
        if pierce <= 0:
            queue_free()
```

**Add new function** `_spawn_ricochet()` at the end of projectile.gd (after `_physics_process`):

```gdscript
func _spawn_ricochet(primary_target: Node2D) -> void:
    var enemies := get_tree().get_nodes_in_group("enemies")
    var best_enemy: Node2D = null
    var best_dist: float = 100.0  # KNIFE_LV3_RICOCHET_RANGE
    for enemy in enemies:
        if is_instance_valid(enemy) and enemy.is_alive and enemy != primary_target and not enemy in _hit_enemies:
            var dist := global_position.distance_to(enemy.global_position)
            if dist < best_dist:
                best_dist = dist
                best_enemy = enemy
    if best_enemy == null:
        return
    # Spawn a new ricochet projectile toward the bounce target
    var ricochet: Area2D = preload("res://scenes/projectile.tscn").instantiate()
    ricochet.global_position = primary_target.global_position
    ricochet.direction = primary_target.global_position.direction_to(best_enemy.global_position)
    ricochet.speed = 300.0  # KNIFE_LV3_RICOCHET_SPEED
    ricochet.damage = damage * 0.5  # KNIFE_LV3_RICOCHET_DAMAGE_MUL
    ricochet.pierce = 0
    ricochet.color = Color(1.0, 0.9, 0.5)  # Golden tint to indicate ricochet
    ricochet.size = 4.0  # KNIFE_LV3_RICOCHET_SIZE
    ricochet.weapon_id = "knife"
    ricochet.weapon_level = weapon_level
    ricochet.lifetime = 0.5  # KNIFE_LV3_RICOCHET_LIFETIME
    get_parent().call_deferred("add_child", ricochet)
```

#### File 3: `scripts/weapons/weapon_fire.gd` (second modification)

In `fire_projectile()`, after line 79 where `proj.setup()` is called and before line 81 `var proj_damage`, add:

```gdscript
if data.weapon_id == "knife":
    proj.weapon_level = level
```

This sets the weapon level on the projectile so it knows whether to trigger ricochet.

### 3.4 Integration Points

| Integration Point | Description | Risk |
|---|---|---|
| projectile.gd `_on_body_entered()` | Ricochet triggers on primary hit only | Low -- pierce > 0 means primary target; ricochet does not affect pierce count |
| projectile.gd `_spawn_ricochet()` | New function, self-contained | Low -- searches enemy group, spawns one projectile, exits |
| weapon_fire.gd `fire_projectile()` | Sets weapon_level on knife projectiles | Low -- one additional property assignment |
| Evolved weapons (fireknife, frostknife) | Evolved weapons have `is_evolved = true` and do NOT go through the knife ricochet path (they have their own weapon_ids: "fireknife", "frostknife") | None -- ricochet only triggers on `weapon_id == "knife"` |

### 3.5 Estimated Code Lines

| File | New Lines | Modified Lines | Total |
|---|---|---|---|
| `scripts/weapons/weapon_fire.gd` | 7 (constants) + 2 (level cache) | 2 (set weapon_level) | 11 |
| `scripts/projectile.gd` | 1 (weapon_level var) + 25 (_spawn_ricochet) + 5 (ricochet call in _on_body_entered) | 3 (add ricochet block) | 34 |
| **Total** | | | **~45 lines** |

### 3.6 Balance Analysis

- Knife Lv1: 1 projectile, 2.0 damage, 0.7s CD = 2.86 DPS (single target)
- Knife Lv3 (current): 3 projectiles, 3.2 damage, 0.7s CD = 13.7 DPS (single target)
- Knife Lv3 (with ricochet): 3 projectiles x (3.2 primary + 1.6 ricochet vs 2nd target) = 14.4 DPS primary + up to 6.9 DPS secondary = ~21.3 DPS total vs 2 targets
- Effective boost: ~55% vs 2 targets, ~0% vs 1 target (ricochet has no target)
- This is within acceptable range because it only triggers when 2+ enemies are within 100px

### 3.7 Why This Design

- **Ricochet instead of pierce+1**: Ricochet bounces to a NEARBY enemy (within 100px), creating a new targeting pattern. Pierce+1 would just make the knife go through the target, which is less interesting and overlaps with the evolved fireknife/frostknife which already have pierce.
- **50% damage on bounce**: Prevents ricochet from being stronger than the primary hit. The bounce is a bonus, not the main damage source.
- **0.5s lifetime on ricochet projectile**: Prevents ricochet knives from traveling across the screen. They are short-range bounces that feel like a "splash" effect.
- **Golden tint**: Provides visual feedback that the Lv3 effect is active, distinguishing ricochet knives from regular ones.

---

## 4. TOP 2: Frost Aura Lv3 Shatter

### 4.1 Mechanic Definition

When a frozen enemy dies, if the player has Frost Aura at Lv3, the enemy shatters, dealing 2.0 damage to all enemies within 50px of the dying enemy's position.

### 4.2 Numerical Constants

| Constant Name | Value | Unit | File Location |
|---|---|---|---|
| `FROSTAURA_LV3_SHATTER_RADIUS` | 50.0 | pixels | `scripts/weapons/weapon_fire.gd` (add to top) |
| `FROSTAURA_LV3_SHATTER_DAMAGE` | 2.0 | HP | `scripts/weapons/weapon_fire.gd` (add to top) |

### 4.3 Files to Modify

#### File 1: `scripts/weapons/weapon_fire.gd`

**Add constants** (after the existing Aura constants around line 19):

```gdscript
# Frost Aura Lv3: Shatter
const FROSTAURA_LV3_SHATTER_RADIUS: float = 50.0
const FROSTAURA_LV3_SHATTER_DAMAGE: float = 2.0
```

#### File 2: `scripts/enemy.gd`

**Modify `die()` function** (line 233-245):

After `_handle_kill_rewards()` call (line 238) and before `_spawn_xp_gems()` (line 239), add the shatter logic:

```gdscript
func die() -> void:
    if not is_alive:
        return
    is_alive = false

    _handle_kill_rewards()
    _handle_shatter()        # NEW: Frost Aura Lv3 shatter check
    _spawn_xp_gems()
    _spawn_food_drop()
    _spawn_crate_drop()
    _handle_boss_death()
    _handle_splitter_death()

    queue_free()
```

**Add new function** `_handle_shatter()` in enemy.gd (after `_handle_kill_rewards`):

```gdscript
func _handle_shatter() -> void:
    # Frost Aura Lv3: Shatter -- frozen enemy explodes on death
    if _freeze_timer <= 0.0:
        return  # Not frozen, no shatter
    var player: Node2D = _find_player()
    if not player or not is_instance_valid(player):
        return
    if not player.owned_weapons.has("frostaura"):
        return
    if player.owned_weapons["frostaura"] < 3:
        return  # Not Lv3 yet
    # Shatter: deal 2.0 damage to all enemies within 50px
    var shatter_radius: float = 50.0  # FROSTAURA_LV3_SHATTER_RADIUS
    var shatter_damage: float = 2.0    # FROSTAURA_LV3_SHATTER_DAMAGE
    var all_enemies := get_tree().get_nodes_in_group("enemies")
    for enemy in all_enemies:
        if is_instance_valid(enemy) and enemy.is_alive and enemy != self:
            var dist := global_position.distance_to(enemy.global_position)
            if dist <= shatter_radius:
                enemy.take_damage(shatter_damage, "frostaura")
    # Optional: visual effect -- create a brief white circle
    _spawn_shatter_effect()
```

**Add visual helper** `_spawn_shatter_effect()`:

```gdscript
func _spawn_shatter_effect() -> void:
    var circle: Node2D = Node2D.new()
    circle.global_position = global_position
    var script := GDScript.new()
    script.source_code = """extends Node2D
var alpha: float = 0.6
func _process(delta):
    alpha -= delta * 3.0
    if alpha <= 0.0:
        queue_free()
    queue_redraw()
func _draw():
    draw_circle(Vector2.ZERO, 50.0, Color(0.5, 0.8, 1.0, alpha))
"""
    script.reload()
    circle.set_script(script)
    get_parent().call_deferred("add_child", circle)
```

### 4.4 Integration Points

| Integration Point | Description | Risk |
|---|---|---|
| enemy.gd `die()` | Checks `_freeze_timer` > 0 and player frostaura level >= 3 | Low -- uses existing `_freeze_timer` and `_find_player()` |
| enemy.gd `_handle_shatter()` | New function, called from `die()` | Low -- searches enemy group, deals damage, spawns effect |
| player.owned_weapons["frostaura"] | Direct dictionary lookup | Low -- if player does not own frostaura, the key does not exist, `has()` returns false |
| Interaction with frostaura freeze | Frost Aura at Lv3 already applies `freeze_pct = 0.08` per tick (see `weapon_fire.gd` line 306). In a swarm, 2-4 enemies are typically frozen simultaneously. Shatter creates chain reactions | None -- shatter damage (2.0) is not enough to kill most enemies (zombie has 4 HP), preventing infinite shatter loops |

### 4.5 Estimated Code Lines

| File | New Lines | Modified Lines | Total |
|---|---|---|---|
| `scripts/weapons/weapon_fire.gd` | 2 (constants) | 0 | 2 |
| `scripts/enemy.gd` | 18 (_handle_shatter) + 14 (_spawn_shatter_effect) + 1 (call in die()) | 1 (add call) | 34 |
| **Total** | | | **~36 lines** |

### 4.6 Balance Analysis

- Frost Aura Lv3 DPS (current): (1.0 + 2*0.5) = 2.0 DPS from aura + 8% freeze chance per tick
- Shatter DPS contribution: In a typical swarm of 8 enemies near the player, ~2-3 are frozen at any time. When one dies, shatter hits ~3 nearby enemies for 2.0 damage each = 6.0 bonus damage per shatter event
- Shatter events per minute: ~10-15 (depends on kill rate of frozen enemies)
- Total shatter DPS: ~1.0-1.5 DPS (spread across multiple targets)
- Relative boost: ~50-75% situational DPS boost during swarms
- **Chain reaction risk**: Shatter damage (2.0) cannot kill a full-HP zombie (4.0 HP at wave start, scaling with time). Minimum shatter victim HP is > 2.0, so no infinite loops. However, if an enemy is already low HP from the aura tick AND gets shattered, it might die and shatter again. The chain would be: shatter deals 2.0 -> enemy had 1.5 HP -> dies -> was still frozen? Yes, but `_freeze_timer` is not cleared on shatter. The second shatter deals 2.0 to its neighbors. This is a max 2-deep chain and is ACCEPTABLE (it rewards the freeze playstyle).

### 4.7 Why This Design

- **Trigger on death, not on freeze application**: If shatter triggered when freeze is applied, it would be overpowered (every freeze tick would damage all nearby enemies). Triggering on death means the player must actually kill the frozen enemy first, creating a kill-priority mechanic.
- **2.0 damage**: Enough to be meaningful (kills small splitters in one hit, chunks zombies for half HP), but not enough to trivialize swarms.
- **50px radius**: Matches the typical spacing of enemies in a swarm. Not so large that it hits everything on screen, but large enough to hit 2-4 enemies clustered together.
- **Visual feedback**: A brief blue-white expanding circle provides clear visual feedback that shatter occurred. Uses the same inline-script pattern as `weapon_effects.gd` cone effect for consistency.

---

## 5. TOP 3: Boomerang Lv3 Homing Tweak

### 5.1 Mechanic Definition

At Lv3, boomerang tracking angle is multiplied by 1.5, making boomerangs significantly more likely to curve toward enemies on the outward flight path.

### 5.2 Numerical Constants

| Constant Name | Value | Unit | File Location |
|---|---|---|---|
| `BOOMERANG_LV3_TRACK_ANGLE_MUL` | 1.5 | multiplier | `scripts/weapons/weapon_fire.gd` (add to top) |

Current scaling in `weapon_fire.gd` line 366:
```
track_angle = data.boomerang_track_angle + (level - 1) * 0.26
```

At Lv1: 0.52 rad (30 deg), Lv2: 0.78 rad (45 deg), Lv3: 1.04 rad (60 deg)

With the homing tweak multiplier at Lv3: 1.04 * 1.5 = 1.56 rad (89 deg)

This means at Lv3, the boomerang can track enemies within a 178-degree cone in front of it -- essentially full hemisphere tracking.

### 5.3 Files to Modify

#### File 1: `scripts/weapons/weapon_fire.gd`

**Add constant** (after line 28, the existing `BOOMERANG_MAX_COUNT` constant):

```gdscript
# Boomerang Lv3: Homing Tweak
const BOOMERANG_LV3_TRACK_ANGLE_MUL: float = 1.5
```

**Modify `fire_boomerang()` function** (line 366):

Current code:
```gdscript
track_angle = data.boomerang_track_angle + (level - 1) * 0.26
```

Change to:
```gdscript
track_angle = data.boomerang_track_angle + (level - 1) * 0.26
if level >= 3:
    track_angle *= BOOMERANG_LV3_TRACK_ANGLE_MUL
```

This is the ONLY change needed. One constant, one if-statement, two lines of code.

### 5.4 Integration Points

| Integration Point | Description | Risk |
|---|---|---|
| weapon_fire.gd `fire_boomerang()` line 366 | Multiplies track_angle at Lv3 | Minimal -- track_angle is passed to `setup_boomerang()` and used in `boomerang.gd` `_physics_process()` for tracking |
| boomerang.gd `_physics_process()` | No changes needed -- it already uses `_track_angle` from setup | None |
| Evolved boomerang weapons (thunderang, blazerang) | Evolved weapons use their own `boomerang_track_angle` values (1.31 and 1.05 respectively) and are NOT affected by this change (the `if level >= 3` check only applies in the `else` branch, i.e., non-evolved) | None |

### 5.5 Estimated Code Lines

| File | New Lines | Modified Lines | Total |
|---|---|---|---|
| `scripts/weapons/weapon_fire.gd` | 2 (constant + if block) | 1 (modify existing line) | 3 |
| **Total** | | | **3 lines** |

### 5.6 Balance Analysis

- Boomerang Lv1: 1 boomerang, track_angle 0.52 rad (30 deg). Narrow tracking cone, often misses moving enemies
- Boomerang Lv3 (current): 3 boomerangs, track_angle 1.04 rad (60 deg). Moderate tracking, still misses frequently at max range
- Boomerang Lv3 (with homing tweak): 3 boomerangs, track_angle 1.56 rad (89 deg). Near-hemisphere tracking, very rarely misses
- Effective hit rate increase: Estimated from 60% to 85% hit rate on outward flight
- DPS impact: ~40% more effective DPS (from hitting more often, not from dealing more damage per hit)
- This is balanced because boomerang's DPS is already lower than projectile weapons (longer cooldown, slower projectile, travel time)

### 5.7 Why This Design

- **Purely numerical change**: The simplest possible implementation -- one multiplication. No new code paths, no new scenes, no new state.
- **Track angle multiplier instead of flat bonus**: A multiplier scales with the existing level-based track_angle progression, preserving the Lv1 < Lv2 < Lv3 curve naturally.
- **1.5x multiplier specifically**: At Lv3, the final track_angle of 1.56 rad means the boomerang can track enemies within 89 degrees of its current heading. This is "very good tracking" but not "perfect homing" -- enemies directly behind the boomerang are still safe. A 2.0x multiplier would give 120-degree tracking, which feels too "sticky" and removes the skill of positioning.
- **No visual change needed**: The homing improvement is felt through gameplay (boomerangs curve more aggressively), not through new visual effects. This keeps the implementation cost near zero.

---

## 6. Full Summary Table

### 6.1 Implementation Cost Comparison

| Rank | Effect | New Lines | Files Touched | New Scenes | New Signals |
|---|---|---|---|---|---|
| 1 | Knife Ricochet | ~45 | 2 (weapon_fire.gd, projectile.gd) | 0 | 0 |
| 2 | Frost Aura Shatter | ~36 | 2 (weapon_fire.gd, enemy.gd) | 0 | 0 |
| 3 | Boomerang Homing | ~3 | 1 (weapon_fire.gd) | 0 | 0 |
| -- | **TOP 3 Total** | **~84** | **3 unique files** | **0** | **0** |
| 4 | Lightning Chain On Kill | ~40 | 3 (weapon_fire.gd, weapon_controller.gd, enemy.gd) | 0 | 1 (kill signal) |
| 5 | Bible Pulse | ~30 | 2 (weapon_fire.gd, weapon_controller.gd) | 0 | 0 |
| 6 | Holy Water Freeze | ~15 | 2 (weapon_fire.gd, spin_blade.gd) | 0 | 0 |
| 7 | Fire Staff Burn Zone | ~60 | 3 (weapon_fire.gd, new burn_zone.gd, new scene) | 1 | 0 |

### 6.2 Complete Constant Reference (for all 7 effects)

The following constants should be added to `scripts/weapons/weapon_fire.gd` in a dedicated block:

```gdscript
# =============================================
# Weapon Lv3 Quality-Change Constants
# =============================================

# Knife Lv3: Ricochet
const KNIFE_LV3_RICOCHET_RANGE: float = 100.0
const KNIFE_LV3_RICOCHET_DAMAGE_MUL: float = 0.5
const KNIFE_LV3_RICOCHET_SPEED: float = 300.0
const KNIFE_LV3_RICOCHET_SIZE: float = 4.0
const KNIFE_LV3_RICOCHET_LIFETIME: float = 0.5

# Frost Aura Lv3: Shatter
const FROSTAURA_LV3_SHATTER_RADIUS: float = 50.0
const FROSTAURA_LV3_SHATTER_DAMAGE: float = 2.0

# Boomerang Lv3: Homing Tweak
const BOOMERANG_LV3_TRACK_ANGLE_MUL: float = 1.5

# Lightning Lv3: Chain On Kill (Tier B -- implement later)
const LIGHTNING_LV3_COK_RANGE: float = 200.0
const LIGHTNING_LV3_COK_DAMAGE_MUL: float = 0.5

# Bible Lv3: Expanding Aura (Tier B -- implement later)
const BIBLE_LV3_PULSE_INTERVAL: float = 2.0
const BIBLE_LV3_PULSE_RADIUS: float = 60.0
const BIBLE_LV3_PULSE_DAMAGE: float = 1.5

# Holy Water Lv3: Frost Blessing (Tier B -- implement later)
const HOLYWATER_LV3_FREEZE_CHANCE: float = 0.15
const HOLYWATER_LV3_FREEZE_DURATION: float = 0.5

# Fire Staff Lv3: Searing Flames (Tier C -- implement last)
const FIRESTAFF_LV3_ZONE_RADIUS: float = 40.0
const FIRESTAFF_LV3_ZONE_DPS: float = 1.0
const FIRESTAFF_LV3_ZONE_DURATION: float = 2.0
```

### 6.3 Projectile.gd New Field Reference

`scripts/projectile.gd` needs one new field for the Knife Ricochet:

```gdscript
var weapon_level: int = 1
```

This field should be set by `weapon_fire.gd` `fire_projectile()` for knife weapons only (other weapons do not need it yet, but it is harmless to set for all projectile types if desired).

---

## 7. Testing Checklist

### 7.1 Knife Ricochet Tests

| Test Case | Expected Behavior |
|---|---|
| Knife Lv1 hits enemy | No ricochet, single target damage only |
| Knife Lv2 hits enemy | No ricochet, single target damage only |
| Knife Lv3 hits enemy with no other enemies nearby | No ricochet (no target within 100px) |
| Knife Lv3 hits enemy with 1 enemy within 100px | Ricochet spawns, hits second enemy for 50% damage |
| Knife Lv3 hits enemy with 3 enemies within 100px | Ricochet spawns, hits NEAREST non-primary enemy for 50% damage |
| Knife Lv3 ricochet projectile | Has golden tint (Color 1.0, 0.9, 0.5), size 4px, lifetime 0.5s |
| Fireknife (evolved) hits enemy | No ricochet (weapon_id is "fireknife", not "knife") |
| Frostknife (evolved) hits enemy | No ricochet (weapon_id is "frostknife", not "knife") |

### 7.2 Frost Aura Shatter Tests

| Test Case | Expected Behavior |
|---|---|
| Non-frozen enemy dies (frostaura Lv3) | No shatter |
| Frozen enemy dies (no frostaura) | No shatter |
| Frozen enemy dies (frostaura Lv1) | No shatter |
| Frozen enemy dies (frostaura Lv3) | Shatter triggers, 2.0 damage to enemies within 50px |
| Frozen enemy dies (frostaura Lv3, no enemies within 50px) | Shatter triggers but hits nothing |
| Two frozen enemies die simultaneously | Both shatter, each damages the other's neighbors |
| Shatter kills a frozen enemy | Second shatter triggers (chain, max 2 deep) |

### 7.3 Boomerang Homing Tests

| Test Case | Expected Behavior |
|---|---|
| Boomerang Lv1 track_angle | 0.52 rad (unchanged) |
| Boomerang Lv2 track_angle | 0.78 rad (unchanged) |
| Boomerang Lv3 track_angle | 1.56 rad (0.52 + 2*0.26 = 1.04, * 1.5 = 1.56) |
| Thunderang (evolved) track_angle | 1.31 rad (unchanged, not affected) |
| Blazerang (evolved) track_angle | 1.05 rad (unchanged, not affected) |

---

## 8. Design Decisions Log

| # | Decision | Why | Alternative Considered |
|---|---|---|---|
| 1 | Ricochet spawns a NEW projectile instead of redirecting the existing one | A new projectile is cleaner -- it starts from the primary target's position with a fresh hit list. Redirecting the existing projectile would require resetting its position, direction, hit_enemies, and pierce, which is fragile | Redirect existing projectile (riskier -- could miss pierce handling) |
| 2 | Ricochet damage uses `damage * 0.5` not a flat value | Flat damage would not scale with player damage_bonus, making ricochet irrelevant in late game. 50% multiplier scales naturally | Flat 2.0 damage (does not scale) |
| 3 | Shatter checks `_freeze_timer > 0` not a "was_frozen" flag | The simplest check -- if the enemy has any freeze time remaining when they die, they shatter. No new state variables needed | New `_was_frozen: bool` flag set on `apply_freeze()` (unnecessary complexity) |
| 4 | Shatter uses `take_damage(source="frostaura")` | Kill attribution to frostaura ensures shatter kills count toward frostaura-related synergies (if any future synergies are added) | Source = "shatter" (creates a new weapon_id for kill tracking, adds complexity) |
| 5 | Boomerang homing is a multiplier not a flat bonus | Flat bonus (+0.5 rad) would give Lv3 = 1.54 rad, similar to multiplier result. But multiplier preserves the natural Lv1 < Lv2 < Lv3 progression curve better | Flat +0.5 rad bonus (slightly less elegant but same numerical result) |
| 6 | 1.5x homing multiplier, not 2.0x | At 2.0x, Lv3 track_angle would be 2.08 rad (119 deg), giving nearly full-circle tracking. This removes the positioning skill element -- boomerangs would almost never miss. 1.5x gives 89 deg tracking, strong but not perfect | 2.0x multiplier (too strong, removes skill expression) |
| 7 | Ricochet projectile does NOT apply status effects (burn/slow) | Ricochet is a knife behavior. Knives do not have innate burn or slow. If the player has synergies that add burn (e.g., mage_crit_to_burn), the ricochet should NOT inherit them because it would double-dip status effects | Ricochet inherits all status effects from parent projectile (complex, requires copying burn_dps/slow_pct fields) |
| 8 | Shatter visual uses inline GDScript (same pattern as cone effect) | Consistency with existing `weapon_effects.gd` visual patterns. No new scene files needed | Dedicated shatter_effect.tscn scene (unnecessary overhead for a 0.2s effect) |
