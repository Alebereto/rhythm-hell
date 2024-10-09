class_name Event2D extends Item2D

var bar_gap: float:
	set(value):
		bar_gap = value
		if is_node_ready(): _set_sizes()
const CONNECTOR_TRANSPARACY: float = 0.5

var _event_info: Globals.EventInfo
func get_info() -> Globals.EventInfo:  return _event_info

# Get refrences to event rects
@onready var _event_polygon: Polygon2D = $EventPolygon
@onready var _start_polygon: Polygon2D = $StartPolygon
@onready var _connector: Line2D = $Connector

@onready var _area: Area2D = $Area2D



# Called when the node enters the scene tree for the first time.
func _ready():
	_event_info = Globals.EventInfo.new()
	_update_visuals()


func copy_other(event: Item2D) -> void:
	if not event is Event2D: return
	set_data_from(event.get_info())


## copies data from event_info
func set_data_from(event_info: Globals.EventInfo) -> void:
	_event_info = Globals.EventInfo.new(event_info)
	_update_visuals()


func on_placed() -> void:
	_area.collision_layer = 1 # make event selectable


# set visuals functions

func _update_visuals() -> void:
	_set_colors(_event_info.color)
	_set_sizes()

func _set_colors(c: Color) -> void:
	# set polygon colors
	_event_polygon.color = c
	_start_polygon.color = c

	# set connector color
	var connector_color = c
	connector_color.a = CONNECTOR_TRANSPARACY
	_connector.default_color = connector_color

func _set_sizes() -> void:
	var start_pos = -(_event_info.delay) * bar_gap
	_start_polygon.position.x = start_pos
	_connector.points[0].x = start_pos
