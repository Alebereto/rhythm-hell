extends Node2D

# Size values for timeline (TODO: set to fit control instead of constants)
const BAR_GAP: float = 64.0
const BAR_WIDTH: float = 2.0
const BARS_OFFSET: float = 20.0
const BAR_HEIGHT: float = 290.0
const BARS: int = 4

var layer_gap: float: get = _get_layer_gap
const LAYERS: int = 5
func _get_layer_gap() -> float: return (BAR_HEIGHT / (LAYERS+1))


# Item scene loactions
var note_scene: PackedScene = preload("res://scenes/level_editor/assets/level_editor_menu/items/note_2d.tscn")
const EVENT_PATH = ""
const MARKER_PATH = ""


var _level: Level


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



# Total beats in _level
var total_beats: float: get = _get_total_beats
# Indicator note_scene that is shown in timeline
var indicator_item: get = _get_indicator_item

# Getters
func _get_total_beats() -> float: return _level.beat_count

func _get_indicator_item():
	# TODO: change to indicator according to current item type
	if _indicator_root.get_child_count() == 0: return null
	return _indicator_root.get_child(0)


# Timeline settings
var snap_beats: float = 1.0



## Gets song information. Called when loading the level editor
func load_level(level: Level):
	_level = level
	_set_initial_values()
	_load_items(level)



func _set_initial_values() -> void:
	_init_time_marker()
	_on_total_beats_change()
	_indicator_root.position = _snap_pos(_indicator_root.position, snap_beats)

func _on_total_beats_change() -> void:
	_draw_grid()

# Loads items from save into timeline
func _load_items(level: Level) -> void:
	for note_info in level.note_list:
		var placing_note = Globals.NoteInfo.new(note_info)

		var x = _beat_to_pixel(note_info.b)
		var y = _layer_to_pixel(note_info.layer)

		_place_item(placing_note, Vector2(x,y))

	# TODO: load other items




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

# layer 1 to LAYERS
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

func _generate_note_info(note: Node2D) -> Globals.NoteInfo:
	var beat = _pixel_to_beat(note.position.x)
	var layer = _pixel_to_layer(note.position.y)
	# make map of note_scene info
	var note_info = note.get_data()

	note_info.s = beat - note_info.delay # note_scene start beat
	note_info.b = beat 	# note_scene arrival beat
	note_info.layer = layer

	return note_info

## Used for custom sorting of note_list
func _sort_note_list(a: Globals.NoteInfo, b: Globals.NoteInfo) -> bool:
	return a.s < b.s

## Generate note_scene list from notes in timeline
func generate_note_list() -> Array[Globals.NoteInfo]:
	var note_list: Array[Globals.NoteInfo] = []

	for note in _notes_root.get_children():
		var note_info = _generate_note_info(note)
		# add to list
		note_list.append(note_info)

	# sort note_list by beat start
	note_list.sort_custom(_sort_note_list)

	return note_list




## Called when user left clicks timeline box while on item tool.
## Gets position of mouse when clicked on panel
func place_indicator_item(_item_pos: Vector2) -> void:
	_place_item(indicator_item.get_data(), _indicator_root.position)


## Gets item info and position on timeline, creates item and places is in position.
## Can fail if the placement is not legal
func _place_item(item_info: Globals.ItemInfo, time_pos: Vector2) -> void:
	var item: Node2D = _create_item(item_info)
	item.position = time_pos
	item.on_placed()
	if not _is_legal_placement(item): delete_item(item)

func _create_item(item_info: Globals.ItemInfo) -> Node2D:
	var item = null


	if item_info is Globals.NoteInfo:
			item = note_scene.instantiate()
			_notes_root.add_child(item)

			item.set_data_from(item_info)
	
	# TODO: create other items

	return item



func _is_legal_placement(_item: Node2D) -> bool:
	# TODO: check if other note_scene is placed in same beat
	#		check if start beat is before start of song
	return true


## Set indicator item to given stats
func set_indicator_item(item: Globals.ItemInfo) -> void:
	# TODO: switch between indicator items
	indicator_item.set_data_from(item)


func delete_item(item: Node2D) -> void:
	item.queue_free()


func show_indicator_item(show_indicator: bool) -> void:
	_indicator_root.visible = show_indicator
