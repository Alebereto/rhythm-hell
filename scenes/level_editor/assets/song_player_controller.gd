extends PanelContainer

@export var _song_player: SongPlayer

# Get refrences
@onready var song_name_label: Label = $VBoxContainer/SongName

@onready var current_time_label: Label = $VBoxContainer/TimeShower/Current
@onready var end_time_label: Label = $VBoxContainer/TimeShower/End
@onready var play_button: Button = $VBoxContainer/TimeShower/PlayButton

@onready var song_scroller: HSlider = $VBoxContainer/SongScroller


## Gets song name and song length in seconds, updates info on song player
func _init_info(song_name: String, song_length: float) -> void:
	song_name_label.text = song_name
	end_time_label.text = Globals.format_seconds(song_length)
	song_scroller.max_value = song_length


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if _song_player.is_playing():
		_update_visuals()

## Updates song info with current seconds from song player
func _update_visuals() -> void:
	var seconds = _song_player.current_raw_second
	song_scroller.value = seconds


func _on_play() -> void:
	# set play icon to button ============
	_song_player.play()

func _on_pause() -> void:
	# set pause icon to button =========
	_song_player.pause()

	

## Gets called when loading level to level editor or when making new level
func _set_song_stats(song: Song) -> void:
	_init_info(song.song_name, song.length)


# Input functions ================================

## Called when play button gets toggled
func _on_play_button_toggled(toggled_on: bool):
	if toggled_on: _on_play()
	else: _on_pause()

## Called when song scroller gets moved
func _on_song_scroller_drag_ended(seconds: float):
	_song_player.seek(seconds)


func _on_song_scroller_drag_started():
	_on_pause()


func _on_song_scroller_value_changed(seconds: float):
	current_time_label.text = Globals.format_seconds(seconds)
