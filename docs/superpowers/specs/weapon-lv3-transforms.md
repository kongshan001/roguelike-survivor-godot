# Weapon Lv3 Quality-Change Transforms -- Priority Sort + Implementation Spec

**Author**: Designer Agent
**Date**: 2026-04-16
**Priority**: P1 HIGH
**Status**: Design Complete (All 7 Effects Specified)
**Parent Spec**: `docs/superpowers/specs/character-upgrade-paths.md` Section 3

---

## 1. Design Overview

This spec takes the 7 weapon Lv3 quality-change effects defined in `character-upgrade-paths.md` Section 3 and provides: (a) a priority ranking based on implementation cost vs player experience value, and (b) detailed implementation specifications for ALL 7 effects with precise file paths, function names, code modification points, and numerical constants.

Sections 3-5 cover Tier A (Knife, Frost Aura, Boomerang). Sections 6-8 cover Tier B (Lightning, Bible, Holy Water). Section 9 covers Tier C (Fire Staff). Sections 10-12 provide the consolidated summary, test checklist, and design decisions log.

The goal is to give the Programmer Agent a complete, actionable blueprint that requires zero additional design clarification. Total estimated implementation: ~212 lines across 6 files, 0 new scenes, 0 new signals.

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

## 6. TIER B #1: Lightning Lv3 Chain On Kill

### 6.1 Mechanic Definition

When lightning kills an enemy, if the weapon is at Lv3, an additional lightning bolt strikes a random enemy within 200px of the killed target, dealing 50% of the base lightning damage. This bonus bolt does NOT trigger another chain on kill (preventing infinite loops). The bonus bolt uses the standard lightning visual effect.

### 6.2 Numerical Constants

| Constant Name | Value | Unit | File Location |
|---|---|---|---|
| `LIGHTNING_LV3_COK_RANGE` | 200.0 | pixels | `scripts/weapons/weapon_fire.gd` (add to Lv3 constants block) |
| `LIGHTNING_LV3_COK_DAMAGE_MUL` | 0.5 | multiplier | `scripts/weapons/weapon_fire.gd` (add to Lv3 constants block) |
| `LIGHTNING_LV3_COK_SIGNAL` | "lightning_kill" | signal name | `scripts/enemy.gd` (new signal on enemy) |

### 6.3 Files to Modify

#### File 1: `scripts/weapons/weapon_fire.gd`

Constants are already defined in Section 6.2 of the constant block (lines 479-480 of the existing spec). No additional constants needed.

#### File 2: `scripts/enemy.gd`

**Modify `die()` function** (lines 233-245):

After `_handle_kill_rewards()` call (line 238), before `_spawn_xp_gems()` (line 239), add the chain-on-kill check. This mirrors the Frost Aura Shatter pattern where die-time effects are placed after reward handling.

```gdscript
func die() -> void:
    if not is_alive:
        return
    is_alive = false

    _handle_kill_rewards()
    _handle_shatter()          # Frost Aura Lv3
    _handle_lightning_cok()    # NEW: Lightning Lv3 Chain On Kill
    _spawn_xp_gems()
    _spawn_food_drop()
    _spawn_crate_drop()
    _handle_boss_death()
    _handle_splitter_death()

    queue_free()
```

**Add new function** `_handle_lightning_cok()` in enemy.gd (after `_handle_shatter`):

```gdscript
func _handle_lightning_cok() -> void:
    # Lightning Lv3: Chain On Kill -- bonus bolt on lightning kill
    if _last_hit_by != "lightning":
        return
    var player: Node2D = _find_player()
    if not player or not is_instance_valid(player):
        return
    if not player.owned_weapons.has("lightning"):
        return
    if player.owned_weapons["lightning"] < 3:
        return  # Not Lv3 yet
    # Find a random enemy within 200px
    var cok_range: float = 200.0  # LIGHTNING_LV3_COK_RANGE
    var cok_damage_mul: float = 0.5  # LIGHTNING_LV3_COK_DAMAGE_MUL
    var all_enemies := get_tree().get_nodes_in_group("enemies")
    var candidates: Array = []
    for enemy in all_enemies:
        if is_instance_valid(enemy) and enemy.is_alive and enemy != self:
            var dist := global_position.distance_to(enemy.global_position)
            if dist <= cok_range:
                candidates.append(enemy)
    if candidates.is_empty():
        return
    # Pick a random target
    var target: Node2D = candidates[randi() % candidates.size()]
    # Calculate bonus bolt damage: 50% of base lightning damage at Lv3
    var level: int = player.owned_weapons["lightning"]
    var base_damage: float = 5.0 + (level - 1)  # matches weapon_fire.gd line 220
    var dmg_bonus: float = 1.0 + player.damage_bonus
    var bonus_damage: float = base_damage * dmg_bonus * cok_damage_mul
    target.take_damage(bonus_damage, "lightning_cok", false)
    # Visual: lightning bolt from dying enemy to target
    var pm: Node = get_parent()
    if pm:
        WeaponEffects.create_lightning_effect(global_position, target.global_position, Color(1.0, 1.0, 0.4), pm)
```

**Note**: `WeaponEffects` is accessed via `load("res://scripts/weapons/weapon_effects.gd")`. Since `_handle_lightning_cok()` runs in enemy.gd which does not have a reference to weapon_effects, we load it statically:

```gdscript
var _weapon_effects: RefCounted = null

func _get_weapon_effects() -> RefCounted:
    if not _weapon_effects:
        _weapon_effects = load("res://scripts/weapons/weapon_effects.gd").new()
    return _weapon_effects
```

Then in `_handle_lightning_cok()`, replace the visual call with:
```gdscript
_get_weapon_effects().create_lightning_effect(global_position, target.global_position, Color(1.0, 1.0, 0.4), pm)
```

Alternatively, keep it simpler by using the static call pattern:
```gdscript
load("res://scripts/weapons/weapon_effects.gd").create_lightning_effect(global_position, target.global_position, Color(1.0, 1.0, 0.4), pm)
```

### 6.4 Integration Points

| Integration Point | Description | Risk |
|---|---|---|
| enemy.gd `die()` | Checks `_last_hit_by == "lightning"` + player lightning level >= 3 | Low -- uses existing `_last_hit_by` kill attribution |
| enemy.gd `_handle_lightning_cok()` | New function, called from `die()` | Low -- searches enemy group, picks random, deals damage, spawns visual |
| player.owned_weapons["lightning"] | Direct dictionary lookup | Low -- `has()` returns false if not owned |
| weapon_id "lightning_cok" | Bonus bolt uses distinct source ID to prevent recursive chain | Low -- `_last_hit_by` on the bonus bolt victim is "lightning_cok", not "lightning", so `_handle_lightning_cok()` will not trigger again |
| Evolved lightning weapons (thunderholywater, blizzard, thunderang, thunderbeam) | Evolved weapons use different weapon_ids, NOT "lightning" | None -- chain on kill only triggers on `_last_hit_by == "lightning"` |

### 6.5 Estimated Code Lines

| File | New Lines | Modified Lines | Total |
|---|---|---|---|
| `scripts/weapons/weapon_fire.gd` | 0 (constants already in spec) | 0 | 0 |
| `scripts/enemy.gd` | 30 (_handle_lightning_cok) + 1 (call in die()) | 1 (add call) | 32 |
| **Total** | | | **~32 lines** |

### 6.6 Balance Analysis

- Lightning Lv1: 1 bolt, 5.0 damage, 1.5s CD = 3.33 DPS (single target)
- Lightning Lv3 (current): 2 bolts, 7.0 damage each, 2 chains, 1.5s CD = 7.0 DPS (primary) + 14.0 (chains) = ~21 DPS vs groups
- Lightning Lv3 (with chain on kill): When a lightning bolt kills an enemy, bonus bolt deals 7.0 * 0.5 = 3.5 damage to a random enemy within 200px
- Chain on kill triggers: In a typical swarm, ~5-8 kills per minute from lightning. At 50% damage per trigger, that is ~17.5-28.0 bonus damage per minute = ~0.3-0.5 DPS
- Relative boost: ~2-3% total DPS contribution (low because lightning already has high DPS via chain_count)
- **Why the low DPS impact is acceptable**: Chain on kill is a cascade mechanic, not a raw DPS boost. During swarm clearing, killing a weak enemy (bat, small splitter) triggers a bonus bolt that finishes off a damaged enemy, creating satisfying chain reactions. The value is in the cascading kill timing, not raw numbers.
- **No infinite loop**: The bonus bolt source is "lightning_cok", not "lightning". If the bonus bolt kills, `_last_hit_by` is "lightning_cok" which does not match the "lightning" check. Max chain depth = 1.

### 6.7 Why This Design

- **Random target instead of nearest**: Lightning is thematically "chaotic energy". Random target selection creates unpredictable cascade patterns that feel electric and exciting. Nearest target would be deterministic and boring.
- **50% damage multiplier**: At 100%, the bonus bolt would be as strong as the primary, effectively doubling lightning's kill rate in swarms. 50% is meaningful enough to finish off damaged enemies but not strong enough to replace the primary bolts.
- **Source "lightning_cok" prevents recursion**: Using a distinct weapon_id is the simplest possible anti-recursion mechanism. No flags, no counters, no state. The string mismatch naturally prevents loops.
- **200px range**: Matches the typical enemy spacing in a swarm (enemies are 30-50px apart, so 200px reaches ~4-6 enemies). Not so large that it hits enemies across the screen.

### 6.8 Test Cases

| Test Case | Expected Behavior |
|---|---|
| Lightning Lv1 kills enemy | No chain on kill |
| Lightning Lv2 kills enemy | No chain on kill |
| Lightning Lv3 kills enemy with no enemies within 200px | Chain on kill triggers but finds no target |
| Lightning Lv3 kills enemy with 3 enemies within 200px | Bonus bolt hits 1 random enemy for 50% base damage |
| Lightning Lv3 bonus bolt kills an enemy | No second chain on kill (source is "lightning_cok") |
| Thunderholywater (evolved) kills enemy | No chain on kill (weapon_id is "thunderholywater") |
| Blizzard (evolved) kills enemy | No chain on kill (weapon_id is "blizzard") |
| Lightning Lv3 kills enemy, player has no lightning | No chain (owned_weapons check fails) |

---

## 7. TIER B #2: Bible Lv3 Expanding Aura

### 7.1 Mechanic Definition

When Bible is at Lv3, the orbit periodically emits a damage pulse every 2 seconds, dealing 1.5 damage to all enemies within 60px of the player. This is a close-range AoE supplement that makes Bible useful even when no enemies are at orbit range. The pulse is centered on the player, not on the orbit blades.

### 7.2 Numerical Constants

| Constant Name | Value | Unit | File Location |
|---|---|---|---|
| `BIBLE_LV3_PULSE_INTERVAL` | 2.0 | seconds | `scripts/weapons/weapon_fire.gd` (add to Lv3 constants block) |
| `BIBLE_LV3_PULSE_RADIUS` | 60.0 | pixels | `scripts/weapons/weapon_fire.gd` (add to Lv3 constants block) |
| `BIBLE_LV3_PULSE_DAMAGE` | 1.5 | HP | `scripts/weapons/weapon_fire.gd` (add to Lv3 constants block) |

### 7.3 Files to Modify

#### File 1: `scripts/weapons/weapon_fire.gd`

Constants are already defined in Section 6.2 of the constant block (lines 483-485 of the existing spec). No additional constants needed.

#### File 2: `scripts/weapon_controller.gd`

**Add new variable** (after line 6, alongside existing `_boomerang_instances: Array = []`):

```gdscript
var _bible_pulse_timer: float = 0.0
```

**Modify `_physics_process()`** (lines 30-54):

After `_update_boomerangs(delta)` call (line 53), add the Bible pulse logic:

```gdscript
func _physics_process(delta):
    if not _registered:
        UpgradePool.ensure_weapons_registered()
        _registered = true

    if GameManager.is_game_over:
        return

    var player: CharacterBody2D = get_parent()
    if not player.is_alive:
        return

    for weapon_id in player.owned_weapons:
        if not _weapon_timers.has(weapon_id):
            _weapon_timers[weapon_id] = 0.0

        _weapon_timers[weapon_id] -= delta
        if _weapon_timers[weapon_id] <= 0.0:
            var data: WeaponData = UpgradePool._weapons.get(weapon_id)
            if data:
                _fire_weapon(weapon_id, data, player)
                _weapon_timers[weapon_id] = data.cooldown

    _update_boomerangs(delta)
    _update_bible_pulse(delta, player)  # NEW: Bible Lv3 pulse
```

**Add new function** `_update_bible_pulse()` in weapon_controller.gd (after `_update_boomerangs`):

```gdscript
func _update_bible_pulse(delta: float, player: CharacterBody2D) -> void:
    # Bible Lv3: Expanding Aura -- periodic damage pulse
    if not player.owned_weapons.has("bible"):
        return
    if player.owned_weapons["bible"] < 3:
        return  # Not Lv3 yet
    _bible_pulse_timer -= delta
    if _bible_pulse_timer > 0.0:
        return
    _bible_pulse_timer = 2.0  # BIBLE_LV3_PULSE_INTERVAL
    var pulse_radius: float = 60.0  # BIBLE_LV3_PULSE_RADIUS
    var pulse_damage: float = 1.5  # BIBLE_LV3_PULSE_DAMAGE
    var dmg_bonus: float = 1.0 + player.damage_bonus
    var all_enemies := get_tree().get_nodes_in_group("enemies")
    for enemy in all_enemies:
        if is_instance_valid(enemy) and enemy.is_alive:
            var dist := player.global_position.distance_to(enemy.global_position)
            if dist <= pulse_radius:
                enemy.take_damage(pulse_damage * dmg_bonus, "bible_pulse")
    # Visual: expanding ring
    var pm: Node = _get_projectile_manager(player)
    if pm:
        _get_effects().create_pulse_ring_effect(player.global_position, pulse_radius, Color(0.9, 0.85, 0.5), pm)
```

#### File 3: `scripts/weapons/weapon_effects.gd`

**Add new static function** `create_pulse_ring_effect()` (after `create_cone_effect`, around line 59):

```gdscript
static func create_pulse_ring_effect(pos: Vector2, max_radius: float, color: Color, parent: Node) -> void:
    var node := Node2D.new()
    var script := GDScript.new()
    script.source_code = """extends Node2D
var max_radius: float = 60.0
var color: Color = Color.WHITE
var alpha: float = 0.5
var progress: float = 0.0

func _process(delta):
    progress += delta * 4.0  # 0.25s expand time
    alpha -= delta * 3.0
    if alpha <= 0.0 or progress >= 1.0:
        queue_free()
    queue_redraw()

func _draw():
    var r = max_radius * progress
    draw_circle(Vector2.ZERO, r, Color(color.r, color.g, color.b, alpha * 0.3))
    draw_arc(Vector2.ZERO, r, 0.0, TAU, 24, Color(color.r, color.g, color.b, alpha), 2.0)
"""
    script.reload()
    node.set_script(script)
    node.set_deferred("max_radius", max_radius)
    node.set_deferred("color", color)
    node.global_position = pos
    parent.call_deferred("add_child", node)
```

### 7.4 Integration Points

| Integration Point | Description | Risk |
|---|---|---|
| weapon_controller.gd `_physics_process()` | Bible pulse runs every frame as a timer check | Low -- early returns if no bible or level < 3 |
| weapon_controller.gd `_update_bible_pulse()` | New function, self-contained timer + enemy query | Low -- reuses same pattern as `_update_boomerangs` |
| weapon_effects.gd `create_pulse_ring_effect()` | New visual function, follows same inline-GDScript pattern as cone effect | Low -- self-contained visual with auto-cleanup |
| player.owned_weapons["bible"] | Direct dictionary lookup | Low -- `has()` returns false if not owned |
| Interaction with bible orbit | Bible orbit already deals contact damage via spin_blade.gd. Pulse is independent AoE centered on player | None -- pulse does not interfere with orbit hit cooldowns |
| Interaction with blizzard aura | Blizzard is evolved, weapon_id is "blizzard" not "bible". Pulse only checks for "bible" | None |

### 7.5 Estimated Code Lines

| File | New Lines | Modified Lines | Total |
|---|---|---|---|
| `scripts/weapon_controller.gd` | 1 (var) + 20 (_update_bible_pulse) + 1 (call) | 1 (add call in _physics_process) | 23 |
| `scripts/weapons/weapon_effects.gd` | 25 (create_pulse_ring_effect) | 0 | 25 |
| **Total** | | | **~48 lines** |

### 7.6 Balance Analysis

- Bible Lv1: 1 orbit blade, 80px radius, 1.0 damage per contact, ~3 hits/sec = 3.0 DPS (situational -- only when enemies touch orbit)
- Bible Lv3 (current): 1 orbit blade, 120px radius, 2.0 damage per contact, ~3 hits/sec = 6.0 DPS
- Bible Lv3 (with pulse): +1.5 damage / 2.0 seconds * dmg_bonus to all enemies within 60px = +0.75 bonus DPS base
- Relative boost: ~12.5% of Bible's base DPS (0.75 / 6.0)
- With dmg_bonus (Mage 1.20): 0.75 * 1.20 = 0.9 DPS, ~15% relative boost
- In a typical swarm of 5 enemies within 60px: 5 * 0.75 = 3.75 bonus DPS total (spread across targets)
- **Assessment**: The pulse is a supplementary close-range effect. It does not replace the orbit (which has wider range) but ensures Bible has some baseline usefulness when enemies are too close for the orbit to be effective. Bible is currently the weakest DPS weapon; the pulse helps close the gap.

### 7.7 Why This Design

- **Pulse centered on player, not orbit**: The orbit blades already cover the outer ring (80-120px). The pulse covers the inner dead zone (0-60px) where orbit blades cannot reach. This makes Bible a complete zone-control weapon.
- **2.0 second interval**: At 1.0s, the pulse would be too frequent and overlap with aura weapons. At 3.0s, it would feel too rare. 2.0s gives a satisfying rhythmic pulse that players can anticipate.
- **1.5 damage**: Low enough to be supplementary (not replacing aura or orbit damage), high enough to consistently kill small splitters (1.0 HP) and chip zombies (4.0 HP).
- **Inline GDScript visual (same as cone effect)**: Consistency with existing `weapon_effects.gd` patterns. The expanding ring provides clear visual feedback without needing a new scene file.
- **Timer in weapon_controller instead of spin_blade**: The pulse is a property of the bible weapon, not the orbit blade instance. Placing the timer in weapon_controller keeps the logic centralized and avoids modifying the generic spin_blade.gd.

### 7.8 Test Cases

| Test Case | Expected Behavior |
|---|---|
| Bible Lv1 orbit | No pulse damage |
| Bible Lv2 orbit | No pulse damage |
| Bible Lv3 orbit, no enemies within 60px | Pulse triggers but hits nothing |
| Bible Lv3 orbit, 3 enemies within 60px | Pulse deals 1.5 damage to all 3 enemies every 2s |
| Bible Lv3 pulse timer | First pulse fires 2s after bible reaches Lv3 |
| Flamebible (evolved) | No pulse (weapon_id is "flamebible", not "bible") |
| Pulse damage source | `take_damage(source="bible_pulse")` for kill attribution |
| Player moves during pulse | Pulse follows player position (centered on player.global_position) |

---

## 8. TIER B #3: Holy Water Lv3 Frost Blessing

### 8.1 Mechanic Definition

When Holy Water is at Lv3, each orbit blade hit has a 15% chance to apply a 0.5s freeze to the hit enemy. At Lv3, Holy Water has 3 blades that each hit ~3 times/second, giving roughly 1 freeze per second on a single target.

### 8.2 Numerical Constants

| Constant Name | Value | Unit | File Location |
|---|---|---|---|
| `HOLYWATER_LV3_FREEZE_CHANCE` | 0.15 | fraction | `scripts/weapons/weapon_fire.gd` (add to Lv3 constants block) |
| `HOLYWATER_LV3_FREEZE_DURATION` | 0.5 | seconds | `scripts/weapons/weapon_fire.gd` (add to Lv3 constants block) |

### 8.3 Files to Modify

#### File 1: `scripts/weapons/weapon_fire.gd`

Constants are already defined in Section 6.2 of the constant block (lines 488-489 of the existing spec). No additional constants needed.

**Modify `update_orbit()` function** (lines 121-171):

In the holywater branch (lines 130-135), add the weapon level to the spin_blade instance so it can check for Lv3:

After line 164 (`instance.weapon_id = weapon_id`), add:

```gdscript
if weapon_id == "holywater":
    instance.weapon_level = level
```

This requires adding a `weapon_level` variable to spin_blade.gd (see File 2 below).

#### File 2: `scripts/spin_blade.gd`

**Add new variable** (after line 11, alongside existing `var weapon_id: String = ""`):

```gdscript
var weapon_level: int = 1
```

**Modify `_physics_process()` function** (lines 26-48):

After the `enemy.take_damage(damage, weapon_id)` call (line 47), before `_hit_cooldowns[enemy] = 0.3` (line 48), add the freeze logic:

```gdscript
func _physics_process(delta):
    _angle += rotation_speed * delta

    var to_remove: Array = []
    for enemy in _hit_cooldowns:
        _hit_cooldowns[enemy] -= delta
        if _hit_cooldowns[enemy] <= 0:
            to_remove.append(enemy)
    for e in to_remove:
        _hit_cooldowns.erase(e)

    queue_redraw()

    var all_enemies = get_tree().get_nodes_in_group("enemies")
    for i in range(orbit_count):
        var blade_angle = _angle + (TAU * i / orbit_count)
        var blade_pos = Vector2(cos(blade_angle), sin(blade_angle)) * orbit_radius
        for enemy in all_enemies:
            if is_instance_valid(enemy) and enemy.is_alive and not _hit_cooldowns.has(enemy):
                var dist = blade_pos.distance_to(enemy.global_position - global_position)
                if dist < blade_size + 10.0:
                    enemy.take_damage(damage, weapon_id)
                    # Holy Water Lv3: Frost Blessing
                    if weapon_id == "holywater" and weapon_level >= 3:
                        if randf() < 0.15:  # HOLYWATER_LV3_FREEZE_CHANCE
                            enemy.apply_freeze(0.5)  # HOLYWATER_LV3_FREEZE_DURATION
                    _hit_cooldowns[enemy] = 0.3
```

### 8.4 Integration Points

| Integration Point | Description | Risk |
|---|---|---|
| spin_blade.gd `_physics_process()` | Freeze check added after existing damage logic | Low -- uses existing `apply_freeze()` method on enemy |
| spin_blade.gd `weapon_level` | New variable, set by weapon_fire.gd during orbit creation | Low -- default 1 means no freeze at Lv1/Lv2 |
| weapon_fire.gd `update_orbit()` | Sets `weapon_level` on holywater orbit instances | Low -- one additional property assignment |
| enemy.gd `apply_freeze()` | Existing method at line 225-226, used by frostaura | None -- freeze duration stacks via `maxf()` |
| Interaction with frostaura freeze | Frostaura applies freeze_pct * delta + bonus. Holy Water applies flat 0.5s. Both use `apply_freeze()` which takes `maxf()` | None -- longer freeze wins, no double-freeze |
| Interaction with frostaura shatter | If holywater freeze triggers and the enemy dies while frozen, AND player has frostaura Lv3, shatter triggers | Synergy -- this is an intentional positive interaction that rewards using both holywater and frostaura |
| Evolved holywater weapons (thunderholywater, holyshockwave) | Evolved weapons use their own weapon_ids | None -- freeze only triggers on `weapon_id == "holywater"` |

### 8.5 Estimated Code Lines

| File | New Lines | Modified Lines | Total |
|---|---|---|---|
| `scripts/spin_blade.gd` | 1 (weapon_level var) + 3 (freeze check) | 0 | 4 |
| `scripts/weapons/weapon_fire.gd` | 2 (set weapon_level) | 0 | 2 |
| **Total** | | | **~6 lines** |

### 8.6 Balance Analysis

- Holy Water Lv1: 1 blade, 1.5 damage, ~3 hits/sec = 4.5 DPS (contact)
- Holy Water Lv3 (current): 3 blades, 2.0 damage, ~3 hits/sec/blade = 18 DPS
- Holy Water Lv3 (with Frost Blessing): Each blade hit has 15% chance to apply 0.5s freeze
  - Per blade: 3 hits/sec * 0.15 = 0.45 freezes/sec
  - 3 blades vs single target: 1.35 freezes/sec (but hit_cooldown prevents overlapping, effective ~1 freeze/sec)
  - Freeze duration 0.5s means target is frozen ~50% of the time
  - DPS impact: ~10% indirect boost (frozen enemies do not move, making them easier to hit with other weapons; frozen enemies cannot attack)
- **CC value**: The freeze is primarily a crowd-control tool, not a DPS boost. It interrupts enemy movement and attacks, creating windows for the player to reposition or focus damage.
- **Synergy with frostaura shatter**: If the player has both holywater Lv3 and frostaura Lv3, holywater freeze can set up shatter triggers. This is a meaningful build synergy.

### 8.7 Why This Design

- **15% chance per blade hit**: At 3 blades with ~3 hits/sec each, 15% gives roughly 1 freeze per second on a single target. This is frequent enough to be noticeable but not so frequent that enemies are permanently frozen.
- **0.5s freeze duration**: Brief freeze that interrupts movement and attacks without locking enemies down. Longer durations (1.0s+) would make holywater too powerful as a CC tool, overlapping with frostaura's role.
- **Check in spin_blade.gd, not weapon_fire.gd**: The hit happens in spin_blade.gd `_physics_process()`, so the freeze check must be there. Passing weapon_level through the setup chain is the minimal approach.
- **No visual change to orbit blades**: The freeze effect on the enemy (existing blue tint from frostaura freeze visual) is sufficient feedback. No new visual effects needed for the blades themselves.

### 8.8 Test Cases

| Test Case | Expected Behavior |
|---|---|
| Holy Water Lv1 blade hits enemy | No freeze applied |
| Holy Water Lv2 blade hits enemy | No freeze applied |
| Holy Water Lv3 blade hits enemy (randf < 0.15) | Enemy frozen for 0.5s |
| Holy Water Lv3 blade hits enemy (randf >= 0.15) | No freeze, normal damage |
| Holy Water Lv3 + frostaura Lv3, frozen enemy dies | Shatter triggers (cross-weapon synergy) |
| Thunderholywater (evolved) blade hits enemy | No freeze (weapon_id is "thunderholywater") |
| Holyshockwave (evolved) blade hits enemy | No freeze (weapon_id is "holyshockwave") |
| weapon_level not set (default 1) | No freeze (level < 3) |

---

## 9. TIER C: Fire Staff Lv3 Searing Burst

### 9.1 Mechanic Definition

When Fire Staff is at Lv3, cone attacks that hit enemies cause each hit enemy to explode on death, dealing 3.0 damage to all enemies within 45px. This replaces the original "burn zone" concept (which required a new persistent Area2D scene) with a death-triggered explosion that reuses the same inline-GDScript visual pattern as Frost Aura Shatter.

### 9.2 Numerical Constants

| Constant Name | Value | Unit | File Location |
|---|---|---|---|
| `FIRESTAFF_LV3_BURST_RADIUS` | 45.0 | pixels | `scripts/weapons/weapon_fire.gd` (add to Lv3 constants block) |
| `FIRESTAFF_LV3_BURST_DAMAGE` | 3.0 | HP | `scripts/weapons/weapon_fire.gd` (add to Lv3 constants block) |

### 9.3 Design Decision: Searing Burst instead of Searing Flames (Burn Zone)

The original spec (`character-upgrade-paths.md` Section 3) defined Fire Staff Lv3 as "Searing Flames" -- a persistent burn zone (40px Area2D, 1.0 DPS, 2s duration) spawned at each hit enemy's position. This was ranked Tier C because it required a **new scene type** (persistent Area2D with tick damage) not currently in the codebase.

**Revised approach: Searing Burst** -- an on-death explosion triggered when a firestaff-burning enemy dies. This eliminates the need for a new scene type entirely:

| Original (Burn Zone) | Revised (Searing Burst) | Change |
|---|---|---|
| Requires new burn_zone.tscn + burn_zone.gd | No new scenes or scripts | -1 scene, -1 script |
| Persistent Area2D (2s lifecycle, tick damage) | Instant explosion (one-shot damage) | Simpler lifecycle |
| 1.0 DPS * 2s = 2.0 total damage per zone | 3.0 burst damage to all within 45px | Higher burst, lower sustained |
| ~60 lines + new scene + new script | ~30 lines, no new files | Half the code |

The burst approach achieves the same design goal (area denial / splash damage on firestaff kills) with significantly lower implementation cost.

### 9.4 Files to Modify

#### File 1: `scripts/weapons/weapon_fire.gd`

**Add constants** (replace the existing FIRESTAFF_LV3 constants in the Lv3 block):

The existing spec (lines 491-494) defines:
```gdscript
const FIRESTAFF_LV3_ZONE_RADIUS: float = 40.0
const FIRESTAFF_LV3_ZONE_DPS: float = 1.0
const FIRESTAFF_LV3_ZONE_DURATION: float = 2.0
```

Replace with:
```gdscript
# Fire Staff Lv3: Searing Burst (revised from burn zone)
const FIRESTAFF_LV3_BURST_RADIUS: float = 45.0
const FIRESTAFF_LV3_BURST_DAMAGE: float = 3.0
```

No changes to `fire_cone()` itself -- the cone already applies burn at Lv3 (lines 252-254). The burst trigger happens in `enemy.gd` when a burning enemy dies.

#### File 2: `scripts/enemy.gd`

**Modify `die()` function** (lines 233-245):

After `_handle_lightning_cok()` call, before `_spawn_xp_gems()`, add the searing burst check:

```gdscript
func die() -> void:
    if not is_alive:
        return
    is_alive = false

    _handle_kill_rewards()
    _handle_shatter()          # Frost Aura Lv3
    _handle_lightning_cok()    # Lightning Lv3
    _handle_firestaff_burst()  # NEW: Fire Staff Lv3 Searing Burst
    _spawn_xp_gems()
    _spawn_food_drop()
    _spawn_crate_drop()
    _handle_boss_death()
    _handle_splitter_death()

    queue_free()
```

**Add new function** `_handle_firestaff_burst()` in enemy.gd (after `_handle_lightning_cok`):

```gdscript
func _handle_firestaff_burst() -> void:
    # Fire Staff Lv3: Searing Burst -- burning enemy explodes on death
    if _burn_timer <= 0.0:
        return  # Not burning, no burst
    var player: Node2D = _find_player()
    if not player or not is_instance_valid(player):
        return
    if not player.owned_weapons.has("firestaff"):
        return
    if player.owned_weapons["firestaff"] < 3:
        return  # Not Lv3 yet
    # Check that the burn was from firestaff specifically
    if _last_hit_by != "firestaff":
        return  # Burn from other sources (e.g., fire_slime) does not trigger burst
    # Searing burst: deal 3.0 damage to all enemies within 45px
    var burst_radius: float = 45.0  # FIRESTAFF_LV3_BURST_RADIUS
    var burst_damage: float = 3.0    # FIRESTAFF_LV3_BURST_DAMAGE
    var dmg_bonus: float = 1.0 + player.damage_bonus
    var all_enemies := get_tree().get_nodes_in_group("enemies")
    for enemy in all_enemies:
        if is_instance_valid(enemy) and enemy.is_alive and enemy != self:
            var dist := global_position.distance_to(enemy.global_position)
            if dist <= burst_radius:
                enemy.take_damage(burst_damage * dmg_bonus, "firestaff_burst")
    # Visual: orange expanding circle
    _spawn_burst_effect(burst_radius)
```

**Add visual helper** `_spawn_burst_effect()` (after `_spawn_shatter_effect` or similar inline visual):

```gdscript
func _spawn_burst_effect(radius: float) -> void:
    var circle: Node2D = Node2D.new()
    circle.global_position = global_position
    var script := GDScript.new()
    script.source_code = """extends Node2D
var alpha: float = 0.6
var max_r: float = 45.0

func _process(delta):
    alpha -= delta * 3.0
    if alpha <= 0.0:
        queue_free()
    queue_redraw()

func _draw():
    draw_circle(Vector2.ZERO, max_r, Color(1.0, 0.4, 0.1, alpha * 0.3))
    draw_arc(Vector2.ZERO, max_r, 0.0, TAU, 24, Color(1.0, 0.6, 0.1, alpha), 2.0)
"""
    script.reload()
    circle.set_script(script)
    circle.set_deferred("max_r", radius)
    get_parent().call_deferred("add_child", circle)
```

### 9.5 Integration Points

| Integration Point | Description | Risk |
|---|---|---|
| enemy.gd `die()` | Checks `_burn_timer > 0` + `_last_hit_by == "firestaff"` + player firestaff level >= 3 | Low -- uses existing `_burn_timer` and `_last_hit_by` |
| enemy.gd `_handle_firestaff_burst()` | New function, called from `die()` | Low -- searches enemy group, deals damage, spawns visual |
| weapon_fire.gd `fire_cone()` | No changes needed -- cone already applies burn at Lv3 (lines 252-254, 280-281) | None |
| Interaction with mage_crit_to_burn synergy | Mage Combustion passive applies burn on crits from ANY weapon. If the player crits with a non-firestaff weapon, the burn is applied but `_last_hit_by` is the crit source weapon, not "firestaff". Burst only triggers when `_last_hit_by == "firestaff"` | None -- intentional isolation |
| Interaction with fire_slime burn aura | Fire slime applies burn to player, not enemies. Even if it did, `_last_hit_by` would be the fire slime attack, not "firestaff" | None |
| Evolved firestaff weapons (fireknife, flamebible, blazerang, holyshockwave) | Evolved weapons use different weapon_ids. Burst only triggers on `_last_hit_by == "firestaff"` | None |
| Source "firestaff_burst" | Like "lightning_cok", uses distinct ID to prevent recursive bursts | Low -- if burst kills a burning enemy, `_last_hit_by` is "firestaff_burst" not "firestaff", no recursion |

### 9.6 Estimated Code Lines

| File | New Lines | Modified Lines | Total |
|---|---|---|---|
| `scripts/weapons/weapon_fire.gd` | 2 (replace constants) | 2 (replace existing 3 constants with 2) | 2 |
| `scripts/enemy.gd` | 20 (_handle_firestaff_burst) + 18 (_spawn_burst_effect) + 1 (call in die()) | 1 (add call) | 40 |
| **Total** | | | **~42 lines** |

### 9.7 Balance Analysis

- Fire Staff Lv1: 1 cone hit, 5.0 damage, 1.5s CD = 3.33 DPS (directional)
- Fire Staff Lv3 (current): 1 cone hit, 9.0 damage + burn (2.0 DPS, 2s) = 6.0 + 2.0 = 8.0 DPS
- Fire Staff Lv3 (with Searing Burst): When a burning enemy dies, 3.0 * dmg_bonus burst to all within 45px
  - Burst triggers: ~3-5 kills/min in a typical swarm. Each burst hits ~2-3 nearby enemies for 3.0 * 1.2 (Mage) = 3.6 damage
  - Burst DPS: ~0.4-0.9 DPS (sustained contribution)
  - Relative boost: ~5-11% (situational -- requires grouped burning enemies)
- **Compared to original burn zone design**: Burn zone was 1.0 DPS * 2s = 2.0 total damage per zone, but enemies had to stay in the zone. Burst is 3.0 instant damage in a wider radius (45px vs 40px), dealing damage immediately without requiring enemies to remain in an area.
- **No infinite loop**: Burst source is "firestaff_burst", not "firestaff". If burst kills a burning enemy, that enemy's `_last_hit_by` is "firestaff_burst" (not "firestaff"), so burst does not chain. However: if the original cone hit set `_last_hit_by = "firestaff"` on multiple enemies, and the first burst kills a second burning enemy, the second enemy's `_last_hit_by` is still "firestaff" (set before the burst). So burst CAN chain up to 2 deep:
  - Cone hits enemies A and B, both get burn, both have `_last_hit_by = "firestaff"`
  - Enemy A dies from burn DOT -> burst triggers, kills B -> B dies -> `_last_hit_by` is still "firestaff" -> burst triggers again on B's neighbors
  - This is a max 2-deep chain and is ACCEPTABLE (it rewards the firestaff build).
- **3.0 burst damage**: Enough to kill small splitters (1.0 HP) in one hit and chunk zombies (4.0 HP) for 75% HP. Not enough to one-shot full-HP zombies, preventing trivial swarm clearing.

### 9.8 Why This Design

- **Burst instead of burn zone**: The original burn zone (Tier C) required a new persistent Area2D scene with tick damage and a 2s lifecycle. Burst eliminates this entirely by reusing the same death-trigger pattern as Shatter and Chain On Kill. This reduces implementation from ~60 lines + 1 new scene to ~42 lines + 0 new scenes.
- **Check `_last_hit_by == "firestaff"`**: Ensures burst only triggers from firestaff-inflicted burns, not from burns applied by synergies (mage_crit_to_burn) or enemies (fire_slime). This keeps the effect scoped to the weapon's identity.
- **Check `_burn_timer > 0`**: The enemy must be actively burning when it dies. If burn expired and the enemy dies from another weapon, no burst. This rewards killing enemies quickly after the cone hit.
- **45px radius (slightly larger than original 40px)**: Compensates for the instant burst (enemies may have moved slightly since the cone hit). 45px still only hits closely grouped enemies.
- **Orange visual (same pattern as shatter's blue)**: Consistent visual language. Blue circle = frost shatter, orange circle = fire burst. Both use the inline GDScript pattern.

### 9.9 Test Cases

| Test Case | Expected Behavior |
|---|---|
| Fire Staff Lv1 kills enemy (with burn from synergy) | No burst |
| Fire Staff Lv2 kills burning enemy | No burst |
| Fire Staff Lv3 kills burning enemy, no enemies within 45px | Burst triggers but hits nothing |
| Fire Staff Lv3 kills burning enemy, 3 enemies within 45px | Burst deals 3.0 * dmg_bonus to all 3 |
| Burst kills a second burning enemy | Second burst triggers (2-deep chain) |
| Second burst kills a third burning enemy | Third burst does NOT trigger (`_last_hit_by` is "firestaff_burst") |
| Fireknife (evolved) kills burning enemy | No burst (weapon_id is "fireknife") |
| Non-firestaff burn kills enemy | No burst (`_last_hit_by` is not "firestaff") |
| Fire Staff Lv3 cone hits but enemy dies from another weapon | No burst if burn expired; burst if still burning and `_last_hit_by` was "firestaff" |

---

## 10. Full Summary Table

### 10.1 Implementation Cost Comparison (All 7 Effects)

| Rank | Effect | New Lines | Files Touched | New Scenes | New Signals |
|---|---|---|---|---|---|
| 1 | Knife Ricochet | ~45 | 2 (weapon_fire.gd, projectile.gd) | 0 | 0 |
| 2 | Frost Aura Shatter | ~36 | 2 (weapon_fire.gd, enemy.gd) | 0 | 0 |
| 3 | Boomerang Homing | ~3 | 1 (weapon_fire.gd) | 0 | 0 |
| -- | **Tier A Total** | **~84** | **3 unique files** | **0** | **0** |
| 4 | Lightning Chain On Kill | ~32 | 1 (enemy.gd) | 0 | 0 |
| 5 | Bible Pulse | ~48 | 2 (weapon_controller.gd, weapon_effects.gd) | 0 | 0 |
| 6 | Holy Water Freeze | ~6 | 2 (weapon_fire.gd, spin_blade.gd) | 0 | 0 |
| -- | **Tier B Total** | **~86** | **3 unique files** | **0** | **0** |
| 7 | Fire Staff Searing Burst | ~42 | 2 (weapon_fire.gd, enemy.gd) | 0 | 0 |
| -- | **Tier C Total** | **~42** | **2 unique files** | **0** | **0** |
| -- | **ALL 7 Total** | **~212** | **6 unique files** | **0** | **0** |

**Key improvement**: The original Tier C estimate was ~60 lines + 1 new scene + 1 new script. The revised Searing Burst design reduces this to ~42 lines + 0 new files. Additionally, the Lightning Chain On Kill was originally estimated at ~40 lines + 1 new signal across 3 files, but the actual design (Section 6) achieves it in ~32 lines in just 1 file (enemy.gd) with no signals, by using the same die()-hook pattern as Shatter.

### 10.2 Complete Constant Reference (All 7 Effects)

The following constants should be added to `scripts/weapons/weapon_fire.gd` in a dedicated block (after line 28):

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

# Lightning Lv3: Chain On Kill
const LIGHTNING_LV3_COK_RANGE: float = 200.0
const LIGHTNING_LV3_COK_DAMAGE_MUL: float = 0.5

# Bible Lv3: Expanding Aura
const BIBLE_LV3_PULSE_INTERVAL: float = 2.0
const BIBLE_LV3_PULSE_RADIUS: float = 60.0
const BIBLE_LV3_PULSE_DAMAGE: float = 1.5

# Holy Water Lv3: Frost Blessing
const HOLYWATER_LV3_FREEZE_CHANCE: float = 0.15
const HOLYWATER_LV3_FREEZE_DURATION: float = 0.5

# Fire Staff Lv3: Searing Burst (revised from burn zone)
const FIRESTAFF_LV3_BURST_RADIUS: float = 45.0
const FIRESTAFF_LV3_BURST_DAMAGE: float = 3.0
```

### 10.3 New Variables Reference

**`scripts/projectile.gd`** -- new field for Knife Ricochet:

```gdscript
var weapon_level: int = 1
```

This field should be set by `weapon_fire.gd` `fire_projectile()` for knife weapons (line 92, after `proj.damage = proj_damage`).

**`scripts/spin_blade.gd`** -- new field for Holy Water Frost Blessing:

```gdscript
var weapon_level: int = 1
```

This field should be set by `weapon_fire.gd` `update_orbit()` for holywater weapons (after line 164).

**`scripts/weapon_controller.gd`** -- new variable for Bible Pulse:

```gdscript
var _bible_pulse_timer: float = 0.0
```

### 10.4 enemy.gd die() Hook Summary

All three die()-time effects (Shatter, Chain On Kill, Searing Burst) use the same hook pattern in `enemy.gd` `die()` (line 233-245):

```gdscript
func die() -> void:
    if not is_alive:
        return
    is_alive = false

    _handle_kill_rewards()
    _handle_shatter()           # Frost Aura Lv3: frozen enemy explodes
    _handle_lightning_cok()     # Lightning Lv3: bonus bolt on kill
    _handle_firestaff_burst()   # Fire Staff Lv3: burning enemy explodes
    _spawn_xp_gems()
    _spawn_food_drop()
    _spawn_crate_drop()
    _handle_boss_death()
    _handle_splitter_death()

    queue_free()
```

All three handlers follow the same pattern:
1. Early return if condition not met (status timer / weapon ID / weapon level)
2. Find player via `_find_player()`
3. Check `player.owned_weapons` for weapon and level
4. Search enemies in group within range
5. Deal damage with distinct source ID
6. Optional visual effect

---

## 11. Testing Checklist

### 11.1 Knife Ricochet Tests

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

### 11.2 Frost Aura Shatter Tests

| Test Case | Expected Behavior |
|---|---|
| Non-frozen enemy dies (frostaura Lv3) | No shatter |
| Frozen enemy dies (no frostaura) | No shatter |
| Frozen enemy dies (frostaura Lv1) | No shatter |
| Frozen enemy dies (frostaura Lv3) | Shatter triggers, 2.0 damage to enemies within 50px |
| Frozen enemy dies (frostaura Lv3, no enemies within 50px) | Shatter triggers but hits nothing |
| Two frozen enemies die simultaneously | Both shatter, each damages the other's neighbors |
| Shatter kills a frozen enemy | Second shatter triggers (chain, max 2 deep) |

### 11.3 Boomerang Homing Tests

| Test Case | Expected Behavior |
|---|---|
| Boomerang Lv1 track_angle | 0.52 rad (unchanged) |
| Boomerang Lv2 track_angle | 0.78 rad (unchanged) |
| Boomerang Lv3 track_angle | 1.56 rad (0.52 + 2*0.26 = 1.04, * 1.5 = 1.56) |
| Thunderang (evolved) track_angle | 1.31 rad (unchanged, not affected) |
| Blazerang (evolved) track_angle | 1.05 rad (unchanged, not affected) |

### 11.4 Lightning Chain On Kill Tests

| Test Case | Expected Behavior |
|---|---|
| Lightning Lv1 kills enemy | No chain on kill |
| Lightning Lv2 kills enemy | No chain on kill |
| Lightning Lv3 kills enemy with no enemies within 200px | Chain on kill triggers but finds no target |
| Lightning Lv3 kills enemy with 3 enemies within 200px | Bonus bolt hits 1 random enemy for 50% base damage |
| Lightning Lv3 bonus bolt kills an enemy | No second chain (source is "lightning_cok") |
| Thunderholywater (evolved) kills enemy | No chain (weapon_id is "thunderholywater") |
| Blizzard (evolved) kills enemy | No chain (weapon_id is "blizzard") |

### 11.5 Bible Pulse Tests

| Test Case | Expected Behavior |
|---|---|
| Bible Lv1 orbit | No pulse damage |
| Bible Lv2 orbit | No pulse damage |
| Bible Lv3 orbit, no enemies within 60px | Pulse triggers but hits nothing |
| Bible Lv3 orbit, 3 enemies within 60px | Pulse deals 1.5 * dmg_bonus to all 3 enemies every 2s |
| Bible Lv3 pulse timer | First pulse fires 2s after bible reaches Lv3 |
| Flamebible (evolved) | No pulse (weapon_id is "flamebible") |
| Pulse damage source | `take_damage(source="bible_pulse")` for kill attribution |

### 11.6 Holy Water Freeze Tests

| Test Case | Expected Behavior |
|---|---|
| Holy Water Lv1 blade hits enemy | No freeze applied |
| Holy Water Lv2 blade hits enemy | No freeze applied |
| Holy Water Lv3 blade hits enemy (randf < 0.15) | Enemy frozen for 0.5s |
| Holy Water Lv3 blade hits enemy (randf >= 0.15) | No freeze, normal damage |
| Holy Water Lv3 + frostaura Lv3, frozen enemy dies | Shatter triggers (cross-weapon synergy) |
| Thunderholywater (evolved) blade hits enemy | No freeze (weapon_id is "thunderholywater") |

### 11.7 Fire Staff Searing Burst Tests

| Test Case | Expected Behavior |
|---|---|
| Fire Staff Lv1 kills enemy (with burn from synergy) | No burst |
| Fire Staff Lv2 kills burning enemy | No burst |
| Fire Staff Lv3 kills burning enemy, no enemies within 45px | Burst triggers but hits nothing |
| Fire Staff Lv3 kills burning enemy, 3 enemies within 45px | Burst deals 3.0 * dmg_bonus to all 3 |
| Burst kills a second burning enemy | Second burst triggers (2-deep chain) |
| Second burst kills a third burning enemy | No third burst (`_last_hit_by` is "firestaff_burst") |
| Fireknife (evolved) kills burning enemy | No burst (weapon_id is "fireknife") |
| Non-firestaff burn kills enemy | No burst (`_last_hit_by` is not "firestaff") |

---

## 12. Design Decisions Log

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
| 9 | Lightning Chain On Kill uses die()-hook, NOT a signal | The original Tier B estimate assumed a signal from enemy -> weapon_controller. But fire_lightning() is a synchronous call, and the die() hook pattern (same as Shatter) is simpler and requires no signals or new callback chains. All state needed (player ref, weapon level, enemy position) is available in die() | Signal-based callback (adds coupling between enemy.gd and weapon_controller.gd) |
| 10 | Lightning COK source is "lightning_cok" (not "lightning") | Prevents recursive chain on kill. If the bonus bolt kills, `_last_hit_by` is "lightning_cok" which does not match the "lightning" check. Simple string mismatch prevents infinite loops without flags or counters | Chain depth counter (unnecessary complexity for a max-1-depth chain) |
| 11 | Lightning COK picks RANDOM target, not nearest | Lightning is thematically "chaotic energy". Random target creates unpredictable cascades that feel electric. Nearest target would be deterministic and boring | Nearest target (predictable, less exciting) |
| 12 | Bible pulse centered on PLAYER, not orbit blades | Orbit blades already cover 80-120px range. The pulse covers the 0-60px inner dead zone where blades cannot reach, making Bible a complete zone-control weapon | Pulse centered on blades (redundant with existing blade contact damage) |
| 13 | Bible pulse timer in weapon_controller.gd, not spin_blade.gd | The pulse is a property of the bible weapon, not the orbit blade instance. weapon_controller already manages weapon_timers and _physics_process. Adding the timer there keeps logic centralized | Timer in spin_blade.gd (would require passing level info, adds complexity to generic spin_blade) |
| 14 | Bible pulse uses create_pulse_ring_effect (new visual function) | The expanding ring visual is distinct from cone/polygon effects and provides clear visual feedback. Using the same inline-GDScript pattern as cone effect keeps consistency | Reuse create_cone_effect (wrong shape -- cone is directional, pulse is radial) |
| 15 | Holy Water freeze passes weapon_level through spin_blade, not via signal | The hit happens in spin_blade.gd `_physics_process()`, and freeze must be checked at hit time. Passing weapon_level via a simple property is the most minimal approach | Signal from spin_blade to weapon_controller (adds coupling, async timing issues) |
| 16 | Holy Water freeze chance 15% (not higher) | At 3 blades * 3 hits/sec * 15% = ~1.35 freezes/sec effective. This gives roughly 1 freeze per second, frequent enough to notice but not permanent lockdown. 25% would give ~2.25/sec, making enemies permanently frozen | 25% chance (too frequent, trivializes enemies) |
| 17 | Fire Staff revised from Burn Zone to Searing Burst | Burn zone required a new persistent Area2D scene with tick damage lifecycle (1 new .tscn + 1 new .gd + lifecycle management). Searing Burst achieves the same design goal (area splash on firestaff kills) using the same die()-hook pattern as Shatter, eliminating all new scenes and scripts | Burn zone with persistent Area2D (original design, 60 lines + 1 scene + 1 script) |
| 18 | Fire Staff burst checks `_last_hit_by == "firestaff"` | Ensures burst only triggers from firestaff-inflicted burns, not from mage_crit_to_burn or fire_slime burns. Keeps the effect scoped to the weapon identity | Check only `_burn_timer > 0` (would trigger on any burn source, too broad) |
| 19 | Fire Staff burst source is "firestaff_burst" | Same anti-recursion pattern as "lightning_cok". If burst kills a burning enemy, `_last_hit_by` on that enemy may still be "firestaff" (set before burst), allowing a 2-deep chain. The 2-deep chain is ACCEPTABLE and rewards the firestaff build | Strictly prevent all chains (would require a `_burst_depth` counter, unnecessary complexity) |
| 20 | All three die()-time effects (Shatter, COK, Burst) use the same hook pattern | Consistent code structure. All three check a status condition + weapon ownership + weapon level, then search enemies and deal damage. This makes the code predictable and easy to extend for future Lv3 effects | Different patterns per effect (inconsistent, harder to maintain) |
