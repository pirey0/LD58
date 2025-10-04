extends Connection
class_name ConnectionTransfer

var time_to_next := 0.0
var packet_size := 100.0

func _ready() -> void:
	super()
	set_physics_process(false)

func on_connection_established():
	set_physics_process(true)
	pass
	

func _physics_process(delta: float) -> void:
	update_sending(delta)

func update_sending(delta):
	if time_to_next > 0.0:
		time_to_next -= delta
		return
	
	if source.money < packet_size:
		return
	
	time_to_next = 1.0
	source.change_money(-packet_size)
	
	var inst : ConnectionItem = preload("res://content/connection_item.tscn").instantiate()
	inst.setup(self, packet_size)
	G.world.add_child(inst)
