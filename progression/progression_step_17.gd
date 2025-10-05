extends ProgressionStep


func get_display_title() -> String:
	return "Part of the 0.003%"

func get_display_descr() -> String:
	return "Reach a value of %s" % Util.format_money(Balancing.GOAL_NET_WORTH_4)

func begin_step():
	super()

func skip_step():
	super()
	
func _physics_process(delta: float) -> void:
	if G.progression.net_worth > Balancing.GOAL_NET_WORTH_4:
		finish()
