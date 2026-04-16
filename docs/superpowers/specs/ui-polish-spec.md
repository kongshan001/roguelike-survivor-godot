# UI 打磨视觉规范 (v1.0.2)

**版本**: R18
**日期**: 2026-04-17
**作者**: Art Agent
**目标读者**: Programmer Agent, QA Agent
**前置**: art-log.md R16/R17 UI 动画框架, v1.0.1-priority-assessment.md

## 1. 概述

本文档定义 v1.0.2 的 UI 视觉优化规范，包含 4 项 UI 打磨内容：升级面板卡牌悬浮效果、武器进化预告视觉、成就解锁动画、波次过渡横幅优化。所有效果基于 Tween 动画实现，不需要新增 PNG 精灵。

### 1.1 设计目标

| 目标 | 说明 |
|------|------|
| 提升操控反馈 | 卡牌悬浮效果让升级选择更有交互感 |
| 信息预知 | 武器进化预告让玩家提前规划升级路线 |
| 成就感强化 | 成就解锁动画让里程碑时刻更难忘 |
| 节奏感优化 | 波次过渡横幅增加游戏节奏的仪式感 |

---

## 2. 升级面板卡牌悬浮效果 (Card Hover Effect)

### 2.1 悬浮 (hover) 效果

当鼠标/键盘焦点移到某张升级选项卡上时触发。

| 属性 | 值 | 说明 |
|------|-----|------|
| 缩放 | (1.0, 1.0) -> (1.08, 1.08) | 轻微放大 8% |
| 发光边框 | modulate 偏暖白 Color(1.1, 1.05, 0.95) | 模拟发光 |
| Y 偏移 | -4px | 卡片微微上浮 |
| 时长 | 0.12s | 快速响应 |
| 缓动 | ease_out | 平滑过渡 |

### 2.2 取消悬浮 (unhover) 效果

| 属性 | 值 | 说明 |
|------|-----|------|
| 缩放 | (1.08, 1.08) -> (1.0, 1.0) | 恢复原尺寸 |
| 发光消退 | Color(1.1, 1.05, 0.95) -> Color.WHITE | 发光消退 |
| Y 偏移 | +4px (回到原位) | 卡片下沉 |
| 时长 | 0.1s | 略快于 hover |
| 缓动 | ease_in | 快速收回 |

### 2.3 选中效果 (Card Selected)

当玩家按下 1/2/3 键选择某张卡片时触发。

| 属性 | 值 | 说明 |
|------|-----|------|
| 缩放 | (1.08, 1.08) -> (1.15, 1.15) -> (0.8, 0.8) | 先微放大再缩小 |
| 闪白 | modulate = Color(5, 5, 5) | HDR 白色闪烁 |
| 淡出 | modulate.a: 1.0 -> 0.0 | 选中后淡出 |
| 总时长 | 0.2s | 快速 |
| 缓动 | ease_in | 爽快确认 |

### 2.4 未选中卡片消退

选中的卡片触发后，其余未选中卡片执行消退效果。

| 属性 | 值 | 说明 |
|------|-----|------|
| 缩放 | (1.0, 1.0) -> (0.9, 0.9) | 轻微缩小 |
| 变暗 | modulate: -> Color(0.5, 0.5, 0.5) | 变灰 |
| 淡出 | modulate.a: 1.0 -> 0.0 | 完全消失 |
| 时长 | 0.2s | 与选中卡片同步 |
| 延迟 | 0.05s | 选中卡片效果后稍延迟 |

### 2.5 实现代码

```gdscript
# 在 hud.gd 中，为每张升级选项卡添加鼠标/键盘悬浮检测

func _on_card_hover(card: Control) -> void:
    var t := create_tween()
    t.tween_property(card, "scale", Vector2(1.08, 1.08), 0.12).set_ease(Tween.EASE_OUT)
    t.parallel().tween_property(card, "modulate", Color(1.1, 1.05, 0.95), 0.12)
    t.parallel().tween_property(card, "position:y", -4.0, 0.12).set_relative(true)

func _on_card_unhover(card: Control) -> void:
    var t := create_tween()
    t.tween_property(card, "scale", Vector2.ONE, 0.1).set_ease(Tween.EASE_IN)
    t.parallel().tween_property(card, "modulate", Color.WHITE, 0.1)
    t.parallel().tween_property(card, "position:y", 4.0, 0.1).set_relative(true)

func _on_card_selected(card: Control, all_cards: Array) -> void:
    # 选中卡片效果
    var t := create_tween()
    card.modulate = Color(5, 5, 5)  # HDR 白闪
    t.tween_property(card, "scale", Vector2(1.15, 1.15), 0.08).set_ease(Tween.EASE_OUT)
    t.tween_property(card, "scale", Vector2(0.8, 0.8), 0.12).set_ease(Tween.EASE_IN)
    t.parallel().tween_property(card, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_IN)

    # 未选中卡片消退
    for other in all_cards:
        if other != card:
            var ot := create_tween().set_delay(0.05)
            ot.tween_property(other, "scale", Vector2(0.9, 0.9), 0.15).set_ease(Tween.EASE_IN)
            ot.parallel().tween_property(other, "modulate", Color(0.5, 0.5, 0.5, 0.0), 0.2).set_ease(Tween.EASE_IN)
```

---

## 3. 武器进化预告视觉 (Evolution Preview)

### 3.1 触发条件

当玩家拥有的武器 + 被动满足进化条件时，升级面板中进化武器选项的卡片显示"进化预告"视觉标记。

### 3.2 预告视觉标记

| 元素 | 规格 | 说明 |
|------|------|------|
| 顶部标签 | "EVOLVE" 文字, 金色 Color(1.0, 0.84, 0.0) #FFD700 | 3px 高标签条 |
| 标签背景 | Color(0.1, 0.1, 0.15, 0.8) 半透明暗底 | 金色文字的衬托 |
| 边框发光 | 1px 金色边框 Color(1.0, 0.84, 0.0, 0.6) | 比普通卡片边框更醒目 |
| 光晕脉动 | 0.4 <-> 0.8 alpha, 周期 1.0s | 持续发光暗示"可进化" |
| 箭头图标 | "^" 向上箭头, 金色 8px | 暗示"升级为更强形态" |

### 3.3 进化预告动画

当进化武器选项出现在升级面板中时：

| 阶段 | 属性变化 | 时长 | 缓动 | 说明 |
|------|---------|------|------|------|
| 出场 | scale: (0.5, 0.5) -> (1.0, 1.0) | 0.2s | ease_out_back | 弹性放大 |
| 光晕脉动 | modulate 偏金 Color(1.1, 1.05, 0.9) <-> Color.WHITE | 1.0s | ease_in_out | 循环脉动 |
| 标签淡入 | 标签 alpha: 0.0 -> 1.0 | 0.3s | ease_out | 延迟 0.15s |

### 3.4 进化组合提示

当玩家同时拥有进化所需的两个武器（而非武器+被动）时：

| 元素 | 规格 |
|------|------|
| 提示文字 | "Combine: WeaponA + WeaponB" |
| 文字颜色 | Color(0.7, 0.7, 0.75) 浅灰 |
| 文字大小 | 10px |
| 位置 | 卡片底部 |
| 出现动画 | 淡入 0.3s |

### 3.5 实现代码

```gdscript
# hud.gd 中，_show_upgrade_panel() 里，当 option.is_evolution == true 时:

func _setup_evolution_preview(card: Control, option: Dictionary) -> void:
    # 添加 EVOLVE 顶部标签
    var evolve_label := Label.new()
    evolve_label.name = "EvolveTag"
    evolve_label.text = "EVOLVE"
    evolve_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))  # 金色
    evolve_label.add_theme_font_size_override("font_size", 8)
    evolve_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    evolve_label.position = Vector2(card.size.x / 2 - 20, -2)
    card.add_child(evolve_label)

    # 金色边框 + 光晕脉动
    var glow_tween := create_tween().set_loops()
    glow_tween.tween_property(card, "modulate", Color(1.1, 1.05, 0.9), 0.5).set_ease(Tween.EASE_IN_OUT)
    glow_tween.tween_property(card, "modulate", Color.WHITE, 0.5).set_ease(Tween.EASE_IN_OUT)

    # 进化组合提示（如果有双武器进化信息）
    if option.has("combine_hint"):
        var hint := Label.new()
        hint.text = option.combine_hint
        hint.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
        hint.add_theme_font_size_override("font_size", 10)
        hint.position = Vector2(0, card.size.y - 14)
        card.add_child(hint)
```

---

## 4. 成就解锁动画 (Achievement Unlock Animation)

### 4.1 成就弹出 (Achievement Toast)

当玩家达成成就时，屏幕右下角弹出成就通知。

| 属性 | 值 | 说明 |
|------|-----|------|
| 位置 | 屏幕右下角，距底部 80px，距右边 20px | HUD 上方，不遮挡技能按钮 |
| 尺寸 | 260 x 50 px | 紧凑通知条 |
| 背景 | Color(0.08, 0.08, 0.12, 0.9) 暗底 | 半透明暗紫 |
| 边框 | Color(1.0, 0.84, 0.0) 金色 1px | 成就专属金色 |
| 图标 | 成就类型图标 (16x16) | 左侧 |
| 标题 | 成就名称, 白色, 14px | 居中偏左 |
| 描述 | 成就描述, 灰色 Color(0.7, 0.7, 0.75), 10px | 标题下方 |

### 4.2 成就弹出动画

| 阶段 | 属性变化 | 时长 | 缓动 | 说明 |
|------|---------|------|------|------|
| 滑入 | position.x: +280 -> 0 (从右侧滑入) | 0.4s | ease_out_back | 弹性滑入 |
| 停留 | 无变化 | 2.5s | -- | 阅读时间 |
| 滑出 | position.x: 0 -> +280 | 0.3s | ease_in | 向右滑出 |
| 淡出 | modulate.a: 1.0 -> 0.0 | 0.3s | ease_in | 与滑出同步 |

**总时长**: 3.2s (0.4 + 2.5 + 0.3)

### 4.3 成就类型颜色

| 成就类型 | 边框/标题颜色 | 图标底色 | 说明 |
|---------|-------------|---------|------|
| 战斗 | Color(1.0, 0.3, 0.2) 红 | Color(0.4, 0.1, 0.1) 暗红 | 击杀/连杀/伤害相关 |
| 收集 | Color(1.0, 0.84, 0.0) 金 | Color(0.3, 0.25, 0.05) 暗金 | 武器/被动/金币相关 |
| 生存 | Color(0.3, 0.9, 0.4) 绿 | Color(0.1, 0.3, 0.1) 暗绿 | 存活/波次/无伤相关 |
| 特殊 | Color(0.5, 0.3, 0.9) 紫 | Color(0.15, 0.1, 0.3) 暗紫 | 彩蛋/隐藏成就 |

### 4.4 成就解锁闪光效果

| 属性 | 值 | 说明 |
|------|-----|------|
| 闪白 | modulate = Color(3, 3, 2) | 0.05s 暖色闪光 |
| 金光 | modulate -> Color(1.2, 1.1, 0.8) | 0.1s 金色残留 |
| 恢复 | modulate -> Color.WHITE | 0.15s 恢复正常 |

### 4.5 多成就队列

当多个成就同时解锁时：
- 成就通知按解锁顺序排队
- 每个通知间隔 0.5s 开始
- 同时最多显示 1 个通知（新通知等待旧通知滑出后出现）

### 4.6 实现代码

```gdscript
# 成就通知系统 (可集成到 hud.gd 或独立 achievement_toast.gd)

var _achievement_queue: Array[Dictionary] = []
var _showing_achievement: bool = false

func show_achievement(title: String, desc: String, category: String = "combat") -> void:
    _achievement_queue.append({"title": title, "desc": desc, "category": category})
    if not _showing_achievement:
        _show_next_achievement()

func _show_next_achievement() -> void:
    if _achievement_queue.is_empty():
        _showing_achievement = false
        return
    _showing_achievement = true
    var data := _achievement_queue.pop_front()

    # 颜色映射
    var border_color: Color
    match data.category:
        "combat":  border_color = Color(1.0, 0.3, 0.2)
        "collect": border_color = Color(1.0, 0.84, 0.0)
        "survive": border_color = Color(0.3, 0.9, 0.4)
        "special": border_color = Color(0.5, 0.3, 0.9)
        _:         border_color = Color(1.0, 0.84, 0.0)

    # 创建通知条
    var toast := Panel.new()
    toast.name = "AchievementToast"
    toast.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
    toast.offset_left = -280.0
    toast.offset_top = -130.0
    toast.offset_right = -20.0
    toast.offset_bottom = -80.0
    toast.self_modulate = Color(0.08, 0.08, 0.12, 0.9)

    # 标题
    var title_label := Label.new()
    title_label.text = data.title
    title_label.add_theme_color_override("font_color", Color.WHITE)
    title_label.add_theme_font_size_override("font_size", 14)
    title_label.position = Vector2(24, 4)
    toast.add_child(title_label)

    # 描述
    var desc_label := Label.new()
    desc_label.text = data.desc
    desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
    desc_label.add_theme_font_size_override("font_size", 10)
    desc_label.position = Vector2(24, 24)
    toast.add_child(desc_label)

    add_child(toast)

    # 动画
    var start_x := toast.position.x
    toast.position.x += 280.0  # 从右侧开始
    toast.modulate = Color(3, 3, 2)  # 初始暖色闪光

    var t := create_tween()
    t.tween_property(toast, "modulate", Color(1.2, 1.1, 0.8), 0.05)  # 金光残留
    t.tween_property(toast, "modulate", Color.WHITE, 0.15)
    t.parallel().tween_property(toast, "position:x", start_x, 0.4)\
        .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
    t.tween_interval(2.0)
    t.tween_property(toast, "position:x", start_x + 280.0, 0.3).set_ease(Tween.EASE_IN)
    t.parallel().tween_property(toast, "modulate:a", 0.0, 0.3).set_ease(Tween.EASE_IN)
    t.tween_callback(func():
        toast.queue_free()
        _show_next_achievement()
    )
```

---

## 5. 波次过渡横幅优化 (Wave Transition Banner Enhancement)

### 5.1 当前状态

R9 已创建 5 个波次横幅 PNG (wave_banner_w1~w5.png, 600x80)。R16 定义了滑入/停留/滑出动画参数 (0.4s/2.0s/0.3s)。R17 提供了完整 Tween 代码。

### 5.2 优化内容

在现有波次横幅基础上增加以下视觉增强：

#### 5.2.1 横幅内容层

| 元素 | 规格 | 说明 |
|------|------|------|
| 波次编号 | "WAVE N", 白色, 24px 加粗 | 左侧色带旁 |
| 波次名称 | 波次英文名, 白色, 18px | 编号右侧 |
| 底部描述行 | 敌人预告文字, Color(0.7, 0.7, 0.75) 灰白, 12px | 第二行 |
| 进度条 | 100x4 矩形, 波次色填充 | 底部 10px 居中 |

#### 5.2.2 横幅背景增强

| 属性 | 值 | 说明 |
|------|-----|------|
| 暗幕 | 全屏 ColorRect alpha 0.0 -> 0.3 -> 0.0 | 横幅出现时屏幕微暗 |
| 暗幕时长 | 0.5s 淡入 + 2.0s 保持 + 0.3s 淡出 | 与横幅同步 |
| 扫光效果 | 白色半透明条 alpha=0.15 从左到右扫过 | 横幅停留期间 |

#### 5.2.3 扫光效果参数

| 属性 | 值 | 说明 |
|------|-----|------|
| 扫光宽度 | 80px | 窄条 |
| 扫光颜色 | Color(1, 1, 1, 0.15) | 半透明白 |
| 扫光方向 | 从左到右 (x: -80 -> 680) | 单次 |
| 扫光时长 | 0.8s | 在停留 2.0s 期间执行 |
| 扫光延迟 | 横幅滑入后 0.3s | 延迟启动 |
| 缓动 | linear | 匀速扫过 |

#### 5.2.4 波次预告文字

| 波次 | 描述文字 | 敌人图标 |
|------|---------|---------|
| Wave 1 | "Zombies incoming!" | 绿色点 x3 |
| Wave 2 | "Bats join the fray!" | 紫色点 x2 |
| Wave 3 | "Skeletons & Ghosts!" | 白色点 + 灰白点 |
| Wave 4 | "Elite forces!" | 红色大点 x1 |
| Wave 5 | "BOSS APPROACHES!" | 骷髅图标 (boss_warning.png) |

#### 5.2.5 Boss 波次特殊横幅

Wave 5 (Boss 波次) 使用增强版横幅：

| 属性 | 值 | 说明 |
|------|-----|------|
| 背景 | Color(0.2, 0.02, 0.02, 0.95) 暗红 | 比普通波次更暗更红 |
| 文字颜色 | Color(1.0, 0.2, 0.15) 红色 | 非白色 |
| 脉动 | scale: (1.0,1.0) <-> (1.02,1.02), 0.5s | 横幅本身微脉动 |
| 屏幕震动 | 强度 2.0, 一次 | 横幅出现时 |

### 5.3 实现代码 (增强版)

```gdscript
# 在 R17 的 _show_wave_banner() 基础上增强:

func _show_wave_banner(wave: int, wave_name: String) -> void:
    # 暗幕
    var dimmer := ColorRect.new()
    dimmer.name = "WaveDimmer"
    dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
    dimmer.color = Color(0, 0, 0, 0.0)
    dimmer.z_index = -1
    add_child(dimmer)

    var dim_t := create_tween()
    dim_t.tween_property(dimmer, "color:a", 0.3, 0.5)
    dim_t.tween_interval(2.0)
    dim_t.tween_property(dimmer, "color:a", 0.0, 0.3)
    dim_t.tween_callback(dimmer.queue_free)

    # ... (保留 R17 的横幅创建代码)

    # Boss 波次特殊处理
    if wave == 5:
        _wave_banner.color = Color(0.2, 0.02, 0.02, 0.95)
        _wave_banner_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.15))
        # 屏幕震动
        if has_node("/root/Arena/Camera2D"):
            Arena.camera_shake(2.0)

    # 扫光效果
    var sweep := ColorRect.new()
    sweep.name = "SweepLight"
    sweep.size = Vector2(80, 80)
    sweep.color = Color(1, 1, 1, 0.15)
    sweep.position = Vector2(-80, 0)
    _wave_banner.add_child(sweep)

    var sweep_t := create_tween().set_delay(0.3)
    sweep_t.tween_property(sweep, "position:x", 680.0, 0.8)
    sweep_t.tween_callback(sweep.queue_free)
```

---

## 6. UI 打磨效果汇总表

| UI 元素 | 总时长 | 主要属性 | 缓动 | 新增代码量(估) |
|---------|--------|---------|------|------------|
| 卡牌悬浮 | 0.12s on / 0.1s off | scale + modulate + position.y | ease_out / ease_in | ~30 行 |
| 卡牌选中 | 0.2s | scale + modulate(HDR) + alpha | ease_in | ~20 行 |
| 进化预告 | 持续 | modulate 脉动 + 标签 | ease_in_out | ~25 行 |
| 成就弹出 | 3.2s | position.x + modulate | ease_out_back / ease_in | ~60 行 |
| 波次暗幕 | 2.8s | color.a | ease | ~15 行 |
| 波次扫光 | 0.8s | position.x | linear | ~10 行 |

---

## 7. 配色补充

### 7.1 成就类型配色表

| 成就类型 | 主色 | 边框色 | 图标底色 |
|---------|------|--------|---------|
| 战斗 (combat) | Color(1.0, 0.3, 0.2) #FF4D33 | 同主色 | Color(0.4, 0.1, 0.1) #661A1A |
| 收集 (collect) | Color(1.0, 0.84, 0.0) #FFD700 | 同主色 | Color(0.3, 0.25, 0.05) #4D400D |
| 生存 (survive) | Color(0.3, 0.9, 0.4) #4DE666 | 同主色 | Color(0.1, 0.3, 0.1) #1A4D1A |
| 特殊 (special) | Color(0.5, 0.3, 0.9) #804DE6 | 同主色 | Color(0.15, 0.1, 0.3) #261A4D |

### 7.2 进化预告配色

| 元素 | 颜色 | 说明 |
|------|------|------|
| EVOLVE 标签文字 | Color(1.0, 0.84, 0.0) #FFD700 | 金色，复用项目金色 |
| 标签背景 | Color(0.1, 0.1, 0.15, 0.8) | 半透明暗底 |
| 进化边框 | Color(1.0, 0.84, 0.0, 0.6) | 金色半透明边框 |
| 光晕脉动 | Color(1.1, 1.05, 0.9) <-> Color.WHITE | 暖白微偏金 |
| 组合提示文字 | Color(0.7, 0.7, 0.75) | 浅灰色 |

### 7.3 Boss 横幅配色

| 元素 | 颜色 | 说明 |
|------|------|------|
| 背景 | Color(0.2, 0.02, 0.02, 0.95) | 暗红背景 |
| 文字 | Color(1.0, 0.2, 0.15) | 红色文字 |
| 扫光 | Color(1, 1, 1, 0.15) | 半透明白 |
| 暗幕 | Color(0, 0, 0, 0.3) | 全屏微暗 |

---

## 8. 设计决策记录

1. **卡牌悬浮放大 8% 而非更大**: 8% 是微妙的放大，不会导致卡片文字超出可读范围。10% 以上会导致卡片边缘超出容器或遮挡相邻卡片。8% 放大配合 -4px Y 偏移创造"卡片被提起"的感觉。

2. **选中效果使用 HDR 白闪 Color(5,5,5)**: 普通白色在亮色卡片上不够明显。HDR 值确保无论卡片底色如何（蓝/红/绿/金），选中瞬间都有过曝闪光效果。

3. **进化预告使用循环脉动而非静态标记**: 静态金色边框容易被忽略（升级面板出现时间很短）。循环 alpha 脉动(0.4-0.8)让进化选项在视觉上"跳动"，吸引注意力。

4. **成就弹出使用右下角而非中央**: 中央会遮挡游戏视野。右下角在 HUD 信息区域附近，玩家自然会注意到但不会干扰游戏。260x50 的紧凑尺寸确保不影响技能按钮。

5. **波次暗幕 alpha 0.3**: 不完全遮挡游戏（alpha 1.0 会让玩家失去位置感），0.3 提供足够的聚焦效果。Boss 波次暗幕可以考虑提高到 0.4。

6. **扫光效果使用 linear 缓动**: 扫光应是匀速运动（模拟物理光束扫过），ease_in_out 会让两端减速，不够自然。

7. **成就队列而非同时弹出**: 同时弹出多个通知会导致遮挡和混乱。队列系统确保每个成就都有足够的展示时间。

---

## 9. Programmer Agent 集成清单

| 优先级 | 文件 | 集成内容 |
|--------|------|---------|
| P1 | scripts/hud.gd _show_upgrade_panel() | 卡牌悬浮 + 选中效果 |
| P1 | scripts/hud.gd _show_upgrade_panel() | 进化预告标记 + 光晕脉动 |
| P1 | scripts/hud.gd 或新建 achievement_toast.gd | 成就弹出动画 + 队列 |
| P2 | scripts/hud.gd _show_wave_banner() | 暗幕 + 扫光 + Boss 特殊横幅 |
| P2 | scripts/save_manager.gd | 成就解锁信号连接到 toast |

---

## 10. 卡牌悬浮阴影 (R19 补充)

### 10.1 阴影参数

| 参数 | 值 | 说明 |
|------|-----|------|
| 阴影类型 | 底部偏移 ColorRect | 像素风硬边阴影，无模糊 |
| 阴影颜色 | Color(0.0, 0.0, 0.0, 0.3) | 半透明黑色 |
| 阴影尺寸 | 卡片尺寸 + Vector2(4, 4) | 略大于卡片 |
| 阴影偏移 | Vector2(2, 3) | 右下偏移 |
| 阴影层级 | z_index = 卡片 z_index - 1 | 在卡片后方 |
| 出现时机 | 与 hover 动画同步 | 0.12s |
| 消失时机 | 与 unhover 动画同步 | 0.1s |

### 10.2 hover 时阴影变化

| 状态 | 阴影偏移 | 阴影 alpha | 说明 |
|------|---------|-----------|------|
| 默认 | Vector2(2, 3) | 0.3 | 轻微阴影 |
| hover | Vector2(3, 5) | 0.3 | 偏移增大，模拟卡片"升起"后阴影变长 |
| unhover | Vector2(2, 3) | 0.3 | 恢复默认 |

### 10.3 实现代码

```gdscript
# hud.gd 中，为每张升级选项卡创建阴影:
var shadow := ColorRect.new()
shadow.name = "CardShadow"
shadow.color = Color(0.0, 0.0, 0.0, 0.3)
shadow.size = card.size + Vector2(4, 4)
shadow.position = Vector2(2, 3)
shadow.z_index = -1
card.add_child(shadow)

# hover 时阴影偏移微调:
func _on_card_hover(card: Control) -> void:
    var shadow := card.get_node("CardShadow")
    var t := create_tween()
    t.tween_property(card, "scale", Vector2(1.08, 1.08), 0.12).set_ease(Tween.EASE_OUT)
    t.parallel().tween_property(card, "modulate", Color(1.1, 1.05, 0.95), 0.12)
    t.parallel().tween_property(card, "position:y", -4.0, 0.12).set_relative(true)
    t.parallel().tween_property(shadow, "position", Vector2(3, 5), 0.12)

func _on_card_unhover(card: Control) -> void:
    var shadow := card.get_node("CardShadow")
    var t := create_tween()
    t.tween_property(card, "scale", Vector2.ONE, 0.1).set_ease(Tween.EASE_IN)
    t.parallel().tween_property(card, "modulate", Color.WHITE, 0.1)
    t.parallel().tween_property(card, "position:y", 4.0, 0.1).set_relative(true)
    t.parallel().tween_property(shadow, "position", Vector2(2, 3), 0.1)
```

---

## 11. 进化光晕双层参数 (R19 补充)

### 11.1 光晕层级

| 层级 | 尺寸偏移 | alpha 范围 | 颜色 | 说明 |
|------|---------|-----------|------|------|
| 内层 | 卡片边缘 0px | 0.5 <-> 0.9 | Color(1.0, 0.84, 0.0) 金 | 贴卡片边缘发光 |
| 外层 | 卡片边缘 +2px | 0.2 <-> 0.5 | Color(1.0, 0.84, 0.0, 0.35) 金半透明 | 模拟光晕扩散 |

### 11.2 脉动参数

| 参数 | 值 | 说明 |
|------|-----|------|
| 脉动周期 | 1.0s (0.5s 增亮 + 0.5s 减暗) | 与 R18 定义一致 |
| 缓动 | ease_in_out | 平滑脉动无顿挫 |
| 内层 alpha | 0.5 -> 0.9 -> 0.5 (循环) | 较强发光 |
| 外层 alpha | 0.2 -> 0.5 -> 0.2 (循环) | 较弱扩散 |

### 11.3 实现代码

```gdscript
func _setup_evolution_glow(card: Control) -> void:
    # 内层光晕
    var inner_glow := ColorRect.new()
    inner_glow.name = "EvolveInnerGlow"
    inner_glow.color = Color(1.0, 0.84, 0.0, 0.7)
    inner_glow.set_anchors_preset(Control.PRESET_FULL_RECT)
    inner_glow.z_index = -1
    card.add_child(inner_glow)

    # 外层光晕 (+2px)
    var outer_glow := ColorRect.new()
    outer_glow.name = "EvolveOuterGlow"
    outer_glow.color = Color(1.0, 0.84, 0.0, 0.35)
    outer_glow.set_anchors_preset(Control.PRESET_FULL_RECT)
    outer_glow.offset_left = -2.0
    outer_glow.offset_top = -2.0
    outer_glow.offset_right = 2.0
    outer_glow.offset_bottom = 2.0
    outer_glow.z_index = -2
    card.add_child(outer_glow)

    # 脉动动画
    var glow_t := create_tween().set_loops()
    glow_t.tween_property(inner_glow, "color:a", 0.9, 0.5).set_ease(Tween.EASE_IN_OUT)
    glow_t.tween_property(inner_glow, "color:a", 0.5, 0.5).set_ease(Tween.EASE_IN_OUT)

    var outer_t := create_tween().set_loops()
    outer_t.tween_property(outer_glow, "color:a", 0.5, 0.5).set_ease(Tween.EASE_IN_OUT)
    outer_t.tween_property(outer_glow, "color:a", 0.2, 0.5).set_ease(Tween.EASE_IN_OUT)
```

---

## 12. 成就弹窗背景装饰 (R19 补充)

### 12.1 弹窗结构

| 元素 | 规格 | 说明 |
|------|------|------|
| 弹窗尺寸 | 260 x 50 px | R18 已定义 |
| 背景色 | Color(0.08, 0.08, 0.12, 0.9) 暗底 | R18 已定义 |
| 顶部装饰条 | 3px 高, 类型色, 全宽 | 弹窗顶部颜色标识 |
| 图标区域 | 16x16, 左侧, 距左 4px 居中 | 成就类型图标位置 |
| 图标底色 | 类型暗色 20x20 | 图标背景衬托 |

### 12.2 成就图标底色

| 类型 | 图标底色 | ColorRect 图标色 | 图标形状 |
|------|---------|----------------|---------|
| 战斗 (combat) | Color(0.4, 0.1, 0.1) #661A1A 暗红 | Color(1.0, 0.3, 0.2) 红 | 12x12 方形 |
| 收集 (collect) | Color(0.3, 0.25, 0.05) #4D400D 暗金 | Color(1.0, 0.84, 0.0) 金 | 12x12 菱形 |
| 生存 (survive) | Color(0.1, 0.3, 0.1) #1A4D1A 暗绿 | Color(0.3, 0.9, 0.4) 绿 | 12x12 十字 |
| 特殊 (special) | Color(0.15, 0.1, 0.3) #261A4D 暗紫 | Color(0.5, 0.3, 0.9) 紫 | 12x12 圆形 |

### 12.3 弹窗顶部装饰条实现

```gdscript
# 成就弹窗中添加顶部装饰条:
var top_strip := ColorRect.new()
top_strip.name = "TopStrip"
top_strip.set_anchors_preset(Control.PRESET_TOP_WIDE)
top_strip.offset_bottom = 3.0
top_strip.color = border_color  # 类型色
toast.add_child(top_strip)
```

---

## 13. 波次横幅渐变配色表 (R19 补充)

### 13.1 渐变方向

从左到右，左端为波次色(饱和)，右端渐暗至暗蓝紫底色。线性水平渐变。

### 13.2 渐变端点色值

| 波次 | 左端色 (饱和) | 中间过渡 | 右端色 (暗化) |
|------|-------------|---------|-------------|
| Wave 1 | Color(0.30, 0.69, 0.31) #4CAF50 绿 | Color(0.20, 0.45, 0.25) | Color(0.10, 0.10, 0.18) #1A1A2E 底色 |
| Wave 2 | Color(1.0, 0.84, 0.31) #FFD64F 黄 | Color(0.65, 0.55, 0.25) | Color(0.10, 0.10, 0.18) 底色 |
| Wave 3 | Color(1.0, 0.57, 0.0) #FF9100 橙 | Color(0.65, 0.38, 0.0) | Color(0.10, 0.10, 0.18) 底色 |
| Wave 4 | Color(0.94, 0.33, 0.31) #F0544F 红 | Color(0.60, 0.22, 0.20) | Color(0.10, 0.10, 0.18) 底色 |
| Wave 5 | Color(1.0, 0.09, 0.17) #FF172B 深红 | Color(0.65, 0.06, 0.11) | Color(0.10, 0.10, 0.18) 底色 |

### 13.3 代码动态渐变实现 (3 层 ColorRect)

```gdscript
# 横幅渐变使用 3 层 ColorRect 堆叠:
# 层1: 饱和色 (左半, alpha=0.9)
# 层2: 过渡色 (中段, alpha=0.5)
# 层3: 底色 (全宽, alpha=0.9)

func _create_gradient_banner(wave: int) -> ColorRect:
    var banner := ColorRect.new()
    banner.size = Vector2(600, 80)

    # 底色层 (全宽)
    var bg := ColorRect.new()
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    bg.color = Color(0.10, 0.10, 0.18, 0.9)
    banner.add_child(bg)

    # 过渡层 (中段)
    var mid := ColorRect.new()
    mid.set_anchors_preset(Control.PRESET_FULL_RECT)
    mid.offset_right = -200.0  # 右侧留出底色
    mid.color = _get_wave_mid_color(wave)
    banner.add_child(mid)

    # 饱和层 (左端)
    var saturated := ColorRect.new()
    saturated.set_anchors_preset(Control.PRESET_FULL_RECT)
    saturated.offset_right = -400.0  # 仅左侧 1/3
    saturated.color = _get_wave_saturated_color(wave)
    banner.add_child(saturated)

    return banner
```

### 13.4 波次预告图标点

| 预告敌人 | 图标颜色 | 图标形状 | 波次 |
|---------|---------|---------|------|
| 僵尸 | Color(0.30, 0.69, 0.31) 绿 | 3px 圆点 x3 | Wave 1 |
| 蝙蝠 | Color(0.67, 0.28, 0.74) 紫 | 3px 圆点 x2 | Wave 2 |
| 骷髅 + 幽灵 | Color(0.88, 0.88, 0.88) 白 + 灰白 | 3px 圆点组合 | Wave 3 |
| 精英 | Color(0.72, 0.11, 0.11) 红 | 5px 圆点 x1 (更大) | Wave 4 |
| Boss | Color(0.96, 0.26, 0.21) 红 | 8px 圆点或 boss_warning.png | Wave 5 |
