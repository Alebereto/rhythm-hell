class_name Note2D extends Item2D

var bar_gap: float:
	set(value):
		bar_gap = value
		if is_node_ready(): _set_sizes()
const CONNECTOR_TRANSPARACY: float = 0.5

var _note_info: Globals.NoteInfo
func get_info() -> Globals.NoteInfo:  return _note_info

# Get refrences to note rects
@onready var _note_polygon: Polygon2D = $NotePolygon
@onready var _start_polygon: Polygon2D = $StartPolygon
@onready var _connector: Line2D = $Connector

@onready var _area: Area2D = $Area2D



# Called when the node enters the scene tree for the first time.
func _ready():
	_note_info = Globals.NoteInfo.new()
	_update_visuals()


func copy_other(note: Item2D) -> void:
	if not note is Note2D: return
	set_data_from(note.get_info())


## copies data from note_info
func set_data_from(note_info: Globals.NoteInfo) -> void:
	_note_info = Globals.NoteInfo.new(note_info)
	_update_visuals()


func on_placed() -> void:
	_area.collision_layer = 1  # make note selectable

# set visuals functions

func _update_visuals() -> void:
	_set_colors(_note_info.color)
	_set_sizes()

func _set_colors(c: Color) -> void:
	# set polygon colors
	_note_polygon.color = c
	_start_polygon.color = c

	# set connector color
	var connector_color = c
	connector_color.a = CONNECTOR_TRANSPARACY
	_connector.default_color = connector_color

func _set_sizes() -> void:
	if _note_info.rotated: _note_polygon.rotation = deg_to_rad(45.0)
	else:				   _note_polygon.rotation = 0.0

	var start_pos = -(_note_info.delay) * bar_gap
	_start_polygon.position.x = start_pos
	_connector.points[0].x = start_pos
