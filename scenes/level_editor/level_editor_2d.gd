extends Node2D

const SAVE_NAME = "save.dat"
const AUDIO_NAME = "song.ogg"

enum GT {KARATE, BADMIN}
enum MENU {MAIN_MENU, LEVEL_EDITOR}


@export_category("Game Settings")
# Game type
@export var game_type: GT = GT.KARATE
# Song name
@export var song_name: String = "My Song"
# Song audio file
@export_global_file("*.ogg") var audio_source: String
# Initial BPM of song
@export_range(0,200) var initial_bpm: int = 60
# Location to save song into
@export_dir var songs_dir: String = "res://songs"

@export_category("Refrences")
@export var time_line: Node2D
@export var muisc_player: PanelContainer
@export var header_tabs: HBoxContainer
@export var item_lists: TabContainer


@export_category("Menus")
@export var main_menu: MarginContainer
@export var level_editor: VBoxContainer

@onready var audio_player = $AudioStreamPlayer

@export_category("Popups")
@export var _load_dialog: FileDialog
@export var _bad_path_popup: AcceptDialog


# value of current place in song (seconds)
var track_time: float = 0
var paused: bool = true
# Song length in seconds
var song_length: float = 60

var _current_menu: MENU


signal load_dialog_complete(path)



# Called when the node enters the scene tree for the first time.
func _ready():
	# connect signals
	_connect_signals()

	# load main menu on startup
	_show_menu(MENU.MAIN_MENU)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


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


## Gets song path from user, returns true if succeeded
func _get_song_path():
	# show load file popup and get directory path
	_load_dialog.visible = true
	var song_path = await load_dialog_complete
	# maybe clear dialog box stuff?? ======================

	if song_path == null: return null # user cancelled load

	if not _legal_song_path(song_path):
		_bad_path_popup.visible = true
		return null
	return song_path

func _legal_song_path(song_path: String) -> bool:
	# check if dat and ogg files exist in directory ================
	return true


## Called when loading a song, can fail
func _load_song() -> void:
	var song_path = await _get_song_path()
	if song_path == null: return
	# load music file
	audio_player.stream = load(audio_source)
	song_length = audio_player.stream.get_length()


## Gets level information dictionary
func get_level_data() -> Dictionary:
	# Ordered list of notes (by start beat)
	var note_list: Array[Dictionary] = time_line.generate_note_list()

	var bpm_events: Array[Dictionary] = []
	
	var save_data = {
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
	var data_path = "%s/%s" %[save_dir, SAVE_NAME]
	var audio_path = "%s/%s" %[save_dir, AUDIO_NAME]
	
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
	pass # Replace with function body.


func seek(value):
	pass # Replace with function body.
