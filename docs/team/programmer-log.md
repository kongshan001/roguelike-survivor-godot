# 程序工作记录

## 当前优先级

| 优先级 | 事项 | 状态 |
|--------|------|------|
| P0 | 建立角色分工体系 | ✅ 已完成 |
| P0 | CharacterData + DifficultyData 数据类 | ✅ 已完成 |
| P0 | 角色选择/难度选择/武器选择场景 | ✅ 已完成 |
| P0 | GameManager 扩展（角色/难度/金币/连击） | ✅ 已完成 |
| P0 | Player 适配（角色属性/暴击/护甲） | ✅ 已完成 |
| P1 | 7种武器系统重构 | ✅ 已完成 |
| P1 | 7种敌人 + Boss三阶段 + 弹幕系统 | ✅ 已完成 |
| P1 | 5段波次进度 + 无尽模式生成 | ✅ 已完成 |
| P2 | 8种进化武器系统 | ✅ 已完成 |
| P2 | 17种协同效应系统 | ✅ 已完成 |
| P3 | 商店/存档/任务/成就系统 | ✅ 已完成 |

## 技术决策

### 2026-04-12: 项目架构
- **决策**: 采用 Godot 4.6 场景驱动架构，Resource 子类定义数据
- **为什么**: Godot 原生模式，利于编辑器集成和测试
- **技术栈**: Godot 4.6 + GDScript + GUT 测试框架

### 2026-04-12: Phase 3 敌人系统实现
- **决策**: Boss AI 抽离为独立模块 `scripts/enemies/boss_ai.gd`，通过 `load()` 动态实例化
- **为什么**: 避免文件过长（500行约束），`class_name` 跨目录解析在 GUT 测试中有问题
- **新增文件**: `scripts/enemy_bullet.gd`, `scenes/enemy_bullet.tscn`, `scripts/enemies/boss_ai.gd`
- **修改文件**: `scripts/enemy.gd`, `scripts/enemy_spawner.gd`, `scripts/data/enemy_data.gd`
- **架构约束**: 使用动态 `load()` 而非 `class_name` 引用外部模块类

### 2026-04-12: Phase 4-5 进化武器 + 协同效应
- **决策**: 武器注册迁入 UpgradePool，weapon_registry 只保留进化配方匹配逻辑
- **为什么**: 消除循环依赖（weapon_registry → UpgradePool autoload → parse-time resolution）
- **决策**: 协同效应使用独立 autoload SynergyManager，player.gd 通过 null guard 调用
- **为什么**: GUT 测试中 autoload 不可用，null guard 保证测试安全

### 2026-04-12: Phase 6 商店/存档/任务/成就
- **决策**: SaveManager 使用 Godot ConfigFile 持久化，全局 autoload
- **为什么**: INI 格式简单可靠，Godot 原生支持
- **新增文件**: `scripts/autoload/save_manager.gd`, `scripts/shop.gd`, `scenes/shop.tscn`, `test/unit/test_save_manager.gd`
- **修改文件**: `project.godot`（注册 SaveManager）, `scripts/player.gd`（商店加成）, `scripts/enemy.gd`（金币加成）, `scripts/xp_gem.gd`（经验加成）, `scripts/game_over_screen.gd`（任务/成就检测）, `scripts/title_screen.gd`（商店入口）
- **集成要点**:
  - 商店加成在 player._ready() 中应用（HP/速度/拾取/武器伤害）
  - 金币加成在 enemy die 时应用
  - 经验加成在 xp_gem._collect() 时应用
  - 任务/成就检测在 game_over_screen._ready() 触发
  - 灵魂碎片 = 金币×30% 在局结束时自动转化

### 2026-04-12: 可玩性修复（难度/角色追踪/HUD/null guard）
- **决策**: 从 H5 config.js DIFFICULTY 配置直接取值，添加 DIFFICULTY_PRESETS 到 GameManager
- **为什么**: easy/normal/hard 难度体验完全相同，DifficultyData 资源类未被使用
- **修改**: GameManager 新增 DIFFICULTY_PRESETS + get_difficulty_mul() + character_kills
- **修改**: arena.gd 应用 player_hp_mul/player_speed_mul 到玩家
- **修改**: enemy_spawner.gd 应用 enemy_hp_mul/enemy_speed_mul/enemy_dmg_mul/spawn_interval_mul/boss_hp_mul/boss_speed_mul
- **修改**: save_manager.gd 检测 warrior_30/ranger_30 角色30杀任务
- **修改**: hud.tscn + hud.gd 新增 GoldLabel、ComboLabel、DifficultyLabel
- **修改**: weapon_controller.gd 所有 SynergyManager 调用添加 null guard

### 2026-04-12: 可玩性深度修复（伤害追踪/全面难度乘数/无尽锁定）
- **决策**: 添加 damage_taken bool 追踪无伤状态，修复 no_damage 任务/成就检测
- **为什么**: no_damage 任务和 no_damage_survive 成就从未检查实际伤害状态
- **修改**: GameManager 新增 damage_taken，player.take_damage() 设为 true
- **修改**: save_manager.gd 检测 no_damage 任务 + no_damage_survive 成就
- **修改**: xp_gem.gd 应用 difficulty exp_mul（easy 1.3x, hard 0.8x）
- **修改**: arena.gd 碰撞伤害应用 enemy_dmg_mul
- **修改**: enemy.gd 子弹伤害 + 分裂子体 HP/速度/伤害 应用难度乘数
- **修改**: difficulty_select.gd 无尽模式锁定检查（SaveManager.endless_unlocked）
