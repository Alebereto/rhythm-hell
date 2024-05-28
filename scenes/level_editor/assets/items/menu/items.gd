extends HBoxContainer


signal switch_to_item(item: Globals.ItemInfo)


@onready var _item_settings = $ItemSettings
@onready var _item_selector = $ItemSelection


# Input functions =======================

func _on_choose_item(item: Globals.ItemInfo) -> void:
	var copied_item = item.clone()
	_item_settings.set_item_display(copied_item)
	switch_to_item.emit(copied_item)


func _on_item_settings_changed(item_info: Globals.ItemInfo) -> void:
	# TODO: deselect item in item selector ????
	switch_to_item.emit(item_info)

func _on_item_settings_saved(item_info: Globals.ItemInfo) -> void:
	_item_selector.add_item(item_info)



# Recieved Signals ======================

func _on_time_line_copied_item(item):

	pass


func _on_loaded_level_editor(song: Song):
	# load items from song
	pass



