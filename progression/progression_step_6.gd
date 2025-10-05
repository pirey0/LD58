extends ProgressionStep


func get_display_title() -> String:
	return "(Illusionary) Profits"

func get_display_descr() -> String:
	return "There has to be a way to generate profit... Or at least the illusion of it. Reach at least $1000 in profit in your subsidiary."

func begin_step():
	G.progression.year_cycle_active = true
	super()

func skip_step():
	super()
	G.progression.year_cycle_active = true
	
func _physics_process(delta: float) -> void:
	for x : Company in G.get_all_player_companies():
		if not x.is_in_group("main_company") and x.new_revenue > 1000:
			finish()
	
