# HudScreenEffects Implementation Guide -- R35 Update

**Author**: Art Agent
**Date**: 2026-04-18
**Round**: R35
**Status**: Code-Level Implementation Guide for Programmer Agent
**Parent**: R34 hud_screen_effects.gd spec in `docs/team/art-log.md`
**Target File**: `scripts/hud_screen_effects.gd` (new file)

---

## 1. Overview

This document provides a **code-level implementation guide** for the `HudScreenEffects` module -- a RefCounted subsystem that manages three full-screen overlay effects:

1. **Damage Flash** -- Red flash when player takes damage
2. **Level Up Flash** -- Warm white flash when player levels up
3. **Boss Vignette** -- Pulsing red edge glow during boss waves

This R35 update refines the visual timing parameters based on playtesting feedback from the R34 spec:

| Effect | R34 Fade-out | R35 Fade-out | Change Reason |
|--------|-------------|-------------|---------------|
| Damage Flash | 0.25s | **0.15s** | Faster fadeout prevents visual interference during combat |
| Level Up Flash | 0.4s | **0.3s** | Tighter timing feels more responsive with upgrade panel |
| Boss Vignette Pulse | 1.5Hz (continuous) | **0.5s period** | Cleaner specification; 0.5s period = 2.0Hz pulse |

---

## 2. Visual Parameters -- Final

### 2.1 Damage Flash (受伤闪红)

| Attribute | Value | Notes |
|-----------|-------|-------|
| Trigger | `GameManager.health_changed` with HP decrease | |
| Node Type | `ColorRect` | PRESET_FULL_RECT |
| Color | Color(0.8, 0.0, 0.0) | Deep red #CC0000 |
| Alpha Peak | 0.3 | Semi-transparent |
| Fade In | 0.0s (instant) | Immediate impact |
| **Fade Out** | **0.15s** | Fast消退, minimal combat interference |
| Fade Curve | TRANS_QUAD, EASE_OUT | Quick start, smooth finish |
| Default State | visible = false | |
| CanvasLayer | layer = 100 | Above all game content |

### 2.2 Level Up Flash (升级闪光)

| Attribute | Value | Notes |
|-----------|-------|-------|
| Trigger | `GameManager.level_up` signal | |
| Node Type | `ColorRect` | PRESET_FULL_RECT |
| Color | Color(1.0, 1.0, 0.8) | Warm white #FFFFCC |
| Alpha Peak | 0.25 | Softer than damage flash |
| Fade In | 0.05s | Near-instant with smoothness |
| **Fade Out** | **0.3s** | Medium消退 |
| Fade Curve | TRANS_QUAD, EASE_OUT | |
| Default State | visible = false | |

### 2.3 Boss Vignette (Boss暗角)

| Attribute | Value | Notes |
|-----------|-------|-------|
| Trigger | Boss wave started (`WAVE_DEFS.boss == true`) | |
| Node Type | 4x ColorRect (top/bottom/left/right edges) | |
| Color | Color(0.6, 0.0, 0.0) | Dark red #990000 |
| Alpha Max | 0.35 | Persistent but not overwhelming |
| Fade In | 1.0s | Slow immersion for dread |
| Fade Out | 0.5s | Clear resolution when boss defeated |
| **Pulse Period** | **0.5s** | 0.5s per cycle = alpha oscillates every 0.5s |
| Pulse Amplitude | +/-0.05 | Alpha range: [0.30, 0.40] |
| Edge Width | 40 px | Per edge strip |
| Default State | visible = false | |

### 2.4 Visual Comparison Table

| Aspect | Damage Flash | Level Up Flash | Boss Vignette |
|--------|-------------|---------------|---------------|
| Color | Color(0.8, 0.0, 0.0) red | Color(1.0, 1.0, 0.8) warm white | Color(0.6, 0.0, 0.0) dark red |
| Alpha Peak | 0.3 | 0.25 | 0.35 (sustained) |
| Fade In | 0.0s | 0.05s | 1.0s |
| Fade Out | 0.15s | 0.3s | 0.5s |
| Persistence | Flash (one-shot) | Flash (one-shot) | Continuous until boss dies |
| Emotion | Danger / Pain | Reward / Growth | Pressure / Dread |
| Nodes | 1 ColorRect | 1 ColorRect | 4 ColorRect edges |

---

## 3. hud_screen_effects.gd -- Complete Implementation

```gdscript
# scripts/hud_screen_effects.gd
# HUD Screen Overlay Effects -- Damage Flash / Level Up Flash / Boss Vignette
# Instantiated by hud.gd as a RefCounted subsystem.
# All overlay nodes live under the hud's CanvasLayer.

class_name HudScreenEffects
extends RefCounted


# ==================== CONSTANTS ====================

# --- Damage Flash (受伤闪红) ---
const DAMAGE_FLASH_COLOR: Color = Color(0.8, 0.0, 0.0)
const DAMAGE_FLASH_ALPHA: float = 0.3
const DAMAGE_FLASH_FADE_TIME: float = 0.15  # R35: reduced from 0.25s

# --- Level Up Flash (升级闪光) ---
const LEVEL_UP_FLASH_COLOR: Color = Color(1.0, 1.0, 0.8)
const LEVEL_UP_FLASH_ALPHA: float = 0.25
const LEVEL_UP_FLASH_FADE_IN: float = 0.05
const LEVEL_UP_FLASH_FADE_OUT: float = 0.3  # R35: reduced from 0.4s

# --- Boss Vignette (Boss暗角) ---
const BOSS_VIGNETTE_COLOR: Color = Color(0.6, 0.0, 0.0)
const BOSS_VIGNETTE_MAX_ALPHA: float = 0.35
const BOSS_VIGNETTE_FADE_IN: float = 1.0
const BOSS_VIGNETTE_FADE_OUT: float = 0.5
const BOSS_VIGNETTE_EDGE_WIDTH: float = 40.0
const BOSS_VIGNETTE_PULSE_PERIOD: float = 0.5  # R35: 0.5s period (2.0 Hz)
const BOSS_VIGNETTE_PULSE_AMP: float = 0.05


# ==================== INTERNAL STATE ====================

var _host: CanvasLayer = null
var _damage_flash: ColorRect = null
var _level_up_flash: ColorRect = null
var _boss_vignette_edges: Array[ColorRect] = []
var _boss_active: bool = false
var _boss_pulse_time: float = 0.0
var _damage_tween: Tween = null
var _levelup_tween: Tween = null
var _boss_tween: Tween = null


# ==================== LIFECYCLE ====================

func _init(host: CanvasLayer) -> void:
    _host = host
    _setup_damage_flash()
    _setup_level_up_flash()
    _setup_boss_vignette()


# ==================== DAMAGE FLASH ====================

func _setup_damage_flash() -> void:
    _damage_flash = ColorRect.new()
    _damage_flash.name = "DamageFlash"
    _damage_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
    _damage_flash.color = Color(DAMAGE_FLASH_COLOR.r, DAMAGE_FLASH_COLOR.g, DAMAGE_FLASH_COLOR.b, 0.0)
    _damage_flash.visible = false
    _damage_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _host.add_child(_damage_flash)


## Show red flash on damage. Call from health_changed signal when HP decreases.
func show_damage_flash() -> void:
    if _damage_flash == null or not _damage_flash.is_inside_tree():
        return
    # Kill previous tween if still running (rapid damage)
    if _damage_tween and _damage_tween.is_valid():
        _damage_tween.kill()
    _damage_flash.visible = true
    _damage_flash.color = Color(DAMAGE_FLASH_COLOR.r, DAMAGE_FLASH_COLOR.g,
                                 DAMAGE_FLASH_COLOR.b, DAMAGE_FLASH_ALPHA)
    _damage_tween = _host.create_tween()
    _damage_tween.tween_property(_damage_flash, "color:a", 0.0, DAMAGE_FLASH_FADE_TIME) \
        .set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    _damage_tween.tween_callback(func() -> void:
        _damage_flash.visible = false
    )


# ==================== LEVEL UP FLASH ====================

func _setup_level_up_flash() -> void:
    _level_up_flash = ColorRect.new()
    _level_up_flash.name = "LevelUpFlash"
    _level_up_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
    _level_up_flash.color = Color(LEVEL_UP_FLASH_COLOR.r, LEVEL_UP_FLASH_COLOR.g,
                                   LEVEL_UP_FLASH_COLOR.b, 0.0)
    _level_up_flash.visible = false
    _level_up_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _host.add_child(_level_up_flash)


## Show warm white flash on level up. Call from level_up signal.
func show_level_up_flash() -> void:
    if _level_up_flash == null or not _level_up_flash.is_inside_tree():
        return
    if _levelup_tween and _levelup_tween.is_valid():
        _levelup_tween.kill()
    _level_up_flash.visible = true
    _level_up_flash.color = Color(LEVEL_UP_FLASH_COLOR.r, LEVEL_UP_FLASH_COLOR.g,
                                   LEVEL_UP_FLASH_COLOR.b, 0.0)
    _levelup_tween = _host.create_tween()
    # Fade in 0.05s
    _levelup_tween.tween_property(_level_up_flash, "color:a", LEVEL_UP_FLASH_ALPHA,
                                   LEVEL_UP_FLASH_FADE_IN)
    # Fade out 0.3s
    _levelup_tween.tween_property(_level_up_flash, "color:a", 0.0,
                                   LEVEL_UP_FLASH_FADE_OUT) \
        .set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    _levelup_tween.tween_callback(func() -> void:
        _level_up_flash.visible = false
    )


# ==================== BOSS VIGNETTE ====================

func _setup_boss_vignette() -> void:
    var edge_names: Array[String] = [
        "BossVignetteTop", "BossVignetteBottom",
        "BossVignetteLeft", "BossVignetteRight"
    ]
    for edge_name in edge_names:
        var edge := ColorRect.new()
        edge.name = edge_name
        edge.color = Color(BOSS_VIGNETTE_COLOR.r, BOSS_VIGNETTE_COLOR.g,
                           BOSS_VIGNETTE_COLOR.b, 0.0)
        edge.visible = false
        edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
        _host.add_child(edge)
        _boss_vignette_edges.append(edge)
    _position_vignette_edges()


func _position_vignette_edges() -> void:
    if _boss_vignette_edges.size() < 4:
        return
    var vp_size: Vector2 = _host.get_viewport().get_visible_rect().size \
        if _host.get_viewport() else Vector2(1280.0, 720.0)
    var w: float = BOSS_VIGNETTE_EDGE_WIDTH
    # Top edge
    _boss_vignette_edges[0].set_anchors_preset(Control.PRESET_TOP_WIDE)
    _boss_vignette_edges[0].offset_top = 0.0
    _boss_vignette_edges[0].offset_bottom = w
    # Bottom edge
    _boss_vignette_edges[1].set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    _boss_vignette_edges[1].offset_top = -w
    _boss_vignette_edges[1].offset_bottom = 0.0
    # Left edge
    _boss_vignette_edges[2].set_position(Vector2(0.0, 0.0))
    _boss_vignette_edges[2].set_size(Vector2(w, vp_size.y))
    # Right edge
    _boss_vignette_edges[3].set_position(Vector2(vp_size.x - w, 0.0))
    _boss_vignette_edges[3].set_size(Vector2(w, vp_size.y))


## Show boss vignette with 1.0s fade-in. Call on boss wave start.
func show_boss_vignette() -> void:
    if _boss_vignette_edges.size() < 4:
        return
    _boss_active = true
    _boss_pulse_time = 0.0
    _position_vignette_edges()
    if _boss_tween and _boss_tween.is_valid():
        _boss_tween.kill()
    for edge in _boss_vignette_edges:
        edge.visible = true
        edge.color = Color(BOSS_VIGNETTE_COLOR.r, BOSS_VIGNETTE_COLOR.g,
                           BOSS_VIGNETTE_COLOR.b, 0.0)
    _boss_tween = _host.create_tween()
    for edge in _boss_vignette_edges:
        _boss_tween.parallel().tween_property(
            edge, "color:a", BOSS_VIGNETTE_MAX_ALPHA, BOSS_VIGNETTE_FADE_IN
        ).set_trans(Tween.TRANS_SINE)


## Hide boss vignette with 0.5s fade-out. Call on boss defeat or wave end.
func hide_boss_vignette() -> void:
    _boss_active = false
    if _boss_tween and _boss_tween.is_valid():
        _boss_tween.kill()
    if _boss_vignette_edges.size() < 4:
        return
    var tween := _host.create_tween()
    for edge in _boss_vignette_edges:
        tween.parallel().tween_property(edge, "color:a", 0.0, BOSS_VIGNETTE_FADE_OUT)
    tween.tween_callback(func() -> void:
        for edge in _boss_vignette_edges:
            edge.visible = false
    )


## Process boss vignette pulse. Call from _process(delta) each frame.
## Uses 0.5s period sine wave for pulsating alpha.
func process_boss_pulse(delta: float) -> void:
    if not _boss_active:
        return
    if _boss_vignette_edges.size() < 4:
        return
    _boss_pulse_time += delta
    # 0.5s period: frequency = 1.0 / 0.5 = 2.0 Hz
    # alpha = max_alpha + amplitude * sin(t * 2pi / period)
    var pulse_alpha: float = BOSS_VIGNETTE_MAX_ALPHA \
        + BOSS_VIGNETTE_PULSE_AMP * sin(_boss_pulse_time * TAU / BOSS_VIGNETTE_PULSE_PERIOD)
    for edge in _boss_vignette_edges:
        edge.color = Color(BOSS_VIGNETTE_COLOR.r, BOSS_VIGNETTE_COLOR.g,
                           BOSS_VIGNETTE_COLOR.b, pulse_alpha)
```

---

## 4. hud.gd Integration Points

### 4.1 Add subsystem declaration

```gdscript
# In hud.gd, near line 19 (other subsystem declarations):
var _screen_fx: RefCounted = null
```

### 4.2 Initialize in _ready()

```gdscript
# In hud.gd _ready(), after _mastery_panel initialization (around line 72):
_screen_fx = load("res://scripts/hud_screen_effects.gd").new(self)
```

### 4.3 Connect damage flash

```gdscript
# In hud.gd _on_health_changed(), modify existing function:
func _on_health_changed(current: float, max_hp: float) -> void:
    $HealthBar.value = (current / max_hp) * 100.0
    $HealthLabel.text = "%d/%d" % [int(current), int(max_hp)]
    # Damage flash: trigger when HP has decreased
    if current < max_hp and _screen_fx:
        _screen_fx.show_damage_flash()
```

Note: The `current < max_hp` check is a simplified trigger. A more precise approach would track previous HP:

```gdscript
# Alternative (recommended for Phase C):
var _prev_hp: float = 0.0

func _on_health_changed(current: float, max_hp: float) -> void:
    $HealthBar.value = (current / max_hp) * 100.0
    $HealthLabel.text = "%d/%d" % [int(current), int(max_hp)]
    if current < _prev_hp and _screen_fx:
        _screen_fx.show_damage_flash()
    _prev_hp = current
```

### 4.4 Connect level up flash

```gdscript
# In hud.gd _on_level_up(), modify existing function:
func _on_level_up(_new_level: int) -> void:
    _pending_level_ups += 1
    if AudioManager: AudioManager.play_sfx_by_id("player_levelup")
    if _screen_fx:
        _screen_fx.show_level_up_flash()
    _show_upgrade_panel()
```

### 4.5 Connect boss vignette

```gdscript
# In hud.gd _on_wave_started(), modify existing function:
func _on_wave_started(wave: int, wave_name: String) -> void:
    _toast.show_toast("Wave %d: %s" % [wave, wave_name], GameManager.get_wave_color())
    # Boss vignette control
    if _screen_fx:
        var def: Dictionary = GameManager._get_current_wave_def()
        if def.get("boss", false):
            _screen_fx.show_boss_vignette()
        else:
            _screen_fx.hide_boss_vignette()

# In hud.gd _on_wave_completed(), add vignette hide:
func _on_wave_completed(wave: int) -> void:
    _toast.show_toast("Wave %d Complete!" % wave, Color(0.3, 0.69, 0.31))
    if _screen_fx:
        _screen_fx.hide_boss_vignette()

# In hud.gd _on_victory_achieved(), add vignette hide:
func _on_victory_achieved(gold_bonus: int) -> void:
    # ... existing victory label code ...
    if _screen_fx:
        _screen_fx.hide_boss_vignette()
```

### 4.6 Add pulse processing in _process()

```gdscript
# In hud.gd _process(), add after existing _skill_btn.update_display:
func _process(delta: float) -> void:
    $TimerLabel.text = GameManager.format_time(GameManager.elapsed_time)
    _update_wave_display()
    if _toast:
        _toast.process_queue(delta)
    _skill_btn.update_display(_get_player())
    # Boss vignette pulse
    if _screen_fx:
        _screen_fx.process_boss_pulse(delta)
```

---

## 5. GUT Test Reference

```gdscript
# test/unit/test_hud_screen_effects.gd
extends GutInternalTester

# --- Constant Validation ---

func test_damage_flash_color() -> void:
    assert_eq(HudScreenEffects.DAMAGE_FLASH_COLOR, Color(0.8, 0.0, 0.0))

func test_damage_flash_alpha() -> void:
    assert_eq(HudScreenEffects.DAMAGE_FLASH_ALPHA, 0.3)

func test_damage_flash_fade_time() -> void:
    assert_eq(HudScreenEffects.DAMAGE_FLASH_FADE_TIME, 0.15)

func test_level_up_flash_color() -> void:
    assert_eq(HudScreenEffects.LEVEL_UP_FLASH_COLOR, Color(1.0, 1.0, 0.8))

func test_level_up_flash_alpha() -> void:
    assert_eq(HudScreenEffects.LEVEL_UP_FLASH_ALPHA, 0.25)

func test_level_up_flash_fade_out() -> void:
    assert_eq(HudScreenEffects.LEVEL_UP_FLASH_FADE_OUT, 0.3)

func test_boss_vignette_color() -> void:
    assert_eq(HudScreenEffects.BOSS_VIGNETTE_COLOR, Color(0.6, 0.0, 0.0))

func test_boss_vignette_max_alpha() -> void:
    assert_eq(HudScreenEffects.BOSS_VIGNETTE_MAX_ALPHA, 0.35)

func test_boss_vignette_pulse_period() -> void:
    assert_eq(HudScreenEffects.BOSS_VIGNETTE_PULSE_PERIOD, 0.5)

func test_boss_vignette_pulse_amp() -> void:
    assert_eq(HudScreenEffects.BOSS_VIGNETTE_PULSE_AMP, 0.05)

func test_boss_vignette_edge_width() -> void:
    assert_eq(HudScreenEffects.BOSS_VIGNETTE_EDGE_WIDTH, 40.0)


# --- Instantiation & Node Creation ---

func test_can_instantiate() -> void:
    var layer := CanvasLayer.new()
    add_child_autofree(layer)
    var fx := HudScreenEffects.new(layer)
    assert_not_null(fx)

func test_damage_flash_node_created() -> void:
    var layer := CanvasLayer.new()
    add_child_autofree(layer)
    var fx := HudScreenEffects.new(layer)
    var node := layer.get_node_or_null("DamageFlash")
    assert_not_null(node, "DamageFlash node should exist")
    assert_false(node.visible, "DamageFlash should start hidden")

func test_level_up_flash_node_created() -> void:
    var layer := CanvasLayer.new()
    add_child_autofree(layer)
    var fx := HudScreenEffects.new(layer)
    var node := layer.get_node_or_null("LevelUpFlash")
    assert_not_null(node, "LevelUpFlash node should exist")
    assert_false(node.visible, "LevelUpFlash should start hidden")

func test_boss_vignette_edges_created() -> void:
    var layer := CanvasLayer.new()
    add_child_autofree(layer)
    var fx := HudScreenEffects.new(layer)
    for name in ["BossVignetteTop", "BossVignetteBottom",
                  "BossVignetteLeft", "BossVignetteRight"]:
        assert_not_null(layer.get_node_or_null(name),
                        "%s should exist" % name)


# --- Functional Tests ---

func test_show_damage_flash_visibility() -> void:
    var layer := CanvasLayer.new()
    add_child_autofree(layer)
    var fx := HudScreenEffects.new(layer)
    fx.show_damage_flash()
    var node: ColorRect = layer.get_node("DamageFlash")
    assert_true(node.visible)
    assert_almost_eq(node.color.a, 0.3, 0.01)

func test_show_level_up_flash_visibility() -> void:
    var layer := CanvasLayer.new()
    add_child_autofree(layer)
    var fx := HudScreenEffects.new(layer)
    fx.show_level_up_flash()
    var node: ColorRect = layer.get_node("LevelUpFlash")
    assert_true(node.visible)

func test_show_boss_vignette_visibility() -> void:
    var layer := CanvasLayer.new()
    add_child_autofree(layer)
    var fx := HudScreenEffects.new(layer)
    fx.show_boss_vignette()
    for name in ["BossVignetteTop", "BossVignetteBottom",
                  "BossVignetteLeft", "BossVignetteRight"]:
        assert_true(layer.get_node(name).visible,
                    "%s should be visible" % name)

func test_hide_boss_vignette_sets_inactive() -> void:
    var layer := CanvasLayer.new()
    add_child_autofree(layer)
    var fx := HudScreenEffects.new(layer)
    fx.show_boss_vignette()
    fx.hide_boss_vignette()
    assert_false(fx._boss_active)

func test_boss_pulse_alpha_in_range() -> void:
    var layer := CanvasLayer.new()
    add_child_autofree(layer)
    var fx := HudScreenEffects.new(layer)
    fx.show_boss_vignette()
    # Simulate multiple frames of pulse
    for i in range(60):
        fx.process_boss_pulse(1.0 / 60.0)
    var alpha: float = layer.get_node("BossVignetteTop").color.a
    assert_true(alpha >= 0.30 and alpha <= 0.40,
                "Boss vignette alpha should be in [0.30, 0.40], got %f" % alpha)

func test_boss_pulse_oscillates() -> void:
    var layer := CanvasLayer.new()
    add_child_autofree(layer)
    var fx := HudScreenEffects.new(layer)
    fx.show_boss_vignette()
    # Collect alpha samples over one full period (0.5s)
    var alphas: Array[float] = []
    for i in range(30):  # 30 frames at 60fps = 0.5s = 1 period
        fx.process_boss_pulse(1.0 / 60.0)
        alphas.append(layer.get_node("BossVignetteTop").color.a)
    # Alpha should vary (not constant)
    var min_a: float = alphas.min()
    var max_a: float = alphas.max()
    assert_gt(max_a - min_a, 0.01,
              "Boss pulse alpha should oscillate over one period")

func test_boss_pulse_not_active_when_hidden() -> void:
    var layer := CanvasLayer.new()
    add_child_autofree(layer)
    var fx := HudScreenEffects.new(layer)
    # Never showed boss vignette
    fx.process_boss_pulse(0.016)
    assert_eq(fx._boss_pulse_time, 0.0,
              "Pulse time should not advance when boss not active")
```

---

## 6. R34 -> R35 Parameter Changelog

| Constant | R34 Value | R35 Value | Reason |
|----------|-----------|-----------|--------|
| DAMAGE_FLASH_FADE_TIME | 0.25 | **0.15** | Faster消退 reduces visual interference during combat; 0.15s is still perceptible but not lingering |
| LEVEL_UP_FLASH_FADE_OUT | 0.4 | **0.3** | Tighter timing pairs better with upgrade panel popup; feels more responsive |
| BOSS_VIGNETTE_PULSE_FREQ | 1.5 (Hz) | -- | Replaced by PERIOD |
| BOSS_VIGNETTE_PULSE_PERIOD | -- | **0.5** (s) | 0.5s period = 2.0Hz; cleaner spec; pulse formula uses `sin(t * TAU / period)` instead of `sin(t * freq * TAU)` |

All other constants remain unchanged from R34.

---

## 7. Node Architecture

```
CanvasLayer (hud.gd, layer=100)
  +-- DamageFlash (ColorRect, PRESET_FULL_RECT, visible=false)
  +-- LevelUpFlash (ColorRect, PRESET_FULL_RECT, visible=false)
  +-- BossVignetteTop (ColorRect, 40px high, visible=false)
  +-- BossVignetteBottom (ColorRect, 40px high, visible=false)
  +-- BossVignetteLeft (ColorRect, 40px wide, visible=false)
  +-- BossVignetteRight (ColorRect, 40px wide, visible=false)
```

All 6 overlay nodes live under the same CanvasLayer as the HUD. The `HudScreenEffects` RefCounted holds references to these nodes and manages their visibility, color, and Tween animations.

---

*Guide generated by Art Agent R35 on 2026-04-18*
*Previous version: R34 in `docs/team/art-log.md`*
