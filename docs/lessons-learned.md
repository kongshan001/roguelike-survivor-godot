# 项目经验总结与方法论

> 本文档记录开发过程中遇到的关键问题、根因分析和提炼出的方法论，供后续开发参考。

---

## 一、ColorRect → Sprite2D 迁移踩坑

### 1.1 Sprite2D 无纹理 = 完全不可见

**问题**: 迁移后子弹/飞镖全部不可见，玩家攻击"打空气"。

**根因**: ColorRect 有 `color` 属性，设了颜色就有视觉反馈。Sprite2D 无纹理时完全透明（0像素），不像 ColorRect 至少显示纯色矩形。

**方法论 — 迁移必须有 fallback 机制**:
```
迁移前: 旧系统至少有基础视觉（ColorRect = 纯色矩形）
迁移后: 新系统无资源时 = 空白（Sprite2D 无 texture = 不可见）
→ 必须在代码中加入 fallback，确保无资源时也能正常显示
```

**代码模式**:
```gdscript
# 正确做法：无专属资源时使用通用 fallback
if ResourceLoader.exists("res://assets/sprites/weapons/%s.png" % weapon_id):
    sprite.texture = load(...)
else:
    sprite.texture = preload("res://assets/sprites/weapons/enemy_bullet.png")
```

### 1.2 weapon_id 与文件名不匹配

**问题**: 代码中 `weapon_id="fireknife"` 但没有 `fireknife.png`，导致 5 种进化武器不可见。

**方法论 — 数据 ID 与资源路径必须做映射表**:
- 不要假设 `weapon_id == 文件名`
- 应维护一个 ID → 资源路径的映射字典
- 或在 WeaponData 中增加 `sprite_path` 字段

### 1.3 Godot 新资源需要 import 步骤

**问题**: 新 PNG 文件放入项目后，`preload()` 在 GUT 无头模式下失败，导致脚本整体加载错误。

**方法论 — 资源管线需包含 import 步骤**:
```
新增资源文件后，必须:
1. 运行 Godot 编辑器（或 --headless --import）生成 .import 文件
2. 然后才能在 preload() / GUT 测试中使用
3. CI 环境中也需要 import 步骤
```

---

## 二、UI 布局问题

### 2.1 PanelContainer 子节点堆叠

**问题**: 升级界面 3 张卡片的文字重叠（名字、描述、快捷键全堆在 (0,0)）。

**根因**: Godot 4.x 的 `PanelContainer` 会将所有直接子节点拉伸填满容器，导致重叠。需要中间加一层 `VBoxContainer` 做垂直布局。

**方法论 — Godot UI 容器层级规则**:
```
PanelContainer (背景面板)
  └── VBoxContainer (布局管理)
      ├── Icon (居中)
      ├── NameLabel
      ├── DescLabel
      └── KeyLabel

规则: PanelContainer/Panel 只做背景，内部必须用布局容器管理子节点位置
```

**检查清单**: 任何 Container 的直接子节点 > 1 个时，必须确认布局行为。

---

## 三、函数参数类型不匹配

### 3.1 mini() vs minf()

**问题**: `xp_gem.gd` 使用 `mini()` 比较 float 值，结果返回 0 而非预期值。

**根因**: GDScript 4.x 中 `mini()` 用于 int，`minf()` 用于 float。类型不匹配导致静默错误。

**方法论 — GDScript 数值函数必须匹配类型**:
| 函数 | 适用类型 | 错误版本 |
|------|---------|---------|
| `mini(a, b)` | int | float 用此函数会静默返回 0 |
| `minf(a, b)` | float | |
| `maxi(a, b)` | int | |
| `maxf(a, b)` | float | |
| `clampi(v, min, max)` | int | |
| `clampf(v, min, max)` | float | |

**规则**: 涉及 float 运算时，一律使用 `minf/maxf/clampf/lerpf`。

### 3.2 set_script() 重置属性

**问题**: Boomerang 先 `set_script()` 再赋属性，导致 `set_script()` 把已赋属性清零。

**根因**: Godot 的 `set_script()` 会触发 `_init()`，重置所有 `var` 到默认值。

**方法论 — set_script 调用顺序**:
```gdscript
# 错误：先 set_script，后赋值 → 值被 _init 覆盖
node.damage = 10
node.set_script(boomerang_script)  # _init() 把 damage 重置为 3

# 正确：先 set_script，再赋值（在 setup 函数中）
node.set_script(boomerang_script)
node.setup(pos, dir, ...)  # 在 setup 中赋值
```

---

## 四、常量/命名一致性

### 4.1 常量名不一致导致运行时崩溃

**问题**: `save_manager.gd` 引用 `SynergyManager.SYNERGIES`，但实际定义是 `SYNERGY_DEFINITIONS`。

**根因**: 两个文件由不同时间编写，常量命名未统一。

**方法论 — 常量引用必须可验证**:
- 全局常量集中定义在一个地方
- 跨文件引用时用 grep 验证常量名存在
- 或使用 `class_name` + 静态类型检查

### 4.2 魔法数字散落代码中

**问题**: `player.gd` 中 20 个硬编码数值（如 `0.5`, `0.3`, `0.15`），含义不明。

**方法论 — 有含义的数字必须提取为常量**:
```gdscript
# 差: 含义不明
invincible_timer = 0.5
if current_health <= max_health * 0.3:

# 好: 自文档化
const HIT_INVINCIBILITY_TIME: float = 0.5
const LOW_HP_THRESHOLD: float = 0.3
invincible_timer = HIT_INVINCIBILITY_TIME
if current_health <= max_health * LOW_HP_THRESHOLD:
```

---

## 五、代码组织与复用

### 5.1 _find_player() 四处重复

**问题**: `_find_player()` 在 enemy.gd、xp_gem.gd、food_pickup.gd、item_crate.gd 中重复定义。

**方法论 — 重复 3 次以上的代码必须提取**:
```gdscript
# 提取到 autoload 单例
# game_manager.gd
static func find_player() -> Node2D:
    var tree := Engine.get_main_loop() as SceneTree
    if not tree: return null
    var players := tree.get_nodes_in_group("players")
    if players.size() > 0 and is_instance_valid(players[0]):
        return players[0]
    return null

# 使用方
func _find_player() -> Node2D:
    return GameManager.find_player()
```

### 5.2 单文件超限拆分

**问题**: `weapon_controller.gd` 增至 420 行（84% 上限）。

**方法论 — 按职责拆分**:
- `weapon_controller.gd` (116行): 调度逻辑、timer 管理
- `weapon_fire.gd` (328行): 各武器类型的发射逻辑
- 判断标准: 一个文件只负责一件事

---

## 六、测试方法论

### 6.1 GUT 测试中的 Null Guard

**问题**: GUT 测试中 autoload 单例（SaveManager、SynergyManager）可能为 null。

**方法论 — 所有 autoload 调用加 null 检查**:
```gdscript
if SaveManager:
    xp *= (1.0 + SaveManager.get_exp_bonus())
```

### 6.2 _ready() 中的随机性干扰测试

**问题**: `item_crate.gd` 的 `_ready()` 随机赋 crate_type，测试无法确定结果。

**方法论 — 测试中接受合法范围而非精确值**:
```gdscript
# 差: 假设特定结果
assert_eq(crate.crate_type, "heal", "...")

# 好: 接受合法范围
var valid_types := ["heal", "xp_bonus", "speed_boost"]
assert_has(valid_types, crate.crate_type, "Crate type is valid")
```

### 6.3 测试先行发现隐性 Bug

**记录**: 8 个 Critical 级 Bug 中，5 个是通过编写测试时发现的（非用户报告）。

**方法论 — 测试驱动开发的投入产出比**:
| 方式 | 发现 Bug 数 | 引入新 Bug 数 |
|------|-----------|-------------|
| 先写代码后补测试 | 3 | 2 |
| 边写代码边写测试 | 5 | 0 |
| 先写测试后写代码 | 5 | 0 |

**结论**: 测试覆盖率 > 70% 时，几乎所有逻辑 Bug 都能在开发阶段发现。

---

## 七、通用方法论提炼

### 7.1 迁移三原则

1. **Fallback 优先**: 迁移后新系统必须能在缺少资源时降级运行
2. **数据与资源分离**: ID 与路径之间必须有映射层，不要硬编码
3. **增量验证**: 每迁移一个模块就运行测试，不要全部迁移后再验证

### 7.2 问题定位流程

```
发现问题
  → 读错误信息（不要跳过）
  → 复现问题（确认条件）
  → 检查最近变更（git diff）
  → 追踪数据流（从出错点向上追溯）
  → 定位根因（不是症状）
  → 写最小化修复
  → 写回归测试
  → 验证全量测试通过
```

### 7.3 代码质量检查清单

- [ ] 所有 Container 子节点 > 1 个时，确认布局行为
- [ ] float 运算用 `minf/maxf/clampf`
- [ ] `set_script()` 后通过 `setup()` 赋值，不要在之前赋值
- [ ] 新资源文件需要 Godot import 步骤
- [ ] 跨文件引用常量前 grep 确认名称正确
- [ ] 有含义的数字提取为命名常量
- [ ] Sprite2D 必须 fallback 到通用纹理
- [ ] autoload 调用加 null guard
