extends HBoxContainer


signal item_switched(item_info: Globals.ItemInfo)


@onready var _item_settings = $ItemSettings
@onready var _item_selector = $ItemSelector


func load_level(level: Level):
	_item_selector.add_default_items()
	_item_selector.select_default()
	
	if level.items_dict != null:
		_item_selector.set_from_items_dict(level.items_dict)

func unload() -> void:
	_item_selector.clear_items()


func generate_dynamic_data(level: Level) -> void:
	level.items_dict = _item_selector.get_items_dict()

func on_time_line_copied_item(_item):
	# TODO: implement copies
	pass

# Input signals =======================

## Called by item selector when selecting an item
func _on_item_selected(item_info: Globals.ItemInfo) -> void:
	var copied_item = Globals.clone_item_info(item_info)
	_item_settings.set_item_display(copied_item)
	item_switched.emit(copied_item)


func _on_item_settings_changed(item_info: Globals.ItemInfo) -> void:
	# TODO: deselect item in item selector ????
	_item_selector.deselect_all()

	var copied_item = Globals.clone_item_info(item_info)
	item_switched.emit(copied_item)

func _on_item_settings_saved(item_info: Globals.ItemInfo) -> void:
	_item_selector.add_item(item_info)

