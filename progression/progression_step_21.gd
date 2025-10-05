extends ProgressionStep


func get_display_title() -> String:
	return "Monopoly"

func get_display_descr() -> String:
	return "Aquire every single public company."

func begin_step():
	super()

func skip_step():
	super()
	
func _physics_process(delta: float) -> void:
	for x in G.get_all_companies():
		if x is PublicCompany and not x.player_owned:
			return
	finish()
