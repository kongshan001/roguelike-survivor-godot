extends RefCounted
## Enemy loot/reward spawning module.
## Extracted from enemy.gd to keep it under 500 lines.
## Handles XP gems, food drops, item crates, gold calculation, and kill rewards.

# --- Food drop constants ---
const FOOD_SPAWN_OFFSET: float = 15.0
const FOOD_COLLISION_RADIUS: float = 6.0
const FOOD_SPRITE_SCALE: Vector2 = Vector2(0.25, 0.25)
const FOOD_MODULATE_COLOR: Color = Color(0.4, 0.9, 0.3)
const FOOD_DROP_BASE_CHANCE: float = 0.1

# --- Splitter child constants ---
const SPLITTER_CHILD_ID: String = "splitter_small"
const SPLITTER_CHILD_NAME: String = "小分裂者"
const SPLITTER_CHILD_HP: float = 1.0
const SPLITTER_CHILD_SPEED: float = 70.0
const SPLITTER_CHILD_DAMAGE: float = 1.0
const SPLITTER_CHILD_XP: int = 1
const SPLITTER_CHILD_COLOR: Color = Color(0.3, 0.71, 0.67)
const SPLITTER_CHILD_SIZE: float = 8.0
const SPLITTER_CHILD_OFFSET: float = 20.0

# --- XP gem spawn offset ---
const XP_GEM_SPAWN_OFFSET: float = 10.0
const XP_GEM_BONUS_OFFSET: float = 15.0

# --- Boss reward constants ---
const BOSS_BONUS_GEM_COUNT: int = 5
const ENDLESS_BOSS_GOLD: int = 50
const ENDLESS_BOSS_XP: float = 30.0
const ENDLESS_FOOD_COUNT: int = 5
const ENDLESS_FOOD_SPREAD: float = 30.0


# --- Kill rewards ---

func handle_kill_rewards(enemy_data: EnemyData, last_hit_by: String, was_crit: bool) -> void:
	## Register kill with GameManager, award gold and score.
	GameManager.register_kill()
	GameManager.score += enemy_data.xp_value
	GameManager.enemy_count -= 1

	var gold_amount: int = _calculate_gold_drop(enemy_data, last_hit_by, was_crit)
	GameManager.add_gold(gold_amount)

	# holywater_luckycoin synergy: holy water kill +1 gold
	if SynergyManager and SynergyManager.has_synergy("holywater_luckycoin"):
		if last_hit_by == "holywater":
			GameManager.add_gold(1)

	# Weapon mastery kill attribution
	if SaveManager and last_hit_by != "":
		_track_weapon_kill(last_hit_by)


func _calculate_gold_drop(enemy_data: EnemyData, last_hit_by: String, was_crit: bool) -> int:
	## Calculate gold drop amount with all bonuses applied.
	var gold_amount: int = 3
	if SaveManager:
		gold_amount = int(float(gold_amount) * (1.0 + SaveManager.get_gold_bonus()))

	# Lucky coin passive: +15% gold per stack
	var player_ref: Node2D = GameManager.find_player()
	if player_ref and player_ref.has_passive("luckycoin"):
		var lucky_stacks: int = player_ref.owned_passives.get("luckycoin", 0)
		gold_amount = int(float(gold_amount) * (1.0 + 0.15 * lucky_stacks))

	# crit_luckycoin synergy: double gold on crit
	if SynergyManager and SynergyManager.has_synergy("crit_luckycoin"):
		gold_amount *= 2

	# Combo gold bonus: +1 gold per kill when combo >= 5
	if GameManager.combo_count >= 5:
		gold_amount += 1

	return gold_amount


func _track_weapon_kill(last_hit_by: String) -> void:
	## Track weapon kill for mastery system, handling evolved weapons.
	var evolved_parents: Dictionary = {
		"thunderholywater": ["holywater", "lightning"], "fireknife": ["knife", "firestaff"],
		"holydomain": ["bible", "holywater"], "blizzard": ["frostaura", "lightning"],
		"frostknife": ["knife", "frostaura"], "flamebible": ["bible", "firestaff"],
		"thunderang": ["boomerang", "lightning"],
		"blazerang": ["boomerang", "firestaff"], "sentineltotem": ["bible", "boomerang"]
	}
	if evolved_parents.has(last_hit_by):
		for parent_id: String in evolved_parents[last_hit_by]:
			SaveManager.add_weapon_kill(parent_id)
	else:
		SaveManager.add_weapon_kill(last_hit_by)


# --- XP gem spawning ---

func spawn_xp_gems(enemy_data: EnemyData, global_pos: Vector2, last_hit_by: String, was_crit: bool, burn_timer: float, pickup_mgr: Node) -> void:
	## Spawn XP gem(s) at enemy position, including synergy bonuses.
	_spawn_xp_gem(enemy_data, global_pos, pickup_mgr)

	# magnet_crit synergy: crit drops bonus gem worth +2
	if SynergyManager and SynergyManager.has_synergy("magnet_crit") and was_crit:
		_spawn_bonus_gem(2, global_pos, pickup_mgr)

	# firestaff_luckycoin synergy: burning kill +1 gem
	if SynergyManager and SynergyManager.has_synergy("firestaff_luckycoin"):
		if last_hit_by == "firestaff" and burn_timer > 0:
			_spawn_bonus_gem(1, global_pos, pickup_mgr)


func spawn_boss_gems(enemy_data: EnemyData, global_pos: Vector2, pickup_mgr: Node) -> void:
	## Spawn boss bonus gems (all modes).
	for i in range(BOSS_BONUS_GEM_COUNT):
		_spawn_xp_gem(enemy_data, global_pos, pickup_mgr)


func _spawn_xp_gem(enemy_data: EnemyData, global_pos: Vector2, pickup_mgr: Node) -> void:
	## Spawn a single XP gem at the given position.
	var gem_scene: PackedScene = preload("res://scenes/xp_gem.tscn")
	var gem: Area2D = gem_scene.instantiate()
	gem.global_position = global_pos + Vector2(randf_range(-XP_GEM_SPAWN_OFFSET, XP_GEM_SPAWN_OFFSET),
		randf_range(-XP_GEM_SPAWN_OFFSET, XP_GEM_SPAWN_OFFSET))
	gem.xp_value = enemy_data.xp_value
	if pickup_mgr:
		pickup_mgr.call_deferred("add_child", gem)


func _spawn_bonus_gem(value: int, global_pos: Vector2, pickup_mgr: Node) -> void:
	## Spawn a bonus XP gem with a specific value.
	var gem_scene: PackedScene = preload("res://scenes/xp_gem.tscn")
	var gem: Area2D = gem_scene.instantiate()
	gem.global_position = global_pos + Vector2(randf_range(-XP_GEM_BONUS_OFFSET, XP_GEM_BONUS_OFFSET),
		randf_range(-XP_GEM_BONUS_OFFSET, XP_GEM_BONUS_OFFSET))
	gem.xp_value = value
	if pickup_mgr:
		pickup_mgr.call_deferred("add_child", gem)


# --- Food spawning ---

func spawn_food_drop(enemy_data: EnemyData, global_pos: Vector2, parent: Node2D) -> void:
	## Potentially spawn food at enemy position based on drop chance.
	if randf() < FOOD_DROP_BASE_CHANCE * GameManager.get_difficulty_mul("food_drop_mul", 1.0):
		_spawn_food_at(global_pos + Vector2(randf_range(-FOOD_SPAWN_OFFSET, FOOD_SPAWN_OFFSET),
			randf_range(-FOOD_SPAWN_OFFSET, FOOD_SPAWN_OFFSET)), parent)


func _spawn_food_at(pos: Vector2, parent: Node2D) -> void:
	## Create and place a food pickup at the given position.
	var food: Area2D = Area2D.new()
	food.collision_mask = 1  # Player layer
	food.set_script(preload("res://scripts/food_pickup.gd"))
	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = FOOD_COLLISION_RADIUS
	shape.shape = circle
	food.add_child(shape)
	var sprite: Sprite2D = Sprite2D.new()
	var tex_path: String = "res://assets/sprites/pickups/food.png"
	if ResourceLoader.exists(tex_path):
		sprite.texture = load(tex_path)
	sprite.scale = FOOD_SPRITE_SCALE
	sprite.modulate = FOOD_MODULATE_COLOR
	food.add_child(sprite)
	food.global_position = pos
	parent.call_deferred("add_child", food)


# --- Item crate spawning ---

func spawn_crate_drop(enemy_data: EnemyData, global_pos: Vector2, pickup_mgr: Node) -> void:
	## Potentially spawn an item crate based on drop_chance.
	if randf() < enemy_data.drop_chance:
		_spawn_item_crate(global_pos, pickup_mgr)


func _spawn_item_crate(global_pos: Vector2, pickup_mgr: Node) -> void:
	## Create and place an item crate at the given position.
	var crate_scene: PackedScene = preload("res://scenes/item_crate.tscn")
	var crate: Area2D = crate_scene.instantiate()
	crate.global_position = global_pos
	if pickup_mgr:
		pickup_mgr.call_deferred("add_child", crate)


# --- Splitter child spawning ---

func spawn_split_children(enemy_data: EnemyData, global_pos: Vector2, parent: Node2D) -> void:
	## Spawn splitter child enemies at the parent's position.
	var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
	for i in range(enemy_data.split_count):
		var child_data: EnemyData = EnemyData.new()
		child_data.enemy_id = SPLITTER_CHILD_ID
		child_data.enemy_name = SPLITTER_CHILD_NAME
		child_data.max_hp = SPLITTER_CHILD_HP
		child_data.speed = SPLITTER_CHILD_SPEED
		child_data.damage = SPLITTER_CHILD_DAMAGE
		child_data.xp_value = SPLITTER_CHILD_XP
		child_data.color = SPLITTER_CHILD_COLOR
		child_data.size = SPLITTER_CHILD_SIZE
		child_data.is_child = true
		# Apply difficulty multipliers to children
		child_data.max_hp *= GameManager.get_difficulty_mul("enemy_hp_mul")
		child_data.speed *= GameManager.get_difficulty_mul("enemy_speed_mul")
		child_data.damage *= GameManager.get_difficulty_mul("enemy_dmg_mul")

		var child: CharacterBody2D = enemy_scene.instantiate()
		child.enemy_data = child_data
		var offset := Vector2(randf_range(-SPLITTER_CHILD_OFFSET, SPLITTER_CHILD_OFFSET),
			randf_range(-SPLITTER_CHILD_OFFSET, SPLITTER_CHILD_OFFSET))
		child.global_position = global_pos + offset
		parent.call_deferred("add_child", child)
		GameManager.enemy_count += 1


# --- Boss death handling ---

func handle_boss_death(enemy_data: EnemyData, global_pos: Vector2, parent: Node2D, pickup_mgr: Node) -> void:
	## Handle boss-specific death rewards.
	GameManager.boss_killed = true
	GameManager.boss_kill_count += 1

	# Boss bonus gems (all modes)
	spawn_boss_gems(enemy_data, global_pos, pickup_mgr)

	# Endless mode boss kill rewards
	if GameManager.selected_difficulty == "endless":
		_apply_endless_boss_reward(global_pos, parent)


func _apply_endless_boss_reward(global_pos: Vector2, parent: Node2D) -> void:
	## Apply endless mode specific boss kill rewards.
	GameManager.add_gold(ENDLESS_BOSS_GOLD)
	GameManager.add_xp(ENDLESS_BOSS_XP)
	spawn_endless_boss_food(global_pos, parent)
	GameManager.boss_kill_reward.emit(ENDLESS_BOSS_GOLD, int(ENDLESS_BOSS_XP))


func spawn_endless_boss_food(global_pos: Vector2, parent: Node2D) -> void:
	## Spawn food drops at random offsets for endless mode boss kill.
	for i in range(ENDLESS_FOOD_COUNT):
		var offset := Vector2(randf_range(-ENDLESS_FOOD_SPREAD, ENDLESS_FOOD_SPREAD),
			randf_range(-ENDLESS_FOOD_SPREAD, ENDLESS_FOOD_SPREAD))
		_spawn_food_at(global_pos + offset, parent)
