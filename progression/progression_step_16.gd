extends ProgressionStep


func get_display_title() -> String:
	return "Heavy Hitter"

func get_display_descr() -> String:
	return "Aquire a company with an evaluation of at least %s." % Util.format_money(Balancing.GOAL_PURCHASE_1)

func begin_step():
	super()

func skip_step():
	super()
	
func _physics_process(delta: float) -> void:
	if G.progression.max_buyout >= Balancing.GOAL_PURCHASE_1:
		finish()
