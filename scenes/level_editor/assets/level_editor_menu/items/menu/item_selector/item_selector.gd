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
	var copied_item = Globals.clone_item_info(item_info)

	match copied_item.type:
		Globals.ITEM_TYPE.NOTE:
			_notes.append(copied_item)
			_notes_item_list.add_item(copied_item.name)
		Globals.ITEM_TYPE.EVENT:
			_events.append(copied_item)
			_events_item_list.add_item(copied_item.name)
		Globals.ITEM_TYPE.MARKER:
			_markers.append(copied_item)
			_markers_item_list.add_item(copied_item.name)



## Change visuals to deselect all items
func deselect_all() -> void:
	_notes_item_list.deselect_all()
	_events_item_list.deselect_all()
	_markers_item_list.deselect_all()



# functions used for loading and saving items to save.dat

func get_items_dict() -> Dictionary:
	var items_dict = {
		"notes": _items_to_dicts(_notes.slice(1)),
		"events": _items_to_dicts(_events),
		"markers": _items_to_dicts(_markers)
	}
	return items_dict

func set_from_items_dict(items_dict: Dictionary) -> void:
	var notes_info = _dicts_to_items(items_dict["notes"], Globals.ITEM_TYPE.NOTE)
	for note_info in notes_info:
		add_item(note_info)

	var events_info = _dicts_to_items(items_dict["events"], Globals.ITEM_TYPE.EVENT)
	for event_info in events_info:
		add_item(event_info)

	var markers_info = _dicts_to_items(items_dict["markers"], Globals.ITEM_TYPE.MARKER)
	for marker_info in markers_info:
		add_item(marker_info)


func _items_to_dicts(items: Array) -> Array:
	var dict_arr: Array = []
	for item in items:
		dict_arr.append(item.get_info_dict())
	return dict_arr

func _dicts_to_items(dicts: Array, type: Globals.ITEM_TYPE):
	var items_arr = []
	for dict in dicts:
		var item
		match type:
			Globals.ITEM_TYPE.NOTE: item = Globals.NoteInfo.new(dict)
			# Globals.ITEM_TYPE.EVENT: item = Globals.EventInfo.new(dict)
			# Globals.ITEM_TYPE.MARKER: item = Globals.MarkerInfo.new(dict)
		items_arr.append(item)
	return items_arr





# Input signals ========================

func _on_notes_item_selected(index):
	_select_item(_notes[index])


func _on_events_item_selected(index):
	_select_item(_events[index])


func _on_markers_item_selected(index):
	_select_item(_markers[index])

