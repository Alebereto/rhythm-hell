extends MarginContainer

const ACTIONS_REMEMBERED = 10

signal save_level(level: Level)
signal set_header_states( save: bool, undo: bool, redo: bool, level_settings: bool )


# true if all changes were saved. TODO: use for unsaved changes popup
var saved = false:
	set(value):
		saved = value
		_update_header_states()


var _level: Level

# true if level editor menu is shown
var _is_focused: bool = false

var _previous_actions = Globals.Stack.new(ACTIONS_REMEMBERED)
var _undone_actions = Globals.Stack.new(ACTIONS_REMEMBERED)

@onready var _song_player: SongPlayer = $SongPlayer
@onready var _items_menu: HBoxContainer = $Panels/OptionsMenus/ItemsMenu
@onready var _song_player_controller: PanelContainer = $Panels/OptionsMenus/SongMenu/SongPlayerController
@onready var _time_line_settings: PanelContainer = $Panels/OptionsMenus/SongMenu/TimeLineSettings

@onready var _time_line: VBoxContainer = $Panels/TimeLine



## Loads level, reutrns true if successful
func load_level(level: Level) -> bool:
	_level = level
	
	# load audio file to song player
	_song_player.load_song(level.song_audio_path)

	if level.length == null: level.length = _song_player.song_length
	
	_items_menu.load_level(level)
	_song_player_controller.load_level(level)
	_time_line_settings.load_level(level)
	_time_line.load_level(level)
	
	_is_focused = true
	return true

## Called when unloading level editor menu
func unload() -> void:
	_update_level_data()
	_is_focused = false

	_items_menu.unload()
	_time_line.unload()

	_clear_action_memory()
	_level = null

## Sends current level infromation to save_level signal
func save() -> void:
	_update_level_data()
	saved = true
	save_level.emit(_level)




## Takes given action.
func _take_action( action: Globals.EditorAction ):
	_time_line.take_action(action)


## Called after succsesfuly taking an action
func _on_action_taken( action: Globals.EditorAction ):
	saved = false
	# If action is saved in stack, clear redo stack and add action to previous actions.
	if action.remember:
		action.remember = false
		_undone_actions.clear()
		_previous_actions.push( action )


## Undo last action
func _undo():
	if _previous_actions.size() <= 0: return

	var last_action: Globals.EditorAction = _previous_actions.pop()	# get last action
	var _inverse_last_action = last_action.get_inverse_action()
	_inverse_last_action.remember = false # maybe add this line to get_inverse_action()

	_take_action( _inverse_last_action )
	_undone_actions.push(last_action)

	_update_header_states()
	
## Redo last undone action
func _redo():
	if _undone_actions.size() <= 0: return

	var redo_action = _undone_actions.pop()

	_take_action(redo_action)
	_previous_actions.push(redo_action)

	_update_header_states()


func _clear_action_memory():
	_previous_actions.clear()
	_undone_actions.clear()
	_update_header_states()



# Updates level data with information that is not immediatley saved
func _update_level_data() -> void:
	# Ordered list of notes (by start beat)
	_time_line.generate_dynamic_data(_level)
	_items_menu.generate_dynamic_data(_level)



func _update_header_states():

	var save_state = not saved
	var undo_state = true if _previous_actions.size() > 0 else false
	var redo_state = true if _undone_actions.size() > 0 else false
	var level_settings = true

	set_header_states.emit(save_state, undo_state, redo_state, level_settings)



# Input signals =====================================================================================

# Items menu inputs ========

func _on_items_menu_item_switched(item: Globals.ItemInfo) -> void:
	_time_line.set_item(item)
	_time_line_settings.change_tool_to(Globals.TOOL.ITEM)	# emits tool changed signal


# TimeLine settings inputs ======

func _on_time_line_settings_tool_changed(t: Globals.TOOL) -> void:
	_time_line.set_tool(t)

func _on_time_line_settings_snap_beats_changed(value: float) -> void:
	_time_line.set_snap_beats(value)



# TimeLine inputs ==========

func _on_time_line_item_copied(item: Globals.ItemInfo) -> void:
	_items_menu.on_time_line_copied_item(item)


func _on_time_line_time_marker_moved(second: float) -> void:
	_song_player_controller.on_time_marker_moved(second)



# song playing inputs =================

func _on_song_player_song_ended() -> void:
	_song_player_controller.on_song_end()


func _on_song_player_controller_paused() -> void:
	_song_player.pause()


func _on_song_player_controller_played() -> void:
	_song_player.play()


func _on_song_player_controller_seeked(seconds: float) -> void:
	_song_player.seek(seconds)



func _on_song_player_controller_scroller_value_changed(second: float) -> void:
	_time_line.on_song_player_value_changed(second)

# Keyboard inputs ===================

func _input(event):
	if _is_focused:
		if event.is_action_pressed("level_editor_set_select_tool"):
			_time_line_settings.change_tool_to(Globals.TOOL.SELECT)
		if event.is_action_pressed("level_editor_set_delete_tool"):
			_time_line_settings.change_tool_to(Globals.TOOL.DELETE)
		if event.is_action_pressed("level_editor_set_item_tool"):
			_time_line_settings.change_tool_to(Globals.TOOL.ITEM)

		if event.is_action_pressed("level_editor_undo"): _undo()
		if event.is_action_pressed("level_editor_redo"): _redo()

		if event.is_action_pressed("level_editor_save"):
			save()
		
