extends Control
class_name ConnectionItem

var connection : Connection
var vanished := false
var progress := 0.0
var speed := 0.25
var value

func setup(con : Connection, value):
	self.value = value
	connection = con
	con.on_vanish.connect(on_connection_vanish)
	

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if vanished:
		return
	
	progress += delta * speed
	if progress >= 1.0:
		on_target_reached()
		
	position = connection.get_pos_at(progress)
	
func on_target_reached():
	connection.destination.change_money(value)
	vanish()

func on_connection_vanish():
	vanish()

func vanish():
	if vanished:
		return
	vanished = true
	queue_free()
	
