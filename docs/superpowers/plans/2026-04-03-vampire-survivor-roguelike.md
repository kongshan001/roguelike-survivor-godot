# Vampire Survivor-like Roguelike Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a minimal playable 2D top-down roguelike with auto-attack weapons, escalating enemy waves, XP/level-up with 3-choice upgrades, and item pickups.

**Architecture:** Scene-driven — each entity is an independent Godot Scene communicating via signals. Weapon/enemy stats defined as Godot Resources. Two Autoload singletons manage global game state and the upgrade pool.

**Tech Stack:** Godot 4.6, GDScript, built-in 2D physics (CharacterBody2D, Area2D), no external assets.

---

## File Structure

```
godot_demo/
├── project.godot
├── icon.svg
├── scenes/
│   ├── main.tscn
│   ├── title_screen.tscn
│   ├── arena.tscn
│   ├── game_over_screen.tscn
│   ├── player.tscn
│   ├── enemy.tscn
│   ├── projectile.tscn
│   ├── xp_gem.tscn
│   ├── item_crate.tscn
│   └── hud.tscn
├── scripts/
│   ├── autoload/
│   │   ├── game_manager.gd
│   │   └── upgrade_pool.gd
│   ├── player.gd
│   ├── enemy.gd
│   ├── enemy_spawner.gd
│   ├── projectile.gd
│   ├── spin_blade.gd
│   ├── xp_gem.gd
│   ├── item_crate.gd
│   ├── pickup_manager.gd
│   ├── data/
│   │   ├── weapon_data.gd
│   │   ├── enemy_data.gd
│   │   └── passive_data.gd
│   ├── weapon_controller.gd
│   ├── hud.gd
│   ├── title_screen.gd
│   ├── game_over_screen.gd
│   └── arena.gd
└── resources/
    ├── weapons/
    │   ├── magic_orb.tres
    │   ├── spin_blade.tres
    │   ├── lightning.tres
    │   └── fire_burst.tres
    └── enemies/
        ├── slime.tres
        ├── bat.tres
        ├── golem.tres
        └── boss.tres
```

---

## Task 1: Project Setup

**Files:**
- Create: `project.godot`
- Create: `icon.svg`
- Create: `scripts/autoload/game_manager.gd`
- Create: `scenes/main.tscn`
- Create: `scripts/autoload/upgrade_pool.gd`

- [ ] **Step 1: Initialize Godot project**

Create `project.godot`:

```ini
; Engine configuration file.
; It's best edited using the editor UI and not directly,
; since the parameters that go here are not all obvious.
;
; Format:
;   [section] ; section goes between []
;   param=value ; assign values to parameters

config_version=5

[application]

config/name="Survivor Arena"
run/main_scene="res://scenes/main.tscn"
config/features=PackedStringArray("4.6", "Forward Plus")

[autoload]

GameManager="*res://scripts/autoload/game_manager.gd"
UpgradePool="*res://scripts/autoload/upgrade_pool.gd"

[display]

window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="canvas_items"

[input]

move_up={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":87,"physical_keycode":0,"key_label":0,"unicode":119,"location":0,"echo":false,"script":null)]
}
move_down={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":83,"physical_keycode":0,"key_label":0,"unicode":115,"location":0,"echo":false,"script":null)]
}
move_left={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":65,"physical_keycode":0,"key_label":0,"unicode":97,"location":0,"echo":false,"script":null)]
}
move_right={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":68,"physical_keycode":0,"key_label":0,"unicode":100,"location":0,"echo":false,"script":null)]
}
```

- [ ] **Step 2: Create a simple icon.svg**

Create `icon.svg`:

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128">
  <rect width="128" height="128" fill="#1a1a2e"/>
  <circle cx="64" cy="64" r="40" fill="#e94560"/>
  <circle cx="52" cy="55" r="6" fill="#fff"/>
  <circle cx="76" cy="55" r="6" fill="#fff"/>
  <circle cx="52" cy="55" r="3" fill="#1a1a2e"/>
  <circle cx="76" cy="55" r="3" fill="#1a1a2e"/>
  <path d="M 48 78 Q 64 92 80 78" stroke="#fff" stroke-width="3" fill="none"/>
</svg>
```

- [ ] **Step 3: Create GameManager autoload**

Create `scripts/autoload/game_manager.gd`:

```gdscript
extends Node

signal player_died
signal level_up(new_level: int)
signal xp_changed(current: float, needed: float)
signal health_changed(current: float, max_health: float)
signal enemies_changed(count: int)

var score: int = 0
var enemies_killed: int = 0
var elapsed_time: float = 0.0
var player_level: int = 1
var current_xp: float = 0.0
var xp_to_next_level: float = 5.0
var is_paused: bool = false
var is_game_over: bool = false

var enemy_count: int = 0:
	set(v):
		enemy_count = v
		enemies_changed.emit(enemy_count)


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS


func reset():
	score = 0
	enemies_killed = 0
	elapsed_time = 0.0
	player_level = 1
	current_xp = 0.0
	xp_to_next_level = 5.0
	is_paused = false
	is_game_over = false
	enemy_count = 0


func add_xp(amount: float):
	current_xp += amount
	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		player_level += 1
		xp_to_next_level = _calculate_xp_needed(player_level)
		level_up.emit(player_level)
	xp_changed.emit(current_xp, xp_to_next_level)


func _calculate_xp_needed(level: int) -> float:
	# Quadratic scaling: 5, 12, 22, 35, 52, ...
	return 5.0 + (level - 1) * 7.0 + (level - 1) * (level - 1) * 0.5


func format_time(seconds: float) -> String:
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [mins, secs]
```

- [ ] **Step 4: Create UpgradePool autoload**

Create `scripts/autoload/upgrade_pool.gd`:

```gdscript
extends Node

var _weapons: Dictionary = {}
var _passives: Dictionary = {}
var _initialized: bool = false


func _ensure_initialized():
	if _initialized:
		return
	_initialized = true
	# Weapons will be registered by weapon_controller on ready
	# Passives are static
	_passives = {
		"max_hp_up": {"name": "Max HP Up", "description": "+20 Max HP", "icon_color": Color.GREEN},
		"speed_up": {"name": "Speed Up", "description": "+15% Move Speed", "icon_color": Color.CYAN},
		"pickup_range": {"name": "Pickup Range", "description": "+25px Magnet Range", "icon_color": Color.YELLOW},
		"armor": {"name": "Armor", "description": "-3 Damage Taken", "icon_color": Color.GRAY},
		"regen": {"name": "Regen", "description": "+1 HP / 5s", "icon_color": Color.PINK},
	}


func register_weapon(weapon_id: String, data: Resource):
	_ensure_initialized()
	_weapons[weapon_id] = data


func get_random_upgrades(owned_weapons: Dictionary, count: int = 3) -> Array[Dictionary]:
	_ensure_initialized()
	var options: Array[Dictionary] = []

	# Add new weapons the player doesn't own yet
	for weapon_id in _weapons:
		if not owned_weapons.has(weapon_id):
			var w: Resource = _weapons[weapon_id]
			options.append({
				"type": "new_weapon",
				"id": weapon_id,
				"name": w.weapon_name,
				"description": w.description,
				"icon_color": Color.ORANGE,
			})
		else:
			# Upgrade existing weapon (max 5 levels)
			var current_level: int = owned_weapons[weapon_id]
			if current_level < 5:
				var w: Resource = _weapons[weapon_id]
				options.append({
					"type": "weapon_upgrade",
					"id": weapon_id,
					"name": w.weapon_name + " Lv%d" % (current_level + 1),
					"description": "Upgrade %s" % w.weapon_name,
					"icon_color": Color.ORANGE,
				})

	# Add passives
	for passive_id in _passives:
		var p: Dictionary = _passives[passive_id]
		options.append({
			"type": "passive",
			"id": passive_id,
			"name": p.name,
			"description": p.description,
			"icon_color": p.icon_color,
		})

	# Shuffle and pick
	options.shuffle()
	var result: Array[Dictionary] = []
	for i in range(mini(count, options.size())):
		result.append(options[i])
	return result
```

- [ ] **Step 5: Create main.tscn (entry point)**

Create `scenes/main.tscn`:

```
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/title_screen.gd" id="1"]

[node name="Main" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
script = ExtResource("1")

[node name="Background" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
color = Color(0.1, 0.1, 0.18, 1)

[node name="Title" type="Label" parent="."]
layout_mode = 1
anchors_preset = 5
anchor_left = 0.5
anchor_right = 0.5
offset_left = -200.0
offset_top = 150.0
offset_right = 200.0
offset_bottom = 220.0
grow_horizontal = 2
text = "Survivor Arena"
horizontal_alignment = 1

[node name="StartButton" type="Button" parent="."]
layout_mode = 1
anchors_preset = 7
anchor_left = 0.5
anchor_top = 1.0
anchor_right = 0.5
anchor_bottom = 1.0
offset_left = -100.0
offset_top = -200.0
offset_right = 100.0
offset_bottom = -150.0
grow_horizontal = 2
grow_vertical = 0
text = "Start Game"

[node name="ControlsHint" type="Label" parent="."]
layout_mode = 1
anchors_preset = 7
anchor_left = 0.5
anchor_top = 1.0
anchor_right = 0.5
anchor_bottom = 1.0
offset_left = -100.0
offset_top = -100.0
offset_right = 100.0
offset_bottom = -70.0
grow_horizontal = 2
grow_vertical = 0
text = "WASD to move"
horizontal_alignment = 1
```

- [ ] **Step 6: Create title_screen.gd**

Create `scripts/title_screen.gd`:

```gdscript
extends Control


func _ready():
	$StartButton.pressed.connect(_on_start_pressed)


func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/arena.tscn")
```

---

## Task 2: Data Resource Classes

**Files:**
- Create: `scripts/data/weapon_data.gd`
- Create: `scripts/data/enemy_data.gd`
- Create: `scripts/data/passive_data.gd`

- [ ] **Step 1: Create weapon_data.gd**

Create `scripts/data/weapon_data.gd`:

```gdscript
class_name WeaponData
extends Resource

@export var weapon_name: String = "Weapon"
@export var weapon_id: String = ""
@export var damage: float = 10.0
@export var cooldown: float = 1.5
@export var projectile_speed: float = 300.0
@export var projectile_count: int = 1
@export var projectile_pierce: int = 1
@export var projectile_range: float = 500.0
@export var description: String = ""
@export var color: Color = Color.WHITE
@export var projectile_size: float = 8.0
@export var weapon_type: String = "projectile"  # "projectile", "orbit", "lightning", "aoe"
@export var aoe_radius: float = 80.0  # For fire_burst
@export var orbit_count: int = 1  # For spin_blade
@export var orbit_radius: float = 80.0  # For spin_blade
@export var chain_count: int = 0  # For lightning
```

- [ ] **Step 2: Create enemy_data.gd**

Create `scripts/data/enemy_data.gd`:

```gdscript
class_name EnemyData
extends Resource

@export var enemy_name: String = "Enemy"
@export var max_hp: float = 20.0
@export var speed: float = 60.0
@export var damage: float = 10.0
@export var xp_value: int = 5
@export var color: Color = Color.GREEN
@export var size: float = 16.0
@export var shape: String = "circle"  # "circle", "triangle", "square", "hexagon"
@export var is_boss: bool = false
@export var drop_chance: float = 0.1
```

- [ ] **Step 3: Create passive_data.gd**

Create `scripts/data/passive_data.gd`:

```gdscript
class_name PassiveData
extends Resource

@export var passive_name: String = "Passive"
@export var passive_id: String = ""
@export var description: String = ""
@export var icon_color: Color = Color.WHITE
```

---

## Task 3: Player Scene

**Files:**
- Create: `scripts/player.gd`
- Create: `scenes/player.tscn`

- [ ] **Step 1: Create player.gd**

Create `scripts/player.gd`:

```gdscript
extends CharacterBody2D

signal died
signal took_damage

@export var move_speed: float = 150.0
@export var max_health: float = 100.0
@export var pickup_range: float = 50.0
@export var armor: int = 0

var current_health: float
var invincible_timer: float = 0.0
var is_alive: bool = true
var regen_timer: float = 0.0
var regen_amount: float = 0.0
var speed_multiplier: float = 1.0

# Weapon tracking: weapon_id -> level (0 means not owned, 1-5 means owned at that level)
var owned_weapons: Dictionary = {}

@onready var hurtbox: Area2D = $Hurtbox
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var weapon_controller: Node = $WeaponController
@onready var sprite: ColorRect = $Sprite


func _ready():
	current_health = max_health
	GameManager.health_changed.emit(current_health, max_health)


func _physics_process(delta):
	if not is_alive:
		return

	# Movement
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * move_speed * speed_multiplier
	move_and_slide()

	# Invincibility
	if invincible_timer > 0:
		invincible_timer -= delta
		# Flash effect
		sprite.visible = fmod(invincible_timer, 0.1) > 0.05

	# Regeneration
	if regen_amount > 0:
		regen_timer += delta
		if regen_timer >= 5.0:
			regen_timer -= 5.0
			heal(regen_amount)


func take_damage(amount: float):
	if invincible_timer > 0 or not is_alive:
		return

	var actual_damage = maxf(1.0, amount - armor)
	current_health -= actual_damage
	GameManager.health_changed.emit(current_health, max_health)
	took_damage.emit()

	if current_health <= 0:
		current_health = 0
		die()
	else:
		invincible_timer = 0.5


func heal(amount: float):
	current_health = minf(current_health + amount, max_health)
	GameManager.health_changed.emit(current_health, max_health)


func die():
	is_alive = false
	died.emit()
	GameManager.is_game_over = true
	GameManager.player_died.emit()
	# Transition to game over after a brief delay
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/game_over_screen.tscn")
	)


func add_weapon(weapon_id: String):
	owned_weapons[weapon_id] = 1


func upgrade_weapon(weapon_id: String) -> bool:
	if owned_weapons.has(weapon_id) and owned_weapons[weapon_id] < 5:
		owned_weapons[weapon_id] += 1
		return true
	return false


func get_weapon_level(weapon_id: String) -> int:
	return owned_weapons.get(weapon_id, 0)


func apply_passive(passive_id: String):
	match passive_id:
		"max_hp_up":
			max_health += 20.0
			heal(20.0)
		"speed_up":
			speed_multiplier += 0.15
		"pickup_range":
			pickup_range += 25.0
		"armor":
			armor += 3
		"regen":
			regen_amount += 1.0
```

- [ ] **Step 2: Create player.tscn**

Create `scenes/player.tscn`:

```
[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="res://scripts/player.gd" id="1"]
[ext_resource type="Script" path="res://scripts/weapon_controller.gd" id="2"]

[sub_resource type="CircleShape2D" id="CircleShape2D"]
radius = 16.0

[sub_resource type="CircleShape2D" id="HurtboxShape"]
radius = 16.0

[node name="Player" type="CharacterBody2D"]
script = ExtResource("1")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("CircleShape2D")

[node name="Sprite" type="ColorRect" parent="."]
offset_left = -16.0
offset_top = -16.0
offset_right = 16.0
offset_bottom = 16.0
color = Color(1, 1, 1, 1)

[node name="Hurtbox" type="Area2D" parent="."]
monitorable = false

[node name="CollisionShape2D" type="CollisionShape2D" parent="Hurtbox"]
shape = SubResource("HurtboxShape")

[node name="WeaponController" type="Node" parent="."]
script = ExtResource("2")
```

---

## Task 4: Weapon Controller & Projectile

**Files:**
- Create: `scripts/weapon_controller.gd`
- Create: `scripts/projectile.gd`
- Create: `scenes/projectile.tscn`

- [ ] **Step 1: Create weapon_controller.gd**

Create `scripts/weapon_controller.gd`:

```gdscript
extends Node

var _weapon_timers: Dictionary = {}  # weapon_id -> remaining_cooldown
var _registered: bool = false
var _magic_orb_data: WeaponData
var _spin_blade_instance: Node2D = null


func _physics_process(delta):
	if not _registered:
		_register_weapons()
		_registered = true

	if GameManager.is_game_over:
		return

	var player: CharacterBody2D = get_parent()
	if not player.is_alive:
		return

	# Update cooldowns and fire weapons
	for weapon_id in player.owned_weapons:
		if not _weapon_timers.has(weapon_id):
			_weapon_timers[weapon_id] = 0.0

		_weapon_timers[weapon_id] -= delta
		if _weapon_timers[weapon_id] <= 0.0:
			var data: WeaponData = UpgradePool._weapons.get(weapon_id)
			if data:
				_fire_weapon(weapon_id, data, player)
				_weapon_timers[weapon_id] = data.cooldown


func _register_weapons():
	_magic_orb_data = WeaponData.new()
	_magic_orb_data.weapon_name = "Magic Orb"
	_magic_orb_data.weapon_id = "magic_orb"
	_magic_orb_data.damage = 10.0
	_magic_orb_data.cooldown = 1.5
	_magic_orb_data.projectile_speed = 300.0
	_magic_orb_data.projectile_count = 1
	_magic_orb_data.projectile_pierce = 1
	_magic_orb_data.projectile_range = 500.0
	_magic_orb_data.description = "Fires an orb at the nearest enemy"
	_magic_orb_data.color = Color(0.4, 0.6, 1.0)
	_magic_orb_data.projectile_size = 8.0
	_magic_orb_data.weapon_type = "projectile"
	UpgradePool.register_weapon("magic_orb", _magic_orb_data)

	var spin_blade_data = WeaponData.new()
	spin_blade_data.weapon_name = "Spin Blade"
	spin_blade_data.weapon_id = "spin_blade"
	spin_blade_data.damage = 15.0
	spin_blade_data.cooldown = 3.0
	spin_blade_data.description = "Orbiting blades around the player"
	spin_blade_data.color = Color(0.8, 0.8, 0.9)
	spin_blade_data.weapon_type = "orbit"
	spin_blade_data.orbit_count = 2
	spin_blade_data.orbit_radius = 80.0
	UpgradePool.register_weapon("spin_blade", spin_blade_data)

	var lightning_data = WeaponData.new()
	lightning_data.weapon_name = "Lightning"
	lightning_data.weapon_id = "lightning"
	lightning_data.damage = 20.0
	lightning_data.cooldown = 2.0
	lightning_data.description = "Strikes a random nearby enemy"
	lightning_data.color = Color(1.0, 1.0, 0.3)
	lightning_data.weapon_type = "lightning"
	lightning_data.projectile_range = 300.0
	lightning_data.chain_count = 1
	UpgradePool.register_weapon("lightning", lightning_data)

	var fire_burst_data = WeaponData.new()
	fire_burst_data.weapon_name = "Fire Burst"
	fire_burst_data.weapon_id = "fire_burst"
	fire_burst_data.damage = 12.0
	fire_burst_data.cooldown = 3.0
	fire_burst_data.description = "AoE explosion around the player"
	fire_burst_data.color = Color(1.0, 0.3, 0.1)
	fire_burst_data.weapon_type = "aoe"
	fire_burst_data.aoe_radius = 80.0
	UpgradePool.register_weapon("fire_burst", fire_burst_data)


func _fire_weapon(weapon_id: String, data: WeaponData, player: CharacterBody2D):
	var level: int = player.owned_weapons[weapon_id]
	match data.weapon_type:
		"projectile":
			_fire_projectile(data, level, player)
		"orbit":
			_activate_spin_blade(data, level, player)
		"lightning":
			_fire_lightning(data, level, player)
		"aoe":
			_fire_aoe(data, level, player)


func _fire_projectile(data: WeaponData, level: int, player: CharacterBody2D):
	var count: int = data.projectile_count + (level - 1)
	var pierce: int = data.projectile_pierce + (level - 1)
	var damage: float = data.damage + (level - 1) * 3.0

	var enemies = _get_enemies_in_range(player, 600.0)
	if enemies.is_empty():
		return

	for i in range(count):
		var target: Node2D = enemies[i % enemies.size()]
		var projectile_scene = preload("res://scenes/projectile.tscn")
		var proj = projectile_scene.instantiate()
		proj.setup(
			player.global_position,
			target.global_position,
			data.projectile_speed,
			damage,
			pierce,
			data.color,
			data.projectile_size
		)
		player.get_parent().get_node("ProjectileManager").add_child(proj)


func _activate_spin_blade(data: WeaponData, level: int, player: CharacterBody2D):
	var orbit_count: int = data.orbit_count + (level - 1)
	var damage: float = data.damage + (level - 1) * 4.0
	var radius: float = data.orbit_radius + (level - 1) * 10.0

	if _spin_blade_instance and is_instance_valid(_spin_blade_instance):
		_spin_blade_instance.queue_free()

	var spin_blade_script = load("res://scripts/spin_blade.gd")
	_spin_blade_instance = Node2D.new()
	_spin_blade_instance.set_script(spin_blade_script)
	_spin_blade_instance.setup(orbit_count, damage, radius, data.color, data.projectile_size)
	player.get_parent().get_node("ProjectileManager").add_child(_spin_blade_instance)
	_spin_blade_instance.global_position = player.global_position


func _fire_lightning(data: WeaponData, level: int, player: CharacterBody2D):
	var damage: float = data.damage + (level - 1) * 5.0
	var range_val: float = data.projectile_range + (level - 1) * 30.0
	var chains: int = data.chain_count + (level - 1)

	var enemies = _get_enemies_in_range(player, range_val)
	if enemies.is_empty():
		return

	for i in range(mini(1 + chains, enemies.size())):
		var target: Node2D = enemies[i]
		if target.has_method("take_damage"):
			target.take_damage(damage)
		# Visual: draw a line from player to enemy
		_create_lightning_effect(player.global_position, target.global_position, data.color)


func _fire_aoe(data: WeaponData, level: int, player: CharacterBody2D):
	var damage: float = data.damage + (level - 1) * 3.0
	var radius: float = data.aoe_radius + (level - 1) * 15.0

	var enemies = _get_enemies_in_range(player, radius)
	for enemy in enemies:
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)

	# Visual: expanding circle
	_create_aoe_effect(player.global_position, radius, data.color)


func _get_enemies_in_range(player: Node2D, range_val: float) -> Array:
	var enemies: Array = []
	var all_enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in all_enemies:
		if is_instance_valid(enemy) and enemy.is_alive:
			var dist = player.global_position.distance_to(enemy.global_position)
			if dist <= range_val:
				enemies.append(enemy)
	# Sort by distance
	enemies.sort_custom(func(a, b):
		return player.global_position.distance_to(a.global_position) < player.global_position.distance_to(b.global_position)
	)
	return enemies


func _create_lightning_effect(from: Vector2, to: Vector2, color: Color):
	var line = Line2D.new()
	line.width = 3.0
	line.default_color = color
	# Zigzag lightning
	var points = [from]
	var segments = 5
	for i in range(1, segments):
		var t = float(i) / segments
		var point = from.lerp(to, t)
		point += Vector2(randf_range(-15, 15), randf_range(-15, 15))
		points.append(point)
	points.append(to)
	line.points = points
	get_parent().get_parent().get_node("ProjectileManager").add_child(line)
	# Auto-remove after 0.15s
	var tween = line.create_tween()
	tween.tween_interval(0.15)
	tween.tween_callback(line.queue_free)


func _create_aoe_effect(pos: Vector2, radius: float, color: Color):
	var circle = Node2D.new()
	var script = GDScript.new()
	script.source_code = """
extends Node2D
var radius: float = 0.0
var target_radius: float = 0.0
var color: Color = Color.WHITE
var alpha: float = 0.6

func _process(delta):
	radius = lerpf(radius, target_radius, delta * 10.0)
	alpha -= delta * 3.0
	if alpha <= 0.0:
		queue_free()
	queue_redraw()

func _draw():
	draw_circle(Vector2.ZERO, radius, Color(color.r, color.g, color.b, alpha))
"""
	circle.set_script(script)
	circle.radius = 0.0
	circle.target_radius = radius
	circle.color = color
	circle.global_position = pos
	get_parent().get_parent().get_node("ProjectileManager").add_child(circle)


# Keep spin blade following the player
func _process(_delta):
	if _spin_blade_instance and is_instance_valid(_spin_blade_instance):
		var player: CharacterBody2D = get_parent()
		_spin_blade_instance.global_position = player.global_position
```

- [ ] **Step 2: Create projectile.gd**

Create `scripts/projectile.gd`:

```gdscript
extends Area2D

var speed: float = 300.0
var damage: float = 10.0
var pierce: int = 1
var direction: Vector2 = Vector2.RIGHT
var color: Color = Color.WHITE
var size: float = 8.0
var lifetime: float = 5.0
var _hit_enemies: Array = []


func setup(pos: Vector2, target_pos: Vector2, spd: float, dmg: float, prc: int, col: Color, sz: float):
	global_position = pos
	direction = pos.direction_to(target_pos)
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	speed = spd
	damage = dmg
	pierce = prc
	color = col
	size = sz
	# Update visual
	var sprite = $Sprite as ColorRect
	if sprite:
		sprite.color = color
		sprite.size = Vector2(size * 2, size * 2)
		sprite.position = -sprite.size / 2.0
	var shape = $CollisionShape2D.shape as CircleShape2D
	if shape:
		shape.radius = size


func _physics_process(delta):
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

	# Rotate to face direction
	rotation = direction.angle()


func _on_body_entered(body: Node2D):
	if body.is_in_group("enemies") and body.has_method("take_damage") and not body in _hit_enemies:
		body.take_damage(damage)
		_hit_enemies.append(body)
		pierce -= 1
		if pierce <= 0:
			queue_free()
```

- [ ] **Step 3: Create projectile.tscn**

Create `scenes/projectile.tscn`:

```
[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="res://scripts/projectile.gd" id="1"]

[sub_resource type="CircleShape2D" id="CircleShape2D"]
radius = 8.0

[node name="Projectile" type="Area2D"]
script = ExtResource("1")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("CircleShape2D")

[node name="Sprite" type="ColorRect" parent="."]
offset_left = -8.0
offset_top = -8.0
offset_right = 8.0
offset_bottom = 8.0
color = Color(1, 1, 1, 1)

[connection signal="body_entered" from="." to="." method="_on_body_entered"]
```

---

## Task 5: Spin Blade (Orbit Weapon)

**Files:**
- Create: `scripts/spin_blade.gd`

- [ ] **Step 1: Create spin_blade.gd**

Create `scripts/spin_blade.gd`:

```gdscript
extends Node2D

var orbit_count: int = 2
var damage: float = 15.0
var orbit_radius: float = 80.0
var color: Color = Color.WHITE
var blade_size: float = 10.0
var rotation_speed: float = 3.0
var _angle: float = 0.0
var _hit_cooldowns: Dictionary = {}


func setup(count: int, dmg: float, radius: float, col: Color, sz: float):
	orbit_count = count
	damage = dmg
	orbit_radius = radius
	color = col
	blade_size = sz


func _physics_process(delta):
	_angle += rotation_speed * delta

	# Clear expired cooldowns
	var to_remove: Array = []
	for enemy in _hit_cooldowns:
		_hit_cooldowns[enemy] -= delta
		if _hit_cooldowns[enemy] <= 0:
			to_remove.append(enemy)
	for e in to_remove:
		_hit_cooldowns.erase(e)

	queue_redraw()

	# Check collisions
	var all_enemies = get_tree().get_nodes_in_group("enemies")
	for i in range(orbit_count):
		var blade_angle = _angle + (TAU * i / orbit_count)
		var blade_pos = Vector2(cos(blade_angle), sin(blade_angle)) * orbit_radius
		for enemy in all_enemies:
			if is_instance_valid(enemy) and enemy.is_alive and not _hit_cooldowns.has(enemy):
				var dist = blade_pos.distance_to(enemy.global_position - global_position)
				if dist < blade_size + 10.0:
					enemy.take_damage(damage)
					_hit_cooldowns[enemy] = 0.3


func _draw():
	for i in range(orbit_count):
		var blade_angle = _angle + (TAU * i / orbit_count)
		var pos = Vector2(cos(blade_angle), sin(blade_angle)) * orbit_radius
		# Draw a small rotated rectangle (blade shape)
		draw_set_transform(pos, blade_angle, Vector2.ONE)
		var half = blade_size
		draw_rect(Rect2(-half * 0.3, -half, half * 0.6, half * 2), color)
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
```

---

## Task 6: Enemy System

**Files:**
- Create: `scripts/enemy.gd`
- Create: `scenes/enemy.tscn`

- [ ] **Step 1: Create enemy.gd**

Create `scripts/enemy.gd`:

```gdscript
extends CharacterBody2D

@export var enemy_data: EnemyData

var current_hp: float
var is_alive: bool = true
var _flash_timer: float = 0.0
var _player: Node2D = null


func _ready():
	if enemy_data:
		current_hp = enemy_data.max_hp
		add_to_group("enemies")
		# Set visual
		var sprite = $Sprite as ColorRect
		if sprite:
			sprite.color = enemy_data.color
			sprite.size = Vector2(enemy_data.size * 2, enemy_data.size * 2)
			sprite.position = -sprite.size / 2.0
		var shape = $CollisionShape2D.shape as CircleShape2D
		if shape:
			shape.radius = enemy_data.size
		# Set hitbox collision shape too
		var hitbox_shape = $Hitbox/CollisionShape2D.shape as CircleShape2D
		if hitbox_shape:
			hitbox_shape.radius = enemy_data.size

	# Scale HP by elapsed time
	var time_bonus = 1.0 + (GameManager.elapsed_time / 60.0) * 0.1
	current_hp *= time_bonus


func _physics_process(delta):
	if not is_alive:
		return

	if not _player or not is_instance_valid(_player):
		_player = _find_player()
		if not _player:
			return

	# Move toward player
	var direction = global_position.direction_to(_player.global_position)
	velocity = direction * enemy_data.speed
	move_and_slide()

	# Flash effect
	if _flash_timer > 0:
		_flash_timer -= delta
		var sprite = $Sprite as ColorRect
		if sprite:
			sprite.color = Color.WHITE if fmod(_flash_timer, 0.1) > 0.05 else enemy_data.color


func take_damage(amount: float):
	if not is_alive:
		return
	current_hp -= amount
	_flash_timer = 0.2

	if current_hp <= 0:
		die()


func die():
	is_alive = false
	GameManager.enemies_killed += 1
	GameManager.score += enemy_data.xp_value
	GameManager.enemy_count -= 1

	# Drop XP gem
	_spawn_xp_gem()

	# Chance to drop item crate
	if randf() < enemy_data.drop_chance:
		_spawn_item_crate()

	# Boss drops multiple gems
	if enemy_data.is_boss:
		for i in range(5):
			_spawn_xp_gem()

	queue_free()


func _find_player() -> Node2D:
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		return players[0]
	return null


func _spawn_xp_gem():
	var gem_scene = preload("res://scenes/xp_gem.tscn")
	var gem = gem_scene.instantiate()
	gem.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
	gem.xp_value = enemy_data.xp_value
	get_parent().get_node("PickupManager").add_child(gem)


func _spawn_item_crate():
	var crate_scene = preload("res://scenes/item_crate.tscn")
	var crate = crate_scene.instantiate()
	crate.global_position = global_position
	get_parent().get_node("PickupManager").add_child(crate)
```

- [ ] **Step 2: Create enemy.tscn**

Create `scenes/enemy.tscn`:

```
[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="res://scripts/enemy.gd" id="1"]

[sub_resource type="CircleShape2D" id="EnemyShape"]
radius = 16.0

[sub_resource type="CircleShape2D" id="HitboxShape"]
radius = 16.0

[node name="Enemy" type="CharacterBody2D"]
script = ExtResource("1")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("EnemyShape")

[node name="Sprite" type="ColorRect" parent="."]
offset_left = -16.0
offset_top = -16.0
offset_right = 16.0
offset_bottom = 16.0
color = Color(0, 1, 0, 1)

[node name="Hitbox" type="Area2D" parent="."]
collision_mask = 2

[node name="CollisionShape2D" type="CollisionShape2D" parent="Hitbox"]
shape = SubResource("HitboxShape")
```

---

## Task 7: Enemy Spawner

**Files:**
- Create: `scripts/enemy_spawner.gd`

- [ ] **Step 1: Create enemy_spawner.gd**

Create `scripts/enemy_spawner.gd`:

```gdscript
extends Node

var _spawn_timer: float = 0.0
var _boss_timer: float = 60.0
var _camera: Camera2D = null


func _ready():
	_camera = get_node("/root/Arena/Camera2D")


func _physics_process(delta):
	if GameManager.is_game_over:
		return

	GameManager.elapsed_time += delta
	_spawn_timer -= delta
	_boss_timer -= delta

	# Spawn regular enemies
	if _spawn_timer <= 0:
		var spawn_count = _get_spawn_count()
		var spawn_interval = _get_spawn_interval()
		_spawn_timer = spawn_interval

		for i in range(spawn_count):
			_spawn_enemy(_get_random_enemy_data())

	# Spawn boss
	if _boss_timer <= 0:
		_boss_timer = 60.0
		_spawn_boss()


func _get_spawn_interval() -> float:
	var t = GameManager.elapsed_time
	if t < 30:
		return 2.0
	elif t < 60:
		return 1.5
	elif t < 120:
		return 1.2
	else:
		return 0.8


func _get_spawn_count() -> int:
	var t = GameManager.elapsed_time
	if t < 30:
		return 1
	elif t < 60:
		return 2
	elif t < 120:
		return 3
	else:
		return 4


func _get_random_enemy_data() -> EnemyData:
	var t = GameManager.elapsed_time
	var data = EnemyData.new()

	var roll = randf()
	if t < 30:
		data.enemy_name = "Slime"
		data.max_hp = 20.0
		data.speed = 60.0
		data.damage = 10.0
		data.xp_value = 5
		data.color = Color.GREEN
		data.size = 16.0
	elif t < 60:
		if roll < 0.6:
			data.enemy_name = "Slime"
			data.max_hp = 25.0
			data.speed = 65.0
			data.damage = 12.0
			data.xp_value = 6
			data.color = Color.GREEN
			data.size = 16.0
		else:
			data.enemy_name = "Bat"
			data.max_hp = 10.0
			data.speed = 120.0
			data.damage = 5.0
			data.xp_value = 3
			data.color = Color(0.6, 0.3, 0.8)
			data.size = 10.0
	else:
		if roll < 0.4:
			data.enemy_name = "Slime"
			data.max_hp = 30.0
			data.speed = 70.0
			data.damage = 14.0
			data.xp_value = 7
			data.color = Color.GREEN
			data.size = 16.0
		elif roll < 0.7:
			data.enemy_name = "Bat"
			data.max_hp = 15.0
			data.speed = 130.0
			data.damage = 7.0
			data.xp_value = 4
			data.color = Color(0.6, 0.3, 0.8)
			data.size = 10.0
		else:
			data.enemy_name = "Golem"
			data.max_hp = 80.0
			data.speed = 30.0
			data.damage = 25.0
			data.xp_value = 15
			data.color = Color(0.6, 0.4, 0.2)
			data.size = 24.0

	data.drop_chance = 0.1
	return data


func _spawn_boss():
	var data = EnemyData.new()
	data.enemy_name = "Boss"
	data.max_hp = 500.0
	data.speed = 40.0
	data.damage = 40.0
	data.xp_value = 100
	data.color = Color(0.9, 0.1, 0.1)
	data.size = 32.0
	data.is_boss = true
	data.drop_chance = 1.0
	_spawn_enemy(data)


func _spawn_enemy(data: EnemyData):
	var enemy_scene = preload("res://scenes/enemy.tscn")
	var enemy = enemy_scene.instantiate()
	enemy.enemy_data = data

	# Spawn outside camera view
	var spawn_pos = _get_spawn_position()
	enemy.global_position = spawn_pos

	get_parent().add_child(enemy)
	GameManager.enemy_count += 1


func _get_spawn_position() -> Vector2:
	var camera: Camera2D = _camera
	if not camera:
		return Vector2(randf_range(-500, 500), randf_range(-500, 500))

	var viewport_size = camera.get_viewport().get_visible_rect().size
	var cam_pos = camera.global_position
	var margin = 50.0

	# Pick random edge: 0=top, 1=bottom, 2=left, 3=right
	var edge = randi() % 4
	var pos = cam_pos
	match edge:
		0:  # top
			pos = Vector2(cam_pos.x + randf_range(-viewport_size.x, viewport_size.x), cam_pos.y - viewport_size.y / 2 - margin)
		1:  # bottom
			pos = Vector2(cam_pos.x + randf_range(-viewport_size.x, viewport_size.x), cam_pos.y + viewport_size.y / 2 + margin)
		2:  # left
			pos = Vector2(cam_pos.x - viewport_size.x / 2 - margin, cam_pos.y + randf_range(-viewport_size.y, viewport_size.y))
		3:  # right
			pos = Vector2(cam_pos.x + viewport_size.x / 2 + margin, cam_pos.y + randf_range(-viewport_size.y, viewport_size.y))

	# Clamp to arena bounds (1500px radius from center)
	pos = pos.clamp(Vector2(-1500, -1500), Vector2(1500, 1500))
	return pos
```

---

## Task 8: XP Gems & Pickup Manager

**Files:**
- Create: `scripts/xp_gem.gd`
- Create: `scenes/xp_gem.tscn`
- Create: `scripts/pickup_manager.gd`

- [ ] **Step 1: Create xp_gem.gd**

Create `scripts/xp_gem.gd`:

```gdscript
extends Area2D

var xp_value: int = 5
var magnet_speed: float = 300.0
var is_moving_to_player: bool = false
var _player: Node2D = null


func _ready():
	# Set visual based on value
	var sprite = $Sprite as ColorRect
	if sprite:
		if xp_value >= 15:
			sprite.color = Color(0.2, 0.4, 1.0)  # Blue for big
			sprite.size = Vector2(12, 12)
		elif xp_value >= 10:
			sprite.color = Color.GREEN
			sprite.size = Vector2(10, 10)
		else:
			sprite.color = Color.YELLOW
			sprite.size = Vector2(8, 8)
		sprite.position = -sprite.size / 2.0


func _physics_process(delta):
	if not _player or not is_instance_valid(_player):
		_player = _find_player()
		if not _player:
			return

	var dist = global_position.distance_to(_player.global_position)
	if dist <= _player.pickup_range:
		is_moving_to_player = true

	if is_moving_to_player:
		var direction = global_position.direction_to(_player.global_position)
		global_position += direction * magnet_speed * delta
		magnet_speed += 200.0 * delta  # Accelerate

		if dist < 10.0:
			_collect()


func _find_player() -> Node2D:
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		return players[0]
	return null


func _collect():
	GameManager.add_xp(xp_value)
	queue_free()
```

- [ ] **Step 2: Create xp_gem.tscn**

Create `scenes/xp_gem.tscn`:

```
[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="res://scripts/xp_gem.gd" id="1"]

[sub_resource type="CircleShape2D" id="GemShape"]
radius = 6.0

[node name="XPGem" type="Area2D"]
script = ExtResource("1")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("GemShape")

[node name="Sprite" type="ColorRect" parent="."]
offset_left = -4.0
offset_top = -4.0
offset_right = 4.0
offset_bottom = 4.0
color = Color(1, 1, 0, 1)
```

- [ ] **Step 3: Create item_crate.gd and pickup_manager.gd**

Create `scripts/item_crate.gd`:

```gdscript
extends Area2D

var crate_type: String = ""  # "heal", "xp_bonus", "speed_boost"
var _player: Node2D = null


func _ready():
	# Random crate type
	var roll = randf()
	if roll < 0.5:
		crate_type = "heal"
		$Sprite.color = Color.GREEN
	elif roll < 0.8:
		crate_type = "xp_bonus"
		$Sprite.color = Color.CYAN
	else:
		crate_type = "speed_boost"
		$Sprite.color = Color(1, 0.5, 0)


func _physics_process(_delta):
	if not _player or not is_instance_valid(_player):
		_player = _find_player()
		if not _player:
			return

	var dist = global_position.distance_to(_player.global_position)
	if dist < 20.0:
		_collect()


func _find_player() -> Node2D:
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		return players[0]
	return null


func _collect():
	match crate_type:
		"heal":
			_player.heal(30.0)
		"xp_bonus":
			GameManager.add_xp(50.0)
		"speed_boost":
			_player.speed_multiplier += 0.3
			# Revert after 10s
			get_tree().create_timer(10.0).timeout.connect(func():
				if is_instance_valid(_player):
					_player.speed_multiplier -= 0.3
			)
	queue_free()
```

Create `scripts/pickup_manager.gd`:

```gdscript
extends Node2D

# PickupManager just acts as a container node for gems and crates.
# No logic needed here — gems and crates manage themselves.
```

Create `scenes/item_crate.tscn`:

```
[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="res://scripts/item_crate.gd" id="1"]

[sub_resource type="RectangleShape2D" id="CrateShape"]
size = Vector2(16, 16)

[node name="ItemCrate" type="Area2D"]
script = ExtResource("1")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("CrateShape")

[node name="Sprite" type="ColorRect" parent="."]
offset_left = -8.0
offset_top = -8.0
offset_right = 8.0
offset_bottom = 8.0
color = Color(0, 1, 0, 1)
```

---

## Task 9: HUD (Health, XP, Timer, Upgrade Panel)

**Files:**
- Create: `scripts/hud.gd`
- Create: `scenes/hud.tscn`

- [ ] **Step 1: Create hud.gd**

Create `scripts/hud.gd`:

```gdscript
extends CanvasLayer

var _upgrade_options: Array[Dictionary] = []
var _pending_level_ups: int = 0


func _ready():
	GameManager.health_changed.connect(_on_health_changed)
	GameManager.xp_changed.connect(_on_xp_changed)
	GameManager.level_up.connect(_on_level_up)
	GameManager.player_died.connect(_on_player_died)

	$UpgradePanel.visible = false
	$UpgradePanel/Panel/Card1.gui_input.connect(_on_card_input.bind(0))
	$UpgradePanel/Panel/Card2.gui_input.connect(_on_card_input.bind(1))
	$UpgradePanel/Panel/Card3.gui_input.connect(_on_card_input.bind(2))


func _process(_delta):
	$TimerLabel.text = GameManager.format_time(GameManager.elapsed_time)


func _on_health_changed(current: float, max_hp: float):
	$HealthBar.value = (current / max_hp) * 100.0
	$HealthLabel.text = "%d/%d" % [int(current), int(max_hp)]


func _on_xp_changed(current: float, needed: float):
	$XPBar.value = (current / needed) * 100.0
	$LevelLabel.text = "Lv %d" % GameManager.player_level


func _on_level_up(_new_level: int):
	_pending_level_ups += 1
	_show_upgrade_panel()


func _on_player_died():
	# Handled by player.gd scene transition
	pass


func _show_upgrade_panel():
	get_tree().paused = true
	_pending_level_ups -= 1

	var player = _get_player()
	if not player:
		return

	_upgrade_options = UpgradePool.get_random_upgrades(player.owned_weapons, 3)

	for i in range(3):
		var card = $UpgradePanel/Panel.get_child(i) as Control
		if i < _upgrade_options.size():
			card.visible = true
			var option = _upgrade_options[i]
			card.get_node("NameLabel").text = option.name
			card.get_node("DescLabel").text = option.description
			card.get_node("Icon").color = option.icon_color
			card.get_node("KeyLabel").text = "[%d]" % (i + 1)
		else:
			card.visible = false

	$UpgradePanel.visible = true


func _on_card_input(event: InputEvent, index: int):
	if event is InputEventMouseButton and event.pressed:
		_select_upgrade(index)


func _input(event: InputEvent):
	if $UpgradePanel.visible and event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: _select_upgrade(0)
			KEY_2: _select_upgrade(1)
			KEY_3: _select_upgrade(2)


func _select_upgrade(index: int):
	if index >= _upgrade_options.size():
		return

	var option = _upgrade_options[index]
	var player = _get_player()
	if not player:
		return

	match option.type:
		"new_weapon":
			player.add_weapon(option.id)
		"weapon_upgrade":
			player.upgrade_weapon(option.id)
		"passive":
			player.apply_passive(option.id)

	$UpgradePanel.visible = false

	if _pending_level_ups > 0:
		_show_upgrade_panel()
	else:
		get_tree().paused = false


func _get_player() -> Node2D:
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		return players[0]
	return null
```

- [ ] **Step 2: Create hud.tscn**

Create `scenes/hud.tscn`:

```
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/hud.gd" id="1"]

[node name="HUD" type="CanvasLayer"]
script = ExtResource("1")

[node name="HealthBar" type="ProgressBar" parent="."]
offset_left = 20.0
offset_top = 20.0
offset_right = 220.0
offset_bottom = 36.0
show_percentage = false

[node name="HealthLabel" type="Label" parent="."]
offset_left = 20.0
offset_top = 40.0
offset_right = 220.0
offset_bottom = 56.0
text = "100/100"

[node name="XPBar" type="ProgressBar" parent="."]
offset_left = 20.0
offset_top = 60.0
offset_right = 220.0
offset_bottom = 72.0
show_percentage = false

[node name="LevelLabel" type="Label" parent="."]
offset_left = 20.0
offset_top = 76.0
offset_right = 220.0
offset_bottom = 92.0
text = "Lv 1"

[node name="TimerLabel" type="Label" parent="."]
offset_left = 1100.0
offset_top = 20.0
offset_right = 1260.0
offset_bottom = 40.0
text = "00:00"
horizontal_alignment = 2

[node name="UpgradePanel" type="Control" parent="."]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 1

[node name="Panel" type="HBoxContainer" parent="UpgradePanel"]
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -300.0
offset_top = -120.0
offset_right = 300.0
offset_bottom = 120.0
grow_horizontal = 2
grow_vertical = 2
alignment = 1

[node name="Card1" type="PanelContainer" parent="UpgradePanel/Panel"]
custom_minimum_size = Vector2(180, 240)

[node name="Icon" type="ColorRect" parent="UpgradePanel/Panel/Card1"]
layout_mode = 2
custom_minimum_size = Vector2(40, 40)
color = Color(1, 1, 1, 1)

[node name="NameLabel" type="Label" parent="UpgradePanel/Panel/Card1"]
layout_mode = 2
text = "Weapon"
horizontal_alignment = 1

[node name="DescLabel" type="Label" parent="UpgradePanel/Panel/Card1"]
layout_mode = 2
text = "Description"
horizontal_alignment = 1
autowrap_mode = 2

[node name="KeyLabel" type="Label" parent="UpgradePanel/Panel/Card1"]
layout_mode = 2
text = "[1]"
horizontal_alignment = 1

[node name="Card2" type="PanelContainer" parent="UpgradePanel/Panel"]
custom_minimum_size = Vector2(180, 240)

[node name="Icon" type="ColorRect" parent="UpgradePanel/Panel/Card2"]
layout_mode = 2
custom_minimum_size = Vector2(40, 40)
color = Color(1, 1, 1, 1)

[node name="NameLabel" type="Label" parent="UpgradePanel/Panel/Card2"]
layout_mode = 2
text = "Weapon"
horizontal_alignment = 1

[node name="DescLabel" type="Label" parent="UpgradePanel/Panel/Card2"]
layout_mode = 2
text = "Description"
horizontal_alignment = 1
autowrap_mode = 2

[node name="KeyLabel" type="Label" parent="UpgradePanel/Panel/Card2"]
layout_mode = 2
text = "[2]"
horizontal_alignment = 1

[node name="Card3" type="PanelContainer" parent="UpgradePanel/Panel"]
custom_minimum_size = Vector2(180, 240)

[node name="Icon" type="ColorRect" parent="UpgradePanel/Panel/Card3"]
layout_mode = 2
custom_minimum_size = Vector2(40, 40)
color = Color(1, 1, 1, 1)

[node name="NameLabel" type="Label" parent="UpgradePanel/Panel/Card3"]
layout_mode = 2
text = "Weapon"
horizontal_alignment = 1

[node name="DescLabel" type="Label" parent="UpgradePanel/Panel/Card3"]
layout_mode = 2
text = "Description"
horizontal_alignment = 1
autowrap_mode = 2

[node name="KeyLabel" type="Label" parent="UpgradePanel/Panel/Card3"]
layout_mode = 2
text = "[3]"
horizontal_alignment = 1
```

---

## Task 10: Arena (Main Gameplay Scene)

**Files:**
- Create: `scripts/arena.gd`
- Create: `scenes/arena.tscn`

- [ ] **Step 1: Create arena.gd**

Create `scripts/arena.gd`:

```gdscript
extends Node2D


func _ready():
	GameManager.reset()
	# Give player starting weapon
	var player = $Player
	player.add_weapon("magic_orb")
	player.add_to_group("players")

	# Connect enemy hitbox to player hurtbox
	# Enemies deal damage on contact via Hurtbox detection
	player.hurtbox.body_entered.connect(_on_player_hurtbox_entered.bind(player))


func _on_player_hurtbox_entered(body: Node2D, player: CharacterBody2D):
	if body.is_in_group("enemies") and body.is_alive and player.is_alive:
		player.take_damage(body.enemy_data.damage)
```

- [ ] **Step 2: Create arena.tscn**

Create `scenes/arena.tscn`:

```
[gd_scene load_steps=6 format=3]

[ext_resource type="Script" path="res://scripts/arena.gd" id="1"]
[ext_resource type="PackedScene" path="res://scenes/player.tscn" id="2"]
[ext_resource type="Script" path="res://scripts/enemy_spawner.gd" id="3"]
[ext_resource type="Script" path="res://scripts/pickup_manager.gd" id="4"]
[ext_resource type="PackedScene" path="res://scenes/hud.tscn" id="5"]

[node name="Arena" type="Node2D"]
script = ExtResource("1")

[node name="Ground" type="ColorRect" parent="."]
offset_left = -1500.0
offset_top = -1500.0
offset_right = 1500.0
offset_bottom = 1500.0
color = Color(0.15, 0.15, 0.22, 1)

[node name="Camera2D" type="Camera2D" parent="."]
zoom = Vector2(1, 1)

[node name="Player" parent="." instance=ExtResource("2")]

[node name="EnemySpawner" type="Node" parent="."]
script = ExtResource("3")

[node name="ProjectileManager" type="Node2D" parent="."]

[node name="PickupManager" type="Node2D" parent="."]
script = ExtResource("4")

[node name="HUD" parent="." instance=ExtResource("5")]
```

---

## Task 11: Game Over Screen

**Files:**
- Create: `scripts/game_over_screen.gd`
- Create: `scenes/game_over_screen.tscn`

- [ ] **Step 1: Create game_over_screen.gd**

Create `scripts/game_over_screen.gd`:

```gdscript
extends Control


func _ready():
	$VBox/TimeLabel.text = "Time: %s" % GameManager.format_time(GameManager.elapsed_time)
	$VBox/KillsLabel.text = "Enemies Killed: %d" % GameManager.enemies_killed
	$VBox/LevelLabel.text = "Level: %d" % GameManager.player_level
	$VBox/ScoreLabel.text = "Score: %d" % GameManager.score

	$VBox/RestartButton.pressed.connect(_on_restart)
	$VBox/MenuButton.pressed.connect(_on_menu)


func _on_restart():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/arena.tscn")


func _on_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")
```

- [ ] **Step 2: Create game_over_screen.tscn**

Create `scenes/game_over_screen.tscn`:

```
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/game_over_screen.gd" id="1"]

[node name="GameOverScreen" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
script = ExtResource("1")

[node name="Background" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
color = Color(0.1, 0.05, 0.05, 0.9)

[node name="VBox" type="VBoxContainer" parent="."]
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -150.0
offset_top = -150.0
offset_right = 150.0
offset_bottom = 150.0
grow_horizontal = 2
grow_vertical = 2
alignment = 1

[node name="Title" type="Label" parent="VBox"]
layout_mode = 2
text = "GAME OVER"
horizontal_alignment = 1

[node name="TimeLabel" type="Label" parent="VBox"]
layout_mode = 2
text = "Time: 00:00"
horizontal_alignment = 1

[node name="KillsLabel" type="Label" parent="VBox"]
layout_mode = 2
text = "Enemies Killed: 0"
horizontal_alignment = 1

[node name="LevelLabel" type="Label" parent="VBox"]
layout_mode = 2
text = "Level: 1"
horizontal_alignment = 1

[node name="ScoreLabel" type="Label" parent="VBox"]
layout_mode = 2
text = "Score: 0"
horizontal_alignment = 1

[node name="RestartButton" type="Button" parent="VBox"]
layout_mode = 2
text = "Restart"

[node name="MenuButton" type="Button" parent="VBox"]
layout_mode = 2
text = "Main Menu"
```

---

## Task 12: Camera Follow & Polish

**Files:**
- Modify: `scripts/arena.gd`

- [ ] **Step 1: Add camera follow logic to arena.gd**

Update `scripts/arena.gd` — add `_process` to make camera follow player:

```gdscript
extends Node2D


func _ready():
	GameManager.reset()
	var player = $Player
	player.add_weapon("magic_orb")
	player.add_to_group("players")
	player.hurtbox.body_entered.connect(_on_player_hurtbox_entered.bind(player))


func _process(_delta):
	# Camera follows player
	var player = $Player
	if player and is_instance_valid(player):
		$Camera2D.global_position = player.global_position


func _on_player_hurtbox_entered(body: Node2D, player: CharacterBody2D):
	if body.is_in_group("enemies") and body.is_alive and player.is_alive:
		player.take_damage(body.enemy_data.damage)
```

---

## Task 13: Collision Layer Setup

**Files:**
- Modify: `project.godot`

- [ ] **Step 1: Add collision layer configuration**

Add to `project.godot` under `[physics]`:

```ini
[physics]

2d/collision_layer_1_name="Player"
2d/collision_layer_2_name="Enemies"
2d/collision_layer_3_name="Projectiles"
2d/collision_layer_4_name="Pickups"
```

**Layer assignments**:
- Player: layer 1 (player body), mask 2 (detects enemies)
- Enemy: layer 2 (enemy body), mask 1 (detects player)
- Projectile: layer 3, mask 2 (hits enemies)
- XP Gem: layer 4
- Item Crate: layer 4

These are set in the scene files via `collision_layer` and `collision_mask` properties. The implementation tasks above already account for this.

---

## Task 14: Run & Verify

- [ ] **Step 1: Create all directories**

Run:
```bash
mkdir -p scenes scripts/autoload scripts/data resources/weapons resources/enemies
```

- [ ] **Step 2: Open project in Godot**

Run:
```bash
open /Applications/Godot.app
```

Then in Godot: Project → Import → select `/Users/ks_128/Documents/godot_demo/project.godot`

- [ ] **Step 3: Verify the game runs**

Press F5 or click the Play button in Godot editor. Expected:
1. Title screen appears with "Survivor Arena" text and "Start Game" button
2. Clicking "Start Game" loads the arena
3. Player (white square) moves with WASD
4. Enemies (colored shapes) spawn and chase the player
5. Magic orb (blue circle) auto-fires at nearest enemy
6. Enemies drop yellow XP gems on death
7. Collecting enough gems triggers level-up with 3-card selection
8. Player death shows game over screen with stats
9. Restart returns to arena
