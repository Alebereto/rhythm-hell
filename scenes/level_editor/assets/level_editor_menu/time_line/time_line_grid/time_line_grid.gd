extends Node2D

# Size values for timeline (TODO: set to fit control instead of constants)
const BAR_GAP: float = 64.0
const BAR_WIDTH: float = 2.0
const BARS_OFFSET: float = 20.0
const BAR_HEIGHT: float = 290.0
const BARS: int = 4

const LAYERS: int = 5
var layer_gap: float:
	get: return (BAR_HEIGHT / (LAYERS+1))

# Item scenes
const NOTE_SCENE: PackedScene = preload("res://scenes/level_editor/assets/level_editor_menu/items/note_2d.tscn")
const EVENT_PATH = ""
const MARKER_PATH = ""



@export_category("Customize")
@export var _bar_color: Color
@export var _beat_color: Color
@export var _layer_color: Color


# Get TimeLine part refrences
@onready var _anchor: Node2D = $Anchor
@onready var _grid_lines: Node2D = $Anchor/Grid/GridLines
@onready var _grid_layers: Node2D = $Anchor/Grid/GridLayers
@onready var _notes_root: Node2D = $Anchor/Items/Notes
@onready var _indicator_root: Node2D = $Anchor/IndicatorRoot
@onready var _time_marker: Node2D = $Anchor/TimeMarker


var _level: Level

# Total beats in level
var total_beats: float:
	get: return _level.beat_count

# Timeline settings
var snap_beats: float = 1.0


# Indicator node that is shown in timeline
var _indicator_item:
	get:
		# TODO: change to indicator according to current item type
		if _indicator_root.get_child_count() == 0: return null
		return _indicator_root.get_child(0)

func get_indicator_item_info():
	var item_info = Globals.clone_item_info(_indicator_item.get_data())
	item_info.b = _pixel_to_beat(_indicator_root.position.x)
	item_info.layer = _pixel_to_layer(_indicator_root.position.y)
	return item_info

## Set indicator item to given stats
func set_indicator_item(item_info: Globals.ItemInfo) -> void:
	# TODO: switch between indicator items
	_indicator_item.set_data_from(item_info)






## Gets level information. Called when loading the level editor
func load_level(level: Level):
	_level = level
	_set_initial_values()
	_load_items_from_level(level)



func _set_initial_values() -> void:
	_init_time_marker()
	_on_total_beats_change()
	_indicator_root.position = _snap_pos(_indicator_root.position, snap_beats)

func _on_total_beats_change() -> void:
	_draw_grid()

# Loads items from save into timeline
func _load_items_from_level(level: Level) -> void:
	for note_info in level.note_list:
		var placing_note = Globals.NoteInfo.new(note_info)
		place_item(placing_note)

	# TODO: load other items



func _get_item_info_coords(item_info: Globals.ItemInfo):
	var x = _beat_to_pixel(item_info.b)
	var y = _layer_to_pixel(item_info.layer)
	return Vector2(x,y)


## Gets item info, creates and places item according to b and layer values.
## returns true if succeeded.
func place_item(item_info: Globals.ItemInfo) -> bool:

	var time_pos = _get_item_info_coords(item_info)

	if not _is_legal_placement(time_pos): return false

	# create item and place on timeline
	var item: Node2D = _create_item(item_info)
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


## Gets position on timeline, updates indicator root to snap position.
##
## Called when moving mouse on timeline
func update_indicator_pos(time_pos):
	_indicator_root.position = _snap_pos(time_pos, snap_beats)

## Gets second in song, moves time marker to correct position.
##
## Called when moving time bar in song player controller
func move_time_marker(second: float) -> void:
	_time_marker.position.x = _beat_to_pixel(_level.seconds_to_beats(second))

## Gets beat in song, moves timeline anchor accordingly
##
## Called when scrolling timeline
func scroll_to_beat(beat: float) -> void:
	_anchor.position.x = -beat  * BAR_GAP



# Draw grid functions

func _make_bar(num: int, bar: bool) -> Line2D:
	var line := Line2D.new()
	var c: Color
	if bar: c = _bar_color
	else: c = _beat_color

	var x = (BAR_GAP * num) + BARS_OFFSET
	line.add_point(Vector2(x,0))
	line.add_point(Vector2(x,BAR_HEIGHT))
	line.default_color = c
	line.width = BAR_WIDTH
	line.z_as_relative = 1
	return line

func _make_layer(num: int) -> Line2D:
	var line := Line2D.new()
	line.default_color = _layer_color
	var y = _layer_to_pixel(num)
	var end_x = (total_beats * BAR_GAP) + BARS_OFFSET

	line.add_point(Vector2(BARS_OFFSET, y))
	line.add_point(Vector2(end_x, y))
	line.width = BAR_WIDTH
	line.z_as_relative = 0
	return line

func _make_label(idx: int) -> Label:
	var label = Label.new()

	var x = (BAR_GAP * idx) + BARS_OFFSET
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(x-6, -26)
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
		var line := _make_layer(i)
		_grid_layers.add_child(line)

func _init_time_marker() -> void:
	var line := Line2D.new()
	line.add_point(Vector2(0,0))
	line.add_point(Vector2(0,BAR_HEIGHT))
	line.default_color = Color.RED
	line.width = 3.0

	_time_marker.add_child(line)
	_time_marker.position.x = BARS_OFFSET




## Gets position on timeline, returns position on timeline snapped to beat
func _snap_pos(pos: Vector2, snap_ratio: float) -> Vector2:
	var x = _pixel_to_beat(pos.x)
	x = round(x / snap_ratio) * snap_ratio # round beat to nearest snap
	x = _beat_to_pixel(x)

	var y: float = _pixel_to_layer(pos.y) * layer_gap

	return Vector2(x,y)

## Gets x pixel on timeline, returns beat
func _pixel_to_beat(pixel: float) -> float:
	var beat: float = (pixel - BARS_OFFSET) / BAR_GAP
	return clamp(beat, 0, total_beats)

## Gets y pixel on timeline, returns layer
func _pixel_to_layer(pixel: float) -> int:
	return clamp(round(pixel / layer_gap), 1, LAYERS)

## returns pixel on timeline.
## layer is a value from 1 to LAYER.
func _layer_to_pixel(num: int) -> float:
	return layer_gap * num

## Gets beat, returns pixel on timeline
func _beat_to_pixel(beat: float) -> float:
	var pixel: float = (beat * BAR_GAP) + BARS_OFFSET
	return pixel



## Gets position on panel, returns position on timeline
func panel_to_timeline(pos: Vector2) -> Vector2:
	return Vector2(pos.x - _anchor.position.x, pos.y)

func pixel_to_second(pixel: float) -> float:
	return _level.beats_to_seconds(_pixel_to_beat(pixel))
	


# Generating 

func _get_note_info(note: Node2D) -> Globals.NoteInfo:
	var beat = _pixel_to_beat(note.position.x)
	var layer = _pixel_to_layer(note.position.y)
	# add timline info to note_info
	var note_info = note.get_data()

	note_info.s = beat - note_info.delay # note start beat
	# TODO: maybe next two lines are not needed
	note_info.b = beat 	# note arrival beat
	note_info.layer = layer

	return note_info

## Used for custom sorting of note_list
func _sort_note_list(a: Globals.NoteInfo, b: Globals.NoteInfo) -> bool:
	return a.s < b.s

## Generate note list from notes in timeline
func generate_note_list() -> Array[Globals.NoteInfo]:
	var note_list: Array[Globals.NoteInfo] = []

	for note in _notes_root.get_children():
		var note_info = _get_note_info(note)
		# add to list
		note_list.append(note_info)

	# sort note_list by beat start
	note_list.sort_custom(_sort_note_list)

	return note_list



func get_items_at_global(global_pos) -> Array:
	var arr = []

	var gui = get_node("/root/LevelEditor/Camera2D/GUI")

	# Set point quary that can find items
	var point_quary = PhysicsPointQueryParameters2D.new()
	point_quary.position = global_pos
	point_quary.collide_with_areas = true
	point_quary.canvas_instance_id = gui.get_instance_id()

	var space_state = get_world_2d().direct_space_state
	var intersected: Array = space_state.intersect_point(point_quary)

	# go over all intersections and delete the items
	for info_dict in intersected:
		var nd: Node2D = info_dict["collider"].get_parent()
		## TODO: check if item is Item2d or something?????????
		arr.append(nd)

	return arr





## Returns item node from given item_info.
func _create_item(item_info: Globals.ItemInfo) -> Node2D:
	var item = null

	if item_info is Globals.NoteInfo:
			item = NOTE_SCENE.instantiate()
			_notes_root.add_child(item)

			item.set_data_from(item_info)
	
	# TODO: create other items

	return item



func _is_legal_placement(_time_pos: Vector2) -> bool:
	# TODO: check if other items are placed in same beat
	#		check if start beat is before start of song
	return true


func show_indicator_item(show_indicator: bool) -> void:
	_indicator_root.visible = show_indicator
