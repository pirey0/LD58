extends ProgressionStep


func get_display_title() -> String:
	return "New Heights"

func get_display_descr() -> String:
	return "Now that you have a basic grasp of the trade, reach %s total eval." % Util.format_money(Balancing.GOAL_NET_WORTH_1)

func begin_step():
	G.progression.trading_goods_tier_2 = true
	super()

func skip_step():
	G.progression.trading_goods_tier_2 = true
	super()
	
func _physics_process(delta: float) -> void:
	if G.progression.net_worth > Balancing.GOAL_NET_WORTH_1:
		finish()
