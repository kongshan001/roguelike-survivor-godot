extends Node2D
## Overcharge mark -- applied by thunderbeam via the Overcharge weapon_weapon synergy.
## Detonates after a delay, dealing AOE damage. Stacks up to max_stacks.

# --- Constants ---
const OVERCHARGE_DELAY: float = 3.0
const OVERCHARGE_EXPLOSION_DAMAGE: float = 10.0
const OVERCHARGE_EXPLOSION_RADIUS: float = 80.0
const OVERCHARGE_MAX_STACKS: int = 3
const INDICATOR_SIZE: Vector2 = Vector2(4.0, 4.0)
const INDICATOR_COLOR: Color = Color(0.6, 0.2, 0.9)
const BLINK_INTERVAL: float = 0.3
const EXPLOSION_RING_EXPAND_TIME: float = 0.2

# --- State ---
var _enemy: Node2D = null
var _delay: float = OVERCHARGE_DELAY
var _explosion_damage: float = OVERCHARGE_EXPLOSION_DAMAGE
var _explosion_radius: float = OVERCHARGE_EXPLOSION_RADIUS
var _max_stacks: int = OVERCHARGE_MAX_STACKS
var _stacks: int = 1
var _blink_timer: float = 0.0
var _indicator: ColorRect = null
var _detonated: bool = false


func setup(enemy: Node2D, delay: float, dmg: float, radius: float, max_stacks: int) -> void:
	_enemy = enemy
	_delay = delay
	_explosion_damage = dmg
	_explosion_radius = radius
	_max_stacks = max_stacks


func _ready() -> void:
	# Create visual indicator on the enemy
	_indicator = ColorRect.new()
	_indicator.size = INDICATOR_SIZE
	_indicator.color = INDICATOR_COLOR
	_indicator.position = -INDICATOR_SIZE * 0.5
	_indicator.z_index = 10
	add_child(_indicator)

	# Start detonation timer
	var timer: Timer = Timer.new()
	timer.name = "DetonateTimer"
	timer.wait_time = _delay
	timer.one_shot = true
	timer.autostart = true
	timer.timeout.connect(_detonate)
	add_child(timer)


func _physics_process(delta: float) -> void:
	if _detonated:
		return

	# Check if enemy is still valid
	if _enemy == null or not is_instance_valid(_enemy):
		# Enemy died or was freed -- reparent and detonate at last known position
		_reparent_to_arena()
		_detonate()
		return

	# Follow enemy position
	global_position = _enemy.global_position

	# Blink indicator
	_blink_timer += delta
	if _blink_timer >= BLINK_INTERVAL:
		_blink_timer -= BLINK_INTERVAL
		if _indicator:
			_indicator.visible = not _indicator.visible


func add_stack() -> void:
	if _stacks < _max_stacks:
		_stacks += 1


func _reparent_to_arena() -> void:
	if _enemy != null and is_instance_valid(_enemy):
		global_position = _enemy.global_position
		var parent: Node = _enemy.get_parent()
		if parent and _enemy == get_parent():
			_enemy.remove_child(self)
			parent.add_child(self)
			return
	# Fallback: if we can't reparent from enemy, just ensure we're in the tree
	if not get_parent():
		var arena: Node = get_tree().current_scene
		if arena:
			arena.add_child(self)


func _detonate() -> void:
	if _detonated:
		return
	_detonated = true

	var pos: Vector2 = global_position
	var total_damage: float = _explosion_damage * _stacks

	# Find all enemies within explosion radius
	var all_enemies: Array = GameManager.get_cached_enemies() if GameManager else get_tree().get_nodes_in_group("enemies")
	for enemy in all_enemies:
		if is_instance_valid(enemy) and enemy.is_alive:
			var dist: float = pos.distance_to(enemy.global_position)
			if dist <= _explosion_radius:
				enemy.take_damage(total_damage, "overcharge")

	# Visual: expanding purple ring
	_spawn_explosion_visual(pos)

	queue_free()


func _spawn_explosion_visual(pos: Vector2) -> void:
	var parent: Node = get_parent()
	if not parent:
		return
	var ring: ColorRect = ColorRect.new()
	ring.color = Color(0.6, 0.2, 0.9, 0.6)
	ring.size = Vector2(4.0, 4.0)
	ring.position = pos - Vector2(2.0, 2.0)
	ring.z_index = 8
	parent.call_deferred("add_child", ring)
	# Animate expansion via tween after it enters tree
	ring.ready.connect(func():
		var tween: Tween = ring.create_tween()
		var target_size: Vector2 = Vector2(_explosion_radius * 2.0, _explosion_radius * 2.0)
		tween.tween_property(ring, "size", target_size, EXPLOSION_RING_EXPAND_TIME)
		tween.parallel().tween_property(ring, "position", pos - _explosion_radius * Vector2.ONE, EXPLOSION_RING_EXPAND_TIME)
		tween.parallel().tween_property(ring, "color:a", 0.0, EXPLOSION_RING_EXPAND_TIME)
		tween.tween_callback(ring.queue_free)
	)
