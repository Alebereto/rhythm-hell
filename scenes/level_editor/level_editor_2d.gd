extends Node2D

enum EditorMenu {NONE, MAIN_MENU, LEVEL_EDITOR, LEVEL_SETTINGS}


# Menus
@onready var _header_tabs = $Camera2D/GUI/Background/MainLayout/HeaderTabs
@onready var _main_menu = $Camera2D/GUI/Background/MainLayout/MainMenu
@onready var _level_settings_menu = $Camera2D/GUI/Background/MainLayout/LevelSettings
@onready var _level_editor_menu = $Camera2D/GUI/Background/MainLayout/LevelEditorMenu

# Popups
@onready var _load_dir_popup: FileDialog = $Popups/LoadDir
@onready var _bad_path_popup: AcceptDialog = $Popups/Alert


var _current_menu: EditorMenu = EditorMenu.NONE



func _ready():
	# load main menu on startup
	_load_main_menu()



## Load the main menu
func _load_main_menu() -> void:
	if _current_menu == EditorMenu.LEVEL_EDITOR:
		_level_editor_menu.unload()

	_header_tabs.set_edit_menu_states(false, false, false)
	_header_tabs.set_file_menu_states(true, true, false)
	_show_menu(EditorMenu.MAIN_MENU)

## Load the level editor with given level (can fail)
func _load_level_editor_menu(level: Level) -> void:

	if _current_menu == EditorMenu.LEVEL_EDITOR:
		_level_editor_menu.unload()
	_level_editor_menu.load_level(level)

	_header_tabs.set_edit_menu_states(false, false, true)
	_header_tabs.set_file_menu_states(true, true, true)
	_show_menu(EditorMenu.LEVEL_EDITOR)

## Load the level settings menu
func _load_level_settings_menu(new_level: bool, current_level: Level) -> void:
	if _current_menu == EditorMenu.LEVEL_EDITOR:
		_level_editor_menu.unload()

	_level_settings_menu.load(new_level, current_level)

	_header_tabs.set_edit_menu_states(false, false, false)
	_header_tabs.set_file_menu_states(false, true, false)
	_show_menu(EditorMenu.LEVEL_SETTINGS)



## Shows menu with given id
func _show_menu(id: EditorMenu) -> void:
	# Hide all menus
	_main_menu.visible = false
	_level_editor_menu.visible = false
	_level_settings_menu.visible = false

	_current_menu = id
	match id:
		EditorMenu.MAIN_MENU: _main_menu.visible = true
		EditorMenu.LEVEL_EDITOR: _level_editor_menu.visible = true
		EditorMenu.LEVEL_SETTINGS: _level_settings_menu.visible = true




## Gets level path from user, returns null if failed
func _get_level_path():
	# show load file popup and get directory path
	_load_dir_popup.visible = true
	var level_path = await _load_dir_popup.dir_select_resolved

	if level_path == null: return null # user cancelled load

	if not Globals.is_legal_level_path(level_path):
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
	var save_dir = "%s/%s" %[Globals.get_custom_levels_path(), level.name]

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


func _load_level_from_dir() -> void:
	var level: Level = await _get_level_from_user()
	if level == null: return
	_load_level_editor_menu(level)


# input signals ====================================================================================

# main menu =========================

func _on_main_menu_new_level_requested():
	_load_level_settings_menu(true, null)


func _on_main_menu_load_level_requested():
	_load_level_from_dir()


# Level editor menu ======================

## Called when user saves level in level editor menu
func _on_level_editor_menu_save_level(level: Level):
	_on_save_requested(level)

func _on_level_editor_menu_set_header_states(save_state: bool, undo_state: bool, redo_state: bool, level_settings_state: bool):
	_header_tabs.set_edit_menu_states(undo_state, redo_state, level_settings_state)
	_header_tabs.set_file_menu_states(true, true, save_state)


# Header ===============================


func _on_header_tabs_save_level():
	if _current_menu == EditorMenu.LEVEL_EDITOR: _level_editor_menu.save()


func _on_header_tabs_new_level():
	var lvl = null
	if _current_menu == EditorMenu.LEVEL_EDITOR:
		_level_editor_menu.update_level_data()
		lvl = _level_editor_menu.get_edited_level()
	_load_level_settings_menu(true, lvl)

func _on_header_tabs_load_level():
	_load_level_from_dir()


func _on_header_tabs_redo():
	if _current_menu == EditorMenu.LEVEL_EDITOR:
		_level_editor_menu.redo()


func _on_header_tabs_undo():
	if _current_menu == EditorMenu.LEVEL_EDITOR:
		_level_editor_menu.undo()


func _on_header_tabs_level_settings():
	if _current_menu != EditorMenu.LEVEL_EDITOR: return

	_level_editor_menu.update_level_data()
	_load_level_settings_menu(false, _level_editor_menu.get_edited_level())


func _on_header_tabs_quit():
	# TODO: check if save needed
	get_tree().quit()



# Level settings ======================================


func _on_level_settings_confirmed(level:Level):
	_load_level_editor_menu(level)


func _on_level_settings_exit(level: Level= null):
	if level == null: _load_main_menu()
	else: _load_level_editor_menu(level)
