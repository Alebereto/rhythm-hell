extends Control

signal custom_levels_pressed
signal exit_pressed
signal hovered


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Inputs ==============================

func _on_hover():
	hovered.emit()


func _on_custom_levels_button_pressed():
	custom_levels_pressed.emit()


func _on_exit_button_pressed():
	exit_pressed.emit()
