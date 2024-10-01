extends Mole

const UP_TIME = 0.12
const LOWER_TIME = 0.04
const RISE_TIME = 0.05

# Called when the node enters the scene tree for the first time.
func _ready():
	_bonk_sound = $BonkSound
	_bonk_perfect_sound = $BonkPerfectSound

func rise(time: float):
	# animate
	var jumps_tween = create_tween()
	jumps_tween.tween_property(self, "position:y", creep_height, CREATE_TIME)
	jumps_tween.tween_callback(_play_creep_sound)
	jumps_tween.tween_callback(_jump.bind(time, HIDDEN_HEIGHT, peak_height))

	# hide and destroy mole
	jumps_tween.tween_property(self, "position:y", HIDDEN_HEIGHT, CREATE_TIME).set_delay(time+LOWER_TIME+UP_TIME)
	jumps_tween.tween_callback(queue_free).set_delay(CREATE_TIME)

func _jump(time: float, end_height: float, top_height: float):
	_activate()
	set_arrival_time(time)
	_active_tween = create_tween()
	_active_tween.tween_callback(_play_rise_sound).set_delay(time - RISE_TIME)
	_active_tween.tween_property(self, "position:y", top_height, RISE_TIME)
	_active_tween.tween_property(self, "position:y", end_height, LOWER_TIME).set_delay(UP_TIME)

func on_bonk(perfect: bool) -> void:
	super(perfect)
	if _active_tween.is_valid() and _active_tween.is_running():
		_active_tween.kill()
	_active_tween = create_tween()
	_active_tween.tween_property(self, "position:y", creep_height, LOWER_TIME)

func on_tap():
	super()
	if _active_tween.is_valid() and _active_tween.is_running():
		_active_tween.kill()
	_active_tween = create_tween()
	_active_tween.tween_property(self, "position:y", creep_height, LOWER_TIME)
