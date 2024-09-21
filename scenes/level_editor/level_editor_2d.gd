extends Node2D

enum MENU {NONE, MAIN_MENU, LEVEL_EDITOR}


@export_category("Prefrences")
# Location to save song into
@export_dir var songs_dir: String = "res://songs"


@export_category("Refrences")
@export_group("Menu")
@export var _header_tabs: PanelContainer
@export var _level_editor_menu: MarginContainer
@export var _main_menu: MarginContainer

@export_group("Popups")
@export var _load_dir_popup: FileDialog
@export var _bad_path_popup: AcceptDialog



var _current_menu: MENU = MENU.NONE



# Called when the node enters the scene tree for the first time.
func _ready():
	# load main menu on startup
	_load_main_menu()


# menu functions
func _hide_menus() -> void:
	_main_menu.visible = false
	_level_editor_menu.visible = false

func _show_menu(id: MENU) -> void:
	_hide_menus()
	_current_menu = id
	match id:
		MENU.MAIN_MENU: _main_menu.visible = true
		MENU.LEVEL_EDITOR: _level_editor_menu.visible = true


## Load the main menu
func _load_main_menu() -> void:
	_show_menu(MENU.MAIN_MENU)

## Load the level editor with given song
func _load_level_editor_menu(song: Level) -> void:

	var success = _level_editor_menu.load_song(song)
	if not success: return

	_show_menu(MENU.LEVEL_EDITOR)



## Gets level path from user, returns null if failed
func _get_level_path():
	# show load file popup and get directory path
	_load_dir_popup.visible = true
	var song_path = await _load_dir_popup.dir_select_resolved
	# maybe clear dialog box stuff?? ======================

	if song_path == null: return null # user cancelled load

	if not Globals.legal_song_path(song_path):
		_bad_path_popup.visible = true
		return null
	return song_path


## Called when loading a song, can fail if song_path input is bad
func _load_level() -> void:
	var song_path = await _get_level_path()
	if song_path == null: return
	# load song info
	var song = Level.new(song_path)

	_load_level_editor_menu(song)

## Called when creating new song
func _load_new_level(song: Level) -> void:
	_load_level_editor_menu(song)



## Saves level to songs directory
func _save_level(song_name: String, save_data: Dictionary, audio_source: String) -> void:
	
	var save_data_str = JSON.stringify(save_data)
	
	# make directory for song
	var save_dir = "%s/%s" %[songs_dir, song_name]
	print(save_dir)
	# check if save directory exists
	if not DirAccess.dir_exists_absolute(save_dir):
		DirAccess.make_dir_absolute(save_dir)
	
	# File paths
	var data_path = "%s/%s" %[save_dir, Globals.SAVE_FILE_NAME]
	var audio_path = "%s/%s" %[save_dir, Globals.AUDIO_FILE_NAME]
	
	# make data file
	var file = FileAccess.open(data_path, FileAccess.WRITE)
	file.store_string(save_data_str)
	file.close()
	# copy audio file to song directory if not exists
	if not FileAccess.file_exists(audio_path):
		DirAccess.copy_absolute(audio_source, audio_path)


func _on_save_requested(song: Level) -> void:
	# TODO: check if level exists and show prompt of overwriting
	_save_level(song.song_name, song.data, song.audio_path)


# input signals ===========================


func _on_main_menu_new_song_requested(song):
	_load_new_level(song)


func _on_main_menu_load_song_requested():
	_load_level()


func _on_header_tabs_load_song_requested():
	_load_level()


func _on_header_tabs_save_song_requested():
	_level_editor_menu.save()


func _on_level_editor_menu_save_level(song: Level):
	_on_save_requested(song)
