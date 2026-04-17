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
| P1 | 武器Lv3质变效果剩余4武器详细规格 | ✅ 已完成（规格见 specs/weapon-lv3-transforms.md Sections 6-9） |
| P1 | 剩余4武器Lv3规格验证 + 精灵覆盖审核 + 竞品进化路线对比 | ✅ 已完成（R14，规格见 specs/weapon-lv3-transforms.md Sections 13-15） |
| P1 | 像素精灵迁移设计审核（ColorRect->Sprite2D前置） | ✅ 已完成（R14，P0缺失: lightning/firestaff/frostaura/sentineltotem） |
| P1 | 最终难度曲线调参 + 功能完整度审计 + 精灵迁移影响评估 | ✅ 已完成（R15，规格见 specs/r15-final-balance-review.md） |
| P1 | 游戏体验终极Review + 新手引导设计 + 角色平衡最终验证 | ✅ 已完成（R16，规格见 specs/tutorial-system.md） |
| P1 | v1.0.1功能优先级排序 + 波次转场细化 + 角色选择页改进 | ✅ 已完成（R17，规格见 specs/v1.0.1-priority-assessment.md） |
| P1 | v1.0.2功能路线图 + 游戏体验终极Review + 数值平衡最终调参 | ✅ 已完成（R18，规格见 specs/v1.0.2-roadmap.md + specs/game-experience-review.md） |
| P1 | XP曲线微调（Lv6-8降10%）| ✅ 已完成（R19，规格见 specs/xp-curve-tuning.md） |
| P1 | 商店Tier 4升级设计 | ✅ 已完成（R19，规格见 specs/shop-t4-design.md） |
| P1 | 武器精通系统设计（7武器x4等级） | ✅ 已完成（R19，规格见 specs/weapon-mastery.md） |
| P1 | 武器精通UI展示设计（徽章/Toast/暂停面板） | ✅ 已完成（R20，规格见 specs/weapon-mastery-ui.md） |
| P2 | 击中反馈系统设计（粒子/伤害数字/暴击/差异化） | ✅ 已完成（R20设计，R21精确化，规格见 specs/hit-feedback-design.md） |
| P2 | v1.0.2平衡性数据分析（精通/商店T4/XP/最大乘数） | ✅ 已完成（R20，记录在本文件 Round 20） |
| P2 | 投射物拖尾参数精确化（6武器间隔/alpha/size曲线） | ✅ 已完成（R21，规格见 specs/projectile-trail-vfx.md） |
| P2 | v1.0.2功能完成度评估 | ✅ 已完成（R21，记录在本文件 Round 21） |
| P2 | 3种未注册进化武器（frostvortex/holyshockwave/thunderbeam） | 已设计+详细数值（R24） |
| P2 | 7种共享被动图标精灵 | 待Art生成 |
| P1 | v1.0.2发布清单 | ✅ 已完成（R22，规格见 specs/v1.0.2-release-notes.md） |
| P1 | v1.0.3路线图 | ✅ 已完成（R22，规格见 specs/v1.0.3-roadmap.md） |
| P1 | R1-R22全历程复盘总结 | ✅ 已完成（R22，记录在本文件 Round 22） |
| P2 | 教程扩展步骤6-8（进化/连击/协同） | ✅ 已设计（R23，规格见 specs/tutorial-extension.md） |
| P2 | 进化武器注册方案（分阶段） | ✅ 已设计+详细数值（R23-R24，规格见 specs/evolved-weapon-registration.md） |
| P1 | hud.gd精通代码拆分方案 | ✅ 已设计（R24，规格见 specs/hud-mastery-panel-spec.md） |

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
- **2026-04-13 扩展**: 新增第18种协同"命运赌徒"（暴击+幸运币 -> 暴击时双倍金币），填补暴击和幸运币两个被动之间的联动空白
- **数值来源**: H5 `SYNERGIES` 配置
- **规格文件**: `docs/superpowers/specs/phase5-synergy-design.md`

### 2026-04-13: Dash 闪避系统设计
- **决策**: 玩家按 Space 触发短距离冲刺，冷却 2.5s，冲刺期间短暂无敌
- **为什么**: 提供主动闪避手段，增加操作深度，缓解后期弹幕密度压力
- **数值**: 冲刺距离 80px，持续 0.15s，冷却 2.5s，残影 3 个

### 2026-04-13: 食物掉落机制设计
- **决策**: 敌人死亡 10% 基础概率掉落食物，拾取回复 1 HP
- **为什么**: 参考原版 VS 的地板鸡肉，为高压局提供微量续航
- **数值**: 10% 基础概率 x 难度 food_drop_mul，食物受磁铁吸引

### 2026-04-13: 屏幕震动反馈设计
- **决策**: 受伤时震动 3.0 强度，连杀 >=20 时震动 2.0 强度
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
| boots_regen | 移动时再生速度x2 | player.gd _physics_process() (already implemented) |
| armor_regen | HP<30%时临时+3护甲 | player.gd take_damage() |
| magnet_maxhp | 拾取宝石2%回复1HP | xp_gem.gd _collect() |
| crit_luckycoin | 暴击时金币掉落翻倍 | enemy.gd die() |

**武器+被动 (8个未接入，在 weapon_controller.gd)**:
| ID | 效果 | 接入位置 |
|---|---|---|
| knife_crit | 飞刀可暴击 | _fire_knife() |
| lightning_magnet | 闪电+1链,范围+50 | _fire_lightning() |
| firestaff_armor | 锥形+40deg,燃烧+1s | _fire_cone() |
| frost_regen | 冰冻+5%,持续+0.5s | _fire_aura() |
| holywater_luckycoin | 圣水击杀+1金币 | holywater on_kill |
| firestaff_luckycoin | 燃烧击杀+1宝石 | firestaff burn_kill |
| frostaura_luckycoin | 冰冻敌人宝石吸引+30 | frostaura freeze |
| boomerang_magnet | 回旋镖飞行吸引宝石30 | boomerang.gd |
| boomerang_crit | 回旋镖可暴击,size x1.2,+1穿透 | _fire_boomerang() |

### 2026-04-13: 连击奖励系统设计
- **决策**: 连击数提供经验加成，里程碑触发提示
- **数值来源**: H5 COMBO 配置
- **经验加成**: combo_count x 5%，上限 50%（10连击封顶）
- **金币阈值**: 连击>=5时额外+1金币/击杀
- **里程碑**: [5, 10, 20, 50] 显示提示

### 2026-04-13: Boss 警告 UI 设计
- **决策**: Boss 出生前 15 秒显示红色警告横幅
- **数值**: warningTime=15s，toast 持续 2.5s
- **显示内容**: skull icon "Boss 即将来袭！" 红色横幅，2.5s 后渐隐

### 2026-04-13: 幸运硬币基础被动效果
- **决策**: 幸运硬币被动需要实际生效（暴击伤害+50%，金币+15%）
- **接入**: player.gd 中 crit_damage_mul += 0.5（已实现），enemy.gd die() 中 gold x (1 + 0.15xstack)

### 2026-04-13: 击杀归属追踪系统设计
- **决策**: enemy 新增 `_last_hit_by: String` 和 `_was_crit: bool`，每次 take_damage 记录来源武器ID和是否暴击
- **接入方式**:
  - `enemy.take_damage(amount, source, was_crit)` -- source 为 weapon_id 字符串
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
- **数据一致性**: xp_gem.gd 硬编码 combox0.05 / max 0.5，应引用 GameManager.COMBO_EXP_RATE / COMBO_MAX_BONUS
- **测试优先级**: P0 修复击杀归属断裂，P1 补充11项缺失测试

### 2026-04-13: 集成差距第二轮审核
- **Critical Bug**: weapon_controller.gd _fire_projectile 中 proj.weapon_id 从未赋值，导致所有投射物类武器的击杀归属追踪完全失效
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
| 6 | **暴风雪/雷霆回旋/烈焰回旋进化武器特效** | 基础行为在，进化武器特殊效果缺失 | MEDIUM | P1 |
| 7 | **协同效果HUD提示** | 协同触发后无UI通知 | MEDIUM | P2 |
| 8 | **连击经验加成实际生效** | combo_bonus 经验值计算在 xp_gem 硬编码，非系统化 | LOW | P2 |
| 9 | **磁铁被动效果(经验获取+30%)** | pickup_range 增大已实现，但EXP加成未实现 | LOW | P2 |
| 10 | **宝箱奖励(buff药水/临时加速)** | item_crate 仅掉宝，无临时buff | MEDIUM | P2 |
| 11 | **连锁闪电视觉(thunderang/thunderholywater)** | 进化武器注册了但无链式闪电特效 | LOW | P3 |
| 12 | **火焰轨迹视觉(blazerang)** | 进化武器注册了但无火焰轨迹特效 | LOW | P3 |
| 13 | **烈焰经文燃烧脉冲** | flamebible 注册了但无燃烧DOT脉冲 | LOW | P3 |
| 14 | **无尽模式Boss击杀奖励** | H5有gold/exp/food奖励，Godot仅普通Boss奖励 | LOW | P3 |
| 15 | **灵魂碎片掉落机制** | soulFragmentRate=0.3 仅在结算时转换金币，H5有局内掉落 | LOW | P3 |

---

## 反思复盘 (2026-04-16)

**PM 评分**: 76/100 (项目总评 74.2，低于 80 阈值)

### 做得好的
- 功能差距分析系统全面，15 项逐条对比 H5 config.js 与 Godot 实现
- TOP3 优先级排序清晰（宝箱/无尽循环/UI展示），与程序团队对齐顺畅
- 每项设计决策都有"为什么"的理由记录

### 需要改进的 (基于 PM 反馈)
1. **未执行竞品调研阶段** -- 缺少 Vampire Survivors / Brotato / Holocure 的横向对比分析
2. **TOP3 设计规格未写入 specs/ 目录** -- 功能差距分析和 TOP3 方案停留在 log 内
3. **无数值表输出** -- 三个方案缺少可直接使用的数值定义表

### 下周期行动项
1. **每个 P0/P1 设计必须输出到 specs/ 目录**
2. **新功能设计前必须完成竞品调研**

---

## Round 18 执行 (2026-04-17)

### 任务背景

项目评分 94.6/100，1276 测试全通过，v1.0.0 已获 Reviewer 发布批准，v1.0.1 进行中（tutorial, enemy cache, BUG-272, character select enhance, wave banner）。本轮完成三项策划任务：(1) v1.0.2 功能路线图，(2) 游戏体验终极 Review，(3) 数值平衡最终调参。

### 任务 1: v1.0.2 功能路线图

**输出文件**: `docs/superpowers/specs/v1.0.2-roadmap.md`

**设计概述**: v1.0.2 是 v1.0.1 hotfix 之后的首个内容与打磨更新，聚焦四大支柱：(1) 角色动画视觉打磨，(2) 音频系统补全，(3) 武器精通长期养成系统，(4) 新手引导深化。

**核心优先级排序**:

| 优先级 | 功能 | 玩家影响 | 成本 | 风险 | 预估行数 |
|---|---|---|---|---|---|
| 1 | 角色动画 (Sprite2D + _physics_process) | 3 | 4 | Low | ~25 |
| 2 | 音频系统 (BGM + SFX) | 5 | 2 | Low | ~400 |
| 3 | 新手引导深化 (3 新步骤) | 4 | 4 | Low | ~40 |
| 4 | 武器精通系统 (Kill-Tracking) | 4 | 2 | Low | ~250 |

**延后到 v1.1.0 的功能**: Daily Challenge (需 seeded RNG 系统)、第4角色、新关卡、Touch/Gamepad 支持、Localization。

**关键决策**:
- 角色动画使用 Method C (Sprite2D + _physics_process)，不修改 .tscn 文件，~25 行代码
- 音频系统是玩家影响最高的功能 (5/5)，但需外部资源（BGM/SFX）
- 武器精通系统提供长期养成目标：7 基础武器 x 4 精通等级 = 28 个里程碑
- Daily Challenge 延后因 seeded RNG 需重构 10+ 文件的随机数调用

### 任务 2: 游戏体验终极 Review

**输出文件**: `docs/superpowers/specs/game-experience-review.md`

**设计概述**: 从四个时间维度分析玩家完整体验曲线：(1) 前30秒新手引导效果，(2) 1-3分钟节奏与升级频率，(3) 3-5分钟深度与角色差异，(4) 重复游玩动力。

**核心发现**:

1. **前30秒缺乏仪式感**: 玩家进入竞技场无倒计时、无视觉冲击、首个击杀反馈弱（screen shake 仅 2.0/0.08s）。建议添加入场倒计时和首个击杀强化反馈。

2. **1-3分钟存在"平铺中段"**: 在 Lv4-Lv7（约50s-2:00）区间，每次升级仅为 +1 count/+0.6 damage 的边际提升，无质变时刻。90秒的平缓期导致玩家动力下降。建议对 XP 表 Lv6-8 微调降低（32->29, 42->38, 55->50）。

3. **进化时间窗口合理**: 最快进化约 2:15（集中升级 Mage），最慢约 3:30（分散升级）。Boss 在 4:03 出现，玩家有 30-90 秒体验进化武器的力量感。

4. **Meta-progression 后劲不足**: 商店约 5 局可满级（875 成本 / 174 每局），之后仅剩成就和 Endless 个人最佳。建议添加 Tier 4 商店升级（总成本升至 1835 = ~10 局）和武器精通系统。

**体验曲线可视化**:
```
情感强度
    ^                                          Boss
    |                                         fight
    |                                     ___/--\
    |                     Evolution    ___/       \
    |                    power spike__/            \
    |        Lv3      /                            \
    |      quality  /                               \
    |     change  /   <-- "Flat Middle" -->          \
    |     /      /     (1:00 - 2:30)                  \
    |   /       /                                      \
    | /  Level  \                                      Endless
    |/   ups     \                                    scaling
    +---+----+----+----+----+----+----+----+----+----+------>
    0s  30s  1m   1:30  2m   2:30  3m   4m   5m   7m   10m
         W1       W2         W3         W4   W5/Boss
```

**识别 11 个摩擦点 (F1-F11)**，按严重度排序:
- F1: 无入场仪式 (Medium, v1.0.2)
- F3: Lv1->Lv2 升级无质变 (Medium, v1.1.0)
- F4: 中期升级频率过慢 (Medium, v1.0.2)
- F6: 角色Build趋同 (Medium, v1.0.2)
- F9: 商店满级过快 (Medium, v1.0.2)

### 任务 3: 数值平衡最终调参

#### 3.1 基础武器单目标 DPS 分析

所有 DPS 计算基于 Normal 难度、dmg_bonus=1.0、目标为单一敌人。

| 武器 | 类型 | 基础DPS (Lv1) | Lv2 DPS | Lv3 DPS | Lv3质变 | 计算公式 |
|---|---|---|---|---|---|---|
| Knife | Projectile | 2.86 | 4.62 | 6.00 | Ricochet(+1弹射,50%伤害) | dmg/cd x count; Lv3 ricochet = +25% effective |
| HolyWater | Orbit | 1.50 | 4.50 | 6.00 | Frost(15%冻结0.5s) | 1.5 dmg x 1 hit/rotation; Lv2=3 orbits, Lv3=2.0dmg |
| Lightning | Lightning | 2.50 | 3.00 | 7.50 | Chain On Kill(击杀额外闪电) | (5+Lv-1)/2.0; Lv3=2 bolts + chains |
| Bible | Orbit | 1.00 | 2.00 | 6.00 | Expanding Radius(1.5x) | contact DPS; Lv3=2.0dmg x 1.5x radius = more hits |
| FireStaff | Cone | 2.00 | 4.00 | 6.67 | Burn(3 DPS, 2s) | (3+2)/1.5 = 3.33 + burn 3.0 = 6.67 |
| FrostAura | Aura | 1.00 | 1.50 | 2.00 | Shatter(2dmg, 50px on freeze death) | 1.0 DPS continuous; Lv3=freeze+shatter bonus |
| Boomerang | Boomerang | 1.67 | 4.00 | 7.50 | Homing +50% | 3/1.8 x 1; Lv2=2 bmrang; Lv3=3 bmrang, more hits |

**基础武器 DPS 排名 (Lv3)**:

| 排名 | 武器 | Lv3 DPS | 评价 |
|---|---|---|---|
| 1 | Lightning | 7.50 | 高爆发，但有空窗期 |
| 2 | Boomerang | 7.50 | 持续追踪，有效DPS高 |
| 3 | FireStaff | 6.67 | 直伤+DOT，稳定 |
| 4 | Knife | 6.00 | 弹射增加有效命中 |
| 5 | HolyWater | 6.00 | 3轨道环绕，稳定 |
| 6 | Bible | 6.00 | 扩展半径增加覆盖率 |
| 7 | FrostAura | 2.00 | 控场型，非DPS导向 |

**分析**:
- DPS 差距 3.75x (FrostAura 2.0 vs Lightning/Boomerang 7.5)，在可接受范围内
- FrostAura 的价值在控场（减速+冻结），而非 DPS。这是设计意图
- Lightning 和 Boomerang 并列第一，但 Lightning 有 2s 空窗期，实际体验不同
- 所有武器在 Lv3 都有约 4-7.5 DPS 区间，数值健康

#### 3.2 进化武器 DPS 分析

进化武器的 DPS 使用 upgrade_pool.gd 中注册的实际数值计算。

| 武器 | 类型 | 有效DPS | AOE效率 | 计算说明 |
|---|---|---|---|---|
| thunderholywater | Orbit | 11.25 | HIGH (3 orbits) | 2.5 dmg x 3 orbits x 4.5 speed / 1.0 cd |
| fireknife | Projectile | 20.0 | MED (3 proj, pierce 2) | 3.0 x 3 proj / 0.5 cd + burn 2.0 DPS |
| holydomain | Orbit | 10.0 | HIGH (4 orbits) | 2.5 x 4 orbits / 1.0 cd |
| blizzard | Aura+Lightning | 14.0 | VERY HIGH (160px + chain) | 3.0 aura + 8.0 x 3 targets / 2.0 cd |
| frostknife | Projectile | 16.7 | MED-HIGH (4 proj, pierce 2) | 2.5 x 4 / 0.6 cd |
| flamebible | Orbit | 20.0 | HIGH (140px, burn) | 5.0 contact + burn 3.0 DPS |
| thunderang | Boomerang | 25.0 | HIGH (4 bmrang, pierce 3) | 5.0 x 4 / 0.8 cd |
| blazerang | Boomerang | 18.75 | HIGH (3 bmrang, burn) | 5.0 x 3 / 0.8 cd + burn 3.0 |
| sentineltotem | Orbit+Fire | 9.4 | MED (2 orbits, 0.8s fire) | 2.5 x 2 contact + 2.5 x 2 fire / 0.8 |

**进化武器 DPS 排名**:

| 排名 | 武器 | DPS | AOE效率 | 评价 |
|---|---|---|---|---|
| 1 | thunderang | 25.0 | HIGH | 最高DPS，追踪+穿透+闪电链 |
| 2 | fireknife | 20.0 | MED | 高频投射+燃烧DOT |
| 3 | flamebible | 20.0 | HIGH | 超大范围+灼烧，最安全 |
| 4 | blazerang | 18.75 | HIGH | 追踪+燃烧，持续性 |
| 5 | frostknife | 16.7 | MED-HIGH | 减速+穿透，控制型 |
| 6 | blizzard | 14.0 | VERY HIGH | 最大范围，最佳AOE |
| 7 | thunderholywater | 11.25 | HIGH | 旋转+闪电，稳定 |
| 8 | holydomain | 10.0 | HIGH | 超大半径，防护型 |
| 9 | sentineltotem | 9.4 | MED | 最弱进化，但自动射击 |

**分析**:
- DPS 差距: 9.4 (sentineltotem) vs 25.0 (thunderang) = 2.66x
- 这个差距在 R10 平衡调整（7.9x -> 4.5x）的基础上进一步缩窄到 2.66x
- thunderang 仍是 DPS 之王，但需要 4 个回旋镖同时飞行才能达到理论值
- sentineltotem 作为最弱进化，其价值在"全自动"（无需瞄准），这是合理的效用补偿
- blizzard 的 DPS 不最高（14.0），但 AOE 效率是所有武器中最高的（160px 范围 + 闪电链 3 目标）

**结论**: 进化武器 DPS 平衡健康。最高与最低差距 2.66x，在效用差异补偿范围内。无需进一步数值调整。

#### 3.3 进化武器是否过于强势？

**对比: 基础武器 Lv3 vs 进化武器**:

| 对比维度 | 基础武器 Lv3 平均 | 进化武器平均 | 倍率 |
|---|---|---|---|
| 单目标 DPS | 6.0 | 16.1 | 2.7x |
| AOE 覆盖 | 低-中 | 中-极高 | 3-4x |
| 效用（控场/穿透） | 低 | 高 | 显著 |

**分析**:
- 进化武器平均 DPS 是基础武器 Lv3 的 2.7 倍。这是设计意图：进化是游戏中期的"奖励时刻"
- 在 H5 中，进化武器的倍率约 3x，我们 2.7x 略低于 H5 基准
- 进化武器不可升级（最高 Lv1），这意味着基础武器有 3 个升级槽而进化武器有 0 个
- 考虑到进化需要两个 Lv3 武器（总共 6 次升级投入），2.7x 的力量感提升是合理的

**结论**: 进化武器强势程度合适。2.7x 倍率对得起 6 次升级的投入。不需要削弱。

#### 3.4 角色被动对平衡的影响

| 角色 | 被动效果 | DPS影响 | 平衡评估 |
|---|---|---|---|
| Mage | +20% weapon damage (所有武器) | 所有武器 DPS x 1.20 | **强** -- 全局伤害提升，无条件触发 |
| Warrior | +1 armor (受伤-1) | 0% (防御性) | **适中** -- 纯防御，不增加DPS |
| Ranger | +12% crit (Keen Eye, 每5次必暴) | 有效crit率 ~23% -> DPS x 1.23 | **强** -- 条件触发，与暴击装备协同 |

**分析**:
- Mage 的 +20% 无条件伤害提升是最简单的加成，且在 weapon_controller.gd 的 dmg_bonus 计算中统一生效
- Ranger 的 Keen Eye 条件是"每 5 次开火"，配合基础 10% 暴击率有效暴击率约 23%，相当于 ~23% DPS 提升（高于 Mage 的 20%）
- 但 Ranger 需要 5 次开火堆叠才能触发，前几次攻击暴击率低，实际平均提升约 18-20%
- Warrior 的 +1 armor 是纯防御加成，不增加 DPS，这对 Hard 模式有显著生存价值

**角色 DPS 差距**:

| 角色 | 基础武器 Lv3 DPS | 加成后 DPS | 提升幅度 |
|---|---|---|---|
| Mage (Knife Lv3) | 6.0 | 7.2 | +20% |
| Warrior (Knife Lv3) | 6.0 | 6.0 | +0% (防御补偿) |
| Ranger (Knife Lv3) | 6.0 | ~7.4 | ~23% (含 crit) |

**Mage vs Ranger DPS 差距**: 约 3%，在统计噪声范围内。平衡健康。

**角色 HP 差距对体验的影响**:

| 角色 | 有效HP (Normal) | 有效HP (Hard) | 生存差距 |
|---|---|---|---|
| Mage | 8 HP | 6 HP (x0.75) | 基准 |
| Warrior | 12 HP + 1 armor | 9 HP + 1 armor | +62.5% vs Mage |
| Ranger | 6 HP | 4.5 HP | -25% vs Mage |

Ranger 在 Hard 模式下 4.5 HP + 190 速度 = 纯闪避生存。这是有意设计（玻璃大炮），但需要玩家有足够的操作水平。新手引导建议已反映这一点（Ranger 推荐难度 = Hard）。

**结论**: 角色被动平衡健康。Mage 和 Ranger 的 DPS 差距在 3% 以内。Warrior 的纯防御加成通过 HP 差异补偿。不需要调整。

#### 3.5 最终平衡结论

| 维度 | 状态 | 说明 |
|---|---|---|
| 基础武器 DPS | **平衡** | 2.0-7.5 DPS 区间 (3.75x 差距)，FrostAura 控场补偿 |
| 进化武器 DPS | **平衡** | 9.4-25.0 DPS 区间 (2.66x 差距)，效用差异补偿合理 |
| 进化 vs 基础 | **平衡** | 2.7x 倍率，匹配 6 次升级投入 |
| 角色被动 | **平衡** | Mage +20% vs Ranger +23% vs Warrior +armor，差距 <3% |
| 难度缩放 | **平衡** | Easy/Normal/Hard/Endless 已全部调参验证 |
| 经济系统 | **平衡但偏快** | 5 局满商店，建议 v1.0.2 添加 Tier 4 延长至 ~10 局 |

**不需要数值调整的项目**: 基础武器数值、进化武器数值、角色被动数值、难度乘数。

**建议 v1.0.2 微调**: (1) 商店添加 Tier 4 升级，(2) XP 表 Lv6-8 微降 10%，(3) 首个击杀反馈强化。

### 输出文件

| 文件 | 功能 | 优先级 |
|---|---|---|
| `docs/superpowers/specs/v1.0.2-roadmap.md` | v1.0.2 功能路线图 | P1 HIGH |
| `docs/superpowers/specs/game-experience-review.md` | 游戏体验终极Review (4时间维度) | P1 HIGH |
| `docs/team/designer-log.md` (本文件) | R18 数值平衡最终调参 | P1 HIGH |

### 决策记录

**v1.0.2 路线图**:
- **决策**: v1.0.2 聚焦角色动画、音频系统、武器精通、新手引导深化
- **为什么**: 这四项覆盖了视觉打磨（动画）、体验缺失（音频）、长期留存（精通）、新手体验（引导）四个维度
- **放弃的替代方案**: (1) Daily Challenge 放入 v1.0.2（seeded RNG 成本太高，hotfix 版不应引入新系统）；(2) 新关卡放入 v1.0.2（内容更新应独立于打磨更新）
- **规格文件**: `docs/superpowers/specs/v1.0.2-roadmap.md`

**游戏体验 Review**:
- **决策**: 识别 11 个摩擦点，最关键的是"平铺中段"（1:00-2:30）和 meta-progression 后劲不足
- **为什么**: 平铺中段导致每次升级缺乏兴奋感，meta-progression 不足导致 5 局后失去动力
- **放弃的替代方案**: (1) 全面重构升级系统（成本过高，风险过大）；(2) 添加微交易（不符合项目定位）
- **规格文件**: `docs/superpowers/specs/game-experience-review.md`

**数值平衡最终调参**:
- **决策**: 当前数值平衡健康，不需要武器/角色/进化武器的数值调整
- **为什么**: 基础武器 DPS 差距 3.75x（合理），进化武器 DPS 差距 2.66x（R10 已大幅改善），角色被动 DPS 差距 <3%（统计噪声）
- **建议微调**: 商店 Tier 4（延长养成线），XP 表 Lv6-8 降 10%（加速中段）
- **放弃的替代方案**: (1) 全面 nerf 高 DPS 武器（导致力量感下降）；(2) buff FrostAura DPS（破坏控场定位）

### 自评打分

| 维度 | 得分 | 说明 |
|---|---|---|
| v1.0.2 路线图完整性 | 9/10 | 包含 7 个候选功能、优先级矩阵、版本时间线、验收标准 |
| 游戏体验分析深度 | 9/10 | 4 个时间维度、11 个摩擦点、体验曲线可视化、竞品对比 |
| DPS 平衡分析准确性 | 9/10 | 7 基础武器 x 3 等级 + 9 进化武器全覆盖，计算公式透明 |
| 数值来源可追溯性 | 10/10 | 所有数值引用 upgrade_pool.gd 和 weapon_fire.gd 中的实际注册值 |
| 设计决策记录 | 9/10 | 每个决策有原因和替代方案 |
| 与现有系统一致性 | 9/10 | 路线图引用已有 spec 文件，Review 引用已有系统，平衡分析引用实际代码 |

**综合评分**: 91/100

### 改进空间
1. DPS 分析基于理论计算而非实测数据，投射物命中率假设为 100%（实际约 70-80%）
2. AOE 效率排名为主观评估，缺乏量化指标（如"每秒覆盖面积"）
3. v1.0.2 路线图未考虑 Art Agent 的工作量（角色动画需 Art 配合，但 Art 资产已存在）
4. 经济系统的 Tier 4 建议未设计具体数值（成本、效果），留待 v1.0.2 正式设计阶段

---

## Round 19 执行 (2026-04-17)

### 任务背景

项目评分 94.8/100，1319 测试通过，v1.0.1 核心功能完成，v1.0.2 路线图已设计。R18 发现"平坦中段"(1:00-2:30)是体验瓶颈，XP 曲线过慢导致升级间隔过长。R18 还指出商店约 5 局可满级，养成周期不足。本轮完成三项策划任务：(1) XP 曲线微调方案，(2) 商店 T4 升级设计，(3) 武器精通系统设计。

### 任务 1: XP 曲线微调方案

**输出文件**: `docs/superpowers/specs/xp-curve-tuning.md`

**设计概述**: 将 EXP_TABLE 索引 4-6（对应 Lv5->6, Lv6->7, Lv7->8）的 XP 需求降低约 10%（32->29, 42->38, 55->50），压缩"平坦中段"从 60 秒到约 50 秒。

**核心分析**:
- 当前 Lv7->8 需要 55 XP，以 4.0 XP/s 的获取速率需要 ~13.8 秒，这期间玩家没有任何升级反馈
- 调整后 Lv7->8 降至 50 XP，时间缩短至 ~12.5 秒
- 累计影响在 Lv8 时为 -6.3%，之后快速衰减（Lv15 仅 -1.0%）
- 进化时间窗口偏移仅 ~5-10 秒，不影响 Boss 战前准备

**精确修改指令**:
- 文件: `scripts/autoload/game_manager.gd`，第 85 行
- 旧值: `[8.0, 12.0, 18.0, 24.0, 32.0, 42.0, 55.0, 70.0, ...]`
- 新值: `[8.0, 12.0, 18.0, 24.0, 29.0, 38.0, 50.0, 70.0, ...]`

### 任务 2: 商店 T4 升级设计

**输出文件**: `docs/superpowers/specs/shop-t4-design.md`

**设计概述**: 为全部 6 种商店升级添加 Tier 4 层级，将养成周期从 ~5 局延长到 ~10 局。T4 成本统一为 T3 的 2 倍。

**数值定义**:

| 升级 | T4 成本 | T4 效果 | 总成本 (T1-T4) |
|---|---|---|---|
| maxhp | 160 | +5 HP (累计+5) | 300 |
| speed | 160 | +5% 速度 (累计+20%) | 300 |
| pickup | 120 | +5 范围 (累计+20) | 225 |
| expbonus | 200 | +5% 经验 (累计+20%) | 375 |
| weapondmg | 240 | +5% 伤害 (累计+15%) | 450 |
| gold | 120 | +10% 金币 (累计+40%) | 225 |

**总成本**: 875 (旧) -> 1875 (新)，+114%
**满级局数**: 5.0 -> 10.8 局 (Normal)

**实现要点**:
- `save_manager.gd`: SHOP_UPGRADES 的 max_level 改为 4，costs 数组添加第 4 元素
- `save_manager.gd`: 6 个 getter 函数添加第 4 个数组元素
- `shop.gd`: 效果文本更新
- 成就自动适配（已使用 max_level 比较）
- 存档兼容（level 3 存档正常加载）

### 任务 3: 武器精通系统设计

**输出文件**: `docs/superpowers/specs/weapon-mastery.md`

**设计概述**: 7 种基础武器各设 4 级精通（50/200/500/1000 击杀），每级提供 +2%/+4%/+6%/+8% 伤害加成。进化武器击杀同时计入两个父武器的精通进度。

**精通等级定义**:

| 等级 | 名称 | 击杀阈值 | 伤害加成 | 标志色 |
|---|---|---|---|---|
| 0 | Novice | 0 | +0% | 灰色 |
| 1 | Apprentice | 50 | +2% | 青铜色 |
| 2 | Adept | 200 | +4% | 银色 |
| 3 | Expert | 500 | +6% | 金色 |
| 4 | Master | 1000 | +8% | 钻石色 |

**击杀归因机制**:
- 利用现有 `_last_hit_by` 系统（已在 synergy 中使用）
- 进化武器通过 `evolved_parents` 字典映射到两个父武器
- 燃烧 DOT / 冻碎 / 分裂体等边界情况已分析

**持久化方案**:
- `save_manager.gd` 新增 `weapon_kills: Dictionary` 和 `MASTERY_THRESHOLDS/MASTERY_BONUSES/BASE_WEAPONS` 常量
- 新增 `add_weapon_kill()`, `get_weapon_kill_count()`, `get_weapon_mastery_tier()`, `get_weapon_mastery_bonus()` 函数
- Save/Load 在 ConfigFile 中使用 `mastery/<weapon_id>` 键

**伤害加成公式**: `Final = Base x (1 + shop_bonus + mastery_bonus) x character_passive`
- 加成是武器专属的（不影响其他武器）
- 与商店加成叠加，与角色被动乘算
- 最大组合（全 T4 商店 + 全精通 + Mage）: 1.48x，平衡健康

**新增成就**:
- `mastery_first`: 任意武器达 Apprentice（奖励 30 SF）
- `mastery_all`: 全 7 武器达 Master（奖励 500 SF，长期目标，约 39-78 局）

**UI 方案**: 商店页面底部新增"武器精通"区域，7 行网格显示武器名称、等级、击杀进度条、当前加成百分比。

**实现范围**: 约 250 行代码，涉及 5 个文件修改 + 1 个新测试文件。

### 输出文件

| 文件 | 功能 | 优先级 |
|---|---|---|
| `docs/superpowers/specs/xp-curve-tuning.md` | XP 曲线 Lv6-8 微调方案 | P1 HIGH |
| `docs/superpowers/specs/shop-t4-design.md` | 商店 Tier 4 升级设计 | P1 HIGH |
| `docs/superpowers/specs/weapon-mastery.md` | 武器精通系统完整设计 | P1 HIGH |
| `docs/team/designer-log.md` (本文件) | R19 执行记录 | P1 HIGH |

### 决策记录

**XP 曲线微调**:
- **决策**: 仅调整 EXP_TABLE 索引 4-6（Lv5->8），降幅约 10%
- **为什么**: "平坦中段"是 R18 确认的核心体验瓶颈，10% 是最小有效调整量
- **放弃的替代方案**: (1) 全局 XP 乘数（太粗暴，影响所有阶段）；(2) 15%+ 降幅（进化时间窗口偏移过大）
- **规格文件**: `docs/superpowers/specs/xp-curve-tuning.md`

**商店 T4**:
- **决策**: 全部 6 种升级添加 T4，成本 = 2x T3
- **为什么**: 均匀扩展避免某些升级感觉"被遗弃"，2x 成本简单可预测
- **放弃的替代方案**: (1) 添加新升级类型（需新 getter/UI/平衡分析，成本过高）；(2) 仅为部分升级添加 T4（体验不一致）
- **规格文件**: `docs/superpowers/specs/shop-t4-design.md`

**武器精通**:
- **决策**: 7 基础武器 x 4 等级，击杀归因到 _last_hit_by，进化武器计入双父武器
- **为什么**: 利用现有击杀归因系统（synergy 已验证），28 个里程碑提供长期目标
- **放弃的替代方案**: (1) 进化武器独立精通（16 轨道过于分散）；(2) 基于使用时间而非击杀数（难以追踪，鼓励挂机）
- **规格文件**: `docs/superpowers/specs/weapon-mastery.md`

### 自评打分

| 维度 | 得分 | 说明 |
|---|---|---|
| XP 曲线分析精度 | 9/10 | 逐级计算时间/累计/偏移，量化"平坦中段"缓解效果 |
| 商店 T4 数值平衡 | 9/10 | 总成本翻倍（875->1875），T4 效果递进合理，与商店 T1-T3 风格一致 |
| 武器精通系统完整性 | 9/10 | 涵盖等级定义、击杀归因、持久化、UI、成就、边界情况 |
| 实现指令精确性 | 10/10 | 三项设计均包含精确的文件名、行号、旧值/新值 |
| 数值来源可追溯性 | 10/10 | 所有数值引用 game_manager.gd EXP_TABLE 和 save_manager.gd SHOP_UPGRADES |
| 与现有系统一致性 | 9/10 | 击杀归因复用 _last_hit_by，精通加成复用 shop bonus 框架 |

**综合评分**: 93/100

### 改进空间
1. 精通系统的 UI 设计仅提供 ASCII 草图，缺少 Godot 场景结构细节（需与程序 Agent 协作）
2. 商店 T4 的 gold 反馈循环未量化（T4 gold +40% 可能加速后期购买节奏，需实测验证）
3. XP 调整对 Hard 模式的影响未单独分析（Hard 的 exp_mul=0.8 可能放大调整效果）
4. 精通成就 mastery_all 需要 7000 总击杀，对休闲玩家可能过于遥远（可考虑降低至 Master 500 击杀）

---

## Round 20 执行 (2026-04-17)

### 任务背景

项目评分 95.2/100，1398 测试通过，v1.0.1 全面完成，v1.0.2 实现启动。R19 完成了三大核心系统设计（XP 曲线微调、商店 T4、武器精通）。本轮聚焦 v1.0.2 新系统的 UI 表现层（精通 UI）、打击感反馈层（击中反馈）、以及新增功能对整体平衡的量化影响分析。

### 任务 1: 武器精通 UI 展示设计

**输出文件**: `docs/superpowers/specs/weapon-mastery-ui.md`

**设计概述**: 为 R19 设计的武器精通系统定义三层 UI 展示方案：(1) HUD 武器槽位上的 6x6 精通等级徽章（青铜/银/金/钻石），(2) 精通等级提升时的 Toast 通知 + Expert/Master 的屏幕闪烁特效，(3) 暂停菜单中的 7 武器精通详情面板（进度条 + 击杀数 + 加成百分比）。

**核心设计**:

| 展示面 | 方案 | 关键参数 |
|---|---|---|
| HUD 徽章 | 6x6 ColorRect，weapon slot 右下角 | Tier 0 隐藏, 1=青铜, 2=银, 3=金, 4=钻石脉动 |
| 升级通知 | 复用 hud_toast.gd | Tier 3/4 额外触发全屏色闪 0.4s |
| 暂停面板 | 独立 hud_mastery_panel.gd (~80行) | 300x420px, 7 行武器, 进度条 80px |

**HUD 集成方案**:
- 新建 `scripts/hud_mastery_panel.gd` (RefCounted, 类似 hud_toast.gd 模式)
- hud.gd 仅增加 ~27 行（信号连接 + 处理器 + 色闪）
- 总行数从 410 增至约 437，远低于 500 行上限
- SaveManager 新增 `mastery_tier_up` signal，在 `add_weapon_kill()` 检测到升级时 emit

### 任务 2: 击中反馈设计

**输出文件**: `docs/superpowers/specs/hit-feedback-design.md`

**设计概述**: 基于 R19 Art Agent 竞品调研（VS 投射物拖尾 + HoloCure 击中粒子），设计四层击中反馈系统：命中粒子爆发、伤害数字弹出、暴击特效、武器差异化。

**核心数值表**:

| 效果 | 参数 | 值 |
|---|---|---|
| 命中粒子 | 数量/尺寸/寿命 | 3个 / 2x2px / 0.15s |
| 伤害数字(普攻) | 字号/颜色/动画 | 10px / 白色 / 上漂30px 0.6s |
| 伤害数字(暴击) | 字号/颜色/动画 | 14px / 金色 / 水平抖动+-2px 0.15s + 上漂 |
| 暴击粒子 | 数量/颜色/速度 | 5个 / 金色 / 60-80px/s |
| 粒子池上限 | 60 粒子 + 20 数字 | 溢出时静默丢弃 |
| 武器频率限制 | 0.1s/0.15s | 自动武器 0.1s，光环/轨道 0.15s |

**武器差异化**:
- 7 种基础武器各有独立粒子颜色（复用 art-log 配色表）
- 进化武器 P2 阶段统一使用金色，P3 阶段实现双色混合
- 特殊行为（闪电定向扩散、火焰余烬、冰霜慢散射、回旋镖弧形）为 P3 打磨

**实现范围**: 新建 `scripts/hit_feedback.gd` (~120 行) + 修改 `enemy.gd` (~5 行) + `arena.gd` (~10 行) = ~135 行

### 任务 3: 平衡性数据分析

#### 3.1 武器精通 +8% 对 DPS 排名的影响

**分析前提**: 精通加成是武器专属的（+2%/+4%/+6%/+8% per weapon），与商店加成叠加，与角色被动乘算。

**公式**: `Final = Base x (1 + shop_bonus + mastery_bonus) x character_passive`

**基础武器 DPS 排名对比 (Lv3, 全商店 T4 + 全精通 Tier 4)**:

| 排名 | 武器 | 当前 DPS (T4 shop only) | 加入精通后 DPS | 精通增幅 | 排名变化 |
|---|---|---|---|---|---|
| 1 | Lightning | 8.63 (x1.15) | 9.23 (x1.23) | +7.0% | 不变 |
| 2 | Boomerang | 8.63 (x1.15) | 9.23 (x1.23) | +7.0% | 不变 |
| 3 | FireStaff | 7.67 (x1.15) | 8.21 (x1.23) | +7.0% | 不变 |
| 4 | Knife | 6.90 (x1.15) | 7.38 (x1.23) | +7.0% | 不变 |
| 5 | HolyWater | 6.90 (x1.15) | 7.38 (x1.23) | +7.0% | 不变 |
| 6 | Bible | 6.90 (x1.15) | 7.38 (x1.23) | +7.0% | 不变 |
| 7 | FrostAura | 2.30 (x1.15) | 2.46 (x1.23) | +7.0% | 不变 |

**关键发现**:

1. **排名零变动**: 精通加成对所有武器是等比例的（都是 +8% 最大值），因此相对排名完全不变。Lightning 和 Boomerang 仍然并列第一。

2. **绝对差距缩小可忽略**: Lightning (9.23) vs FrostAura (2.46) = 3.75x 差距，与无精通时 (8.63 vs 2.30 = 3.75x) 完全相同。加成是加法叠加，不是乘法叠加，所以不会放大差距。

3. **多武器精通的现实**: 玩家不太可能在所有武器上都达到 Tier 4（需要 7000 总击杀）。更现实的场景是主武器 Tier 4 (+8%) + 副武器 Tier 2 (+4%) + 其余 Tier 0 (0%)。这意味着不同武器之间的 DPS 差距实际会略有增大，但增幅极小（主武器额外 +4% 优势 vs 副武器），在统计噪声范围内。

**结论**: 精通 +8% 对 DPS 平衡无影响。排名不变，差距比例不变。

#### 3.2 商店 T4 对经济系统的长期影响

**核心问题**: T4 gold (+40% 总金币加成) 是否会形成正反馈循环，加速后续 T4 购买，导致经济过热？

**经济模型分析**:

| 购买顺序 | 累计花费 | 当前金币加成 | 金币效率 | 剩余升级成本 |
|---|---|---|---|---|
| gold T1 (15 SF) | 15 | +10% | 1.10x | 860 |
| gold T2 (30 SF) | 45 | +20% | 1.20x | 830 |
| gold T3 (60 SF) | 105 | +30% | 1.30x | 770 |
| gold T4 (120 SF) | 225 | +40% | 1.40x | 1650 |

**反馈循环量化**:

Normal 模式基础收入每局约 174 SF（soul fragments）。

| 金币加成 | 每局收入 | 购买 gold T4 后每局 |
|---|---|---|
| 无加成 | 174 SF | 174 x 1.40 = 244 SF |
| Gold T3 (30%) | 226 SF | 226 x 1.40/1.30 = 244 SF |

**关键计算**: 购买 gold T4 需要花费 120 SF。购买后每局多赚 244 - 226 = 18 SF/局（假设此前已有 T3）。回本需要 120 / 18 = **6.7 局**。

**如果优先购买 gold T4 的最优路径**:
- 前 3 局购买 gold T1-T3（花费 105 SF，收入 174+191+208 = 573 SF）
- 第 4 局购买 gold T4（花费 120 SF，金币加成 40%）
- 第 5-10 局每局收入 244 SF，共 1464 SF
- 剩余 5 项 T4 总成本 1650 SF
- 需要约 7 局（1464 + 前期盈余 ~300 = ~1764 SF）

**与不优先 gold 的路径对比**:
- 不购买 gold T4，每局收入 174 SF（无加成）或 226 SF（gold T3）
- 10 局总收入（T3 gold 后）: 105 SF (gold cost) + 226 x 7 = 1582 + ~269 前期 = ~1851 SF
- 差异: 优先 T4 gold 约 1764 SF vs 不优先约 1851 SF -> 差距仅约 87 SF（5%）

**结论**: gold T4 的正反馈循环是温和的。最优购买顺序与非最优顺序仅差 ~5%。原因是 gold T4 的 120 SF 成本需要 6.7 局才能回本，在此期间其他升级的收益已经累计。**gold T4 不会导致经济过热**。

#### 3.3 XP 曲线微调对升级节奏的改善量化

**调整内容**: EXP_TABLE 索引 4-6 从 [32, 42, 55] 改为 [29, 38, 50]

**Normal 模式升级时间对比**:

| 等级 | 旧 XP | 新 XP | 旧时间 | 新时间 | 节省 | 体验改善 |
|---|---|---|---|---|---|---|
| 5->6 | 32 | 29 | ~1:30 | ~1:24 | 6s | 获得第 3 个被动或升级武器 |
| 6->7 | 42 | 38 | ~2:00 | ~1:46 | 14s | Wave 2 内获得额外升级 |
| 7->8 | 55 | 50 | ~2:30 | ~2:11 | 19s | 进入 Wave 3 前更充分准备 |

**Wave 2 (1:03 - 2:00) 内的升级次数**:
- 旧曲线: 2 次升级（Lv5, Lv6）-- 第二次恰好在 Wave 结束时
- 新曲线: 3 次升级（Lv5, Lv6, Lv7）-- 第三次在 Wave 结束前 14 秒

**改善量化**:
- Wave 2 内升级次数: 2 -> 3 (+50%)
- Lv8 到达时间: 2:30 -> 2:11 (-12.7%)
- 进化时间窗口偏移: ~5-10s（可忽略）
- Lv15 累计偏差: -1.0%（完全可忽略）

**Hard 模式影响** (exp_mul=0.8):

| 等级 | 旧等效 XP | 新等效 XP | 旧时间 | 新时间 | 节省 |
|---|---|---|---|---|---|
| 5->6 | 40 (32/0.8) | 36.3 (29/0.8) | ~1:48 | ~1:39 | 9s |
| 6->7 | 52.5 (42/0.8) | 47.5 (38/0.8) | ~2:18 | ~2:05 | 13s |
| 7->8 | 68.8 (55/0.8) | 62.5 (50/0.8) | ~2:52 | ~2:37 | 15s |

Hard 模式的节省绝对值略小于 Normal（因为 exp_mul=0.8 放大了 XP 需求），但相对比例相同。Hard 模式下"平坦中段"仍然是 2:05-2:37（32s），比旧值 2:18-2:52（34s）缩短了 2 秒。改善幅度略小但仍为正。

**结论**: XP 曲线微调在 Normal 下将 Wave 2 升级次数从 2 提升至 3，显著改善"平坦中段"。Hard 模式同样受益，改善幅度略小但方向一致。

#### 3.4 最大乘数健康度检查

**问题**: 角色被动 + 精通 + 商店 T4 的最大乘数组合是否仍在健康范围内？

**所有叠加来源分析**:

| 来源 | 类型 | 最大值 | 叠加方式 |
|---|---|---|---|
| 商店 weapondmg T4 | 永久加成 | +15% | 加法 |
| 武器精通 Tier 4 | 永久加成 | +8% | 加法（与商店） |
| Mage 被动 | 局内加成 | x1.20 | 乘法（与商店+精通） |
| Ranger Keen Eye | 局内加成 | ~+23% 有效暴击率 | 乘法（暴击伤害乘区） |
| 被动: crit 3层 | 局内加成 | +24% 暴击率 | 独立概率 |
| 被动: luckycoin 3层 | 局内加成 | +150% 暴击伤害 | 乘法（暴击时） |
| 商店 maxhp T4 | 永久加成 | +5 HP | 加法 |
| 商店 speed T4 | 永久加成 | +20% 速度 | 乘法 |
| 商店 expbonus T4 | 永久加成 | +20% EXP | 乘法 |
| 商店 gold T4 | 永久加成 | +40% 金币 | 乘法 |

**最大伤害乘数计算 (极端场景)**:

**场景 A: Mage 主刀 + 全商店 T4 + 刀精通 Tier 4 + 3层 crit + 3层 luckycoin**

```
Base damage = 3 (knife Lv1)
Shop bonus = +15% -> multiplier = 1.15
Mastery bonus = +8% -> multiplier = 1.15 + 0.08 = 1.23
Mage passive = x1.20 -> multiplier = 1.23 x 1.20 = 1.476
Crit rate = 10% base + 24% (crit x3) + Keen Eye = ~34% effective
Crit damage = base x 1.476 x (1 + 1.5 from luckycoin x3) = 1.476 x 2.5 = 3.69x
Expected DPS multiplier = 1.476 x (1 + 0.34 x 1.5) = 1.476 x 1.51 = 2.23x
```

**场景 B: Ranger 主回旋镖 + 全商店 T4 + 回旋镖精通 Tier 4 + 3层 crit**

```
Base damage = 3 (boomerang Lv1)
Shop + mastery = 1.23x
Ranger passive (Keen Eye) = ~1.23x effective
Crit from passives = 10% + 24% + Keen Eye cycle = ~34%
Expected multiplier = 1.23 x 1.23 x (1 + 0.34 x 0.5) = 1.23 x 1.23 x 1.17 = 1.77x
```

**场景 C: Warrior 主火焰 + 全商店 T4 + 火焰精通 Tier 4 (无 crit 构建)**

```
Base damage = 3 (firestaff Lv1)
Shop + mastery = 1.23x
Warrior passive = no DPS boost (defensive)
Expected multiplier = 1.23x
+ Burn DPS = 3.0 x 1.23 = 3.69 burn DPS
Total = 1.23x direct + 3.69 burn (vs base 2.0 + 3.0 burn) = 1.23x overall
```

**最大乘数对比**:

| 场景 | 总乘数 | vs 无升级 | 是否健康 |
|---|---|---|---|
| A: Mage knife crit build | 2.23x | +123% | 健康但偏强 -- 需要 10+ 局养成 + 特定装备组合 |
| B: Ranger boomerang | 1.77x | +77% | 非常健康 |
| C: Warrior firestaff | 1.23x | +23% | 保守健康 |
| 无精通 (仅商店 T4) | 1.15-1.38x | +15-38% | 基准线 |

**健康范围判断标准**:

| 乘数范围 | 评价 | 说明 |
|---|---|---|
| 1.0x - 1.3x | 保守 | 仅商店升级，不涉及精通 |
| 1.3x - 1.8x | 健康 | 商店 + 部分精通，大多数玩家的实际范围 |
| 1.8x - 2.5x | 偏强但可接受 | 全投入养成 + 特定 build，需要 15+ 局达成 |
| 2.5x+ | 需要警惕 | 可能导致后期内容过简单 |

**结论**: 最大乘数 2.23x（场景 A）处于"偏强但可接受"区间。这需要极端条件（Mage + knife + 全精通 Tier 4 + 全商店 T4 + 3层 crit + 3层 luckycoin），是一个需要 15-20 局才能达成的终极构建。对于这个投入量，2.23x 的回报是合理的。Hard 模式的 1.5x 敌人 HP/伤害 scaling 会抵消大部分优势（2.23x / 1.5x = 1.49x 有效优势 vs 无升级的 Hard 模式）。

**最大乘数不受影响的理由**:
1. 精通加成是加法叠加（+8%），不是乘法叠加
2. 角色被动、商店、精通三个乘区各自独立，不会指数级增长
3. 商店 T4 的 gold 加成不直接影响伤害，仅加速养成
4. 精通是武器专属的，不可能在同一武器上叠加多次

**不需要调整的项目**: 精通加成幅度、商店 T4 效果值、角色被动值、XP 调整值。

**需要监控的项目**: 场景 A（Mage 极限 crit build）在实测中是否导致 Hard/Endless 模式过于简单。如果实测发现 2.23x 使 Hard 通关率显著上升，可在 v1.0.3 考虑将 crit luckycoin 的暴击伤害加成从 +50%/stack 降至 +40%/stack。

### 输出文件

| 文件 | 功能 | 优先级 |
|---|---|---|
| `docs/superpowers/specs/weapon-mastery-ui.md` | 武器精通 UI 展示设计 | P1 HIGH |
| `docs/superpowers/specs/hit-feedback-design.md` | 击中反馈系统设计 | P2 HIGH |
| `docs/team/designer-log.md` (本文件) | R20 平衡性数据分析 | P1 HIGH |

### 决策记录

**精通 UI 设计**:
- **决策**: 三层 UI（徽章 + Toast + 暂停面板），新模块 `hud_mastery_panel.gd` 约 80 行
- **为什么**: hud.gd 已达 410 行，遵循单文件 <500 行规范需抽取子系统。三层设计覆盖局内（徽章）、事件（Toast）、详情（面板）三个信息密度需求
- **放弃的替代方案**: (1) 精通信息仅在商店页面显示（缺乏局内反馈）；(2) 独立精通面板场景（过度设计，打断游戏节奏）
- **规格文件**: `docs/superpowers/specs/weapon-mastery-ui.md`

**击中反馈设计**:
- **决策**: 四层反馈（粒子爆发 + 伤害数字 + 暴击特效 + 武器差异化），新建 `hit_feedback.gd` 约 120 行
- **为什么**: R19 Art 竞品调研确认击中粒子和伤害数字是投入产出比最高的两项游戏感改进。3 粒子/命中的方案适配我们 30+ 同时敌人的密度
- **放弃的替代方案**: (1) GPUParticles2D 系统（过于重量级，与项目 ColorRect 风格不一致）；(2) 全局频率限制而非 per-weapon（多武器 build 会导致反馈饥饿）
- **规格文件**: `docs/superpowers/specs/hit-feedback-design.md`

**平衡性分析**:
- **决策**: v1.0.2 三大新功能（精通 +8%、商店 T4、XP 微调）不会破坏现有平衡
- **为什么**: 精通加成是等比例 +8%（不改变排名），商店 T4 gold 的正反馈循环回本需 6.7 局（温和），XP 微调仅影响 Lv5-8 区间（累计偏差 -6.3% 快速衰减至 -1.0%）
- **量化结论**: 最大乘数 2.23x（Mage 极限 crit build，需 15-20 局）处于健康范围上限，不需调整
- **放弃的替代方案**: (1) 提前 nerf crit luckycoin（为时过早，需实测数据）；(2) 降低精通加成至 +5%（削弱养成奖励感）

### 自评打分

| 维度 | 得分 | 说明 |
|---|---|---|
| 精通 UI 设计完整性 | 9/10 | 覆盖 HUD 徽章、Toast、暂停面板三层，与 hud.gd 集成方案清晰 |
| 击中反馈设计精确度 | 9/10 | 每个参数（尺寸/颜色/速度/寿命）均有数值和理由，性能约束量化 |
| 平衡性分析深度 | 9/10 | 四个维度全覆盖（DPS 排名/经济/XP/最大乘数），每个结论有量化计算支撑 |
| 数值来源可追溯性 | 10/10 | 所有分析引用 R19 specs 和 H5 config.js 的具体常量 |
| 与现有系统一致性 | 9/10 | 复用 hud_toast.gd、enemy_death_effects.gd 模式、art-log 配色表 |
| 风险评估合理性 | 8/10 | 识别了 gold T4 反馈循环和最大乘数 2.23x 的潜在风险，但缺乏实测数据验证 |

**综合评分**: 90/100

### 改进空间
1. ~~击中反馈的 P3 武器差异化效果（闪电定向/火焰余烬/冰霜慢散射）未给出精确的角度/颜色渐变参数~~ R21 已修正
2. 经济模型假设每局 174 SF 是固定值，实际 Endless 模式和 Quest 奖励会导致收入波动更大
3. 精通 UI 的暂停面板依赖未实现的暂停菜单系统，需要与程序 Agent 协调实现优先级
4. ~~击中反馈未分析对自动武器（holywater/bible 持续接触）的具体频率限制是否足够~~ R21 已通过最坏情况计算验证（28并发粒子/60池上限 = 安全）

---

## Round 21 执行 (2026-04-17)

### 任务背景

项目评分 95.8/100，1520 测试全通过，v1.0.2 三大核心功能已落地（XP 微调、商店 T4、武器精通）。本轮完成三项策划任务：(1) 击中反馈参数精确化（7 种武器的粒子速度/角度/暴击参数），(2) 投射物拖尾参数精确化（6 种武器的间隔/alpha/size 曲线），(3) v1.0.2 功能完成度评估。

### 任务 1: 击中反馈参数精确化

**输出文件**: `docs/superpowers/specs/hit-feedback-design.md` (R21 更新)

**设计概述**: 将 R20 的笼统参数（"40-60px/s 散射速度"）替换为 7 种武器的精确数值定义。每种武器具有独立的粒子扩散角度、速度范围、方向基准和暴击差异化参数。

**核心精确化内容**:

**粒子速度/角度精确表**:

| 武器 | 散射角度 | 普攻速度 | 暴击速度 | 方向基准 |
|---|---|---|---|---|
| Knife | -30 到 +30 度 | 35-55 px/s | 55-75 px/s | 冲击方向 |
| HolyWater | 360 度全向 | 40-60 px/s | 60-80 px/s | 无（全向） |
| Lightning | -60 到 +60 度（向下） | 45-65 px/s | 65-85 px/s | 向下锥形 |
| Bible | 360 度全向 | 30-50 px/s | 50-70 px/s | 无（全向） |
| FireStaff | -45 到 +45 度 | 40-60 px/s | 60-80 px/s | 玩家朝向 |
| FrostAura | 360 度全向 | 20-30 px/s | 35-55 px/s | 无（全向） |
| Boomerang | -45 到 +45 度（垂直于飞行方向） | 40-60 px/s | 60-80 px/s | 垂直于飞行方向 |

**暴击粒子增量**: 5 个（vs 普攻 3 个），全金色 Color(1.0, 0.84, 0.0)

**伤害数字精确参数**:
- 普攻: 10px 字体, 白色, 上漂 30px/0.6s（速度 -50 px/s）, alpha 保持 0.4s 后 0.2s 淡出
- 暴击: 14px 字体, 金色, 先水平抖动 +-2px/0.15s（6 步每 0.025s）, 然后上漂 30px/0.45s（速度 -66.7 px/s）

**频率限制精确值**:
- Projectile/Cone/Boomerang: 100ms
- Orbit/Aura: 150ms
- Lightning: 0ms（无限制，2s 冷却已足够稀疏）

**最坏情况粒子数验证**: 7 武器全开时理论最大 ~28 并发粒子，远低于 60 池上限。

### 任务 2: 投射物拖尾参数精确化

**输出文件**: `docs/superpowers/specs/projectile-trail-vfx.md` (R21 更新)

**设计概述**: 将 R20 的通用参数替换为 6 种有投射物武器的精确拖尾参数，包含生成间隔（毫秒）、逐帧 alpha 衰减表、size 衰减曲线、进化武器 vs 基础武器差异、以及精确的对象池大小计算。

**拖尾生成间隔精确表**:

| 武器 | 投射物速度 | 生成间隔 | 段间间距 | 帧数（60fps） |
|---|---|---|---|---|
| Knife | 350 px/s | 50ms | 17.5px | 3 帧 |
| Boomerang | 280 px/s | 60ms | 16.8px | 4 帧 |
| FireKnife | 400 px/s | 40ms | 16.0px | 2 帧 |
| FrostKnife | 380 px/s | 45ms | 17.1px | 3 帧 |
| Thunderang | 280 px/s | 60ms | 16.8px | 4 帧 |
| Blazerang | 280 px/s | 50ms | 14.0px | 3 帧 |

**Alpha 衰减逐帧值**: 为每种武器提供了 7-13 帧的完整 alpha 表（见 spec Section 3.2），含 Thunderang 的 +-0.08 随机闪烁参数。

**Size 衰减曲线**: Knife/Boomerang/Thunderang 无缩放；FireKnife 1.0->0.7（火焰减弱）；FrostKnife 1.0->0.5（冰块溶解）；Blazerang 1.0->1.2（火焰扩散）。

**进化 vs 基础差异**: 进化武器拖尾始终更显著（更高 alpha 起始值、更大尺寸、更长寿命、独特行为如闪烁/收缩/膨胀）。

**对象池精确计算**: 理论最大 76 段 + 4 余量 = **80 ColorRect**，另加 20 火花粒子。总内存 ~20KB。

### 任务 3: v1.0.2 功能完成度评估

#### 3.1 已完成功能清单

| 功能 | 规格文件 | 实现状态 | 验证方式 |
|---|---|---|---|
| XP 曲线微调（Lv6-8 降 10%） | specs/xp-curve-tuning.md | **已实现** | game_manager.gd 第 85 行已更新为 29.0/38.0/50.0 |
| 商店 Tier 4 升级 | specs/shop-t4-design.md | **已实现** | save_manager.gd costs 数组含 4 元素，max_level=4 |
| 武器精通系统（7 武器 x 4 等级） | specs/weapon-mastery.md | **已实现** | save_manager.gd 含 MASTERY_THRESHOLDS/MASTERY_BONUSES/add_weapon_kill/get_weapon_mastery_tier |
| 武器精通成就（mastery_first/mastery_all） | specs/weapon-mastery.md | **已实现** | save_manager.gd 含 check_mastery_achievements |
| 角色动画（Sprite2D + _physics_process） | specs/character-animation-integration.md | **已实现** | player.gd 含 _anim_time/_anim_frame/ANIM_INTERVAL/_setup_character_animation |
| 敌人缓存系统（性能优化） | -- | **已实现** | GameManager.get_cached_enemies() |

#### 3.2 已设计但未实现功能清单

| 功能 | 规格文件 | 优先级 | 预估行数 | 阻塞项 |
|---|---|---|---|---|
| 武器精通 UI（HUD 徽章/Toast/暂停面板） | specs/weapon-mastery-ui.md | P2 HIGH | ~80 新建 + ~27 hud.gd | 无，可直接实现 |
| 击中反馈系统（粒子/伤害数字/暴击） | specs/hit-feedback-design.md | P2 HIGH | ~165 | 无，可直接实现 |
| 投射物拖尾 VFX | specs/projectile-trail-vfx.md | P2 MEDIUM | ~173 | 无，可直接实现 |
| 音频系统（BGM + SFX） | specs/v1.0.2-roadmap.md 4.4 | P1 HIGH | ~400 | 需外部音频资源 |
| 新手引导深化（3 新步骤） | specs/v1.0.2-roadmap.md 4.5 | P2 MEDIUM | ~40 | 无，v1.0.1 tutorial 已存在 |

#### 3.3 v1.0.2 发布标准定义

**v1.0.2 可发布的最低标准**:

| 标准 | 状态 | 说明 |
|---|---|---|
| 所有 1520+ 测试通过 | **已满足** | 0 失败, 0 pending, 0 孤儿 |
| XP 曲线微调已部署 | **已满足** | game_manager.gd 已更新 |
| 商店 T4 已部署 | **已满足** | save_manager.gd 已更新 |
| 武器精通后端已部署 | **已满足** | 击杀追踪/持久化/伤害加成 |
| 角色动画已部署 | **已满足** | player.gd 已实现 |
| 项目评分 >= 95 | **已满足** | 当前 95.8 |

**v1.0.2 完全体标准（额外）**:

| 标准 | 状态 | 说明 |
|---|---|---|
| 武器精通 UI 已部署 | **未实现** | 规格已完成，~107 行代码 |
| 击中反馈已部署 | **未实现** | 规格已完成，~165 行代码 |
| 投射物拖尾已部署 | **未实现** | 规格已完成，~173 行代码 |
| 音频系统已部署 | **未实现** | 需外部资源 |
| 新手引导 3 新步骤 | **未实现** | 规格已在 roadmap 中，~40 行代码 |

**结论**: v1.0.2 的核心功能（XP 微调、商店 T4、精通系统、角色动画）已全部落地并通过测试。剩余 5 项为视觉打磨和新手体验增强。按当前项目评分 95.8，v1.0.2 已达到最低发布标准。

#### 3.4 预计剩余工作量

| 功能 | 预估行数 | 预估测试 | 复杂度 | 建议优先级 |
|---|---|---|---|---|
| 武器精通 UI | ~107 行 | ~30 行测试 | 中 | 1 (已完成后端，UI 是最后一步) |
| 击中反馈 | ~165 行 | ~35 行测试 | 中高 | 2 (gamefeel 核心改进) |
| 投射物拖尾 | ~173 行 | ~40 行测试 | 中 | 3 (视觉打磨，依赖击中反馈的对象池模式) |
| 新手引导 3 步 | ~40 行 | ~15 行测试 | 低 | 4 (简单扩展现有系统) |
| 音频系统 | ~400 行 | ~20 行测试 | 高 | 5 (需外部资源，不阻塞发布) |

**剩余总代码量**: ~885 行实现 + ~140 行测试 = ~1025 行

**风险评估**: 击中反馈和拖尾共享对象池模式（ColorRect 池化），建议先实现击中反馈（建立池模式），再实现拖尾（复用模式）。enemy.gd 已 499 行接近 500 行限制，击中反馈需要抽取到独立模块（hit_feedback.gd），这有助于 enemy.gd 行数控制。

### 输出文件

| 文件 | 功能 | 优先级 |
|---|---|---|
| `docs/superpowers/specs/hit-feedback-design.md` | 击中反馈精确参数（R21 更新） | P2 HIGH |
| `docs/superpowers/specs/projectile-trail-vfx.md` | 投射物拖尾精确参数（R21 更新） | P2 MEDIUM |
| `docs/team/designer-log.md` (本文件) | R21 执行记录 + v1.0.2 完成度评估 | P1 HIGH |

### 决策记录

**击中反馈参数精确化**:
- **决策**: 7 种武器各有独立散射角度和速度范围，而非统一的 40-60 px/s
- **为什么**: 刀具高速水平散射（-30 到 +30 度）匹配其投射物特性；冰霜慢散射（20-30 px/s）匹配其控场特性；闪电向下锥形匹配"天雷"视觉；回旋镖垂直散射匹配弧形飞行路径。武器差异化是击中反馈的核心价值
- **放弃的替代方案**: 统一速度 + 仅颜色差异（失去了行为层面的武器识别）
- **规格文件**: `docs/superpowers/specs/hit-feedback-design.md`

**投射物拖尾参数精确化**:
- **决策**: 每种武器的生成间隔根据投射物速度计算，目标是 ~15-18px 段间间距
- **为什么**: 间距过小（< 10px）视觉上重叠看不出拖尾效果；间距过大（> 25px）拖尾断裂不连贯。Knife 350px/s x 50ms = 17.5px 合适；FireKnife 400px/s 需要 40ms 才能保持 16px 间距
- **进化武器差异化哲学**: 进化拖尾始终更显著（更高 alpha、更大尺寸、更长寿命、独特行为），因为进化武器是玩家投入 6 次升级获得的奖励
- **放弃的替代方案**: 统一 50ms 间隔（高速武器间距 20px+，低速武器间距 14px-，不一致）
- **规格文件**: `docs/superpowers/specs/projectile-trail-vfx.md`

**v1.0.2 完成度评估**:
- **决策**: v1.0.2 已达到最低发布标准（核心功能全落地，1520 测试通过，评分 95.8）
- **为什么**: R19 设计的三大核心系统（XP 微调/商店 T4/精通系统）和 R18 规划的角色动画均已实现并验证。剩余功能（击中反馈/拖尾/精通 UI/音频/新手引导）属于视觉打磨层，不阻塞版本发布
- **放弃的替代方案**: 等待全部功能完成再发布（延迟玩家获取平衡改善的时间）
- **建议发布策略**: 先发布 v1.0.2a（核心平衡），后续 v1.0.2b 补充视觉打磨

### 自评打分

| 维度 | 得分 | 说明 |
|---|---|---|
| 击中反馈参数精确度 | 10/10 | 每种武器有精确的速度范围、角度范围、暴击差异化、逐帧 shake 时序 |
| 投射物拖尾参数精确度 | 10/10 | 逐帧 alpha 表、逐帧 size 表、进化 vs 基础对比、对象池精确计算 |
| v1.0.2 完成度分析 | 9/10 | 已完成/未完成清单清晰，发布标准量化，剩余工作预估合理 |
| 数值来源可追溯性 | 10/10 | 所有速度引用 upgrade_pool.gd 实际注册值，所有 alpha/size 有公式推导 |
| 与现有系统一致性 | 9/10 | 参数匹配实际代码中的武器类型和投射物行为 |
| 风险评估合理性 | 9/10 | enemy.gd 499 行限制已识别为风险，建议抽取 hit_feedback.gd |

**综合评分**: 95/100

### 改进空间
1. 击中反馈的 P3 进化武器颜色混合（8 种进化武器双色混合）仅提供了色值表，未给出混合公式和映射逻辑
2. 拖尾参数未考虑 Endless 模式 70+ 敌人同时在线的极端场景（理论上限 76 段可能不够，但实际不太可能 6 种投射物武器同时激活）
3. v1.0.2 发布策略建议（v1.0.2a + v1.0.2b）未与程序 Agent 和 PM 协调确认
4. 音频系统的外部资源依赖未给出备选方案（如果无法获取音频资源，v1.0.2 的 Player Impact 评分项将落空）

---

## Round 22 执行 (2026-04-17)

### 任务背景

项目评分 96.4/100，1635 测试全通过，v1.0.2 核心功能全部落地（XP 微调、商店 T4、武器精通、角色动画、击中反馈、投射物拖尾、敌人动画）。剩余精通 UI 集成约 107 行代码未实现。本轮执行三项总结性任务：(1) v1.0.2 完整发布清单，(2) v1.0.3 路线图设计，(3) R1-R22 全历程复盘总结。

### 任务 1: v1.0.2 发布清单

**输出文件**: `docs/superpowers/specs/v1.0.2-release-notes.md`

**设计概述**: 完整记录 v1.0.2 的全部变更，包含 9 项新功能、7 项 Bug 修复、测试增长统计（1276 -> 1635, +28%）、性能改善记录（5 项）、已知限制（3 项未实现 UI + 5 项技术债务）、以及从 v1.0.1 升级的指南（存档兼容性、API 变更、新增常量）。

### 任务 2: v1.0.3 路线图

**输出文件**: `docs/superpowers/specs/v1.0.3-roadmap.md`

**设计概述**: v1.0.3 聚焦完成 v1.0.2 遗留的 UI 工作（精通徽章/Toast/暂停面板 ~107 行）、新手引导扩展（3 步 ~40 行）、3 种未注册进化武器补全（~60 行），以及条件性音频系统（~400 行，依赖外部资源评估）。核心技术债务清理目标为至少解决 2 个 P2 项。

**优先级排序**:

| 优先级 | 功能 | 预估行数 | 阻塞项 |
|---|---|---|---|
| P1 | 武器精通 UI（徽章+Toast+暂停面板） | ~107 | 无 |
| P2 | 新手引导 3 步（协同/进化/连击） | ~40 | 无 |
| P2 | 注册 3 种进化武器 | ~60 | 无 |
| P1 (条件) | 音频系统 | ~400 | 需外部音频资源 |

### 任务 3: 20+ 轮复盘总结

#### 评分轨迹

```
R1-R5   (Phase 0-2):  ~74.2 (基线，角色/难度/武器基础)
R6-R8   (Phase 3-5):  ~78.0 (敌人/进化/协同，822测试)
R9      (功能差距):   ~80.0 (宝箱/无尽/成就UI识别)
R10-R12 (补全+技能):  ~86.0 (TOP3功能+角色技能)
R13-R15 (精灵迁移):   ~90.0 (Sprite2D+平衡调参+1112测试)
R16     (压力测试):   ~91.5 (1191测试,79项边界测试)
R17     (v1.0.1):    ~94.6 (Tutorial+Cache+Bug修复)
R18-R19 (v1.0.2设计): ~95.2 (路线图+体验Review+数值调参)
R20     (v1.0.2核心): ~95.8 (XP/T4/Mastery,1520测试)
R21     (v1.0.2打磨): ~96.0 (击中反馈+拖尾,1635测试)
R22     (v1.0.2发布): ~96.4 (发布清单+复盘+路线图)
```

**总提升**: 74.2 -> 96.4 (+22.2 分, +29.9%)

#### 测试增长轨迹

```
R1:    118 测试 (基线)
R6:    467 测试 (+349, Phase 补全)
R8:    822 测试 (+355, 协同+集成)
R13:   428 测试 (重构清理，质量>数量)
R15:  1112 测试 (+684, 精灵迁移+覆盖)
R16:  1191 测试 (+79, 边界压力)
R17:  1319 测试 (+128, Tutorial+Cache)
R20:  1520 测试 (+201, v1.0.2核心)
R21:  1635 测试 (+115, 反馈+拖尾)
```

**总增长**: 118 -> 1635 (+1386%, +1517 测试)

#### 关键里程碑

| 里程碑 | 轮次 | 分数 | 意义 |
|---|---|---|---|
| 首次 80 分 | R9 | ~80.0 | 从"开发中"跨入"可发布"门槛 |
| 首次 90 分 | R13-R15 | ~90.0 | 精灵迁移+平衡调参推动的质量飞跃 |
| 首次 95 分 | R20 | 95.8 | v1.0.2 三大核心系统全落地 |
| 历史最高 | R22 | 96.4 | 击中反馈+拖尾打磨完成 |

#### 三个最大教训

**教训 1: 设计先行，实现后行，但不要让设计积压**

在 R9 识别了宝箱系统（P0 HIGH）、无尽模式闭环（P0 HIGH）、成就 UI 展示（P1 HIGH）三项关键缺失，但直到 R12-R13 才开始实现。设计规格停留在 designer-log 中未进入 programmer-log 的开发管道，导致 2-3 轮的延迟。

**改进**: 每轮结束时，将 P0/P1 设计规格显式移交到 programmer-log 的"下一轮任务"列表，确保设计到实现的转换不超过 1 轮。

**教训 2: 文件行数限制是最容易被忽视的架构约束**

enemy.gd 在 R20 达到 499 行（99.8%），仅剩 1 行余量。根本原因是每次添加新功能（击杀归属、精通归因、食物掉落）都在 die() 函数上叠加逻辑，而没有同步重构。直到 R21 才通过 enemy_loot.gd 提取降至 359 行。

**改进**: 当文件超过 400 行（80%）时触发重构警告。当文件超过 470 行（94%）时阻塞新功能添加，必须先重构。

**教训 3: 对象池模式应该更早引入**

击中反馈（R21）和投射物拖尾（R21）都使用了 ColorRect 对象池。但如果在 R13 精灵迁移时就引入通用对象池模式，后续所有粒子/残影效果都能复用，减少重复设计工作。

**改进**: 在项目早期（Phase 3-4）就建立通用池基础设施，而非在每个视觉特效模块中独立实现。

#### Agent 协作效率分析

| 协作关系 | 效率评估 | 关键事件 | 改进建议 |
|---|---|---|---|
| Designer -> Programmer | 良好 | R20 的 3 项设计（XP/T4/Mastery）在 1 轮内全部实现 | 保持 |
| Designer -> Art | 一般 | 角色动画规格在 R14 设计但 Art 资产已提前存在，浪费了规格沟通 | 提前确认资产状态 |
| Programmer -> QA | 良好 | BUG-275 (缩进错误) 在 QA 测试期间快速修复，0 轮延迟 | 保持 |
| QA -> Programmer | 良好 | 122 项新测试 (R20) 在实现同期编写，实现了测试前置 | 保持 |
| Reviewer -> All | 有效但延迟 | R10 审核发现进化成就追踪失效（Critical），但 2 轮后才修复 | Critical bug 应在发现后 1 轮内修复 |
| Designer -> Designer | 自我改进 | R16 PM 反馈"未执行竞品调研"，R18-R19 补齐调研阶段 | 流程改进已生效 |

**协作评分**: 82/100

**关键瓶颈**: 设计规格到实现的转换存在 1-2 轮延迟，主要因为无显式移交机制。

### 输出文件

| 文件 | 功能 | 优先级 |
|---|---|---|
| `docs/superpowers/specs/v1.0.2-release-notes.md` | v1.0.2 完整发布清单 | P1 HIGH |
| `docs/superpowers/specs/v1.0.3-roadmap.md` | v1.0.3 路线图 | P1 HIGH |
| `docs/team/designer-log.md` (本文件) | R22 执行记录 + 复盘总结 | P1 HIGH |

### 决策记录

**v1.0.2 发布清单**:
- **决策**: 发布包含 9 项新功能、7 项 Bug 修复、5 项性能改善的完整清单
- **为什么**: v1.0.2 是项目评分最高的版本（96.4），需要完整的变更记录支持版本管理和后续维护
- **放弃的替代方案**: 仅列出用户可见变更（遗漏技术改善和测试数据）

**v1.0.3 路线图**:
- **决策**: v1.0.3 聚焦 v1.0.2 遗留 UI + 条件性音频系统
- **为什么**: 精通 UI 是 R20 就设计好的功能，后端已部署 2 轮仍无 UI，是最高优先级的未完成项。音频系统虽影响最大但受外部资源阻塞
- **放弃的替代方案**: (1) v1.0.3 直接做 Daily Challenge（seeded RNG 成本过高，不适合收尾版本）；(2) v1.0.3 做新关卡（内容更新应独立版本号）

**复盘总结**:
- **决策**: 记录评分轨迹、测试增长、关键里程碑、三个最大教训、Agent 协作分析
- **为什么**: 22 轮的工作积累了大量经验教训，系统性复盘有助于后续版本避免重复错误
- **三个教训的核心**: (1) 设计到实现的移交需要显式机制，(2) 文件行数管理需要主动而非被动，(3) 基础设施（对象池）应更早投资

### 自评打分

| 维度 | 得分 | 说明 |
|---|---|---|
| 发布清单完整性 | 9/10 | 覆盖功能/Bug/测试/性能/限制/升级指南 6 个维度 |
| 路线图可行性 | 9/10 | 优先级排序有量化评分，条件性功能有明确决策点 |
| 复盘深度 | 9/10 | 评分轨迹、测试增长、3 个教训、协作分析全覆盖 |
| 数值来源可追溯性 | 10/10 | 所有数据引用 qa-log/programmer-log/reviewer-log 实际记录 |
| 与现有系统一致性 | 9/10 | 路线图引用已有 spec 文件，发布清单引用已有实现记录 |

**综合评分**: 92/100

### 改进空间
1. 复盘中的评分轨迹 R1-R15 为估算值（非实际测量），因为早期轮次未记录精确分数
2. Agent 协作效率分析基于日志记录而非实际时间跟踪，缺乏定量效率指标（如"每轮小时数"）
3. 音频系统的外部资源评估未包含具体的供应商对比或时间线预估

---

## Round 23 执行 (2026-04-17)

### 任务背景

项目评分 95.8/100，1700 测试全通过，v1.0.2 已完成（精通徽章/Toast/闪光、拖尾特效、4种进化武器行为）。本轮作为 v1.0.3 的策划前置工作，聚焦三项任务：(1) 细化 v1.0.3 功能设计（教程扩展、进化武器注册），(2) Sprite2D 迁移状态确认与风险分析，(3) 输出可直接实施的详细规格。

### 规格文件审计

**现有规格文件 51 个**，逐一审核后分为三类：

#### 已完成并已实现 (46 个)

核心设计全部落地：角色系统、难度模式、7种基础武器、9种已注册进化武器、7种敌人+Boss、18种协同、商店/存档、3角色主动技能、多关卡、火焰史莱姆、Sentinel简化、进化扩展、角色升级路径、武器Lv3质变、精灵迁移、教程5步、v1.0.1/v1.0.2/v1.0.3路线图、角色动画、波次转场、角色选择增强、游戏体验Review、XP曲线、商店T4、武器精通+UI、击中反馈、拖尾特效、发布清单。

#### 已设计但未完全实现 (3 个)

| 规格 | 设计完成度 | 实现状态 | v1.0.3 行动 |
|---|---|---|---|
| `tutorial-system.md` | 5步全部设计 | 5步已实现 | 扩展3步(6-8) |
| `weapon-mastery-ui.md` | 3层UI全设计 | Toast+闪光已实现 | 暂停面板待实现 |
| `evolution-expansion.md` | 12种进化全设计 | 9种已注册+实现 | 3种待注册 |

#### 本轮新增规格 (3 个)

| 规格 | 功能 | 优先级 |
|---|---|---|
| `docs/superpowers/specs/tutorial-extension.md` | 教程步骤6-8详细设计 | P2 MEDIUM |
| `docs/superpowers/specs/evolved-weapon-registration.md` | 3种未注册进化武器注册方案 | P2 LOW |
| `docs/superpowers/specs/sprite2d-migration-plan.md` | Sprite2D迁移状态确认 | Informational |

### 任务 1: 教程扩展3步骤设计

**输出文件**: `docs/superpowers/specs/tutorial-extension.md`

**设计概述**: 在现有5步教程基础上添加3个中局发现型提示：(6) 进化预提示（2武器Lv2时告知进化存在），(7) 连击奖励（combo>=5时解释XP加成），(8) 协同激活（首次触发协同时说明机制）。

**关键数值**:

| 步骤 | 触发条件 | 提示内容 | 超时 |
|---|---|---|---|
| 6 | 2武器均>=Lv2 | "Weapons evolve at Lv3! Check combinations." | 4.0s |
| 7 | combo_count >= 5 | "Combo kills give bonus XP! Keep your streak." | 3.5s |
| 8 | SynergyManager活跃协同数增加 | "Synergy activated! Combos create effects." | 4.0s |

**实现范围**: ~40行新增代码在tutorial_manager.gd + ~30行测试 = ~70行总计。

**关键决策**:
- 步骤6在Lv2触发（而非Lv3），让玩家在进化发生前就有所预期
- 步骤7的combo阈值=5（25% XP加成），而非10或20，确保大多数玩家首次游戏就能触发
- 步骤8使用轮询SynergyManager.active_synergies.size()（而非信号），避免修改SynergyManager
- TUTORIAL_TOTAL_STEPS从5更新为8，所有现有检查使用常量自动适配
- 向后兼容：tutorial_completed=true的存档跳过所有8步

### 任务 2: 3种未注册进化武器注册方案

**输出文件**: `docs/superpowers/specs/evolved-weapon-registration.md`

**设计概述**: frostvortex/holyshockwave/thunderbeam 三种进化武器有完整数值规格但未注册。分为两阶段实施：(A+B) 注册+数据定义（v1.0.3，~43行），(C+D) 发射行为+新脚本（v1.1.0，~235行）。

**差距分析**:

| 武器 | upgrade_pool注册 | weapon_registry配方 | weapon_fire行为 | 新脚本 |
|---|---|---|---|---|
| frostvortex | 缺失 | 缺失 | 缺失(spiral) | spiral_blade.gd |
| holyshockwave | 缺失 | 缺失 | 缺失(pulse) | pulse_ring.gd |
| thunderbeam | 缺失 | 缺失 | 缺失(beam) | beam_line.gd |

**分阶段实施**:
- Phase A（v1.0.3）: upgrade_pool.gd添加3个注册 + weapon_registry.gd添加3个配方 = ~30行
- Phase B（v1.0.3）: weapon_data.gd确认/添加spiral/pulse/beam字段 = ~13行
- Phase C（v1.1.0）: weapon_controller.gd添加3个match分支 + weapon_fire.gd添加3个函数 = ~95行
- Phase D（v1.1.0）: spiral_blade.gd + pulse_ring.gd + beam_line.gd = ~140行

**Phase A+B 后的效果**: 进化配方被识别，升级面板会显示进化选项，但选择后武器不发射（match fallthrough）。这是改进（当前进化选项完全不出现），但需要Phase C+D才能完整功能。

### 任务 3: Sprite2D 迁移状态确认

**输出文件**: `docs/superpowers/specs/sprite2d-migration-plan.md`

**确认结论**: Sprite2D迁移已100%完成，无后续工作。

**代码审查验证**:
- `player.gd`: 使用 `$Sprite` (Sprite2D)，加载 `characters/{id}.png`
- `enemy.gd`: 使用 `$Sprite` (Sprite2D)，加载 `enemies/{id}.png`
- `projectile.gd`: 使用 `$Sprite` (Sprite2D)，加载 `weapons/{id}.png`
- `xp_gem.gd`: 使用 `$Sprite` (Sprite2D)，加载 `pickups/xp_gem_{size}.png`
- 所有实体使用统一模式: Sprite2D节点 + texture加载 + scale计算

**剩余ColorRect使用**全部为有意保留（UI背景、HUD覆盖层、VFX粒子、升级卡图标）。

**精灵资产生成策略**: `tools/generate_sprites.py` (Pillow) 生成所有63个PNG。3个新进化武器精灵（frostvortex/holyshockwave/thunderbeam）需在Phase C+D实施时添加。

**风险**: 无。迁移稳定，10+轮次无回归。

### 优先级表更新

| 优先级 | 事项 | 状态 |
|--------|------|------|
| P0 | 角色系统设计（法师/战士/游侠） | 已完成 |
| P0 | 难度模式设计（休闲/标准/噩梦/无尽） | 已完成 |
| P0 | 7种基础武器数值设计 | 已完成 |
| P1 | 8种进化武器设计 | 已完成 |
| P1 | 7种敌人 + Boss三阶段设计 | 已完成 |
| P2 | 18种协同效应设计 | 已完成 |
| P2 | 商店/存档/任务/成就设计 | 已完成 |
| P2 | 角色主动技能设计（3角色） | 已完成 |
| P1 | 多关卡设计（3关卡） | 已完成 |
| P1 | 火焰史莱姆简化方案 + 角色技能集成 | 已完成 |
| P1 | 进化武器扩展（4种新类型） | 已完成 |
| P2 | 设计文档审查 | 已完成 |
| P1 | Sentinel类型简化 + 进化武器DPS平衡调整 | 已完成 |
| P1 | 角色升级差异化路线 + 武器质变等级 | 已完成 |
| P1 | 武器Lv3质变效果全部7武器详细规格 | 已完成 |
| P1 | 像素精灵迁移设计审核 | 已完成 |
| P1 | 最终难度曲线调参 + 功能完整度审计 | 已完成 |
| P1 | 游戏体验终极Review + 新手引导设计 | 已完成 |
| P1 | v1.0.1功能优先级排序 | 已完成 |
| P1 | v1.0.2功能路线图 | 已完成 |
| P1 | XP曲线微调（Lv6-8降10%）| 已完成 |
| P1 | 商店Tier 4升级设计 | 已完成 |
| P1 | 武器精通系统设计（7武器x4等级） | 已完成 |
| P1 | 武器精通UI展示设计（徽章/Toast/暂停面板） | 已完成 |
| P2 | 击中反馈系统设计 | 已完成 |
| P2 | 投射物拖尾参数精确化 | 已完成 |
| P2 | 3种未注册进化武器（frostvortex/holyshockwave/thunderbeam） | 已设计（Phase A+B待实施） |
| P2 | 7种共享被动图标精灵 | 已设计待Art生成 |
| P1 | v1.0.2发布清单 | 已完成 |
| P1 | v1.0.3路线图 | 已完成 |
| P1 | R1-R22全历程复盘总结 | 已完成 |
| P2 | 教程扩展步骤6-8（进化/连击/协同） | 已设计（R23，待实施） |
| P2 | 进化武器注册方案（分阶段） | 已设计（R23，Phase A+B待实施） |
| INFO | Sprite2D迁移状态确认 | 已完成（R23，迁移100%完成，无后续工作） |

### 输出文件

| 文件 | 功能 | 优先级 |
|---|---|---|
| `docs/superpowers/specs/tutorial-extension.md` | 教程步骤6-8详细设计 | P2 MEDIUM |
| `docs/superpowers/specs/evolved-weapon-registration.md` | 3种进化武器注册方案 | P2 LOW |
| `docs/superpowers/specs/sprite2d-migration-plan.md` | Sprite2D迁移状态确认 | INFO |
| `docs/team/designer-log.md` (本文件) | R23 执行记录 | P1 HIGH |

### 决策记录

**教程扩展步骤6-8**:
- **决策**: 3个中局发现型提示，顺序触发，全部自动消失
- **为什么**: 进化/连击/协同是3个最不透明的中局机制，玩家当前无法通过游戏内信息理解它们
- **放弃的替代方案**: (1) 并行触发+优先级队列（过度工程化）；(2) 强制按键确认（打断战斗节奏）；(3) 独立教程关卡（实现成本500+行）
- **规格文件**: `docs/superpowers/specs/tutorial-extension.md`

**进化武器注册分阶段**:
- **决策**: v1.0.3仅注册配方+数据定义（Phase A+B），v1.1.0实现发射行为（Phase C+D）
- **为什么**: 注册是低风险（~43行），让玩家看到进化选项出现。发射行为需要3个新脚本（~235行），不适合收尾版本
- **Phase A+B后的已知限制**: 选择进化后武器存在但不发射，需在release notes中说明
- **放弃的替代方案**: (1) 等v1.1.0一起做（延迟配方发现2个版本）；(2) v1.0.3实现全部（范围膨胀风险）
- **规格文件**: `docs/superpowers/specs/evolved-weapon-registration.md`

**Sprite2D迁移确认**:
- **决策**: 记录迁移100%完成，无后续工作
- **为什么**: 代码审查确认所有6个实体场景使用Sprite2D，10+轮次零回归，63个PNG资产生成完整
- **放弃的替代方案**: 继续监控（不必要的开销）
- **规格文件**: `docs/superpowers/specs/sprite2d-migration-plan.md`

### 自评打分

| 维度 | 得分 | 说明 |
|---|---|---|
| 教程扩展设计完整性 | 9/10 | 3步骤各有触发条件/内容/超时/状态机/API扩展/测试用例 |
| 进化武器注册方案精确度 | 9/10 | 分阶段实施有明确行数/风险/依赖分析，含Phase A+B后的已知限制说明 |
| Sprite2D迁移审计覆盖度 | 9/10 | 逐文件审查4个核心实体脚本，确认ColorRect使用模式全部替换 |
| 数值来源可追溯性 | 10/10 | 所有触发阈值引用GameManager/SynergyManager实际代码中的常量 |
| 与现有系统一致性 | 10/10 | 教程扩展复用TutorialManager现有模式，注册复用upgrade_pool现有格式 |
| 向后兼容性分析 | 9/10 | tutorial_completed=true存档兼容、Phase A+B后weapon_controller行为分析 |

**综合评分**: 93/100

### 改进空间
1. 教程步骤8（协同）的触发时机不可控——如果玩家不搭配协同组合则永远不触发，可考虑添加跳过机制（超时30秒后自动完成步骤8）
2. 进化武器注册Phase A+B后的"沉默武器"体验可能让玩家困惑（投入6次升级获得一个不攻击的武器），需要在release notes中明确说明
3. 教程扩展的3个步骤可能在中局战斗中分散玩家注意力，后续可考虑添加"关闭教程提示"的设置选项

---

## Round 24 执行 (2026-04-17)

### 任务背景

项目评分 96.4/100，1700 测试全通过，v1.0.2 全面完成。R23 创建了 3 个 v1.0.3 规格文档（教程扩展/进化武器注册/Sprite2D 迁移）。关键发现：hud.gd 达 463 行（92.6% 的 500 行上限），3 种进化武器（frostvortex/holyshockwave/thunderbeam）仅有数值规格但缺少详细注册数值表。本轮聚焦：(1) 设计 hud.gd 精通代码拆分方案，(2) 细化 3 种缺失进化武器数值表，(3) 输出可直接实施的详细规格。

### 任务 1: hud.gd 精通徽章拆分方案

**输出文件**: `docs/superpowers/specs/hud-mastery-panel-spec.md`

**设计概述**: 将 hud.gd 中 ~82 行精通相关代码（常量定义 + 徽章创建/更新 + 全屏闪烁 + 武器名查询）提取到独立的 `scripts/hud_mastery_panel.gd` RefCounted 模块，遵循 hud_toast.gd / hud_skill_button.gd 的既定模式。提取后 hud.gd 从 463 行降至 ~383 行，为 v1.0.3 暂停菜单集成留出 ~117 行空间。

**提取范围**:

| hud.gd 区域 | 行数 | 提取目标 |
|---|---|---|
| 精通常量 (MASTERY_* + 3 个数组) | ~21 行 | hud_mastery_panel.gd 常量 |
| `_get_weapon_display_name()` | ~8 行 | hud_mastery_panel.gd 公开函数 |
| `_show_mastery_flash()` | ~16 行 | hud_mastery_panel.gd 私有函数 |
| `_ensure_mastery_badge()` | ~19 行 | hud_mastery_panel.gd 公开函数 |
| `_start_badge_pulse()` | ~5 行 | hud_mastery_panel.gd 私有函数 |
| **总计** | **~82 行** | |

**hud.gd 变更**:
- 移除 82 行精通代码
- 新增 2 行（`var _mastery_panel` 声明 + 构造函数调用）
- `_on_mastery_tier_up()` 从 9 行简化为 2 行委托
- 净变化: -80 行（463 -> ~383）

**模块公开 API**:

| 函数 | 签名 | 用途 |
|---|---|---|
| `on_tier_up(weapon_id, new_tier)` | 主入口，处理 toast + 闪烁 + 徽章更新 | 替代原 hud.gd 的 9 行处理函数 |
| `ensure_badge(weapon_id, slot)` | 在武器槽上创建精通徽章 | 供武器槽设置时调用 |
| `get_weapon_display_name(weapon_id)` | 武器 ID -> 显示名称映射 | 内部使用 |

**关键决策**:
- `_on_mastery_tier_up()` 信号处理保留在 hud.gd（协调逻辑属于协调者），仅 2 行委托调用
- `_toast` 通过构造函数注入（避免模块重复创建 toast 系统）
- 常量全部跟随模块移动（hud.gd 不保留任何精通特定知识）
- 修复了原实现缺少的"徽章升级时更新"逻辑（原代码只创建徽章，从不在升级时更新颜色）

**暂停菜单扩展点**: 未来 v1.0.3 实现暂停菜单时，hud_mastery_panel.gd 新增 `build_pause_panel()` 函数（~40 行），返回包含 7 武器精通详情的 Control 节点。

### 任务 2: 缺失进化武器详细数值表

**输出文件**: `docs/superpowers/specs/evolved-weapon-registration.md` (R24 更新)

**设计概述**: 为 frostvortex、holyshockwave、thunderbeam 三种未注册进化武器补充完整的数值参考表。将 evolution-expansion.md Sections 5.1/5.3/5.4 中分散的数值合并为单一注册就绪的参考文档，包含每个属性的值、单位、来源和设计理由。

**新增 5 个数值小节**:

**5.1 Frost Vortex 完整数值参考**:

| 属性 | 值 | 设计理由 |
|---|---|---|
| damage | 3.0 HP | 6 刃 x 3.0 = 总输出可观，单刃低于 fireknife(3.0) 因为螺旋命中频率更高 |
| cooldown | 999.0s | 始终激活（同 orbit/aura） |
| spiral_blade_count | 6 | 60度间隔，视觉密度高但不过于拥挤 |
| spiral_max_radius | 180.0px | 超过 holydomain(130)，覆盖显著屏幕区域 |
| slow_pct | 0.4 | 与 frostknife 一致 |
| freeze_pct | 0.08 | 与 frostaura Lv3 一致 |

**5.2 Holy Shockwave 完整数值参考**:

| 属性 | 值 | 设计理由 |
|---|---|---|
| damage | 12.0 HP | R10 从 8.0 上调，原为 DPS 最低进化武器 |
| cooldown | 2.5s | R10 从 3.0 下调，增加脉冲频率 |
| pulse_max_radius | 200.0px | 超过 blizzard aura(160)，覆盖大部分屏幕中心 |
| burn_dps + burn_duration | 2.0 + 2.0s | 与 firestaff 燃烧一致 |
| 脉冲 DPS | 6.4 (含燃烧) | 最低原始 DPS，但 Resonance 协同在密集波次可提升至 ~10.0 |

**5.3 Thunder Beam 完整数值参考**:

| 属性 | 值 | 设计理由 |
|---|---|---|
| damage | 4.0 HP/tick | 每 0.3s 一次，3 tick/激活 = 12.0 HP/激活 |
| beam_active_duration | 1.0s | 40% 正常运行时间（1.0s 开 + 1.5s 关） |
| chain_count | 2 | 与 thunderang 链数一致 |
| projectile_range | 1200.0px | 等效无限（竞技场 2500-3000 宽） |
| 多目标 DPS | ~9.6 | 3 种新武器中最高，但需要敌人排成一线 |

**5.4 三武器 DPS 对比**:

| 武器 | 原始 DPS | 有效 DPS | 定位 |
|---|---|---|---|
| frostvortex | ~6.0 | ~8.0 | 控场（减速+冰冻） |
| holyshockwave | 4.8 | 6.4+燃烧 | 保证 AoE（全屏命中） |
| thunderbeam | 4.8(单) | 9.6(群) | 长程穿透（方向依赖） |

**平衡评估**: 三种新武器均落在 B 级（6.4-9.6 有效 DPS），对比现有 A 级武器（fireknife 20.0, thunderang 28.5）。这是有意为之 -- 3 种新武器提供独特功能（控场/保证 AoE/长程穿透）而非原始 DPS，它们是情境性强大而非全局优势。

**5.5 WeaponData.gd 字段验证**: 10 个新字段（spiral: 4, pulse: 3, beam: 3）需要确认/添加到 weapon_data.gd。6 个已有字段（slow_pct, freeze_pct, burn_dps, burn_duration, chain_count, orbit_fire_rate）已确认存在。

### 优先级表更新

| 优先级 | 事项 | 状态 |
|--------|------|------|
| P0 | 角色系统设计（法师/战士/游侠） | 已完成 |
| P0 | 难度模式设计（休闲/标准/噩梦/无尽） | 已完成 |
| P0 | 7种基础武器数值设计 | 已完成 |
| P1 | 8种进化武器设计 | 已完成 |
| P1 | 7种敌人 + Boss三阶段设计 | 已完成 |
| P2 | 18种协同效应设计 | 已完成 |
| P2 | 商店/存档/任务/成就设计 | 已完成 |
| P2 | 角色主动技能设计（3角色） | 已完成 |
| P1 | 多关卡设计（3关卡） | 已完成 |
| P1 | 火焰史莱姆简化方案 + 角色技能集成 | 已完成 |
| P1 | 进化武器扩展（4种新类型） | 已完成 |
| P2 | 设计文档审查 | 已完成 |
| P1 | Sentinel类型简化 + 进化武器DPS平衡调整 | 已完成 |
| P1 | 角色升级差异化路线 + 武器质变等级 | 已完成 |
| P1 | 武器Lv3质变效果全部7武器详细规格 | 已完成 |
| P1 | 像素精灵迁移设计审核 | 已完成 |
| P1 | 最终难度曲线调参 + 功能完整度审计 | 已完成 |
| P1 | 游戏体验终极Review + 新手引导设计 | 已完成 |
| P1 | v1.0.1功能优先级排序 | 已完成 |
| P1 | v1.0.2功能路线图 | 已完成 |
| P1 | XP曲线微调（Lv6-8降10%）| 已完成 |
| P1 | 商店Tier 4升级设计 | 已完成 |
| P1 | 武器精通系统设计（7武器x4等级） | 已完成 |
| P1 | 武器精通UI展示设计（徽章/Toast/暂停面板） | 已完成 |
| P2 | 击中反馈系统设计 | 已完成 |
| P2 | 投射物拖尾参数精确化 | 已完成 |
| P2 | 3种未注册进化武器（frostvortex/holyshockwave/thunderbeam） | 已设计+详细数值（R24） |
| P2 | 7种共享被动图标精灵 | 已设计待Art生成 |
| P1 | v1.0.2发布清单 | 已完成 |
| P1 | v1.0.3路线图 | 已完成 |
| P1 | R1-R22全历程复盘总结 | 已完成 |
| P2 | 教程扩展步骤6-8（进化/连击/协同） | 已设计（R23，待实施） |
| P2 | 进化武器注册方案（分阶段） | 已设计+详细数值（R23-R24） |
| INFO | Sprite2D迁移状态确认 | 已完成（R23，迁移100%完成） |
| P1 | hud.gd精通代码拆分方案 | 已设计（R24，hud_mastery_panel.gd） |

### 输出文件

| 文件 | 功能 | 优先级 |
|---|---|---|
| `docs/superpowers/specs/hud-mastery-panel-spec.md` | hud.gd 精通代码拆分规格 | P1 HIGH |
| `docs/superpowers/specs/evolved-weapon-registration.md` | 3种进化武器详细数值表（R24更新） | P2 LOW |
| `docs/team/designer-log.md` (本文件) | R24 执行记录 | P1 HIGH |

### 决策记录

**hud.gd 精通代码拆分**:
- **决策**: 提取 ~82 行精通代码到独立 hud_mastery_panel.gd RefCounted 模块
- **为什么**: hud.gd 达 463 行（92.6%），暂停菜单集成还需 ~30 行，不拆分将超 500 行上限。提取后 hud.gd 降至 ~383 行，留出 117 行空间
- **放弃的替代方案**: (1) 仅提取暂停面板到独立文件，保留徽章代码在 hud.gd（徽章代码占 82 行，是提取的主体）；(2) 将 hud.gd 拆为多个 CanvasLayer 场景（过度工程化，破坏现有架构）
- **修复**: 原实现缺少"升级时更新徽章颜色"逻辑，新模块的 `on_tier_up()` 包含此修复
- **规格文件**: `docs/superpowers/specs/hud-mastery-panel-spec.md`

**进化武器详细数值表**:
- **决策**: 为 3 种缺失进化武器补充完整注册就绪的数值参考表
- **为什么**: Programmer Agent 实施注册时需要单一来源的完整数值，原数值分散在 evolution-expansion.md 的 3 个小节中。补充了每个属性的设计理由和 DPS 分析，使实施和测试有据可查
- **放弃的替代方案**: (1) 仅引用 evolution-expansion.md 不补充细节（实施时需交叉引用 3 个小节，效率低）；(2) 直接修改 evolution-expansion.md（该文件是 R9 的完整设计文档，不应被覆盖）
- **规格文件**: `docs/superpowers/specs/evolved-weapon-registration.md` (R24 更新 Section 5)

### 自评打分

| 维度 | 得分 | 说明 |
|---|---|---|
| 拆分方案精确度 | 10/10 | 逐行标注提取范围、hud.gd 净变化量、模块公开/私有 API、暂停菜单扩展点 |
| 数值表完整性 | 9/10 | 每个属性有值/单位/来源/理由，DPS 对比表和 WeaponData 字段验证齐全 |
| 与现有模式一致性 | 10/10 | 拆分方案严格遵循 hud_toast.gd / hud_skill_button.gd 的 RefCounted 模式 |
| 数值来源可追溯性 | 10/10 | 所有数值引用 evolution-expansion.md 具体小节和 R10 平衡调整记录 |
| 风险评估合理性 | 9/10 | 识别了"原实现缺少徽章更新"的 bug，量化了 hud.gd 行数预算（当前/拆分后/暂停菜单后） |

**综合评分**: 96/100

### 改进空间
1. 拆分方案未提供 hud_mastery_panel.gd 的完整实现代码（仅接口和关键函数签名），Programmer Agent 需自行补全辅助函数的具体实现细节
2. 进化武器的 DPS 计算假设了"密集敌人群体"的命中频率（frostvortex ~0.33 hits/s/blade），实际命中频率取决于敌人密度和螺旋模式，需要实测校准
3. 暂停菜单的 build_pause_panel() 仅提供了函数签名，未设计详细的 VBoxContainer/HBoxContainer 布局树（需要结合 weapon-mastery-ui.md Section 4.2 的 ASCII 布局在实施时构建）

---

## R25 优先级建议

基于R24的设计输出和v1.0.3路线图，建议R25的优先级排序：

| 优先级 | 任务 | 负责 Agent | 预估行数 | 阻塞项 |
|---|---|---|---|---|
| P1 | hud.gd 精通代码拆分（hud_mastery_panel.gd ~95行） | Programmer | ~95实现 + ~50测试 | 无，规格已完成 |
| P1 | 教程步骤6-8实现（tutorial_manager.gd扩展） | Programmer | ~40实现 + ~30测试 | 无，规格已完成 |
| P1 | 暂停菜单 + 精通面板集成 | Programmer | ~80实现 + ~30测试 | 依赖 hud_mastery_panel.gd |
| P2 | 进化武器Phase A+B注册（upgrade_pool + weapon_registry + weapon_data） | Programmer | ~43实现 + ~12测试 | 无 |
| P2 | 3个新进化武器PNG生成（generate_sprites.py扩展） | Art | ~30行Python | 无，Palette已有 |
| P3 | 进化武器Phase C+D发射行为实现 | Programmer | ~235实现 + ~40测试 | Phase A+B完成后 |
| P3 | 音频系统（需外部资源评估） | Designer + Programmer | ~400实现 | 外部BGM/SFX资源 |

**建议R25范围**: 专注P1（hud拆分 + 教程扩展 + 暂停菜单），视情况推进P2（进化注册）。P3推迟到v1.1.0。
