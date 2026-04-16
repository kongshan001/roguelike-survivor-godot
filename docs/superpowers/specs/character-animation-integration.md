# 角色动画集成方案

**版本**: R17
**日期**: 2026-04-17
**作者**: Art Agent
**目标读者**: Programmer Agent

## 背景

当前 `player.gd` 使用单个 `Sprite2D` 节点加载静态角色精灵。R16 新增了 3 个动画帧精灵:
- `assets/sprites/characters/mage_cast.png` (32x32)
- `assets/sprites/characters/warrior_block.png` (32x32)
- `assets/sprites/characters/ranger_draw.png` (32x32)

目标: 玩家移动时在帧 1 (idle) 和帧 2 (action) 之间以 4 FPS 交替，停止时冻结为帧 1。

## 方案对比

### 方案 A: AnimatedSprite2D (Godot 内置)

#### 概述
将 `player.tscn` 中的 `Sprite2D` 节点替换为 `AnimatedSprite2D`，创建 SpriteFrames 资源配置 2 帧动画。

#### 代码修改点

| 文件 | 行号 | 修改内容 |
|------|------|---------|
| `scenes/player.tscn` | 20-21 | 将 `[node name="Sprite" type="Sprite2D"]` 替换为 `[node name="Sprite" type="AnimatedSprite2D"]`，添加 SpriteFrames 子资源 |
| `scripts/player.gd` | 105 | `@onready var sprite: Sprite2D = $Sprite` 改为 `@onready var sprite: AnimatedSprite2D = $Sprite` |
| `scripts/player.gd` | 126-141 | `_ready()` 中按角色类型设置 SpriteFrames 的帧纹理 |
| `scripts/player.gd` | 181 | `_physics_process()` 中根据 `is_moving` 控制 `sprite.play()` / `sprite.pause()` |

#### 实现代码

**player.tscn 修改**:

```
[sub_resource type="SpriteFrames" id="CharacterFrames"]
animations = [{
"frames": [{
"duration": 1.0,
"texture": ExtResource("mage_idle")
}, {
"duration": 1.0,
"texture": ExtResource("mage_cast")
}],
"loop": true,
"name": &"walk",
"speed": 4.0
}]

[node name="Sprite" type="AnimatedSprite2D" parent="."]
sprite_frames = SubResource("CharacterFrames")
animation = &"walk"
centered = true
```

**player.gd 修改**:

```gdscript
# 第 105 行: 类型改为 AnimatedSprite2D
@onready var sprite: AnimatedSprite2D = $Sprite

# _ready() 中按角色类型动态设置帧纹理
func _setup_character_animation() -> void:
    var frames := SpriteFrames.new()
    frames.add_animation("walk")
    frames.set_animation_speed("walk", 4.0)
    frames.set_animation_loop("walk", true)

    match GameManager.selected_character:
        "warrior":
            frames.add_frame("walk", preload("res://assets/sprites/characters/warrior.png"))
            frames.add_frame("walk", preload("res://assets/sprites/characters/warrior_block.png"))
            _char_color = Color(0.83, 0.18, 0.18)
        "ranger":
            frames.add_frame("walk", preload("res://assets/sprites/characters/ranger.png"))
            frames.add_frame("walk", preload("res://assets/sprites/characters/ranger_draw.png"))
            _char_color = Color(0.18, 0.45, 0.2)
        "mage":
            frames.add_frame("walk", preload("res://assets/sprites/characters/mage.png"))
            frames.add_frame("walk", preload("res://assets/sprites/characters/mage_cast.png"))
            _char_color = Color(0.08, 0.4, 0.75)

    sprite.sprite_frames = frames
    sprite.animation = "walk"
    sprite.stop()  # 初始静止在帧 0

# _physics_process() 中添加动画控制 (约第 181 行之后)
    # 动画控制
    if is_moving:
        if not sprite.is_playing():
            sprite.play("walk")
    else:
        if sprite.is_playing():
            sprite.stop()
            sprite.frame = 0  # 回到 idle 帧
```

#### 优点
1. **Godot 原生方案**: AnimatedSprite2D 专门为精灵动画设计，API 清晰
2. **帧率控制精确**: `set_animation_speed("walk", 4.0)` 直接设定 FPS
3. **播放状态查询方便**: `is_playing()`, `frame` 属性可直接使用
4. **支持未来扩展**: 如需添加更多帧(受伤/攻击/死亡动画)，只需增加 SpriteFrames 条目
5. **编辑器可视化**: 可在 Godot 编辑器中预览动画效果

#### 缺点
1. **需要修改 .tscn 文件**: Art Agent 禁止修改 .tscn，需 Programmer Agent 执行
2. **SpriteFrames 子资源**: 需要在 .tscn 中定义子资源或动态创建
3. **测试回归风险**: player.tscn 节点类型变更可能导致现有引用 `sprite.texture` 的代码报错
4. **残影系统适配**: `_spawn_afterimages()` 使用 `sprite.texture`，AnimatedSprite2D 没有 `texture` 属性，需改为 `sprite.sprite_frames.get_frame_texture("walk", 0)`

#### 受影响代码 (需同步修改)

| 位置 | 当前代码 | 修改后 |
|------|---------|--------|
| player.gd:129 `sprite.texture = preload(...)` | 直接设置纹理 | 移除，改为 `_setup_character_animation()` |
| player.gd:400 `afterimage.texture = sprite.texture` | 获取当前纹理 | `afterimage.texture = sprite.sprite_frames.get_frame_texture("walk", sprite.frame)` |

---

### 方案 B: Sprite2D + Timer 手动切换

#### 概述
保持 Sprite2D 不变，添加 Timer 节点控制帧切换。

#### 代码修改点

| 文件 | 行号 | 修改内容 |
|------|------|---------|
| `scripts/player.gd` | 新增 | 添加 `_anim_timer: Timer` 变量和 `_anim_frame: int` 变量 |
| `scripts/player.gd` | _ready() | 创建 Timer 节点，加载两帧纹理 |
| `scripts/player.gd` | _physics_process() | 根据 is_moving 启停 Timer |

#### 实现代码

```gdscript
# 新增成员变量
var _anim_timer: Timer = null
var _anim_frame: int = 0
var _idle_texture: Texture2D = null
var _action_texture: Texture2D = null
const ANIM_FPS: float = 4.0

# _ready() 中添加:
func _setup_character_animation() -> void:
    _anim_timer = Timer.new()
    _anim_timer.wait_time = 1.0 / ANIM_FPS  # 0.25s
    _anim_timer.one_shot = false
    _anim_timer.timeout.connect(_on_anim_timer_timeout)
    add_child(_anim_timer)

    match GameManager.selected_character:
        "warrior":
            _idle_texture = preload("res://assets/sprites/characters/warrior.png")
            _action_texture = preload("res://assets/sprites/characters/warrior_block.png")
        "ranger":
            _idle_texture = preload("res://assets/sprites/characters/ranger.png")
            _action_texture = preload("res://assets/sprites/characters/ranger_draw.png")
        "mage":
            _idle_texture = preload("res://assets/sprites/characters/mage.png")
            _action_texture = preload("res://assets/sprites/characters/mage_cast.png")

    sprite.texture = _idle_texture

func _on_anim_timer_timeout() -> void:
    _anim_frame = 1 - _anim_frame  # 0 <-> 1 交替
    sprite.texture = _action_texture if _anim_frame == 1 else _idle_texture

# _physics_process() 中:
    # 动画控制
    if is_moving:
        if _anim_timer and _anim_timer.is_stopped():
            _anim_timer.start()
    else:
        if _anim_timer and not _anim_timer.is_stopped():
            _anim_timer.stop()
            _anim_frame = 0
            sprite.texture = _idle_texture
```

#### 优点
1. **不修改 .tscn 文件**: 保持 Sprite2D 节点类型不变
2. **不破坏现有引用**: `sprite.texture` 仍然可用，残影系统无需修改
3. **逻辑清晰**: Timer 回调中切换纹理，简单直观

#### 缺点
1. **Timer 精度问题**: Timer 基于帧时钟，在低帧率下可能不精确
2. **额外节点**: 每帧一个 Timer 节点（虽影响极小）
3. **需要管理 Timer 生命周期**: pause/stop/unpause 时需正确处理 Timer 状态
4. **不够"Godot 惯用"**: Godot 社区更推荐 AnimatedSprite2D 方案

---

### 方案 C: Sprite2D + _physics_process 检测 velocity

#### 概述
保持 Sprite2D 不变，不用 Timer，在 _physics_process 中累计时间切换帧。

#### 代码修改点

| 文件 | 行号 | 修改内容 |
|------|------|---------|
| `scripts/player.gd` | 新增 | `_anim_time: float` 和 `_anim_frame: int` 变量 |
| `scripts/player.gd` | _ready() | 加载两帧纹理 |
| `scripts/player.gd` | _physics_process() | 累计 delta 时间，达到阈值时切换帧 |

#### 实现代码

```gdscript
# 新增成员变量
var _anim_time: float = 0.0
var _anim_frame: int = 0
var _idle_texture: Texture2D = null
var _action_texture: Texture2D = null
const ANIM_INTERVAL: float = 1.0 / 4.0  # 4 FPS = 0.25s

# _ready() 中 (同方案 B):
func _setup_character_animation() -> void:
    match GameManager.selected_character:
        "warrior":
            _idle_texture = preload("res://assets/sprites/characters/warrior.png")
            _action_texture = preload("res://assets/sprites/characters/warrior_block.png")
        "ranger":
            _idle_texture = preload("res://assets/sprites/characters/ranger.png")
            _action_texture = preload("res://assets/sprites/characters/ranger_draw.png")
        "mage":
            _idle_texture = preload("res://assets/sprites/characters/mage.png")
            _action_texture = preload("res://assets/sprites/characters/mage_cast.png")

    sprite.texture = _idle_texture

# _physics_process() 末尾添加:
    # 角色行走动画
    if is_moving and _idle_texture:
        _anim_time += delta
        if _anim_time >= ANIM_INTERVAL:
            _anim_time -= ANIM_INTERVAL
            _anim_frame = 1 - _anim_frame
            sprite.texture = _action_texture if _anim_frame == 1 else _idle_texture
    else:
        _anim_time = 0.0
        _anim_frame = 0
        if _idle_texture:
            sprite.texture = _idle_texture
```

#### 优点
1. **不修改 .tscn 文件**: 保持 Sprite2D 不变
2. **不破坏现有引用**: `sprite.texture` 可用，残影系统无需修改
3. **无额外节点**: 不需要 Timer，纯代码逻辑
4. **与 _physics_process 对齐**: 动画帧切换与物理帧同步，不会出现视觉撕裂
5. **delta 时间精确**: 使用实际 delta 而非固定间隔
6. **代码最少**: 添加代码量最少（~15 行新增）

#### 缺点
1. **不够"Godot 惯用"**: 手动管理帧计数不如 AnimatedSprite2D 优雅
2. **_physics_process 代码膨胀**: 已有大量逻辑，再加动画控制增加复杂度
3. **暂停状态需特殊处理**: get_tree().paused 时 _physics_process 不执行，动画自然停止（实际上是期望行为）

---

## 推荐方案: C (Sprite2D + _physics_process)

### 推荐理由

1. **最小侵入性**: 不修改 player.tscn，不改变节点类型，不破坏 200+ 行测试中的 `sprite.texture` 引用
2. **残影系统零改动**: `_spawn_afterimages()` 第 400 行 `afterimage.texture = sprite.texture` 无需任何修改
3. **代码量最少**: 仅新增 ~15 行代码（2 个纹理变量 + 1 个时间变量 + 1 个帧变量 + _physics_process 中 8 行逻辑）
4. **动画自然停止**: 暂停（升级面板）时 _physics_process 不执行，动画冻结在当前帧；恢复后继续
5. **性能最优**: 无额外 Timer 节点，无 AnimatedSprite2D 引擎开销
6. **is_moving 已存在**: player.gd 第 181 行已有 `is_moving` 变量判断，直接复用

### 实现清单

| 步骤 | 文件 | 位置 | 操作 |
|------|------|------|------|
| 1 | scripts/player.gd | 成员变量区 (约第 106 行后) | 添加 `_anim_time`, `_anim_frame`, `_idle_texture`, `_action_texture`, `ANIM_INTERVAL` |
| 2 | scripts/player.gd | _ready() 末尾 (约第 141 行后) | 添加 `_setup_character_animation()` 调用和函数定义 |
| 3 | scripts/player.gd | _physics_process() 末尾 (约第 217 行前) | 添加动画帧切换逻辑 |
| 4 | 无需修改 | player.tscn | 不修改场景文件 |

### 测试注意

1. 静止时验证 `sprite.texture` 为 idle 纹理
2. 移动时验证帧 0/帧 1 每 0.25s 交替
3. 停止移动后立即回到帧 0
4. 升级面板暂停时动画冻结
5. Dash 时动画状态正确（可考虑 Dash 期间保持当前帧或播放帧 2）
6. 受伤闪烁期间动画不中断（sprite.visible 切换不影响 texture）

---

## 备选: 方案 A 适用场景

如果未来需要添加更多动画帧（如 4 帧行走、8 帧攻击动画），建议迁移到方案 A (AnimatedSprite2D)。当前 2 帧循环的简单场景下，方案 C 是最优选择。
