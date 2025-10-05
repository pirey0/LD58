extends ProgressionStep


func get_display_title() -> String:
	return "Going Private"

func get_display_descr() -> String:
	return "Loans will only take you so far. It's time to take it to the next step. \n Aquire a publicly traded company."

func begin_step():
	spawn_first_companies()
	super()

func spawn_first_companies():
	G.progression.spawn_companies(10)

func skip_step():
	spawn_first_companies()
	super()
	
func _physics_process(delta: float) -> void:
	if G.progression.aquired_public_company:
		finish()
