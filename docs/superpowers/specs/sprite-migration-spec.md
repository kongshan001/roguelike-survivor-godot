# Sprite Migration Visual Specification (ColorRect -> Sprite2D)

**Author**: Art Agent R14
**Date**: 2026-04-17
**Related**: `docs/team/art-log.md`, `tools/generate_sprites.py`

## Overview

All game entity scenes have already migrated from ColorRect to Sprite2D (verified by QA R4 visual verification, 428 tests passed). This document specifies the visual mapping for any remaining ColorRect fallbacks and provides the complete reference table for Sprite2D texture -> display size -> modulate mappings.

Current migration status: **COMPLETE** for all 6 game entity scenes (player, enemy, projectile, xp_gem, item_crate, enemy_bullet).

---

## 1. Sprite Display Size Mapping

### 1.1 Entity Sprites

Each Sprite2D loads a PNG texture. The display size is controlled by `sprite.scale`, calculated as `scale_factor = (entity_size * 2.0) / base_texture_size`.

| Entity | PNG Texture | Texture Size (px) | Entity Size (px) | Scale Factor | Display Size (px) |
|--------|------------|-------------------|-------------------|-------------|-------------------|
| Player | `characters/{warrior,ranger,mage}.png` | 32x32 | 16 (collision radius) | 1.0 | 32x32 |
| Enemy (standard) | `enemies/{id}.png` | 32x32 | 16 (default) | 1.0 | 32x32 |
| Enemy (boss) | `enemies/boss.png` | 64x64 | 32 (boss) | 1.0 | 64x64 |
| Enemy (splitter_small) | `enemies/splitter_small.png` | 32x32 | 8 (splitter_small) | 0.5 | 16x16 |
| Enemy (elite_knight) | `enemies/elite_knight.png` | 24x24 | custom | varies | ~24x24 |
| Enemy (fire_slime) | `enemies/fire_slime.png` | 32x32 | custom | varies | ~32x32 |
| Projectile (standard) | `weapons/{id}.png` | 16x16 | varies | varies | varies |
| Projectile (evolved knife) | `weapons/fireknife.png` | 20x20 | varies | varies | varies |
| Projectile (evolved knife) | `weapons/frostknife.png` | 20x20 | varies | varies | varies |
| Boomerang (standard) | `weapons/boomerang.png` | 16x16 | varies | varies | varies |
| Boomerang (evolved) | `weapons/thunderang.png` | 20x20 | varies | varies | varies |
| Boomerang (evolved) | `weapons/blazerang.png` | 20x20 | varies | varies | varies |
| Enemy Bullet | `weapons/enemy_bullet.png` | 16x16 | varies | varies | varies |
| XP Gem Small | `pickups/xp_gem_small.png` | 8x8 | 6 (collision) | 1.0 | 8x8 |
| XP Gem Medium | `pickups/xp_gem_medium.png` | 10x10 | 6 (collision) | 1.0 | 10x10 |
| XP Gem Large | `pickups/xp_gem_large.png` | 12x12 | 6 (collision) | 1.0 | 12x12 |
| Food | `pickups/food.png` | 8x8 | 6 (collision) | 1.0 | 8x8 |
| Item Crate | `pickups/crate_{heal,xp,speed}.png` | 16x16 | 16x16 (collision) | 1.0 | 16x16 |
| Chest | `pickups/chest.png` | 16x16 | 16x16 (collision) | 1.0 | 16x16 |

### 1.2 Scale Factor Formula

All entity scripts use the same pattern:

```gdscript
var base_size: float = <TEXTURE_SIZE>.0  # 32.0 for enemies, 16.0 for weapons
var scale_factor: float = (entity_size * 2.0) / base_size
sprite.scale = Vector2(scale_factor, scale_factor)
```

Where `entity_size` is the collision radius (not diameter). This means:
- A 16px radius enemy with 32px texture => scale = (16*2)/32 = 1.0 (1:1 mapping)
- A 8px radius enemy with 32px texture => scale = (8*2)/32 = 0.5 (half size)

### 1.3 Centered Alignment

All Sprite2D nodes use `centered = true` (verified in all 6 entity .tscn files). This means:
- **Sprite2D position** = entity position (automatic centering, no manual offset needed)
- **Previous ColorRect** required manual `position = -size/2` offset (no longer needed)

For any remaining ColorRect elements, the Sprite2D equivalent is:

```gdscript
# ColorRect (old):
var rect = ColorRect.new()
rect.size = Vector2(32, 32)
rect.position = -rect.size / 2  # manual centering
rect.color = Color(0.3, 0.5, 1.0)

# Sprite2D (new):
var sprite = Sprite2D.new()
sprite.texture = load("res://assets/sprites/characters/mage.png")
# centered = true by default, no manual offset needed
```

---

## 2. Modulate Color Mapping Table

### 2.1 Modulate Values by Entity State

| State | Modulate Value | Usage |
|-------|---------------|-------|
| Normal | `Color.WHITE` (1,1,1,1) | Default state |
| Hurt Flash | `Color(8, 8, 8)` alternating with `Color.WHITE` | 0.2s duration, 0.1s toggle cycle |
| Freeze | `Color(0.5, 0.7, 1.0)` via modulate | Applied to enemy sprite during freeze |
| Burn | `Color(1.0, 0.4, 0.1)` tint | Applied via modulate on burning enemies |
| Alpha Fade (dying) | `modulate.a = 0.3` then `1.0` | Enemy death alpha oscillation |
| Dash Afterimage | `Color(player_color, alpha)` at 0.4/0.3/0.2 | Player dash residual images |

### 2.2 Damage Flash Implementation (Sprite2D)

Current implementation in `enemy.gd` line 137:

```gdscript
sprite.modulate = Color(8, 8, 8) if fmod(_flash_timer, 0.1) > 0.05 else Color.WHITE
```

**How this works with Sprite2D**: `Color(8, 8, 8)` uses HDR color values (>1.0) to create an overbright flash effect. When applied as `modulate`, it multiplies with the texture color, pushing all RGB channels toward white. This is the standard Sprite2D damage flash technique in Godot 4.x.

**Alternative approaches** (for reference):
- `sprite.modulate = Color.WHITE` with `sprite.self_modulate = Color(8,8,8)` -- same effect
- Tween-based: `tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)` -- smoother but requires tween management

### 2.3 Freeze Effect Implementation (Sprite2D)

Applied as modulate tint: `Color(0.5, 0.7, 1.0)` shifts the sprite toward blue.

For enhanced freeze with the new `freeze_star.png` effect sprite:
```gdscript
# Tint the enemy sprite
sprite.modulate = Color(0.5, 0.7, 1.0)

# Show freeze star above enemy
var star = Sprite2D.new()
star.texture = load("res://assets/sprites/effects/freeze_star.png")
star.position = Vector2(0, -enemy_data.size - 4)
add_child(star)
```

### 2.4 Burn Effect Implementation (Sprite2D)

Burn visual uses modulate tint on the sprite:
```gdscript
sprite.modulate = Color(1.0, 0.4, 0.1)  # orange-red tint while burning
```

### 2.5 Transparency/Alpha Effects (Sprite2D)

```gdscript
# Fade out
sprite.modulate.a = 0.5  # 50% transparent

# Ghost enemy (semi-transparent by default)
sprite.modulate = Color(1, 1, 1, 0.7)  # 70% opacity

# Dash afterimage
var afterimage = Sprite2D.new()
afterimage.texture = sprite.texture  # copy player texture
afterimage.modulate = Color(0.1, 0.14, 0.49, 0.3)  # player color, 30% alpha
```

---

## 3. Remaining ColorRect Usage (Non-Migrating)

The following ColorRect usages are intentional and should NOT be migrated to Sprite2D:

| Location | Usage | Reason |
|----------|-------|--------|
| `arena.tscn` Ground | Full-screen background | Solid color rectangle, no texture needed |
| `main.tscn` Background | Title screen background | Solid color, no texture |
| `shop.tscn` Background | Shop screen background | Solid color |
| `game_over_screen.tscn` Background | Game over background | Solid color |
| `character_select.gd:70` | Character selection icon | Dynamic color per character, too simple for texture |
| `weapon_select.gd:39` | Weapon selection icon | Dynamic color per weapon |
| `hud_skill_button.gd` | Skill cooldown overlay | Dynamic size/alpha for cooldown progress |
| `skill_effects.gd` | VFX elements | Dynamic size/color/alpha for expanding rings, afterimages, arrows |
| `weapon_effects.gd` | Flash effects | Full-screen flash with dynamic alpha |
| `achievement_screen.gd` | Panel backgrounds | UI panel background, solid color |

---

## 4. Lv3 Effect Sprite Integration Map

These 7 new effect sprites should be loaded by the Programmer Agent when implementing Lv3 weapon transforms:

| Effect Sprite | Size | Loaded In | ColorRect Fallback Color | Fallback Size |
|---------------|------|-----------|------------------------|---------------|
| `effects/knife_ricochet.png` | 8x8 | `projectile.gd` `_spawn_ricochet()` | Color(1.0, 0.90, 0.40) | 8x8 |
| `effects/frost_shatter.png` | 16x16 | `enemy.gd` `_spawn_shatter_effect()` | Color(0.53, 0.87, 1.0) | 16x16 |
| `effects/boomerang_homing_trail.png` | 8x8 | `boomerang.gd` `_physics_process()` | Color(0.27, 0.73, 0.33) | 8x8 |
| `effects/lightning_chain_kill.png` | 12x12 | `enemy.gd` `_handle_lightning_cok()` | Color(1.0, 0.87, 0.20) | 12x12 |
| `effects/bible_expand.png` | 16x16 | `weapon_effects.gd` `create_pulse_ring_effect()` | Color(1.0, 0.84, 0.0) | 16x16 |
| `effects/holywater_frost.png` | 8x8 | `spin_blade.gd` `_physics_process()` | Color(0.73, 0.87, 1.0) | 8x8 |
| `effects/firestaff_explode.png` | 16x16 | `enemy.gd` `_handle_firestaff_burst()` | Color(1.0, 0.27, 0.0) | 16x16 |

### Integration Pattern

Each effect sprite should follow this loading pattern:

```gdscript
# Try to load the effect sprite
var sprite = Sprite2D.new()
var tex_path = "res://assets/sprites/effects/<effect_name>.png"
if ResourceLoader.exists(tex_path):
    sprite.texture = load(tex_path)
else:
    # ColorRect fallback
    var rect = ColorRect.new()
    rect.size = Vector2(W, H)
    rect.color = FALLBACK_COLOR
    sprite = rect  # or add as sibling
sprite.centered = true
sprite.position = spawn_position
add_child(sprite)
```

---

## 5. Skill Icon Texture Integration

The 3 skill icon PNGs exist but are not yet loaded by `hud_skill_button.gd`. The Programmer Agent should update:

**Current** (`hud_skill_button.gd` line 53-58):
```gdscript
_skill_icon = ColorRect.new()
_skill_icon.color = icon_color  # solid color per character
```

**Target**:
```gdscript
var tex_path = "res://assets/sprites/skills/%s.png" % skill_id
if ResourceLoader.exists(tex_path):
    _skill_icon = TextureRect.new()
    _skill_icon.texture = load(tex_path)
    _skill_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
else:
    _skill_icon = ColorRect.new()
    _skill_icon.color = icon_color  # fallback
```

| Skill ID | Texture Path | Fallback Color |
|----------|-------------|---------------|
| `elemental_burst` | `res://assets/sprites/skills/elemental_burst.png` | Color(0.2, 0.4, 0.9) blue |
| `shield_charge` | `res://assets/sprites/skills/shield_charge.png` | Color(0.8, 0.2, 0.2) red |
| `arrow_rain` | `res://assets/sprites/skills/arrow_rain.png` | Color(0.2, 0.7, 0.3) green |

---

## 6. Character Passive Icon Texture Integration

The 3 passive icon PNGs exist in `assets/sprites/passives/`. Integration point: HUD upgrade cards.

| Passive ID | Texture Path | Fallback Color |
|------------|-------------|---------------|
| `mage_damage_scale` | `res://assets/sprites/passives/mage_vortex.png` | Color(0.10, 0.37, 0.90) |
| `warrior_armor_mastery` | `res://assets/sprites/passives/warrior_shield.png` | Color(0.80, 0.13, 0.13) |
| `ranger_crit_boost` | `res://assets/sprites/passives/ranger_crosshair.png` | Color(0.13, 0.55, 0.23) |
