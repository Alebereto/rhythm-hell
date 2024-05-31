extends TabContainer

signal item_selected(item: Globals.ItemInfo)


@onready var _notes_item_list: ItemList = $Notes
@onready var _events_item_list: ItemList = $Events
@onready var _markers_item_list: ItemList = $Markers


var _notes = []
var _events = []
var _markers = []



# Called when the node enters the scene tree for the first time.
func _ready():
	_set_default_items()


func _set_default_items() -> void:
	var note_info = Globals.NoteInfo.new()
	add_item(note_info)

func _select_item(item_info: Globals.ItemInfo) -> void:
	item_selected.emit(item_info)

	

func select_default() -> void:
	_notes_item_list.select(0)
	_on_notes_item_selected(0)

func add_item(item_info: Globals.ItemInfo) -> void:
	match item_info.type:
		Globals.ITEM_TYPE.NOTE:
			_notes.append(item_info)
			_notes_item_list.add_item(item_info.name)
		Globals.ITEM_TYPE.EVENT:
			_events.append(item_info)
			_events_item_list.add_item(item_info.name)
		Globals.ITEM_TYPE.MARKER:
			_markers.append(item_info)
			_markers_item_list.add_item(item_info.name)



# functions used for loading and saving items to save.dat

func get_items_dict() -> Dictionary:
	var items_dict = {
		"notes": _items_to_dict(_notes),
		"events": _items_to_dict(_events),
		"markers": _items_to_dict(_markers)
	}
	return items_dict

func set_items_dict(items_dict) -> void:
	if not items_dict is Dictionary: return
	_notes = _dict_to_items(items_dict["notes"], Globals.ITEM_TYPE.NOTE)
	_events = _dict_to_items(items_dict["events"], Globals.ITEM_TYPE.EVENT)
	_markers = _dict_to_items(items_dict["markers"], Globals.ITEM_TYPE.MARKER)


func _items_to_dict(items):
	var dict_arr = []
	for item in items:
		dict_arr.append(item.get_info_dict())
	return dict_arr

func _dict_to_items(dicts, type: Globals.ITEM_TYPE):
	var items_arr = []
	for dict in dicts:
		var item
		match type:
			Globals.ITEM_TYPE.NOTE: item = Globals.NoteInfo.new()
			Globals.ITEM_TYPE.EVENT: item = Globals.EventInfo.new()
			Globals.ITEM_TYPE.MARKER: item = Globals.MarkerInfo.new()
		item.set_from_dict(dict)
		items_arr.append(item)
	return items_arr





# Input signals ========================

func _on_notes_item_selected(index):
	_select_item(_notes[index])


func _on_events_item_selected(index):
	_select_item(_events[index])


func _on_markers_item_selected(index):
	_select_item(_markers[index])

