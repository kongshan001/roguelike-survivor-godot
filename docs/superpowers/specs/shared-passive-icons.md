# Shared Passive Icon Sprites -- v1.0.3 Spec

**Created**: 2026-04-17 (R24, Art Agent)
**Status**: Design complete, awaiting Programmer Agent integration

## Overview

7 shared passive items each get a unique 16x16 pixel art PNG icon. Icons replace the current ColorRect fallback in the upgrade card panel (hud.gd line 163: `card.get_node("VBox/Icon").color = option.icon_color`).

## Passive Icon Design Table

### 1. 暴击戒指 (Crit Ring) -- passive_id: "crit"

| Property | Value |
|----------|-------|
| Size | 16x16 px (canvas 32x32, downscaled) |
| Primary | Color(1.0, 0.80, 0.20) #FFCC33 warm gold |
| Secondary | Color(0.85, 0.65, 0.10) #D9A61A darker gold ring |
| Accent | Color(1.0, 1.0, 1.0) white star burst |
| Shape | Circular ring (band 2px wide) with 4-pointed star burst at top-right |
| Readability | Gold circle = ring. White star = critical hit burst. |
| ColorRect fallback | Color(1.0, 0.80, 0.20) 16x16 |

**Pixel layout (32x32 canvas)**:
```
Ring body: circle at (16,16) radius 10, 2px wide band in #FFCC33
Ring shadow: same circle, radius 11, 1px wide in #D9A61A (outer edge)
Star burst: 4-pointed star at (24,8), 4px span, #FFFFFF
Ring highlight: 2px arc at top-left of ring in #FFE680
Background: transparent
```

### 2. 护甲 (Armor) -- passive_id: "armor"

| Property | Value |
|----------|-------|
| Size | 16x16 px (canvas 32x32, downscaled) |
| Primary | Color(0.60, 0.60, 0.65) #999AA6 steel silver |
| Secondary | Color(0.45, 0.45, 0.50) #737380 darker steel |
| Accent | Color(1.0, 0.84, 0.0) #FFD700 gold rivet |
| Shape | Heater shield (pointed bottom, flat top), 2 gold rivets |
| Readability | Shield silhouette = defense/armor. Gold rivets = crafted item. |
| ColorRect fallback | Color(0.60, 0.60, 0.65) 16x16 |

**Pixel layout (32x32 canvas)**:
```
Shield body: heater shield outline -- flat top (x:8..24, y:6..7), 
  sides taper (x:8..16 left, x:24..16 right, y:8..26), 
  point bottom (16,28). Fill #999AA6.
Shield border: 1px darker outline #737380
Rivets: 2px gold dots at (12,12) and (20,12) in #FFD700
Crossbar: horizontal line at y=18, x:10..22 in #737380
Background: transparent
```

### 3. 磁铁 (Magnet) -- passive_id: "magnet"

| Property | Value |
|----------|-------|
| Size | 16x16 px (canvas 32x32, downscaled) |
| Primary | Color(0.90, 0.25, 0.25) #E64040 red pole |
| Secondary | Color(0.30, 0.30, 0.90) #4D4DE6 blue pole |
| Accent | Color(0.70, 0.70, 0.75) #B3B3BF silver body |
| Shape | U-shaped horseshoe magnet, red on left tip, blue on right tip |
| Readability | Horseshoe = magnet. Red/blue poles = attraction. |
| ColorRect fallback | Color(1.0, 0.30, 0.30) 16x16 |

**Pixel layout (32x32 canvas)**:
```
Left arm: vertical bar x:8..12, y:4..20 in #B3B3BF
Right arm: vertical bar x:20..24, y:4..20 in #B3B3BF
Curve: bottom arc connecting arms, y:18..26, x:8..24 in #B3B3BF
Red pole tip: fill (8..12, 4..8) in #E64040
Blue pole tip: fill (20..24, 4..8) in #4D4DE6
Highlight: 1px white line on left edge of each arm
Field lines: 2 small arcs around tips in semi-transparent gold
Background: transparent
```

### 4. 疾风靴 (Speed Boots) -- passive_id: "speedboots"

| Property | Value |
|----------|-------|
| Size | 16x16 px (canvas 32x32, downscaled) |
| Primary | Color(0.30, 0.70, 1.0) #4DB3FF sky blue |
| Secondary | Color(0.20, 0.50, 0.80) #3380CC darker blue |
| Accent | Color(1.0, 1.0, 1.0) white speed lines |
| Shape | Boot silhouette (side view) with 3 horizontal speed lines behind |
| Readability | Boot = footwear. Speed lines = fast movement. Blue = wind/sky. |
| ColorRect fallback | Color(0.30, 0.70, 1.0) 16x16 |

**Pixel layout (32x32 canvas)**:
```
Boot body: side-view boot, toe at right
  Shaft: x:14..22, y:4..16 in #4DB3FF
  Sole: x:10..26, y:16..20 in #3380CC
  Heel: x:10..14, y:16..24 in #3380CC
  Toe cap: x:22..26, y:12..16 in #3380CC
Speed lines: 3 horizontal lines at (4,8), (6,12), (4,16) in #FFFFFF, alpha 0.6
  each line 6px long, 1px tall
Lace detail: 2px crossing at (18,8) in #FFFFFF
Background: transparent
```

### 5. 生命结晶 (Max Health Crystal) -- passive_id: "maxhp"

| Property | Value |
|----------|-------|
| Size | 16x16 px (canvas 32x32, downscaled) |
| Primary | Color(0.85, 0.15, 0.35) #D92659 crimson |
| Secondary | Color(0.65, 0.10, 0.25) #A61A40 dark crimson |
| Accent | Color(1.0, 0.60, 0.75) #FF99BF pink highlight |
| Shape | Octagonal crystal/gem with internal facet lines and top highlight |
| Readability | Gem/crystal shape = valuable augment. Red/pink = health/vitality. |
| ColorRect fallback | Color(0.90, 0.20, 0.40) 16x16 |

**Pixel layout (32x32 canvas)**:
```
Crystal body: octagon centered at (16,18)
  Points at: (16,4), (26,10), (28,18), (26,26), (16,30), (6,26), (4,18), (6,10)
  Fill: #D92659
Facet line 1: (16,4) to (16,30) in #A61A40 (vertical center)
Facet line 2: (4,18) to (28,18) in #A61A40 (horizontal center)
Top highlight: triangle (12,8)-(20,8)-(16,4) in #FF99BF
Bottom shadow: triangle (16,30)-(26,26)-(6,26) in #A61A40
Background: transparent
```

### 6. 再生护符 (Regen Amulet) -- passive_id: "regen"

| Property | Value |
|----------|-------|
| Size | 16x16 px (canvas 32x32, downscaled) |
| Primary | Color(0.20, 0.85, 0.40) #33D966 emerald green |
| Secondary | Color(0.15, 0.65, 0.30) #26A64D darker green |
| Accent | Color(1.0, 1.0, 1.0) white cross (healing symbol) |
| Shape | Circular pendant/medallion with small loop at top, white cross in center |
| Readability | Medallion = amulet. Green cross = healing/regeneration. |
| ColorRect fallback | Color(0.20, 0.90, 0.40) 16x16 |

**Pixel layout (32x32 canvas)**:
```
Loop: small arc at (16,2..6), 4px wide opening in #26A64D
Chain hint: 2px line from loop top to canvas top edge in #26A64D
Medallion body: circle at (16,18) radius 10 in #33D966
Medallion border: circle at (16,18) radius 11, 1px in #26A64D
Cross vertical: (15..17, 12..24) in #FFFFFF
Cross horizontal: (10..22, 16..18) in #FFFFFF
Ring highlight: 2px arc at top-left of circle in #4DE680
Background: transparent
```

### 7. 幸运硬币 (Lucky Coin) -- passive_id: "luckycoin"

| Property | Value |
|----------|-------|
| Size | 16x16 px (canvas 32x32, downscaled) |
| Primary | Color(1.0, 0.85, 0.10) #FFD91A bright gold |
| Secondary | Color(0.85, 0.70, 0.05) #D9B30D darker gold edge |
| Accent | Color(0.90, 0.55, 0.0) #E68C00 amber star emblem |
| Shape | Circular coin with dentilled (notched) edge, central star emblem |
| Readability | Gold circle = coin. Star = luck/fortune. Amber = treasure. |
| ColorRect fallback | Color(1.0, 0.85, 0.10) 16x16 |

**Pixel layout (32x32 canvas)**:
```
Coin body: circle at (16,16) radius 11 in #FFD91A
Coin edge: circle at (16,16) radius 12, 1px in #D9B30D
Dentils: 8 small 1px bumps on outer edge at 45-degree intervals in #D9B30D
Inner circle: circle at (16,16) radius 8, 1px outline in #D9B30D
Star emblem: 5-pointed star at (16,16) ~6px span in #E68C00
Highlight: 2px arc at top-left in #FFE680
Shadow: 2px arc at bottom-right in #CCA800
Background: transparent
```

## ColorRect Fallback Mapping

When PNG fails to load, each passive falls back to a ColorRect:

| passive_id | Fallback Color | Size | Source |
|------------|---------------|------|--------|
| crit | Color(1.0, 0.80, 0.20) | 16x16 | Primary warm gold |
| armor | Color(0.60, 0.60, 0.65) | 16x16 | Steel silver |
| magnet | Color(1.0, 0.30, 0.30) | 16x16 | Red pole (upgrade_pool icon_color) |
| speedboots | Color(0.30, 0.70, 1.0) | 16x16 | Sky blue |
| maxhp | Color(0.90, 0.20, 0.40) | 16x16 | Crimson |
| regen | Color(0.20, 0.90, 0.40) | 16x16 | Emerald green |
| luckycoin | Color(1.0, 0.85, 0.10) | 16x16 | Bright gold |

Note: Fallback colors are derived from each icon's primary color. They match the `icon_color` values in `upgrade_pool.gd` where applicable (minor adjustments for visual consistency with the pixel art versions).

## PALETTE Additions for generate_sprites.py

```python
# Shared passive icons
"passive_crit_gold":      (0xFF, 0xCC, 0x33),  # #FFCC33 warm gold ring
"passive_crit_dark":      (0xD9, 0xA6, 0x1A),  # #D9A61A darker gold ring
"passive_armor_steel":    (0x99, 0x9A, 0xA6),  # #999AA6 steel silver
"passive_armor_dark":     (0x73, 0x73, 0x80),  # #737380 darker steel
"passive_magnet_red":     (0xE6, 0x40, 0x40),  # #E64040 red pole
"passive_magnet_blue":    (0x4D, 0x4D, 0xE6),  # #4D4DE6 blue pole
"passive_magnet_body":    (0xB3, 0xB3, 0xBF),  # #B3B3BF silver magnet body
"passive_boots_sky":      (0x4D, 0xB3, 0xFF),  # #4DB3FF sky blue
"passive_boots_dark":     (0x33, 0x80, 0xCC),  # #3380CC darker blue
"passive_hp_crimson":     (0xD9, 0x26, 0x59),  # #D92659 crimson crystal
"passive_hp_dark":        (0xA6, 0x1A, 0x40),  # #A61A40 dark crimson
"passive_hp_pink":        (0xFF, 0x99, 0xBF),  # #FF99BF pink highlight
"passive_regen_green":    (0x33, 0xD9, 0x66),  # #33D966 emerald green
"passive_regen_dark":     (0x26, 0xA6, 0x4D),  # #26A64D darker green
"passive_coin_gold":      (0xFF, 0xD9, 0x1A),  # #FFD91A bright gold coin
"passive_coin_dark":      (0xD9, 0xB3, 0x0D),  # #D9B30D darker gold edge
"passive_coin_amber":     (0xE6, 0x8C, 0x00),  # #E68C00 amber star emblem
```

## File Output Paths

| passive_id | File Path |
|------------|-----------|
| crit | assets/sprites/passives/crit.png |
| armor | assets/sprites/passives/armor.png |
| magnet | assets/sprites/passives/magnet.png |
| speedboots | assets/sprites/passives/speedboots.png |
| maxhp | assets/sprites/passives/maxhp.png |
| regen | assets/sprites/passives/regen.png |
| luckycoin | assets/sprites/passives/luckycoin.png |

## HUD Integration Guide (for Programmer Agent)

In `hud.gd` line 163, change from:
```gdscript
card.get_node("VBox/Icon").color = option.icon_color
```

To:
```gdscript
var icon_node = card.get_node("VBox/Icon")
var tex_path := "res://assets/sprites/passives/%s.png" % option.id
if option.type == "passive" and ResourceLoader.exists(tex_path):
    # Replace ColorRect with TextureRect or load texture
    icon_node.texture = load(tex_path)
else:
    icon_node.color = option.icon_color
```

If the icon node is a ColorRect (current), Programmer Agent should either:
1. Change the scene node from ColorRect to TextureRect and set `texture` + `stretch_mode`, or
2. Add a child TextureRect that overlays the ColorRect when PNG exists

Option 1 is cleaner. The TextureRect should use `stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED` with `texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST` to preserve pixel art.

## Design Decisions

1. **16x16 size consistent with character passive icons**: The 3 existing character passive icons (mage_vortex, warrior_shield, ranger_crosshair) are 16x16. Shared passive icons use the same size for visual consistency in the upgrade card panel.

2. **Shape-driven differentiation over color-only**: Each icon has a unique silhouette (ring, shield, horseshoe, boot, crystal, medallion, coin) so players can distinguish passives even in peripheral vision. Color reinforces the identity but is not the sole differentiator.

3. **Upgrade_pool icon_color preserved as ColorRect fallback**: The existing `icon_color` values in `upgrade_pool.gd` serve as the ColorRect fallback. PNG colors are slightly richer (3 colors vs 1 color) but the primary color maps back to the icon_color for consistency.

4. **Crit Ring vs Lucky Coin both gold-dominant**: These two passives both use gold tones. Differentiation is by shape (ring vs coin) and accent (white star burst vs amber star emblem). Lucky Coin uses a slightly more yellow gold (#FFD91A) while Crit Ring uses warmer gold (#FFCC33).

5. **Magnet uses classic red/blue pole coloring**: Red/blue is the universal magnet visual. The horseshoe shape is immediately recognizable. This differs from the upgrade_pool icon_color (red only) -- the PNG version adds the blue pole for full magnet identity.

6. **No outline for passive icons**: Unlike evolved weapon sprites which use a 1px dark outline (#1A1A2E), passive icons are small (16x16) and will appear on a card background. An outline would reduce internal detail space. If icons prove hard to read on certain backgrounds, a 1px outline can be added later.
