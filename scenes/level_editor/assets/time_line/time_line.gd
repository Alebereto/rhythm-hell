extends Node2D


signal copied_item(item: Globals.ItemInfo)


var _song: Song


@export_category("Refrences")
@export var _time_scroller: HScrollBar

@export_category("Customize")
@export var bar_color: Color
@export var beat_color: Color
@export var layer_color: Color


# Get TimeLine part refrences
@onready var anchor: Node2D = $Anchor
@onready var grid_lines: Node2D = $Anchor/Grid/GridLines
@onready var grid_layers: Node2D = $Anchor/Grid/GridLayers
@onready var notes_root: Node2D = $Anchor/Items/Notes
@onready var indicator_root: Node2D = $Anchor/IndicatorRoot
@onready var time_marker: Node2D = $Anchor/TimeMarker


# Array of notes in timeline
var _notes: Array: get = _get_notes
# Total beats in _song
var total_beats: float: get = _get_total_beats
# Indicator note that is shown in timeline
var indicator_item: get = _get_indicator_item


# Timeline settings
var _snap_beats: float = 1.0
var _current_tool: Globals.TOOL

# Size values for timeline
const BAR_GAP: float = 64.0
const BAR_WIDTH: float = 2.0
const BARS_OFFSET: float = 20.0
const BAR_HEIGHT: float = 290.0
const BARS: int = 4

var layer_gap: float: get = _get_layer_gap
const LAYERS: int = 5

# Getters
func _get_total_beats() -> float: return _song.beat_count
func _get_layer_gap() -> float: return (BAR_HEIGHT / (LAYERS+1))

func _get_notes() -> Array: return notes_root.get_children()
func _get_indicator_item():
	if indicator_root.get_child_count() == 0: return null
	return indicator_root.get_child(0)



# Called when the node enters the scene tree for the first time.
func _ready():
	pass



func _set_initial_values() -> void:
	_init_time_marker()
	_on_total_beats_change()
	indicator_root.position = _snap_pos(indicator_root.position, _snap_beats)




func _on_total_beats_change() -> void:
	_init_time_scroller()
	_draw_grid()


func _init_time_scroller() -> void:
	var end_x = (total_beats * BAR_GAP) + BARS_OFFSET
	_time_scroller.max_value = end_x
	_time_scroller.page = 0.1 * end_x



# Draw grid functions

func _make_bar(num: int, bar: bool) -> Line2D:
	var line := Line2D.new()
	var c: Color
	if bar: c = bar_color
	else: c = beat_color

	var x = (BAR_GAP * num) + BARS_OFFSET
	line.add_point(Vector2(x,0))
	line.add_point(Vector2(x,BAR_HEIGHT))
	line.default_color = c
	line.width = BAR_WIDTH
	line.z_as_relative = 1
	return line

func _make_layer(num: int) -> Line2D:
	var line := Line2D.new()
	line.default_color = layer_color
	var y = layer_gap * (num + 1)
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
	label.text = str(idx+1)
	return label

func _draw_grid() -> void:

	# make vertical lines
	for i in int(total_beats):
		var line := _make_bar(i, (i % BARS == 0))
		line.add_child(_make_label(i))
		grid_lines.add_child(line)
	
	# make horizontal lines
	for i in LAYERS:
		var line := _make_layer(i)
		grid_layers.add_child(line)

func _init_time_marker() -> void:
	var line := Line2D.new()
	line.add_point(Vector2(0,0))
	line.add_point(Vector2(0,BAR_HEIGHT))
	line.default_color = Color.RED
	line.width = 3.0

	time_marker.add_child(line)
	time_marker.position.x = BARS_OFFSET



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

## Gets beat, returns pixel on timeline
func _beat_to_pixel(beat: float) -> float:
	var pixel: float = (beat * BAR_GAP) + BARS_OFFSET
	return pixel



## Places note in indicator_item position, assumes tile is empty
func _place_note(pos: Vector2) -> void:
	# check if legal indicator_item ===============

	var copied_note: Node2D = indicator_item.duplicate()
	notes_root.add_child(copied_note)

	copied_note.copy_other(indicator_item)
	copied_note.position = indicator_root.position

	


## Used for custom sorting of note_list
func _sort_note_list(a:Dictionary, b:Dictionary) -> bool:
	return a["s"] < b["s"]

## Generate note list from notes in timeline
func generate_note_list() -> Array[Dictionary]:
	var note_list: Array[Dictionary] = []

	for note: Node2D in _notes:
		var beat = _pixel_to_beat(note.position.x)
		# make map of note info
		var note_info = note.get_data().get_info_dict()

		note_info["s"] = beat - note_info["delay"] # note start beat
		note_info["b"] = beat 	# note arrival beat

		# add to list
		note_list.append(note_info)

	# sort note_list by beat start
	note_list.sort_custom(_sort_note_list)

	return note_list



func _switch_to_tool(t: Globals.TOOL):
	_current_tool = t


# Recieved Signals =======================================

func _on_load_level_editor(song: Song):
	_song = song
	_set_initial_values()

func _on_song_controller_value_change(value):
	time_marker.position.x = _beat_to_pixel(_song.seconds_to_beats(value))

## Called when changing snap_beats value
func _on_change_snap_beats(value):
	_snap_beats = value


func _on_items_menu_switch_to_item(item: Globals.ItemInfo) -> void:

	indicator_item.set_data(item)
	indicator_item.update_visuals()

# Input functions ========================================

## Called when mouse moves or clicks in timeline panel
func _on_panel_gui_input(event):
	var pos: Vector2 = event.position # mouse location relative to panel
	var time_pos: Vector2 = Vector2(pos.x - anchor.position.x, pos.y) # mouse location on timeline

	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			1: _on_left_click_timeline(time_pos)
			2: _on_right_click_timeline(time_pos)

	if event is InputEventMouseMotion:
		indicator_root.position = _snap_pos(time_pos, _snap_beats)

## Called when mouse enters timeline panel
func _on_panel_mouse_entered():
	indicator_root.visible = true

## Called when mouse exits timeline panel
func _on_panel_mouse_exited():
	indicator_root.visible = false

## Called when user left clicks timeline panel
func _on_left_click_timeline(pos: Vector2) -> void:
	if indicator_item == null: return
	_place_note(indicator_item.position)

## Called when user right clicks timeline panel
func _on_right_click_timeline(pos: Vector2) -> void:
	pass

## called when scrolling timeline _time_scroller
func _on_h_scroll_bar_scrolling():
	var pos = _time_scroller.value
	anchor.position.x = -pos
