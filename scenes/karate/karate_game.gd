extends GameController

@export_group("Cannon")
@export var _cannon: Node3D
@export_file("*.tscn") var _projectile_path: String

# Called when the node enters the scene tree for the first time.
func _ready():
	note_started.connect(_play_note)
	super()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _play_note(note: Dictionary):
	var fire_time = note["b"] - note["s"]
	_cannon.fire(_projectile_path, fire_time)

