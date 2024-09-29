extends Projectile


@onready var _hit_sound: AudioStreamPlayer3D = $HitSound

func _ready():
	super()

func _physics_process(delta):
	super(delta)

func on_hit(late: bool, perfect: bool) -> void:
	super(late, perfect)
	# TODO: play different sound when perfect
	if not late:
		_hit_sound.play()
		launch_forwards()


func poof():
	$Model.visible = false
	$PoofEffect.finished.connect(queue_free)
	$PoofEffect.emitting = true
