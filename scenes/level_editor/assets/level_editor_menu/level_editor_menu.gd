extends MarginContainer


signal save_level(level)

var _level: Level

# true if level editor menu is shown
var _is_focused: bool = false

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
	_is_focused = false
	_level = null


## Sends current level infromation to save_level signal
func save() -> void:
	_update_level_data()
	save_level.emit(_level)

# Updates song data with information that is not immediatley saved
func _update_level_data() -> void:
	# Ordered list of notes (by start beat)
	_time_line.generate_dynamic_data(_level)
	_items_menu.generate_dynamic_data(_level)


# Input signals ====================

# Items menu inputs

func _on_items_menu_item_switched(item: Globals.ItemInfo) -> void:
	_time_line.set_item(item)
	_time_line_settings.change_tool_to(Globals.TOOL.ITEM)	# emits tool changed signal


# TimeLine settings inputs

func _on_time_line_settings_tool_changed(t: Globals.TOOL) -> void:
	_time_line.set_tool(t)

func _on_time_line_settings_snap_beats_changed(value: float) -> void:
	_time_line.set_snap_beats(value)



# TimeLine inputs

func _on_time_line_item_copied(item: Globals.ItemInfo) -> void:
	_items_menu.on_time_line_copied_item(item)


func _on_time_line_time_marker_moved(second: float) -> void:
	_song_player_controller.on_time_marker_moved(second)



# Level playing inputs

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

# Keyboard inputs

func _input(event):
	if _is_focused:
		if event.is_action_pressed("level_editor_set_select_tool"):
			_time_line_settings.change_tool_to(Globals.TOOL.SELECT)
		if event.is_action_pressed("level_editor_set_delete_tool"):
			_time_line_settings.change_tool_to(Globals.TOOL.DELETE)
		if event.is_action_pressed("level_editor_set_item_tool"):
			_time_line_settings.change_tool_to(Globals.TOOL.ITEM)

		if event.is_action_pressed("level_editor_save"):
			save()
		
