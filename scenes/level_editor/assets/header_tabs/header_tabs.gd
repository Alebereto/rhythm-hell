extends PanelContainer

# file signals
signal new_level
signal loaded_level
signal saved_level
signal quit

# edit signals
signal undo
signal redo
signal level_settings

enum FILE_BUTTON_ID{NEW, LOAD, SAVE, QUIT}
enum EDIT_BUTTON_ID{UNDO, REDO, LEVEL_SETTINGS}

@onready var _file_tab: MenuButton = $Tabs/File
@onready var _edit_tab: MenuButton = $Tabs/Edit



func _ready():
	var file_tab_popup: PopupMenu = _file_tab.get_popup() # get popup
	file_tab_popup.id_pressed.connect(_on_file_popup_pressed) # connect id pressed signal
	# set icon widths for file menu
	for i in range(file_tab_popup.item_count):
		file_tab_popup.set_item_icon_max_width(file_tab_popup.get_item_index(i), 30)

	_edit_tab.get_popup().id_pressed.connect(_on_edit_popup_pressed)


func set_file_menu_states(new_state: bool, load_state: bool, save_state: bool, quit_state: bool = true):
	var file_popup: PopupMenu = _file_tab.get_popup()
	file_popup.set_item_disabled(file_popup.get_item_index(FILE_BUTTON_ID.NEW), not new_state)
	file_popup.set_item_disabled(file_popup.get_item_index(FILE_BUTTON_ID.LOAD), not load_state)
	file_popup.set_item_disabled(file_popup.get_item_index(FILE_BUTTON_ID.SAVE ), not save_state)
	file_popup.set_item_disabled(file_popup.get_item_index(FILE_BUTTON_ID.QUIT), not quit_state)

func set_edit_menu_states(undo_state: bool, redo_state: bool, level_settings_state: bool):
	var edit_popup: PopupMenu = _edit_tab.get_popup()
	edit_popup.set_item_disabled(edit_popup.get_item_index(EDIT_BUTTON_ID.UNDO), not undo_state)
	edit_popup.set_item_disabled(edit_popup.get_item_index(EDIT_BUTTON_ID.REDO), not redo_state)
	edit_popup.set_item_disabled(edit_popup.get_item_index(EDIT_BUTTON_ID.LEVEL_SETTINGS), not level_settings_state)



# Input signals =================================

func _on_file_popup_pressed(id: int) -> void:
	match id:
		FILE_BUTTON_ID.NEW: new_level.emit()
		FILE_BUTTON_ID.SAVE: saved_level.emit()
		FILE_BUTTON_ID.LOAD: loaded_level.emit()
		FILE_BUTTON_ID.QUIT: quit.emit()

func _on_edit_popup_pressed(id):
	match id:
		EDIT_BUTTON_ID.UNDO: undo.emit()
		EDIT_BUTTON_ID.REDO: redo.emit()
		EDIT_BUTTON_ID.LEVEL_SETTINGS: level_settings.emit()
