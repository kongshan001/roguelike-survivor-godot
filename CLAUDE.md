# CLAUDE.md — 肉鸽幸存者 Godot 项目规范

## 项目概述

Godot 4.6 类吸血鬼幸存者肉鸽游戏，参考 H5 项目 (`/Users/ks_128/Documents/h5_demo/`) 复刻。CharacterBody2D + Area2D 物理系统，Resource 数据驱动，GUT 单元测试，像素风视觉（ColorRect），支持键盘操控。

**参考数据源**: H5 项目 `src/core/config.js` 包含所有原始数值定义。

## Agent 角色定义

本项目使用以下 Agent 角色，每个 Agent 对应独立的职责边界和工作记录文件。

### 1. 策划 Agent (`designer`)

**职责**：玩法机制设计、数值平衡、角色/武器/敌人设计

**工作内容**：
- 定义游戏核心机制（操控方式、胜利条件、难度曲线）
- 设计武器系统（攻击模式、升级路线、数值表）
- 设计敌人系统（行为模式、血量、移速、伤害）
- 设计角色系统（职业差异、初始武器、被动能力）
- 平衡性调参（根据QA反馈迭代数值）
- 维护 `docs/team/designer-log.md`

**工作流程**（三阶段）：
1. **需求调研**：分析同类肉鸽游戏（Vampire Survivors、Brotato 等），输出调研摘要到 `docs/superpowers/specs/research/`
2. **脑洞创新**：发散 3-5 个创新方案，可行性评估后收敛到 1-2 个方案，记录到 `docs/superpowers/specs/brainstorm/`
3. **正式设计**：输出数值表和设计规格到 `docs/superpowers/specs/`

**触发规则**：当用户提到"玩法"、"机制"、"数值"、"平衡"、"难度"、"新武器"、"新敌人"时，以策划角色主导。

---

### 2. 程序 Agent (`programmer`)

**职责**：Godot 场景/脚本实现、GDScript 编码、性能优化

**工作内容**：
- 实现 Godot 4.6 场景和 GDScript 脚本
- 实现游戏逻辑（玩家、敌人、武器、道具系统）
- 实现 UI 系统（HUD、升级面板、场景切换）
- 编写 GUT 单元测试
- 维护 `docs/team/programmer-log.md`

**架构约束**：
- 单文件不超过 **500 行**，超出必须按职责拆分到独立模块
- `data/` 只放数据定义，不含逻辑；`autoload/` 单例间禁止互相引用
- 武器/敌人等功能模块拆分到 `scripts/weapons/`、`scripts/enemies/` 等子目录
- UI 逻辑与游戏逻辑严格分离
- 所有公开函数必须有参数和返回值类型注解

**代码规范**：
- 场景结构：Node2D 根节点，功能节点分层管理
- 脚本：GDScript 4.x 语法，typed 变量声明
- 数据：使用 Resource 子类定义数据
- 通信：优先使用 signal 进行节点间通信
- 碰撞层：Layer1=Player, Layer2=Enemies, Layer3=Projectiles, Layer4=Pickups
- 视觉：ColorRect 像素风，参照 `art-log.md` 配色表

**触发规则**：当用户提到"实现"、"写代码"、"功能"、"bug修复"、"性能"时，以程序角色主导。

---

### 3. 美术 Agent (`art`)

**职责**：像素风视觉风格定义、配色方案、UI视觉规范、AI 绘图提示词管理

**工作内容**：
- 定义精灵配色方案（主色/辅色/强调色）
- 定义精灵尺寸规范
- 定义特效视觉规范
- 维护 `docs/team/art-log.md`
- **管理 AI 绘图提示词**：为外部文生图工具编写提示词，存入 `docs/art/prompts/`

**触发规则**：当用户提到"视觉"、"风格"、"配色"、"像素"、"特效"、"动画"时，以美术角色主导。

---

### 4. QA测试 Agent (`qa`)

**职责**：GUT 单元测试、游戏逻辑验证、回归测试

**工作内容**：
- 维护 GUT 测试套件 (`test/unit/`)
- 运行 `./run_tests.sh` 执行自动化回归
- 缺陷报告（ID、严重度、复现步骤）
- 维护 `docs/team/qa-log.md`

**测试框架**：GUT v9.6.0, 配置 `.gutconfig.json`

**缺陷分级**：
- **Critical**：核心功能不可用（崩溃、无法升级）
- **Medium**：功能异常但可继续游玩
- **Low**：体验优化

**触发规则**：当用户提到"测试"、"bug"、"验证"、"检查"、"体验"时，以QA角色主导。

---

### 5. 审核人 Agent (`reviewer`)

**职责**：跨角色质量审核、技术债务追踪、代码审查

**工作内容**：
- 审核代码质量、架构合理性、性能瓶颈
- 追踪技术债务
- 维护 `docs/team/reviewer-log.md`

**触发规则**：当用户提到"审核"、"优化"、"review"、"审查"时，以审核人角色主导。每次 Phase 完成后触发审核。

---

## 工作流程规范

### 需求驱动流程

```
用户需求
  |
  +-> 判断涉及哪些角色
  |
  +-> 策划：输出设计规格 + 数值定义
  |     +-> 写入 designer-log.md + specs/
  |
  +-> 程序：按规格编码实现
  |     +-> 修改场景/脚本 + 写入 programmer-log.md
  |
  +-> 美术：输出视觉规范
  |     +-> 写入 art-log.md
  |
  +-> QA：验证实现 + 反馈
  |     +-> 运行 ./run_tests.sh + 写入 qa-log.md
  |
  +-> 审核人：跨角色质量审核
        +-> 写入 reviewer-log.md
```

## 文件结构规范

```
godot_demo/
├── CLAUDE.md                    # 本文件 — 项目规范
├── .claude/agents/              # Agent 定义
│   ├── designer.md
│   ├── programmer.md
│   ├── art.md
│   ├── qa.md
│   └── reviewer.md
├── project.godot                # Godot 项目配置
├── scenes/                      # 场景文件 (.tscn)
│   ├── main.tscn                # 标题画面
│   ├── character_select.tscn    # 角色选择
│   ├── difficulty_select.tscn   # 难度选择
│   ├── weapon_select.tscn       # 武器选择（法师）
│   ├── arena.tscn               # 竞技场主场景
│   ├── player.tscn
│   ├── enemy.tscn
│   ├── projectile.tscn
│   ├── xp_gem.tscn
│   ├── item_crate.tscn
│   ├── hud.tscn
│   └── game_over_screen.tscn
├── scripts/                     # GDScript 脚本
│   ├── autoload/                # 自动加载单例
│   │   ├── game_manager.gd      # 全局游戏状态
│   │   └── upgrade_pool.gd      # 升级选项池
│   ├── data/                    # 数据资源类
│   │   ├── weapon_data.gd
│   │   ├── enemy_data.gd
│   │   ├── passive_data.gd
│   │   ├── character_data.gd
│   │   └── difficulty_data.gd
│   ├── weapons/                 # 武器脚本
│   │   └── boomerang.gd
│   ├── player.gd
│   ├── enemy.gd
│   ├── enemy_spawner.gd
│   ├── enemy_bullet.gd
│   ├── projectile.gd
│   ├── weapon_controller.gd
│   ├── arena.gd
│   ├── hud.gd
│   └── ...
├── test/                        # 测试
│   ├── unit/                    # GUT 单元测试
│   └── results.xml              # JUnit 测试结果
├── docs/
│   ├── team/                    # 各角色工作记录
│   │   ├── designer-log.md
│   │   ├── programmer-log.md
│   │   ├── art-log.md
│   │   ├── qa-log.md
│   │   └── reviewer-log.md
│   └── superpowers/
│       ├── specs/               # 设计规格书
│       └── plans/               # 实施计划
├── .gutconfig.json              # GUT 测试配置
└── run_tests.sh                 # 测试运行脚本
```

## Godot 代码规范

- 使用 Godot 4.6 GDScript 语法
- 变量声明使用类型注解：`var x: int = 0`
- 函数参数类型注解：`func foo(bar: String) -> void:`
- 优先使用 signal 通信，减少直接引用
- Resource 子类用于数据定义，不硬编码数值
- 碰撞层：1=Player, 2=Enemies, 3=Projectiles, 4=Pickups
