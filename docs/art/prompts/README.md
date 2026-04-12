# AI 绘图提示词目录

本目录管理所有用于外部文生图工具的提示词，按资产类型分文件。

## 文件清单

| 文件 | 内容 | 目标工具 |
|------|------|----------|
| `character_prompts.md` | 角色立绘/头像 | Midjourney / SD |
| `enemy_prompts.md` | 敌人精灵 | Midjourney / SD |
| `weapon_prompts.md` | 武器图标/特效 | Midjourney / SD |
| `ui_prompts.md` | UI 按钮/面板/图标 | Midjourney / SD |
| `scene_prompts.md` | 场景背景/地面/装饰 | Midjourney / SD |
| `effect_prompts.md` | 粒子/光效/动画帧 | Midjourney / SD |

## 使用流程

1. 美术 Agent 编写提示词 → 对应文件
2. 用户在外部文生图工具执行生成
3. 生成图片放入 `assets/sprites/` 对应目录
4. 美术 Agent 更新 `art-log.md` 记录
5. 程序 Agent 替换 ColorRect 为 Sprite2D

## 风格锁定

所有提示词统一使用以下风格前缀：
```
pixel art, 16-bit, top-down view, game sprite, transparent background, no outline
```

## 色值映射

提示词中的配色必须与 `docs/team/art-log.md` 配色表中的 Color 值对应。
