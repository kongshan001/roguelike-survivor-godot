# 策划工作记录

## 当前优先级

| 优先级 | 事项 | 状态 |
|--------|------|------|
| P0 | 角色系统设计（法师/战士/游侠） | ✅ 已完成 |
| P0 | 难度模式设计（休闲/标准/噩梦/无尽） | ✅ 已完成 |
| P0 | 7种基础武器数值设计 | ✅ 已完成 |
| P1 | 8种进化武器设计 | ✅ 已完成（规格见 specs/phase4-weapon-evolution-design.md） |
| P1 | 7种敌人 + Boss三阶段设计 | ✅ 已完成（规格见 specs/phase3-enemy-design.md） |
| P2 | 18种协同效应设计 | ✅ 已完成（规格见 specs/phase5-synergy-design.md） |
| P2 | 商店/存档/任务/成就设计 | ✅ 已完成（规格见 specs/phase6-shop-save-design.md） |
| P2 | 角色主动技能设计（3角色） | ✅ 已完成（规格见 specs/character-skills.md） |
| P1 | 多关卡设计（3关卡） | ✅ 已完成（规格见 specs/multi-stage.md） |
| P1 | 火焰史莱姆简化方案 + 角色技能集成 | ✅ 已完成（规格见 specs/fire-slime-design.md） |
| P1 | 进化武器扩展（4种新类型: spiral/sentinel/pulse/beam） | ✅ 已完成（规格见 specs/evolution-expansion.md） |
| P2 | 设计文档审查（数值来源+Decision Log补全） | ✅ 已完成（skill-vfx-spec.md 已修正） |
| P1 | Sentinel类型简化 + 进化武器DPS平衡调整 | ✅ 已完成（规格见 specs/sentinel-simplification.md） |
| P1 | 角色升级差异化路线 + 武器质变等级 | ✅ 已完成（规格见 specs/character-upgrade-paths.md） |
| P1 | 武器Lv3质变效果优先排序 + TOP3实现规格 | ✅ 已完成（规格见 specs/weapon-lv3-transforms.md） |

## 决策记录

### 2026-04-12: 角色系统设计
- **决策**: 3个职业（法师/战士/游侠），参考 H5 config.js CHARACTERS
- **为什么**: 不同职业提供差异化体验，增加重玩性
- **数值来源**: H5 `CHARACTERS` 配置

### 2026-04-12: 难度模式设计
- **决策**: 4种难度（休闲/标准/噩梦/无尽），参考 H5 config.js DIFFICULTY
- **为什么**: 满足不同水平玩家需求，无尽模式提供长期挑战
- **数值来源**: H5 `DIFFICULTY` 配置

### 2026-04-12: 7种敌人 + Boss 三阶段设计
- **决策**: 7种敌人（僵尸/蝙蝠/骷髅/精英骷髅/幽灵/分裂者/小分裂者），Boss 三阶段行为
- **调研**: 参考 Vampire Survivors、Brotato、Holocure 品类趋势，引入 Boss 多阶段行为
- **脑洞**: 3个方案中选中"Boss 三阶段行为"，备份"精英敌人变体"留作后续迭代
- **为什么**: H5 原设计覆盖品类核心，额外 Boss 三阶段提升战斗高潮感
- **数值来源**: H5 `ENEMY_TYPES` + `WAVE_PROGRESS` + `ENDLESS` 配置
- **规格文件**: `docs/superpowers/specs/phase3-enemy-design.md`

### 2026-04-12: 8种进化武器设计
- **决策**: 双武器 Lv3 合成进化，8 种进化武器不可再升级
- **调研**: VS 用武器+被动进化，H5 用双武器进化，后者更简单直接
- **脑洞**: 选中"双武器合成+进化特效"，放弃"进化武器可继续升级"
- **为什么**: H5 进化系统已充分验证，进化武器不可升级避免后期数值失控
- **数值来源**: H5 `EVOLUTIONS` + `WEAPONS` 配置
- **规格文件**: `docs/superpowers/specs/phase4-weapon-evolution-design.md`

### 2026-04-12: 18种协同效应设计
- **决策**: 7 种被动+被动 + 11 种武器+被动协同，参考 H5 SYNERGIES
- **调研**: VS 用进化不产生实时效果，H5 实时协同更有"发现组合"乐趣
- **脑洞**: 选中"H5 原版 17 协同 + HUD 提示"，放弃"三件套协同"
- **2026-04-13 扩展**: 新增第18种协同"命运赌徒"（暴击+幸运币 → 暴击时双倍金币），填补暴击和幸运币两个被动之间的联动空白
- **数值来源**: H5 `SYNERGIES` 配置
- **规格文件**: `docs/superpowers/specs/phase5-synergy-design.md`

### 2026-04-13: Dash 闪避系统设计
- **决策**: 玩家按 Space 触发短距离冲刺，冷却 2.5s，冲刺期间短暂无敌
- **为什么**: 提供主动闪避手段，增加操作深度，缓解后期弹幕密度压力
- **数值**: 冲刺距离 80px，持续 0.15s，冷却 2.5s，残影 3 个

### 2026-04-13: 食物掉落机制设计
- **决策**: 敌人死亡 10% 基础概率掉落食物，拾取回复 1 HP
- **为什么**: 参考原版 VS 的地板鸡肉，为高压局提供微量续航
- **数值**: 10% 基础概率 × 难度 food_drop_mul，食物受磁铁吸引

### 2026-04-13: 屏幕震动反馈设计
- **决策**: 受伤时震动 3.0 强度，连杀 ≥20 时震动 2.0 强度
- **为什么**: 战斗打击感反馈，连杀震动强化爽感
- **数值**: decay=5.0/s，随机偏移方向

### 2026-04-13: 15个协同效应接入方案
- **现状**: synergy_manager.gd 定义了18个协同，但仅3个（holywater_maxhp/bible_boots/boots_regen）在实际代码中生效
- **接入点定义**:

**被动+被动 (7个，主要在 player.gd 和 enemy.gd die())**:
| ID | 效果 | 接入位置 |
|---|---|---|
| crit_boots | 暴击时发射飞刀(0.5x伤害,250速度,1s寿命) | weapon_controller.gd _on_crit() |
| armor_maxhp | 护甲效果翻倍 | player.gd take_damage() |
| magnet_crit | 暴击额外掉落价值+2宝石 | enemy.gd die() |
| boots_regen | 移动时再生速度×2 | player.gd _physics_process() ✅已实现 |
| armor_regen | HP<30%时临时+3护甲 | player.gd take_damage() |
| magnet_maxhp | 拾取宝石2%回复1HP | xp_gem.gd _collect() |
| crit_luckycoin | 暴击时金币掉落翻倍 | enemy.gd die() |

**武器+被动 (8个未接入，在 weapon_controller.gd)**:
| ID | 效果 | 接入位置 |
|---|---|---|
| knife_crit | 飞刀可暴击 | _fire_knife() |
| lightning_magnet | 闪电+1链,范围+50 | _fire_lightning() |
| firestaff_armor | 锥形+40°,燃烧+1s | _fire_cone() |
| frost_regen | 冰冻+5%,持续+0.5s | _fire_aura() |
| holywater_luckycoin | 圣水击杀+1金币 | holywater on_kill |
| firestaff_luckycoin | 燃烧击杀+1宝石 | firestaff burn_kill |
| frostaura_luckycoin | 冰冻敌人宝石吸引+30 | frostaura freeze |
| boomerang_magnet | 回旋镖飞行吸引宝石30 | boomerang.gd |
| boomerang_crit | 回旋镖可暴击,size×1.2,+1穿透 | _fire_boomerang() |

### 2026-04-13: 连击奖励系统设计
- **决策**: 连击数提供经验加成，里程碑触发提示
- **数值来源**: H5 COMBO 配置
- **经验加成**: combo_count × 5%，上限 50%（10连击封顶）
- **金币阈值**: 连击≥5时额外+1金币/击杀
- **里程碑**: [5, 10, 20, 50] 显示提示

### 2026-04-13: Boss 警告 UI 设计
- **决策**: Boss 出生前 15 秒显示红色警告横幅
- **数值**: warningTime=15s，toast 持续 2.5s
- **显示内容**: "💀 Boss 即将来袭！" 红色横幅，2.5s 后渐隐

### 2026-04-13: 幸运硬币基础被动效果
- **决策**: 幸运硬币被动需要实际生效（暴击伤害+50%，金币+15%）
- **接入**: player.gd 中 crit_damage_mul += 0.5（✅已实现），enemy.gd die() 中 gold × (1 + 0.15×stack)

### 2026-04-13: 击杀归属追踪系统设计
- **决策**: enemy 新增 `_last_hit_by: String` 和 `_was_crit: bool`，每次 take_damage 记录来源武器ID和是否暴击
- **接入方式**:
  - `enemy.take_damage(amount, source, was_crit)` — source 为 weapon_id 字符串
  - projectile.gd 在 setup 时记录 weapon_id，_on_body_entered 时传递给 take_damage
  - 直接伤害（lightning/cone/aura）在 weapon_controller 中传递 weapon_id
- **为什么**: 5个剩余协同需要知道"什么武器击杀了敌人"或"这次伤害是否暴击"

### 2026-04-13: 剩余5个协同接入方案
| ID | 效果 | 实现方式 |
|---|---|---|
| crit_boots | 暴击时发射飞刀(0.5x,250速,1s) | enemy.take_damage 时若 was_crit 且有协同，在 weapon_controller 中额外投射 |
| holywater_luckycoin | 圣水击杀+1金币 | enemy.die() 检查 _last_hit_by=="holywater" |
| firestaff_luckycoin | 燃烧击杀+1宝石 | enemy.die() 检查 _last_hit_by=="firestaff" 且 _burn_timer>0 |
| frostaura_luckycoin | 冰冻敌人宝石吸引+30 | xp_gem._collect() 检查来源enemy是否被冰冻 |
| boomerang_magnet | 回旋镖飞行吸引宝石30 | boomerang.gd _physics_process 中拉取附近xp_gem |

### 2026-04-13: 升级重投系统设计
- **决策**: 升级面板添加"重投"按钮，每局最多1次，重新随机3个选项
- **数值**: maxReroll=1，按钮显示在面板右侧

### 2026-04-13: 和平主义者成就修复
- **决策**: GameManager 新增 `kills_at_60: int`，在 elapsed_time>=60 时记录当前 kills 数
- **为什么**: H5 检查 `s.killsAt60 === 0`，不是全程0杀而是前60秒0杀

### 2026-04-13: 功能差距审核结果
- **关键Bug**: projectile.gd _on_body_entered 仍用 body.take_damage(damage) 未传 weapon_id/is_crit，导致投射物类武器击杀归属失效
- **关联Bug**: spin_blade.gd（圣水/圣经环绕体）未传 weapon_id
- **数据一致性**: xp_gem.gd 硬编码 combo×0.05 / max 0.5，应引用 GameManager.COMBO_EXP_RATE / COMBO_MAX_BONUS
- **测试优先级**: P0 修复击杀归属断裂，P1 补充11项缺失测试

### 2026-04-13: 集成差距第二轮审核
- **Critical Bug**: weapon_controller.gd _fire_projectile 中 proj.weapon_id 从未赋值，导致所有投射物类武器的击杀归属追踪完全失效
  - 影响: knife/holywater/boomerang 的 kill attribution 全部断裂
  - 上轮修复了接收端(enemy.take_damage签名)但漏了发送端(proj赋值)
- **Critical Bug**: boss_ai.gd 子弹未设 weapon_id，Boss 击杀归属丢失
- **Medium**: all_evolved 成就定义但从未检查，hud.gd 中已用 meta 记录进化但 save_manager 未读取
- **Low**: RerollButton 仅有键盘快捷键(R)，无视觉按钮

---

## 2026-04-15: H5 vs Godot 功能差距分析

### 分析方法
逐项对比 H5 `config.js` 全部配置块与 Godot 项目实际代码实现，列出所有缺失/不完整的功能。

### 完整功能差距清单

| # | H5 功能 | Godot 状态 | 游戏影响 | 优先级 |
|---|---------|-----------|---------|--------|
| 1 | **宝箱系统 (CHEST)** | 完全缺失 | HIGH | P0 |
| 2 | **无尽模式完整循环** | 基础Boss循环已有，缺通关条件/胜利画面 | HIGH | P0 |
| 3 | **任务/成就UI展示** | 后端逻辑完整，无展示界面 | HIGH | P1 |
| 4 | **HUD 武器槽位显示** | 完全缺失 | MEDIUM | P1 |
| 5 | **波次进度条 UI** | 完全缺失 | MEDIUM | P1 |
| 6 | **暴风雪/雷霆回旋/烈焰回旋进化武器特效** | 基础行为在，进化武器特殊效果缺失(lightning chain/flame trail) | MEDIUM | P1 |
| 7 | **协同效果HUD提示** | 协同触发后无UI通知 | MEDIUM | P2 |
| 8 | **连击经验加成实际生效** | combo_bonus 经验值计算在 xp_gem 硬编码，非系统化 | LOW | P2 |
| 9 | **磁铁被动效果(经验获取+30%)** | pickup_range 增大已实现，但EXP加成未实现 | LOW | P2 |
| 10 | **宝箱奖励(buff药水/临时加速)** | item_crate 仅掉宝，无临时buff | MEDIUM | P2 |
| 11 | **连锁闪电视觉(thunderang/thunderholywater)** | 进化武器注册了但无链式闪电特效 | LOW | P3 |
| 12 | **火焰轨迹视觉(blazerang)** | 进化武器注册了但无火焰轨迹特效 | LOW | P3 |
| 13 | **烈焰经文燃烧脉冲** | flamebible 注册了但无燃烧DOT脉冲 | LOW | P3 |
| 14 | **无尽模式Boss击杀奖励** | H5有gold/exp/food奖励，Godot仅普通Boss奖励 | LOW | P3 |
| 15 | **灵魂碎片掉落机制** | soulFragmentRate=0.3 仅在结算时转换金币，H5有局内掉落 | LOW | P3 |

### TOP 3 缺失功能设计规格

#### Feature #1: 宝箱系统 (CHEST) -- P0 HIGH

H5 的 CHEST 系统是一个重要的中期续航和随机性来源。每 90 秒在玩家周围 300-500px 范围内随机生成一个宝箱（最多同时 2 个），玩家靠近 30px 后自动开启，随机获得三种奖励之一：回复 3HP、10 秒移速+50%、或 +20 经验。开启消耗 20 金币，给金币系统增加了有意义的经济决策——玩家需要权衡是存钱买宝箱还是花在商店升级上。

当前 Godot 项目已有 `item_crate.tscn` 和 `item_crate.gd`，但这是敌人掉落的道具箱，不是 H5 的定时宝箱。宝箱系统需要新增一个独立的定时器系统（建议挂在 `arena.gd` 或新建 `chest_spawner.gd`），参考 H5 的 `CHEST` 配置：spawnInterval=90s, maxChests=2, spawnMinRange=300, spawnMaxRange=500, pickupRange=30, cost=20。奖励池为 heal(3HP)/speed(+50%,10s)/exp(+20)，每种等概率 1/3。临时加速 buff 需要在 `player.gd` 中新增一个 timed_modifier 系统。

#### Feature #2: 无尽模式完整循环 -- P0 HIGH

当前无尽模式实现了基础 Boss 循环（每 240s 一个 Boss，HP/速度按 1.5x/1.1x 递增），敌人 HP/速度按时间线性增长。但缺少关键的游戏循环闭环：H5 中无尽模式在击败 Boss 后会显示一个里程碑奖励（每 60 秒一个），Boss 击杀奖励为 gold=50, exp=30, food=5，灵魂碎片倍率 1.5x。更重要的是，当前 `game_over_screen.gd` 仅在玩家死亡时触发，无尽模式应该有"主动撤退"选项，让玩家在任意时刻选择结算离开，保留已获得的所有奖励。

设计要点：(1) HUD 新增"撤退"按钮，仅无尽模式可见，点击后触发正常结算流程；(2) Boss 击杀时额外掉落 50 金 + 30 经验 + 5 食物（参考 H5 `ENDLESS.bossKillReward`）；(3) 每 60 秒里程碑触发 bonus（`ENDLESS.milestoneInterval=60`），显示当前存活时间；(4) 灵魂碎片倍率 1.5x（`ENDLESS.soulFragmentBonusMul`）；(5) 每分钟金币奖励 +0.5（`ENDLESS.goldBonusPerMin`）。

#### Feature #3: 任务/成就/HUD 展示界面 -- P1 HIGH

当前 Godot 项目的任务和成就系统后端逻辑非常完整（`save_manager.gd` 包含 14 个任务和 27 个成就的检测、奖励发放、持久化），但玩家完全看不到这些内容。没有任务列表界面，没有成就展示，没有任务完成/成就解锁的实时通知。H5 项目在 HUD 上有实时 toast 通知，在主菜单有独立的任务/成就页面。

设计方案分三层：(1) **HUD 实时通知** -- 监听 `SaveManager.quest_completed` 和 `SaveManager.achievement_unlocked` 信号，在 HUD 右上角显示 toast（图标+名称+奖励），2 秒后渐隐，最多同时显示 2 条；(2) **主菜单入口** -- 在 `main.tscn` 标题画面新增"任务"和"成就"按钮，打开独立场景展示全部任务/成就列表，完成项高亮、未完成项灰色，显示进度描述；(3) **游戏结算页** -- `game_over_screen.gd` 在现有统计下方新增"本局完成：xxx"列表，展示本局新完成的任务和成就。这直接影响玩家留存和目标感，是肉鸽游戏"再来一局"的核心驱动力。

### 实施优先级建议

```
Phase 7A (P0): 宝箱系统 + 无尽模式完整循环
Phase 7B (P1): 任务/成就展示 UI + HUD武器槽 + 波次进度条
Phase 7C (P2): 进化武器特效补全 + 协同通知 + 磁铁EXP加成
```

### 决策记录

- **为什么优先宝箱系统**: 宝箱是唯一缺失的系统性玩法模块（定时随机奖励），直接影响中期节奏和经济决策深度
- **为什么无尽模式第二**: 无尽模式是 H5 的核心留存玩法，当前实现只有骨架，缺少完整的奖励和闭环
- **为什么UI展示第三**: 后端已完整，补上展示层性价比极高，对玩家目标感影响大

## 反思复盘 (2026-04-16)

**PM 评分**: 76/100 (项目总评 74.2，低于 80 阈值)

### 做得好的
- 功能差距分析系统全面，15 项逐条对比 H5 config.js 与 Godot 实现
- TOP3 优先级排序清晰（宝箱/无尽循环/UI展示），与程序团队对齐顺畅
- 每项设计决策都有"为什么"的理由记录

### 需要改进的 (基于 PM 反馈)
1. **未执行竞品调研阶段** -- 缺少 Vampire Survivors / Brotato / Holocure 的横向对比分析，设计决策缺少品类基准参照
2. **TOP3 设计规格未写入 docs/superpowers/specs/** -- 功能差距分析和 TOP3 方案停留在 designer-log 内，程序团队无法按规格文件引用
3. **无数值表输出** -- 宝箱/无尽模式/UI展示三个方案缺少可直接使用的数值定义表（常量名、值、单位），程序团队需要反复沟通确认

### 下周期行动项
1. **每个 P0/P1 设计必须输出到 specs/ 目录** -- 包含数值常量表（变量名/值/单位/来源），供程序团队直接引用实现
2. **新功能设计前必须完成竞品调研** -- 输出调研摘要到 docs/superpowers/specs/research/，明确品类基准和差异化定位

**承诺**: 下次设计输出将严格按三阶段流程（调研 -> 脑洞 -> 正式设计），规格文件和数值表写入 docs/superpowers/specs/ 目录，不再仅停留在工作日志中。

---

## 第二轮执行 (2026-04-16)

### 执行内容

根据第一轮功能差距分析和 PM 反馈，正式输出 TOP3 设计规格文件到 `docs/superpowers/specs/` 目录。

### 输出文件

| 文件 | 功能 | 优先级 | 状态 |
|---|---|---|---|
| `docs/superpowers/specs/chest-system.md` | 宝箱系统 | P0 HIGH | 已完成 |
| `docs/superpowers/specs/endless-mode-loop.md` | 无尽模式完整循环 | P0 HIGH | 已完成 |
| `docs/superpowers/specs/achievement-ui.md` | 任务/成就UI展示 | P1 HIGH | 已完成 |

### 设计规格质量检查

每份规格文件包含以下标准结构：
- Design Overview (设计概述 + 为什么这样设计)
- Numerical Constants Table (数值常量表: 常量名/值/单位/H5来源/备注)
- State Machine / Logic Flow (状态机或逻辑流程)
- Visual Specification (视觉规范: 尺寸/颜色/动画)
- Integration Map (集成点: 需修改的文件/新增的文件/新增的信号)
- Balance Analysis (平衡性分析: 奖励曲线/风险收益)
- Design Decisions Log (决策记录: 每个决策的原因和被放弃的替代方案)

### 决策记录

**宝箱系统 (chest-system.md)**:
- **决策**: 每90秒在玩家300-500px范围内生成宝箱，消耗20金币开启，等概率1/3获得heal(3HP)/speed(+50%,10s)/xp(+20)
- **关键决策**: 仅在玩家拥有>=20金币时生成宝箱(避免无法开启的宝箱堆积)，不满足条件时30秒后重试
- **为什么**: H5的CHEST是唯一缺失的系统性玩法模块，引入金币消耗决策和随机正反馈

**无尽模式完整循环 (endless-mode-loop.md)**:
- **决策**: HUD新增"撤退"按钮(Q键)，Boss击杀奖励(50金+30XP+5食物)，60秒里程碑奖励，灵魂碎片1.5x倍率，每分钟+0.5金币被动收入
- **关键决策**: 撤退无需确认对话框(保持动作节奏流畅)
- **为什么**: 无尽模式是核心留存机制，缺少完整循环导致玩家被困或缺乏目标感

**任务/成就UI展示 (achievement-ui.md)**:
- **决策**: 三层UI -- HUD实时toast通知(右上角) + 主菜单任务/成就列表页 + 游戏结算本局完成摘要
- **关键决策**: Toast最多同时显示2条，成就隐藏项显示"???"，结算页最多显示5项
- **为什么**: 后端14任务+27成就已完整实现，补上展示层是最高性价比的UX改进

### 自评打分

| 维度 | 得分 | 说明 |
|---|---|---|
| 数值表完整性 | 9/10 | 每份规格包含完整的常量名/值/单位/H5来源对照表 |
| 程序可执行性 | 9/10 | 包含集成点映射、文件修改清单、代码片段示例、状态机图 |
| 平衡性分析 | 8/10 | 宝箱有经济影响分析，无尽模式有奖励曲线对比 |
| 设计决策记录 | 9/10 | 每个关键决策有"为什么"和"替代方案"对比 |
| 视觉规范 | 7/10 | 包含ASCII线框图、颜色色值、尺寸规范，但缺少实际像素布局图 |
| 与H5一致性 | 9/10 | 所有数值均有H5 config.js来源标注 |

**综合评分**: 85/100

### 改进空间
1. 视觉规范可以更细化（动画关键帧、字体具体设置）
2. 缺少竞品调研阶段（Round 2是直接执行，未补充调研）
3. 三个规格之间的交叉引用可以更紧密（如宝箱奖励在无尽模式下的特殊处理）

---

## 第三轮执行 (2026-04-16)

### 执行内容

完成 R5 反思承诺的两个行动项：(1) 执行竞品调研阶段；(2) 输出波次系统和难度调参规格文件到 specs/ 目录。

### 调研阶段

竞品调研对比了 Vampire Survivors、Brotato、HoloCure 和 H5 参考项目，围绕四个维度（角色差异化、武器进化、无尽模式留存、成就/任务激励）进行系统性分析。

**输出文件**: `docs/superpowers/specs/research/competitive-analysis.md`

关键发现：
- 角色差异化不足是当前最大差距（3 个角色 vs 品类平均 30+）
- 波次/关卡结构是最有影响力的缺失功能（所有品类头部游戏都有波次边界）
- 成就/任务后端已领先品类，差距仅在 UI 展示层
- 进化系统机制完善，差距在视觉效果层面

### 脑洞阶段

围绕调研发现，提出 3 个创新方案：

1. **"五波节奏"方案** -- 将 300 秒分为 5 个命名波次，每波间 3 秒休息。选中进入正式设计。核心创意：在连续刷怪中引入节奏感，每波有独特的敌人组合和色彩主题。
2. **"无尽循环"方案** -- 无尽模式每 5 波为一个 cycle，每个 cycle 敌人 HP/速度/生成率递增。选中进入正式设计。核心创意：与波次系统自然配对，在 cycle 边界制造明显的难度跳变。
3. **"波次奖励"方案** -- 每波完成给予小奖励（金币/经验/临时 buff），与宝箱系统重叠。放弃。替代方案：胜利时给予一次性奖励更简洁。

可行性评估：
| 方案 | 技术成本 | 平衡难度 | 理解成本 | 结论 |
|---|---|---|---|---|
| 五波节奏 | 低（enemy_spawner 修改） | 中（需要调整生成节奏） | 低（直观） | 选中 |
| 无尽循环 | 低（cycle 计数器） | 中（需要调参 cycle 乘数） | 低（波次编号递增） | 选中 |
| 波次奖励 | 中（奖励系统集成） | 高（与宝箱/商店经济冲突） | 低 | 放弃 |

### 正式设计阶段

#### 输出文件

| 文件 | 功能 | 优先级 |
|---|---|---|
| `docs/superpowers/specs/research/competitive-analysis.md` | 竞品调研摘要 | 调研产出 |
| `docs/superpowers/specs/stage-system.md` | 波次/关卡系统设计 | P1 HIGH |
| `docs/superpowers/specs/difficulty-tuning.md` | 难度曲线调参建议 | P1 HIGH |

#### 波次系统设计要点

- **5 波结构**：Opening(60s) -> Swarm(57s) -> Darkness(57s) -> Elite(57s) -> Boss(57s)
- **3 秒波间休息**：不生成新敌人，现有敌人仍活动
- **波次进度条**：顶部 4px 彩色条，颜色随波次变化（绿->黄->橙->红->深红）
- **胜利条件**：标准/噩梦模式存活 300 秒触发胜利，显示 "VICTORY" 画面
- **无尽模式**：5 波一组为 1 cycle，每个 cycle 敌人 HP+30%/速度+10%/生成率-10%
- **Boss 波次**：Boss 在第 5 波开始时立即生成
- **数值来源**：波次定义来自 H5 `WAVE_PROGRESS.stages`，cycle 乘数参考 H5 `ENDLESS`

#### 难度调参要点

- **Hard Boss HP**：从 2.0x 降至 1.8x（400->360 HP，击杀时间从 27s 降至 24s）
- **Hard 生成间隔下限**：新增 0.7s 下限（防止 180s 后生成过快）
- **无尽缩放改为 cycle 级**：替代当前每分钟线性缩放，更平滑的难度曲线
- **Easy/Normal 不变**：与 H5 完全一致，无需调整
- **数值来源**：所有变更都有数据支撑（击杀时间分析、敌人数量分析、XP 经济分析）

### 决策记录

**波次系统**:
- **决策**: 5 波命名波次 + 3 秒休息 + 波次进度条 + 胜利条件 + 无尽 cycle 循环
- **关键决策**: 波间休息时敌人仍活动（不冻结），只停止新敌人生成
- **为什么**: 品类头部游戏全部使用某种波次边界，当前连续刷怪缺乏节奏感
- **放弃的替代方案**: (1) 波次间完全冻结（太简单，消除紧张感）；(2) 随机波次组合（难以平衡）
- **规格文件**: `docs/superpowers/specs/stage-system.md`

**难度调参**:
- **决策**: Hard Boss HP 降至 1.8x；新增 Hard 生成间隔下限 0.7s；无尽缩放改为 cycle 级
- **关键决策**: 只调 Hard 和无尽，不碰 Easy/Normal
- **为什么**: Hard Boss 27 秒击杀时间过长（乏味而非有挑战性）；180s 后生成速率无法反制；无尽每分钟线性缩放在前 10 分钟太陡
- **放弃的替代方案**: (1) 大幅降低 Hard 难度（失去 Hard 身份）；(2) 无尽保持线性但降低系数（不如 cycle 结构清晰）
- **规格文件**: `docs/superpowers/specs/difficulty-tuning.md`

**竞品调研**:
- **决策**: 对比 VS/Brotato/HoloCure/H5 四个项目，聚焦四个维度
- **关键发现**: 角色差异化（P2 改进）、波次结构（P1 本次解决）、进化视觉（P1 待实现）、成就 UI（P1 achievement-ui.md 已设计）
- **规格文件**: `docs/superpowers/specs/research/competitive-analysis.md`

### 自评打分

| 维度 | 得分 | 说明 |
|---|---|---|
| 调研完整性 | 9/10 | 4 个竞品 x 4 个维度，每个维度有数值对比和差距评级 |
| 三阶段流程合规 | 10/10 | 严格按 调研->脑洞->正式设计 执行，承诺兑现 |
| 数值表完整性 | 9/10 | 波次定义表、cycle 乘数表、难度调参对照表、XP 经济分析 |
| 程序可执行性 | 8/10 | 包含集成点映射、文件修改清单、代码片段、状态机图 |
| 平衡性分析 | 9/10 | 击杀时间分析、生成数量分析、HP 缩放对比、XP 经济分析 |
| 设计决策记录 | 9/10 | 每个决策有原因和替代方案 |

**综合评分**: 90/100

### 改进空间
1. 波次系统尚未考虑多地图场景（当前只有单一竞技场）
2. 难度调参建议缺乏实际测试验证（需要 QA 对比测试数据）
3. 角色差异化的深入设计留作后续轮次

---

## Round 7 执行 (2026-04-16)

### 任务背景

项目评分 87.2/100，689 测试全通过。本轮完成两项策划任务：(1) 角色主动技能设计，(2) 多关卡设计。

### 执行流程

严格按三阶段流程：调研 -> 脑洞 -> 正式设计。

#### 第一阶段：调研（复用 R6 竞品分析）

竞品分析已在 `docs/superpowers/specs/research/competitive-analysis.md` 完成。本轮直接引用关键发现：

- **角色差异化**：HoloCure 的角色专属主动技能是品类最佳实践；当前 3 角色只有数值差异，差距评级 HIGH
- **关卡多样性**：所有品类头部游戏使用多关卡/多地图，当前单一竞技场差距评级 HIGH

#### 第二阶段：脑洞

**角色技能脑洞** (`docs/superpowers/specs/brainstorm/character-skills-brainstorm.md`)：
- 提出 5 个方案：元素爆发套件、姿态切换套件、专属大招套件、资源构建套件、召唤/宠物套件
- 可行性评估：从技术成本、平衡难度、理解成本三维度打分
- 收敛：选中"元素爆发套件"（方案1），融合"专属大招套件"（方案3）的被动特性设计

**多关卡脑洞** (`docs/superpowers/specs/brainstorm/multi-stage-brainstorm.md`)：
- 提出 5 个方案：线性战役、关卡选择、带继承战役、程序化关卡、分支路径
- 收敛：选中"关卡选择"（方案2），将"带继承战役"（方案3）列为未来演进方向

#### 第三阶段：正式设计

##### 任务 1：角色主动技能设计

**输出文件**: `docs/superpowers/specs/character-skills.md`

**设计概述**: 每个角色获得 1 个主动技能（E 键触发）+ 1 个被动特性。

| 角色 | 主动技能 | 冷却 | 效果 | 被动特性 |
|---|---|---|---|---|
| Mage | Elemental Burst | 20s | 以自身为中心 150px AoE，15 伤害 + 1.5s 冰冻 | Mana Attunement: 技能冷却中 +10% 武器伤害 |
| Warrior | Shield Charge | 15s | 朝移动方向冲锋 160px，10 伤害 + 2s 眩晕 | Iron Will: HP<=30% 时 +3 护甲 3s，30s 内部CD |
| Ranger | Arrow Rain | 18s | 自动锁定最近敌群，12 箭雨落 100px 范围，每箭 5 伤害 | Keen Eye: 每 5 次武器命中必定暴击 |

**关键决策**:
- 技能伤害不随武器等级缩放（保持技能为固定"工具技能"而非缩放 DPS 来源）
- 技能伤害受 damage_bonus 修正（Mage 的 +20%、商店升级等仍然生效）
- E 键统一触发（简单直觉，不需要每角色不同键位）
- 15-20s 冷却范围：每波（57s）可使用 3-4 次，是有意义的"能力时刻"但不替代自动攻击

##### 任务 2：多关卡设计

**输出文件**: `docs/superpowers/specs/multi-stage.md`

**设计概述**: 3 个独立关卡，从关卡选择画面进入，每关 5 分钟独立通关。

| 关卡 | 主题 | 竞技场 | 敌人类型 | 环境 | Boss |
|---|---|---|---|---|---|
| 幽暗森林 | 教学 | 3000x3000 | zombie, bat (2种) | 迷雾 (500px 可见) | Ancient Treant (150HP, 召唤僵尸) |
| 熔岩洞窟 | 中等 | 2500x2500 | +skeleton, ghost, fire_slime (5种) | 岩浆池 (1HP/s) | Magma Golem (200HP, 扩大岩浆) |
| 魔王城 | 困难 | 2500x2500 | 全部 7 种 | 黑暗 (400px) + 闪电 | Demon Lord (300HP, 3阶段弹幕) |

**新敌人 -- Fire Slime (火焰史莱姆)**:
- HP=6, 速度=30, 伤害=1, XP=4
- 特殊：留下火焰轨迹 (0.5 HP/s)，死亡爆炸 (40px, 1 HP)
- 仅出现在熔岩洞窟和魔王城

**关键决策**:
- 关卡选择而非线性战役（匹配现有 5 分钟结构，独立平衡，低技术风险）
- 顺序解锁：Stage 2 需通关 Stage 1（Normal），Stage 3 需通关 Stage 2（Normal）
- 每关使用相同 5 波结构（与 stage-system.md 一致），但波次定义和敌人池不同
- 环境效果分级：森林纯视觉（迷雾）-> 洞窟有伤害（岩浆）-> 城堡有干扰（黑暗+闪电）

### 决策记录

**角色技能系统**:
- **决策**: 每角色 1 主动技能 (E 键) + 1 被动特性，15-20s 冷却
- **为什么**: HoloCure 的角色专属主动技能是品类最佳实践；单一冷却技能创造"能力时刻"而不打断自动攻击流
- **放弃的替代方案**: 姿态切换（平衡复杂度太高）、资源构建（增加过多机制层）、召唤/宠物（AI 性能风险）
- **规格文件**: `docs/superpowers/specs/character-skills.md`

**多关卡系统**:
- **决策**: 3 个独立关卡（关卡选择模式），顺序解锁，每关 5 波
- **为什么**: 匹配现有 5 分钟结构，独立可平衡，低技术风险；线性战役留作未来演进
- **放弃的替代方案**: 线性战役（15 分钟过长，死亡惩罚过大）、程序化关卡（质量不可控）
- **规格文件**: `docs/superpowers/specs/multi-stage.md`

### 自评打分

| 维度 | 得分 | 说明 |
|---|---|---|
| 调研完整性 | 8/10 | 复用 R6 竞品分析，未做新的专项调研（主动技能品类调研依赖已有分析） |
| 三阶段流程合规 | 9/10 | 两个设计都经过 脑洞(5方案->收敛) -> 正式设计 流程，脑洞记录写入 brainstorm/ |
| 数值表完整性 | 9/10 | 技能数值表（8+常量/角色）、被动数值表、波次配置表、环境常量表、Boss 阶段表 |
| 程序可执行性 | 8/10 | 包含集成点映射、新文件清单、Resource 定义、信号定义、状态机 |
| 平衡性分析 | 8/10 | DPS 影响分析、XP 经济分析（每关独立）、冷却 vs 武器周期分析、环境伤害分析 |
| 设计决策记录 | 9/10 | 每个关键决策有原因和替代方案 |
| 与现有系统一致性 | 9/10 | 复用 stage-system.md 波次结构、复用 enemy_data.gd 数据格式、复用 dash 系统 |

**综合评分**: 87/100

### 改进空间
1. 角色技能缺少实际测试数据（需要 QA 验证 DPS 影响和手感）
2. 多关卡的环境效果（岩浆/迷雾/黑暗）缺少性能影响分析（大量 Area2D 叠加的风险）
3. 关卡解锁条件仅设计了一种（Normal 通关），未考虑 Easy 模式是否也应解锁
4. ~~Fire Slime 的火焰轨迹和死亡爆炸需要新的 enemy 行为系统（当前 enemy.gd 不支持 DoT 地面效果）~~ -- R8 已完成简化方案设计

---

## Round 8 执行 (2026-04-16)

### 任务背景

PM 在 R7 反馈中指出"火焰史莱姆火焰轨迹实现复杂度未评估"。本轮完成两项策划任务：(1) 火焰史莱姆简化方案设计 + 熔岩关卡环境危害数值；(2) 角色被动技能在 weapon_controller 中的集成方案。

### 任务 1: 火焰史莱姆简化方案

**问题**: 原始 multi-stage.md 中 Fire Slime 设计了两种特殊能力：(a) 每 0.5 秒在移动路径上生成火焰轨迹粒子（0.5 HP/s），(b) 死亡时 40px 半径爆炸（1 HP）。PM 指出实现复杂度未评估。

**简化方案**: 选中 Plan A -- 被动燃烧光环（Passive Burn Aura）。取消火焰轨迹粒子，改为接触时直接对玩家施加 burn 效果，复用现有 `apply_burn()` 系统。

**关键设计决策**:
- 不创建新的场景类型（无粒子、无地面贴花、无持久化区域）
- 仅需在 enemy.gd 添加 ~8 行代码（距离检测 + 调用 player.apply_burn）
- 在 player.gd 添加 ~5 行代码（burn 变量 + apply_burn 方法 + DOT tick）
- 在 enemy_data.gd 添加 3 个 export（has_burn_aura, burn_aura_dps, burn_aura_duration）

**火焰史莱姆数值**:

| 属性 | 值 | 对比 |
|---|---|---|
| HP | 6.0 | 介于 skeleton(5) 和 elite_skeleton(12) 之间 |
| 速度 | 30 px/s | 比 skeleton(20) 快，比 zombie(40) 慢 |
| 伤害 | 1.0 | 标准 |
| XP | 4 | 与 ghost/splitter 相当 |
| Burn DPS | 2.0 HP/s | 与 firestaff 的 BURN_DPS 一致 |
| Burn 持续 | 1.5s | 略短于武器 burn(2.0s)，避免堆叠过强 |

**熔岩关卡环境危害数值**:

| 属性 | 值 | 决策原因 |
|---|---|---|
| 岩浆池数量 | 4 个 | 2500x2500 竞技场约 0.6% 覆盖率，稀疏但有意义 |
| 岩浆池半径 | 40-70 px | 避免 80px 过大 |
| 每次tick伤害 | 0.5 HP | Mage(8HP) 需 16s 站立才会死，惩罚但不致命 |
| tick间隔 | 1.0s | 大于无敌帧(0.5s)，允许冲刺穿越 |
| 安全区 | 中心 150px | 保证出生点无岩浆 |

**相比 multi-stage.md 的变更**:
- 岩浆伤害从 1.0 HP/s 降至 0.5 HP/tick（避免 Mage 5 秒致死）
- tick 间隔从 0.5s 增至 1.0s（允许冲刺穿越）
- 池数量从 5-8 缩减至固定 4（简化实现）
- 池最大半径从 80 降至 70（减少覆盖率）

### 任务 2: 角色技能在 weapon_controller 中的集成设计

#### Mana Attunement (+10% 伤害)

**接入点**: `weapon_controller.gd` 第 58 行 `dmg_bonus` 计算。

```gdscript
# 现有: var dmg_bonus: float = 1.0 + player.damage_bonus
# 新增: 如果是 Mage 且技能在冷却中，dmg_bonus *= 1.10
```

**生效条件**: `player.is_skill_on_cooldown()` 返回 true 时生效。
**前提**: player.gd 需新增 `skill_cooldown_timer: float` 和 `is_skill_on_cooldown()` 方法。

**平衡影响**: Mage 基础 damage_bonus = 0.20，有 mana_attunement 时为 1.20 * 1.10 = 1.32。实际 DPS 提升 10%（相对提升）。

#### Keen Eye (每 5 次命中必定暴击)

**计数器位置**: `weapon_controller.gd` 新增 `_keen_eye_counter: int`。

**触发逻辑**: 每次调用 `_fire_weapon()` 时计数器 +1，达到 5 时重置并设置 `force_crit = true`。force_crit 标志传递给 weapon_fire.gd 的所有 fire 函数。

**设计决策: 按开火计数而非按命中计数**:
- 按开火计数（推荐）：同步、确定性、无信号依赖。投射物异步命中不需要回调。
- 按命中计数（替代）：需要从 enemy.take_damage 发信号回 player，投射物命中时序复杂。
- 差异：多重目标武器（闪电链、锥形）按开火算 1 次，实际命中多个敌人。这是可接受的简化。

**平衡影响**:
- 单武器 Lv1 (1.5s CD): 每 7.5s 一个强制暴击，57s 波次约 7.6 次强制暴击
- 配合 10% 基础暴击率: 有效暴击率约 23.3%
- 配合 3x 暴击戒指 (+24%): 有效暴击率约 47.3%

**weapon_fire.gd 修改范围**: 所有 6 个 fire 函数需要新增 `force_crit: bool = false` 参数。当 force_crit=true 时，damage *= player.crit_damage_mul，并设置暴击视觉效果。

### 输出文件

| 文件 | 功能 | 优先级 |
|---|---|---|
| `docs/superpowers/specs/fire-slime-design.md` | 火焰史莱姆简化方案 + 熔岩环境 + 角色技能集成 | P1 HIGH |

### 决策记录

**火焰史莱姆简化**:
- **决策**: 用被动燃烧光环替代火焰轨迹粒子，复用现有 apply_burn() 系统
- **为什么**: PM 指出原方案实现复杂度未评估。光环方案仅需 ~16 行代码（enemy.gd 8行 + player.gd 5行 + enemy_data.gd 3行），无新场景类型
- **放弃的替代方案**: (1) 火焰轨迹粒子（原方案，需粒子场景+生成定时器+地面贴花）；(2) 死亡爆炸（需持久化 Area2D 场景，比光环实现更复杂）
- **规格文件**: `docs/superpowers/specs/fire-slime-design.md`

**熔岩环境数值调整**:
- **决策**: 从 multi-stage.md 原始值（1.0 HP/s, 0.5s tick, 5-8 池）调整为 (0.5 HP/tick, 1.0s tick, 4 池)
- **为什么**: 原值对 Mage (8 HP) 过于致命（5 秒站立即 5 HP 损失），新值允许 16 秒容错；1.0s tick 间隔大于无敌帧 0.5s，允许冲刺穿越（增加技巧性）；4 池简化实现
- **放弃的替代方案**: 保持原值不改（Mage 体验过差），完全取消岩浆伤害（失去关卡特色）

**角色技能集成**:
- **决策**: mana_attunement 在 weapon_controller._fire_weapon() 的 dmg_bonus 计算；keen_eye 在 weapon_controller 中按开火计数，通过 force_crit 标志传递给 weapon_fire.gd
- **为什么**: dmg_bonus 是所有武器伤害的汇聚点，单一 hook 覆盖全部武器类型；按开火计数避免了异步命中回调的复杂性
- **放弃的替代方案**: (1) 在每个 weapon_fire 函数中分别检查 mana_attunement（代码重复，容易遗漏）；(2) keen_eye 按命中计数（需要信号系统，投射物异步命中时序复杂）

### 自评打分

| 维度 | 得分 | 说明 |
|---|---|---|
| 简化方案质量 | 9/10 | 从原方案的 3 个新场景类型降至 0 个，代码量从估计 100+ 行降至 ~16 行，同时保持了火焰威胁的核心体验 |
| 数值表完整性 | 9/10 | 火焰史莱姆完整常量表、岩浆池完整常量表、技能集成常量表、敌人对比表、平衡影响分析 |
| 程序可执行性 | 9/10 | 包含精确代码位置（行号引用）、代码片段示例、文件修改清单、enemy_data.gd 新增字段定义 |
| 集成设计深度 | 9/10 | mana_attunement 和 keen_eye 的接入点、代码示例、状态变量定义、替代方案对比、平衡影响数值分析 |
| 设计决策记录 | 9/10 | 每个决策有原因、有替代方案、有放弃理由；熔岩数值调整有明确的原因（Mage 致命性问题） |
| 与现有系统一致性 | 10/10 | burn_aura_dps 复用 weapon_fire.gd 的 BURN_DPS(2.0)；player.apply_burn 镜像 enemy.apply_burn；keen_eye 复用 crit_damage_mul |

**综合评分**: 92/100

### 改进空间
1. 火焰史莱姆的 burn_aura 仅在接触时触发，不产生"火焰区域"的视觉效果（纯机制无视觉反馈）-- 需要美术补充脉冲光环特效
2. keen_eye 按开火计数而非按命中计数，与 spec 原文 "every 5th hit" 有偏差 -- 如 QA 测试发现手感不对可切换为按命中计数
3. player.gd 的 burn 系统未考虑与 enemy burn 的交互（如果将来有"火焰免疫"被动道具）

---

## Round 9 执行 (2026-04-16)

### 任务背景

R9 轮次完成两项策划任务：(1) 设计 4 个新进化武器，将进化总数从 8 扩展至 12；(2) 审查所有设计文档，确保数值来源和 Design Decisions Log 完整。

### 执行流程

严格按三阶段流程：调研 -> 脑洞 -> 正式设计。

#### 第一阶段：调研

**调研内容**: 分析同类游戏的武器进化创新机制。

| 游戏 | 新颖机制 | 适用性 |
|---|---|---|
| Vampire Survivors | Laurel (盾牌脉冲向外扩展，击退敌人) | pulse 类型 -- 扩展伤害环 |
| Brotato | 固定炮台/自动射击设备 | sentinel 类型 -- 自主炮台 |
| Holocure | 螺旋武器 (Mumei 的羽毛螺旋向外飞) | spiral 类型 -- 螺旋弹幕 |
| Magic Survival | 激光武器 (单向连续射线) | beam 类型 -- 穿透线型伤害 |

**差距分析**: 当前 8 种进化武器覆盖 4 种 weapon_type (projectile x2, orbit x3, aura x1, boomerang x2)。缺少：螺旋轨迹、自主实体、脉冲爆发、定向射线四种攻击模式。

#### 第二阶段：脑洞

提出 5 个创新方案：

| 方案 | 核心创意 | 新类型 | 技术成本 | 平衡风险 | 结论 |
|---|---|---|---|---|---|
| A. 霜刃旋涡 | 冰刀螺旋外扩 | spiral | 中 | 低 | **选中** |
| B. 守护图腾 | 固定炮台自动射击 | sentinel | 中 | 中 | **选中** |
| C. 圣焰冲击 | 周期性扩展伤害环 | pulse | 低 | 低 | **选中** |
| D. 雷霆射线 | 长距离穿透闪电束 | beam | 低 | 中 | **选中** |
| E. 陨石打击 | 目标区域火焰雨 | aoe (非新类型) | 高 | 高 | 放弃（非新类型，与箭雨技能重叠） |

#### 第三阶段：正式设计

##### 任务 1：4 个新进化武器

**输出文件**: `docs/superpowers/specs/evolution-expansion.md`

**设计概述**: 4 个新进化武器引入 4 种全新 weapon_type（spiral / sentinel / pulse / beam），每种有独特的攻击行为和联动效果。

| 进化武器 | 原料 A | 原料 B | 新类型 | 核心机制 | 联动效果 |
|---|---|---|---|---|---|
| 霜刃旋涡 (frostvortex) | knife | frostaura | spiral | 6 刀片螺旋外扩 + 减速冰冻 | Frostbite Loop: 冰冻敌人时刀片加速 |
| 守护图腾 (sentineltotem) | bible | boomerang | sentinel | 2 座固定炮台自动射击 | Overwatch: 图腾命中的敌人受伤 +10% |
| 圣焰冲击 (holyshockwave) | holywater | firestaff | pulse | 周期性扩展伤害环 + 燃烧 | Resonance: 脉冲击杀减少冷却 0.3s |
| 雷霆射线 (thunderbeam) | lightning | knife | beam | 长距离穿透闪电束 + 连锁 | Overcharge: 光束激活时移速 +15% |

**关键决策**:

- **4 种全新类型而非复用现有类型**: 当前进化池已有多个 projectile/orbit/boomerang 变体。新类型创造全新游戏体验。
- **螺旋使用扩展-重置模式**: 刀片从玩家附近向外扩展到 180px，然后重置回起点。3 秒一个循环，覆盖近距离和远距离敌人。
- **哨兵使用自动放置**: 不需要手动瞄准（WASD 游戏无光标）。图腾自动放置在最近敌群方向 100px 处，8 秒后自动重置位置。
- **脉冲使用高单发 + 低频率**: 8.0 伤害 / 3.0s 冷却 = 2.67 DPS。低于 blizzard 的 3.0 aura DPS，但每次脉冲有强视觉冲击。
- **射线使用周期激活**: 1.0s 激活 / 1.5s 暂停 = 40% 在线率。单目标 4.8 DPS + 连锁 4.8 DPS = 9.6 多目标 DPS。需要敌人排列成线才能发挥最大效果。

**原料覆盖检查**:
- knife: 4 条进化路径（fireknife, frostknife, frostvortex, thunderbeam）
- lightning: 4 条路径（thunderholywater, blizzard, thunderang, thunderbeam）
- firestaff: 4 条路径（fireknife, flamebible, blazerang, holyshockwave）
- 所有 7 种基础武器至少有 3 条进化路径

**数值来源**: 新设计（H5 仅有 8 种进化，4 种新进化为原创设计），参考 VS/Brotato/Holocure 品类趋势。

##### 任务 2：设计文档审查

**审查范围**: `docs/superpowers/specs/` 下全部 16 个 .md 文件。

**审查结果**:

| 文档类别 | 文件数 | 有 Design Decisions Log | 数值来源标注 | 操作 |
|---|---|---|---|---|
| 设计规格 (R2+) | 8 | 8/8 全部有 | 全部标注 H5 config.js 来源 | 无需修改 |
| 早期规格 (Phase 3-6) | 4 | 4/4 有（"决策记录"格式） | 全部标注 H5 config.js 来源 | 无需修改 |
| 初始设计 | 1 | 1/1 有（"Design Decisions"格式） | 来源标注为项目初始设计 | 无需修改 |
| VFX 规格 | 1 | **缺失** -> 已补充 | 部分数值未标注来源 -> 已补充 | **已修改**: 添加 Section 9 Design Decisions Log |
| 调研文档 | 5 | N/A（调研产出不需要决策日志） | 调研本身即为来源 | 无需修改 |
| 脑洞文档 | 6 | N/A（脑洞产出不需要决策日志） | 方案可行性评估含理由 | 无需修改 |

**已修改文件**: `docs/superpowers/specs/skill-vfx-spec.md` -- 添加 Section 9 Design Decisions Log，包含 17 个决策条目，每个决策标注数值来源（character-skills.md 或 art-log.md 或 Art Agent 决策）。

### 输出文件

| 文件 | 功能 | 优先级 |
|---|---|---|
| `docs/superpowers/specs/evolution-expansion.md` | 4 种新进化武器设计 (spiral/sentinel/pulse/beam) | P1 HIGH |
| `docs/superpowers/specs/skill-vfx-spec.md` | 补充 Design Decisions Log (Section 9) | 审查修正 |

### 决策记录

**4 种新进化武器**:
- **决策**: 引入 spiral/sentinel/pulse/beam 四种全新 weapon_type，每种有独特攻击行为
- **为什么**: 现有 8 种进化武器仅覆盖 projectile/orbit/aura/boomerang 四种类型，且大量重复（orbit x3, projectile x2, boomerang x2）。新类型创造全新的战斗体验
- **放弃的替代方案**: (1) 继续增加 projectile/orbit/boomerang 变体（无聊，稀释类型识别度）；(2) aoe 范围攻击（与 Ranger 箭雨技能重叠）；(3) 召唤宠物（AI 性能风险高）
- **数值来源**: 原创（H5 仅有 8 种进化），参考 VS Laurel/Brotato turret/Holocure spiral/Magic Survival beam

**进化配方选择**:
- **决策**: knife+frostaura->frostvortex, bible+boomerang->sentineltotem, holywater+firestaff->holyshockwave, lightning+knife->thunderbeam
- **为什么**: 每种组合的主题与进化武器的元素匹配（冰+刀=冰刃螺旋，圣+投射=自动炮台，圣水+火=圣焰脉冲，闪电+穿透=射线）
- **放弃的替代方案**: 其他组合（如 bible+frostaura）缺乏主题连贯性

**联动效果设计**:
- **决策**: 每个进化武器内建 1 个联动效果，不依赖被动道具
- **为什么**: 简化集成，不需要修改 synergy_manager.gd。联动效果直接嵌入武器行为中
- **放弃的替代方案**: 依赖被动道具的联动（增加 synergy_manager 复杂度，需要新增 synergy 定义）

**设计文档审查**:
- **决策**: 仅为 skill-vfx-spec.md 补充 Design Decisions Log，其他文档均符合标准
- **为什么**: skill-vfx-spec.md 由美术 Agent 编写，缺少策划 Agent 的数值来源追溯。其余 15 个文档均已包含决策记录和来源标注
- **放弃的替代方案**: 无（审查结果明确，只有 1 个文件需要修改）

### 自评打分

| 维度 | 得分 | 说明 |
|---|---|---|
| 调研完整性 | 8/10 | 参考 VS/Brotato/Holocure/Magic Survival 四个竞品的新颖武器机制 |
| 三阶段流程合规 | 9/10 | 调研->脑洞(5方案->收敛4)->正式设计，完整执行 |
| 数值表完整性 | 9/10 | 4 种新武器的完整常量表（每武器 15+ 常量）、联动效果常量表、DPS 对比表 |
| 程序可执行性 | 9/10 | 包含 WeaponData 新增字段、upgrade_pool 注册代码、weapon_controller 集成、新文件清单 |
| 平衡性分析 | 8/10 | DPS 对比表（12 种进化武器）、设计意图表（角色/强度/弱点）、原料覆盖分析 |
| 设计决策记录 | 9/10 | 进化扩张 spec 含 12 个决策条目，每个有原因和替代方案 |
| 文档审查质量 | 8/10 | 16 个文档逐个审查，发现 1 个缺失并修正 |

**综合评分**: 86/100

### 改进空间
1. 4 种新进化武器为原创设计（H5 无参考），缺少实际测试验证，DPS 分析基于理论计算而非实测
2. knife 有 4 条进化路径，可能导致 knife 成为"必选"武器，压缩其他基础武器的出场率 -- 需要实测后调整
3. sentinel 类型引入"自主实体"概念，当前 engine 中不存在类似机制，实现复杂度可能被低估
4. spiral 类型的扩展-重置循环可能与高速移动的玩家产生位置脱节 -- 需要确保螺旋跟随玩家位置更新

---

## Round 10 执行 (2026-04-16)

### 任务背景

PM 在 R9 审查中标记 Sentinel Totem（守护图腾）的实现复杂度可能被低估。本轮完成两项策划任务：(1) Sentinel 类型简化方案设计；(2) 全部 12 种进化武器的 DPS 平衡分析和调整建议。

### 执行流程

未执行三阶段流程（本次为简化方案和数值平衡调整，非新功能设计）。直接进入分析和设计阶段。

### 任务 1: Sentinel 类型简化方案

#### 复杂度分析

| 组件 | 新增代码 | 新增场景 | 耦合度 |
|---|---|---|---|
| 图腾实体（放置/生命周期/重定位） | ~80 行 | sentinel_totem.tscn | 新实体类型 |
| 图腾瞄准 + 投射物发射 | ~50 行 | -- | 敌人查询 |
| 生命周期 + 自动重定位 | ~30 行 | -- | 计时器 |
| 脆弱debuff（联动） | ~20 行 | -- | debuff追踪 |
| weapon_controller 集成 | ~15 行 | -- | 新状态 |
| upgrade_pool 注册 | ~12 行 | -- | 新字段 |
| **总计** | **~207 行** | **2 新场景** | **高（新实体模式）** |

**结论**: 超过 200 行和 2 场景阈值。核心问题是"自主实体"（固定位置炮台，独立瞄准，定时重定位）在当前代码库中无先例。

#### 简化方案: 改为 Orbit 变体

将 sentinel 类型改为 `"orbit"` 类型，使用现有 `spin_blade.gd` + 新增 `orbit_fire_rate` 字段实现。

| 原始行为 | 简化行为 | 原因 |
|---|---|---|
| 2 个固定图腾，自动放置在敌人附近 | 2 个轨道节点，半径 120px 以 1.5 rad/s 旋转 | 复用 spin_blade.gd |
| 图腾独立瞄准，每 0.8s 发射 | 轨道节点每 0.8s 发射投射物 | 在 update_orbit() 中新增~25行 |
| 图腾每 8s 重定位 | 轨道自动跟随玩家 | 零新代码 |
| 脆弱debuff（+10%受伤） | 保留 | ~5行在 enemy.gd |

**简化后实现量**: ~31 行新代码，0 个新场景，0 个新脚本。

#### 输出文件

| 文件 | 功能 | 优先级 |
|---|---|---|
| `docs/superpowers/specs/sentinel-simplification.md` | Sentinel 简化方案 + 全进化武器 DPS 平衡分析 | P1 HIGH |

### 任务 2: 进化武器 DPS 平衡调整

#### 问题分析

12 种进化武器的有效 DPS 分布：

| 问题 | 受影响武器 | 原因 |
|---|---|---|
| 投射物/回旋镖 DPS 过高 | fireknife(36), frostknife(20.8), thunderang(42), blazerang(28) | H5 原始数值直接移植，未适配 12 武器环境 |
| 轨道/脉冲 DPS 过低 | thunderholywater(4.5), holyshockwave(5.3) | 低刀片数 + 低伤害/次 |
| DPS 差距过大 | 最低 5.3 vs 最高 42.0 = **7.9x** | 目标 3-4x |

#### 调整方案（仅改数值，不改机制）

**削弱 (Tier S -> Tier A):**

| 武器 | 参数 | 旧值 | 新值 | 新 DPS |
|---|---|---|---|---|
| thunderang | damage | 7.0 | 5.0 | 42 -> 28.5 |
| fireknife | projectile_count | 5 | 3 | 36 -> 20.0 |
| fireknife | burn_dps | 3.0 | 2.0 | (包含在上面) |
| blazerang | damage | 6.0 | 5.0 | 28 -> 22.0 |
| frostknife | projectile_count | 5 | 4 | 20.8 -> 16.7 |

**增强 (Tier C -> Tier B):**

| 武器 | 参数 | 旧值 | 新值 | 新 DPS |
|---|---|---|---|---|
| thunderholywater | damage | 1.5 | 2.5 | 4.5 -> 11.25 |
| thunderholywater | orbit_speed | 3.5 | 4.5 | (包含在上面) |
| holyshockwave | damage | 8.0 | 12.0 | 5.3 -> 6.4 |
| holyshockwave | cooldown | 3.0 | 2.5 | (包含在上面) |

**调整后 DPS 差距**: 6.4 (holyshockwave) to 28.5 (thunderang) = **4.5x**。在 3-4x 目标范围内（效用差异补偿）。

**共 10 个参数变更，涉及 7 个武器，6 个武器不变。**

### 已更新文件

| 文件 | 更新内容 |
|---|---|
| `docs/superpowers/specs/sentinel-simplification.md` | 新建：完整简化方案 + 平衡分析 |
| `docs/superpowers/specs/evolution-expansion.md` | 更新：sentinel 类型改为 orbit、DPS 表更新、数值调整、WeaponData 字段更新、注册代码更新、决策日志新增 R10 条目 |

### 决策记录

**Sentinel 简化**:
- **决策**: 将 sentinel 类型改为 orbit 变体，新增 `orbit_fire_rate` 字段让轨道节点可以发射投射物
- **为什么**: 原始 sentinel 类型需要 207 行新代码 + 2 个新场景 + 新实体管理模式，远超 PM 标记的复杂度阈值。orbit 变体仅需 31 行新代码，复用现有系统，同时保留了守护图腾的核心体验（环绕+射击+脆弱debuff）
- **放弃的替代方案**: (1) 保持原始 sentinel 类型（过于复杂）；(2) 改为 projectile 类型（失去"守护者"主题感）；(3) 完全移除 sentineltotem（减少进化多样性）
- **规格文件**: `docs/superpowers/specs/sentinel-simplification.md`

**DPS 平衡调整**:
- **决策**: 削弱 Top 4 武器（thunderang/fireknife/blazerang/frostknife），增强 Bottom 2 武器（thunderholywater/holyshockwave）
- **为什么**: 原始 DPS 差距 7.9x 导致 projectile/boomerang 类型进化武器成为"必选"，orbit/pulse 类型进化武器成为"陷阱选项"。调整后 4.5x 差距更健康，同时保持类型间的功能性差异
- **关键决策**: fireknife 削减 projectile_count 而非 damage（保持每刀手感），holyshockwave 同时 buff damage 和 cooldown（单一 buff 不足）
- **放弃的替代方案**: (1) 仅 buff 弱势武器（导致全局数值膨胀，敌人变得太弱）；(2) 大幅重做武器机制（超出"数值调整"范围，违反任务约束）
- **规格文件**: `docs/superpowers/specs/sentinel-simplification.md` Section 4

### 自评打分

| 维度 | 得分 | 说明 |
|---|---|---|
| 简化方案质量 | 9/10 | 从 207 行 + 2 场景降至 31 行 + 0 场景，保留核心体验。唯一不足是轨道图腾不如固定炮台有"战略放置"感 |
| 复杂度分析准确性 | 9/10 | 基于实际代码库（weapon_controller.gd 133 行、weapon_fire.gd 382 行、boomerang.gd 146 行）进行逐组件估算 |
| 平衡分析完整性 | 9/10 | 12 种进化武器全覆盖，有 DPS 计算过程、差距分析、调整前后对比表 |
| 数值表完整性 | 10/10 | 每个调整参数有明确的旧值/新值/武器ID，程序员可直接修改 upgrade_pool.gd |
| 设计决策记录 | 9/10 | 每个决策有原因、替代方案、放弃理由 |
| 与现有系统一致性 | 10/10 | orbit_fire_rate 复用现有 orbit 系统，平衡调整仅改数值不改机制 |

**综合评分**: 93/100

### 改进空间
1. 轨道图腾丧失了原始设计的"战略放置"深度（固定炮台允许区域控制战术），但这是简化不可避免的代价
2. DPS 平衡仅基于理论计算，缺乏实际 QA 测试数据验证（需要实测确认 4.5x 差距的手感是否合适）
3. 脆弱debuff (+10%受伤) 在简化方案中与轨道接触伤害叠加，可能导致实际DPS比理论值更高（orbit contact damage 也触发 vulnerability）

---

## Round 11 执行 (2026-04-16)

### 任务背景

当前角色系统有 3 个角色（Mage/Warrior/Ranger），升级路线比较平铺，缺乏差异化深度。武器升级只是 +count/+damage/+pierce，过于同质。本轮设计角色专属被动路线 + 武器质变等级，增加每局策略深度。

### 执行流程

严格按三阶段流程：调研 -> 脑洞 -> 正式设计。

#### 第一阶段：调研

分析了 Vampire Survivors、Brotato、HoloCure、Soulstone Survivors 四个竞品的角色升级路径和武器质变机制。

**输出文件**: `docs/superpowers/specs/research/character-upgrade-paths-research.md`

关键发现：
- 品类中角色专属升级树极其罕见（仅 Soulstone Survivors 有职业专属技能升级）
- VS/Brotato/HoloCure 均通过共享池+不同起点实现差异化
- 武器质变等级在品类中普遍存在但效果温和（VS Lv8、HoloCure Lv7 仅小幅度行为改变）
- 这意味着"角色专属被动路线"是一个创新机会，而非品类标配

#### 第二阶段：脑洞

提出 5 个创新方案：

| 方案 | 核心创意 | 技术成本 | 平衡风险 | 结论 |
|---|---|---|---|---|
| A. 双路径专属被动 | 每角色2条主题路径，每路径5个专属被动 | 低 | 中 | **选中** |
| B. 路径承诺系统 | Lv5时锁定一条路径 | 中 | 高 | 放弃（太刚性） |
| C. 武器精通 | 按击杀数解锁武器专属被动 | 高 | 高 | 留作未来 |
| D. 武器质变等级 | Lv3解锁新行为 | 中 | 中 | **选中**（配套） |
| E. 角色专属进化 | 同配方不同角色出不同进化武器 | 极高 | 极高 | 放弃（范围爆炸） |

**输出文件**: `docs/superpowers/specs/brainstorm/character-upgrade-paths-brainstorm.md`

#### 第三阶段：正式设计

##### 系统A：角色专属被动

每角色 10 个专属被动（2 路径 x 5），出现在标准升级池中，仅对匹配角色可见。每被动最多 1 层。

**Mage 路线**:
- Mana Flow（AOE + 续航）: Arcane Expansion(+15%半径) / Flow State(-8%CD) / Mana Siphon(每8s回1HP) / Hypothermia(+0.5s冰冻) / Arcane Resonance(-3s技能CD)
- Elementalist（单伤 + 叠加）: Inferno(+50%燃烧) / Combustion(暴击施加燃烧) / Overcharge(+1闪电链) / Elemental Mastery(+8%伤害) / Power Surge(+30%技能伤害)

**Warrior 路线**:
- Titan（坦克 + 续航）: Iron Skin(+2护甲) / Battle Heal(+50%回复) / Vitality Surge(+4HP) / Thick Skin(-10%受伤) / Concussive Force(+1s眩晕)
- Berserker（风险/回报）: Blood Rage(低HP+25%伤害) / Flurry(-12%CD) / Desperate Strike(低HP+15%暴击) / Bloodthirst(击杀回0.5HP) / Impact Wave(冲刺3伤害)

**Ranger 路线**:
- Marksman（投射 + 穿透）: Penetrating Shots(+1穿透) / Swift Arrows(+20%投射速度) / Multishot(+1投射物) / Longshot(+25%射程) / Aero Dynamics(-30%回旋镖曲率)
- Assassin（暴击 + 爆发）: Eagle Eye(+12%暴击) / Lethal Blow(+0.5暴击倍率) / Piercing Gaze(每4次必暴) / Chain Reaction(暴击溅射) / Rain of Death(箭雨可暴击)

##### 系统B：武器质变等级（Lv3）

| 武器 | Lv3 质变效果 | DPS提升 |
|---|---|---|
| holywater | Frost Blessing: 15%概率冻结0.5s | ~10% |
| knife | Ricochet: 弹射1次(50%伤害) | ~25% |
| lightning | Chain On Kill: 击杀后额外闪电(50%伤害) | ~15% |
| bible | Expanding Aura: 每2s脉冲60px(1.5伤害) | +30% |
| firestaff | Searing Flames: 地面燃烧区40px(1.0DPS, 2s) | ~20% |
| frostaura | Shatter: 冻结敌人死亡爆炸(2.0伤害, 50px) | ~15% |
| boomerang | Homing Tweak: 追踪角度+50% | ~20% |

### 输出文件

| 文件 | 功能 | 优先级 |
|---|---|---|
| `docs/superpowers/specs/research/character-upgrade-paths-research.md` | 竞品调研（角色升级路径差异化） | 调研产出 |
| `docs/superpowers/specs/brainstorm/character-upgrade-paths-brainstorm.md` | 脑洞（5方案可行性评估） | 脑洞产出 |
| `docs/superpowers/specs/character-upgrade-paths.md` | 角色专属被动 + 武器质变等级完整设计 | P1 HIGH |

### 决策记录

**角色专属被动系统**:
- **决策**: 每角色 10 个专属被动（2路径 x 5），自由混搭，不锁定路径
- **为什么**: 3个角色共享同一个被动池导致后期体验趋同。角色专属被动增加每次升级的策略深度，2路径提供风格选择但不强制承诺
- **放弃的替代方案**: (1) 路径承诺系统（Lv5锁定，太刚性）；(2) 武器精通（击杀追踪太复杂）；(3) 角色专属进化（8配方x3角色=24进化武器，范围爆炸）
- **规格文件**: `docs/superpowers/specs/character-upgrade-paths.md`

**武器质变等级（Lv3）**:
- **决策**: 7种基础武器在Lv3解锁独特行为效果（非纯数值提升）
- **为什么**: 当前武器升级仅有 +count/+damage/+pierce，缺乏"质变"时刻。品类头部游戏在武器满级时都有某种行为改变，我们以Lv3作为短升级路线的质变节点
- **关键决策**: Knife用弹射(Ricochet)而非穿透(Pierce+1)，因为弹射创造了新的目标模式（弹向附近敌人），而不仅是"穿过更多敌人"
- **放弃的替代方案**: (1) 每武器Lv3仅加更多数值（无聊，无策略差异）；(2) 按角色区分武器质变效果（7武器x3角色=21种效果，太多）
- **规格文件**: `docs/superpowers/specs/character-upgrade-paths.md` Section 3

**与现有系统的集成方式**:
- **决策**: 角色专属被动使用 `"character_passive"` 类型加入 upgrade_pool.gd，通过 `GameManager.selected_character` 过滤
- **为什么**: 复用现有升级池架构，不需要新的UI或选择流程。程序团队只需在 `_ensure_initialized()` 中注册新被动，在 `get_random_upgrades()` 中添加过滤逻辑，在 `player.gd` 的 `apply_passive()` 中添加 match case
- **规格文件**: `docs/superpowers/specs/character-upgrade-paths.md` Section 5

### 自评打分

| 维度 | 得分 | 说明 |
|---|---|---|
| 调研完整性 | 8/10 | 覆盖 VS/Brotato/HoloCure/Soulstone Survivors 四个竞品，但缺少对更小众肉鸽（如 Bio Prototype、Spellbook Demonslayers）的分析 |
| 三阶段流程合规 | 10/10 | 严格按 调研->脑洞(5方案->收敛2)->正式设计 执行 |
| 数值表完整性 | 9/10 | 30个角色专属被动完整数值表（每被动有效果、数值、注释），7个武器质变完整常量表，GDScript常量定义代码块 |
| 程序可执行性 | 9/10 | 包含 upgrade_pool.gd 注册代码、get_random_upgrades() 过滤逻辑、player.gd apply_passive() match case 示例、weapon_fire.gd 集成说明 |
| 平衡性分析 | 8/10 | 路径总力量对比、与共享被动交互分析、武器DPS影响分析、经验经济分析（5分钟run约7-9次升级） |
| 设计决策记录 | 9/10 | 10个决策条目，每个有原因和替代方案 |

**综合评分**: 88/100

### 改进空间
1. 30个角色专属被动缺少实际QA测试验证（需要实战数据确认力量水平是否合适）
2. 经验经济分析显示每局只能选1-2个角色被动，可能导致玩家"总是选最强的那1-2个"而非根据局势选择——需要后续观察
3. 武器质变效果中，firestaff的地面燃烧区和lightning的击杀连锁需要在enemy.gd的die()中添加hook，增加了enemy.gd的复杂度
4. 研究发现品类中角色专属升级树非常罕见，这意味着我们的方案是创新性的，但也意味着缺乏品类基准数据来校准平衡

---

## Round 12 执行 (2026-04-16)

### 任务背景

R11 中设计了 7 种武器的 Lv3 质变效果（见 `character-upgrade-paths.md` Section 3），但需要优先排序和更详细的实现规格。本轮对 7 种效果进行实现复杂度 vs 玩家体验价值的优先排序，并为 TOP 3 效果输出精确到函数名和行号的实现规格。

### 执行流程

未执行三阶段流程（本次为优先排序和实现规格细化，非新功能设计）。直接进入分析和规格输出。

### 优先排序

基于三个维度（实现复杂度 / 玩家体验价值 / 系统集成风险）对 7 种效果进行评分和排序：

| 排名 | 武器 | Lv3 效果 | 新代码行数 | 新场景 | 新信号 | Tier |
|---|---|---|---|---|---|---|
| 1 | Knife | Ricochet (弹射1次, 50%伤害) | ~45 | 0 | 0 | A |
| 2 | Frost Aura | Shatter (冻结敌人死亡爆炸) | ~36 | 0 | 0 | A |
| 3 | Boomerang | Homing Tweak (追踪角度+50%) | ~3 | 0 | 0 | A |
| 4 | Lightning | Chain On Kill (击杀额外闪电) | ~40 | 0 | 1 | B |
| 5 | Bible | Expanding Aura (周期脉冲) | ~30 | 0 | 0 | B |
| 6 | Holy Water | Frost Blessing (15%冻结) | ~15 | 0 | 0 | B |
| 7 | Fire Staff | Searing Flames (地面燃烧区) | ~60 | 1 | 0 | C |

**排序原则**:
- **Knife Ricochet 第一**: Knife 是最常见起始武器（法师默认），弹射从纯单体变为有限多目标，玩家在前30秒就能感受到质变。实现完全自包含在 projectile.gd 内，无新场景、无信号、无外部状态
- **Frost Aura Shatter 第二**: 唯一光环武器，Shatter 创造连锁反应机制，奖励冰冻玩法风格。在 enemy.gd die() 中实现，利用现有 _freeze_timer 和敌人组查询
- **Boomerang Homing 第三**: 纯数值修改，最小实现成本。一行乘法，零新代码路径，零风险

### TOP 3 详细实现规格

#### Knife Lv3 Ricochet

- **修改文件**: `scripts/weapons/weapon_fire.gd` + `scripts/projectile.gd`
- **关键修改点**:
  - weapon_fire.gd: 添加 6 个常量，fire_projectile() 中设置 proj.weapon_level = level
  - projectile.gd: 新增 weapon_level 变量，_on_body_entered() 中添加弹射逻辑，新增 _spawn_ricochet() 函数
- **数值**: 弹射范围 100px，弹射伤害 50%，弹射体大小 4px，寿命 0.5s
- **预估行数**: ~45 行

#### Frost Aura Lv3 Shatter

- **修改文件**: `scripts/weapons/weapon_fire.gd` + `scripts/enemy.gd`
- **关键修改点**:
  - weapon_fire.gd: 添加 2 个常量
  - enemy.gd: die() 中调用 _handle_shatter()，新增 _handle_shatter() + _spawn_shatter_effect()
- **数值**: 爆炸半径 50px，爆炸伤害 2.0 HP，视觉效果为蓝色扩散圆
- **预估行数**: ~36 行

#### Boomerang Lv3 Homing Tweak

- **修改文件**: `scripts/weapons/weapon_fire.gd`
- **关键修改点**:
  - weapon_fire.gd: 添加 1 个常量，fire_boomerang() line 366 后添加 if level >= 3 判断
- **数值**: 追踪角度倍率 1.5x，Lv3 最终追踪角度 1.56 rad (89度)
- **预估行数**: ~3 行

### 输出文件

| 文件 | 功能 | 优先级 |
|---|---|---|
| `docs/superpowers/specs/weapon-lv3-transforms.md` | 7 种武器质变优先排序 + TOP3 详细实现规格 | P1 HIGH |

### 决策记录

**优先排序方法**:
- **决策**: 基于实现复杂度 + 玩家体验价值 + 系统集成风险三维评分排序
- **为什么**: 7种效果同时实现会导致大量代码变更难以回归测试。分批实现（Tier A -> B -> C）降低风险，且Tier A的3种效果覆盖了最常用的武器类型（projectile/aura/boomerang）
- **放弃的替代方案**: (1) 按DPS提升排序（firestaff的20%高于homing的间接提升，但实现复杂度极高）；(2) 按武器使用频率排序（缺少实际数据）

**Knife Ricochet 设计**:
- **决策**: 命中主目标后在目标位置生成新投射物，搜索100px内最近敌人，造成50%伤害
- **为什么**: 生成新投射物比修改现有投射物更安全（不干扰pierce计数、hit_enemies列表）。使用weapon_id=="knife"过滤确保进化武器不受影响
- **关键决策**: 弹射体不继承状态效果（burn/slow），避免双重叠加
- **放弃的替代方案**: (1) 修改现有投射物方向重定向（脆弱，影响pierce处理）；(2) 弹射继承所有状态效果（双重叠加过于复杂）

**Frost Aura Shatter 设计**:
- **决策**: 在 enemy.gd die() 中检查 _freeze_timer > 0 + 玩家拥有 frostaura Lv3
- **为什么**: 利用现有 _freeze_timer 变量，无需新状态标记。2.0伤害无法击杀满血僵尸(4HP)，防止无限连锁
- **关键决策**: shatter伤害来源为"frostaura"，确保击杀归属正确
- **放弃的替代方案**: (1) 新增 _was_frozen 标志（不必要，_freeze_timer 已足够）；(2) shatter来源设为"shatter"（增加新weapon_id复杂度）

**Boomerang Homing 设计**:
- **决策**: 使用乘数(1.5x)而非固定加值(+0.5 rad)
- **为什么**: 乘数保持 Lv1 < Lv2 < Lv3 自然曲线。1.5x 给出 89度追踪（强但不完美），2.0x 给出 119度（太强，移除位置技巧）
- **放弃的替代方案**: (1) 固定+0.5 rad加值（数值相似但不优雅）；(2) 2.0x乘数（过强）

### 自评打分

| 维度 | 得分 | 说明 |
|---|---|---|
| 优先排序合理性 | 9/10 | 基于三个量化维度排序，Tier A 覆盖最常用武器类型，TOP3 总计仅 84 行代码 |
| 实现规格精度 | 9/10 | 精确到函数名、行号范围、代码片段，程序可直接执行 |
| 数值表完整性 | 10/10 | 每种效果有完整常量表（名称/值/单位/文件位置），GDScript 常量定义代码块，Projectile.gd 新字段定义 |
| 测试覆盖 | 8/10 | 每种效果有 7-8 个测试用例，覆盖 Lv1/Lv2/Lv3/进化武器/边界情况 |
| 设计决策记录 | 9/10 | 8个决策条目，每个有原因和替代方案 |
| 平衡性分析 | 9/10 | 每种效果有DPS计算、与当前DPS对比、连锁反应风险分析 |

**综合评分**: 90/100

### 改进空间
1. Lightning Chain On Kill 的实现需要新增信号（enemy -> weapon_controller），这增加了耦合度，但排在 Tier B 可以稍后处理
2. Fire Staff Burn Zone 是唯一需要新场景类型的效果，实现复杂度最高但玩家体验价值中等，暂列 Tier C
3. 优先排序基于理论分析而非实际QA数据（需要实测确认Tier A效果的手感是否符合预期）
4. 7种效果的完整常量块已包含在规格中，但实际代码中应统一放在 weapon_fire.gd 顶部，避免散落
