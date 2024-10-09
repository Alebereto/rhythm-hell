extends Node2D

# Size values for timeline (TODO: set to fit control instead of constants)
const INITIAL_BAR_GAP: float = 64.0
const BAR_WIDTH: float = 2.0
const BARS_OFFSET: float = 20.0
const BAR_HEIGHT: float = 290.0
const BARS: int = 4

const LAYERS: int = 5
var layer_gap: float:
	get: return (BAR_HEIGHT / (LAYERS+1))

const MARKER_Y: float = 0.0


# Item scenes
const NOTE_SCENE: PackedScene = preload("res://scenes/level_editor/assets/level_editor_menu/items/item_objects/note_2d.tscn")
const EVENT_SCENE: PackedScene = preload("res://scenes/level_editor/assets/level_editor_menu/items/item_objects/event_2d.tscn")
const MARKER_SCENE: PackedScene = preload("res://scenes/level_editor/assets/level_editor_menu/items/item_objects/marker_2d.tscn")



@export_category("Customize")
@export var _bar_color: Color
@export var _beat_color: Color
@export var _layer_color: Color


# Get TimeLine part refrences
@onready var _anchor: Node2D = $Anchor
@onready var _grid_lines: Node2D = $Anchor/Grid/GridLines
@onready var _grid_layers: Node2D = $Anchor/Grid/GridLayers

@onready var _notes_root: Node2D = $Anchor/Items/Notes
@onready var _events_root: Node2D = $Anchor/Items/Events
@onready var _markers_root: Node2D = $Anchor/Items/Markers

# Time marker
@onready var _time_marker: Node2D = $Anchor/TimeMarker
@onready var _time_marker_line: Line2D = $Anchor/TimeMarker/Line
@onready var _time_marker_collision: CollisionShape2D = $Anchor/TimeMarker/Area2D/CollisionShape2D

# Indicator
@onready var _indicator_root: Node2D = $Anchor/IndicatorRoot
@onready var _indicator_note: Note2D = $Anchor/IndicatorRoot/Note2D
@onready var _indicator_event: Event2D = $Anchor/IndicatorRoot/Event2D
@onready var _indicator_marker: Mark2D = $Anchor/IndicatorRoot/Marker2D


var _level: Level

# Total beats in level
var total_beats: float:
	get: return _level.get_beat_count()

# Timeline settings
var snap_beats: float = 1.0
var bar_gap: float = INITIAL_BAR_GAP:
	set(value):
		bar_gap = value
		_on_bar_gap_change()


func _ready():
	_indicator_note.bar_gap = bar_gap
	_indicator_event.bar_gap = bar_gap



## Gets level information. Called when loading the level editor
func load_level(level: Level):
	_level = level
	_set_initial_values()
	_load_items_from_level(level)

func unload():
	_remove_all_items()
	_undraw_grid()



func _set_initial_values() -> void:
	_init_time_marker()
	_on_total_beats_change()
	_indicator_root.position = _snap_pos(_indicator_root.position, snap_beats) # set initial pos



func _on_total_beats_change() -> void:
	_undraw_grid()
	_draw_grid()

## Called when time changes
func on_time_change(second: float) -> void:
	_move_time_marker(second)
	# TODO: update scroll position to match marker position

## Called when bar gap changes
func _on_bar_gap_change() -> void:
	# Update space between lines
	var lines = _grid_lines.get_children()
	for i in range(lines.size()):  lines[i].position.x = _beat_to_pixel(i)
	# Update indicator gaps
	_indicator_note.bar_gap = bar_gap
	_indicator_event.bar_gap = bar_gap
	# Update notes, event, and marker positions
	for note in _notes_root.get_children(): pass
	# TODO: sdfsdfsdf

	# Update time marker position
	# TODO: do it



## Deletes all items from timeline
func _remove_all_items() -> void:
	for note in _notes_root.get_children():
		note.queue_free()
	for event in _events_root.get_children():
		event.queue_free()
	for marker in _markers_root.get_children():
		marker.queue_free()



## Gets beat in song, moves timeline anchor accordingly
##
## Called when scrolling timeline
func scroll_to_beat(beat: float) -> void:
	_anchor.position.x = -beat  * bar_gap


## Gets position on timeline, returns position on timeline snapped to beat
func _snap_pos(pos: Vector2, snap_ratio: float, snap_y= true) -> Vector2:
	var x = _pixel_to_beat(pos.x)
	x = round(x / snap_ratio) * snap_ratio # round beat to nearest snap
	x = _beat_to_pixel(x)

	var y: float = (_pixel_to_layer(pos.y) * layer_gap) if snap_y else MARKER_Y

	return Vector2(x,y)


## Gets item info, returns its position
func _get_item_info_coords(item_info: Globals.ItemInfo) -> Vector2:
	var x = _beat_to_pixel(item_info.b)
	var y: float
	if item_info is Globals.MarkerInfo: y = MARKER_Y
	else: y = _layer_to_pixel(item_info.layer)
	return Vector2(x,y)


## Gets global position, returns items that were found at that point
func get_items_at_global(global_pos) -> Array[Item2D]:
	var items: Array[Item2D] = []

	var gui = get_node("/root/LevelEditor/Camera2D/GUI")

	# Set point quary that can find items
	var point_quary = PhysicsPointQueryParameters2D.new()
	point_quary.position = global_pos
	point_quary.collide_with_areas = true
	point_quary.canvas_instance_id = gui.get_instance_id()

	var space_state = get_world_2d().direct_space_state
	var intersected: Array = space_state.intersect_point(point_quary)

	# go over all intersections and append the items
	for info_dict in intersected:
		var nd: Node2D = info_dict["collider"].get_parent()
		if nd is Item2D: items.append(nd)

	return items



# Generating info ================================================================

func _get_note_info(note: Note2D) -> Globals.NoteInfo:
	var note_info = note.get_info()

	# add timline info to note_info
	var beat = _pixel_to_beat(note.position.x)
	var layer = _pixel_to_layer(note.position.y)
	
	note_info.s = beat - note_info.delay # note start beat
	# TODO: maybe next two lines are not needed
	note_info.b = beat 	# note arrival beat
	note_info.layer = layer

	return note_info

func _get_event_info(event: Event2D) -> Globals.EventInfo:
	var event_info = event.get_info()

	# add timline info to note_info
	var beat = _pixel_to_beat(event.position.x)
	var layer = _pixel_to_layer(event.position.y)
	
	event_info.s = beat - event_info.delay # event start beat
	# TODO: maybe next two lines are not needed
	event_info.b = beat 	# note arrival beat
	event_info.layer = layer

	return event_info

func _get_marker_info(marker: Mark2D) -> Globals.MarkerInfo:
	var marker_info = marker.get_info()
	marker_info.b = _pixel_to_beat(marker.position.x)
	return marker_info

## Used for custom sorting of note_list
func _sort_notes_events_list(a, b) -> bool: return a.s < b.s


## Generate note list from notes in timeline
func generate_note_list() -> Array[Globals.NoteInfo]:
	var note_list: Array[Globals.NoteInfo] = []

	for note in _notes_root.get_children():  note_list.append(_get_note_info(note))

	note_list.sort_custom(_sort_notes_events_list) # sort note_list by beat start

	return note_list

func generate_event_list() -> Array[Globals.EventInfo]:
	var event_list: Array[Globals.EventInfo] = []

	for event in _events_root.get_children():  event_list.append(_get_event_info(event))

	event_list.sort_custom(_sort_notes_events_list) # sort event_list by beat start

	return event_list

func generate_marker_list() -> Array[Globals.MarkerInfo]:
	var marker_list: Array[Globals.MarkerInfo] = []
	for marker in _markers_root.get_children(): marker_list.append(_get_marker_info(marker))
	return marker_list


# Placing and Deleting ==============================================================


## Returns item node from given item_info.
func _create_item(item_info: Globals.ItemInfo) -> Item2D:
	var item = null

	if item_info is Globals.NoteInfo:
		item = NOTE_SCENE.instantiate()
		item.bar_gap = bar_gap
		_notes_root.add_child(item)
	
	elif item_info is Globals.EventInfo:
		item = EVENT_SCENE.instantiate()
		item.bar_gap = bar_gap
		_events_root.add_child(item)
	
	elif item_info is Globals.MarkerInfo:
		item = MARKER_SCENE.instantiate()
		_markers_root.add_child(item)
	
	if item != null: item.set_data_from(item_info)

	return item


func _is_legal_placement(_time_pos: Vector2) -> bool:
	# TODO: check if other items are placed in same beat
	#		check if start beat is before start of song
	return true


## Gets item info, creates and places item according to b and layer values.
## returns true if succeeded.
func place_item(item_info: Globals.ItemInfo) -> bool:

	var time_pos = _get_item_info_coords(item_info)

	if not _is_legal_placement(time_pos): return false

	# create item and place on timeline
	var item: Item2D = _create_item(item_info)
	item.position = time_pos
	item.on_placed()

	return true

## Gets item info, deletes item
func delete_item(item_info: Globals.ItemInfo) -> bool:
	var time_pos = _get_item_info_coords(item_info)
	var global_pos = _anchor.to_global(time_pos)
	var items = get_items_at_global(global_pos)

	if len(items) <= 0: return false
	items[0].queue_free()
	return true


# Loads items from save into timeline
func _load_items_from_level(level: Level) -> void:
	for note_info in level.note_list:  place_item(Globals.NoteInfo.new(note_info))

	for event_info in level.event_list:  place_item(Globals.EventInfo.new(event_info))
	
	for marker_info in level.marker_list:  place_item(Globals.MarkerInfo.new(marker_info))


# Indicator item ======================================================================

var _current_indicator_type: Globals.ITEM_TYPE

# Indicator node that is shown in timeline
var _indicator_item: Item2D:
	get:
		match _current_indicator_type:
			Globals.ITEM_TYPE.NOTE: return _indicator_note
			Globals.ITEM_TYPE.EVENT: return _indicator_event
			Globals.ITEM_TYPE.MARKER: return _indicator_marker
		return null


func get_indicator_item_info() -> Globals.ItemInfo:
	var item_info = Globals.clone_item_info(_indicator_item.get_info())
	# Add some data according to position
	item_info.b = _pixel_to_beat(_indicator_root.position.x)
	if item_info is Globals.NoteInfo or item_info is Globals.EventInfo:  item_info.layer = _pixel_to_layer(_indicator_root.position.y)
	return item_info

## Set indicator item to given stats
func set_indicator_item_info(item_info: Globals.ItemInfo) -> void:
	if item_info is Globals.NoteInfo: 		_current_indicator_type = Globals.ITEM_TYPE.NOTE
	elif item_info is Globals.EventInfo: 	_current_indicator_type = Globals.ITEM_TYPE.EVENT
	else: 									_current_indicator_type = Globals.ITEM_TYPE.MARKER

	show_indicator()
	_indicator_item.set_data_from(item_info)

func show_indicator() -> void:
	_indicator_note.visible = false
	_indicator_event.visible = false
	_indicator_marker.visible = false

	match _current_indicator_type:
		Globals.ITEM_TYPE.NOTE: _indicator_note.visible = true
		Globals.ITEM_TYPE.EVENT: _indicator_event.visible = true
		Globals.ITEM_TYPE.MARKER: _indicator_marker.visible = true

func set_indicator_visibility(state: bool) -> void:  _indicator_root.visible = state


## Gets position on timeline, updates indicator root to snap position.
##
## Called when moving mouse on timeline
func update_indicator_pos(time_pos):
	var snap_y = false if _indicator_item.get_info() is Globals.MarkerInfo else true
	_indicator_root.position = _snap_pos(time_pos, snap_beats, snap_y)


# Time marker =========================================================================

## Gets second in song, moves time marker to correct position.
##
## Called when moving time bar in song player controller
func _move_time_marker(second: float) -> void:
	_time_marker.position.x = _beat_to_pixel(_level.seconds_to_beats(second))


func _init_time_marker() -> void:
	_set_time_marker_height(BAR_HEIGHT)
	_time_marker.position.x = BARS_OFFSET

func _set_time_marker_height(h: float) -> void:
	_time_marker_line.set_point_position(1, Vector2(0, h))
	_time_marker_collision.shape.b = Vector2(0,h)




# Drawing grid =================================================================

## Returns a Line2D for the beat line of the given num (from 0 to total beats)
## if bar is true, uses _bar_color
func _make_bar(num: int, bar: bool) -> Line2D:
	# Make Line2D
	var line := Line2D.new()
	var c: Color = _bar_color if bar else _beat_color
	line.add_point(Vector2(0,0))
	line.add_point(Vector2(0,BAR_HEIGHT))
	line.default_color = c
	line.width = BAR_WIDTH
	line.z_as_relative = 1
	# Set position
	line.position.x = _beat_to_pixel(num)

	return line

## Returns a Line2d for the layer with the given number
func _make_layer(num: int) -> Line2D:
	# Make Line2D
	var line := Line2D.new()
	var end_x = (total_beats * bar_gap) + BARS_OFFSET
	line.add_point(Vector2(BARS_OFFSET, 0))
	line.add_point(Vector2(end_x, 0))
	line.default_color = _layer_color
	line.width = BAR_WIDTH
	line.z_as_relative = 0
	# Set position
	line.position.y = _layer_to_pixel(num)

	return line

## Returns a label for the beat number display
func _make_label(idx: int) -> Label:
	var label = Label.new()
	# Align label
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	label.grow_vertical = Control.GROW_DIRECTION_BEGIN
	label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	label.position.y -= 3
	# Set text
	label.text = str(idx)
	return label

func _draw_grid() -> void:

	# make vertical lines
	for i in int(total_beats):
		var line := _make_bar(i, (i % BARS == 0))
		line.add_child(_make_label(i))
		_grid_lines.add_child(line)
	
	# make horizontal lines
	for i in LAYERS:
		var line := _make_layer(i+1)
		_grid_layers.add_child(line)

func _undraw_grid() -> void:
	for n in _grid_lines.get_children():
		n.queue_free()
	for n in _grid_layers.get_children():
		n.queue_free()


# Conversions ===================================================================

## Gets x pixel on timeline, returns beat
func _pixel_to_beat(pixel: float) -> float:  return clamp((pixel - BARS_OFFSET) / bar_gap, 0, total_beats)

## Gets y pixel on timeline, returns layer
func _pixel_to_layer(pixel: float) -> int:  return clamp(round(pixel / layer_gap), 1, LAYERS)

## returns pixel on timeline.
## layer is a value from 1 to LAYER.
func _layer_to_pixel(num: int) -> float:  return layer_gap * num

## Gets beat, returns pixel on timeline
func _beat_to_pixel(beat: float) -> float:  return (beat * bar_gap) + BARS_OFFSET



## Gets position on panel, returns position on timeline
func panel_to_timeline(pos: Vector2) -> Vector2:  return Vector2(pos.x - _anchor.position.x, pos.y)

func pixel_to_second(pixel: float) -> float:  return _level.beats_to_seconds(_pixel_to_beat(pixel))
	

