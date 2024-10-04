extends Projectile


@onready var _poof_effect: GPUParticles3D = $Effects/PoofEffect
# Sounds
@onready var _hit_sound: AudioStreamPlayer3D = $Sounds/HitSound
@onready var _hit_perfect_sound: AudioStreamPlayer3D = $Sounds/HitPerfectSound
@onready var _miss_sound: AudioStreamPlayer3D = $Sounds/MissSound


func _ready():
	id = Globals.PROJECTILES.ROCK
	super()


## Called by karate_game when hit
func on_hit(late: bool, perfect: bool) -> void:
	super(late, perfect)

	launch_forwards(perfect, late)
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
	$Model.visible = false
	_poof_effect.finished.connect(queue_free)
	_poof_effect.emitting = true
