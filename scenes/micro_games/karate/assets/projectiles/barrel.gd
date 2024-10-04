extends Projectile

@export var contained_projectile: PackedScene

@onready var _break_effect: GPUParticles3D = $Effects/BreakEffect
@onready var _model: Node3D = $Model

@onready var _poof_effect: GPUParticles3D = $Effects/PoofEffect
# Sounds
@onready var _hit_sound: AudioStreamPlayer3D = $Sounds/BreakSound
@onready var _hit_perfect_sound: AudioStreamPlayer3D = $Sounds/BreakPerfectSound
@onready var _miss_sound: AudioStreamPlayer3D = $Sounds/MissSound


func _ready():
	id = Globals.PROJECTILES.BARREL
	super()


## Called by karate_game when hit
func on_hit(late: bool, perfect: bool) -> void:
	super(late, perfect)

	linear_velocity = Vector3(0,0,0)	# stop projectile
	collision_layer = 0
	collision_mask = 0

	_break_effect.emitting = true
	_model.visible = false

	if late:
		_miss_sound.play()
	else:
		if perfect: _hit_perfect_sound.play()
		else: _hit_sound.play()

func on_touch():
	super()
	_miss_sound.play()

## Called by karate_game when projectile should be destroyed
func poof():
	_model.visible = false
	_poof_effect.finished.connect(queue_free)
	_poof_effect.emitting = true
