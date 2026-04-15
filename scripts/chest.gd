extends Area2D

# Chest interaction constants (from design spec)
const CHEST_PICKUP_RANGE: float = 30.0
const CHEST_PROMPT_RANGE: float = 60.0
const CHEST_COST: int = 20
const CHEST_OPEN_ANIM_DURATION: float = 0.3

# Reward constants
const REWARD_HEAL_AMOUNT: float = 3.0
const REWARD_SPEED_BONUS: float = 0.5
const REWARD_SPEED_DURATION: float = 10.0
const REWARD_XP_AMOUNT: float = 20.0

# Visual constants
const COLLISION_RADIUS: float = 15.0

var _player: Node2D = null
var _is_opened: bool = false


func _ready() -> void:
	# Build visual: Sprite2D with chest texture
	var visual: Sprite2D = Sprite2D.new()
	visual.texture = load("res://assets/sprites/pickups/chest.png")
	visual.z_index = 1
	add_child(visual)

	# Build collision shape
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = COLLISION_RADIUS
	var collision: CollisionShape2D = CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)

	# Build prompt label
	var prompt: Label = Label.new()
	prompt.name = "PromptLabel"
	prompt.position = Vector2(-50, -35)
	prompt.size = Vector2(100, 20)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.visible = false
	add_child(prompt)


func _physics_process(_delta: float) -> void:
	if _is_opened:
		return

	if not _player or not is_instance_valid(_player):
		_player = GameManager.find_player()
		if not _player:
			return

	var dist: float = global_position.distance_to(_player.global_position)
	var prompt: Label = get_node_or_null("PromptLabel")
	if not prompt:
		return

	if dist <= CHEST_PROMPT_RANGE:
		if GameManager.gold >= CHEST_COST:
			prompt.text = "[E] Open (%d Gold)" % CHEST_COST
			prompt.add_theme_color_override("font_color", Color.WHITE)
		else:
			prompt.text = "Need %d Gold" % CHEST_COST
			prompt.add_theme_color_override("font_color", Color.GRAY)

		prompt.visible = true

		# Check interaction
		if dist <= CHEST_PICKUP_RANGE and Input.is_action_just_pressed("interact"):
			if GameManager.gold >= CHEST_COST:
				_open()
	else:
		prompt.visible = false


func _open() -> void:
	_is_opened = true

	# Deduct gold
	GameManager.gold -= CHEST_COST
	GameManager.gold_changed.emit(GameManager.gold)

	# Roll reward (equal 1/3 chance)
	var roll: float = randf()
	if roll < 0.333:
		_apply_heal_reward()
	elif roll < 0.666:
		_apply_speed_reward()
	else:
		_apply_xp_reward()

	# Hide prompt
	var prompt: Label = get_node_or_null("PromptLabel")
	if prompt:
		prompt.visible = false

	# Play open animation then destroy
	_play_open_animation()


func _apply_heal_reward() -> void:
	if _player and is_instance_valid(_player):
		_player.heal(REWARD_HEAL_AMOUNT)
	_show_reward_text("+3 HP", Color(0.4, 0.733, 0.417))  # #66bb6a


func _apply_speed_reward() -> void:
	if _player and is_instance_valid(_player):
		_player.speed_multiplier += REWARD_SPEED_BONUS
		get_tree().create_timer(REWARD_SPEED_DURATION).timeout.connect(
			func():
				if is_instance_valid(_player):
					_player.speed_multiplier -= REWARD_SPEED_BONUS
		)
	_show_reward_text("Speed +50%!", Color(1.0, 0.835, 0.31))  # #ffd54f


func _apply_xp_reward() -> void:
	GameManager.add_xp(REWARD_XP_AMOUNT)
	_show_reward_text("+20 XP", Color(0.259, 0.647, 0.961))  # #42a5f5


func _show_reward_text(text: String, color: Color) -> void:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-40, -50)
	label.size = Vector2(80, 20)
	add_child(label)

	# Float up and fade animation
	var tween: Tween = create_tween()
	tween.tween_property(label, "position:y", -90.0, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.4)
	tween.tween_callback(label.queue_free)


func _play_open_animation() -> void:
	# Scale burst: 1.0 -> 1.3 -> 0.0
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), CHEST_OPEN_ANIM_DURATION * 0.5)
	tween.tween_property(self, "scale", Vector2(0.0, 0.0), CHEST_OPEN_ANIM_DURATION * 0.5)
	tween.tween_callback(queue_free)
