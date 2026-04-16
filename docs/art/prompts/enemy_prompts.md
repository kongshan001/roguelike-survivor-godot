# 敌人精灵 AI 绘图提示词

## 通用风格锁定词

```
pixel art, 16-bit, top-down view, game sprite, transparent background, no outline, simple design, dark background for visibility
```

## 通用负面提示词

```
blurry, 3d, realistic, photorealistic, text, watermark, complex shading, anti-aliased, smooth gradients
```

---

### 僵尸 Zombie (zombie)
- **用途**：敌人精灵
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：64x64 → 裁剪到 16x16
- **主体描述**：A shambling zombie with outstretched arms, green skin, torn clothes, seen from top-down view
- **配色指引**：主色 #4CAF50 绿色，辅色 #2E7D32 深绿
- **完整 Prompt**：`pixel art, 16-bit, top-down view, game sprite, transparent background, no outline, a green zombie with outstretched arms, shambling pose, torn clothes, simple design --ar 1:1`
- **备注**：ColorRect 回退 Color(0.3, 0.69, 0.31)，16px 正方形

---

### 蝙蝠 Bat (bat)
- **用途**：敌人精灵
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：64x64 → 裁剪到 14x14
- **主体描述**：A small purple bat with spread wings, flying pose, top-down view
- **配色指引**：主色 #AB47BC 紫色，辅色 #7B1FA2 深紫
- **完整 Prompt**：`pixel art, 16-bit, top-down view, game sprite, transparent background, no outline, a purple bat with spread wings, flying pose, small and fast-looking, simple design --ar 1:1`
- **备注**：ColorRect 回退 Color(0.67, 0.28, 0.74)，14px

---

### 骷髅 Skeleton (skeleton)
- **用途**：敌人精灵（远程，单发射击）
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：64x64 → 裁剪到 14x14
- **主体描述**：A white skeleton holding a bone staff, standing pose, top-down view
- **配色指引**：主色 #E0E0E0 白色，辅色 #9E9E9E 灰色
- **完整 Prompt**：`pixel art, 16-bit, top-down view, game sprite, transparent background, no outline, a white skeleton holding a bone staff, standing upright, bony features visible, simple design --ar 1:1`
- **备注**：ColorRect 回退 Color(0.88, 0.88, 0.88)，14px

---

### 精英骷髅 Elite Skeleton (elite_skeleton)
- **用途**：敌人精灵（远程，3方向射击）
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：64x64 → 裁剪到 18x18
- **主体描述**：A dark red elite skeleton with glowing eyes, holding dual bone wands, menacing pose, top-down view
- **配色指引**：主色 #B71C1C 深红，辅色 #880E4F 暗红
- **完整 Prompt**：`pixel art, 16-bit, top-down view, game sprite, transparent background, no outline, a dark red elite skeleton with glowing red eyes, dual bone wands, menacing pose, larger than normal skeleton, simple design --ar 1:1`
- **备注**：ColorRect 回退 Color(0.72, 0.11, 0.11)，18px

---

### 幽灵 Ghost (ghost)
- **用途**：敌人精灵（相位转移，瞬移）
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：64x64 → 裁剪到 12x12
- **主体描述**：A translucent grey-white ghost, wispy tail, semi-transparent, floating pose, top-down view
- **配色指引**：主色 #B0BEC5 灰白，辅色 #78909C 灰色
- **完整 Prompt**：`pixel art, 16-bit, top-down view, game sprite, transparent background, no outline, a translucent grey-white ghost, wispy ethereal tail, semi-transparent appearance, floating pose, simple design --ar 1:1`
- **备注**：ColorRect 回退 Color(0.69, 0.74, 0.77)，12px，需要支持 modulate.a 透明度变化

---

### 分裂者 Splitter (splitter)
- **用途**：敌人精灵（死亡分裂为2个小分裂者）
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：64x64 → 裁剪到 16x16
- **主体描述**：A teal-green blob creature with visible division lines on its body, suggesting it can split, top-down view
- **配色指引**：主色 #00897B 青绿，辅色 #004D40 深青
- **完整 Prompt**：`pixel art, 16-bit, top-down view, game sprite, transparent background, no outline, a teal-green blob creature with visible division lines, looks like it could split apart, organic shape, simple design --ar 1:1`
- **备注**：ColorRect 回退 Color(0, 0.54, 0.48)，16px

---

### 小分裂者 Splitter Small (splitter_small)
- **用途**：敌人精灵（分裂者死亡后生成）
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：32x32 → 裁剪到 8x8
- **主体描述**：A small light-teal blob, half the size of the parent splitter, top-down view
- **配色指引**：主色 #4DB6AC 浅青绿
- **完整 Prompt**：`pixel art, 16-bit, top-down view, game sprite, transparent background, no outline, a tiny light-teal blob creature, half size of parent, cute and round, simple design --ar 1:1`
- **备注**：ColorRect 回退 Color(0.3, 0.71, 0.67)，8px

---

### Boss (boss)
- **用途**：Boss 精灵（三阶段行为）
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：128x128 → 裁剪到 32x32
- **主体描述**：A large demonic red boss with horns, muscular arms, glowing yellow eyes, menacing aura, top-down view
- **配色指引**：主色 #F44336 红色，辅色 #B71C1C 深红，强调色 #FFD600 黄色眼睛
- **完整 Prompt**：`pixel art, 16-bit, top-down view, game sprite, transparent background, no outline, a large demonic red boss monster with horns, muscular build, glowing yellow eyes, menacing aura, twice the size of normal enemies, detailed pixel art --ar 1:1`
- **备注**：ColorRect 回退 Color(0.96, 0.26, 0.21)，32px。三阶段可能需要 3 个变体（正常/愤怒/暴走）

---

### 敌人弹幕 Enemy Bullet (enemy_bullet)
- **用途**：敌人射击弹幕精灵
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：16x16 → 裁剪到 4x4
- **主体描述**：A small glowing red orb projectile, trailing particles, top-down view
- **配色指引**：主色 #FF6B6B 亮红
- **完整 Prompt**：`pixel art, 16-bit, top-down view, game sprite, transparent background, no outline, a tiny glowing red orb projectile with small trail, simple and clean, simple design --ar 1:1`
- **备注**：ColorRect 回退 Color(0.9, 0.9, 0.9)，4px

---

### 火焰史莱姆 Fire Slime (fire_slime)
- **用途**：波次系统敌人变体精灵（Swarm 波次后出现）
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：128x128 -> 裁剪到 32x32
- **主体描述**：An orange-red slime creature with bright yellow flame wisps on top, amorphous blob body with rounded dome, white eyes with dark pupils, wavy bottom edge suggesting liquid movement, membrane texture lines on body, taller central flame core, more detailed at 32x32, top-down view
- **配色指引**：主色 #FF6622 橙红，辅色 #CC4411 暗橙阴影，强调色 #FFCC00 明黄火焰核心
- **负面提示词**：blurry, 3d, realistic, text, watermark, solid fire, ice, blue
- **完整 Prompt**：`pixel art, 16-bit, top-down view, game sprite, transparent background, dark outline #1A1A2E, an orange-red #FF6622 slime creature at 32x32 pixels with yellow #FFCC00 flame wisps burning on top, tall central flame core, amorphous blob body with rounded dome, white eyes, dark pupils, wavy liquid bottom, membrane texture lines, detailed for larger size, simple design --ar 1:1`
- **备注**：ColorRect 回退 Color(1.0, 0.4, 0.133) #FF6622 橙红 32px (R9 从 16px 升级至 32px)。与僵尸绿色史莱姆形成火焰/自然视觉对立。enemy_id 为 "fire_slime"。v2 更新：尺寸从 16x16 升级至 32x32，增加火焰细节、膜纹理线和更大的眼睛。

---

### 精英骑士 Elite Knight (elite_knight)
- **用途**：波次系统敌人变体精灵（Elite/Boss 波次出现）
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：128x128 -> 裁剪到 24x24
- **主体描述**：A tall dark purple armored knight with horned helmet, glowing purple eyes through visor slit, silver sword on right side, gold belt buckle and sword guard, floating purple aura particles around body, top-down view
- **配色指引**：主色 #442266 暗紫铠甲，辅色 #33154D 深紫细节，强调色 #8844BB 亮紫高光/眼睛
- **负面提示词**：blurry, 3d, realistic, text, watermark, red armor, blue armor, no weapon
- **完整 Prompt**：`pixel art, 16-bit, top-down view, game sprite, transparent background, dark outline #1A1A2E, a tall dark purple #442266 armored knight with horned helmet, glowing purple #8844BB eyes through visor, silver sword, gold accents on belt and sword guard, floating purple aura particles, menacing and elite-looking, larger than normal enemies at 24x24, simple design --ar 1:1`
- **备注**：ColorRect 回退 Color(0.267, 0.133, 0.4) #442266 暗紫 24px；紫系配色与蝙蝠(#AB47BD)区分--骑士为暗紫，蝙蝠为亮紫。24px 尺寸介于普通敌人(16px)和 Boss(32px)之间体现精英层级。enemy_id 为 "elite_knight"。
