extends MarginContainer


signal save_level(_song)

var _song: Song

# true if level editor menu is shown
var _is_focused: bool = false

@onready var _song_player: SongPlayer = $SongPlayer
@onready var _items_menu: HBoxContainer = $Panels/OptionsMenus/ItemsMenu
@onready var _song_player_controller: PanelContainer = $Panels/OptionsMenus/SongMenu/SongPlayerController
@onready var _time_line_settings: PanelContainer = $Panels/OptionsMenus/SongMenu/TimeLineSettings

@onready var _time_line: VBoxContainer = $Panels/TimeLine



## Loads song, reutrns true if successful
func load_song(song: Song) -> bool:
	_song = song
	
	# load audio file to song player
	_song_player.load_song(song.audio_path)

	if song["length"] == null:	song["length"] = _song_player.song_length
	
	_items_menu.load_song(song)
	_song_player_controller.load_song(song)
	_time_line_settings.load_song(song)
	_time_line.load_song(song)
	
	_is_focused = true
	return true

## Called when unloading level editor menu
func unload() -> void:
	_is_focused = false


## Sends current level infromation to save_level signal
func save() -> void:
	_update_song_data()
	save_level.emit(_song)

# Updates song data with information that is not immediatley saved
func _update_song_data() -> void:
	# Ordered list of notes (by start beat)
	var time_line_data: Dictionary = _time_line.generate_dynamic_data()
	var items_data: Dictionary = _items_menu.generate_dynamic_data()

	_song.data.merge(time_line_data, true)
	_song.data.merge(items_data, true)


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



# Song playing inputs

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
		
