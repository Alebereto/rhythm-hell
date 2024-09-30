extends Node3D

signal mole_bonked( mole: Mole )

var color: Color = Color.WHITE

# Called when the node enters the scene tree for the first time.
func _ready():
	_set_color()


func _set_color():
	$Model/Blunt.get_active_material(0).albedo_color = color


func _is_bonking_speed() -> bool:
	return true

# Inputs ======================

func _on_body_entered(_body):
	pass
