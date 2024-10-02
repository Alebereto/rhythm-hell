class_name Mole extends Node3D

signal bonk_effect(global_position: Vector3, perfect: bool)
signal creeped
signal risen

const CREATE_TIME = 0.1
const HEAD_HEIGHT = 0.2

var bonk_time = 0.03

const HIDDEN_HEIGHT = -1.0
var creep_height: float = 0
var peak_height: float = 1

# sounds
var creep_sound: AudioStreamPlayer3D
var rise_sound: AudioStreamPlayer3D


func is_active() -> bool: return _active

var _active = false
var _active_tween: Tween
var _rise_played: bool = false

# for measuring if player hit on time
var _arrival_time = 0
var _active_time = 0	# time since started = true


# Called when the node enters the scene tree for the first time.
func _ready(): pass


func _physics_process(delta):
	if _active: _active_time += delta

func get_destination_difference() -> float:
	return abs(_arrival_time - _active_time)


func rise(_time: float) -> void: pass
	



func _activate():
	_active_time = 0
	_active = true

func _deactivate():
	_active = false
	

func set_arrival_time(time: float): _arrival_time = time



func _jump(time: float, end_height: float, top_height: float, rise_time: float, up_time: float, lower_time: float):
	_activate()
	set_arrival_time(time)
	_rise_played = false
	_active_tween = create_tween()
	_active_tween.tween_property(self, "position:y", top_height, rise_time).set_delay(time - rise_time)
	_active_tween.tween_callback(_play_rise_sound)
	_active_tween.tween_property(self, "position:y", end_height, lower_time).set_delay(up_time)


func on_bonk(perfect: bool) -> void:
	_deactivate()
	if not _rise_played: rise_sound.play()
	bonk_effect.emit(global_position, perfect)

	_return_to_creep()

func on_tap() -> void:
	_deactivate()
	_return_to_creep()


func _return_to_creep() -> void:
	if _active_tween.is_valid() and _active_tween.is_running():
		_active_tween.kill()
	_active_tween = create_tween()
	_active_tween.tween_property(self, "position:y", creep_height, bonk_time)


func _play_rise_sound() -> void:
	rise_sound.play()
	_rise_played = true
