# 角色技能视觉效果 AI 绘图提示词

**Author**: Art Agent
**Date**: 2026-04-16
**Related Spec**: `docs/superpowers/specs/skill-vfx-spec.md`, `docs/superpowers/specs/character-skills.md` Section 7

## 通用风格锁定词

```
pixel art, 16-bit, top-down view, game sprite, transparent background, crisp edges, no anti-aliasing, dark outline #1A1A2E
```

## 通用负面提示词

```
blurry, 3d, realistic, photorealistic, text, watermark, complex shading, anti-aliased, smooth gradients, photograph, high resolution
```

---

### Mage 技能图标 - Elemental Burst (elemental_burst)
- **用途**：HUD 技能按钮图标
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：64x64 -> 裁剪到 24x24
- **风格锁定词**：pixel art, 16-bit, game UI icon, circular shape, blue magic, transparent background, dark outline
- **主体描述**：A circular blue magic skill icon with radiating arcane energy lines emanating from a bright center point, 8 thin rays extending outward, inner glowing ring, white sparkle at center, evoking a burst of arcane power from a mage character, top-down view
- **配色指引**：主色 #3366E6 蓝色，辅色 #4D80FF 内发光，强调色 #FFFFFF 白色高光
- **负面提示词**：blurry, 3d, realistic, text, watermark, red, green, fire, sword, shield
- **完整 Prompt**：`pixel art, 16-bit, game UI icon, circular blue magic skill icon, 24x24 pixels, #3366E6 deep blue circle with #4D80FF inner glow ring, 8 radiating arcane energy lines, bright white #FFFFFF center sparkle, dark outline #1A1A2E, transparent background, evoking an elemental burst explosion, simple and clean design --ar 1:1`
- **备注**：ColorRect 回退 Color(0.2, 0.4, 0.9) #3366E6 24x24 圆形；在 hud.gd 中作为技能按钮图标使用。character_skills.md Section 7.1 定义 Icon Shape=24x24 circle, Icon Color=Color(0.2, 0.4, 0.9)

---

### Warrior 技能图标 - Shield Charge (shield_charge)
- **用途**：HUD 技能按钮图标
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：64x64 -> 裁剪到 24x24
- **风格锁定词**：pixel art, 16-bit, game UI icon, shield shape, red, transparent background, dark outline
- **主体描述**：A red shield-shaped skill icon with a top-center notch (like a crenellation), golden cross emblem in the center of the shield, white highlight on upper-left corner, the shield is wider than tall with a flat top except for the center notch gap, evoking a warrior's charging shield, top-down view
- **配色指引**：主色 #CC3333 红色，辅色 #FFD700 金色十字纹，强调色 #FFFFFF 白色高光
- **负面提示词**：blurry, 3d, realistic, text, watermark, blue, green, magic, circle, diamond
- **完整 Prompt**：`pixel art, 16-bit, game UI icon, red shield skill icon, 24x24 pixels, #CC3333 red shield body with top-center notch cutout, #FFD700 golden cross emblem in center, #FFFFFF white highlight on upper-left, dark outline #1A1A2E, transparent background, evoking a warrior shield charge ability, clean and bold design --ar 1:1`
- **备注**：ColorRect 回退 Color(0.8, 0.2, 0.2) #CC3333 24x24 方形带缺口；character_skills.md Section 7.1 定义 Icon Shape=24x24 square with notch, Icon Color=Color(0.8, 0.2, 0.2)

---

### Ranger 技能图标 - Arrow Rain (arrow_rain)
- **用途**：HUD 技能按钮图标
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：64x64 -> 裁剪到 24x24
- **风格锁定词**：pixel art, 16-bit, game UI icon, diamond shape, green, arrows, transparent background, dark outline
- **主体描述**：A green diamond-shaped skill icon with three small downward-pointing arrows arranged in a triangle pattern inside the diamond, the arrows are off-white with white tips, one arrow at top-center and two below it, representing arrows falling from the sky, top-down view
- **配色指引**：主色 #33B34D 绿色，辅色 #E6E6CC 箭矢灰白，强调色 #FFFFFF 箭头白色
- **负面提示词**：blurry, 3d, realistic, text, watermark, red, blue, circle, square, fire
- **完整 Prompt**：`pixel art, 16-bit, game UI icon, green diamond skill icon, 24x24 pixels, #33B34D green diamond body, three small off-white #E6E6CC downward arrows with white tips inside the diamond, arranged in triangle pattern, dark outline #1A1A2E, transparent background, evoking an arrow rain ability, clean and readable design --ar 1:1`
- **备注**：ColorRect 回退 Color(0.2, 0.7, 0.3) #33B34D 24x24 菱形；character_skills.md Section 7.1 定义 Icon Shape=24x24 diamond, Icon Color=Color(0.2, 0.7, 0.3)

---

### Mage 技能特效 - Elemental Burst 扩散圆环
- **用途**：技能释放时的视觉效果（程序化生成参考）
- **目标工具**：Stable Diffusion / Midjourney (参考/概念图)
- **尺寸规格**：256x256 -> 参考，实际由程序化 ColorRect 缩放生成
- **风格锁定词**：pixel art, 16-bit, top-down view, game effect, expanding ring, blue energy, transparent background
- **主体描述**：A single frame of an expanding blue-white energy ring, viewed from directly above, the ring is a hollow circle with bright blue-white edges and transparent center, the ring has a subtle glow halo around its outer edge, energy particles scattered along the circumference, representing a magical AoE burst centered on a character
- **配色指引**：主色 Color(0.3, 0.5, 1.0) 蓝白能量，alpha 从 0.8 渐变到 0.0
- **负面提示词**：blurry, 3d, realistic, text, watermark, red, green, fire, solid fill
- **完整 Prompt**：`pixel art, 16-bit, top-down view, game effect sprite, a single frame of an expanding blue-white energy ring, hollow circle with bright #4D80FF blue edges, transparent center, subtle outer glow halo, energy particles along circumference, magical AoE burst effect, transparent background, clean pixel edges --ar 1:1`
- **备注**：ColorRect 程序化回退方案 -- 使用 `_draw()` 绘制 Color(0.3, 0.5, 1.0) 圆环，半径 0->150px 线性扩展，alpha 0.8->0.0 线性衰减，持续 0.2s。详见 skill-vfx-spec.md Section 2.1

---

### Mage 技能特效 - 敌人冰冻蓝色调
- **用途**：被冰冻敌人的 modulate 色调叠加（程序化参考）
- **目标工具**：无需 AI 生成，程序化 modulate 实现
- **尺寸规格**：不适用（直接修改 enemy.modulate 属性）
- **主体描述**：N/A -- 程序化效果
- **配色指引**：modulate 颜色 Color(0.5, 0.7, 1.0) 冰蓝色叠加，持续 1.5s，最后 0.3s 渐变恢复
- **完整 Prompt**：不适用
- **备注**：ColorRect 程序化回退方案 -- 对被命中敌人的 `modulate` 属性设置 Color(0.5, 0.7, 1.0)，1.5s 后在 0.3s 内插值恢复为 Color(1.0, 1.0, 1.0)。详见 skill-vfx-spec.md Section 2.2

---

### Warrior 技能特效 - Shield Charge 红色残影
- **用途**：战士冲刺路径上的残影效果（程序化参考）
- **目标工具**：Stable Diffusion / Midjourney (参考/概念图)
- **尺寸规格**：128x128 -> 参考，实际为 32x32 ColorRect
- **风格锁定词**：pixel art, 16-bit, top-down view, game effect, afterimage, red ghost, transparent background
- **主体描述**：Three red semi-transparent afterimage silhouettes of a warrior character, each progressively more transparent (alpha 0.4, 0.3, 0.2), positioned along a dash path from left to right, each afterimage is a simplified rectangular ghost shape in bright red #E6331A, trailing behind the dashing character, top-down view
- **配色指引**：主色 Color(0.9, 0.2, 0.1) 亮红，三段 alpha 分别 0.4/0.3/0.2
- **负面提示词**：blurry, 3d, realistic, text, watermark, blue, green, detailed, complex
- **完整 Prompt**：`pixel art, 16-bit, top-down view, game effect, three red semi-transparent afterimage silhouettes, rectangular ghost shapes in bright #E6331A red, progressively fading from left to right, alpha 0.4 0.3 0.2, dash trail effect, simple and clean, transparent background --ar 3:1`
- **备注**：ColorRect 程序化回退方案 -- 3 个 32x32 ColorRect，颜色 Color(0.9, 0.2, 0.1)，沿 160px 冲刺路径每隔 40px 放置，alpha 0.4/0.3/0.2 各自 0.3s 内衰减到 0。详见 skill-vfx-spec.md Section 3.1

---

### Warrior 技能特效 - 眩晕星星
- **用途**：被眩晕敌人头顶的旋转星星标记
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：32x32 -> 裁剪到 6x6
- **风格锁定词**：pixel art, 16-bit, game effect, spinning stars, stun indicator, yellow, transparent background
- **主体描述**：A tiny 6x6 pixel yellow four-pointed star with white center highlight, simple star shape with pointed tips extending in four cardinal directions, used as a stun status indicator that orbits above an enemy's head in groups of three, clean and recognizable even at very small size
- **配色指引**：主色 #FFFF00 黄色，强调色 #FFFFFF 白色中心高光，描边 #1A1A2E 暗蓝紫
- **负面提示词**：blurry, 3d, realistic, text, watermark, large, complex, five-pointed
- **完整 Prompt**：`pixel art, 16-bit, game effect sprite, tiny 6x6 yellow #FFFF00 four-pointed star, white #FFFFFF center highlight, dark outline #1A1A2E, stun status indicator, clean pixel-perfect shape, very small and simple, transparent background --ar 1:1`
- **备注**：ColorRect 回退 6x6 ColorRect Color(1.0, 1.0, 0.0) #FFFF00；3 个星星以 120 度间隔围绕敌人头顶 8px 半径旋转，旋转速度 240 deg/s，持续 2.0s。详见 skill-vfx-spec.md Section 3.2。PNG 文件 `assets/sprites/effects/freeze_star.png`

---

### Ranger 技能特效 - Arrow Rain 警告圆
- **用途**：箭雨落下前的目标区域警告指示器（程序化参考）
- **目标工具**：Stable Diffusion / Midjourney (参考/概念图)
- **尺寸规格**：256x256 -> 参考，实际由程序化 ColorRect 绘制
- **风格锁定词**：pixel art, 16-bit, top-down view, game effect, warning circle, yellow, transparent background
- **主体描述**：A semi-transparent yellow warning circle on the ground, 100px radius, viewed from directly above, the circle has a thin yellow outline ring and a very faint yellow fill inside, pulsing gently to draw player attention, indicating where arrows will fall, simple and functional warning indicator
- **配色指引**：主色 Color(1.0, 0.85, 0.0) 黄色半透明，填充 Color(1.0, 0.85, 0.0, 0.15)，描边 alpha 0.3
- **负面提示词**：blurry, 3d, realistic, text, watermark, red, blue, solid, opaque
- **完整 Prompt**：`pixel art, 16-bit, top-down view, game effect, semi-transparent yellow warning circle on ground, 100px radius, thin #FFD900 yellow outline ring, very faint yellow fill inside, pulsing alpha, danger zone indicator for incoming arrows, transparent background, clean and functional --ar 1:1`
- **备注**：ColorRect 程序化回退方案 -- 使用 `_draw()` 绘制 Color(1.0, 0.85, 0.0, 0.3) 圆形轮廓 + Color(1.0, 0.85, 0.0, 0.15) 半透明填充，alpha 在 0.15-0.35 之间脉冲，持续 0.3s。详见 skill-vfx-spec.md Section 4.1

---

### Ranger 技能特效 - 箭矢
- **用途**：箭雨技能中从天空落下的单个箭矢精灵
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：32x64 -> 裁剪到 4x12
- **风格锁定词**：pixel art, 16-bit, game sprite, single arrow, vertical, falling, transparent background
- **主体描述**：A single narrow arrow projectile, 4 pixels wide and 12 pixels tall, pointing downward, off-white body with white arrowhead tip at the top, simple fletching at the bottom, thin and elongated shape suggesting a fast-falling projectile, dark outline for visibility
- **配色指引**：主色 #E6E6CC 灰白箭身，强调色 #FFFFFF 白色箭头尖端
- **负面提示词**：blurry, 3d, realistic, text, watermark, red, blue, wide, thick, horizontal
- **完整 Prompt**：`pixel art, 16-bit, game sprite, single narrow arrow, 4x12 pixels, pointing downward, off-white #E6E6CC body, white #FFFFFF arrowhead tip at top, simple fletching at bottom, thin and elongated, dark outline #1A1A2E, fast-falling projectile appearance, transparent background --ar 1:3`
- **备注**：ColorRect 回退 4x12 ColorRect Color(0.9, 0.9, 0.8) #E6E6CC；12 个箭矢在 100px 半径圆内均匀分布（内圈3/中圈4/外圈5），分4波每波3箭落下，每箭持续 0.2s。PNG 文件 `assets/sprites/effects/arrow.png`

---

### Ranger 技能特效 - 落地闪光
- **用途**：箭矢落地瞬间的白色闪光效果（程序化参考）
- **目标工具**：无需 AI 生成，程序化效果
- **尺寸规格**：不适用（程序化 4x4 -> 12x12 扩展 ColorRect）
- **主体描述**：N/A -- 程序化效果
- **配色指引**：Color(1.0, 1.0, 0.8) 暖白色闪光，从 4x4px 扩展到 12x12px，alpha 0.9->0.0，持续 0.1s
- **完整 Prompt**：不适用
- **备注**：ColorRect 程序化回退方案 -- 每个箭矢落地时在落点创建一个 ColorRect，颜色 Color(1.0, 1.0, 0.8)，从 4x4px 线性扩展到 12x12px，alpha 从 0.9 线性衰减到 0.0，持续 0.1s。详见 skill-vfx-spec.md Section 4.3

---

### 波次转场横幅 - Wave Transition (wave_transition)
- **用途**：波次切换时屏幕中央的水平横幅背景
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：256x16 -> 缩放到 1280x80
- **风格锁定词**：pixel art, 16-bit, game UI, horizontal banner, dark gradient, transparent background
- **主体描述**：A wide horizontal banner bar, dark indigo-purple background with subtle vertical gradient (brighter in center, darker at edges), thin bright edge highlights on top and bottom borders, dashed accent lines inside, clean and atmospheric, used as a wave transition announcement background overlay
- **配色指引**：主色 #1A1A2E 暗蓝紫背景，辅色 #2A2A4E 中心亮条渐变，强调色 #3A3A5E 边缘高光
- **负面提示词**：blurry, 3d, realistic, text, watermark, bright, colorful, red, yellow
- **完整 Prompt**：`pixel art, 16-bit, game UI, wide horizontal banner bar, dark indigo #1A1A2E background, subtle center gradient brighter #2A2A4E, thin #3A3A5E edge highlights top and bottom, dashed accent lines, atmospheric wave transition overlay, clean and minimal, transparent background --ar 16:1`
- **备注**：ColorRect 回退 1280x80 ColorRect Color(0.102, 0.102, 0.18) #1A1A2E；渐变通过中心行变亮实现。PNG 文件 `assets/sprites/ui/wave_transition.png`

---

## 提示词迭代日志

| 日期 | 资产 | 版本 | 评价 | 优化方向 |
|------|------|------|------|---------|
| 2026-04-16 | elemental_burst | v1 | 首次编写 | 待生成验证 |
| 2026-04-16 | shield_charge | v1 | 首次编写 | 待生成验证 |
| 2026-04-16 | arrow_rain | v1 | 首次编写 | 待生成验证 |
| 2026-04-16 | freeze_star | v1 | 首次编写 | 待生成验证 |
| 2026-04-16 | arrow | v1 | 首次编写 | 待生成验证 |
| 2026-04-16 | wave_transition | v1 | 首次编写 | 待生成验证 |

## 回退方案对照表

所有技能 VFX 均提供 ColorRect 程序化回退方案，确保无美术资产时游戏可正常运行。

| VFX 元素 | 回退方案 | 详细规格 |
|----------|---------|---------|
| 扩散圆环 | `_draw()` 绘制 Color(0.3, 0.5, 1.0) 圆环 | skill-vfx-spec.md 2.1 |
| 冰冻色调 | `modulate = Color(0.5, 0.7, 1.0)` | skill-vfx-spec.md 2.2 |
| 红色残影 | 3x 32x32 ColorRect, alpha 递减 | skill-vfx-spec.md 3.1 |
| 眩晕星星 | 3x 6x6 ColorRect 旋转 | skill-vfx-spec.md 3.2 |
| 警告圆 | `_draw()` 绘制半透明黄色圆 | skill-vfx-spec.md 4.1 |
| 箭矢 | 12x 4x12 ColorRect | skill-vfx-spec.md 4.2 |
| 落地闪光 | 4x4->12x12 扩展 ColorRect | skill-vfx-spec.md 4.3 |
| 波次横幅 | 1280x80 ColorRect | 本文件 |
