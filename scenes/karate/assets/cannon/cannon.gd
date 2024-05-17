extends Node3D

@export var target: Node3D

@onready var anchor: Node3D = $Cylinder/ShootAnchor
@onready var projectiles_root: Node3D = $Projectiles

var source_pos: Vector3: get = _get_source_pos
var target_pos: Vector3: get = _get_target_pos

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity_vector: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector")

func _get_source_pos(): return anchor.position
func _get_target_pos(): return target.position

# get 
func _calculate_impulse(time: float, mass: float) -> Vector3:
	var delta_pos = target_pos - source_pos
	return Vector3(1,1,1) * time

func shoot(projectile_scene: String, time: float) -> void:
	var projectile: RigidBody3D = load(projectile_scene).instantiate()
	projectile.position = anchor.position
	projectiles_root.add_child(projectile)
	
	var impulse = _calculate_impulse(time, projectile.mass)
	projectile.apply_impulse(impulse)
	# ==== maybe add as child???


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
