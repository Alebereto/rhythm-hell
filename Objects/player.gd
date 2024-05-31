class_name Player extends Node3D


signal trigger_pressed
signal right_hand_entered_body(body)



func _on_right_hand_body_entered(body):
	right_hand_entered_body.emit(body)


func _on_right_controller_button_pressed(button_name):
	if button_name == "trigger_click": trigger_pressed.emit()
