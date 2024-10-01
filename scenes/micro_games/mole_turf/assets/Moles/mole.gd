class_name Mole extends Node3D

signal bonk_effect(global_position: Vector3, perfect: bool)
signal creeped
signal risen

const CREATE_TIME = 0.1
const HEAD_HEIGHT = 0.2

const HIDDEN_HEIGHT = -1.0
var creep_height: float = 0
var peak_height: float = 1

var _bonk_sound: AudioStreamPlayer3D
var _bonk_perfect_sound: AudioStreamPlayer3D


func is_active() -> bool: return _active

var _active = false
var _active_tween: Tween

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

func on_bonk(perfect: bool) -> void:
	_deactivate()
	if perfect: _bonk_perfect_sound.play()
	else: _bonk_sound.play()
	bonk_effect.emit(global_position, perfect)

func on_tap() -> void:
	_deactivate()

func _activate():
	_active_time = 0
	_active = true

func _deactivate():
	_active = false
	

func set_arrival_time(time: float): _arrival_time = time


func _play_creep_sound() -> void:
	creeped.emit()

func _play_rise_sound() -> void:
	risen.emit()
