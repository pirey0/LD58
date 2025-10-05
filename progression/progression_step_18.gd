extends ProgressionStep


func get_display_title() -> String:
	return "FORTUNE 500"

func get_display_descr() -> String:
	return "Aquire a Fortune 500 company. \n (>%s evaluation)" % Util.format_money(Balancing.GOAL_FORTUNE_500)

func begin_step():
	super()

func skip_step():
	super()
	
func _physics_process(delta: float) -> void:
	pass
	#TODO
