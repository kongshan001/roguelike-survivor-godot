# Phase 6 AI Art Prompts: Shop & Achievement UI

## Directory Index
- `shop_achievement_prompts.md` — Shop UI, Achievement icons, Quest panel

---

## Shop UI Background

**Purpose**: 商店界面背景纹理
**Target Tool**: Midjourney / Stable Diffusion
**Size**: 1280x720
**Style lock words**: pixel art, dark fantasy, 16-bit, UI background, arcane shop
**Color mapping**: Dark purple (#1a1a2e) base, Gold (#FFD700) accents, Deep blue (#16213e) borders
**Negative prompt**: realistic, 3D, photorealistic, blurry, text, watermark

**Prompt**:
```
pixel art style dark fantasy arcane shop background, stone walls with purple crystal shelves, golden candlelight, mystical atmosphere, dark purple and gold color palette, 16-bit game UI background, no characters, subtle magical particle effects, game shop interior --ar 16:9 --s 250
```

---

## Soul Fragment Icon

**Purpose**: 灵魂碎片货币图标
**Target Tool**: Midjourney / Stable Diffusion
**Size**: 64x64
**Style lock words**: pixel art, icon, glowing crystal, blue soul gem
**Color mapping**: Cyan (#00CED1) core, White (#FFFFFF) glow, Dark (#1a1a2e) outline
**Negative prompt**: realistic, large, complex, multiple objects, text

**Prompt**:
```
pixel art game icon, single glowing blue soul crystal fragment, cyan core with white ethereal glow, dark outline, centered, isolated on transparent background, 64x64 sprite, roguelike game currency icon --ar 1:1 --s 150
```

---

## Shop Upgrade Icons (6个)

### 1. Max HP Icon (生命强化)
```
pixel art game icon, red heart with plus symbol, glowing crimson, health upgrade, 64x64 sprite, dark outline, roguelike game item icon --ar 1:1 --s 150
```

### 2. Speed Icon (速度训练)
```
pixel art game icon, blue winged boot, glowing cyan, speed upgrade, 64x64 sprite, dark outline, roguelike game item icon --ar 1:1 --s 150
```

### 3. Pickup Range Icon (拾取精通)
```
pixel art game icon, green radar dish with signal waves, glowing lime, pickup range upgrade, 64x64 sprite, dark outline, roguelike game item icon --ar 1:1 --s 150
```

### 4. EXP Bonus Icon (知识汲取)
```
pixel art game icon, purple open book with sparkle, glowing violet, experience upgrade, 64x64 sprite, dark outline, roguelike game item icon --ar 1:1 --s 150
```

### 5. Weapon DMG Icon (武器精通)
```
pixel art game icon, golden crossed swords, glowing amber, weapon damage upgrade, 64x64 sprite, dark outline, roguelike game item icon --ar 1:1 --s 150
```

### 6. Gold Bonus Icon (贪婪之心)
```
pixel art game icon, golden coin with crown, glowing yellow, gold bonus upgrade, 64x64 sprite, dark outline, roguelike game item icon --ar 1:1 --s 150
```

---

## Achievement Badge Icons (通用)

### Common Achievement
```
pixel art game icon, bronze shield badge, simple design, achievement icon, 64x64 sprite, dark outline, roguelike game UI element --ar 1:1 --s 150
```

### Rare Achievement
```
pixel art game icon, silver star badge, radiant design, achievement icon, 64x64 sprite, dark outline, roguelike game UI element --ar 1:1 --s 150
```

### Epic Achievement
```
pixel art game icon, golden crown badge, legendary glow, achievement icon, 64x64 sprite, dark outline, roguelike game UI element --ar 1:1 --s 150
```

---

## Quest Panel Background

**Purpose**: 任务列表面板背景
**Target Tool**: Midjourney / Stable Diffusion
**Size**: 400x600
**Style lock words**: pixel art, scroll parchment, dark fantasy UI
**Color mapping**: Parchment (#F5DEB3) base, Dark brown (#3D2B1F) text, Gold border
**Negative prompt**: realistic, modern, clean, minimalist, text, watermark

**Prompt**:
```
pixel art style fantasy quest scroll panel, aged parchment texture, dark brown ornate border with gold trim, game UI overlay, medieval fantasy, 16-bit style, empty scroll with decorative header --ar 2:3 --s 200
```

---

## Achievement Unlock Effect

**Purpose**: 成就解锁时的视觉特效
**Target Tool**: For animation frames / sprite sheet
**Size**: 256x256 (sprite sheet 4x4 frames)
**Style lock words**: pixel art, golden burst, sparkle explosion
**Color mapping**: Gold (#FFD700) primary, White (#FFFFFF) flash, Orange (#FFA500) secondary
**Negative prompt**: realistic, 3D, slow, subtle, realistic lighting

**Prompt**:
```
pixel art sprite sheet, golden sparkle explosion burst effect, achievement unlock animation, 16 frames, bright gold and white particles, roguelike game VFX, dark background, symmetrical radial burst --ar 1:1 --s 200
```

---

## Soul Fragment Pickup Effect

**Purpose**: 拾取灵魂碎片的视觉特效
**Target Tool**: For animation frames / sprite sheet
**Size**: 128x128 (sprite sheet 4x4 frames)
**Style lock words**: pixel art, blue soul absorption, ethereal
**Color mapping**: Cyan (#00CED1) primary, White (#FFFFFF) flash
**Negative prompt**: realistic, 3D, fire, red, warm colors

**Prompt**:
```
pixel art sprite sheet, blue soul crystal absorption effect, cyan particles converging to center, ethereal glow, pickup VFX animation, 16 frames, roguelike game effect, dark background --ar 1:1 --s 200
```

---

## Fallback

如果 AI 生图效果不理想，当前项目继续使用 ColorRect 像素风占位方案：
- Soul Fragment: `ColorRect.color = Color(0, 0.8, 0.8)` (cyan)
- Shop icons: 使用 emoji 文字占位
- Achievement badges: `ColorRect.color = Color(1, 0.84, 0)` (gold)
- Quest panel: 深棕半透明背景
