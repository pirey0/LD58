extends Connection
class_name ConnectionGoodsTransfer

var time_to_next := 0.0
var good_per_trade := 1
var good_value := 100.0
var modifier : Texture
var modifier_color : Color
var invert_on_completion := false

var max_amount := -1
var transfered_amount := 0

var taxable := true

const TIMEOUT_TIME := 5.0
var cancel_from_timeout := TIMEOUT_TIME

func _ready() -> void:
	super()

func is_target_valid(target):
	var base = super(target)
	if not base:
		return false
	
	if not target is ProducerCompany and not target.player_owned:
		return false
	return true

func on_connection_established():
	super()
	if invert_on_completion:
		var temp = source
		var tempa = source_angle
		source = destination
		source_angle = destination_angle
		destination = temp
		destination_angle = temp
	
	pass
	

func _physics_process(delta: float) -> void:
	if connected:
		update_sending(delta)
	else:
		update_closure()
	

func update_sending(delta):
	if freeing:
		return
	
	update_closure()
	if closed:
		return
		
	if time_to_next > 0.0:
		time_to_next -= delta
		return
	
	if source.goods < good_per_trade or destination.money < good_value:
		cancel_from_timeout-= delta
		if cancel_from_timeout < 0.0:
			close()
		return
	
	cancel_from_timeout = TIMEOUT_TIME
	time_to_next = 1.0
	source.change_goods(-good_per_trade)
	
	var inst := spawn_item( preload("res://content/connection_item_good.tscn"))
	inst.target_reached.connect(on_target_reached)
	if modifier:
		inst.set_modifier(modifier, modifier_color)
	transfered_amount += good_per_trade
	
	if max_amount > 0.0 and transfered_amount >= max_amount:
		close()


func on_target_reached():
	destination.change_goods(good_per_trade)
	destination.change_money(-good_value, true)
	
	var inst := spawn_item(preload("res://content/connection_item_money.tscn"))
	inst.target_reached.connect(on_money_target_reached)
	inst.value = good_value
	inst.reversed = true
	
func on_money_target_reached():
	source.change_money(good_value,taxable)
