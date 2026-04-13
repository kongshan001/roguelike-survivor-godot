# Survivor Arena

Godot 4.6 类吸血鬼幸存者肉鸽游戏，参考 H5 原型项目复刻。像素风视觉（ColorRect），键盘操控，支持 3 角色 / 7+8 武器 / 18 协同效应。

## 功能概览

### 角色系统
| 角色 | HP | 速度 | 初始武器 | 被动 |
|------|-----|------|----------|------|
| 法师 Mage | 8 | 160 | 自选 | 伤害+20% |
| 战士 Warrior | 12 | 140 | 飞刀 | 护甲+1 |
| 游侠 Ranger | 6 | 190 | 圣水 | 暴击+10% |

### 武器系统
- **7 种基础武器**：圣水（环绕）、飞刀（投射）、闪电（链式）、圣经（环绕）、火焰法杖（锥形）、冰冻光环（光环）、回旋镖（追踪）
- **8 种进化武器**：雷暴圣水、火焰飞刀、圣光领域、暴风雪、冰霜飞刀、烈焰经文、雷霆回旋、烈焰回旋
- 每种武器 3 级，两个满级武器可合成为进化武器

### 敌人系统
| 敌人 | HP | 速度 | 特殊 |
|------|-----|------|------|
| 僵尸 | 3 | 40 | 无 |
| 蝙蝠 | 1 | 80 | 快速 |
| 骷髅 | 5 | 20 | 远程射击 |
| 精英骷髅 | 12 | 15 | 3 方向射击 |
| 幽灵 | 2 | 55 | 50% 抗性，传送 |
| 分裂者 | 4 | 50 | 死亡分裂 |
| Boss | 200 | 30 | 三阶段 AI |

### 其他系统
- **18 种协同效应**：被动+被动 7 种、武器+被动 11 种，全部接入实际逻辑
- **4 种难度**：休闲 / 标准 / 噩梦 / 无尽
- **商店系统**：6 种永久升级（灵魂碎片货币）
- **28 个成就**：8 个分类，跨局累积追踪
- **14 个任务**：角色/击杀/生存/Boss/连击
- **Dash 系统**：无敌冲刺 + 残影
- **食物/箱子掉落**：回血 / 经验加成 / 速度提升

## 技术栈

- **引擎**：Godot 4.6，GL Compatibility 渲染
- **语言**：GDScript 4.x，typed 变量声明
- **架构**：CharacterBody2D + Area2D 物理系统，Resource 数据驱动，Autoload 单例
- **测试**：GUT v9.6.0 单元测试框架，428 测试 / 909 断言
- **视觉**：ColorRect 像素风，无需美术资源

## 项目结构

```
godot_demo/
├── project.godot              # Godot 项目配置
├── CLAUDE.md                  # AI Agent 协作规范
├── run_tests.sh               # 测试运行脚本
├── .gutconfig.json            # GUT 测试配置
├── scenes/                    # 场景文件 (.tscn)
│   ├── main.tscn              # 标题画面
│   ├── character_select.tscn  # 角色选择
│   ├── difficulty_select.tscn # 难度选择
│   ├── weapon_select.tscn     # 武器选择（法师）
│   ├── arena.tscn             # 竞技场
│   ├── hud.tscn               # HUD
│   ├── shop.tscn              # 商店
│   └── ...
├── scripts/                   # GDScript 脚本
│   ├── autoload/              # 自动加载单例
│   │   ├── game_manager.gd    # 全局游戏状态
│   │   ├── upgrade_pool.gd    # 升级选项池
│   │   ├── save_manager.gd    # 存档/成就/任务
│   │   └── synergy_manager.gd # 协同效应
│   ├── data/                  # Resource 数据类
│   ├── weapons/               # 武器模块
│   │   ├── weapon_fire.gd     # 6 种武器发射逻辑
│   │   ├── weapon_registry.gd # 进化配方
│   │   ├── weapon_effects.gd  # 视觉特效
│   │   └── boomerang.gd       # 回旋镖
│   ├── enemies/               # 敌人模块
│   │   └── boss_ai.gd         # Boss 三阶段 AI
│   ├── player.gd              # 玩家控制
│   ├── enemy.gd               # 敌人逻辑
│   ├── enemy_spawner.gd       # 波次生成
│   ├── arena.gd               # 竞技场管理
│   ├── hud.gd                 # HUD + 升级面板
│   └── ...
├── test/unit/                 # GUT 单元测试 (23 文件)
└── docs/
    └── team/                  # Agent 工作记录
```

## 运行与测试

### 运行游戏
```bash
# Godot 编辑器中打开项目，运行 main.tscn
# 或命令行：
godot --path .
```

### 运行测试
```bash
./run_tests.sh
```

### 录制游戏画面
```bash
godot --path . --write-movie /tmp/capture.avi --quit-after 90
```

## 操控

| 按键 | 功能 |
|------|------|
| WASD / 方向键 | 移动 |
| Space | Dash 冲刺 |
| R | 重投升级选项（每局 1 次） |
| Esc | 暂停 |

## 代码规范

- 单文件不超过 500 行，超出按职责拆分
- `data/` 只放数据定义，不含逻辑
- `autoload/` 单例间禁止互相引用（null guard 保护）
- 所有公开函数有参数和返回值类型注解
- 碰撞层：Layer1=Player, Layer2=Enemies, Layer3=Projectiles, Layer4=Pickups
- 优先使用 signal 通信，减少直接节点引用

## 数据来源

原始数值定义参考 H5 原型项目 `src/core/config.js`，所有武器/敌人/角色/难度数值保持一致。
