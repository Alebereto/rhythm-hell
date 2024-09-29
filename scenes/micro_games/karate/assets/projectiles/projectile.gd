class_name Projectile extends RigidBody3D

var active: bool = false

@export_enum("Rock", "Barrel") var id: int = -1
var travel_time: float = 0
var time_active: float = 0

func _ready():
	active = true

func _physics_process(delta):
	if active: time_active += delta



func get_destination_difference() -> float:
	return abs(travel_time - time_active)

## Called when projectile is hit, late is true when hit too late
func on_hit(_late: bool, _perfect: bool) -> void:
	active = false

func on_touch() -> void:
	active = false
	bump()


# moving functions ========

func launch_forwards() -> void:
	linear_velocity = Vector3(0,0,0)	# stop projectile
	apply_impulse(Vector3(0,1,-10))		# launch forwards

func bump() -> void:
	var y_impulse = linear_velocity.y * -1
	var impulse = linear_velocity * -0.5 + Vector3(0,y_impulse,0)
	apply_impulse(impulse)
