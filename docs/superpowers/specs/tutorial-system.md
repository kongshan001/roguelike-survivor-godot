# 新手引导系统设计

**Author**: Designer Agent
**Date**: 2026-04-17
**Round**: R16
**Status**: Design Spec
**Priority**: P1

---

## 1. 设计概述

当前游戏流程为：标题画面 -> 角色选择 -> 难度选择 -> 进入竞技场。首次进入竞技场后，玩家面对大量 HUD 元素（血条、经验条、波次进度条、连击数、金币、波次名称、技能按钮）和自动发射的武器，但没有任何操作提示。标题画面仅有一行 "WASD to move" 文字，不覆盖核心操作（Dash、技能、升级选择）。

本方案设计 5 步渐进式新手引导，通过低侵入性的提示气泡（Tooltip），在首次游戏的前 60 秒内逐步解锁操作知识。每步仅在特定条件下触发，完成后不再重复。引导数据通过 `SaveManager` 持久化（首次游戏标记）。

### 为什么这样设计

- Vampire Survivors 不需要新手引导（仅一个操作：移动），但我们的游戏有 Dash、技能键、升级面板 3 个核心交互，需要最低限度的引导
- Brotato 使用独立的 "Tips" 页面，但跳出游戏流查看操作说明的成本太高
- HoloCure 使用渐进式提示（首次拾取道具时弹出说明），这是品类最佳实践
- 目标：30 秒内教会玩家移动+闪避，60 秒内教会升级选择，不影响战斗节奏

---

## 2. 新手引导步骤定义

### Step 1: 移动引导

| 属性 | 值 |
|---|---|
| **触发条件** | 首次进入竞技场，玩家静止超过 2 秒 |
| **显示内容** | "WASD 移动角色" |
| **位置** | 玩家角色正上方 40px |
| **交互方式** | 按下任意移动键后消失 |
| **超时** | 8 秒后自动消失 |
| **条件检查** | `SaveManager.tutorial_step < 1` |
| **实现** | Arena 场景中创建 Label 节点，跟随玩家位置 |

### Step 2: 闪避引导

| 属性 | 值 |
|---|---|
| **触发条件** | Step 1 完成后，首个敌人进入屏幕 200px 范围内 |
| **显示内容** | "Space 冲刺闪避" |
| **位置** | 玩家角色正上方 40px |
| **交互方式** | 按下 Space 键后消失；或被敌人击中后消失（负面反馈学习） |
| **超时** | 10 秒后自动消失 |
| **条件检查** | `SaveManager.tutorial_step < 2` |
| **实现** | 监听 `enemy_count` 变化或 `health_changed` 信号 |

### Step 3: 武器自动说明

| 属性 | 值 |
|---|---|
| **触发条件** | Step 2 完成后，玩家首次击杀敌人（`enemies_killed` 从 0 变为 1） |
| **显示内容** | "武器自动攻击，拾取掉落的经验宝石升级" |
| **位置** | 屏幕顶部中央（不遮挡战斗区域） |
| **交互方式** | 3 秒后自动消失 |
| **超时** | 3 秒 |
| **条件检查** | `SaveManager.tutorial_step < 3` |

### Step 4: 升级选择引导

| 属性 | 值 |
|---|---|
| **触发条件** | 首次升级面板弹出（`_pending_level_ups` 从 0 变为 1） |
| **显示内容** | "点击卡牌或按 1/2/3 选择升级。按 R 重随。" |
| **位置** | 升级面板上方 |
| **交互方式** | 选择任意升级后消失 |
| **超时** | 无（升级面板暂停游戏，不超时） |
| **条件检查** | `SaveManager.tutorial_step < 4` |
| **实现** | 在 `hud.gd` 的 `_show_upgrade_panel()` 中添加 Label |

### Step 5: 技能引导

| 属性 | 值 |
|---|---|
| **触发条件** | Step 4 完成后，技能冷却首次完成（`is_skill_ready` 变为 true 且之前为 false） |
| **显示内容** | "按 E 使用角色技能" |
| **位置** | 技能按钮图标上方 |
| **交互方式** | 按下 E 键后消失 |
| **超时** | 10 秒后自动消失 |
| **条件检查** | `SaveManager.tutorial_step < 5` |
| **实现** | 在 `hud_skill_button.gd` 中监听 `skill_ready_signal` |

---

## 3. 数值常量表

| 常量名 | 值 | 单位 | 来源 | 备注 |
|---|---|---|---|---|
| `TUTORIAL_LABEL_OFFSET` | 40.0 | px | 设计 | 提示气泡距玩家角色的垂直偏移 |
| `TUTORIAL_STEP_MOVE_TIMEOUT` | 8.0 | s | 设计 | 移动引导自动消失时间 |
| `TUTORIAL_STEP_DASH_TIMEOUT` | 10.0 | s | 设计 | 闪避引导自动消失时间 |
| `TUTORIAL_STEP_WEAPON_TIMEOUT` | 3.0 | s | 设计 | 武器说明自动消失时间 |
| `TUTORIAL_STEP_SKILL_TIMEOUT` | 10.0 | s | 设计 | 技能引导自动消失时间 |
| `TUTORIAL_STEP_ENEMY_RANGE` | 200.0 | px | 设计 | 触发闪避引导的敌人距离 |
| `TUTORIAL_STEP_MOVE_DELAY` | 2.0 | s | 设计 | 触发移动引导的静止等待时间 |
| `TUTORIAL_TOTAL_STEPS` | 5 | int | 设计 | 引导步骤总数 |
| `TUTORIAL_FONT_SIZE` | 14 | int | px | 提示文字字号（与 HUD 一致） |
| `TUTORIAL_BG_COLOR` | Color(0, 0, 0, 0.7) | Color | 设计 | 提示背景色（半透明黑） |
| `TUTORIAL_TEXT_COLOR` | Color(1, 0.85, 0.3) | Color | 设计 | 提示文字色（金色，匹配技能按钮） |
| `TUTORIAL_BG_PADDING` | Vector2(8, 4) | px | 设计 | 提示背景内边距 |

---

## 4. 状态管理

### 4.1 持久化

在 `SaveManager` 中新增：

```gdscript
var tutorial_step: int = 0  # 0=未开始, 1=移动完成, ..., 5=全部完成
var tutorial_completed: bool = false
```

存储在 save 文件中，与 `soul_fragments` 同级。

### 4.2 引导状态机

```
[0: 未触发]
    |
    +-- (arena 加载, 静止 2s) --> [Step 1: 移动]
    |
    +-- (WASD 按下) --> [1: 移动完成]
    |
    +-- (敌人进入 200px) --> [Step 2: 闪避]
    |
    +-- (Space 按下 OR 受伤) --> [2: 闪避完成]
    |
    +-- (首杀) --> [Step 3: 武器说明]
    |
    +-- (3s 超时) --> [3: 武器说明完成]
    |
    +-- (首次升级面板弹出) --> [Step 4: 升级引导]
    |
    +-- (选择升级) --> [4: 升级完成]
    |
    +-- (技能就绪) --> [Step 5: 技能引导]
    |
    +-- (E 按下 OR 10s 超时) --> [5: 全部完成, tutorial_completed = true]
```

### 4.3 一次性保证

- `tutorial_completed == true` 时，所有引导逻辑短路跳过
- 同一 SaveManager 配置文件只触发一次引导
- 如果玩家已通关一次，后续游戏不再显示引导

---

## 5. 视觉规范

### 5.1 提示气泡样式

```
+-----------------------------+
|  WASD 移动角色              |  <- 金色文字, 14px
+-----------------------------+
      |
      v
   [Player]                    <- 黑色半透明背景, 圆角 4px
```

- 使用 `PanelContainer` + `Label` 组合
- PanelContainer 的 `StyleBoxFlat` 设置：bg_color = `Color(0, 0, 0, 0.7)`，border_radius = 4
- Label 字色 `Color(1, 0.85, 0.3)`，字号 14
- 位置：玩家头顶 40px 或 HUD 元素附近

### 5.2 入场动画

- 引导气泡入场：从 `modulate.a = 0` 渐变到 `modulate.a = 1`，持续 0.3 秒
- 退场：从 `modulate.a = 1` 渐变到 `modulate.a = 0`，持续 0.2 秒，然后 `queue_free()`
- 使用 `Tween` 实现动画

---

## 6. 集成映射

### 6.1 需要修改的文件

| 文件 | 修改内容 | 预估行数 |
|---|---|---|
| `scripts/autoload/save_manager.gd` | 新增 `tutorial_step` 和 `tutorial_completed` 持久化变量 | ~4 行 |
| `scripts/arena.gd` | 新增引导管理子节点 `_tutorial_manager` | ~8 行 |
| `scripts/hud.gd` | 在 `_show_upgrade_panel()` 中添加升级引导 Label | ~15 行 |
| `scripts/hud_skill_button.gd` | 监听 `skill_ready_signal` 触发技能引导 | ~12 行 |

### 6.2 新增文件

| 文件 | 功能 | 预估行数 |
|---|---|---|
| `scripts/tutorial_manager.gd` | 引导状态机 + 提示气泡创建/销毁 | ~120 行 |

### 6.3 不需要修改的文件

- `player.gd` -- 不需要修改（引导通过信号和计数器触发，不直接修改玩家逻辑）
- `enemy_spawner.gd` -- 不需要修改（引导通过 `enemy_count` 信号触发）
- `game_manager.gd` -- 不需要修改（引导通过 `enemies_killed` 和 `level_up` 信号触发）

### 6.4 信号依赖

| 引导步骤 | 触发信号 | 来源 |
|---|---|---|
| Step 1 | `_physics_process` 中检测静止时间 | arena.gd / tutorial_manager.gd |
| Step 2 | `GameManager.enemies_changed` 或 `health_changed` | game_manager.gd / player.gd |
| Step 3 | `GameManager.enemies_killed` 变化 | game_manager.gd |
| Step 4 | `GameManager.level_up` | game_manager.gd |
| Step 5 | `player.skill_ready_signal` | player.gd |

---

## 7. 实现复杂度评估

| 维度 | 评级 | 说明 |
|---|---|---|
| 技术实现 | 低 | 仅需 1 个新脚本 (~120 行) + 4 处小修改。所有引导逻辑基于现有信号 |
| 数值平衡 | 无影响 | 引导不修改任何游戏数值，仅在 UI 层叠加提示 |
| 玩家理解 | 低 | 文字提示 + 按键图标，无需图形化教程。5 步渐进，每步仅 1 个操作 |
| 性能 | 无影响 | 引导气泡是静态 Label，每帧仅更新位置（跟随玩家）。完成后销毁 |

---

## 8. 设计决策记录

| 决策 | 原因 | 放弃的替代方案 |
|---|---|---|
| 5 步渐进式而非独立教程关卡 | 匹配品类最佳实践（HoloCure 式 in-context 提示），不中断游戏流。实现成本低（~120 行 vs 独立场景 ~500+ 行） | (1) 独立教程场景（实现成本高，跳出主线流）；(2) 仅标题画面文字说明（不够直观，玩家不看） |
| 提示气泡跟随玩家而非固定位置 | 在移动游戏中，固定位置提示可能被玩家移动到屏幕外。跟随玩家确保始终可见 | 固定屏幕位置的 Tooltip（可能被战斗区域遮挡） |
| 使用 SaveManager 持久化而非 meta | 引导完成状态需要跨会话保存。meta 仅在当前会话有效，游戏重启后丢失 | GameManager.set_meta()（会话级，不适合一次性标记） |
| Step 3 仅 3 秒自动消失 | 武器自动攻击说明不需要交互确认。3 秒足够阅读 12 个中文字符 | 等待拾取宝石确认（拾取时机不可控，可能延迟引导流程） |
| Step 5 在技能就绪时触发而非 arena 加载时 | 技能在 arena 加载时不可用（冷却 0s，初始就 ready 但玩家还不知道）。等待首次技能冷却完成后再提示，上下文更自然 | arena 加载时直接显示（玩家还不知道技能按钮在哪） |
| 不阻塞游戏进行 | 所有引导步骤在游戏进行中显示，不暂停游戏（除 Step 4 利用升级面板已有的暂停） | 暂停游戏显示引导（打断战斗节奏，违背品类核心体验） |

---

## 9. 测试用例建议

| 用例 | 验证内容 | 优先级 |
|---|---|---|
| 首次游戏显示 Step 1 | `tutorial_step == 0`，arena 加载 2s 后显示移动提示 | P0 |
| WASD 消除 Step 1 | 按下移动键后提示消失，`tutorial_step` 更新为 1 | P0 |
| 已完成引导不显示 | `tutorial_completed == true` 时，arena 加载后无任何提示 | P0 |
| Step 2 敌人触发 | 首个敌人进入 200px 范围时显示闪避提示 | P1 |
| Step 4 升级触发 | 首次升级面板弹出时显示选择提示 | P1 |
| Step 5 技能触发 | 首次技能冷却完成时显示技能提示 | P1 |
| 超时自动消失 | Step 1/2/3/5 各自在超时后消失且更新 step | P2 |
| 跳过中间步骤 | 如果玩家 2s 内就开始移动，Step 1 直接完成 | P2 |
| 持久化验证 | 完成引导后重启游戏，引导不再出现 | P1 |
