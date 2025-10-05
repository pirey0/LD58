extends ProgressionStep


func get_display_title() -> String:
	return "Suck it Elon"

func get_display_descr() -> String:
	return "Become the first Trilionair in the world."

func begin_step():
	super()

func skip_step():
	super()
	
func _physics_process(delta: float) -> void:
	if G.progression.net_worth > Balancing.GOAL_NET_WORTH_5:
		finish()
