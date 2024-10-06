class_name SliceObject extends AnimatableBody3D

const CREATE_TIME: float = 0.08
const WAIT_RATIO: float = 3.0/4.0
const SLICE_DURATION: float = 0.35
const SLICE_DISTANCE: float = 0.2

var _active: bool = false
func is_active() -> bool: return _active
var _time_active: float = 0

var _moving: bool = false
var _step: Vector3

var global_target_position: Vector3

var delay: float  # time that after creation the object must reach the target position
var right: bool	 # true if right hand needs to slice this
var color: Color = Color.WHITE  # color of object
var angle: float  # angle of slice

# Model
@onready var _model = $Model
@onready var _sliced_model = $SlicedModel
@onready var _upper_slice = $SlicedModel/UpSlice
@onready var _lower_slice = $SlicedModel/DownSlice

# Sounds
@onready var _spawn_sound: AudioStreamPlayer3D = $Sounds/SpawnSound
@onready var _slice_sound: AudioStreamPlayer3D = $Sounds/SliceSound
@onready var _slice_perfect_sound: AudioStreamPlayer3D = $Sounds/SliceSoundPerfect
@onready var _break_sound: AudioStreamPlayer3D = $Sounds/BreakSound

@onready var _break_effect: GPUParticles3D = $BreakEffect


# Called when the node enters the scene tree for the first time.
func _ready():
	_set_color()
	_spawn()

func _physics_process(delta):
	if _active: _time_active += delta
	if _moving: global_position += _step * delta

func _set_color():
	_model.get_active_material(0).albedo_color = color


func get_destination_difference() -> float:
	return abs(_time_active - delay)




func _spawn() -> void:
	_model.scale = Vector3(0.01, 0.01, 0.01)
	var wait_time: float = WAIT_RATIO * delay
	var travel_time: float = (1-WAIT_RATIO) * delay
	_step = (global_target_position - global_position) / travel_time

	var tween: Tween = create_tween()
	tween.tween_property(_model, "scale", Vector3(1,1,1), CREATE_TIME)
	tween.tween_callback(_spawn_sound.play)
	tween.tween_callback(_activate)
	tween.tween_callback(_launch).set_delay(wait_time)


func _activate(): _active = true

func _launch(): _moving = true



## Called when sliced
func on_slice(perfect: bool) -> void:
	_active = false
	# play sound
	if perfect: _slice_perfect_sound.play()
	else: 		_slice_sound.play()

	_step = _step * 0.05	# slow movement
	_sliced_model.rotate_z(angle)	# rotate sliced model to cut angle
	# switch to sliced model
	_model.visible = false
	_sliced_model.visible = true


	# Animate slice
	var tween: Tween = create_tween()
	
	tween.tween_property(			_upper_slice, "scale", Vector3(0.01, 0.01, 0.01), SLICE_DURATION) \
		 .set_trans(Tween.TRANS_EXPO) \
		 .set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(_upper_slice, "position:y", SLICE_DISTANCE, SLICE_DURATION) \
		 .set_trans(Tween.TRANS_EXPO) \
		 .set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(_lower_slice, "scale", Vector3(0.01, 0.01, 0.01), SLICE_DURATION) \
		 .set_trans(Tween.TRANS_EXPO) \
		 .set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(_lower_slice, "position:y", -SLICE_DISTANCE, SLICE_DURATION) \
		 .set_trans(Tween.TRANS_EXPO) \
		 .set_ease(Tween.EASE_OUT)

	# Delete self after animation
	tween.tween_callback(queue_free)


## Called when sliced too shallow, late or early,
## or when sliced with wrong sword
func on_break():
	_active = false
	# play sound
	_break_sound.play()

	_step = _step * 0.05	# slow movement
	_model.visible = false

	_break_effect.finished.connect(queue_free)
	_break_effect.emitting = true
