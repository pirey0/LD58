extends Connection
class_name ConnectionTransfer

var time_to_next := 0.0
var packet_size := 100.0

var max_amount := -1
var transfered_amount := 0.0

var closed := false
var active_transfers := 0
var taxable := true

func _ready() -> void:
	super()
	set_physics_process(false)

func on_connection_established():
	super()
	set_physics_process(true)
	pass
	

func _physics_process(delta: float) -> void:
	update_sending(delta)

func update_sending(delta):
	if freeing:
		return
	
	if closed:
		if active_transfers <= 0:
			vanish()
		return
	
	if time_to_next > 0.0:
		time_to_next -= delta
		return
	
	if source.money < packet_size:
		close()
		return
	
	time_to_next = 1.0
	source.change_money(-packet_size, taxable)
	
	var inst : ConnectionItem = preload("res://content/connection_item_money.tscn").instantiate()
	inst.value = packet_size
	inst.setup(self)
	inst.target_reached.connect(on_target_reached)
	G.world.add_child(inst,true)
	active_transfers += 1
	inst.tree_exiting.connect(reduce_transfer_counter)
	
	transfered_amount += packet_size
	
	if max_amount > 0.0 and transfered_amount > max_amount:
		close()

func on_target_reached():
	destination.change_money(packet_size,taxable)

func reduce_transfer_counter():
	active_transfers -= 1

func close():
	closed = true
