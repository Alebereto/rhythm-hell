extends Node

const SECONDS_IN_MINUTE = 60
const MILISECONDS_IN_SECOND = 1000000.0
const SHOULDER_RATIO = 3/4.0

# godot image
const GODOT_IMAGE = preload("res://icon.svg")



## Gets seconds, returns string of clock display MM:SS
func format_seconds(seconds: float) -> String:
	var minute = floor(seconds / float(SECONDS_IN_MINUTE))
	var second = floor(int(seconds) % SECONDS_IN_MINUTE)
	var pad = ""
	if second < 10: pad = "0"

	return "%s:%s%s" % [str(minute), pad, str(second)]


# For main menu ===============================================================================================

enum MENU_NAME{MAIN, CUSTOM_LEVELS, RESULTS_SCREEN}
class MainMenuLoadData:
	var _menu_name: Globals.MENU_NAME
	var _results_dict

	func _init(menu_name = Globals.MENU_NAME.MAIN, results_dict = null):
		_menu_name = menu_name
		_results_dict = results_dict
	
	func get_menu_name(): return _menu_name
	func get_results_dict(): return _results_dict



# For micro games =============================================================================================

# micro game indeces
enum MICRO_GAMES{ KARATE , MOLE_TURF, REMIX}
const MICRO_GAME_NAMES = ["Karate", "Mole Turf", "Remix"]

const HIDDEN_OBJECTS_GROUP_NAME = "hidden_in_menu"

# player enum
enum HAND {PUNCHER, HAMMER}

# karate projectiles enum
enum PROJECTILES{ROCK, BARREL}

# mole turf moles
enum MOLE_TYPES{NORMAL, FAST, SLOW}



# For level saving and loading ================================================================================

func get_custom_levels_path() -> String:
	if OS.has_feature("exported"):
		return OS.get_executable_path().get_base_dir() + "/CustomLevels"
	return "res://custom_levels"

const SAVE_FILE_NAME = "save.dat"
const AUDIO_FILE_NAME = "song.ogg"
const LEVEL_IMAGE_NAME = "cover.jpg"


## Gets path to level files, returns true if level is valid
func is_legal_level_path(_level_path: String) -> bool:
	# check if dat and ogg files exist in directory
	if FileAccess.file_exists(_level_path + "/" + SAVE_FILE_NAME) and \
	   FileAccess.file_exists(_level_path + "/" + AUDIO_FILE_NAME):
		return true
	# TODO: check if files are valid
	return false


## Gets array of levels from levels directory
func get_levels_data(levels_path: String) -> Array:
	var folders = DirAccess.get_directories_at(levels_path)

	var levels = []

	for folder in folders:
		var dir = levels_path +"/"+ folder
		if not is_legal_level_path(dir): continue

		# load level
		var level: Level = Level.new(dir)

		levels.append(level)
	
	return levels

func load_external_image( image_path: String ):
	var image = Image.load_from_file(image_path)
	var texture = ImageTexture.create_from_image(image)
	return texture


# Data structures ========================================================================================

class Queue:
	var _q: Array
	var _max_size

	func _init(max_len = INF):
		_q = []
		_max_size = max_len

	func add(item):
		if len(_q) >= _max_size: _q.pop_front()
		_q.push_back(item)
		
	func peek():
		return _q.front()
	
	func clear():
		_q.clear()


class Stack:
	var _s: Array
	var _max_size

	func _init(max_size = INF):
		_s = []
		_max_size = max_size
	
	func push(item):
		if size() >= _max_size: _s.pop_front()
		_s.push_back(item)
	
	func pop():
		return _s.pop_back()
	
	func clear():
		_s.clear()
	
	func size(): return len(_s)




# For level editor ======================================================================================

# level editor enums
enum ITEM_TYPE {NOTE, EVENT, MARKER}
enum TOOL {SELECT, DELETE, ITEM}

const DEFAULT_ITEM_NAME = "Default"



# Item infos =-=-=-=-=-=-=

class ItemInfo:
	var name: String = DEFAULT_ITEM_NAME
	var color: Color = Color.WHITE
	var b: float = 0

	func _init():
		pass
	
	# override
	func get_info_dict() -> Dictionary: return {}

class NoteInfo extends ItemInfo:
	
	var delay: float = 1
	var id: int = 0
	
	var layer: int = 1
	var rotated: bool = true

	var custom_data: Dictionary = {}

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


# Actions =-=-=-=-=-=

class EditorAction:
	var remember = true

	func _init(): pass
	
	func get_inverse_action(): pass


class PlaceItem extends EditorAction:
	var _item_info: ItemInfo

	func _init(item_info):
		_item_info = item_info
	
	func get_item_info(): return _item_info
	
	func get_inverse_action() -> DeleteItem:
		return DeleteItem.new(_item_info)

class DeleteItem extends EditorAction:
	var _item_info: ItemInfo

	func _init(item_info):
		_item_info = item_info

	func get_item_info(): return _item_info
	
	func get_inverse_action() -> PlaceItem:
		return PlaceItem.new(_item_info)
