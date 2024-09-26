extends PanelContainer

# file signals
signal new_level
signal load_level
signal save_level

# edit signals
signal undo
signal redo

enum FILE_BUTTON_ID{NEW, LOAD, SAVE, QUIT}

@onready var _file_tab: MenuButton = $Tabs/File
@onready var _edit_tab: MenuButton = $Tabs/Edit



func _ready():
	var file_tab_popup = _file_tab.get_popup()
	file_tab_popup.id_pressed.connect(_on_file_popup_pressed)
	for i in range(file_tab_popup.item_count):
		file_tab_popup.set_item_icon_max_width(i, 30)

	_edit_tab.get_popup().id_pressed.connect(_on_view_popup_pressed)


func set_undo_state(state: bool):
	pass
func set_redo_state(state: bool):
	pass



# Input signals =================================

func _on_file_popup_pressed(id: int) -> void:
	match id:
		FILE_BUTTON_ID.SAVE: save_level.emit()	# save pressed
		FILE_BUTTON_ID.LOAD: load_level.emit() 	# load pressed

func _on_view_popup_pressed(_id):
	pass
