# QA测试记录

## 测试概况

| 日期 | 测试数 | 断言数 | 结果 |
|------|--------|--------|------|
| 2026-04-15 | 467 | 1076 | 39个集成测试全部通过（test_integration.gd 39/39, 167断言） + 427已有测试 427/428 (1个预存失败 test_player_logic test_take_damage_with_armor) |
| 2026-04-12 | 118 | 255 | 全部通过 |
| 2026-04-12 | 118 | 255 | 全部通过（Phase 4 进化系统） |
| 2026-04-12 | 141 | 282 | 全部通过（Phase 5 协同效应） |
| 2026-04-12 | 190 | 500 | 全部通过（Phase 6 商店/存档/任务/成就） |
| 2026-04-12 | 203 | 547 | 全部通过（补充11成就 + 修复 boss_ai class_name） |
| 2026-04-12 | 203 | 544 | 全部通过（难度乘数 + 角色击杀 + HUD完善 + null guard） |
| 2026-04-12 | 203 | 544 | 全部通过（伤害追踪 + 全面难度乘数 + 无尽锁定） |
| 2026-04-12 | 213 | 568 | 全部通过（Boss时间适配难度 + 难度/追踪测试覆盖） |
| 2026-04-13 | 214 | 568 | 全部通过（第18协同 crit_luckycoin + enemy.gd _spawn_food 拆分修复） |
| 2026-04-13 | 236 | 604 | 全部通过（Dash/食物/震动 22 个新测试 + 协同测试 18→24） |
| 2026-04-13 | 236 | 606 | 全部通过（15协同接入 + 连击奖励 + Boss警告 + 进化追踪） |

## 测试文件覆盖

| 文件 | 测试数 | 覆盖模块 |
|------|--------|----------|
| test_arena_screen_shake.gd | 9 | 屏幕震动触发/衰减/信号 |
| test_character_data.gd | 5 | 角色数据定义 |
| test_data_resources.gd | 21 | 武器/敌人数据资源 |
| test_difficulty_data.gd | 5 | 难度数据定义 |
| test_enemy_logic.gd | 22 | 敌人行为/状态效果/Boss |
| test_food_pickup.gd | 6 | 食物掉落/拾取/回血 |
| test_game_manager.gd | 30 | 全局状态/难度乘数/连击 |
| test_player_dash.gd | 7 | Dash 冷却/无敌/速度 |
| test_player_logic.gd | 25 | 玩家伤害/武器/被动/角色 |
| test_projectile.gd | 9 | 投射物/燃烧/减速 |
| test_save_manager.gd | 50 | 存档/商店/任务/成就/历史 |
| test_synergy_manager.gd | 24 | 18种协同检测 |
| test_upgrade_pool.gd | 11 | 升级池/被动/进化选项 |
| test_weapon_evolution.gd | 18 | 进化配方匹配/替换 |
| test_enemy_spawner.gd | 29 | 波次进度/生成间隔/敌人模板/可用类型 |
| test_weapon_fire.gd | 31 | 武器数值缩放/协同加成/回旋镖创建 |
| test_item_crate.gd | 14 | 箱子类型/收集逻辑/概率阈值 |
| test_enemy_bullet.gd | 15 | 弹幕方向/速度/伤害/生命周期 |
| test_boss_ai.gd | 22 | Boss三阶段/充能/螺旋/角度 |
| test_integration.gd | 39 | 全武器开火/被动应用/核心流程/协同/进化/特效回归 |
| test_boomerang.gd | 17 | 回旋镖飞行/返回/属性保持 |
| test_spin_blade.gd | 12 | 旋转刀刃创建/角度/升级缩放 |
| **合计** | **467** | **24 个测试文件** |

## 缺陷跟踪

| ID | 严重度 | 模块 | 描述 | 状态 |
|----|--------|------|------|------|
| (暂无) | | | | |

## 视觉验证记录

### 2026-04-14 ColorRect -> Sprite2D 迁移视觉验证

**方法**：启动 Godot 游戏至 main.tscn，截屏至 `test/screenshots/qa_visual_test.png`

**Godot 引擎输出**：
```
Godot Engine v4.6.stable.official.89cea1439
OpenGL API 4.1 INTEL-18.8.16 - Compatibility - Using Device: Intel Inc. - Intel(R) HD Graphics 6000
```
无运行时错误，无缺失资源警告。

**代码审查验证**：

1. **场景文件迁移确认** -- 全部 6 个游戏实体场景已迁移为 Sprite2D 节点：
   - `scenes/player.tscn`: `[node name="Sprite" type="Sprite2D"]` -- OK
   - `scenes/enemy.tscn`: `[node name="Sprite" type="Sprite2D"]` -- OK
   - `scenes/projectile.tscn`: `[node name="Sprite" type="Sprite2D"]` -- OK
   - `scenes/xp_gem.tscn`: `[node name="Sprite" type="Sprite2D"]` -- OK
   - `scenes/item_crate.tscn`: `[node name="Sprite" type="Sprite2D"]` -- OK
   - `scenes/enemy_bullet.tscn`: `[node name="Sprite" type="Sprite2D"]` -- OK

2. **脚本纹理加载验证**：
   - `scripts/player.gd`: 按 `GameManager.selected_character` 加载 `warrior.png`/`ranger.png`/`mage.png` -- OK
   - `scripts/enemy.gd`: 通过 `enemy_data.enemy_id` 动态加载 `res://assets/sprites/enemies/{id}.png` -- OK
   - `scripts/projectile.gd`: 通过 `weapon_id` 加载 `res://assets/sprites/weapons/{id}.png` -- OK
   - `scripts/xp_gem.gd`: 按 `xp_value` 分级加载 `xp_gem_small/medium/large.png` -- OK
   - `scripts/item_crate.gd`: 按 `crate_type` 加载 `crate_heal/xp/speed.png` -- OK
   - `scripts/enemy_bullet.gd`: 加载 `res://assets/sprites/weapons/enemy_bullet.png` -- OK

3. **像素精灵资源完整性**：
   - `assets/sprites/characters/`: warrior.png, ranger.png, mage.png (3/3)
   - `assets/sprites/enemies/`: bat, boss, elite_skeleton, ghost, skeleton, splitter, splitter_small, zombie (8/8)
   - `assets/sprites/weapons/`: bible, boomerang, enemy_bullet, holy_water, knife (5/5)
   - `assets/sprites/pickups/`: crate_heal, crate_speed, crate_xp, food, xp_gem_small, xp_gem_medium, xp_gem_large (7/7)

4. **残留 ColorRect 检查**：
   - 场景中仅剩 UI 背景用 ColorRect（main/arena/hud/shop 等场景），属正常用途
   - 脚本中仅剩特效用 ColorRect（残影、闪白、角色选择图标），属正常用途
   - 所有游戏实体节点已完成 ColorRect -> Sprite2D 迁移，无遗漏

**结论**：ColorRect -> Sprite2D 迁移完整，428 项单元测试全部通过（910 断言），Godot 引擎启动无错误，所有像素精灵资源文件齐全。

## 测试命令
- `./run_tests.sh` — 运行全部 GUT 测试
- Godot movie capture: `Godot --path . --write-movie /tmp/capture.avi --quit-after 90`
| 2026-04-13 | 236 | 603 | 全部通过（18/18协同全部接入 + 重投系统 + 和平主义者修复 + 击杀归属追踪） |
| 2026-04-13 | 251 | 623 | 全部通过（击杀归属修复 + 15项新测试 + 常量引用修复） |
| 2026-04-13 | 251 | 623 | 全部通过（all_evolved/all_synergies成就检查 + RerollButton UI + proj.weapon_id修复） |
| 2026-04-13 | 251 | 625 | 全部通过（进化追踪 + evolve_weapon/synergy_first成就 + 历史持久化 + RerollButton） |
| 2026-04-13 | 257 | 629 | 全部通过（ProjectileManager/PickupManager null guard + 6项成就/历史测试） |
| 2026-04-13 | 257 | 628 | 全部通过（清理 player.gd 未使用 took_damage 信号） |
| 2026-04-13 | 257 | 628 | 全部通过（weapon_controller 拆分为 116+328 行 + boomerang bug 修复） |
| 2026-04-13 | 288 | 681 | 全部通过（weapon_fire.gd 31项新测试 + 发现并修复 boomerang set_script 属性重置 bug） |
| 2026-04-13 | 317 | 738 | 全部通过（enemy_spawner.gd 29项新测试：波次进度/生成间隔/敌人模板/可用类型） |
| 2026-04-13 | 343 | 768 | 全部通过（xp_gem 16项 + spin_blade 12项新测试，发现并修复 mini→minf float bug） |
| 2026-04-13 | 394 | 823 | 全部通过（SYNERGIES→SYNERGY_DEFINITIONS修复 + _find_player提取 + shop清理 + 3个新测试文件51项） |
| 2026-04-13 | 428 | 909 | 全部通过（weapon_registry 17项 + boomerang 17项新测试，player.gd 20处常量提取） |
| 2026-04-14 | 428 | 910 | 全部通过（ColorRect->Sprite2D像素精灵迁移回归测试 + 视觉验证） |
| 2026-04-15 | 467 | 1079 | 全部通过（覆盖率分析：33源文件中10个无专门测试文件） |
