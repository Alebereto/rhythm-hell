@tool
extends EditorScript

'''
Editor tool that saves level made in level editor
'''

const SAVE_NAME = "save.dat"
const TRACK_NAME = "track.ogg"

# Level audio file
var track_path: String
# Level name
var song_name: String = "test"
# Initial BPM of song
var initial_bpm: int = 60
# Location to save song into
var songs_dir: String = "res://songs"


## Gets level information dictionary
func get_level_data(root: Node3D) -> Dictionary:
	# Ordered list of notes (by beat)
	var beat_list: Array = []
	
	var notes = root.find_child("Notes").get_children()
	
	for note: Node3D in notes:
		# make map of note info
		var beat = {
			"b": note.position.z # starting beat
		}
		# add to list
		beat_list.append(beat)
	
	var save_data = {
		"initial_bpm": initial_bpm,
		"beat_list": beat_list
	}
	
	return save_data

## Saves song in level editor scene
func save_song(root: Node3D) -> void:
	
	var save_data = get_level_data(root)
	var save_data_str = JSON.stringify(save_data)
	
	# make directory for song
	var save_dir = songs_dir + "/" + song_name
	# check if save directory exists
	if not DirAccess.dir_exists_absolute(save_dir):
		DirAccess.make_dir_absolute(save_dir)
	
	# save file
	var data_path = "%s/%s" %[save_dir, SAVE_NAME]
	var file = FileAccess.open(data_path, FileAccess.WRITE)
	file.store_string(save_data_str)
	file.close()

func _run():
	# Get scene and check if it is the level editor
	var root = get_scene()
	if root.name != "LevelEditor": return
	
	var time_line = root.find_child("TimeLine")
	save_song(time_line)
