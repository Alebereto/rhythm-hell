class_name Projectile extends RigidBody3D

var active: bool = true

@export_enum("Rock", "Barrel") var id: int = -1
var destination_beat: float = -1


func on_hit() -> void:
	active = false

func on_touch() -> void:
	active = false
	bump()

func launch_forwards() -> void:
	linear_velocity = Vector3(0,0,0)	# stop projectile
	apply_impulse(Vector3(0,1,-10))		# launch forwards

func bump() -> void:
	var impulse = linear_velocity * -0.2 + Vector3(0,1,0)
	apply_impulse(impulse)
