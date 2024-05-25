extends PanelContainer

@export var _song_player: SongPlayer
@export var _level_editor: Node2D

# Get refrences
@onready var song_name_label: Label = $VBoxContainer/SongName

@onready var current_time_label: Label = $VBoxContainer/TimeShower/Current
@onready var end_time_label: Label = $VBoxContainer/TimeShower/End
@onready var play_button: Button = $VBoxContainer/TimeShower/PlayButton

@onready var song_scroller: HSlider = $VBoxContainer/SongScroller


signal play
signal pause
signal seek(value: float)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	_update_visuals()

func _update_visuals() -> void:
	var seconds = _song_player.current_second
	current_time_label.text = Globals.format_seconds(seconds)
	song_scroller.value = seconds

func set_song_stats() -> void:
	pass

func _on_play() -> void:
	# set play icon to button ============
	play.emit()

func _on_pause() -> void:
	# set pause icon to button =========
	pause.emit()


## Called when play button gets toggled
func _on_play_button_toggled(toggled_on):
	if toggled_on: _on_play()
	else: _on_pause()


func _on_song_scroller_drag_ended(value_changed):
	seek.emit(value_changed)
