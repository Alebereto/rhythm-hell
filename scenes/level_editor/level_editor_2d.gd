extends Node2D

enum MENU {NONE, MAIN_MENU, LEVEL_EDITOR}


@export_category("Game Data")
# Song name
@export var song_name: String = "My Song"
# Song audio file
@export_global_file("*.ogg") var audio_source: String
# Initial BPM of song
@export_range(0,200) var initial_bpm: int = 100

var song_length: float


@export_category("Prefrences")
# Location to save song into
@export_dir var songs_dir: String = "res://songs"


@export_category("Refrences")

@export_group("Nodes")
@export var time_line: Node2D
@export var header_tabs: HBoxContainer

@export_group("Menus")
@export var main_menu: MarginContainer
@export var level_editor: VBoxContainer

@export_group("Popups")
@export var _load_dialog: FileDialog
@export var _bad_path_popup: AcceptDialog



@onready var song_player = $SongPlayer


var _current_menu: MENU = MENU.NONE
var _song: Song


signal loaded_level_editor(song: Song)
signal load_dialog_complete(path)



# Called when the node enters the scene tree for the first time.
func _ready():
	# connect signals
	_connect_signals()

	# load main menu on startup
	_load_main_menu()



func _connect_signals() -> void:
	header_tabs.file_popup.id_pressed.connect(_on_file_popup_pressed)
	

# menu functions
func _hide_menus() -> void:
	main_menu.visible = false
	level_editor.visible = false

func _show_menu(id: MENU) -> void:
	_hide_menus()
	_current_menu = id
	match id:
		MENU.MAIN_MENU: main_menu.visible = true
		MENU.LEVEL_EDITOR: level_editor.visible = true


func _load_main_menu() -> void:
	_show_menu(MENU.MAIN_MENU)


func _load_level_editor() -> void:

	loaded_level_editor.emit(_song)
	_show_menu(MENU.LEVEL_EDITOR)


## Gets song path from user, returns true if succeeded
func _get_song_path():
	# show load file popup and get directory path
	_load_dialog.visible = true
	var song_path = await load_dialog_complete
	# maybe clear dialog box stuff?? ======================

	if song_path == null: return null # user cancelled load

	if not Globals.legal_song_path(song_path):
		_bad_path_popup.visible = true
		return null
	return song_path



## Called when loading a song, can fail if song_path input is bad
func _load_song() -> void:
	var song_path = await _get_song_path()
	if song_path == null: return
	# load song info
	_song = Song.new(song_path)
	song_player.load_audio_file(_song.audio_path)

	_load_level_editor()


## Called when creating new song
func _new_song() -> void:
	_song = Song.new()

	song_player.load_audio_file(audio_source)
	song_length = song_player.song_length

	_set_song_data()
	_load_level_editor()


## Sets song data according to currently selected variables
func _set_song_data() -> void:
	_song.data["name"] = song_name
	_song.data["initial_bpm"] = initial_bpm
	_song.data["length"] = song_length

## Gets level information dictionary
func get_level_data() -> Dictionary:
	# Ordered list of notes (by start beat)
	var note_list: Array[Dictionary] = time_line.generate_note_list()

	var bpm_events: Array[Dictionary] = []
	
	var save_data = {
		"name": song_name,
		"length": song_length,
		"initial_bpm": initial_bpm,
		"note_list": note_list,
		"bpm_events": bpm_events
	}
	
	return save_data

## Saves song to songs directory
func _save_song() -> void:
	
	var save_data = get_level_data()
	var save_data_str = JSON.stringify(save_data)
	
	# make directory for song
	var save_dir = "%s/%s" %[songs_dir, song_name]
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
	if not FileAccess.file_exists(audio_source):
		DirAccess.copy_absolute(audio_source, audio_path)



# input functions ===========================

func _on_file_popup_pressed(id: int) -> void:
	match id:
		1: _save_song()	# save pressed
		2: _load_song() # load pressed

func _on_load_dir_select(path: String) -> void:
	load_dialog_complete.emit(path)

func _on_load_dir_cancelled() -> void:
	load_dialog_complete.emit(null)


func _on_main_menu_load_pressed():
	_load_song()


func _on_main_menu_new_pressed():
	_new_song()
