extends TabContainer

signal item_selected(item_info: Globals.ItemInfo)

enum MENUS{NOTES, EVENTS, MARKERS}
const ITEM_TEXTURES = [preload("res://assets/icons/item.png"),
					   preload("res://assets/icons/event.png"),
					   preload("res://assets/icons/marker.png")]
const UNROTATED_NOTE_TEXTURE = preload("res://assets/icons/square.png")


# Item lists
@onready var _notes_item_list: ItemList = $Notes
@onready var _events_item_list: ItemList = $Events
@onready var _markers_item_list: ItemList = $Markers

# ItemInfo arrays
var _notes: Array[Globals.NoteInfo] = []
var _events: Array[Globals.EventInfo] = []
var _markers: Array[Globals.MarkerInfo] = []

var current_menu: MENUS:
	get: return current_tab as MENUS


func clear_items():
	_notes = []
	_notes_item_list.clear()
	_events = []
	_events_item_list.clear()
	_markers = []
	_markers_item_list.clear()


func add_default_items() -> void:
	add_item(Globals.NoteInfo.new())
	add_item(Globals.EventInfo.new())
	add_item(Globals.MarkerInfo.new())

func _select_item(item_info: Globals.ItemInfo) -> void:
	item_selected.emit(item_info)


## Given array of item_info and name, return index of item with given name.
## returns -1 if not present.
func _find_item_in(arr: Array, item_name: String) -> int:
	for i in range(len(arr)):
		if arr[i].name == item_name: return i
	return -1
	

func select_default() -> void:
	_notes_item_list.select(0)
	_on_notes_item_selected(0)

func add_item(item_info: Globals.ItemInfo) -> void:

	var copied_item = Globals.clone_item_info(item_info)
	var item_arr: Array
	var item_list: ItemList
	var item_texture: Texture

	# set values according to item type
	if copied_item is Globals.NoteInfo:
		item_arr = _notes
		item_list = _notes_item_list
		if copied_item.rotated: item_texture = ITEM_TEXTURES[MENUS.NOTES]
		else: 					item_texture = UNROTATED_NOTE_TEXTURE
	elif copied_item is Globals.EventInfo:
		item_arr = _events
		item_list = _events_item_list
		item_texture = ITEM_TEXTURES[MENUS.EVENTS]
	elif copied_item is Globals.MarkerInfo:
		item_arr = _markers
		item_list = _markers_item_list
		item_texture = ITEM_TEXTURES[MENUS.MARKERS]
	else:
		return
	
	var arr_idx: int = _find_item_in(item_arr, copied_item.name)

	# if default item is present and current item has name default, return
	if arr_idx == 0 and len(item_arr) > 0: return
	# if item is not in array
	elif arr_idx <= -1:
		item_arr.append(copied_item)
		var idx = item_list.add_item(copied_item.name, item_texture)
		item_list.set_item_icon_modulate(idx, copied_item.color)
	# item is in array, replace it
	else:
		item_arr[arr_idx] = copied_item
		item_list.set_item_icon_modulate(arr_idx, copied_item.color)

func remove_item(idx: int, menu_id: MENUS) -> void:
	if idx <= 0: return # cannot remove default item
	match menu_id:
		MENUS.NOTES:
			if idx >= len(_notes): return
			_notes.remove_at(idx)
			_notes_item_list.remove_item(idx)
		MENUS.EVENTS:
			if idx >= len(_events): return
			_events.remove_at(idx)
			_events_item_list.remove_item(idx)
		MENUS.MARKERS:
			if idx >= len(_markers): return
			_markers.remove_at(idx)
			_markers_item_list.remove_item(idx)



## Change visuals to deselect all items
func deselect_all() -> void:
	_notes_item_list.deselect_all()
	_events_item_list.deselect_all()
	_markers_item_list.deselect_all()



# functions used for loading and saving items to save.dat

func get_items_dict() -> Dictionary:
	var items_dict = {
		"notes": Globals.items_to_dicts(_notes.slice(1)),
		"events": Globals.items_to_dicts(_events.slice(1)),
		"markers": Globals.items_to_dicts(_markers.slice(1))
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

## Called when note has been selected
func _on_notes_item_selected(index: int) -> void:
	_select_item(_notes[index])

func _on_notes_item_clicked(index:int, _at_position:Vector2, mouse_button_index:int):
	if mouse_button_index == MouseButton.MOUSE_BUTTON_RIGHT:
		remove_item(index, MENUS.NOTES)


## Called when event has been selected
func _on_events_item_selected(index: int) -> void:
	_select_item(_events[index])

func _on_events_item_clicked(index:int, _at_position:Vector2, mouse_button_index:int):
	if mouse_button_index == MouseButton.MOUSE_BUTTON_RIGHT:
		remove_item(index, MENUS.EVENTS)


## Called when marker has been selected
func _on_markers_item_selected(index: int) -> void:
	_select_item(_markers[index])

func _on_markers_item_clicked(index:int, _at_position:Vector2, mouse_button_index:int):
	if mouse_button_index == MouseButton.MOUSE_BUTTON_RIGHT:
		remove_item(index, MENUS.MARKERS)
