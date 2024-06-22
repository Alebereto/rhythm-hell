class_name Player extends Node3D


signal right_trigger_pressed
signal menu_button_pressed
signal right_hand_entered_body(body)



func _on_right_hand_body_entered(body):
	right_hand_entered_body.emit(body)


func _on_right_controller_button_pressed(button_name):
	match button_name:
		"trigger_click": right_trigger_pressed.emit()
		"menu_button":	 menu_button_pressed.emit()

