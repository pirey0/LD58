extends Company
class_name ProducerCompany

var description:String:
	set(x):
		description = x
		$Descr.text = x

func _ready() -> void:
	money = 100000
	goods = 100000
	super()

func get_actions() -> Array[ContextAction]:
	return [
		ContextAction.new(create_buy_line, preload("res://art/goods_icon.png"), null, Color.ORANGE_RED, "Buy Good for $300", Color.ORANGE),
	]

func create_buy_line():
	var connection :ConnectionGoodsTransfer = G.world.spawn_goods_connection(self, G.world.get_mouse_angle_to(position), null, 0.0)
	connection.good_value = 300
	G.input.set_selected(connection)
	pass

func change_money(amount, taxable):
	return

func change_goods(amount):
	return


func update_state():
	pass
