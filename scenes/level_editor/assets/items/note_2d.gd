extends Node2D

const BAR_GAP: float = 64.0

var _note_info: Globals.NoteInfo


# Get refrences to note rects
@onready var note_rect: ColorRect = $NoteRect
@onready var start_rect: ColorRect = $StartRect
@onready var connector: ColorRect = $Connector


# Called when the node enters the scene tree for the first time.
func _ready():
	_note_info = Globals.NoteInfo.new()
	update_visuals()

func copy_other(note: Node2D) -> void:
	set_data(note.get_data())
	update_visuals()

func update_visuals() -> void:
	_set_colors(_note_info.color)
	_set_sizes(BAR_GAP)

func _set_colors(c: Color) -> void:
	# set note rect color
	note_rect.color = c
	# set start rect color
	start_rect.color = c

	# set connector color
	var connector_color = c
	connector_color.a = 0.5
	connector.color = connector_color

func _set_sizes(bar_gap: float) -> void:
	if _note_info.rotated: note_rect.rotation = deg_to_rad(45.0)
	else:				   note_rect.rotation = 0.0

	var start_pos = -(_note_info.delay) * bar_gap

	start_rect.position.x = start_pos
	connector.position.x = start_pos
	connector.size.x = -start_pos


func get_data() -> Globals.NoteInfo:
	return _note_info.clone()

func set_data(data: Globals.NoteInfo) -> void:
	_note_info = data
