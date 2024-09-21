extends Projectile

@export var contained_projectile: PackedScene

@onready var _break_effect: GPUParticles3D = $BreakEffect
@onready var _break_sound: AudioStreamPlayer3D = $BreakSound
@onready var _model: Node3D = $Model


func on_hit() -> void:
	super()

	linear_velocity = Vector3(0,0,0)	# stop projectile
	$CollisionShape3D.process_mode = Node.PROCESS_MODE_DISABLED
	_break_sound.play()
	_break_effect.emitting = true
	_model.visible = false
