extends ProgressionStep


func get_display_title() -> String:
	return "New Beginning"

func get_display_descr() -> String:
	return "Found your first company.\n\nRight click to interact.\nMiddle mouse drag to pan.\n"

func begin_step():
	super()
		
	G.progression.start_time = Time.get_unix_time_from_system()
	spawn_you()
	
func spawn_you():
	var pos = G.world.screen_to_world_pos(get_window().size * 0.5)
	var root :Company = G.world.spawn_company_at(pos, "YOU", preload("res://companies/company_start.tscn"))
	root.size_mult = 0.5
	root.apply_size()
	
	
	return root

func skip_step():
	super()
	G.progression.start_time = Time.get_unix_time_from_system()
	var you = spawn_you()
	you.create_first_company()
	G.progression.evaluation_visible = true

func finish():
	super()
	create_tween().tween_callback(func(): G.progression.evaluation_visible=true).set_delay(5.0)

func _physics_process(delta: float) -> void:
	if G.progression.root_exists:
		finish()
