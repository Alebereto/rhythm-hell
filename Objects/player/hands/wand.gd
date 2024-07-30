extends Node3D

@export_color_no_alpha var color: Color = Color.BLUE

@onready var _rod: MeshInstance3D = $Model/Rod

# Called when the node enters the scene tree for the first time.
func _ready():
	_rod.get_active_material(0).albedo_color = color
