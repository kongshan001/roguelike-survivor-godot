# 敌人行为动画视觉规范

**版本**: R18
**日期**: 2026-04-17
**作者**: Art Agent
**目标读者**: Programmer Agent, QA Agent
**前置**: phase3-enemy-design.md, art-log.md R16 敌人动画框架

## 1. 概述

本文档细化全部 10 种敌人的视觉反馈动画，涵盖受伤反馈、死亡效果、Boss 出场、精英差异化四个方面。所有动画基于 Sprite2D 的 modulate / scale / rotation 属性实现，不需要新增 PNG 精灵。

### 1.1 动画类型总览

| 动画类型 | 适用范围 | 触发条件 | 实现方式 |
|---------|---------|---------|---------|
| 受伤闪烁 | 全部敌人 | 受到伤害 | modulate 白闪 |
| 击退抖动 | 全部敌人 | 受到伤害 | position 微偏移 |
| 死亡效果 | 全部敌人 | HP <= 0 | scale + modulate.a + rotation 组合 |
| Boss 出场 | Boss | 首次生成 | scale + 光环 + 屏幕震动 |
| 精英光环脉动 | 精英敌人 | 持续 | modulate 微脉动 |

---

## 2. 受伤反馈 (Hit Feedback)

### 2.1 通用受伤闪烁

所有敌人受伤时统一触发白色闪烁效果。

| 属性 | 值 | 说明 |
|------|-----|------|
| 闪烁颜色 | Color(8, 8, 8) | HDR 白色过曝效果 |
| 闪烁时长 | 0.1s | 极短暂闪白 |
| 闪烁次数 | 1 次 | 不多次闪烁 |
| 恢复颜色 | Color(1, 1, 1) | 标准白色（modulate 默认值） |
| 缓动 | linear | 无缓动，即时切换 |

**实现代码**:
```gdscript
# enemy.gd take_damage() 中，伤害计算之后:
if sprite and is_instance_valid(sprite):
    sprite.modulate = Color(8, 8, 8)  # HDR 白闪
    var t := create_tween()
    t.tween_property(sprite, "modulate", Color.WHITE, 0.1)
```

### 2.2 击退抖动 (Knockback Shake)

受伤时配合闪烁添加轻微位置抖动，增强打击感。

| 属性 | 值 | 说明 |
|------|-----|------|
| 抖动强度 | 2.0 px | 轻微偏移 |
| 抖动次数 | 2 次 | 左右各一次 |
| 单次时长 | 0.03s | 极快 |
| 抖动方向 | 随机水平偏移 | Vector2(sign, 0) * 2.0 |
| 总时长 | 0.06s | 2 x 0.03s |

**实现代码**:
```gdscript
# enemy.gd take_damage() 中，闪烁之后:
if sprite and is_instance_valid(sprite):
    var shake_dir := Vector2(2.0 if randi() % 2 == 0 else -2.0, 0.0)
    var t := create_tween()
    t.tween_property(sprite, "position", shake_dir, 0.03).set_relative(true)
    t.tween_property(sprite, "position", -shake_dir * 0.5, 0.03).set_relative(true)
    t.tween_property(sprite, "position", Vector2.ZERO, 0.02).set_relative(true)
```

### 2.3 受伤闪烁与击退组合时序

```
t=0.00s: modulate = Color(8,8,8), position 偏移 +2px
t=0.03s: position 偏移 -1px
t=0.05s: position 恢复
t=0.10s: modulate = Color.WHITE (闪烁结束)
```

---

## 3. 敌人死亡效果 (Death Effects)

每种敌人有独特的死亡动画，通过 scale / modulate.a / rotation 组合实现。

### 3.1 僵尸 (zombie) -- 倒地压扁

| 阶段 | 属性变化 | 时长 | 缓动 | 说明 |
|------|---------|------|------|------|
| 倒地 | scale: (1,1) -> (1.3, 0.3) | 0.3s | ease_in | 横向拉伸 + 纵向压扁 |
| 淡出 | modulate.a: 1.0 -> 0.0 | 0.3s | ease_in | 同步淡出 |
| 变暗 | modulate: Color(1,1,1) -> Color(0.3,0.2,0.1) | 0.15s | linear | 先变暗再淡出 |

**颜色说明**: 死亡时先变为深棕色 Color(0.3, 0.2, 0.1)（暗示腐烂），然后淡出消失。

### 3.2 蝙蝠 (bat) -- 旋转下坠

| 阶段 | 属性变化 | 时长 | 缓动 | 说明 |
|------|---------|------|------|------|
| 下坠 | scale: (1,1) -> (0.3, 0.3) | 0.25s | ease_in | 缩小 |
| 旋转 | rotation: 0 -> 6.28 (1圈) | 0.25s | linear | 全速旋转 |
| 淡出 | modulate.a: 1.0 -> 0.0 | 0.2s | ease_in | 后半段开始淡出 |
| 下移 | position.y: +8px | 0.25s | ease_in | 模拟坠落 |

**颜色说明**: 无特殊变色，保持原紫色，仅通过旋转+缩小+下坠表达"击落"感。

### 3.3 骷髅 (skeleton) -- 散架淡出

| 阶段 | 属性变化 | 时长 | 缓动 | 说明 |
|------|---------|------|------|------|
| 散架 | scale: (1,1) -> (1.2, 0.5) | 0.2s | ease_in | 纵向压缩 |
| 分离 | position.y: +5px | 0.2s | ease_in | 上半身下坠 |
| 淡出 | modulate.a: 1.0 -> 0.0 | 0.3s | ease_in | 延迟 0.1s 开始 |
| 变暗 | modulate: -> Color(0.5, 0.5, 0.5) | 0.15s | linear | 先变灰 |

**颜色说明**: 骨白色 Color(0.88, 0.88, 0.88) -> 灰色 Color(0.5, 0.5, 0.5) -> 透明。

### 3.4 精英骷髅 (elite_skeleton) -- 盔甲碎裂

| 阶段 | 属性变化 | 时长 | 缓动 | 说明 |
|------|---------|------|------|------|
| 碎裂 | scale: (1,1) -> (1.4, 1.4) -> (0.1, 0.1) | 0.15s + 0.2s | ease_out / ease_in | 先微膨胀再缩小 |
| 旋转 | rotation: 0 -> 1.57 (90度) | 0.35s | ease_in | 倾斜倒下 |
| 淡出 | modulate.a: 1.0 -> 0.0 | 0.25s | ease_in | 与缩小同步 |
| 变暗 | modulate: -> Color(0.4, 0.1, 0.1) | 0.15s | linear | 暗红 |

**颜色说明**: 深红色 Color(0.72, 0.11, 0.11) -> 暗红 Color(0.4, 0.1, 0.1)，暗示盔甲碎裂后褪色。

### 3.5 幽灵 (ghost) -- 消散

| 阶段 | 属性变化 | 时长 | 缓动 | 说明 |
|------|---------|------|------|------|
| 上飘 | position.y: -15px | 0.4s | ease_out | 向上飘散 |
| 淡出 | modulate.a: 0.7 -> 0.0 | 0.4s | ease_in | 从半透明直接消失 |
| 缩小 | scale: (1,1) -> (0.6, 0.6) | 0.4s | ease_in | 缓慢收缩 |

**颜色说明**: 保持原灰白色，无需变色。幽灵本身 alpha=0.7，死亡时从 0.7 直接淡出到 0.0。

### 3.6 分裂者 (splitter) -- 爆裂分裂

| 阶段 | 属性变化 | 时长 | 缓动 | 说明 |
|------|---------|------|------|------|
| 膨胀 | scale: (1,1) -> (1.5, 1.5) | 0.1s | ease_out | 快速膨胀 |
| 爆裂 | scale: (1.5,1.5) -> (0.0, 0.0) | 0.1s | ease_in | 瞬间缩小 |
| 淡出 | modulate.a: 1.0 -> 0.0 | 0.15s | linear | 快速消失 |
| 闪白 | modulate: Color(1.5,1.5,1.5) | 0.05s | linear | 爆裂瞬间闪白 |

**颜色说明**: 膨胀时闪白 Color(1.5, 1.5, 1.5)，强调分裂的"爆裂"感。

### 3.7 小分裂者 (splitter_small) -- 快速消散

| 阶段 | 属性变化 | 时长 | 缓动 | 说明 |
|------|---------|------|------|------|
| 缩小 | scale: (1,1) -> (0.0, 0.0) | 0.15s | ease_in | 快速缩小 |
| 淡出 | modulate.a: 1.0 -> 0.0 | 0.15s | ease_in | 同步淡出 |

**颜色说明**: 无特殊变色。小分裂者是最弱敌人，死亡效果最简单。

### 3.8 火焰史莱姆 (fire_slime) -- 熄灭

| 阶段 | 属性变化 | 时长 | 缓动 | 说明 |
|------|---------|------|------|------|
| 压扁 | scale: (1,1) -> (1.4, 0.4) | 0.25s | ease_in | 像僵尸倒地 |
| 变暗 | modulate: -> Color(0.3, 0.15, 0.05) | 0.15s | linear | 火焰熄灭变灰暗 |
| 淡出 | modulate.a: 1.0 -> 0.0 | 0.2s | ease_in | 与压扁同步 |

**颜色说明**: 橙红色 Color(1.0, 0.4, 0.133) -> 暗褐色 Color(0.3, 0.15, 0.05)，模拟火焰熄灭后的焦色。

### 3.9 精英骑士 (elite_knight) -- 重装倒地

| 阶段 | 属性变化 | 时长 | 缓动 | 说明 |
|------|---------|------|------|------|
| 倾斜 | rotation: 0 -> 1.05 (60度) | 0.35s | ease_in | 向一侧倒下 |
| 下沉 | position.y: +10px | 0.35s | ease_in | 重甲下坠 |
| 变暗 | modulate: -> Color(0.2, 0.1, 0.3) | 0.2s | linear | 暗紫褪色 |
| 淡出 | modulate.a: 1.0 -> 0.0 | 0.3s | ease_in | 延迟 0.15s |

**颜色说明**: 暗紫色 Color(0.267, 0.133, 0.4) -> 极暗紫 Color(0.2, 0.1, 0.3)，盔甲光泽消散。

### 3.10 Boss -- 多阶段死亡 (Boss Death Sequence)

Boss 死亡是最壮观的死亡效果，分三个阶段：

| 阶段 | 属性变化 | 时长 | 缓动 | 说明 |
|------|---------|------|------|------|
| 震惊 | scale: (1,1) -> (1.15, 1.15) | 0.1s | ease_out | 先膨胀 |
| 抖动 | position: 随机 +/- 4px x 3次 | 0.15s | linear | 剧烈抖动 |
| 爆炸 | scale: (1.15,1.15) -> (2.0, 2.0) | 0.15s | ease_out | 膨胀放大 |
| 闪白 | modulate: Color(5, 5, 5) | 0.05s | linear | 爆炸闪光 |
| 碎裂 | scale: (2.0,2.0) -> (0.0, 0.0) | 0.3s | ease_in | 急速缩小 |
| 淡出 | modulate.a: 1.0 -> 0.0 | 0.3s | ease_in | 与缩小同步 |
| 屏幕震动 | 强度 8.0, 衰减 10.0/s | 0.8s | -- | 最强震动 |
| 金光闪烁 | modulate: Color(1,0.9,0.3) | 0.1s | -- | Boss 死亡金色奖励闪光 |

**总时长**: ~0.85s

**颜色变化路径**: 红色 -> 白色(HDR 闪白) -> 金色(奖励) -> 透明

**实现代码**:
```gdscript
# boss_ai.gd die() 函数中:
var t := create_tween()
# 阶段1: 震惊膨胀
t.tween_property(sprite, "scale", Vector2(1.15, 1.15), 0.1).set_ease(Tween.EASE_OUT)
# 阶段2: 抖动
for i in range(3):
    var dir := Vector2(randf_range(-4, 4), randf_range(-4, 4))
    t.tween_property(sprite, "position", dir, 0.05).set_relative(true)
    t.tween_property(sprite, "position", -dir * 0.5, 0.03).set_relative(true)
# 阶段3: 爆炸膨胀 + 闪白
t.tween_property(sprite, "scale", Vector2(2.0, 2.0), 0.15).set_ease(Tween.EASE_OUT)
t.parallel().tween_property(sprite, "modulate", Color(5, 5, 5), 0.05)
# 阶段4: 碎裂缩小 + 金光 + 淡出
t.tween_property(sprite, "modulate", Color(1.0, 0.9, 0.3), 0.05)  # 金光
t.tween_property(sprite, "scale", Vector2.ZERO, 0.3).set_ease(Tween.EASE_IN)
t.parallel().tween_property(sprite, "modulate:a", 0.0, 0.3).set_ease(Tween.EASE_IN)
# 屏幕震动
if has_node("/root/Arena/Camera2D"):
    Arena.camera_shake(8.0)
```

---

## 4. Boss 出场动画 (Boss Entrance)

### 4.1 出场参数

Boss 生成时播放隆重的出场动画，持续约 1.5s。

| 阶段 | 属性变化 | 时长 | 缓动 | 说明 |
|------|---------|------|------|------|
| 缩放 | scale: (0.0, 0.0) -> (1.3, 1.3) | 0.4s | ease_out | 从无到过冲 |
| 回弹 | scale: (1.3, 1.3) -> (1.0, 1.0) | 0.2s | ease_in_out | 过冲回弹 |
| 淡入 | modulate.a: 0.0 -> 1.0 | 0.3s | ease_out | 与缩放同步 |
| 闪红 | modulate: Color(3, 0.5, 0.3) -> Color.WHITE | 0.2s | ease_out | 红色光晕 |
| 光环脉动 | scale.x: 1.0 -> 1.05 -> 1.0 | 0.8s | ease_in_out | 循环脉动 |

### 4.2 出场屏幕效果

| 效果 | 参数 | 说明 |
|------|------|------|
| 屏幕震动 | 强度 5.0, 衰减 8.0/s | Boss 登场震感 |
| 暗角 | Color(0, 0, 0, 0.3) 边缘 vignette | 暗场聚焦 Boss（可选，需程序实现） |
| Boss 警告横幅 | 已有（2.5s 红色脉动） | 提前 15s 触发 |

### 4.3 出场动画时序

```
t=0.00s: scale=(0,0), alpha=0, 屏幕震动开始
t=0.00s-0.30s: scale 增长至 (1.0, 1.0), alpha 淡入
t=0.30s-0.40s: scale 继续至 (1.3, 1.3) 过冲
t=0.40s: 闪红光晕 Color(3, 0.5, 0.3)
t=0.40s-0.60s: scale 回弹至 (1.0, 1.0), 闪红消退
t=0.60s+: 进入待机状态, 光环脉动循环开始
```

### 4.4 Boss 待机光环脉动

| 属性 | 值 | 循环 |
|------|-----|------|
| scale | (1.0, 1.0) <-> (1.05, 1.05) | 是 |
| 周期 | 1.2s (0.6s/方向) | ease_in_out |
| modulate | Color(1.0, 0.95, 0.95) <-> Color.WHITE | 同步微脉动 |

---

## 5. 精英敌人视觉差异化 (Elite Visual Differentiation)

### 5.1 精英骷髅 (elite_skeleton) 差异化

| 视觉属性 | 普通骷髅 | 精英骷髅 | 差异说明 |
|---------|---------|---------|---------|
| 基础尺寸 | 14px | 18px | 体型更大 |
| 配色 | 骨白 #E0E0E0 | 深红 #B81C1C | 阵营色完全不同 |
| 受伤闪烁 | 标准白闪 0.1s | 白闪 + 红光残留 0.15s | 精英受伤后短暂泛红 |
| 死亡效果 | 简单散架 | 盔甲碎裂(微膨胀+缩小) | 更壮观的死亡 |
| 持续光环 | 无 | 金色眼睛脉动 | 头部 2px 金色点 alpha 0.7-1.0 循环 |

**精英受伤红色残留**:
```gdscript
# elite_skeleton 受伤后额外效果:
if enemy_data.enemy_id == "elite_skeleton":
    sprite.modulate = Color(8, 8, 8)  # 标准白闪
    var t := create_tween()
    t.tween_property(sprite, "modulate", Color(1.5, 0.8, 0.7), 0.08)  # 泛红
    t.tween_property(sprite, "modulate", Color.WHITE, 0.07)  # 恢复
```

### 5.2 精英骑士 (elite_knight) 差异化

| 视觉属性 | 普通敌人 | 精英骑士 | 差异说明 |
|---------|---------|---------|---------|
| 基础尺寸 | 16px | 24px | 明确的中间层级 |
| 配色 | 各自阵营色 | 暗紫 #442266 | 新阵营色系 |
| 受伤闪烁 | 标准白闪 0.1s | 白闪 + 紫电弧 0.2s | 受伤时紫光闪烁 |
| 死亡效果 | 基础淡出 | 重装倒地(倾斜+下沉) | 更庄重的倒下 |
| 持续光环 | 无 | 紫色粒子漂浮(alpha=150) | 精灵自带光环粒子 |
| 移动动画 | 无 | 披风飘动(rotation 微摆) | 走路时斗篷摆动 |

**精英骑士受伤紫电弧**:
```gdscript
if enemy_data.enemy_id == "elite_knight":
    sprite.modulate = Color(8, 8, 8)
    var t := create_tween()
    t.tween_property(sprite, "modulate", Color(1.5, 0.6, 2.0), 0.1)  # 紫光闪烁
    t.tween_property(sprite, "modulate", Color.WHITE, 0.1)
```

**精英骑士披风飘动** (待机循环):
```gdscript
if enemy_data.enemy_id == "elite_knight":
    var t := create_tween().set_loops()
    t.tween_property(sprite, "rotation", 0.03, 0.4).set_ease(Tween.EASE_IN_OUT)
    t.tween_property(sprite, "rotation", -0.03, 0.4).set_ease(Tween.EASE_IN_OUT)
```

### 5.3 Boss 持续视觉特征

| 视觉特征 | 规格 | 说明 |
|---------|------|------|
| 尺寸 | 64x64 (游戏中 scale=0.5 显示 32px) | 最大敌人 |
| 光环脉动 | scale (1.0,1.0) <-> (1.05,1.05), 1.2s 周期 | R4 已定义 |
| 角色发光 | 双角金色眼(alpha 脉动 0.8-1.0, 0.8s 周期) | 面部金色高光点 |
| 胸甲闪光 | 每 3s 闪白一次(modulate 白色 0.05s) | 暗示金属质感 |
| 阶段变化 | Phase 2+ 身体发红(modulate 偏红), Phase 3 红色加强 | 难度视觉递进 |

**Boss 阶段变色**:
```gdscript
# boss_ai.gd _enter_phase() 中:
func _enter_phase(phase: int) -> void:
    match phase:
        2:
            sprite.modulate = Color(1.1, 0.9, 0.9)  # 微红
        3:
            sprite.modulate = Color(1.3, 0.7, 0.6)  # 明显偏红
```

---

## 6. 死亡效果汇总表

| 敌人 | 总时长 | scale 变化 | rotation | modulate 变化 | position 变化 | 特点 |
|------|--------|-----------|----------|-------------|-------------|------|
| 僵尸 | 0.3s | (1,1)->(1.3,0.3) | 无 | 变暗->淡出 | 无 | 倒地压扁 |
| 蝙蝠 | 0.25s | (1,1)->(0.3,0.3) | 0->6.28 | 淡出 | +8px 下坠 | 旋转坠落 |
| 骷髅 | 0.3s | (1,1)->(1.2,0.5) | 无 | 变灰->淡出 | +5px 下坠 | 散架 |
| 精英骷髅 | 0.35s | (1,1)->(1.4)->(0.1) | 0->1.57 | 变暗红->淡出 | 无 | 盔甲碎裂 |
| 幽灵 | 0.4s | (1,1)->(0.6,0.6) | 无 | 0.7->0.0 淡出 | -15px 上飘 | 消散 |
| 分裂者 | 0.15s | (1,1)->(1.5)->(0.0) | 无 | 闪白->淡出 | 无 | 爆裂 |
| 小分裂者 | 0.15s | (1,1)->(0.0,0.0) | 无 | 淡出 | 无 | 快速消散 |
| 火焰史莱姆 | 0.25s | (1,1)->(1.4,0.4) | 无 | 变焦色->淡出 | 无 | 熄灭 |
| 精英骑士 | 0.45s | 无 | 0->1.05 | 变暗紫->淡出 | +10px 下沉 | 重装倒地 |
| Boss | 0.85s | (0)->(1.15)->(2.0)->(0) | 无 | 闪白->金色->淡出 | 随机抖动 | 多阶段爆炸 |

---

## 7. 受伤反馈颜色映射

| 敌人 | 受伤闪白色 | 残留变色 | 恢复色 |
|------|-----------|---------|--------|
| 僵尸 | Color(8, 8, 8) | 无 | Color.WHITE |
| 蝙蝠 | Color(8, 8, 8) | 无 | Color.WHITE |
| 骷髅 | Color(8, 8, 8) | 无 | Color.WHITE |
| 精英骷髅 | Color(8, 8, 8) | Color(1.5, 0.8, 0.7) 泛红 | Color.WHITE |
| 幽灵 | Color(8, 8, 8) | 无 | Color.WHITE |
| 分裂者 | Color(8, 8, 8) | 无 | Color.WHITE |
| 小分裂者 | Color(8, 8, 8) | 无 | Color.WHITE |
| 火焰史莱姆 | Color(8, 8, 8) | 无 | Color.WHITE |
| 精英骑士 | Color(8, 8, 8) | Color(1.5, 0.6, 2.0) 紫电弧 | Color.WHITE |
| Boss | Color(8, 8, 8) | 无 | Color.WHITE |

---

## 8. 设计决策记录

1. **受伤闪烁统一使用 HDR Color(8,8,8)**: 标准白色 Color(1,1,1) 在暗色精灵上闪白效果不明显。HDR 值 (8,8,8) 会产生过曝效果，让所有敌人（包括白色骷髅）都能清晰看到闪烁。

2. **击退抖动使用 position 而非 global_position**: sprite 是 enemy 的子节点，修改 sprite.position 作为偏移量，不影响 enemy 的移动逻辑和碰撞判定。

3. **分裂者死亡使用膨胀+爆裂**: 分裂者死亡时产生 2 个子分裂者，"膨胀->缩小"的视觉效果暗示"身体爆开生成子体"。

4. **Boss 死亡分三个阶段**: 震惊->抖动->爆炸的序列模仿经典游戏 Boss 死亡效果（如 Castlevania 的 Boss 爆炸），金色闪光 Color(1.0, 0.9, 0.3) 暗示奖励（Boss 击杀 50 金币）。

5. **精英敌人受伤残留变色**: 普通 0.1s 白闪后恢复正常。精英骷髅额外泛红 0.15s，精英骑士额外紫闪 0.2s，让玩家能通过受伤反馈区分普通和精英敌人。

6. **幽灵死亡使用上飘而非下坠**: 幽灵是飘浮灵异体，物理下坠不合理。向上消散 + 缩小符合"灵魂升天"的视觉隐喻。

7. **Boss 阶段变色**: Phase 1 无变色（红色本体），Phase 2 微红（进入冲锋状态），Phase 3 明显偏红（进入狂暴状态）。变色与行为升级同步，给玩家"Boss 变强了"的视觉提示。

---

## 9. Programmer Agent 集成清单

| 优先级 | 文件 | 集成内容 |
|--------|------|---------|
| P0 | scripts/enemy.gd take_damage() | 通用受伤闪烁 + 击退抖动 |
| P0 | scripts/enemy.gd die() | 按 enemy_id 分支实现 10 种死亡效果 |
| P1 | scripts/boss_ai.gd _enter_phase() | Boss 阶段变色 |
| P1 | scripts/boss_ai.gd die() | Boss 多阶段死亡 + 屏幕震动 |
| P1 | scripts/enemy.gd _ready() | 精英骑士披风飘动循环 + 精英骷髅眼脉动 |
| P2 | scripts/enemy.gd _ready() | Boss 光环脉动 + 胸甲闪光 |
| P2 | scripts/boss_ai.gd die() | Boss 死亡粒子效果 (12个ColorRect碎片) |

---

## 10. 受伤闪烁帧时序 (R19 补充)

### 10.1 通用受伤帧 (全部 10 种敌人)

```
t=0.000s: modulate = Color(8, 8, 8)            -- HDR 白闪开始
t=0.000s: sprite.position.x += shake_dir.x     -- 击退偏移 (+/-2px)
t=0.030s: sprite.position.x -= shake_dir.x*0.5 -- 回弹 (-/+1px)
t=0.050s: sprite.position = Vector2.ZERO        -- 归位
t=0.100s: modulate = Color(1, 1, 1)            -- 恢复正常
```

`shake_dir = Vector2(2.0 if randi()%2==0 else -2.0, 0.0)`

总帧时长: 0.10s

### 10.2 精英骷髅受伤帧 (elite_skeleton)

```
t=0.000s~0.100s: 同通用帧
t=0.100s~0.180s: modulate = Color(8,8,8) -> Color(1.5, 0.8, 0.7)  -- 泛红 0.08s
t=0.180s~0.250s: modulate = Color(1.5, 0.8, 0.7) -> Color.WHITE    -- 恢复 0.07s
```

总帧时长: 0.25s

### 10.3 精英骑士受伤帧 (elite_knight)

```
t=0.000s~0.100s: 同通用帧
t=0.100s~0.200s: modulate = Color(8,8,8) -> Color(1.5, 0.6, 2.0)  -- 紫电弧 0.10s
t=0.200s~0.300s: modulate = Color(1.5, 0.6, 2.0) -> Color.WHITE    -- 恢复 0.10s
```

总帧时长: 0.30s

### 10.4 受伤闪烁强度分级

| 敌人类别 | HDR 值 | 闪白时长 | 残留帧 | 总时长 | 说明 |
|---------|--------|---------|--------|--------|------|
| 普通敌人 (7种) | Color(8, 8, 8) | 0.10s | 无 | 0.10s | 标准白闪 |
| 精英骷髅 | Color(8, 8, 8) | 0.10s | 泛红 0.15s | 0.25s | 受伤泛红 |
| 精英骑士 | Color(8, 8, 8) | 0.10s | 紫电弧 0.20s | 0.30s | 受伤紫闪 |
| Boss | Color(8, 8, 8) | 0.10s | 无 | 0.10s | 同普通，Boss差异通过阶段变色体现 |

---

## 11. Boss 死亡粒子参数 (R19 补充)

Boss 死亡时在"碎裂"阶段产生金色碎片粒子效果。

### 11.1 粒子参数表

| 参数 | 值 | 说明 |
|------|-----|------|
| 粒子数量 | 12 个 | 足够产生碎片感，不造成性能压力 |
| 粒子颜色 | 随机 [Color(1.0,0.9,0.3), Color(0.96,0.26,0.21), Color(1.0,0.84,0.0)] | 金+红+深金三色碎片 |
| 粒子尺寸 | 3x3 ~ 6x6 px | 随机大小，模拟不规则碎片 |
| 初始位置 | Boss 精灵中心 (global_position) | 碎片从 Boss 中心爆出 |
| 发射方向 | 360 度随机 | 全向散射 |
| 发射速度 | 80-160 px/s | 中速散射 |
| 重力 | 120 px/s^2 向下 | 碎片受重力下坠 |
| 初始 alpha | 1.0 | 完全不透明 |
| alpha 衰减 | 1.0 -> 0.0, 0.5s | 0.5s 后完全消失 |
| 旋转速度 | 3-8 rad/s | 碎片翻滚 |
| 生命周期 | 0.5s | 每粒子存活 0.5s |
| 发射时机 | Boss 死亡序列 t=0.55s (碎裂阶段开始时) | 与 Boss 精灵缩小同步 |

### 11.2 ColorRect 手动粒子实现代码

```gdscript
# boss_ai.gd die() 中，碎裂阶段触发时:
var PARTICLE_COLORS := [
    Color(1.0, 0.9, 0.3),    # 金色碎片
    Color(0.96, 0.26, 0.21), # 红色碎片
    Color(1.0, 0.84, 0.0)    # 深金碎片
]

for i in range(12):
    var p := ColorRect.new()
    var size := randf_range(3.0, 6.0)
    p.size = Vector2(size, size)
    p.color = PARTICLE_COLORS[i % 3]
    p.position = global_position - p.size / 2.0
    p.z_index = 5
    get_parent().add_child(p)

    var angle := randf() * TAU
    var speed := randf_range(80.0, 160.0)
    var vel := Vector2(cos(angle), sin(angle)) * speed
    var grav := Vector2(0, 120.0)
    var rot_speed := randf_range(3.0, 8.0)
    var life := 0.5

    var t := create_tween()
    var target_pos := p.position + vel * life + 0.5 * grav * life * life
    t.tween_property(p, "position", target_pos, life)
    t.parallel().tween_property(p, "modulate:a", 0.0, life)
    t.parallel().tween_property(p, "rotation", rot_speed, life).set_relative(true)
    t.tween_callback(p.queue_free)
```

---

## 12. Boss 出场屏幕震动模式 (R19 补充)

### 12.1 震动参数

| 参数 | 值 | 说明 |
|------|-----|------|
| 震动强度 | 5.0 | 比连杀20(7.0)弱，比受伤(3.0)强 |
| 衰减率 | 8.0/s | 快速衰减，Boss 出场震动不应持续过长 |
| 震动持续时间 | 0.625s (5.0 / 8.0) | 自然衰减到 0 |
| 偏移模式 | 随机 Vector2(-1,1) * current_strength | 每帧随机方向 |
| 震动频率 | 每物理帧 (60fps) | 高频抖动 |

### 12.2 震动强度对比表

| 触发条件 | 强度 | 衰减率 | 持续时间 | 体感 |
|---------|------|--------|---------|------|
| 玩家受伤 | 3.0 | 5.0/s | 0.6s | 轻微抖动 |
| Boss 出场 | 5.0 | 8.0/s | 0.625s | 中等震动 |
| 连杀 >=20 | 7.0 | 5.0/s | 1.4s | 强烈震动 |
| Boss 死亡 | 8.0 | 10.0/s | 0.8s | 最强震动 |
| Boss 横幅出现 | 2.0 | 一次 | 0.1s | 轻微一震 |
