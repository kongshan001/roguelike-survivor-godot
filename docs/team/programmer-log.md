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
| P2 | 18种协同效应系统 | ✅ 已完成 |
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

### 2026-04-13: Dash 闪避 + 食物掉落 + 屏幕震动 + 第18个协同
- **决策**: 新增 Dash 系统、食物掉落、屏幕震动反馈、第18个协同效应
- **新增文件**:
  - `scripts/food_pickup.gd` — 食物拾取脚本（1HP 回血，磁铁吸引）
  - `test/unit/test_player_dash.gd` — 7 个 Dash 系统测试
  - `test/unit/test_food_pickup.gd` — 6 个食物拾取测试
  - `test/unit/test_arena_screen_shake.gd` — 9 个屏幕震动测试
- **修改文件**:
  - `scripts/player.gd` — Dash 系统（Space 键触发，80px 冲刺，2.5s 冷却，无敌帧）
  - `scripts/enemy.gd` — _spawn_food()（10% 掉落，难度乘数），修复 _spawn_food 和 _spawn_split_children 函数合并错误
  - `scripts/arena.gd` — 屏幕震动（受伤 3.0，连杀≥20 时 2.0，衰减 5.0/s）
  - `scripts/autoload/synergy_manager.gd` — 第18个协同 "命运赌徒"（crit+luckycoin）
  - `scripts/autoload/game_manager.gd` — food_drop_mul 难度乘数
  - `test/unit/test_synergy_manager.gd` — 新增 crit_luckycoin 测试，总数更新为 18
- **Bug修复**: enemy.gd 中 _spawn_food() 和 _spawn_split_children() 被错误合并为一个函数，导致 parse error，已拆分修复

### 2026-04-13: 15个协同效应接入 + 连击奖励 + Boss警告 + 进化追踪
- **决策**: 将定义在 synergy_manager.gd 中的18个协同效应接入实际游戏逻辑
- **修改文件**:
  - `scripts/weapon_controller.gd` — knife_crit/lightning_magnet/firestaff_armor/frost_regen/boomerang_crit 协同（9处 has_synergy 检查）
  - `scripts/player.gd` — armor_maxhp(护甲翻倍)/armor_regen(低HP+3护甲) 协同
  - `scripts/enemy.gd` — magnet_crit(额外宝石)/crit_luckycoin(双倍金币)/luckycoin基础(金币+15%)/combo gold(+1金≥5连击)
  - `scripts/xp_gem.gd` — magnet_maxhp(2%回复1HP)/combo exp(combo×5%加成)
  - `scripts/enemy_spawner.gd` — Boss出生前15s触发 boss_warning 信号
  - `scripts/hud.gd` — Boss警告Label显示、combo里程碑颜色变化、进化追踪(meta)
  - `scenes/hud.tscn` — 新增 BossWarningLabel 节点
  - `scripts/arena.gd` — 分级屏幕震动(combo 5→3/10→5/20→7/50→10)
  - `scripts/autoload/game_manager.gd` — combo_milestone/boss_warning 信号, COMBO_MILESTONES常量
  - `test/unit/test_arena_screen_shake.gd` — 更新为分级震动预期值
- **接入状态**: 13/18 协同已生效，5个需要额外基础设施（击杀归属追踪等）
- **新增系统**: 连击奖励(经验+金币)、Boss警告UI、进化武器追踪、幸运硬币被动基础效果

---

## 2026-04-16: 技术债务全面审计

### 审计范围
- 33 个 .gd 源文件，24 个测试文件
- 行数统计、架构合规、代码重复、魔法数字、set_script 模式、空指针风险
- 对比 docs/lessons-learned.md 历史问题检查复发

---

### 1. 文件规模审计

| 文件 | 行数 | 占上限% | 风险 |
|------|------|---------|------|
| scripts/autoload/save_manager.gd | 391 | 78.2% | **高** -- 接近警戒线 |
| scripts/enemy.gd | 361 | 72.2% | **高** -- die() 函数承担过多职责 |
| scripts/weapons/weapon_fire.gd | 328 | 65.6% | 中 |
| scripts/enemy_spawner.gd | 256 | 51.2% | 低 |
| scripts/player.gd | 251 | 50.2% | 低 |
| scripts/autoload/upgrade_pool.gd | 219 | 43.8% | 低 |
| scripts/hud.gd | 195 | 39.0% | 低 |
| 其余 26 个文件 | <175 | <35% | 无 |

**结论**: 无文件超过 500 行硬限制。save_manager.gd (391行) 和 enemy.gd (361行) 是重点监控对象。

---

### 2. Top 5 技术债务项

#### TD-1: Autoload 交叉引用 -- SaveManager 直接读取 GameManager 状态 [严重度: HIGH]
- **文件**: `scripts/autoload/save_manager.gd` 第 185-283 行
- **描述**: `check_quests_and_achievements()` 直接读取 `GameManager.enemies_killed`、`GameManager.elapsed_time`、`GameManager.boss_kill_count`、`GameManager.best_combo` 等 10+ 个属性。同时直接读取 `SynergyManager.SYNERGY_DEFINITIONS` 和调用 `SynergyManager.has_synergy()`。
- **违反约束**: CLAUDE.md 规定 "autoload 单例之间禁止互相引用（通过 signal 解耦）"
- **影响**: 测试耦合、初始化顺序依赖、单点修改扩散
- **建议**: 将 game-end 数据打包为 Dictionary 通过 signal 传递，或引入 GameResult 数据类

#### TD-2: enemy.gd die() 函数职责过重 [严重度: HIGH]
- **文件**: `scripts/enemy.gd` 第 223-282 行，die() 函数 60 行
- **描述**: die() 同时处理金币计算(含 SaveManager/SynergyManager/luckycoin 5 层嵌套)、经验宝石生成、食物掉落、物品箱掉落、Boss 死亡、分裂子体生成、协同特效。是整个项目最复杂的单体函数。
- **影响**: 测试困难、修改任一掉落逻辑都需理解全部逻辑
- **建议**: 拆分为 `_handle_gold_drop()`、`_handle_loot_drops()`、`_handle_boss_death()`、`_handle_split_death()` 独立函数

#### TD-3: 私有成员跨模块直接访问 [严重度: MEDIUM]
- **文件**: `scripts/player.gd` 第 211-212 行、`scripts/weapon_controller.gd` 第 48 行
- **描述**: player.gd 直接访问 `UpgradePool._passives`（以下划线开头的私有变量），weapon_controller.gd 直接访问 `UpgradePool._weapons`。
- **违反约束**: GDScript 约定 `_` 前缀为私有，外部不应直接访问
- **建议**: UpgradePool 提供 `get_passive_max_stack(id)` 和 `get_weapon_data(id)` 公开接口

#### TD-4: weapon_fire.gd 中魔法数字未提取 [严重度: MEDIUM]
- **文件**: `scripts/weapons/weapon_fire.gd`
- **描述**: 第 30 行 `0.6`（每级伤害增量）、第 80 行 `250.0`（crit_knife 速度）、第 102 行 `50.0`、`5.0`（holywater 升级参数）、第 108 行 `80.0`、`20.0`（bible 升级参数）、第 183 行 `20.0`、`30.0`（cone 升级参数）、第 234 行 `0.15`（aura slow per level）、第 288 行 `50.0`（boomerang max_dist per level）、第 291 行 `0.4`（cooldown reduction per level）、第 292 行 `0.26`（track angle per level）
- **对比**: player.gd 已完成 20 处常量提取（历史记录），weapon_fire.gd 是当前最大遗漏
- **建议**: 提取为 `const LEVEL_DAMAGE_BONUS := 0.6` 等命名常量，或定义 WeaponLevelScaling Resource

#### TD-5: _find_player() 代理函数仍散布 4 个文件 [严重度: LOW]
- **文件**: `scripts/enemy.gd`、`scripts/xp_gem.gd`、`scripts/food_pickup.gd`、`scripts/item_crate.gd`
- **描述**: lessons-learned.md 第 5.1 节已记录此问题并提取了 `GameManager.find_player()` 静态方法。但 4 个文件仍各自维护 `_find_player()` 代理函数，形成冗余薄层。
- **影响**: 代码重复（虽然已减轻为单行代理）
- **建议**: 各文件 `_physics_process` 中直接调用 `GameManager.find_player()`，消除代理函数

---

### 3. 架构合规性检查

#### 3.1 Autoload 隔离
| 单例 | 引用其他 Autoload | 合规 |
|------|-------------------|------|
| GameManager | 无引用 | PASS |
| UpgradePool | 无引用 | PASS |
| SynergyManager | 无引用 | PASS |
| SaveManager | 引用 GameManager (10+), SynergyManager (6) | **FAIL** |

**说明**: 唯一的交叉引用方向是 SaveManager -> GameManager + SynergyManager。目前仅在一个函数 `check_quests_and_achievements()` 中，但该函数是 100 行的大函数，影响面广。

#### 3.2 数据类纯洁性
- `scripts/data/weapon_data.gd` -- 纯数据，无逻辑引用: PASS
- `scripts/data/enemy_data.gd` -- 纯数据，无逻辑引用: PASS
- `scripts/data/passive_data.gd` -- 纯数据: PASS
- `scripts/data/character_data.gd` -- 纯数据: PASS
- `scripts/data/difficulty_data.gd` -- 纯数据: PASS

#### 3.3 set_script / set_deferred 模式
- `weapon_fire.gd:320` (boomerang): 先 `set_script()` 再通过 `setup_boomerang()` 赋值 -- **PASS** (符合 lessons-learned 3.2)
- `weapon_fire.gd:127` (spin_blade): 先 `set_script()` 再通过 `setup()` 赋值 -- **PASS**
- `weapon_effects.gd:50` (cone effect): 先 `set_script()` 再 `set_deferred()` 赋值 -- **PASS**
- `enemy.gd:309` (food): 先 `set_script()` 再手动添加子节点 -- **PASS** (food_pickup 无 setup 函数，使用默认值)

#### 3.4 碰撞层
- 确认代码中无硬编码 collision_layer/mask，均在 .tscn 场景文件中设置

---

### 4. 潜在 Bug 和风险点

#### BUG-1: boss_ai.gd _process_phase2 重复赋值
- **文件**: `scripts/enemies/boss_ai.gd` 第 59-60 行
- **描述**: `_charge_timer = _charge_duration` 写了两次（连续两行），`_charge_cooldown = 4.0` 在 `_is_charging` 为 false 的分支中被递减但初始值也为 4.0，且递减逻辑与上面的 `_charge_timer` 递减存在混淆。
- **风险**: Boss 第二阶段充能冷却可能不按设计工作

#### BUG-2: item_crate.gd 速度提升无防护
- **文件**: `scripts/item_crate.gd` 第 42-46 行
- **描述**: `speed_multiplier += 0.3` 在 10s 后 `-= 0.3`。若玩家在 10s 内死亡并 queue_free，定时器回调中 `is_instance_valid(_player)` 通过，但 player 可能处于 die() 后状态。此外多次拾取 speed_boost 会累加 0.3x。
- **风险**: 低 -- 但速度乘数理论上可无限叠加

#### BUG-3: enemy.gd _spawn_food 使用 ColorRect 而非 Sprite2D
- **文件**: `scripts/enemy.gd` 第 306-321 行
- **描述**: 食物实体使用 `ColorRect.new()` 创建视觉，而项目已完成 ColorRect->Sprite2D 迁移（见 qa-log.md 视觉验证记录）。这是唯一遗漏的 ColorRect 游戏实体。
- **风险**: 视觉风格不一致

#### RISK-1: get_parent() 无空检查
- **文件**: `scripts/enemy.gd` 第 192、294、303、321、346、357 行
- **描述**: 多处 `get_parent().call_deferred("add_child", ...)` 和 `get_parent().get_node_or_null(...)` 未检查 get_parent() 返回值
- **风险**: 若 enemy 在场景树外被调用（理论上不应发生），将崩溃

---

### 5. lessons-learned.md 复发检查

| 历史问题 | 当前状态 |
|----------|----------|
| ColorRect->Sprite2D 迁移 (1.1) | 基本完成，但 enemy.gd:315 的 food_pickup 仍用 ColorRect |
| weapon_id 与文件名映射 (1.2) | 仍直接拼接路径，无映射表 |
| float vs int 函数 (3.1) | 未发现新的 mini/minf 混用 |
| set_script 顺序 (3.2) | 全部正确 |
| 常量名一致性 (4.1) | 无新的不一致 |
| 魔法数字 (4.2) | player.gd 已修复，weapon_fire.gd 仍有大量魔法数字 |
| _find_player 重复 (5.1) | 已提取到 GameManager.find_player() 但 4 个文件仍保留代理函数 |

---

### 6. 代码重复分析

#### 重复模式 A: "查找玩家 + 磁铁吸引 + 移动 + 收集" 拾取模式
- **文件**: `xp_gem.gd` (77行), `food_pickup.gd` (44行)
- **描述**: 两个文件有高度相似的结构 -- `_find_player()`、`is_moving_to_player`、`magnet_speed` 递增、`dist < 10.0` 时收集
- **建议**: 提取 `PickupBase` 基类或工具脚本

#### 重复模式 B: "实例化投射物 + call_deferred add_child"
- **出现 14 处**: weapon_fire.gd (5处), enemy.gd (5处), boss_ai.gd (1处), weapon_effects.gd (2处), player.gd (1处)
- **描述**: 每处都先实例化场景、设置属性、查找 ProjectileManager、然后 call_deferred
- **建议**: 引入 ProjectileManager.spawn(pattern) 方法统一管理

---

### 7. 质量自评分

**总分: 72/100**

| 评分维度 | 得分 | 满分 | 说明 |
|----------|------|------|------|
| 文件规模合规 | 15 | 15 | 无超限文件 |
| 架构合规 | 8 | 15 | SaveManager 交叉引用其他 autoload |
| 代码质量 | 12 | 20 | weapon_fire.gd 魔法数字、私有成员直接访问 |
| 测试覆盖 | 15 | 15 | 467 测试、24 文件、1079 断言 |
| 重复控制 | 5 | 10 | xp_gem/food_pickup 结构重复、_find_player 代理冗余 |
| Bug 风险 | 7 | 10 | boss_ai 充能逻辑疑似 bug、food ColorRect 遗漏 |
| lessons-learned 遵从 | 5 | 10 | weapon_id 映射表未实现、魔法数字部分复发 |
| null guard | 5 | 5 | autoload 调用普遍有 null guard |

---

### 8. 优先重构任务（若分数需提升至 85+）

| 优先级 | 任务 | 预计行数变化 | 影响范围 |
|--------|------|-------------|----------|
| P0 | 拆分 enemy.gd die() 为 4 个独立函数 | 同文件内重构 | enemy.gd |
| P0 | 修复 boss_ai.gd _process_phase2 重复赋值 | 1-2 行 | boss_ai.gd |
| P1 | SaveManager.check_quests_and_achievements 改为参数注入 | save_manager.gd -20行 + interface | save_manager, game_over_screen |
| P1 | UpgradePool 添加 get_passive_max_stack()/get_weapon_data() 公开接口 | +8 行 | upgrade_pool, player, weapon_controller |
| P1 | weapon_fire.gd 魔法数字提取为常量 | +15 行 | weapon_fire.gd |
| P2 | enemy.gd _spawn_food 改用 Sprite2D + food sprite | 3 行 | enemy.gd |
| P2 | 消除 4 个 _find_player() 代理函数 | -12 行 | enemy/xp_gem/food_pickup/item_crate |
| P3 | 提取 PickupBase 拾取基类 | +40/-60 行 | xp_gem, food_pickup |

---

### 审计结论

项目整体架构合理，文件规模控制良好（无超限），测试覆盖全面（467 测试）。主要技术债务集中在：
1. **SaveManager 与其他 autoload 的交叉引用** -- 这是当前最大的架构违规
2. **enemy.gd die() 职责过重** -- 是代码复杂度的集中点
3. **weapon_fire.gd 魔法数字** -- lessons-learned 中已记录的问题在另一文件复发

建议在下一个功能迭代前完成 P0 级重构任务。

## 反思复盘 (2026-04-16)

**PM 评分**: 71/100 (项目整体 74.2，未达 80 阈值)

### 做得好的方面
- 技术债务审计全面覆盖 33 个源文件，发现 boss_ai.gd 重复赋值等潜在 bug
- 量化评分体系自评 72 分，与 PM 评分 71 分接近，说明自我评估较客观
- 测试覆盖达到 467 测试 / 1079 断言，是该项目的核心质量保障

### 需要改进的方面 (基于 PM 反馈)
1. **Autoload 隔离违规是历史遗留问题，未主动修复** -- SaveManager 交叉引用在审计中被识别但仅记录未修复
2. **weapon_fire.gd 约 15 个魔法数字未提取** -- 审计发现后只写入建议，没有实际动手修复
3. **审计多、修复少** -- 本周期产出以分析和记录为主，缺乏实质性代码改进

### 下周期行动项
1. **修复 boss_ai.gd 第 59-60 行 `_charge_timer` 重复赋值** -- 删除多余一行，验证 Boss 第二阶段充能逻辑正常
2. **提取 weapon_fire.gd 全部魔法数字为命名常量** -- 涉及 ~15 处数值，定义为文件顶部 const，确保 lessons-learned 4.2 不再复发
