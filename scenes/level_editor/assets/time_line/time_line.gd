extends Node2D


@export_category("Refrences")
@export var time_scroller: HScrollBar
@export var snap_beats_slider: VBoxContainer
@export var item_lists: TabContainer

@export_category("Customize")
@export var bar_color: Color
@export var beat_color: Color
@export var layer_color: Color

# Get TimeLine part refrences
@onready var anchor: Node2D = $Anchor
@onready var grid_lines: Node2D = $Anchor/Grid/GridLines
@onready var grid_layers: Node2D = $Anchor/Grid/GridLayers
@onready var notes_root: Node2D = $Anchor/Notes
@onready var indicator_root: Node2D = $Anchor/IndicatorRoot

# Array of notes in timeline
var _notes: Array: get = _get_notes
# Total beats in song
var total_beats: float: get = _get_total_beats
# Indicator note that is shown in timeline
var indicator_note: get = _get_indicator_note

# Timeline settings
var snap_beats: float

# Size values for timeline
const BAR_GAP: float = 64.0
const BAR_WIDTH: float = 2.0
const BARS_OFFSET: float = 20.0
const BAR_HEIGHT: float = 290.0
const BARS: int = 4

var layer_gap: float: get = _get_layer_gap
const LAYERS: int = 5

# Getters
func _get_total_beats() -> float: return 120.0
func _get_layer_gap() -> float: return (BAR_HEIGHT / (LAYERS+1))

func _get_notes() -> Array: return notes_root.get_children()
func _get_indicator_note():
	if indicator_root.get_child_count() == 0: return null
	return indicator_root.get_child(0)


# Called when the node enters the scene tree for the first time.
func _ready():
	_set_initial_values()
	_connect_signals()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _set_initial_values() -> void:
	snap_beats = snap_beats_slider.value
	_on_total_beats_change()
	_init_item_lists()


func _connect_signals() -> void:
	snap_beats_slider.changed_snap_beats.connect(_on_snap_beats_changed)


func _init_item_lists() -> void:
	# =============================================================================
	pass

func _on_snap_beats_changed(value: float) -> void:
	snap_beats = value

func _on_total_beats_change() -> void:
	_init_time_scroller()
	_draw_grid()


func _init_time_scroller() -> void:
	var end_x = (total_beats * BAR_GAP) + BARS_OFFSET
	time_scroller.max_value = end_x
	time_scroller.page = 0.1 * end_x

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
	label.position = Vector2(x-6, -25)
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


## Gets position on timeline, snaps to beat
func _snap_pos(pos: Vector2) -> Vector2:
	var x = _pixel_to_beat(pos.x)
	x = round(x / snap_beats) * snap_beats # round beat to nearest snap beat
	x = _beat_to_pixel(x)

	var y: float = _pixel_to_layer(pos.y) * layer_gap

	return Vector2(x,y)


## Gets pixel on timeline, returns beat
func _pixel_to_beat(pixel: float) -> float:
	var beat: float = (pixel - BARS_OFFSET) / BAR_GAP
	return clamp(beat, 0, total_beats)

func _pixel_to_layer(pixel: float) -> int:
	return clamp(round(pixel / layer_gap), 1, LAYERS)

## Gets beat, returns pixel on timeline
func _beat_to_pixel(beat: float) -> float:
	var pixel: float = (beat * BAR_GAP) + BARS_OFFSET
	return pixel

## Places note in indicator_note position, assumes tile is empty
func _place_note(pos: Vector2) -> void:
	# check if legal indicator_note
	# add beat and layer to dictionary
	var created_note: Node2D	# instantiate new note
	# created_note.copy_from(indicator_note) # (including position)
	# notes_root.add_child(created_note)


## Used for custom sorting of note_list
func _sort_note_list(a:Dictionary, b:Dictionary) -> bool:
	return a["s"] < b["s"]

## Generate note list from notes in timeline
func generate_note_list() -> Array[Dictionary]:
	var note_list: Array[Dictionary] = []

	for note: Node2D in _notes:
		var beat = _pixel_to_beat(note.position.x)
		# make map of note info
		var note_info = {
			"b": beat, 	# note arrival beat
			"s": beat - note.delay # note start beat
		}
		# add to list
		note_list.append(note_info)

	# sort note_list by beat start
	note_list.sort_custom(_sort_note_list)

	return note_list



# Input functions ===================================================

## Called when mouse moves or clicks in timeline panel
func _on_panel_gui_input(event):
	var pos: Vector2 = event.position # mouse location relative to panel
	var time_pos: Vector2 = Vector2(pos.x - anchor.position.x, pos.y) # mouse location on timeline

	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			1: _on_left_click_timeline(time_pos)
			2: _on_right_click_timeline(time_pos)

	if event is InputEventMouseMotion:
		indicator_root.position = _snap_pos(time_pos)

## Called when mouse enters timeline panel
func _on_panel_mouse_entered():
	indicator_root.visible = true

## Called when mouse exits timeline panel
func _on_panel_mouse_exited():
	indicator_root.visible = false

## Called when user left clicks timeline panel
func _on_left_click_timeline(pos: Vector2) -> void:
	if indicator_note == null: return
	_place_note(indicator_note.position)

## Called when user right clicks timeline panel
func _on_right_click_timeline(pos: Vector2) -> void:
	pass

## called when scrolling timeline time_scroller
func _on_h_scroll_bar_scrolling():
	var pos = time_scroller.value
	anchor.position.x = -pos
