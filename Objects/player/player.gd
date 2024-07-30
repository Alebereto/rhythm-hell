class_name Player extends Node3D

signal paused

var height: float = 170

const _HANDS: Array[PackedScene] = [preload("res://objects/player/hands/puncher.tscn")]

@onready var right_controller: XRController3D = $RightController
@onready var left_controller: XRController3D = $LeftController

func _ready():
	right_controller.menu_button_pressed.connect(_on_pause)
	left_controller.menu_button_pressed.connect(_on_pause)

func _on_pause() -> void:
	paused.emit()

func set_right_hand( hand: int ):
	return right_controller.set_hand( _HANDS[hand] )

func set_left_hand( hand: int ):
	return left_controller.set_hand( _HANDS[hand] )
