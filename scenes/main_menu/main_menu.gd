extends Node3D

signal song_played( song )


@export_dir var _temp_song_path: String


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_play_pressed():
	# temporary load song
	var song = Level.new(_temp_song_path)
	song_played.emit(song)


func _on_exit_pressed():
	get_tree().quit()
