extends ProgressionStep


func get_display_title() -> String:
	return "Going Private"

func get_display_descr() -> String:
	return "Loans will only take you so far. It's time to take it to the next step. \n Aquire a publicly traded company."

func begin_step():
	#TODO spawn in first few small companies
	super()

func skip_step():
	super()
	
func _physics_process(delta: float) -> void:
	if G.progression.aquired_public_company:
		finish()
