# Phase 5 设计规格：17 种协同效应

## 设计概述

检测玩家当前的武器和被动组合，当匹配特定配方时实时激活协同效果。17 种协同分为被动+被动（6种）和武器+被动（11种，含 H5 实际的 11 种）两类。

## 被动+被动协同（6种）

| ID | 名称 | 配方 | 效果 |
|----|------|------|------|
| crit_boots | 风之锋刃 | crit + speedboots | 暴击时发射飞刀（0.5x伤害，速度250，存活1s） |
| armor_maxhp | 铁壁之心 | armor + maxhp | 护甲效果翻倍 |
| magnet_crit | 贪婪之魂 | magnet + crit | 暴击额外掉落宝石（+2 XP值） |
| boots_regen | 生命奔流 | speedboots + regen | 移动时再生速度×2 |
| armor_regen | 钢铁堡垒 | armor + regen | 低HP（≤30%）时临时+3护甲 |
| magnet_maxhp | 命运齿轮 | magnet + maxhp | 拾取宝石 2% 概率回复 1 HP |

## 武器+被动协同（11种）

| ID | 名称 | 配方 | 效果 |
|----|------|------|------|
| holywater_maxhp | 圣水膨胀 | holywater + maxhp | 圣水半径×1.3 |
| knife_crit | 致命飞刀 | knife + crit | 飞刀可暴击 |
| lightning_magnet | 过载闪电 | lightning + magnet | 闪电+1链，范围+50 |
| bible_boots | 烈焰圣经 | bible + speedboots | 圣经速度×1.5，半径+20 |
| firestaff_armor | 熔岩法杖 | firestaff + armor | 锥形角度+40°，燃烧持续+1s |
| frost_regen | 极寒光环 | frostaura + regen | 冰冻概率+5%，冰冻持续+0.5s |
| holywater_luckycoin | 圣水炼金 | holywater + luckycoin | 圣水击杀额外+1金币 |
| firestaff_luckycoin | 炼金烈焰 | firestaff + luckycoin | 燃烧击杀额外+1宝石 |
| frostaura_luckycoin | 冰霜拾荒 | frostaura + luckycoin | 冰冻敌人掉落宝石吸引+30px |
| boomerang_magnet | 磁力回旋 | boomerang + magnet | 回旋镖飞行时吸引宝石30px |
| boomerang_crit | 致命回旋 | boomerang + crit | 回旋镖可暴击，暴击尺寸×1.2，暴击穿透+1 |

## 系统机制

### 协同检测
- 每次获得/失去被动时，重新计算活跃协同列表
- 检测条件：`has_passive(a) and has_passive(b)` 或 `has_weapon(a) and has_passive(b)`
- 协同 ID 存入 `active_synergies: Dictionary`

### 效果应用
- **属性加成型**（铁壁之心、圣水膨胀等）：在 weapon_controller/player 中读取协同状态调整数值
- **触发型**（风之锋刃、贪婪之魂等）：在暴击/击杀时检查协同状态触发额外效果
- **行为改变型**（致命飞刀可暴击等）：在武器逻辑中检查协同状态切换行为

### 数据结构
```
synergy_manager.gd (autoload):
  - SYNERGY_DEFINITIONS: Array[Dictionary]
  - active_synergies: Dictionary  # synergy_id -> true
  - check_synergies(owned_weapons, owned_passives) -> void
  - has_synergy(synergy_id) -> bool
```

## 决策记录
- **为什么复用 H5 协同**：17 种协同经过充分验证，覆盖了属性加成/触发/行为改变三类
- **为什么用 autoload 而非组件**：协同效果需要跨多个系统（武器/玩家/弹幕）访问，全局单例最简单
- **数值来源**：全部来自 H5 config.js SYNERGIES
