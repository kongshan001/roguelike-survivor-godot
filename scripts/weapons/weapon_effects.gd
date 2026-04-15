extends RefCounted
## 武器视觉特效，从 weapon_controller 中抽离
## 通过 load("res://scripts/weapons/weapon_effects.gd").new() 使用


static func create_lightning_effect(from: Vector2, to: Vector2, color: Color, parent: Node) -> void:
	var line := Line2D.new()
	line.width = 3.0
	line.default_color = color
	var points := [from]
	var segments := 5
	for i in range(1, segments):
		var t: float = float(i) / segments
		var point: Vector2 = from.lerp(to, t)
		point += Vector2(randf_range(-15, 15), randf_range(-15, 15))
		points.append(point)
	points.append(to)
	line.points = points
	parent.call_deferred("add_child", line)
	var tween := line.create_tween()
	tween.tween_interval(0.15)
	tween.tween_callback(line.queue_free)


static func create_cone_effect(pos: Vector2, dir_angle: float, half_angle: float, range_val: float, color: Color, parent: Node) -> void:
	var node := Node2D.new()
	var script := GDScript.new()
	script.source_code = """extends Node2D
var dir_angle: float = 0.0
var half_angle: float = 0.0
var range_val: float = 0.0
var color: Color = Color.WHITE
var alpha: float = 0.4

func _process(delta):
	alpha -= delta * 3.0
	if alpha <= 0.0:
		queue_free()
	queue_redraw()

func _draw():
	var points = [Vector2.ZERO]
	var steps = 12
	for i in range(steps + 1):
		var a = dir_angle - half_angle + (2.0 * half_angle * i / steps)
		points.append(Vector2(cos(a), sin(a)) * range_val)
	points.append(Vector2.ZERO)
	draw_colored_polygon(points, Color(color.r, color.g, color.b, alpha))
"""
	node.set_script(script)
	# set_script resets all vars via _init, so use set_deferred
	node.set_deferred("dir_angle", dir_angle)
	node.set_deferred("half_angle", half_angle)
	node.set_deferred("range_val", range_val)
	node.set_deferred("color", color)
	node.global_position = pos
	parent.call_deferred("add_child", node)


static func create_evolution_flash(parent: Node) -> void:
	var flash := ColorRect.new()
	flash.color = Color(1, 1, 1, 0.6)
	flash.size = Vector2(2000, 2000)
	flash.position = Vector2(-1000, -1000)
	flash.z_index = 100
	parent.add_child(flash)
	var tween := flash.create_tween()
	tween.tween_property(flash, "color:a", 0.0, 0.3)
	tween.tween_callback(flash.queue_free)
