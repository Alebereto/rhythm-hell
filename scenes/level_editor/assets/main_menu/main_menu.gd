extends MarginContainer

signal new_song_requested(song: Song)
signal load_song_requested


@export_category("Game Data")
# Song name
@export var _song_name: String = "My Song"
# Song audio file
@export_global_file("*.ogg") var _audio_source: String
# Initial BPM of song
@export_range(0,200) var _initial_bpm: int = 100



## Sets song data according to currently selected variables
func _get_new_song() -> Song:
	var song: Song = Song.new()

	song.data["name"] = _song_name
	song.data["initial_bpm"] = _initial_bpm
	song.audio_path = _audio_source

	return song



# Input signals ======================

func _on_load_song_button_pressed():
	load_song_requested.emit()


func _on_new_song_button_pressed():
	new_song_requested.emit(_get_new_song())
