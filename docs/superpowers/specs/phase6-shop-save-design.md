# Phase 6 设计规格：商店/存档/任务/成就

## 设计概述

实现跨局持久化系统：灵魂碎片作为永久货币，商店购买6种升级，14个任务+27个成就提供长期目标。使用 Godot ConfigFile 存储到用户数据目录。

## 灵魂碎片系统
- 30% 击杀掉落率，Boss 100% 掉落
- 灵魂碎片 = 金币 × 30% 转化（每局结束后自动转化）
- 用途：商店购买永久升级

## 商店升级（6种，各3级）

| ID | 名称 | 图标 | Lv1费用 | Lv2费用 | Lv3费用 | 效果 |
|----|------|------|---------|---------|---------|------|
| maxhp | 生命强化 | ❤️ | 20 | 40 | 80 | +1/+2/+3 HP |
| speed | 速度训练 | 👟 | 20 | 40 | 80 | +5%/+10%/+15% 速度 |
| pickup | 拾取精通 | 📡 | 15 | 30 | 60 | +5/+10/+15 拾取范围 |
| expbonus | 知识汲取 | 📚 | 25 | 50 | 100 | +5%/+10%/+15% 经验 |
| weapondmg | 武器精通 | ⚔️ | 30 | 60 | 120 | +3%/+6%/+10% 武器伤害 |
| gold | 贪婪之心 | 💰 | 15 | 30 | 60 | +10%/+20%/+30% 金币 |

## 任务系统（14个）

| ID | 名称 | 条件 | 奖励 |
|----|------|------|------|
| warrior_30 | 战士之道 | 战士击杀30 | 50 |
| ranger_30 | 箭无虚发 | 游侠击杀30 | 50 |
| hard_survive | 勇者无惧 | 噩梦存活2min | 100 |
| hard_boss | 噩梦征服者 | 噩梦杀Boss | 200 |
| kill_50 | 屠戮者 | 单局杀50 | 75 |
| kill_100 | 百人斩 | 单局杀100 | 150 |
| kill_boss | 屠龙者 | 击败Boss | 100 |
| no_damage | 完美闪避 | 不受伤1min | 120 |
| combo_20 | 连击大师 | 20连击 | 100 |
| combo_50 | 连击之王 | 50连击 | 200 |
| endless_5min | 无尽征途 | 无尽存活5min | 150 |
| endless_10min | 不朽传说 | 无尽存活10min | 300 |
| endless_boss3 | 连斩三龙 | 无尽杀3Boss | 400 |
| endless_kill200 | 无尽屠戮 | 无尽杀200 | 250 |

## 成就系统（27个，分类）

**里程碑(5)**：杀100/500/2000敌人，玩10/50局
**生存(3)**：标准3min/5min，噩梦5min
**角色(1)**：全角色通关
**击杀/挑战(8)**：杀Boss/噩梦Boss/连击30/50/无伤2min/单局100杀等
**进化/协同(4)**：首次进化/首次协同/全进化/全协同
**商店(3)**：首次购买/单项满级/全部满级
**任务(2)**：完成一半/完成全部
**隐藏(2)**：3分钟杀Boss/1分钟无杀

## 存档结构

使用 Godot ConfigFile，存储到 `user://save.cfg`：

```
[soul_fragments]
amount=0

[shop_upgrades]
maxhp=0
speed=0
pickup=0
expbonus=0
weapondmg=0
gold=0

[quests]
warrior_30=false
ranger_30=false
...

[achievements]
total_kills_100=false
...

[stats]
total_kills=0
games_played=0
endless_unlocked=false
```

## 数据结构

```
save_manager.gd (autoload):
  - soul_fragments: int
  - shop_upgrades: Dictionary  # id -> level (0-3)
  - completed_quests: Dictionary  # id -> bool
  - completed_achievements: Dictionary
  - total_kills: int
  - games_played: int
  - endless_unlocked: bool
  - save() / load() / reset()
```

## 决策记录
- **为什么用 ConfigFile**：Godot 原生支持，无需 JSON 解析，INI 格式简单可靠
- **为什么灵魂碎片=金币×30%**：H5 原设计，简单直接
- **为什么14任务而非全量**：H5 有14个，覆盖各角色/难度/模式
- **数值来源**：全部来自 H5 config.js SHOP/QUESTS/ACHIEVEMENTS/SAVE
