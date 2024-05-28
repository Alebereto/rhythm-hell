extends TabContainer

signal chose_item(item: Globals.ItemInfo)


@onready var _notes_item_list: ItemList = $Notes
@onready var _events_item_list: ItemList = $Events
@onready var _markers_item_list: ItemList = $Markers


var _notes: Array[Globals.NoteInfo] = []
var _events: Array[Globals.EventInfo] = []
var _markers: Array[Globals.MarkerInfo] = []



# Called when the node enters the scene tree for the first time.
func _ready():
	set_default_items()



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


func _choose_item(item_info: Globals.ItemInfo) -> void:
	chose_item.emit(item_info)



func set_default_items() -> void:
	var note_info = Globals.NoteInfo.new()
	add_item(note_info)

func get_items_dict() -> Dictionary:
	var items_dict = {
		"_notes": _notes,
		"_events": _events,
		"_markers": _markers
	}
	return items_dict

func set_items_dict(items_dict: Dictionary) -> void:
	_notes = items_dict["_notes"]
	_events = items_dict["_events"]
	_markers = items_dict["_markers"]



# Recieved Signals =======================


func _on_item_settings_edited_values() -> void:
	# TODO: deselect current item or something =--=-=-=-==-=-=-==-=
	pass

# Input Functions ========================

func _on_notes_item_selected(index):
	_choose_item(_notes[index])


func _on_events_item_selected(index):
	_choose_item(_events[index])


func _on_markers_item_selected(index):
	_choose_item(_markers[index])



func _on_time_line_copied_item(item):
	pass # Replace with function body.
