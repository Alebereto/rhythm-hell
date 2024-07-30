extends Node3D

@onready var _rod: MeshInstance3D = $Model/Rod

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_color(color: Color) -> void:
	_rod.get_active_material(0).albedo_color = color
