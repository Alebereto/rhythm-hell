extends Node3D

const CANNON_DELAY: float = 0.3
const SHOOT_ANIMATION_NAME: String = "cannon_shoot"


@export var _target: Node3D # Cannon target node
@export var _projectile_root: Node3D

@onready var _anchor: Node3D = $ShootAnchor
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _poof_effect: GPUParticles3D = $PoofEffect
@onready var _shoot_sound: AudioStreamPlayer3D = $ShootSound
@onready var _projectile_timers_root: Node = $ProjectileTimers

# Source and _target vectors of cannon fire
var _source_pos: Vector3: get = _get_source_pos
var _target_pos: Vector3: get = _get_target_pos

# Gravity parameters from settings
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _gravity_vector: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector")


# getters for source and _target vectors
func _get_source_pos(): return _anchor.global_position
func _get_target_pos(): return _target.global_position


func _play_shoot_animation():
	if _animation_player.is_playing(): _animation_player.stop()
	_animation_player.play(SHOOT_ANIMATION_NAME)


## Gets instantiated projectile and time for projectile to reach its destination,
## fires projectile
##
func fire(projectile: Projectile, travel_time: float) -> void:
	_play_shoot_animation()
	_add_projectile_to_queue(projectile, travel_time)

	

## Get impulse vector for given projectile for reaching _source_pos
## in given travel time
func _calculate_impulse(projectile: Projectile, travel_time: float) -> Vector3:

	# get position of projectile source
	var proj_pos = projectile.global_position

	var impulse: Vector3 = (_target_pos - proj_pos) / travel_time
	impulse -= _gravity_vector * _gravity * 0.5 * travel_time

	impulse /= projectile.mass

	return impulse


func launch(projectile: Projectile, travel_time: float) -> void:
	# Set projectile initial position and add to scene
	_projectile_root.add_child(projectile)
	if not projectile.is_node_ready(): await projectile.ready

	projectile.global_position = _source_pos
	
	# Compute impulse for projectile
	var impulse = _calculate_impulse(projectile, travel_time)
	var torque = Vector3(1,2,2)	# TODO: make random vector

	# Add poof effect
	_poof_effect.emitting = true
	# play shoot sound
	_shoot_sound.play()
	
	# Give impulses to projectile
	projectile.apply_impulse(impulse)
	projectile.apply_torque_impulse(torque)



func _add_projectile_to_queue( projectile: Projectile, travel_time: float ) -> void:

	# make timer
	var timer = Timer.new()
	timer.timeout.connect( launch.bind(projectile, travel_time) )
	timer.timeout.connect( (func(node): node.queue_free()).bind(timer) )
	timer.autostart = true
	timer.one_shot = true
	timer.wait_time = CANNON_DELAY
	_projectile_timers_root.add_child( timer )


func clear_projectile_queue() -> void:
	for timer in _projectile_timers_root.get_children():
		timer.queue_free()

