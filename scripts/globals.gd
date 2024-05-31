extends Node

enum ITEM_TYPE {NOTE, EVENT, MARKER}
enum TOOL {SELECT, DELETE, ITEM}

const SAVE_FILE_NAME = "save.dat"
const AUDIO_FILE_NAME = "song.ogg"

const SECONDS_IN_MINUTE = 60
const MILISECONDS_IN_SECOND = 1000000.0


func format_seconds(seconds: float) -> String:
	var minute = floor(seconds / float(SECONDS_IN_MINUTE))
	var second = floor(int(seconds) % SECONDS_IN_MINUTE)
	var pad = ""
	if second < 10: pad = "0"

	return "%s:%s%s" % [str(minute), pad, str(second)]

func legal_song_path(song_path: String) -> bool:
	# check if dat and ogg files exist in directory ================
	return true

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

	func _init():
		type = Globals.ITEM_TYPE.NOTE

	func clone() -> NoteInfo:
		var cloned_note = NoteInfo.new()
		cloned_note.set_from_dict(get_info_dict())
		return cloned_note

	func get_info_dict() -> Dictionary:
		var note_data = {
			"name": name,
			"delay": delay,
			"id": id,
			"custom_data": custom_data,
			"color": color,
			"rotated": rotated
		}
		return note_data

	func set_from_dict(item: Dictionary):
		name = item["name"]
		delay = item["delay"]
		id = item["id"]
		custom_data = item["custom_data"]
		color = item["color"]
		rotated = item["rotated"]


class EventInfo extends ItemInfo:
	func _init():
		pass
	

class MarkerInfo extends ItemInfo:
	func _init():
		pass
