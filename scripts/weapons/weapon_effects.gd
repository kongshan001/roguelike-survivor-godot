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
	script.source_code = (
		"extends Node2D\n"
		+ "var dir_angle: float = 0.0\n"
		+ "var half_angle: float = 0.0\n"
		+ "var range_val: float = 0.0\n"
		+ "var color: Color = Color.WHITE\n"
		+ "var alpha: float = 0.4\n"
		+ "\n"
		+ "func _process(delta):\n"
		+ "\talpha -= delta * 3.0\n"
		+ "\tif alpha <= 0.0:\n"
		+ "\t\tqueue_free()\n"
		+ "\tqueue_redraw()\n"
		+ "\n"
		+ "func _draw():\n"
		+ "\tvar points = [Vector2.ZERO]\n"
		+ "\tvar steps = 12\n"
		+ "\tfor i in range(steps + 1):\n"
		+ "\t\tvar a = dir_angle - half_angle + (2.0 * half_angle * i / steps)\n"
		+ "\t\tpoints.append(Vector2(cos(a), sin(a)) * range_val)\n"
		+ "\tpoints.append(Vector2.ZERO)\n"
		+ "\tdraw_colored_polygon(points, Color(color.r, color.g, color.b, alpha))\n"
	)
	script.reload()
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
