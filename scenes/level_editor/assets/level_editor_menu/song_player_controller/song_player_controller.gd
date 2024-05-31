extends PanelContainer


signal scroller_value_changed(value: float)

signal played
signal paused
signal seeked(seconds: float)


@export var _song_player: SongPlayer	# maybe change get seconds to request to parent??

var _button_state_paused: bool

@export_category("Customize")
@export_file("*.png") var _play_icon: String
@export_file("*.png") var _pause_icon: String

var _play_texture: ImageTexture
var _pause_texture: ImageTexture

# Get refrences
@onready var _song_name_label: Label = $VBoxContainer/SongName
@onready var _current_time_label: Label = $VBoxContainer/TimeShower/Current
@onready var _end_time_label: Label = $VBoxContainer/TimeShower/End
@onready var _play_button: Button = $VBoxContainer/TimeShower/PlayButton
@onready var _song_scroller: HSlider = $VBoxContainer/SongScroller



func _ready():
	_load_textures()
	_set_button_state(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not _button_state_paused:
		var current_second = _song_player.current_raw_second

		_update_visuals(current_second)



func _load_textures() -> void:
	var play_image = Image.load_from_file(_play_icon)
	var pause_image = Image.load_from_file(_pause_icon)

	_play_texture = ImageTexture.create_from_image(play_image)
	_pause_texture = ImageTexture.create_from_image(pause_image)


## Updates song info with current seconds from song player
func _update_visuals(seconds: float) -> void:
	_song_scroller.value = seconds
	_current_time_label.text = Globals.format_seconds(seconds)


## Gets song name and song length in seconds, updates static info on song player
func _init_info(song_name: String, song_length: float) -> void:
	_song_name_label.text = song_name
	_end_time_label.text = Globals.format_seconds(song_length)
	_song_scroller.max_value = song_length



## Gets called when loading level editor menu
func load_song(song: Song):
	_init_info(song.song_name, song.length)


func on_time_marker_moved(second: float) -> void:
	if not _button_state_paused: _on_pause()
	_on_seek(second)
	_update_visuals(second)




func _on_play() -> void:
	_set_button_state(false)
	played.emit()

func _on_pause() -> void:
	_set_button_state(true)
	paused.emit()

func _on_seek(second: float) -> void:
	seeked.emit(second)


func _set_button_state(is_paused: bool) -> void:
	_button_state_paused = is_paused

	if is_paused: _play_button.icon = _play_texture
	else: 	   	  _play_button.icon = _pause_texture



func on_song_end() -> void:
	_set_button_state(true)



# Input signals ================================


func _on_song_scroller_drag_ended(_value_changed: bool):
	_on_seek(_song_scroller.value)


func _on_song_scroller_drag_started():
	_on_pause()


## Called every time the time scroller changes values
func _on_song_scroller_value_changed(seconds: float):
	scroller_value_changed.emit(seconds)


func _on_play_button_pressed():
	if _button_state_paused: _on_play()
	else: _on_pause()

