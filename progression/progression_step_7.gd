extends ProgressionStep


func get_display_title() -> String:
	return "Fiscal Year End"

func get_display_descr() -> String:
	return "You are approaching the end of the year. At the end of every year taxes and debt are collected. If a company is in debt a this time it will go bankrupt."

func begin_step():
	G.progression.year_cycle_completable = true
	spawn_irs()
	super()

func spawn_irs():
	var pos = get_tree().get_first_node_in_group("main_company").position
	var government :Company = G.world.spawn_company_at(pos + Vector2(0,-1400), "IRS", preload("res://content/government_company.tscn"))
	government.description = "National Tax Authority"
	government.size_mult = 4.0
	government.circle_color = Color.NAVY_BLUE
	government.apply_size()

func skip_step():
	super()
	G.progression.year_cycle_completable = true
	spawn_irs()
	
func _physics_process(delta: float) -> void:
	if G.progression.year_finished:
		finish()
	
