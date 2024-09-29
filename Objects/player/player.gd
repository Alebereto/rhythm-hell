class_name Player extends Node3D

signal paused

var height: float = 170

# TODO: load and not preload???
const _HANDS: Array[PackedScene] = [preload("res://objects/player/hands/puncher.tscn"),
									preload("res://objects/player/hands/hammer.tscn")]


# Controllers
@onready var right_controller: XRController3D = $RightController
@onready var left_controller: XRController3D = $LeftController


# Used for fading
@onready var _fade_wall: MeshInstance3D = $XRCamera3D/FadeWall
const FADE_DURATION: float = 1.0



func _ready():
	right_controller.menu_button_pressed.connect(_on_pause)
	left_controller.menu_button_pressed.connect(_on_pause)

	right_controller.wand.laser_on()



func set_right_hand( hand: int ):
	return right_controller.set_hand( _HANDS[hand] )

func set_left_hand( hand: int ):
	return left_controller.set_hand( _HANDS[hand] )


func set_wands_state(state: bool):
	right_controller.set_wand_state(state)
	left_controller.set_wand_state(state)


func stop_inputs() -> void:
	right_controller.stop_inputs()
	left_controller.stop_inputs()


## Fade out then call method
func fade_out(delay: float = 0.0, method = null) -> void:
	var tween = create_tween()
	tween.tween_property(_fade_wall.get_active_material(0), "albedo_color", Color.BLACK, FADE_DURATION).from(Color(0,0,0,0)).set_delay(delay)
	if method is Callable:
		tween.tween_callback(method)

## Fade in then call method
func fade_in(delay: float = 0.0, method = null) -> void:
	var tween = create_tween()
	tween.tween_property(_fade_wall.get_active_material(0), "albedo_color", Color(0,0,0,0), FADE_DURATION).from(Color.BLACK).set_delay(delay)
	if method is Callable:
		tween.tween_callback(method)


# Inputs ===========================================

func _on_pause() -> void:
	paused.emit()

func _on_right_trigger_pressed() -> void:

	if not right_controller.wand.using_laser:
		left_controller.wand.laser_off()
		right_controller.wand.laser_on()

func _on_left_trigger_pressed() -> void:

	if not left_controller.wand.using_laser:
		right_controller.wand.laser_off()
		left_controller.wand.laser_on()
