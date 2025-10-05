extends ProgressionStep


func get_display_title() -> String:
	return "First Trade"

func get_display_descr() -> String:
	return "Setup a trading line from the Retailer to your company."

func begin_step():
	super()
	spawn_goods()
	
func spawn_goods():
	var pos = get_tree().get_first_node_in_group("main_company").position + Vector2(1200,0)
	G.world.spawn_retailer_at(pos)

func skip_step():
	super()
	spawn_goods()

func _physics_process(delta: float) -> void:
	if G.progression.bought_goods:
		finish()
