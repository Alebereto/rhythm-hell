extends MarginContainer

signal new_level_requested
signal load_level_requested


# Input signals ======================

func _on_new_level_button_pressed():
	new_level_requested.emit()


func _on_load_level_button_pressed():
	load_level_requested.emit()
