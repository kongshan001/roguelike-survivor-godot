# 美术资产生产管线

针对 Survivor Arena 项目的免费像素风美术资产生产方案，从 ColorRect 占位到完整替换的完整流程。

---

## 一、工具链总览

| 阶段 | 工具 | 费用 | 用途 |
|------|------|------|------|
| 像素绘制 | [Pixelorama](https://github.com/Orama-Interactive/Pixelorama) | 免费/开源 | 主力像素编辑器，支持动画帧、图层、精灵表 |
| 像素绘制(备选) | [Piskel](https://www.piskelapp.com/) | 免费/浏览器 | 快速草图、简单动画 |
| AI 生成 | [ComfyUI](https://github.com/comfyanonymous/ComfyUI) + Stable Diffusion | 免费/开源 | 批量生成概念图、配色变体 |
| AI 后处理 | Pixelization 插件 (ComfyUI) | 免费 | AI 图→像素风转换 |
| 图像处理 | [GIMP](https://www.gimp.org/) | 免费/开源 | 批量裁剪、调色板量化、去背景 |
| 精灵表打包 | [TexturePacker](https://www.codeandweb.com/texturepacker) (免费版) / [LibreSprite](https://github.com/LibreSprite/LibreSprite) | 免费 | 精灵表打包、Godot 导出 |
| 图标/UI | [Inkscape](https://inkscape.org/) | 免费/开源 | 矢量图标，导出 PNG |

### 一键安装（推荐）

```bash
# macOS
brew install --cask pixelorama gimp inkscape

# ComfyUI (需要 Python 3.10+)
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI
pip install -r requirements.txt
```

---

## 二、资产清单与规格

根据项目当前配色表（art-log.md），需要生产的资产清单：

### 2.1 角色精灵 (16×16, 4方向行走动画)

| 资产 | 帧数 | 主色 | 辅色 | 备注 |
|------|------|------|------|------|
| 法师 (idle/walk×4dir) | 3帧×4方向 | 深蓝 #1A247C | 蓝袍 #1466BF | 顶部视角，带帽子 |
| 战士 (idle/walk×4dir) | 3帧×4方向 | 深红 #B81C1C | 红甲 #D42E2E | 顶部视角，带盾 |
| 游侠 (idle/walk×4dir) | 3帧×4方向 | 深绿 #1C5E21 | 绿衣 #2E7333 | 顶部视角，带弓 |
| Dash 残影 | 1帧 | 角色主色 alpha=0.3 | — | 半透明复用角色精灵 |

### 2.2 敌人精灵

| 资产 | 尺寸 | 主色 | 帧数 | 备注 |
|------|------|------|------|------|
| 僵尸 | 16×16 | #4DB04F | 2帧行走 | 缓慢摇摆 |
| 蝙蝠 | 14×14 | #AB47BD | 2帧飞翼 | 快速扇动 |
| 骷髅 | 14×14 | #E0E0E0 | 2帧行走 | 持弓/杖 |
| 精英骷髅 | 18×18 | #B81C1C | 2帧行走 | 比骷髅大，红色 |
| 幽灵 | 12×12 | #B0BDC3 | 2帧飘浮 | 半透明(alpha 0.7) |
| 分裂者 | 16×16 | #008A7A | 2帧行走 | 青色皮肤 |
| 小分裂者 | 10×10 | #008A7A | 2帧行走 | 分裂者的缩小版 |
| Boss | 32×32 | #F54236 | 4帧(3阶段) | 每阶段外观微变 |

### 2.3 武器精灵

| 资产 | 尺寸 | 颜色 | 备注 |
|------|------|------|------|
| 圣水球 | 8×8 | #4D80FF | 环绕旋转 |
| 飞刀 | 6×6 | #C0C0CC | 方向感 |
| 闪电 | 动态 | #FFFF4D | Line2D 锯齿形 |
| 圣经 | 10×10 | #E6D9B3 | 翻转页 |
| 火焰锥 | 动态 | #FF6619 | 扇形区域 |
| 冰冻光环 | 动态 | #80CCFF | 半透明圆环 |
| 回旋镖 | 8×8 | #996633 | 旋转帧×4 |
| 暴击飞刀 | 4×4 | #FFD900 | 金色小刀 |

### 2.4 拾取物

| 资产 | 尺寸 | 颜色 | 备注 |
|------|------|------|------|
| XP 宝石(小) | 8×8 | 黄 #FFFF00 | xp < 10 |
| XP 宝石(中) | 10×10 | 绿 #00FF00 | 10 ≤ xp < 15 |
| XP 宝石(大) | 12×12 | 蓝 #3366FF | xp ≥ 15 |
| 食物 | 8×8 | 嫩绿 #66E64D | 治愈 |
| 箱子 | 12×12 | 棕 #8B6914 | 随机奖励 |
| 金币 | 6×6 | 金 #FFD700 | 掉落货币 |

### 2.5 UI 元素

| 资产 | 尺寸 | 备注 |
|------|------|------|
| HP 条 | 200×8 | 红→绿渐变 |
| XP 条 | 200×6 | 蓝渐变 |
| 升级面板背景 | 400×300 | 半透明暗色 |
| 被动道具图标(7个) | 16×16 | 各自配色 |
| Boss 警告横幅 | 全宽×40 | 深红底白字 |

---

## 三、生产管线流程

### 路线 A：纯手工（零 AI，完全免费）

```
Pixelorama 绘制 → GIMP 调色板量化 → 导出 PNG → Godot 替换 ColorRect
```

**适用**：角色、敌人等核心资产（需要精确控制）

**步骤**：
1. Pixelorama 中创建 16×16 画布，设置调色板为项目配色表
2. 绘制 idle 帧 + 3 帧行走动画 × 4 方向 = 16 帧
3. 导出为精灵表 PNG（水平排列）
4. GIMP 中 Image → Mode → Indexed → 使用自定义调色板（确保像素纯净）
5. 导出最终 PNG 到 `assets/sprites/`

### 路线 B：AI 辅助（免费，推荐）

```
ComfyUI 生成概念图 → 像素化处理 → Pixelorama 精修 → Godot 替换
```

**适用**：大量相似资产（宝物、图标、背景装饰）

#### ComfyUI 像素风工作流

1. **安装 ComfyUI**：
   ```bash
   git clone https://github.com/comfyanonymous/ComfyUI.git
   cd ComfyUI && pip install -r requirements.txt
   ```

2. **安装像素化插件**：
   ```bash
   cd ComfyUI/custom_nodes
   git clone https://github.com/WASasquatch/comfyui-plugins.git  # WAS Node Suite
   ```

3. **下载像素风模型**（推荐免费模型）：
   - 基础模型：Stable Diffusion XL（[Civitai](https://civitai.com/) 免费下载）
   - 像素风 LoRA：搜索 "pixel art game sprite" on Civitai

4. **Prompt 模板**（适配本项目）：
   ```
   pixel art, 16x16, top-down view, game sprite, transparent background,
   [主体描述], [配色], simple shading, 4 colors maximum,
   no outline, flat colors, retro 16-bit style
   Negative: blurry, 3d, realistic, text, watermark, gradient, anti-aliased
   ```

5. **生成参数**：
   - 尺寸：384×384 → 后处理缩小到 16×16
   - Steps: 20-30, CFG: 7-9
   - Sampler: euler_ancestral

6. **后处理链**（ComfyUI 节点）：
   ```
   生成图像 → Resize 2.5x → Upscale → Pixelization → Export PNG
   ```

7. **精修**：在 Pixelorama 中打开像素化结果，手动调整到精确 16×16

### 路线 C：快速原型（最快）

```
Piskel 在线绘制 → 直接导出 → Godot 替换
```

**适用**：快速验证、原型测试

---

## 四、Godot 资产替换规范

### 4.1 目录结构

```
assets/
├── sprites/
│   ├── characters/          # 角色
│   │   ├── mage.png         # 精灵表
│   │   ├── warrior.png
│   │   └── ranger.png
│   ├── enemies/             # 敌人
│   │   ├── zombie.png
│   │   ├── bat.png
│   │   └── ...
│   ├── weapons/             # 武器投射物
│   ├── pickups/             # 拾取物
│   └── ui/                  # UI 图标
└── audio/                   # 音效（未来）
```

### 4.2 ColorRect → Sprite2D 替换模式

当前所有视觉使用 ColorRect 占位。替换为 Sprite2D 的方式：

```gdscript
# 之前 (ColorRect)
var sprite = ColorRect.new()
sprite.color = Color(0.3, 0.69, 0.31)
sprite.size = Vector2(16, 16)

# 之后 (Sprite2D)
var sprite = Sprite2D.new()
sprite.texture = load("res://assets/sprites/enemies/zombie.png")
sprite.hframes = 2  # 精灵表帧数
```

### 4.3 替换优先级

| 优先级 | 资产 | 原因 |
|--------|------|------|
| P0 | 角色(3) | 玩家最常看到 |
| P1 | 敌人(7) | 视觉区分度最重要 |
| P2 | 武器投射物(7) | 战斗反馈 |
| P3 | 拾取物(6) | 奖励感 |
| P4 | UI 图标(14) | 信息传达 |
| P5 | 背景装饰 | 氛围 |

---

## 五、调色板文件

### Godot 调色板（用于 Pixelorama 导入）

```
# Survivor Arena Palette (14色)
# 格式：R,G,B = 颜色名
10,20,121 = 深蓝(Mage主)
8,102,191 = 蓝袍(Mage辅)
184,28,28 = 深红(Warrior主/Boss)
212,46,46 = 红甲(Warrior辅)
28,94,33 = 深绿(Ranger主)
46,115,51 = 绿衣(Ranger辅)
77,176,79 = 僵尸绿
171,71,189 = 蝙蝠紫
224,224,224 = 骷髅白
176,189,195 = 幽灵灰
0,138,122 = 分裂者青
245,66,54 = Boss红
255,217,0 = 金色(金币/暴击)
128,204,255 = 冰蓝(冰冻)
```

---

## 六、自动化脚本

### 批量 PNG → Godot 资源

```bash
#!/bin/bash
# tools/import_sprites.sh
# 将 assets/sprites/ 下的 PNG 复制到 Godot 可识别的位置
# 并生成 .import 文件

for sprite in assets/sprites/**/*.png; do
    godot --headless --import "$sprite" 2>/dev/null
done
echo "Sprites imported."
```

### ComfyUI 批量生成

```
# ComfyUI API 调用示例（需 ComfyUI 运行在 localhost:8188）
# 使用 tools/comfyui_batch.py 脚本
# 读取 docs/art/prompts/ 下的提示词
# 批量生成到 assets/sprites/
```

---

## 七、推荐工作节奏

| 阶段 | 时间 | 产出 |
|------|------|------|
| 第 1 天 | 2h | Pixelorama 设置 + 调色板 + 法师精灵 |
| 第 2 天 | 2h | 战士 + 游侠精灵 |
| 第 3 天 | 2h | 7 种敌人精灵 |
| 第 4 天 | 1h | 武器投射物 + 拾取物 |
| 第 5 天 | 1h | UI 图标 + 背景装饰 |
| 第 6 天 | 1h | 集成到 Godot + 测试 |

**总计约 9 小时**，完成从 ColorRect 到完整像素精灵的替换。

---

## 参考资源

- [Pixelorama](https://github.com/Orama-Interactive/Pixelorama) — 开源像素编辑器
- [Piskel](https://www.piskelapp.com/) — 在线像素编辑器
- [ComfyUI](https://github.com/comfyanonymous/ComfyUI) — 开源 AI 图像生成
- [The Pixel Art ComfyUI Workflow Guide](https://inzaniak.github.io/blog/articles/the-pixel-art-comfyui-workflow-guide.html) — 像素风 ComfyUI 详细教程
- [Civitai](https://civitai.com/) — 免费 SDXL 模型和 LoRA 下载
- [GIMP](https://www.gimp.org/) — 开源图像处理
- [LibreSprite](https://github.com/LibreSprite/LibreSprite) — Aseprite 开源分支
- [12 Best Pixel Art Generators in 2026](https://www.sprite-ai.art/blog/best-pixel-art-generators-2026) — 工具对比
