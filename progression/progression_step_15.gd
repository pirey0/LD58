extends ProgressionStep


func get_display_title() -> String:
	return "The Big League"

func get_display_descr() -> String:
	return "It's time to start looking at the big players. \n Reach %s total value." % Util.format_money(Balancing.GOAL_NET_WORTH_3)

func begin_step():
	G.progression.spawn_companies(-1)
	G.progression.spawn_extra_utilities()
	super()

func skip_step():
	G.progression.spawn_companies(-1)
	G.progression.spawn_extra_utilities()
	super()
	
func _physics_process(delta: float) -> void:
	if G.progression.net_worth > Balancing.GOAL_NET_WORTH_3:
		finish()
