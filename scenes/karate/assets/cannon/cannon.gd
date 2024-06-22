extends Node3D


@export var _target: Node3D # Cannon target node

@onready var _anchor: Node3D = $Cylinder/ShootAnchor

# Source and _target vectors of cannon fire
var _source_pos: Vector3: get = _get_source_pos
var _target_pos: Vector3: get = _get_target_pos

# Gravity parameters from settings
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _gravity_vector: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector")


# getters for source and _target vectors
func _get_source_pos(): return _anchor.global_position
func _get_target_pos(): return _target.global_position
	

## Get impulse vector for given projectile for reaching _source_pos
## in given travel time
func _calculate_impulse(projectile: Projectile, travel_time: float) -> Vector3:

	# get position of projectile source
	var proj_pos = projectile.global_position

	var impulse: Vector3 = (_target_pos - proj_pos) / travel_time
	impulse -= _gravity_vector * _gravity * 0.5 * travel_time

	impulse /= projectile.mass

	return impulse


## Gets instantiated projectile and time for projectile to reach its destination,
## fires projectile
##
func fire(projectile: Projectile, travel_time: float) -> void:
	projectile.global_position = _source_pos
	
	# Give impulse to projectile
	var impulse = _calculate_impulse(projectile, travel_time)
	projectile.apply_impulse(impulse)
