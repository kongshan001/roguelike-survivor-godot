# Wave Transition AI Drawing Prompts

**Author**: Art Agent (R9)
**Date**: 2026-04-16
**Related Spec**: `docs/superpowers/specs/wave-transition-vfx.md`

## Common Style Lock Words

```
pixel art, 16-bit, top-down view, game UI, transparent background, crisp edges, simple design, dark outline #1A1A2E
```

## Common Negative Prompts

```
blurry, 3d, realistic, photorealistic, text, watermark, complex shading, anti-aliased, smooth gradients, photograph
```

---

### Wave Start Banner - Wave 1 Opening (wave_banner_w1)
- **Usage**: Wave start announcement banner background (green variant)
- **Target Tool**: Stable Diffusion / Midjourney
- **Size Spec**: 256x32 -> scale to 600x80
- **Style Lock Words**: pixel art, 16-bit, game UI, horizontal banner, green gradient, transparent edges
- **Subject Description**: A wide horizontal banner bar with green-tinted gradient background, bright green center stripe, 2px dark outline border on all edges, dashed accent lines near top and bottom, atmospheric wave announcement overlay, the gradient fades from bright green center to darker edges
- **Color Guide**: Main Color #4CAF50 green, Gradient Fade #2E7D32 darker green, Outline #1A1A2E dark indigo
- **Negative Prompts**: blurry, 3d, realistic, text, watermark, red, blue, yellow, solid fill
- **Full Prompt**: `pixel art, 16-bit, game UI, wide horizontal banner bar, green #4CAF50 tinted gradient background, brighter green center stripe, darker green edges, 2px dark outline border #1A1A2E, dashed accent lines near borders, atmospheric wave announcement overlay, clean pixel edges, transparent background --ar 15:2`
- **Notes**: ColorRect fallback Color(0.30, 0.69, 0.31) green, 600x80. Five color variants total (green/yellow/orange/red/deep-red). Wave color comes from WAVE_DEFS[0].color in game_manager.gd. File: `assets/sprites/ui/wave_banner_w1.png`

---

### Wave Start Banner - Wave 2 Swarm (wave_banner_w2)
- **Usage**: Wave start announcement banner background (yellow variant)
- **Target Tool**: Stable Diffusion / Midjourney
- **Size Spec**: 256x32 -> scale to 600x80
- **Style Lock Words**: pixel art, 16-bit, game UI, horizontal banner, yellow gradient, transparent edges
- **Subject Description**: A wide horizontal banner bar with yellow-tinted gradient background, bright golden center stripe, 2px dark outline border, dashed accent lines, atmospheric wave announcement overlay
- **Color Guide**: Main Color #FFD64F yellow, Gradient Fade #CC9900 darker yellow, Outline #1A1A2E dark indigo
- **Negative Prompts**: blurry, 3d, realistic, text, watermark, red, blue, green, solid fill
- **Full Prompt**: `pixel art, 16-bit, game UI, wide horizontal banner bar, golden yellow #FFD64F tinted gradient background, brighter gold center stripe, darker yellow edges, 2px dark outline border #1A1A2E, dashed accent lines near borders, atmospheric wave announcement overlay, clean pixel edges, transparent background --ar 15:2`
- **Notes**: ColorRect fallback Color(1.0, 0.84, 0.31) yellow, 600x80. WAVE_DEFS[1].color. File: `assets/sprites/ui/wave_banner_w2.png`

---

### Wave Start Banner - Wave 3 Darkness (wave_banner_w3)
- **Usage**: Wave start announcement banner background (orange variant)
- **Target Tool**: Stable Diffusion / Midjourney
- **Size Spec**: 256x32 -> scale to 600x80
- **Style Lock Words**: pixel art, 16-bit, game UI, horizontal banner, orange gradient, transparent edges
- **Subject Description**: A wide horizontal banner bar with orange-tinted gradient background, bright orange center stripe, 2px dark outline border, dashed accent lines, atmospheric wave announcement overlay
- **Color Guide**: Main Color #FF9100 orange, Gradient Fade #CC7200 darker orange, Outline #1A1A2E dark indigo
- **Negative Prompts**: blurry, 3d, realistic, text, watermark, red, blue, green, solid fill
- **Full Prompt**: `pixel art, 16-bit, game UI, wide horizontal banner bar, orange #FF9100 tinted gradient background, brighter orange center stripe, darker orange edges, 2px dark outline border #1A1A2E, dashed accent lines near borders, atmospheric wave announcement overlay, clean pixel edges, transparent background --ar 15:2`
- **Notes**: ColorRect fallback Color(1.0, 0.57, 0.0) orange, 600x80. WAVE_DEFS[2].color. File: `assets/sprites/ui/wave_banner_w3.png`

---

### Wave Start Banner - Wave 4 Elite (wave_banner_w4)
- **Usage**: Wave start announcement banner background (red variant)
- **Target Tool**: Stable Diffusion / Midjourney
- **Size Spec**: 256x32 -> scale to 600x80
- **Style Lock Words**: pixel art, 16-bit, game UI, horizontal banner, red gradient, transparent edges
- **Subject Description**: A wide horizontal banner bar with red-tinted gradient background, bright red center stripe, 2px dark outline border, dashed accent lines, atmospheric wave announcement overlay
- **Color Guide**: Main Color #F0544F red, Gradient Fade #B83030 darker red, Outline #1A1A2E dark indigo
- **Negative Prompts**: blurry, 3d, realistic, text, watermark, green, blue, yellow, solid fill
- **Full Prompt**: `pixel art, 16-bit, game UI, wide horizontal banner bar, red #F0544F tinted gradient background, brighter red center stripe, darker red edges, 2px dark outline border #1A1A2E, dashed accent lines near borders, atmospheric wave announcement overlay, clean pixel edges, transparent background --ar 15:2`
- **Notes**: ColorRect fallback Color(0.94, 0.33, 0.31) red, 600x80. WAVE_DEFS[3].color. File: `assets/sprites/ui/wave_banner_w4.png`

---

### Wave Start Banner - Wave 5 Boss (wave_banner_w5)
- **Usage**: Wave start announcement banner background (deep red variant)
- **Target Tool**: Stable Diffusion / Midjourney
- **Size Spec**: 256x32 -> scale to 600x80
- **Style Lock Words**: pixel art, 16-bit, game UI, horizontal banner, deep red gradient, transparent edges, danger
- **Subject Description**: A wide horizontal banner bar with deep red-tinted gradient background, bright crimson center stripe, 2px dark outline border, dashed accent lines, atmospheric and menacing boss wave announcement overlay
- **Color Guide**: Main Color #FF172B deep red, Gradient Fade #CC0E1E darker crimson, Outline #1A1A2E dark indigo
- **Negative Prompts**: blurry, 3d, realistic, text, watermark, green, blue, yellow, calm
- **Full Prompt**: `pixel art, 16-bit, game UI, wide horizontal banner bar, deep red #FF172B tinted gradient background, bright crimson center stripe, darker red edges, 2px dark outline border #1A1A2E, dashed accent lines near borders, menacing boss wave announcement overlay, clean pixel edges, transparent background --ar 15:2`
- **Notes**: ColorRect fallback Color(1.0, 0.09, 0.17) deep red, 600x80. WAVE_DEFS[4].color. File: `assets/sprites/ui/wave_banner_w5.png`

---

### Wave Complete Checkmark (wave_complete)
- **Usage**: Wave completion indicator icon
- **Target Tool**: Stable Diffusion / Midjourney
- **Size Spec**: 128x128 -> crop to 40x40
- **Style Lock Words**: pixel art, 16-bit, game UI, checkmark icon, green, transparent background
- **Subject Description**: A green checkmark symbol, 40x40 pixels, bold V-shaped stroke with dark outline, the checkmark starts from lower-left, angles down to bottom-center, then rises to upper-right, forming a classic checkmark shape, dark indigo outline around the stroke for visibility on any background
- **Color Guide**: Main Color #4CAF50 green, Darker Green #2E7D32 stroke depth, Outline #1A1A2E dark indigo, Highlight #FFFFFF white sparkle on top edge
- **Negative Prompts**: blurry, 3d, realistic, text, watermark, red, blue, X mark, cross
- **Full Prompt**: `pixel art, 16-bit, game UI, green checkmark icon, 40x40 pixels, #4CAF50 bold green checkmark V-stroke, darker green #2E7D32 depth on left side, dark outline #1A1A2E around stroke, white highlight sparkle on top edge, clean pixel-perfect shape, transparent background --ar 1:1`
- **Notes**: ColorRect fallback _draw() rendering green checkmark strokes, Color(0.3, 0.69, 0.31) #4CAF50. Displayed with pop-in animation (scale 0->1.2->1.0). File: `assets/sprites/ui/wave_complete.png`

---

### Boss Warning Flash Background (boss_flash_bg)
- **Usage**: Flashing red background behind Boss warning text (programmatic)
- **Target Tool**: Not needed -- ColorRect programmatic effect
- **Size Spec**: N/A -- full viewport width x 60px ColorRect
- **Subject Description**: N/A -- programmatic effect
- **Color Guide**: Color(0.8, 0.1, 0.1) deep red, alpha pulsing 0.3-0.7 with 0.4s cycle
- **Full Prompt**: N/A
- **Notes**: Pure ColorRect fallback implementation. Alpha pulses using sin wave formula. Duration 2.5s (existing BOSS_WARNING_TIME). No PNG asset needed.

---

### Fire Slime 32x32 (fire_slime)
- **Usage**: Enemy sprite for wave system, larger detailed variant
- **Target Tool**: Stable Diffusion / Midjourney
- **Size Spec**: 128x128 -> crop to 32x32
- **Style Lock Words**: pixel art, 16-bit, top-down view, game sprite, transparent background, dark outline #1A1A2E, fire creature
- **Subject Description**: An orange-red slime creature, amorphous blob body with rounded dome top and wavy liquid bottom edge, bright yellow-orange flame wisps burning on top with a tall central flame core, two white eyes with dark pupils, a wavy mouth expression, subtle membrane texture lines on the body, dark purple-brown outline around entire body and flame, larger and more detailed than the 16x16 variant at 32x32 pixels, top-down view
- **Color Guide**: Main Color #FF6622 orange-red body, Shadow #CC4411 darker orange bottom, Flame Core #FFCC00 bright yellow, Outline #1A1A2E dark indigo
- **Negative Prompts**: blurry, 3d, realistic, text, watermark, ice, blue, green slime, solid fire
- **Full Prompt**: `pixel art, 16-bit, top-down view, game sprite, transparent background, dark outline #1A1A2E, an orange-red #FF6622 slime creature at 32x32 pixels, amorphous blob body with rounded dome, bright yellow #FFCC00 flame wisps burning on top with tall central flame, white eyes with dark pupils, wavy liquid bottom edge, membrane texture lines, fire elemental enemy, simple design --ar 1:1`
- **Notes**: ColorRect fallback Color(1.0, 0.4, 0.133) #FF6622 orange-red, 32px. This replaces the previous 16x16 version. enemy_id "fire_slime". File: `assets/sprites/enemies/fire_slime.png`

---

## Prompt Iteration Log

| Date | Asset | Version | Evaluation | Next Optimization |
|------|-------|---------|------------|-------------------|
| 2026-04-16 | wave_banner_w1-w5 | v1 | First version, 5 color variants | Verify gradient quality at 600x80 |
| 2026-04-16 | wave_complete | v1 | First version, 40x40 checkmark | Verify checkmark readability at small size |
| 2026-04-16 | boss_flash_bg | N/A | Programmatic ColorRect, no prompt needed | N/A |
| 2026-04-16 | fire_slime 32x32 | v2 | Updated from 16x16 to 32x32 with more detail | Verify flame visibility at 32px |

## Fallback Scheme Reference

All assets provide ColorRect fallback:

| Asset | Fallback | Fallback Color |
|-------|----------|---------------|
| wave_banner_w1-w5 | ColorRect 600x80 | Wave-specific color from WAVE_DEFS |
| wave_complete | _draw() checkmark | Color(0.3, 0.69, 0.31) green |
| boss_flash_bg | ColorRect full-width x 60 | Color(0.8, 0.1, 0.1, 0.3-0.7) red pulsing |
| fire_slime | ColorRect 32x32 | Color(1.0, 0.4, 0.133) orange-red |
