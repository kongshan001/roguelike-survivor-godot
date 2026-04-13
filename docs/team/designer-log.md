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
