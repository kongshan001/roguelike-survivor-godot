# Vampire Survivor-like Roguelike - Design Spec

## Overview

A minimal playable 2D top-down roguelike inspired by Vampire Survivors, built in Godot 4.6 with GDScript. The player moves with WASD while weapons auto-attack nearby enemies. Enemies spawn in escalating waves. Killing enemies drops experience gems; leveling up presents a choice of 3 random upgrades. The game ends when the player dies, showing a score screen.

**Visual style**: Simple geometric shapes (circles, rectangles) with solid colors. No external art assets required.

**Input**: WASD movement only. All attacks are automatic.

## Game Flow

```
Title Screen → Arena (main gameplay loop) → Game Over Screen → Title Screen
```

## Architecture: Scene-Driven

Each game entity is an independent Godot Scene communicating via signals. Weapon and passive data defined as Godot Resources (`.tres`).

### Autoload Singletons

| Singleton | Purpose |
|-----------|---------|
| `GameManager` | Game state: score, elapsed time, player level, pause state |
| `UpgradePool` | Registry of all weapons and passives available for selection |

### Scene Tree (Arena)

```
Arena (Node2D)
├── Camera2D (follows player)
├── GroundLayer (TileMap or ColorRect — visual floor)
├── Player (CharacterBody2D)
│   ├── CollisionShape2D
│   ├── Hurtbox (Area2D — detects enemy contact)
│   └── WeaponMount (Node2D — spawn point for projectiles)
├── EnemySpawner (Node)
├── ProjectileManager (Node2D)
├── PickupManager (Node2D)
├── DamageNumberManager (Node2D — floating damage text)
└── HUD (CanvasLayer)
    ├── HealthBar (TextureProgressBar)
    ├── XPBar (TextureProgressBar)
    ├── LevelLabel (Label)
    ├── TimerLabel (Label)
    └── UpgradePanel (Control — hidden until level up)
```

## Core Systems

### 1. Player

- **Movement**: 8-directional via WASD, speed starts at 150 px/s
- **Health**: 100 HP, displayed as a bar above the player and in HUD
- **Hurtbox**: Area2D that detects overlapping enemy Hitboxes. On contact, take damage, flash red, grant 0.5s invincibility
- **Death**: When HP <= 0, transition to Game Over screen

**Script**: `player.gd` — reads Input.get_vector("move_left", "move_right", "move_up", "move_down"), applies velocity, manages HP and invincibility timer.

### 2. Weapons (Auto-Attack)

Weapons fire automatically on a cooldown timer. Each weapon is a Resource defining its behavior, plus a corresponding Projectile scene.

**Initial weapon**: Magic Orb — fires a single orb toward the nearest enemy every 1.5s.

**Weapon Resource fields** (`weapon_data.gd` extends Resource):
- `weapon_name: String`
- `damage: float`
- `cooldown: float` (seconds)
- `projectile_scene: PackedScene`
- `projectile_count: int` (number of projectiles per fire)
- `projectile_speed: float`
- `projectile_pierce: int` (how many enemies it can hit before disappearing)
- `description: String`

**Projectile scene** (`projectile.gd` extends Area2D):
- Spawns at player position, moves toward nearest enemy (or fixed direction if none)
- On body_entered: deal damage, apply knockback, reduce pierce count
- Destroy when pierce <= 0 or off-screen for 5s

**Upgradable weapons** (defined as Resources):
| Weapon | Base Behavior | Upgrades Improve |
|--------|--------------|-----------------|
| Magic Orb | Single orb, 10 dmg, 1.5s cooldown | Damage, count, pierce |
| Spin Blade | Orbits player, 15 dmg, hits per rotation | Damage, orbit count, radius |
| Lightning | Hits random enemy in range, 20 dmg, 2s cooldown | Damage, chain count, range |
| Fire Burst | AoE explosion around player, 12 dmg, 3s cooldown | Damage, radius, frequency |

### 3. Enemies

**Base enemy scene** (`enemy.gd` extends CharacterBody2D):
- Moves toward player at variable speed
- Has HP, speed, damage, and XP_value properties
- On death: spawn XP gem, chance to spawn pickup crate
- Flash white on hit

**Enemy types** (each a separate scene extending base or configured via Resource):

| Enemy | HP | Speed | Damage | XP | Behavior |
|-------|-----|-------|--------|-----|----------|
| Slime (green circle) | 20 | 60 | 10 | 5 | Walks toward player |
| Bat (purple triangle) | 10 | 120 | 5 | 3 | Fast but fragile |
| Golem (brown square) | 80 | 30 | 25 | 15 | Slow tank |
| Boss (red hexagon) | 500 | 40 | 40 | 100 | Spawns every 60s, larger |

### 4. Enemy Spawner

`enemy_spawner.gd` attached to the Arena:
- Spawns enemies outside the camera viewport (random edge position)
- Spawn rate increases over time:
  - 0-30s: 1 enemy/2s
  - 30-60s: 2 enemies/2s
  - 60-120s: 3 enemies/1.5s
  - 120s+: 4 enemies/1s, mixed types
- Boss spawns at 60s, 120s, 180s, etc.
- Enemy HP scales +10% per minute elapsed

### 5. Experience & Level-Up

**XP Gems** (`xp_gem.gd` extends Area2D):
- Small colored circle dropped at enemy death position
- Drawn toward player when within pickup range (starts at 50px)
- On collect: add XP to player, show "+XP" floating text

**Level-up**:
- XP thresholds: 5, 12, 22, 35, 52, 73, 100, 135, 180, 240, ... (quadratic growth)
- On level up: pause game, show UpgradePanel with 3 random choices
- Choices drawn from `UpgradePool` — can be:
  - **New weapon** (if player doesn't have it yet)
  - **Weapon upgrade** (if player already has the weapon, improve its Resource values)
  - **Passive bonus** (one-time stat boost)

**Passive bonuses**:
| Passive | Effect |
|---------|--------|
| Max HP Up | +20 max HP (and heal 20) |
| Speed Up | +15% move speed |
| Pickup Range | +25px gem magnet range |
| Armor | -3 damage taken per hit |
| Regen | +1 HP per 5 seconds |

### 6. Pickups (Item Crates)

`item_crate.gd` extends Area2D:
- Green rectangle, spawns randomly on map or from enemy drops (10% chance)
- Player walks over to collect
- Possible drops: heal 30 HP, +50 bonus XP, temporary speed boost (10s)

### 7. HUD

`hud.gd` extends CanvasLayer:
- Top-left: Health bar (red), XP bar (blue), Level label
- Top-right: Survival timer (mm:ss format)
- On level-up: Show `UpgradePanel` (Centered, semi-transparent background)
  - 3 cards showing icon (colored shape) + name + description
  - Click or press 1/2/3 to select
  - On selection: apply upgrade, resume game

### 8. Game Over Screen

`game_over_screen.tscn`:
- Shows: survival time, enemies killed, player level, final score
- "Restart" button → reload Arena
- "Main Menu" button → return to title

### 9. Title Screen

`title_screen.tscn`:
- Game title "Survivor Arena" in large text
- "Start Game" button
- Brief controls hint: "WASD to move"

## File Structure

```
godot_demo/
├── project.godot
├── export_presets.cfg
├── scenes/
│   ├── main.tscn                    # Entry point
│   ├── title_screen.tscn
│   ├── arena.tscn                   # Main gameplay scene
│   ├── game_over_screen.tscn
│   ├── player.tscn
│   ├── enemy.tscn                   # Base enemy (reused for all types)
│   ├── projectile.tscn              # Generic projectile
│   ├── xp_gem.tscn
│   ├── item_crate.tscn
│   └── hud.tscn
├── scripts/
│   ├── autoload/
│   │   ├── game_manager.gd
│   │   └── upgrade_pool.gd
│   ├── player.gd
│   ├── enemy.gd
│   ├── enemy_spawner.gd
│   ├── projectile.gd
│   ├── xp_gem.gd
│   ├── item_crate.gd
│   ├── pickup_manager.gd
│   ├── weapon_data.gd               # Resource class
│   ├── weapon_controller.gd         # Attached to player, manages weapon timers
│   ├── hud.gd
│   ├── title_screen.gd
│   ├── game_over_screen.gd
│   └── arena.gd
├── resources/
│   ├── weapons/
│   │   ├── magic_orb.tres
│   │   ├── spin_blade.tres
│   │   ├── lightning.tres
│   │   └── fire_burst.tres
│   └── enemies/
│       ├── slime.tres
│       ├── bat.tres
│       ├── golem.tres
│       └── boss.tres
└── docs/
```

## Design Decisions

1. **Single enemy scene with Resource configuration**: Instead of 4 separate enemy scenes, use one `enemy.tscn` with an `enemy_data.gd` Resource that sets color, shape, size, HP, speed, etc. This keeps the scene count low while allowing easy enemy variety.

2. **Weapon as Resource + generic projectile**: Weapons are data (Resource) + behavior (script). The projectile scene is reused — its appearance and behavior come from the weapon Resource. Spin Blade and Fire Burst have their own specialized scenes since they behave differently from a flying projectile.

3. **No save system for MVP**: Game state resets on restart. No persistence needed.

4. **Fixed arena size**: The play area is a 3000x3000 pixel arena. Camera follows player. Enemies spawn outside the camera view but within arena bounds.

5. **Color-coded everything**: Player = white circle, enemies = colored shapes, projectiles = weapon-colored, XP gems = yellow, HP pickups = green, damage numbers = white/red.
