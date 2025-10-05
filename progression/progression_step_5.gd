extends ProgressionStep


func get_display_title() -> String:
	return "Subsidiaries"

func get_display_descr() -> String:
	return "You need to appear to be profitable. Create a subsidiary by right clicking on the parent company."

func begin_step():
	super()
	G.progression.can_create_subsidiary = true

func skip_step():
	super()
	G.progression.can_create_subsidiary = true

func _physics_process(delta: float) -> void:
	if G.progression.created_subsidiary:
		finish()
