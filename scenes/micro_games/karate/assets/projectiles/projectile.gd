class_name Projectile extends RigidBody3D

const FORWARDS = Vector3(0,0,-1)

var active: bool = false

var id: Globals.PROJECTILES
var travel_time: float = 0
var time_active: float = 0


func _ready():
	active = true

func _physics_process(delta):
	if active: time_active += delta



func get_destination_difference() -> float:
	return abs(travel_time - time_active)

## Called by karate_game when hit
func on_hit(_late: bool, _perfect: bool) -> void:
	active = false

func on_touch() -> void:
	active = false
	bump()


## Called by karate_game when projectile should be destroyed
func poof() -> void:
	queue_free()


# moving functions ========

func launch_forwards(perfect: bool, late = false) -> void:
	var force = -18 if perfect else -10
	if late: force = -6

	linear_velocity = Vector3(0,0,0)	# stop projectile
	apply_impulse(Vector3(0,1,force))	# launch forwards

func bump() -> void:
	var y_impulse = linear_velocity.y * -1
	var impulse = linear_velocity * -0.5 + Vector3(0,y_impulse,0)
	apply_impulse(impulse)

