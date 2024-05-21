extends GameController

@export var cannon: Node3D

signal fire_cannon

# Called when the node enters the scene tree for the first time.
func _ready():
	super()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func connect_signals():
	var right_controller: XRController3D = player.find_child("RightController")
	var left_controller: XRController3D = player.find_child("LeftController")

	right_controller.button_pressed.connect(_on_right_button_press)

func _input(event):
	if event.is_action_pressed("test-shoot"):
		print("Shooting!!")
		_shoot_cannon()

func _shoot_cannon():
	fire_cannon.emit("res://scenes/karate/assets/projectiles/projectile.tscn", 1)

func _on_right_button_press(button: String):
	print("Pressed %s" %button)
	_shoot_cannon()
