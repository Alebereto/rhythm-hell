extends PanelContainer


var _button_state_paused: bool = true

@export var _song_player: SongPlayer

@export_category("Customize")
@export_file("*.png") var _play_icon: String
@export_file("*.png") var _pause_icon: String

var _play_texture: ImageTexture
var _pause_texture: ImageTexture

# Get refrences
@onready var song_name_label: Label = $VBoxContainer/SongName
@onready var current_time_label: Label = $VBoxContainer/TimeShower/Current
@onready var end_time_label: Label = $VBoxContainer/TimeShower/End
@onready var play_button: Button = $VBoxContainer/TimeShower/PlayButton
@onready var song_scroller: HSlider = $VBoxContainer/SongScroller


signal song_controller_value_change(value: float)


func _ready():
	_load_textures()
	_connect_signals()
	_set_button_state(true)


func _load_textures() -> void:
	var play_image = Image.load_from_file(_play_icon)
	var pause_image = Image.load_from_file(_pause_icon)

	_play_texture = ImageTexture.create_from_image(play_image)
	_pause_texture = ImageTexture.create_from_image(pause_image)

func _connect_signals() -> void:
	_song_player.song_ended.connect(_on_song_end)

## Gets song name and song length in seconds, updates static info on song player
func _init_info(song_name: String, song_length: float) -> void:
	song_name_label.text = song_name
	end_time_label.text = Globals.format_seconds(song_length)
	song_scroller.max_value = song_length


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if _song_player.is_playing():
		_update_visuals(_song_player.current_raw_second)

## Updates song info with current seconds from song player
func _update_visuals(seconds: float) -> void:
	song_scroller.value = seconds


func _on_play() -> void:
	_set_button_state(false)
	_song_player.play()

func _on_pause() -> void:
	_set_button_state(true)
	_song_player.pause()


func _set_button_state(paused: bool) -> void:
	_button_state_paused = paused

	if paused: play_button.icon = _play_texture
	else: 	   play_button.icon = _pause_texture


# Signal recieved ================================	

## Gets called when loading level to level editor or when making new level
func _on_loaded_level_editor(song: Song):
	_init_info(song.song_name, song.length)


# Input functions ================================

## Called when song scroller gets moved
func _on_song_scroller_drag_ended(_value_changed: bool):
	_song_player.seek(song_scroller.value)


func _on_song_scroller_drag_started():
	_on_pause()


## Called every time the time scroller changes values
func _on_song_scroller_value_changed(seconds: float):
	song_controller_value_change.emit(seconds)
	current_time_label.text = Globals.format_seconds(seconds)


func _on_play_button_pressed():
	if _button_state_paused: _on_play()
	else: _on_pause()

func _on_song_end() -> void:
	_set_button_state(true)
