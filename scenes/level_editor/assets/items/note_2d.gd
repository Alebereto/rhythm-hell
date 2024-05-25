extends Node2D

const BAR_GAP: float = 64.0

@export_category("Settings")
@export var note_name: String = "Note"
@export_range(0,10,0.1) var delay: float = 1
@export_range(0,10,1) var id: int = 0
@export var custom_data: Dictionary

@export_category("Customize")
@export var note_color: Color

# Get refrences to note rects
@onready var note_rect: ColorRect = $NoteRect
@onready var start_rect: ColorRect = $StartRect
@onready var connector: ColorRect = $Connector


# Called when the node enters the scene tree for the first time.
func _ready():
	set_colors(note_color)
	set_sizes(BAR_GAP)


func set_colors(c: Color) -> void:
	# set note rect color
	note_rect.color = c
	# set start rect color
	start_rect.color = c

	# set connector color
	var connector_color = c
	connector_color.a = 0.5
	connector.color = connector_color

func set_sizes(bar_gap: float) -> void:
	var start_pos = -delay * bar_gap

	start_rect.position.x = start_pos
	connector.position.x = start_pos
	connector.size.x = -start_pos
