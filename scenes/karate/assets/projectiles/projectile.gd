class_name Projectile extends RigidBody3D


signal hit(dest_beat: float)


var destination_beat: float = -1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_hit():
	hit.emit(destination_beat)
