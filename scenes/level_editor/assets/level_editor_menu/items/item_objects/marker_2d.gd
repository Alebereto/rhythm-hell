class_name Mark2D extends Item2D


var _marker_info: Globals.MarkerInfo
func get_info() -> Globals.MarkerInfo:  return _marker_info

# Get refrences to marker rects
@onready var _marker_polygon: Polygon2D = $MarkerPolygon

@onready var _area: Area2D = $Area2D



# Called when the node enters the scene tree for the first time.
func _ready():
	_marker_info = Globals.MarkerInfo.new()
	_update_visuals()


func copy_other(marker: Item2D) -> void:
	if not marker is Mark2D: return
	set_data_from(marker.get_info())


## copies data from marker_info
func set_data_from(marker_info: Globals.MarkerInfo) -> void:
	_marker_info = Globals.MarkerInfo.new(marker_info)
	_update_visuals()


func on_placed() -> void:
	_area.collision_layer = 1 # make marker selectable


# set visuals functions

func _update_visuals() -> void:
	_set_colors(_marker_info.color)

func _set_colors(c: Color) -> void:
	# set polygon color
	_marker_polygon.color = c