extends PanelContainer

signal save_song_requested
signal load_song_requested


@onready var _file_tab: MenuButton = $Tabs/File
@onready var _view_tab: MenuButton = $Tabs/View



func _ready():
	_file_tab.get_popup().id_pressed.connect(_on_file_popup_pressed)
	_view_tab.get_popup().id_pressed.connect(_on_view_popup_pressed)


# Input signals =================================

func _on_file_popup_pressed(id: int) -> void:
	match id:
		1: save_song_requested.emit()	# save pressed
		2: load_song_requested.emit() # load pressed

func _on_view_popup_pressed(_id):
	pass
