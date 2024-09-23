extends Node2D

enum MENU {NONE, MAIN_MENU, LEVEL_EDITOR}


@export_category("Prefrences")
# Location to save song into
@export_dir var levels_dir: String = "res://levels"


@export_category("Refrences")
@export_group("Menu")
# @export var _header_tabs: PanelContainer
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



## Load the main menu
func _load_main_menu() -> void:
	_show_menu(MENU.MAIN_MENU)

## Load the level editor with given level (can fail)
func _load_level_editor_menu(level: Level) -> void:

	var success = _level_editor_menu.load_level(level)
	if not success: return

	_show_menu(MENU.LEVEL_EDITOR)


## Hides all menus
func _hide_menus() -> void:
	_main_menu.visible = false
	_level_editor_menu.visible = false

## Shows menu with given id
func _show_menu(id: MENU) -> void:
	_hide_menus()
	_current_menu = id
	match id:
		MENU.MAIN_MENU: _main_menu.visible = true
		MENU.LEVEL_EDITOR: _level_editor_menu.visible = true




## Gets level path from user, returns null if failed
func _get_level_path():
	# show load file popup and get directory path
	_load_dir_popup.visible = true
	var level_path = await _load_dir_popup.dir_select_resolved
	# maybe clear dialog box stuff?? ======================

	if level_path == null: return null # user cancelled load

	if not Globals.legal_level_path(level_path):
		_bad_path_popup.visible = true
		return null
	return level_path

## Called when user loads a level, can fail if level_path input is bad
func _get_level_from_user():
	var level_path = await _get_level_path()
	if level_path == null: return null
	# load level info
	return Level.new(level_path)




## Saves level to levels directory
func _save_level(level: Level) -> void:
	
	var save_data_str = JSON.stringify(level.to_dictionary())
	
	# make directory for song
	var save_dir = "%s/%s" %[levels_dir, level.name]

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
	# copy audio file to song directory if it does not exist
	if not FileAccess.file_exists(audio_path):
		DirAccess.copy_absolute(level.song_audio_path, audio_path)


func _on_save_requested(level: Level) -> void:
	# TODO: check if level exists and show prompt of overwriting
	_save_level(level)


# input signals ===========================

# main menu ======

func _on_main_menu_new_level_requested(level):
	_load_level_editor_menu(level)


func _on_main_menu_load_level_requested():
	var level: Level = await _get_level_from_user()
	_load_level_editor_menu(level)


# Level editor menu ====

## Called when user saves level in level editor menu
func _on_level_editor_menu_save_level(level: Level):
	_on_save_requested(level)


# Other =======

func _on_header_tabs_load_level_requested():
	var level: Level = await _get_level_from_user()
	_load_level_editor_menu(level)


func _on_header_tabs_save_level_requested():
	_level_editor_menu.save()