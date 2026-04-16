# 武器Lv3质变特效 AI 绘图提示词

**Author**: Art Agent
**Date**: 2026-04-16
**Related Spec**: `docs/superpowers/specs/weapon-lv3-transforms.md`, `docs/team/art-log.md` R13

## 通用风格锁定词

```
pixel art, 16-bit, top-down view, game sprite, transparent background, crisp edges, no anti-aliasing, dark outline #1A1A2E, small effect particle
```

## 通用负面提示词

```
blurry, 3d, realistic, photorealistic, text, watermark, complex shading, anti-aliased, smooth gradients, photograph, high resolution, large sprite
```

---

### Knife Lv3 弹射火花 - Ricochet Spark (knife_ricochet)
- **用途**：弹射投射物特效精灵
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：64x64 -> 裁剪到 8x8
- **风格锁定词**：pixel art, 8-bit, game effect particle, star shape, golden, transparent background
- **主体描述**：A tiny 4-pointed star-shaped golden spark effect, cross-shaped body 2 pixels wide with four diagonal arms extending to corners, bright white center point, golden yellow fill, used to indicate a ricocheting knife projectile bounce, top-down view
- **配色指引**：主色 #FFE566 金色，辅色 #FFF4BB 浅金高光，强调色 #FFFFFF 白色核心
- **负面提示词**：blurry, 3d, realistic, text, watermark, blue, green, red, circle, ring
- **完整 Prompt**：`pixel art, 8-bit, tiny game effect particle, 8x8 pixels, 4-pointed golden star spark, #FFE566 golden yellow body with cross pattern, #FFF4BB light gold highlight on inner arms, #FFFFFF single white pixel center, dark outline #1A1A2E on star tips, transparent background, indicating a ricochet projectile bounce, extremely simple and small --ar 1:1`
- **备注**：ColorRect 回退 Color(1.0, 0.90, 0.40) #FFE566 8x8 方形；与 weapon-lv3-transforms.md 3.3 节 ricochet projectile Color(1.0, 0.9, 0.5) 金色色调对应。程序 Agent 在 projectile.gd _spawn_ricochet() 中可加载此精灵作为弹射投射物视觉。
- **动画帧描述** (4帧, 60fps):
  - Frame 1: 完整四角星形, alpha=255, 白色中心点亮
  - Frame 2: 外臂缩短1px, alpha=200, 中心扩展为2x2白
  - Frame 3: 仅剩十字形核心(2x2), alpha=120, 金色淡出
  - Frame 4: 1x1金色点, alpha=40, 消散
  - 总持续时间约 0.067s (快速闪现)
  - 动画模式: Sprite2D modulate alpha 衰减, 无需精灵表

---

### Frost Aura Lv3 碎裂波纹 - Shatter Wave (frost_shatter)
- **用途**：冰冻敌人死亡碎裂AOE特效精灵
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：128x128 -> 裁剪到 16x16
- **风格锁定词**：pixel art, 16-bit, game effect, ice blue ring, expanding wave, transparent background
- **主体描述**：An ice blue circular shatter wave effect, outer ring at radius 6 pixels with ice blue fill, inner lighter ring, 4 white crack lines radiating from center outward in cardinal directions, 2x2 white flash at center, representing an enemy shattering on death while frozen, top-down view
- **配色指引**：主色 #88DDFF 冰蓝，辅色 #CCEEFF 浅冰边缘，强调色 #FFFFFF 白色碎裂线
- **负面提示词**：blurry, 3d, realistic, text, watermark, red, green, yellow, fire, solid circle
- **完整 Prompt**：`pixel art, 16-bit, game effect sprite, 16x16 pixels, ice blue circular shatter wave, #88DDFF ice blue outer ring at radius 6, #CCEEFF lighter inner ring, 4 white #FFFFFF crack lines radiating from center, 2x2 white flash core at center, dark outline #1A1A2E on outer ring edges, transparent background, frozen enemy shattering on death AOE effect --ar 1:1`
- **备注**：ColorRect 回退 Color(0.53, 0.87, 1.0) #88DDFF 16x16 圆形；与 weapon-lv3-transforms.md 4.3 节 _spawn_shatter_effect() 的 Color(0.5, 0.8, 1.0) 匹配。50px 碎裂半径的视觉反馈精灵。
- **动画帧描述** (6帧, 30fps):
  - Frame 1: 中心2x2白色闪光, 无外环 (初始爆炸)
  - Frame 2: 外环出现 r=2, 冰蓝填充, 白色碎裂线开始延伸
  - Frame 3: 外环扩展 r=4, 碎裂线到达外环, alpha=230
  - Frame 4: 外环扩展 r=6 (完整), 冰蓝变浅, alpha=180
  - Frame 5: 外环开始碎裂(像素随机偏移), alpha=100
  - Frame 6: 残余冰蓝碎片消散, alpha=30
  - 总持续时间约 0.2s, scale 从 0.2x 缩放到 1.0x (匹配50px碎裂半径)
  - 动画模式: Sprite2D scale + modulate alpha 衰减

---

### Boomerang Lv3 追踪尾迹 - Homing Trail (boomerang_homing_trail)
- **用途**：回旋镖Lv3增强追踪的尾迹粒子精灵
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：64x64 -> 裁剪到 8x8
- **风格锁定词**：pixel art, 8-bit, game effect particle, green glowing dot, transparent background
- **主体描述**：A small green glowing trail dot with semi-transparent halo, 3x3 solid green core in center, surrounded by lighter green semi-transparent glow ring at alpha 80, indicating the enhanced homing trail of a boomerang tracking enemies, top-down view
- **配色指引**：主色 #44BB55 绿色核心，辅色 #88DD88 浅绿光晕(alpha=80)，强调色 #1A1A2E 暗描边
- **负面提示词**：blurry, 3d, realistic, text, watermark, blue, red, yellow, large, solid block
- **完整 Prompt**：`pixel art, 8-bit, tiny game effect particle, 8x8 pixels, green glowing trail dot, #44BB55 solid green 3x3 core at center, #88DD88 semi-transparent green halo ring around core, dark outline #1A1A2E on core edge, transparent background, indicating boomerang enhanced homing trail particle --ar 1:1`
- **备注**：ColorRect 回退 Color(0.27, 0.73, 0.33) #44BB55 8x8 方形；绿色系与 boomerang 基础色(棕色 #996633)明确区分。追踪增强是纯数值变化(1.5x track_angle)，此精灵为可选视觉增强。
- **动画帧描述** (持续型粒子, 非一次性):
  - 生成: 每 0.05s 在回旋镖飞行路径上生成一个尾迹粒子
  - 粒子生命周期: 0.3s
  - alpha 衰减: 255 -> 0, 线性
  - 缩放: 1.0x -> 0.3x, 尾部逐渐缩小
  - 颜色: 从 #44BB55 (绿) 向 #88DD88 (浅绿) 渐变
  - 动画模式: 每个粒子独立的 Sprite2D, alpha+scale 衰减

---

### Lightning Lv3 连锁闪电 - Chain Lightning (lightning_chain_kill)
- **用途**：击杀时连锁闪电特效精灵
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：96x96 -> 裁剪到 12x12
- **风格锁定词**：pixel art, 16-bit, game effect, yellow lightning bolt, zigzag shape, transparent background
- **主体描述**：A yellow zigzag lightning bolt symbol, diagonal line from upper-left going down-right, with a horizontal jog in the middle creating the classic lightning fork shape, bright yellow-white core pixels along the bolt center, 2 white-hot pixels at the horizontal jog, representing chain lightning triggered on enemy kill, top-down view
- **配色指引**：主色 #FFDD33 黄色闪电体，辅色 #FFFFAA 亮黄白芯，强调色 #FFFFFF 白热中心
- **负面提示词**：blurry, 3d, realistic, text, watermark, blue, red, green, circle, ring, smooth
- **完整 Prompt**：`pixel art, 16-bit, game effect sprite, 12x12 pixels, yellow zigzag lightning bolt, #FFDD33 golden yellow bolt body with diagonal-to-horizontal-to-diagonal shape, #FFFFAA bright yellow-white core pixels along center, #FFFFFF 2 white-hot pixels at jog point, dark outline #1A1A2E around bolt, transparent background, chain lightning on kill effect, angular and sharp --ar 1:1`
- **备注**：ColorRect 回退 Color(1.0, 0.87, 0.20) #FFDD33 12x12 对角线条；weapon-lv3-transforms.md 6.2 节定义 LIGHTNING_LV3_COK_RANGE=200px, LIGHTNING_LV3_COK_DAMAGE_MUL=0.5。此精灵为连锁击杀 bonus bolt 的视觉标识。
- **动画帧描述** (5帧, 40fps):
  - Frame 1: 闪电符号出现, 缩放 0.5x, alpha=255, 中心白热点亮
  - Frame 2: 缩放跳至 1.2x (弹性扩展), alpha=255, 黄色闪烁加强
  - Frame 3: 缩放回 1.0x, alpha=220, 核心黄色略淡
  - Frame 4: 闪电线条开始抖动(随机1px偏移), alpha=120
  - Frame 5: 闪电线段断裂为碎片, alpha=30, 消散
  - 总持续时间约 0.125s (极快速闪电效果)
  - 动画模式: Sprite2D scale 弹性 + modulate alpha 衰减 + 位置微抖

---

### Bible Lv3 扩展光环 - Expanding Aura (bible_expand)
- **用途**：圣经Lv3周期性脉冲伤害光环特效精灵
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：128x128 -> 裁剪到 16x16
- **风格锁定词**：pixel art, 16-bit, game effect, golden expanding ring, concentric circles, transparent background
- **主体描述**：A golden concentric ring effect representing expanding aura pulse, outer golden ring at radius 6 pixels with solid fill, inner lighter gold ring at radius 3 pixels, 2x2 white pulsing core at center, representing the periodic damage pulse from Bible weapon at Lv3, top-down view
- **配色指引**：主色 #FFD700 金色外环，辅色 #FFEE88 浅金内环，强调色 #FFFFFF 白色脉冲核心
- **负面提示词**：blurry, 3d, realistic, text, watermark, blue, red, green, solid disc, flat
- **完整 Prompt**：`pixel art, 16-bit, game effect sprite, 16x16 pixels, golden expanding aura pulse ring, #FFD700 golden outer ring at radius 6, #FFEE88 lighter gold inner ring at radius 3, #FFFFFF 2x2 white pulsing core at center, dark outline #1A1A2E on outer ring, transparent background, periodic damage pulse expanding aura effect --ar 1:1`
- **备注**：ColorRect 回退 Color(1.0, 0.84, 0.0) #FFD700 16x16 空心圆；weapon-lv3-transforms.md 6.2 节定义 BIBLE_LV3_PULSE_RADIUS=60px, BIBLE_LV3_PULSE_INTERVAL=2.0s。此精灵为每次2秒脉冲的视觉反馈。
- **动画帧描述** (8帧, 40fps, 循环):
  - Frame 1: 外环 r=2, 金色描边, 无内环, 中心白色2x2
  - Frame 2: 外环 r=3, 内环出现 r=1, alpha=240
  - Frame 3: 外环 r=4, 内环 r=2, alpha=220
  - Frame 4: 外环 r=5, 内环 r=3, alpha=200 (接近满尺寸)
  - Frame 5: 外环 r=6 (完整), 内环 r=3, alpha=180
  - Frame 6: 外环 r=6, 填充开始淡出, alpha=120
  - Frame 7: 外环 r=6, 仅剩描边轮廓, alpha=60
  - Frame 8: 完全消散, alpha=0
  - 总持续时间约 0.2s, scale 从 0.3x 缩放到 1.0x (匹配60px脉冲半径)
  - 每2秒触发一次循环
  - 动画模式: Sprite2D scale 扩展 + modulate alpha 衰减

---

### Holy Water Lv3 冰霜粒子 - Frost Blessing (holywater_frost)
- **用途**：圣水Lv3冰霜祝福附加冻结效果粒子
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：64x64 -> 裁剪到 8x8
- **风格锁定词**：pixel art, 8-bit, game effect particle, ice crystal, diamond shape, transparent background
- **主体描述**：A tiny blue-white diamond-shaped ice crystal particle with cross-shaped arms extending in 4 cardinal directions from the diamond body, lighter blue-white fill suggesting frost blessing, white center highlight, representing the frost blessing effect when Holy Water freezes enemies at Lv3, top-down view
- **配色指引**：主色 #BBDDFF 蓝白冰晶，辅色 #EEEEFF 白冰高光，强调色 #FFFFFF 白色火花
- **负面提示词**：blurry, 3d, realistic, text, watermark, red, yellow, green, warm, fire
- **完整 Prompt**：`pixel art, 8-bit, tiny game effect particle, 8x8 pixels, blue-white diamond ice crystal, #BBDDFF ice blue diamond body, #EEEEFF lighter frost cross arms extending in 4 directions, #FFFFFF white center highlight dot, dark outline #1A1A2E on diamond edges, transparent background, frost blessing ice particle effect --ar 1:1`
- **备注**：ColorRect 回退 Color(0.73, 0.87, 1.0) #BBDDFF 8x8 菱形；weapon-lv3-transforms.md 6.2 节定义 HOLYWATER_LV3_FREEZE_CHANCE=0.15, HOLYWATER_LV3_FREEZE_DURATION=0.5s。此精灵为圣水冻结触发时的视觉标识。
- **动画帧描述** (3帧, 50fps):
  - Frame 1: 完整菱形冰晶 + 四向十字臂, alpha=255, 白色中心亮
  - Frame 2: 十字臂缩短1px, 菱形主体不变, alpha=150
  - Frame 3: 仅剩菱形核心(2x2), alpha=50, 消散
  - 总持续时间约 0.06s (极快速冰晶闪现)
  - 冻结持续 0.5s 期间此精灵循环显示 (每 0.1s 刷新)
  - 动画模式: Sprite2D modulate alpha 衰减, 循环

---

### Fire Staff Lv3 爆炸圈 - Searing Flames (firestaff_explode)
- **用途**：火焰法杖Lv3燃烧区域爆炸特效精灵
- **目标工具**：Stable Diffusion / Midjourney
- **尺寸规格**：128x128 -> 裁剪到 16x16
- **风格锁定词**：pixel art, 16-bit, game effect, red-orange explosion ring, fire, transparent background
- **主体描述**：A red-orange circular explosion ring effect, outer ring at radius 6 with red-orange fill, inner bright orange fill, 2x2 golden center flash representing the detonation point, 4 dark scorch mark pixels at cardinal directions on outer edge suggesting lingering burn damage, representing Fire Staff Lv3 burn zone explosion, top-down view
- **配色指引**：主色 #FF4500 红橙外环，辅色 #FF8844 亮橙内环，强调色 #FFD700 金色闪光核心
- **负面提示词**：blurry, 3d, realistic, text, watermark, blue, green, ice, cold, smooth circle
- **完整 Prompt**：`pixel art, 16-bit, game effect sprite, 16x16 pixels, red-orange explosion ring, #FF4500 red-orange outer ring at radius 6, #FF8844 bright orange inner fill, #FFD700 2x2 golden flash at center detonation, #1A1A2E 4 dark scorch marks at cardinal edges, dark outline on outer ring, transparent background, fire staff burn zone explosion effect --ar 1:1`
- **备注**：ColorRect 回退 Color(1.0, 0.27, 0.0) #FF4500 16x16 圆形；weapon-lv3-transforms.md 6.2 节定义 FIRESTAFF_LV3_ZONE_RADIUS=40px, FIRESTAFF_LV3_ZONE_DPS=1.0, FIRESTAFF_LV3_ZONE_DURATION=2.0s。此精灵为燃烧区域生成时的爆炸视觉反馈。
- **动画帧描述** (6帧, 30fps):
  - Frame 1: 中心2x2金色闪光, 缩放 0.2x (初始爆炸)
  - Frame 2: 外环出现 r=2, 红橙填充, 中心金色扩展为4x4, 缩放 0.5x, alpha=255
  - Frame 3: 外环扩展 r=4, 亮橙内环出现, 缩放 0.8x, alpha=230
  - Frame 4: 外环扩展 r=6 (完整), 焦痕标记可见, 缩放 1.0x, alpha=200
  - Frame 5: 外环保持, 内部填充变深(橙色->暗红), alpha=100
  - Frame 6: 外环碎裂, 火焰碎片散落, alpha=30, 消散
  - 总持续时间约 0.2s, scale 从 0.2x 缩放到 1.0x (匹配45px爆炸半径)
  - 动画模式: Sprite2D scale 扩展 + modulate alpha 衰减
