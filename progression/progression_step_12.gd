extends ProgressionStep


func get_display_title() -> String:
	return "Economy of Scale"

func get_display_descr() -> String:
	return "You have now unlocked higher volume goods trading options. \nReach $s total value." % Util.format_money(Balancing.GOAL_NET_WORTH_2)

func begin_step():
	G.progression.trading_goods_tier_3 = true
	super()

func skip_step():
	G.progression.trading_goods_tier_3 = true
	super()
	
func _physics_process(delta: float) -> void:
	if G.progression.net_worth > Balancing.GOAL_NET_WORTH_2:
		finish()
