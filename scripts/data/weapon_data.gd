class_name WeaponData
extends Resource

@export var weapon_name: String = "Weapon"
@export var weapon_id: String = ""
@export var damage: float = 10.0
@export var cooldown: float = 1.5
@export var projectile_speed: float = 300.0
@export var projectile_count: int = 1
@export var projectile_pierce: int = 0
@export var projectile_range: float = 500.0
@export var description: String = ""
@export var color: Color = Color.WHITE
@export var projectile_size: float = 8.0

# Weapon types: "projectile", "orbit", "lightning", "aoe", "cone", "aura", "boomerang"
@export var weapon_type: String = "projectile"

# Orbit (holywater, bible)
@export var orbit_count: int = 1
@export var orbit_radius: float = 50.0
@export var orbit_speed: float = 3.0

# Lightning
@export var chain_count: int = 0

# AoE / Aura
@export var aoe_radius: float = 80.0

# Cone (firestaff)
@export var cone_angle: float = 80.0
@export var cone_range: float = 100.0
@export var burn_dps: float = 0.0
@export var burn_duration: float = 0.0

# Aura (frostaura)
@export var slow_pct: float = 0.0
@export var freeze_pct: float = 0.0

# Boomerang
@export var boomerang_max_dist: float = 250.0
@export var boomerang_return_speed: float = 320.0
@export var boomerang_curvature: float = 0.3
@export var boomerang_track_angle: float = 0.52
