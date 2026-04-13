# QA测试记录

## 测试概况

| 日期 | 测试数 | 断言数 | 结果 |
|------|--------|--------|------|
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
| **合计** | **394** | **21 个测试文件** |

## 缺陷跟踪

| ID | 严重度 | 模块 | 描述 | 状态 |
|----|--------|------|------|------|
| (暂无) | | | | |

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
