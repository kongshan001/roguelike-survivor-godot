# Phase 4 设计规格：8 种进化武器

## 设计概述

玩家同时持有两个 Lv3 基础武器时，升级选项中可出现对应的进化选项。选择后移除两个原始武器，替换为一个进化武器（不可再升级）。8 种进化配方直接参考 H5 EVOLUTIONS 配置。

## 进化配方表

| 进化武器 | 原料 A | 原料 B | 中文名 | 描述 |
|----------|--------|--------|--------|------|
| thunderholywater | holywater Lv3 | lightning Lv3 | 雷暴圣水 | 旋转+链式闪电 |
| fireknife | knife Lv3 | firestaff Lv3 | 火焰飞刀 | 燃烧穿透飞刀 |
| holydomain | bible Lv3 | holywater Lv3 | 圣光领域 | 超大范围+圣光脉冲 |
| blizzard | frostaura Lv3 | lightning Lv3 | 暴风雪 | 大范围暴风雪+闪电链 |
| frostknife | knife Lv3 | frostaura Lv3 | 冰霜飞刀 | 减速穿透飞刀 |
| flamebible | bible Lv3 | firestaff Lv3 | 烈焰经文 | 旋转灼烧+火焰脉冲 |
| thunderang | boomerang Lv3 | lightning Lv3 | 雷霆回旋 | 追踪+闪电链 |
| blazerang | boomerang Lv3 | firestaff Lv3 | 烈焰回旋 | 追踪+火焰轨迹 |

## 进化武器数值

### 雷暴圣水 (thunderholywater)
- 类型：orbit + lightning
- 球数=3, 半径=60, DPS=1.5
- 闪电伤害=6, 链=3, CD=2s

### 火焰飞刀 (fireknife)
- 类型：projectile + burn
- 数量=5, 伤害=3, 穿透=2, CD=0.5s
- 燃烧DPS=3, 持续=2s

### 圣光领域 (holydomain)
- 类型：orbit + pulse
- 半径=130, 球数=4, DPS=2.5
- 脉冲间隔=4s, 脉冲伤害=12, 脉冲半径=200

### 暴风雪 (blizzard)
- 类型：aura + lightning
- 半径=160, 减速=70%, DPS=3
- 冰冻概率=15%, 冰冻持续=2s
- 闪电CD=2s, 闪电伤害=8, 链=2

### 冰霜飞刀 (frostknife)
- 类型：projectile + slow
- 数量=5, 伤害=2.5, 穿透=2, CD=0.6s
- 减速=40%, 持续=1.5s
- 冰冻概率=5%, 冰冻持续=1s

### 烈焰经文 (flamebible)
- 类型：orbit + burn + pulse
- 半径=140, 速度=4, DPS=5
- 燃烧DPS=3, 持续=2s
- 脉冲CD=3s, 脉冲伤害=8, 脉冲半径=100

### 雷霆回旋 (thunderang)
- 类型：boomerang + lightning
- 数量=4, 速度=350, 返回速度=380, 伤害=7, 最大距离=400, CD=0.8s, 穿透=3, 追踪角=1.31
- 闪电概率=40%, 范围=120, 目标=2, 伤害=8, 链=2

### 烈焰回旋 (blazerang)
- 类型：boomerang + burn trail
- 数量=3, 速度=330, 返回速度=360, 伤害=6, 最大距离=380, CD=0.8s, 穿透=3
- 火焰轨迹持续=1.5s, 轨迹DPS=2, 燃烧持续=2.5s, 燃烧DPS=3

## 系统机制

### 进化触发条件
- 玩家同时持有两个满级(Lv3)基础武器
- 武器 ID 匹配进化配方
- 升级时进化选项出现在升级池中

### 进化流程
1. 玩家选择进化选项
2. 移除两个原始武器（从 owned_weapons 和 weapon_timers 中删除）
3. 清除原始武器的运行时实例（orbit/boomerang）
4. 添加进化武器到 owned_weapons，等级=1（且为最大等级）
5. 全屏白色闪烁 0.3s 表示进化成功

### WeaponData 新增字段
- `is_evolved: bool = false` — 标记是否为进化武器
- `evolved_from: Array[String] = []` — 进化原料武器 ID 列表
- 进化武器 max_level = 1

## 决策记录
- **为什么用双武器合成**：H5 原设计已验证，比 VS 的"武器+被动"更简单直接
- **为什么进化武器不可升级**：避免后期数值失控，进化武器数值已足够强
- **数值来源**：全部来自 H5 config.js EVOLUTIONS + WEAPONS
