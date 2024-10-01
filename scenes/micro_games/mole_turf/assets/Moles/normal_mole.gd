extends Mole

const UP_TIME = 0.12
const LOWER_TIME = 0.04
const RISE_TIME = 0.05


# Called when the node enters the scene tree for the first time.
func _ready():
	creep_sound = $CreepSound
	rise_sound = $RiseSound

func rise(time: float):
	# animate
	var jumps_tween = create_tween()
	jumps_tween.tween_property(self, "position:y", creep_height, CREATE_TIME)
	jumps_tween.tween_callback(creep_sound.play)
	jumps_tween.tween_callback(_jump.bind(time, HIDDEN_HEIGHT, peak_height, RISE_TIME, UP_TIME, LOWER_TIME))

	# hide and destroy mole
	jumps_tween.tween_property(self, "position:y", HIDDEN_HEIGHT, CREATE_TIME).set_delay(time+LOWER_TIME+UP_TIME)
	jumps_tween.tween_callback(queue_free).set_delay(CREATE_TIME)
