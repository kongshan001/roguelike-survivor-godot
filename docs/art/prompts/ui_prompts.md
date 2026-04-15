# UI 元素 AI 绘图提示词

## 通用风格锁定词

```
pixel art, 16-bit, top-down view, game UI element, transparent background, crisp edges, simple design
```

## 通用负面提示词

```
blurry, 3d, realistic, photorealistic, text, watermark, complex shading, anti-aliased, smooth gradients, photograph
```

---

### 波次进度条背景 Wave Progress Bar (wave_progress)
- **用途**：HUD 波次进度条轨道背景
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：128x8 像素，直接使用
- **风格锁定词**：pixel art, 16-bit, game UI, horizontal bar, dark background, transparent background
- **主体描述**：A horizontal progress bar track, 128 pixels wide and 8 pixels tall, dark indigo background with subtle center highlight stripe, clean pixel-perfect edges, minimal and functional design
- **配色指引**：主色 #1A1A2E 暗蓝紫，辅色 #2A2A3E 中间亮条
- **负面提示词**：blurry, 3d, realistic, text, watermark, gradient, glow
- **完整 Prompt**：`pixel art, 16-bit, game UI, horizontal progress bar track, 128x8 pixels, dark indigo #1A1A2E background, subtle lighter center stripe #2A2A3E, clean pixel edges, minimal design, transparent background --ar 16:1`
- **备注**：ColorRect 回退 Color(0.102, 0.102, 0.18) #1A1A2E 全暗条；程序 Agent 可用 ColorRect 直接替代此资产

---

### 波次标记点 Wave Marker (wave_marker)
- **用途**：HUD 波次进度条上的波次位置标记点
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：64x64 -> 裁剪到 8x8
- **风格锁定词**：pixel art, 16-bit, game UI, diamond shape, golden marker, transparent background
- **主体描述**：A small golden diamond-shaped marker dot, 8x8 pixels, with a bright white highlight sparkle in the upper portion, used as a wave position indicator on a progress bar
- **配色指引**：主色 #FFD700 金色，辅色 #FFFFFF 白色高光，描边 #1A1A2E 暗蓝紫
- **负面提示词**：blurry, 3d, realistic, text, watermark, circle, square
- **完整 Prompt**：`pixel art, 16-bit, game UI, small golden diamond marker, 8x8 pixels, #FFD700 gold color with white sparkle highlight, dark outline, transparent background, crisp pixel edges --ar 1:1`
- **备注**：ColorRect 回退 Color(1.0, 0.843, 0.0) #FFD700 金色 4x4 方块；菱形比圆形更适合进度条标记

---

### Boss 警告图标 Boss Warning (boss_warning)
- **用途**：HUD Boss 波次警告图标
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：128x128 -> 裁剪到 24x24
- **风格锁定词**：pixel art, 16-bit, game UI, skull icon, red glow, warning symbol, transparent background
- **主体描述**：A pixel art skull icon, 24x24 pixels, bone white skull with dark eye sockets containing glowing red pupils, visible teeth row, menacing expression, dark outline, used as Boss wave warning indicator
- **配色指引**：主色 #E0E0E0 骨白，辅色 #CC1010 深红眼睛，强调色 #800808 眼窝暗影，描边 #1A1A2E 暗蓝紫
- **负面提示词**：blurry, 3d, realistic, text, watermark, cute, cartoon, color outside skull
- **完整 Prompt**：`pixel art, 16-bit, game UI, skull icon warning symbol, 24x24 pixels, bone white #E0E0E0 skull, dark eye sockets with glowing red #CC1010 pupils, visible teeth, menacing expression, dark outline #1A1A2E, transparent background --ar 1:1`
- **备注**：ColorRect 回退 Color(0.8, 0.063, 0.063) #CC1010 红色方块；替代方案为 Boss 警告横幅中的骷髅 emoji 文字

---

## 视觉规范参考

### 波次进度条 HUD 布局

```
+-----+-----+-----+-----+-----+
| W1  | W2  | W3  | W4  | W5  |  <- wave_marker (gold diamond) at each position
+-----+-----+-----+-----+-----+
[========================================]  <- wave_progress (128x8 dark bar)
         ^-- filled portion grows with time
```

### 波次进度条颜色映射 (参考 stage-system.md)

| 波次 | 名称 | 进度条填充色 | 标记高亮 |
|------|------|-------------|---------|
| Wave 1 | Opening | #4CAF50 绿 | 金色标记 |
| Wave 2 | Swarm | #FFD700 黄 | 金色标记 |
| Wave 3 | Darkness | #FF8C00 橙 | 金色标记 |
| Wave 4 | Elite | #F44336 红 | 金色标记 |
| Wave 5 | Boss | #CC1010 深红 | Boss 警告图标 |
