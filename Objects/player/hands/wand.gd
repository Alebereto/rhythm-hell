extends Node3D

# Max length that the laser and ray cast gets to
@export_range(0,32) var max_laser_length: float = 16

var _using_laser = false
var using_laser: bool:
	get: return _using_laser

# Wand rod mesh
@onready var _rod: MeshInstance3D = $Model/Rod

# Ray cast of the laser
@onready var _laser: RayCast3D = $Laser
# Beam mesh of the laser
@onready var _beam: MeshInstance3D = $Laser/Beam
# Circle at the end of the laser
@onready var _select_indicator: MeshInstance3D = $Laser/SelectIndicator

# True if user is holding the menu click button
var _clicking: bool:
	get: return get_parent().clicking

# Called when the node enters the scene tree for the first time.
func _ready():
	_laser.target_position.y = max_laser_length	# set ray length

func _process(_delta):
	
	if _using_laser:
		if _laser.is_colliding():
			# Update laser length
			var cast_point = _laser.get_collision_point()
			var d = _laser.global_position.distance_to(cast_point)
			_set_laser_length(d)

			# check if colliding with vr ui
			var collider = _laser.get_collider()
			if collider is VRUI:
				collider.on_ray_movement(cast_point, _clicking)
		else:
			_set_laser_length(max_laser_length)


func _set_laser_length(l: float) -> void:
	var h = min(l, max_laser_length)
	_beam.mesh.height = h
	_beam.position.y = h/2
	_select_indicator.position.y = h

func set_color(color: Color) -> void:
	_rod.get_active_material(0).albedo_color = color


## Gets called by hand controller when clicking or releasing menu click button
func on_button(press: bool) -> void:
	if _using_laser:
		var collider = _laser.get_collider()
		if collider is VRUI:
			var cast_point = _laser.get_collision_point()
			collider.on_ray_button(cast_point, press)


func laser_on():
	_laser.process_mode = Node.PROCESS_MODE_INHERIT
	_laser.visible = true
	_using_laser = true

func laser_off():
	_using_laser = false
	_laser.visible = false
	_laser.process_mode = Node.PROCESS_MODE_DISABLED
