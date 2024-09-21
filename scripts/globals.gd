extends Node

enum ITEM_TYPE {NOTE, EVENT, MARKER}
enum TOOL {SELECT, DELETE, ITEM}

enum HAND {PUNCHER}

enum PROJECTILES{ROCK, BARREL}

const SAVE_FILE_NAME = "save.dat"
const AUDIO_FILE_NAME = "song.ogg"

const SECONDS_IN_MINUTE = 60
const MILISECONDS_IN_SECOND = 1000000.0


## Gets seconds, returns string of clock display MM:SS
func format_seconds(seconds: float) -> String:
	var minute = floor(seconds / float(SECONDS_IN_MINUTE))
	var second = floor(int(seconds) % SECONDS_IN_MINUTE)
	var pad = ""
	if second < 10: pad = "0"

	return "%s:%s%s" % [str(minute), pad, str(second)]

## Gets path to level files, returns true if level is valid
func legal_song_path(_song_path: String) -> bool:
	# check if dat and ogg files exist in directory ================
	return true



func clone_item_info(item_info: ItemInfo) -> ItemInfo:
	var cloned_item_info

	match item_info.type:
		ITEM_TYPE.NOTE: cloned_item_info = NoteInfo.new(item_info)
		ITEM_TYPE.EVENT: cloned_item_info = NoteInfo.new(item_info)
		ITEM_TYPE.MARKER: cloned_item_info = NoteInfo.new(item_info)
	return cloned_item_info



class Queue:
	var q: Array = []
	var max_length

	func _init(max_len = INF):
		max_length = max_len

	func add(item):
		if len(q) >= max_length: q.pop_front()
		q.push_back(item)
		
	func peek():
		return q.front()



class ItemInfo:
	var name: String = "default"
	var type: Globals.ITEM_TYPE

	func _init():
		pass


class NoteInfo extends ItemInfo:
	
	var delay: float = 1
	var id: int = 0
	var custom_data: Dictionary = {}

	var color: Color = Color.WHITE
	var rotated: bool = true

	func _init(note= null):
		# load data from other note
		if note is NoteInfo:
			set_from_dict(note.get_info_dict())

		# load data from save file
		if note is Dictionary:
			set_from_dict(note)
		
		type = Globals.ITEM_TYPE.NOTE


	func get_info_dict() -> Dictionary:
		var note_data = {
			"name": name,
			"delay": delay,
			"id": id,
			"custom_data": custom_data,
			"color": color.to_html(),
			"rotated": rotated
		}
		return note_data

	func set_from_dict(item: Dictionary):
		
		name = item["name"]
		delay = item["delay"]
		id = item["id"]
		custom_data = item["custom_data"]
		color = Color(item["color"])
		rotated = item["rotated"]


class EventInfo extends ItemInfo:
	func _init():
		pass
	

class MarkerInfo extends ItemInfo:
	func _init():
		pass
