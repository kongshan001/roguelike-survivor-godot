# Sprite2D Migration Color Specification

**Author**: Art Agent
**Date**: 2026-04-17
**Round**: R23
**Status**: Reference Spec
**Context**: 66 PNG sprites deployed, ColorRect->Sprite2D migration parameter reference for Programmer Agent.

---

## 1. Purpose

This document provides the complete Sprite2D migration color parameters for every game entity. Each entry includes the exact modulate value, sprite size, texture path, and ColorRect fallback. Programmer Agent can use this as a lookup table when integrating sprites or writing fallback code.

---

## 2. Character Sprites

| Sprite | Canvas | In-Game | Primary Color | Secondary | Accent | Texture Path | modulate |
|--------|--------|---------|--------------|-----------|--------|-------------|----------|
| mage.png | 32x32 | 16x16 | Color(0.1, 0.14, 0.49) | Color(0.08, 0.4, 0.75) | Color(1.0, 0.8, 0.6) | res://assets/sprites/characters/mage.png | Color.WHITE |
| warrior.png | 32x32 | 16x16 | Color(0.72, 0.11, 0.11) | Color(0.83, 0.18, 0.18) | Color(1.0, 0.8, 0.6) | res://assets/sprites/characters/warrior.png | Color.WHITE |
| ranger.png | 32x32 | 16x16 | Color(0.11, 0.37, 0.13) | Color(0.18, 0.45, 0.2) | Color(1.0, 0.8, 0.6) | res://assets/sprites/characters/ranger.png | Color.WHITE |
| mage_cast.png | 32x32 | 16x16 | Same as mage | Same as mage | Color(0.3, 0.5, 1.0) staff glow | res://assets/sprites/characters/mage_cast.png | Color.WHITE |
| warrior_block.png | 32x32 | 16x16 | Same as warrior | Same as warrior | Color(0.6, 0.6, 0.65) shield | res://assets/sprites/characters/warrior_block.png | Color.WHITE |
| ranger_draw.png | 32x32 | 16x16 | Same as ranger | Same as ranger | Color(0.9, 0.9, 0.8) arrow | res://assets/sprites/characters/ranger_draw.png | Color.WHITE |

**modulate rule**: Characters use `sprite.modulate = character_data.color` via player.gd. PNG contains full color data, so modulate is typically Color.WHITE. Animation frames swap texture, not modulate.

---

## 3. Enemy Sprites

| Sprite | Canvas | In-Game | Primary Color | Secondary | Faction | Texture Path | modulate |
|--------|--------|---------|--------------|-----------|---------|-------------|----------|
| zombie.png | 32x32 | 16x16 | Color(0.3, 0.69, 0.31) | -- | Green | res://assets/sprites/enemies/zombie.png | Color.WHITE |
| bat.png | 32x32 | 14x14 | Color(0.67, 0.28, 0.74) | -- | Purple | res://assets/sprites/enemies/bat.png | Color.WHITE |
| skeleton.png | 32x32 | 14x14 | Color(0.88, 0.88, 0.88) | -- | White | res://assets/sprites/enemies/skeleton.png | Color.WHITE |
| elite_skeleton.png | 32x32 | 18x18 | Color(0.72, 0.11, 0.11) | Color(1.0, 0.84, 0.0) gold eyes | Red (Elite) | res://assets/sprites/enemies/elite_skeleton.png | Color.WHITE |
| ghost.png | 32x32 | 12x12 | Color(0.69, 0.74, 0.77) | alpha=180 in PNG | Gray-White | res://assets/sprites/enemies/ghost.png | Color.WHITE |
| splitter.png | 32x32 | 16x16 | Color(0.0, 0.54, 0.48) | -- | Teal | res://assets/sprites/enemies/splitter.png | Color.WHITE |
| splitter_small.png | 32x32 | 8x8 | Color(0.3, 0.71, 0.68) | -- | Teal (juvenile) | res://assets/sprites/enemies/splitter_small.png | Color.WHITE |
| boss.png | 64x64 | 32x32 | Color(0.96, 0.26, 0.21) | Color(1.0, 0.84, 0.0) gold eyes | Red (Boss) | res://assets/sprites/enemies/boss.png | Color.WHITE |
| fire_slime.png | 32x32 | 16x16 | Color(1.0, 0.4, 0.13) | Color(1.0, 0.8, 0.0) core | Orange (Element) | res://assets/sprites/enemies/fire_slime.png | Color.WHITE |
| elite_knight.png | 24x24 | 18x18 | Color(0.27, 0.13, 0.4) | Color(0.53, 0.27, 0.73) highlight | Purple (Elite) | res://assets/sprites/enemies/elite_knight.png | Color.WHITE |

**modulate rule**: enemy.gd uses `sprite.modulate = _tint` for tinting. Default is Color.WHITE. Hit flash via enemy_death_effects.gd sets `sprite.modulate = Color(5, 5, 5)` then recovers. Ghost alpha=180 is baked into PNG.

### ColorRect Fallback (Enemy)

When PNG fails to load:
```
var fallback := ColorRect.new()
fallback.size = Vector2(enemy_data.size * 2, enemy_data.size * 2)
fallback.color = enemy_data.color
```

---

## 4. Weapon Sprites (Base)

| Sprite | Size | Primary Color | modulate (normal) | modulate (crit) | Texture Path | Render Type |
|--------|------|--------------|-------------------|-----------------|-------------|-------------|
| holy_water.png | 16x16 | Color(0.3, 0.5, 1.0) blue | data.color | Color(1.0, 0.85, 0.0) gold | res://assets/sprites/weapons/holy_water.png | orbit |
| knife.png | 16x16 | Color(0.75, 0.75, 0.8) silver | data.color | Color(1.0, 0.85, 0.0) gold | res://assets/sprites/weapons/knife.png | projectile |
| bible.png | 16x16 | Color(0.9, 0.85, 0.7) cream | data.color | Color(1.0, 0.85, 0.0) gold | res://assets/sprites/weapons/bible.png | orbit |
| boomerang.png | 16x16 | Color(0.6, 0.4, 0.2) brown | data.color | Color(1.0, 0.85, 0.0) gold | res://assets/sprites/weapons/boomerang.png | boomerang |
| lightning.png | 16x16 | Color(1.0, 1.0, 0.3) yellow | -- | -- | res://assets/sprites/weapons/lightning.png | HUD icon only |
| firestaff.png | 16x16 | Color(1.0, 0.4, 0.1) orange | -- | -- | res://assets/sprites/weapons/firestaff.png | HUD icon only |
| frostaura.png | 16x16 | Color(0.5, 0.8, 1.0) ice blue | -- | -- | res://assets/sprites/weapons/frostaura.png | HUD icon only |
| enemy_bullet.png | 16x16 | Color(0.88, 0.88, 0.88) white | -- | -- | res://assets/sprites/weapons/enemy_bullet.png | projectile |

**modulate rule**: projectile.gd line 49: `sprite.modulate = color` where color comes from weapon_data. On crit, weapon_fire.gd sets `proj.color = Color(1.0, 0.85, 0.0)` which propagates to modulate.

### ColorRect Fallback (Projectile)

When PNG fails to load:
```
sprite.texture = preload("res://assets/sprites/weapons/enemy_bullet.png")
# enemy_bullet.png is always available as universal fallback
```

---

## 5. Weapon Sprites (Evolved)

All evolved weapon PNGs contain full intrinsic color (not white base). modulate = Color.WHITE by default.

| Sprite | Size | Primary (Evolution) | Secondary | Accent | Outline | Texture Path |
|--------|------|--------------------|-----------|--------|---------|-------------|
| thunderholywater.png | 20x20 | Color(1.0, 0.84, 0.0) thunder yellow | Color(0.3, 0.5, 1.0) blue | Color(1.0, 1.0, 1.0) white | Color(0.102, 0.102, 0.18) | res://assets/sprites/weapons/thunderholywater.png |
| fireknife.png | 20x20 | Color(1.0, 0.27, 0.0) flame orange | Color(1.0, 0.55, 0.0) dark orange | Color(0.75, 0.75, 0.8) silver | Color(0.102, 0.102, 0.18) | res://assets/sprites/weapons/fireknife.png |
| holydomain.png | 24x24 | Color(1.0, 0.84, 0.0) holy gold | Color(0.3, 0.5, 1.0) blue | Color(1.0, 1.0, 1.0) white | Color(0.102, 0.102, 0.18) | res://assets/sprites/weapons/holydomain.png |
| blizzard.png | 24x24 | Color(0.53, 0.87, 1.0) ice blue | Color(1.0, 1.0, 1.0) ice white | Color(0.1, 0.1, 0.18) dark | Color(0.102, 0.102, 0.18) | res://assets/sprites/weapons/blizzard.png |
| frostknife.png | 20x20 | Color(0.53, 0.87, 1.0) ice blue | Color(0.75, 0.75, 0.8) silver | Color(1.0, 1.0, 1.0) white | Color(0.102, 0.102, 0.18) | res://assets/sprites/weapons/frostknife.png |
| flamebible.png | 20x20 | Color(1.0, 0.27, 0.0) fire red | Color(1.0, 0.55, 0.0) dark orange | Color(1.0, 0.84, 0.0) gold | Color(0.102, 0.102, 0.18) | res://assets/sprites/weapons/flamebible.png |
| thunderang.png | 20x20 | Color(1.0, 0.84, 0.0) electric yellow | Color(0.3, 0.5, 1.0) electric blue | Color(0.6, 0.4, 0.2) brown | Color(0.102, 0.102, 0.18) | res://assets/sprites/weapons/thunderang.png |
| blazerang.png | 20x20 | Color(1.0, 0.27, 0.0) blaze red | Color(1.0, 0.55, 0.0) dark orange | Color(0.6, 0.4, 0.2) brown | Color(0.102, 0.102, 0.18) | res://assets/sprites/weapons/blazerang.png |
| sentineltotem.png | 20x20 | Color(0.7, 0.6, 0.2) gold-brown | Color(0.9, 0.85, 0.5) gold projectile | Color(1.0, 0.84, 0.0) gold crown | Color(0.102, 0.102, 0.18) | res://assets/sprites/weapons/sentineltotem.png |

### Trail Colors for Projectiles

| weapon_id | Trail Color (RGB, alpha) | Trail Size | Unique Behavior |
|-----------|-------------------------|-----------|-----------------|
| knife | Color(0.75, 0.75, 0.8, 0.3) | Vector2(5, 7) | None |
| boomerang | Color(0.6, 0.4, 0.2, 0.25) | Vector2(8, 8) | None |
| fireknife | Color(1.0, 0.4, 0.1, 0.35) | Vector2(7, 9) | Scale 1.0->0.7 + spark particle |
| frostknife | Color(0.53, 0.87, 1.0, 0.3) | Vector2(7, 9) | Rotation +PI/4 + scale 1.0->0.5 |
| thunderang | Color(1.0, 0.84, 0.0, 0.25) | Vector2(9, 9) | Alpha flicker +-0.10 |
| blazerang | Color(1.0, 0.27, 0.0, 0.35) | Vector2(9, 9) | Scale 1.0->1.2 + spark particle |

---

## 6. Pickup Sprites

| Sprite | Size | Primary Color | Texture Path | modulate |
|--------|------|--------------|-------------|----------|
| xp_gem_small.png | 8x8 | Color(1.0, 1.0, 0.0) yellow | res://assets/sprites/pickups/xp_gem_small.png | Color.WHITE |
| xp_gem_medium.png | 10x10 | Color(0.0, 1.0, 0.0) green | res://assets/sprites/pickups/xp_gem_medium.png | Color.WHITE |
| xp_gem_large.png | 12x12 | Color(0.2, 0.4, 1.0) blue | res://assets/sprites/pickups/xp_gem_large.png | Color.WHITE |
| food.png | 8x8 | Color(0.4, 0.9, 0.3) green cross | res://assets/sprites/pickups/food.png | Color.WHITE |
| crate_heal.png | 16x16 | Color(0.4, 0.9, 0.3) green+white cross | res://assets/sprites/pickups/crate_heal.png | Color.WHITE |
| crate_xp.png | 16x16 | Color(0.0, 1.0, 1.0) cyan+white star | res://assets/sprites/pickups/crate_xp.png | Color.WHITE |
| crate_speed.png | 16x16 | Color(1.0, 0.5, 0.0) orange+white arrow | res://assets/sprites/pickups/crate_speed.png | Color.WHITE |
| chest.png | 16x16 | Color(0.545, 0.412, 0.078) brown | res://assets/sprites/pickups/chest.png | Color.WHITE |

---

## 7. Visual Z-Index Reference (Arena Scene)

| Layer | Size Range | Entity Types | z_index |
|-------|-----------|-------------|---------|
| 1 | 6-8 px | Small pickups (XP gems, food), small particles | 0 |
| 2 | 8-12 px | Hit feedback particles, splitter_small | 1 |
| 3 | 12-16 px | Base enemies (bat/skeleton/ghost), base projectiles (16x16) | 2 |
| 4 | 16-18 px | Player character, standard enemies (zombie/splitter), elite enemies | 3 |
| 5 | 18-20 px | Elite skeleton/knight, evolved projectiles (20x20) | 4 |
| 6 | 24 px | HolyDomain/Blizzard (24x24), skill icons | 5 |
| 7 | 32-64 px | Boss (64x64) | 6 |
| UI | Variable | HUD sprites, wave banners, mastery panel | 10+ |

---

## 8. ColorRect Fallback Quick Reference

For each entity type, the minimum ColorRect fallback when PNG is unavailable:

```gdscript
# Player fallback
var fb := ColorRect.new()
fb.size = Vector2(16, 16)
fb.color = character_data.color  # mage=deep blue, warrior=dark red, ranger=dark green

# Enemy fallback
var fb := ColorRect.new()
fb.size = Vector2(enemy_data.size * 2, enemy_data.size * 2)
fb.color = enemy_data.color

# Projectile fallback (always falls back to enemy_bullet.png)
sprite.texture = preload("res://assets/sprites/weapons/enemy_bullet.png")

# Pickup fallback
var fb := ColorRect.new()
fb.size = Vector2(8, 8)  # or 10/12/16 based on type
fb.color = pickup_color  # yellow/green/blue/green/orange/brown

# Hit particle (always ColorRect, no PNG needed)
var p := ColorRect.new()
p.size = Vector2(2, 2)
p.color = WEAPON_COLORS[weapon_id]  # from hit_feedback.gd

# Trail (always ColorRect, no PNG needed)
var t := ColorRect.new()
t.size = TRAIL_SIZES[weapon_id]  # from projectile_trail_pool.gd
t.color = TRAIL_COLORS[weapon_id]  # includes alpha

# Mastery badge (always ColorRect, no PNG needed)
var badge := ColorRect.new()
badge.size = Vector2(6, 6)
badge.color = border_color  # tier-dependent
var fill := ColorRect.new()
fill.size = Vector2(4, 4)
fill.position = Vector2(1, 1)
fill.color = fill_color  # tier-dependent
```
