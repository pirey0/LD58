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

func get_actions() -> Array:
	var out = []
	out.append(ContextAction.new(create_buy_line.bind(0), preload("res://art/goods_icon.png"), preload("res://art/up.png"), Color.GREEN, "Buy Goods for $%s (HIGH)" % Balancing.GOOD_VALUE_HIGH, Color.GREEN),)
	
	if G.progression.trading_goods_tier_2:
			out.append(ContextAction.new(create_buy_line.bind(1), preload("res://art/goods_icon.png")\
			,  preload("res://art/up.png"), Color.GREEN, "Buy %s Goods for $%s (HIGH)" % [Balancing.TIER_2_MULT, Balancing.GOOD_VALUE_HIGH*Balancing.TIER_2_MULT], Color.ORANGE))

	if G.progression.trading_goods_tier_3:
			out.append(ContextAction.new(create_buy_line.bind(2), preload("res://art/goods_icon.png")\
			,  preload("res://art/up.png"), Color.GREEN, "Buy %s Goods for $%s (HIGH)" % [Balancing.TIER_3_MULT, Balancing.GOOD_VALUE_HIGH*Balancing.TIER_3_MULT], Color.RED))

	return out 

func create_buy_line(tier):
	var connection :ConnectionGoodsTransfer = G.world.spawn_goods_connection(self, G.world.get_mouse_angle_to(position), null, 0.0)
	connection.modifier = preload("res://art/up.png")
	connection.modifier_color = Color.GREEN
	connection.good_per_trade = Balancing.get_tier_mult(tier)
	connection.good_value = Balancing.GOOD_VALUE_HIGH * Balancing.get_tier_mult(tier)
	connection.connection_established.connect(on_line_created)
	G.input.set_selected(connection)
	pass

func on_line_created():
	G.progression.bought_goods = true
