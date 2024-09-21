extends Node3D


signal vibrate


# Max length that the laser and ray cast gets to
@export_range(0,32) var max_laser_length: float = 16


# True if wand is emitting laser
var _using_laser = false
var using_laser: bool:
	get: return _using_laser

# Refrence to vr menu that wand is pointing at
var _focused_menu = null

# True if user is holding the menu click button
var _clicking: bool:
	get: return get_parent().clicking



# Ray cast of the laser
@onready var _laser: RayCast3D = $Laser
# Beam mesh of the laser
@onready var _beam: MeshInstance3D = $Laser/Beam
# Circle at the end of the laser
@onready var _select_indicator: MeshInstance3D = $Laser/SelectIndicator




# Called when the node enters the scene tree for the first time.
func _ready():
	_laser.target_position.y = max_laser_length	# set ray length

func _process(_delta):
	if _using_laser: _handle_laser()
		


func _handle_laser():
	# update colliding object
	var collider = _laser.get_collider()
	if collider != _focused_menu:
		# entering menu
		if collider is VRUI and _focused_menu == null: _focus(collider)
		# leaving menu
		if collider == null and _focused_menu is VRUI: unfocus()

	# Update laser length and handle pointing at vr menu
	if _laser.is_colliding():
		# Update laser length
		var cast_point = _laser.get_collision_point()
		var d = _laser.global_position.distance_to(cast_point)
		_set_laser_length(d)

		if _focused_menu is VRUI:
			_focused_menu.on_ray_movement(cast_point, _clicking)
	else:
		_set_laser_length(max_laser_length)


func _set_laser_length(l: float) -> void:
	var h = min(l, max_laser_length)
	_beam.mesh.height = h
	_beam.position.y = h/2
	_select_indicator.position.y = h

## called by vr menus when hovering over set items
func _on_hover_item() -> void:
	vibrate.emit()


## Called when focusing on a menu
func _focus(menu: VRUI) -> void:
	# connect hover signal
	menu.hovered.connect(_on_hover_item)

	_focused_menu = menu



## Called when unfocusing from a menu
func unfocus() -> void:
	if _focused_menu is VRUI:
		_focused_menu.on_ray_leave()
		# disconnect hover signal
		if _focused_menu.hovered.is_connected(_on_hover_item): _focused_menu.hovered.disconnect(_on_hover_item)

	_focused_menu = null


func set_color(color: Color) -> void:
	$Model/Rod.get_active_material(0).albedo_color = color

## Gets called by hand controller when clicking or releasing menu click button
func on_button(press: bool) -> void:
	if _using_laser:
		var collider = _laser.get_collider()
		if collider is VRUI:
			var cast_point = _laser.get_collision_point()
			collider.on_ray_button(cast_point, press)


## turns laser on
func laser_on():
	_laser.process_mode = Node.PROCESS_MODE_INHERIT
	_laser.visible = true
	_using_laser = true

## turns laser off
func laser_off():
	_using_laser = false
	unfocus()
	_laser.visible = false
	_laser.process_mode = Node.PROCESS_MODE_DISABLED
