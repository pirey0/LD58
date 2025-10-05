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
	var out = []
	out.append(ContextAction.new(create_buy_line, preload("res://art/goods_icon.png"), null, Color.ORANGE_RED, "Buy Goods from retailer for $%s" % Balancing.GOOD_VALUE_MID, Color.GREEN),)
	
	if G.progression.trading_goods_tier_2:
			out.append(ContextAction.new(create_buy_line, preload("res://art/goods_icon.png")\
			, null, Color.ORANGE_RED, "Buy %s Goods from retailer for $%s" % [Balancing.TIER_2_MULT, Balancing.GOOD_VALUE_MID*Balancing.TIER_2_MULT], Color.GREEN))
	
	return out 

func create_buy_line():
	var connection :ConnectionGoodsTransfer = G.world.spawn_goods_connection(self, G.world.get_mouse_angle_to(position), null, 0.0)
	connection.good_value = Balancing.GOOD_VALUE_MID
	connection.connection_established.connect(on_line_created)
	G.input.set_selected(connection)
	pass

func on_line_created():
	G.progression.bought_goods = true
