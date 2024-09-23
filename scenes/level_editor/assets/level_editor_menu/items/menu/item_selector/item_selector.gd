extends TabContainer

signal item_selected(item: Globals.ItemInfo)


@onready var _notes_item_list: ItemList = $Notes
@onready var _events_item_list: ItemList = $Events
@onready var _markers_item_list: ItemList = $Markers


var _notes: Array[Globals.NoteInfo] = []
var _events: Array[Globals.EventInfo] = []
var _markers: Array[Globals.MarkerInfo] = []



# Called when the node enters the scene tree for the first time.
func _ready():
	_set_default_items()


func _set_default_items() -> void:
	var note_info = Globals.NoteInfo.new()
	add_item(note_info)

	# TODO: add default other items

func _select_item(item_info: Globals.ItemInfo) -> void:
	item_selected.emit(item_info)

	

func select_default() -> void:
	_notes_item_list.select(0)
	_on_notes_item_selected(0)

func add_item(item_info: Globals.ItemInfo) -> void:

	# TODO: overwrite item with same name

	var copied_item = Globals.clone_item_info(item_info)

	if copied_item is Globals.NoteInfo:
			_notes.append(copied_item)
			_notes_item_list.add_item(copied_item.name)
	elif copied_item is Globals.EventInfo:
			_events.append(copied_item)
			_events_item_list.add_item(copied_item.name)
	elif copied_item is Globals.MarkerInfo:
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
		"notes": Globals.items_to_dicts(_notes.slice(1)),
		"events": Globals.items_to_dicts(_events),
		"markers": Globals.items_to_dicts(_markers)
	}
	return items_dict

func set_from_items_dict(items_dict: Dictionary) -> void:
	var notes_info = Globals.dicts_to_items(items_dict["notes"], Globals.ITEM_TYPE.NOTE)
	for note_info in notes_info:
		add_item(note_info)

	var events_info = Globals.dicts_to_items(items_dict["events"], Globals.ITEM_TYPE.EVENT)
	for event_info in events_info:
		add_item(event_info)

	var markers_info = Globals.dicts_to_items(items_dict["markers"], Globals.ITEM_TYPE.MARKER)
	for marker_info in markers_info:
		add_item(marker_info)





# Input signals ========================

func _on_notes_item_selected(index):
	_select_item(_notes[index])


func _on_events_item_selected(index):
	_select_item(_events[index])


func _on_markers_item_selected(index):
	_select_item(_markers[index])

