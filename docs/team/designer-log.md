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
