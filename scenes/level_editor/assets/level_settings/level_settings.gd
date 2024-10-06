extends MarginContainer

signal exit( level: Level )
signal confirmed( level: Level )

# editing level
var level: Level
var current_level_copy: Level
# true if settings were accessed from level editor
var _new_level: bool = true

@onready var _title: Label = $Panel/Contents/Title

@onready var _confirm_button: Button = $Panel/Contents/MenuButtons/ConfirmButton

# Name
@onready var _name_line_edit: LineEdit = $Panel/Contents/LevelSettings/Name/LevelName
# Song path
@onready var _song_file_dialog: FileDialog = $FileDialog
@onready var _song_file_line_edit: LineEdit = $Panel/Contents/LevelSettings/SongSource/SongPath
# Length
@onready var _length_spin_box: SpinBox = $Panel/Contents/LevelSettings/Length/LevelLength
# BPM
@onready var _bpm_spin_box: SpinBox = $Panel/Contents/LevelSettings/BPM/LevelBPM
# Type
@onready var _game_type: OptionButton = $Panel/Contents/LevelSettings/Type/GameType



# Called when the node enters the scene tree for the first time.
func _ready():
	_init_game_types_panel()


## new_level is true if making a new level,
## current_level is the level that is currently being edited, or null if it does not exist.
func load(new_level: bool = true, current_level: Level= null) -> void:
	_new_level = new_level
	if new_level:
		current_level_copy = current_level
		level = Level.new()
		_title.text = "Create New Level"
		_confirm_button.disabled = true
	else:
		assert(current_level != null)
		current_level_copy = current_level.create_copy()
		level = current_level
		_title.text = "Edit Level Settings"
		_confirm_button.disabled = false
	
	_init_level_info()


## Uses current level to set initial values for the settings
func _init_level_info():
	_name_line_edit.text = level.name
	_song_file_line_edit.text = level.song_audio_path
	if level.length is float:
		_length_spin_box.value = level.length
	_bpm_spin_box.value = level.initial_bpm
	_game_type.select(level.micro_game_id)


## Returns true if the current info can create a valid level
func _is_valid_info() -> bool:
	if not level: return false
	if level.song_audio_path == "": return false
	if level.length == null or level.length <= 0: return false
	if level.name == "": return false

	return true


## Called when a value has changed,
## verifies if confirm should be disabled
func _on_values_changed() -> void:
	if _is_valid_info():
		_confirm_button.disabled = false
	else:
		_confirm_button.disabled = true


## Adds micro games to game type dropdown list
func _init_game_types_panel() -> void:
	for i in range(len(Globals.MICRO_GAME_NAMES)):
		var game_name = Globals.MICRO_GAME_NAMES[i]
		_game_type.add_item(game_name, i)



# Inputs =============================

func _on_back_button_pressed():
	# TODO: maybe ask confirmation?
	exit.emit(current_level_copy)


func _on_confirm_button_pressed():
	confirmed.emit(level)
	


func _on_level_name_text_changed(new_text: String) -> void:
	var level_name = "My Level"
	if new_text != "": level_name = new_text
	level.name = level_name

	_on_values_changed()


func _on_pick_song_pressed():
	_song_file_dialog.visible = true

func _on_file_dialog_file_selected(song_path:String):
	# TODO: make sure song is valid
	level.song_audio_path = song_path
	_song_file_line_edit.text = song_path

	_on_values_changed()

func _on_level_length_value_changed(value:float):
	level.length = value
	_on_values_changed()


func _on_level_bpm_value_changed(value):
	level.initial_bpm = int(value)
	_on_values_changed()

func _on_game_type_item_selected(index):
	level.micro_game_id = index
	_on_values_changed()
