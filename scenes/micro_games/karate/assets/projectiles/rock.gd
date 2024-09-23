extends Projectile


@onready var _hit_sound: AudioStreamPlayer3D = $HitSound

func on_hit() -> void:
	super()
	_hit_sound.play()
	launch_forwards()
