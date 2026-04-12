# 进化武器精灵 AI 绘图提示词

## 通用风格锁定词

```
pixel art, 16-bit, top-down view, game sprite, transparent background, no outline, glowing effect, evolved form, more detailed than base weapon
```

## 通用负面提示词

```
blurry, 3d, realistic, photorealistic, text, watermark, simple, plain, basic
```

---

### 雷暴圣水 Thunder Holy Water (thunderholywater)
- **用途**：进化武器精灵（orbit 类型）
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：128x128 → 裁剪到 20x20
- **主体描述**：A glowing blue-white orb with electric arcs crackling around it, spinning motion trail, water droplets with lightning
- **配色指引**：主色 #3366FF 亮蓝，辅色 #FFFFFF 白色电弧，强调色 #FFFF00 黄色闪电
- **完整 Prompt**：`pixel art, 16-bit, top-down view, game sprite, transparent background, glowing blue-white water orb with crackling lightning arcs, electric sparks, evolved holy water, detailed pixel art --ar 1:1`
- **备注**：ColorRect 回退 Color(0.2, 0.4, 1.0)，10px，比基础圣水更大更亮

---

### 火焰飞刀 Fire Knife (fireknife)
- **用途**：进化武器精灵（projectile 类型）
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：64x64 → 裁剪到 12x12
- **主体描述**：A flaming throwing knife with fire trail, orange-red blade with burning aura, multiple copies in flight
- **配色指引**：主色 #FF9901 橙色火焰，辅色 #FF3300 红色刀身
- **完整 Prompt**：`pixel art, 16-bit, top-down view, game sprite, transparent background, a flaming throwing knife with fire trail, orange-red blade with burning aura, multiple knives flying, evolved weapon --ar 1:1`
- **备注**：ColorRect 回退 Color(1.0, 0.6, 0.1)，6px

---

### 圣光领域 Holy Domain (holydomain)
- **用途**：进化武器精灵（orbit + pulse 类型）
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：128x128 → 裁剪到 28x28
- **主体描述**：A massive golden-white light formation with 4 orbiting holy orbs, divine radiance emanating from center, heavenly glow
- **配色指引**：主色 #FFFFCC 金白色，辅色 #FFD700 金色
- **完整 Prompt**：`pixel art, 16-bit, top-down view, game sprite, transparent background, massive golden-white light formation with 4 orbiting holy orbs, divine radiance, heavenly glow effect, evolved weapon --ar 1:1`
- **备注**：ColorRect 回退 Color(1.0, 1.0, 0.8)，14px

---

### 暴风雪 Blizzard (blizzard)
- **用途**：进化武器精灵（aura + lightning 类型）
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：128x128 → 裁剪到 320x320 区域指示
- **主体描述**：A swirling ice storm with snowflakes and frozen lightning bolts, cold blue aura with frost particles
- **配色指引**：主色 #4D99FF 冰蓝色，辅色 #FFFFFF 白色雪花
- **完整 Prompt**：`pixel art, 16-bit, top-down view, game sprite, transparent background, swirling ice storm with snowflakes and frozen lightning, cold blue aura, frost particles, evolved frost aura --ar 1:1`
- **备注**：ColorRect 回退 Color(0.3, 0.6, 1.0)，160px 半径

---

### 冰霜飞刀 Frost Knife (frostknife)
- **用途**：进化武器精灵（projectile + slow 类型）
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：64x64 → 裁剪到 12x12
- **主体描述**：An icy throwing knife with frost trail, blue-white blade with freezing aura, ice crystals forming in its wake
- **配色指引**：主色 #66CCFF 冰蓝色，辅色 #FFFFFF 白色冰晶
- **完整 Prompt**：`pixel art, 16-bit, top-down view, game sprite, transparent background, an icy throwing knife with frost trail, blue-white blade with freezing aura, ice crystals, evolved weapon --ar 1:1`
- **备注**：ColorRect 回退 Color(0.4, 0.8, 1.0)，6px

---

### 烈焰经文 Flame Bible (flamebible)
- **用途**：进化武器精灵（orbit + burn 类型）
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：128x128 → 裁剪到 56x56
- **主体描述**：A burning sacred book with pages on fire, rotating with flame trails, fire pulses emanating outward
- **配色指引**：主色 #FF4D1A 火焰红，辅色 #FF8800 橙色，强调色 #FFD200 黄色火焰
- **完整 Prompt**：`pixel art, 16-bit, top-down view, game sprite, transparent background, a burning sacred book with pages on fire, rotating with flame trails, fire pulses, evolved bible --ar 1:1`
- **备注**：ColorRect 回退 Color(1.0, 0.3, 0.1)，28px

---

### 雷霆回旋 Thunder Boomerang (thunderang)
- **用途**：进化武器精灵（boomerang + lightning 类型）
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：64x64 → 裁剪到 20x20
- **主体描述**：An electric boomerang crackling with lightning, leaving electric arcs in its flight path, blue-white glow
- **配色指引**：主色 #80B2FF 闪电蓝，辅色 #FFFFFF 白色电弧
- **完整 Prompt**：`pixel art, 16-bit, top-down view, game sprite, transparent background, an electric boomerang crackling with lightning, electric arcs in flight path, blue-white glow, evolved weapon --ar 1:1`
- **备注**：ColorRect 回退 Color(0.5, 0.7, 1.0)，10px

---

### 烈焰回旋 Blaze Boomerang (blazerang)
- **用途**：进化武器精灵（boomerang + burn trail 类型）
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：64x64 → 裁剪到 20x20
- **主体描述**：A flaming boomerang leaving a trail of fire behind, orange-red glow, burning embers in its wake
- **配色指引**：主色 #FF6600 火焰橙，辅色 #CC3300 深红
- **完整 Prompt**：`pixel art, 16-bit, top-down view, game sprite, transparent background, a flaming boomerang leaving a trail of fire, orange-red glow, burning embers, evolved weapon --ar 1:1`
- **备注**：ColorRect 回退 Color(1.0, 0.4, 0.0)，10px

---

### 进化闪光特效 Evolution Flash
- **用途**：武器进化时全屏闪光效果
- **目标工具**：无需外部生成，代码实现
- **实现方式**：ColorRect 全屏覆盖白色 → alpha 渐变消失 0.3s
- **备注**：已在 `weapon_effects.gd` 的 `create_evolution_flash()` 中实现
