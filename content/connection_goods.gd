extends Connection
class_name ConnectionGoodsTransfer

var time_to_next := 0.0
var good_value := 100.0
var modifier : Texture
var modifier_color : Color
var invert_on_completion := false

var max_amount := -1
var transfered_amount := 0

var closed := false
var active_transfers := 0
var taxable := true

func _ready() -> void:
	super()
	set_physics_process(false)

func on_connection_established():
	super()
	if invert_on_completion:
		var temp = source
		var tempa = source_angle
		source = destination
		source_angle = destination_angle
		destination = temp
		destination_angle = temp
	
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
	
	if source.goods < 1 or destination.money < good_value:
		close()
		return
	
	time_to_next = 1.0
	source.change_goods(-1)
	
	var inst : ConnectionItem = preload("res://content/connection_item_good.tscn").instantiate()
	inst.setup(self)
	inst.target_reached.connect(on_target_reached)
	G.world.add_child(inst,true)
	inst.tree_exiting.connect(reduce_transfer_counter)
	if modifier:
		inst.set_modifier(modifier, modifier_color)
	
	active_transfers += 1
	transfered_amount += 1
	
	if max_amount > 0.0 and transfered_amount > max_amount:
		close()

func on_target_reached():
	destination.change_goods(1)
	destination.change_money(-good_value, true)
	
	var inst : ConnectionItem = preload("res://content/connection_item_money.tscn").instantiate()
	inst.value = good_value
	inst.setup(self)
	inst.reversed = true
	inst.target_reached.connect(on_money_target_reached)
	G.world.add_child(inst,true)
	active_transfers += 1
	inst.tree_exiting.connect(reduce_transfer_counter)
	
func on_money_target_reached():
	source.change_money(good_value,taxable)

func reduce_transfer_counter():
	active_transfers -= 1
	pass

func close():
	closed = true
