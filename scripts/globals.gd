extends Node


enum MICRO_GAMES{ REMIX=-1, KARATE=0 , SPACE_SHOOTER=1, }
const MICRO_GAME_NAMES = ["Karate", "Space Shooter", "Remix"]

# level editor enums
enum ITEM_TYPE {NOTE, EVENT, MARKER}
enum TOOL {SELECT, DELETE, ITEM}

# player enum
enum HAND {PUNCHER}

# karate projectiles enum
enum PROJECTILES{ROCK, BARREL}


# Level loading
const LEVELS_DIR = "res://levels/"
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
func is_legal_level_path(_level_path: String) -> bool:
	# check if dat and ogg files exist in directory ================
	return true


## Gets pairs of [level, image_path] for every level in levels directory
func get_levels_data() -> Array:
	var folders = DirAccess.get_directories_at(LEVELS_DIR)

	var levels_data = []

	for folder in folders:
		var dir = LEVELS_DIR + folder

		if not is_legal_level_path(dir): continue
		var level: Level = Level.new(dir)
		# TODO: get level image path
		levels_data.append([level, null])
	
	return levels_data




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

	func _init():
		pass
	
	# override
	func get_info_dict() -> Dictionary: return {}


class NoteInfo extends ItemInfo:
	
	var delay: float = 1
	var id: int = 0
	
	var layer: int = 1
	var color: Color = Color.WHITE
	var rotated: bool = true

	var custom_data: Dictionary = {}

	var b: float = 0
	var s: float = 0

	func _init(note= null):
		# load data from other note
		if note is NoteInfo:
			set_from_dict(note.get_info_dict())

		# load data from save file
		if note is Dictionary:
			set_from_dict(note)


	func get_info_dict() -> Dictionary:
		var note_data = {
			"name": name,
			"delay": delay,
			"id": id,
			"layer": layer,
			"color": color.to_html(),
			"rotated": rotated,
			"custom_data": custom_data,
			"b": b,
			"s": s,
		}
		return note_data

	func set_from_dict(item: Dictionary):
		
		name = item["name"]
		delay = item["delay"]
		id = item["id"]
		layer = item["layer"]
		color = Color(item["color"])
		rotated = item["rotated"]
		custom_data = item["custom_data"]
		b = item["b"]
		s = item["s"]


class EventInfo extends ItemInfo:
	func _init():
		pass
	

class MarkerInfo extends ItemInfo:
	func _init():
		pass


func items_to_dicts(items: Array) -> Array[Dictionary]:
	var dict_arr: Array[Dictionary] = []
	for item: Globals.ItemInfo in items:
		dict_arr.append(item.get_info_dict())
	return dict_arr

func dicts_to_items(dicts: Array, type: ITEM_TYPE):
	var items_arr = []
	for dict in dicts:
		var item
		match type:
			ITEM_TYPE.NOTE: item = Globals.NoteInfo.new(dict)
			# ITEM_TYPE.EVENT: item = Globals.EventInfo.new(dict)
			# ITEM_TYPE.MARKER: item = Globals.MarkerInfo.new(dict)
		items_arr.append(item)
	return items_arr


func clone_item_info(item_info: ItemInfo) -> ItemInfo:
	var cloned_item_info = null
	
	if item_info is NoteInfo: 		cloned_item_info = NoteInfo.new(item_info)
	# elif item_info is EventInfo: 	cloned_item_info = EventInfo.new(item_info)
	# elif item_info is MarkerInfo: 	cloned_item_info = MarkerInfo.new(item_info)

	return cloned_item_info
