extends Node2D

const BAR_GAP: float = 64.0

var _note_info: Globals.NoteInfo


# Get refrences to note rects
@onready var _note_rect: ColorRect = $NoteRect
@onready var _start_rect: ColorRect = $StartRect
@onready var _connector: ColorRect = $Connector

@onready var _area: Area2D = $Area2D



# Called when the node enters the scene tree for the first time.
func _ready():
	_note_info = Globals.NoteInfo.new()
	_update_visuals()

func copy_other(note: Node2D) -> void:
	set_data_from(note.get_data())
	_update_visuals()



func get_data() -> Globals.NoteInfo:
	return _note_info

## Gets either note info or note dictionary
func set_data_from(data) -> void:
	_note_info = Globals.NoteInfo.new(data)
	_update_visuals()


func on_placed() -> void:
	_set_pickable()

func _set_pickable() -> void:
	_area.collision_layer = 1


# set visuals functions

func _update_visuals() -> void:
	_set_colors(_note_info.color)
	_set_sizes(BAR_GAP)

func _set_colors(c: Color) -> void:
	# set note rect color
	_note_rect.color = c
	# set start rect color
	_start_rect.color = c

	# set _connector color
	var connector_color = c
	connector_color.a = 0.5
	_connector.color = connector_color

func _set_sizes(bar_gap: float) -> void:
	if _note_info.rotated: _note_rect.rotation = deg_to_rad(45.0)
	else:				   _note_rect.rotation = 0.0

	var start_pos = -(_note_info.delay) * bar_gap

	_start_rect.position.x = start_pos
	_connector.position.x = start_pos
	_connector.size.x = -start_pos
