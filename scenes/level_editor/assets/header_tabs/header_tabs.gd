extends PanelContainer

signal save_song_requested
signal load_song_requested

enum BUTTON_ID{NEW, LOAD, SAVE, QUIT}

@onready var _file_tab: MenuButton = $Tabs/File
@onready var _edit_tab: MenuButton = $Tabs/Edit



func _ready():
	var file_tab_popup = _file_tab.get_popup()
	file_tab_popup.id_pressed.connect(_on_file_popup_pressed)
	for i in range(file_tab_popup.item_count):
		file_tab_popup.set_item_icon_max_width(i, 30)

	_edit_tab.get_popup().id_pressed.connect(_on_view_popup_pressed)


# Input signals =================================

func _on_file_popup_pressed(id: int) -> void:
	match id:
		BUTTON_ID.SAVE: save_song_requested.emit()	# save pressed
		BUTTON_ID.LOAD: load_song_requested.emit() 	# load pressed

func _on_view_popup_pressed(_id):
	pass
