extends Company
class_name ProducerCompany

var description:String:
	set(x):
		description = x
		%Descr.text = x

func _ready() -> void:
	money = 100000
	goods = 100000
	display_value = false
	super()

func get_actions() -> Array[ContextAction]:
	return [
		ContextAction.new(create_buy_line, preload("res://art/goods_icon.png"), null, Color.ORANGE_RED, "Buy Goods from producer for $%s" % Balancing.GOOD_VALUE_MID, Color.ORANGE),
	]

func create_buy_line():
	var connection :ConnectionGoodsTransfer = G.world.spawn_goods_connection(self, G.world.get_mouse_angle_to(position), null, 0.0)
	connection.good_value = Balancing.GOOD_VALUE_MID
	G.input.set_selected(connection)
	pass
