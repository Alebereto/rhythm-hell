extends Node3D


@export var target: Node3D # Cannon target node

@export var projectiles_root: Node3D

@onready var anchor: Node3D = $Cylinder/ShootAnchor

# Source and target vectors of cannon fire
var source_pos: Vector3: get = _get_source_pos
var target_pos: Vector3: get = _get_target_pos

# Gravity parameters from settings
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity_vector: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector")


# getters for source and target vectors
func _get_source_pos(): return anchor.global_position
func _get_target_pos(): return target.global_position
	

## Get impulse vector for projectile given travel time and projectile mass
##
func _calculate_impulse(time: float, projectile: RigidBody3D) -> Vector3:

	# get position of projectile source
	var proj_pos = projectile.global_position

	var impulse: Vector3 = (target_pos - proj_pos) / time
	impulse.y += (0.5 * gravity * time)

	impulse /= projectile.mass

	return impulse

func _create_projectile(projectile_scene: String, start_pos: Vector3) -> RigidBody3D:
	# Instantiate projectile
	var projectile: RigidBody3D = load(projectile_scene).instantiate()
	# Set initial position
	projectile.global_position = start_pos
	# Add projectile to scene
	projectiles_root.add_child(projectile)

	return projectile

## Gets projectile scene path and time for projectile to reach its destination,
## instantiates projectile and fires it
##
func fire(projectile_scene: String, time: float) -> void:
	# Make projectile
	var projectile: RigidBody3D = _create_projectile(projectile_scene, source_pos)
	
	# Give impulse to projectile
	var impulse = _calculate_impulse(time, projectile)
	projectile.apply_impulse(impulse)
