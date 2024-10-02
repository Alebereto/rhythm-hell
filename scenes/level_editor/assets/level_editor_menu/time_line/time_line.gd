extends VBoxContainer


signal item_copied(item: Globals.ItemInfo)
signal time_marker_moved(second: float)

signal action_taken( action: Globals.EditorAction )


@onready var _time_line_scroller: HScrollBar = $TimeLineScroller
@onready var _time_line_grid: Node2D = $TimeLineBox/TimeLineBox/TimeLineGrid
@onready var _time_line_box: Panel = $TimeLineBox/TimeLineBox


var _current_tool: Globals.TOOL


## Called when loading level
func load_level(level: Level) -> void:
	
	_on_total_beats_changed(level.beat_count)
	_time_line_grid.load_level(level)

func unload():
	_time_line_grid.unload()



func _on_total_beats_changed(beats: float) -> void:
	_time_line_scroller.max_value = beats


## update data that was dynamically created in level editor
func generate_dynamic_data(level: Level) -> void:
	level.note_list = _time_line_grid.generate_note_list()


## Called to take actions
func take_action(action: Globals.EditorAction ):
	var action_succeeded = false

	if action is Globals.PlaceItem:
		action_succeeded = _time_line_grid.place_item(action.get_item_info())

	elif action is Globals.DeleteItem:
		action_succeeded = _time_line_grid.delete_item(action.get_item_info())

	if action_succeeded: action_taken.emit( action )





## Sets current tool to given tool
func set_tool(t: Globals.TOOL) -> void:
	_current_tool = t
	_time_line_grid.show_indicator_item(false)

	var cursor = CURSOR_ARROW
	match t:
		Globals.TOOL.SELECT: cursor = CURSOR_ARROW
		Globals.TOOL.DELETE: cursor = CURSOR_CROSS
		Globals.TOOL.ITEM:
			cursor = CURSOR_POINTING_HAND
			if _mouse_in_timeline(): _time_line_grid.show_indicator_item(true)

	_time_line_box.mouse_default_cursor_shape = cursor

## Sets current selected item to given item
func set_item(item_info: Globals.ItemInfo) -> void:
	_time_line_grid.set_indicator_item(item_info)




func _delete_item_action( item_info: Globals.ItemInfo ):
	var delete_action = Globals.DeleteItem.new( item_info )
	take_action(delete_action)


func _place_item_action( item_info: Globals.ItemInfo ):
	var place_action = Globals.PlaceItem.new(item_info)
	take_action(place_action)




## takes a DeleteItem action for items found at global_pos
func _delete_at_pos(global_pos: Vector2) -> void:
	var items = _time_line_grid.get_items_at_global(global_pos)
	for item in items:
		_delete_item_action(item.get_data())




## Returns true if mouse is inside timeline
func _mouse_in_timeline() -> bool:
	return Rect2(Vector2(), _time_line_box.size).has_point(_time_line_box.get_local_mouse_position())




## Called when changing snap beats value
func set_snap_beats(value: float) -> void:
	_time_line_grid.snap_beats = value

## Called when song player time changes
func on_song_player_value_changed(second: float) -> void:
	_time_line_grid.move_time_marker(second)





## Called when left clicking timeline
func _on_left_click_timeline(_time_pos: Vector2, global_pos: Vector2) -> void:
	match _current_tool:
		Globals.TOOL.ITEM:
			_place_item_action(_time_line_grid.get_indicator_item_info())
		Globals.TOOL.DELETE:
			_delete_at_pos(global_pos)

## Called when right clicking timeline
func _on_right_click_timeline(_time_pos: Vector2) -> void:
	pass

## Called when mouse moves on timeline
func _on_timeline_motion(time_pos: Vector2) -> void:
	_time_line_grid.update_indicator_pos(time_pos)

## Called when moving mouse and holding left click
func _on_timeline_motion_left_click(_time_pos: Vector2, global_pos: Vector2)  -> void:
	match _current_tool:
		Globals.TOOL.DELETE: _delete_at_pos(global_pos)




# Input signals ==========================================================================


## Called when scrolling time line scroller
func _on_time_line_scroller_scrolling():
	var beat = _time_line_scroller.value
	_time_line_grid.scroll_to_beat(beat)


## Called when mouse interacts with timeline panel
func _on_time_line_box_gui_input(event):
	var pos: Vector2 = event.position # mouse location relative to panel
	var time_pos: Vector2 = _time_line_grid.panel_to_timeline(pos)
	var global_pos = pos + _time_line_box.global_position

	## Called once when starting click
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_on_left_click_timeline(time_pos, global_pos)

			MOUSE_BUTTON_RIGHT:
				_on_right_click_timeline(time_pos)

	if event is InputEventMouseMotion:
		_on_timeline_motion(time_pos)
		if event.button_mask == MOUSE_BUTTON_LEFT: _on_timeline_motion_left_click(time_pos, global_pos)


func _on_time_line_box_mouse_entered():
	if _current_tool == Globals.TOOL.ITEM:
		_time_line_grid.show_indicator_item(true)


func _on_time_line_box_mouse_exited():
	_time_line_grid.show_indicator_item(false)


## Called when mouse interacts with time bar panel
func _on_time_bar_gui_input(event):
	# If dragging time bar
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) or \
	 	(event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_LEFT):

		# translate position on panel to second in song
		var time_pos: Vector2 = _time_line_grid.panel_to_timeline(event.position)
		var second: float = _time_line_grid.pixel_to_second(time_pos.x)
		# emit time marker moved
		time_marker_moved.emit(second)
