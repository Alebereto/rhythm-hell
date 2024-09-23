extends MarginContainer

signal new_level_requested(level: Level)
signal load_level_requested


@export_category("Game Data")
# Level name
@export var _level_name: String = "My Level"
# Level audio file
@export_global_file("*.ogg") var _audio_source: String
# Initial BPM of song
@export_range(0,200) var _initial_bpm: int = 100



## Sets song data according to currently selected variables
func _get_new_level() -> Level:
	var level: Level = Level.new()

	# TODO: get from menu

	level.name = _level_name
	level.initial_bpm = _initial_bpm
	level.song_audio_path = _audio_source

	return level



# Input signals ======================

func _on_new_level_button_pressed():
	# TODO: make sure _get_new_level() worked
	new_level_requested.emit(_get_new_level())


func _on_load_level_button_pressed():
	load_level_requested.emit()
