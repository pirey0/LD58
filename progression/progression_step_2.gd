extends ProgressionStep


func get_display_title() -> String:
	return "First Trade"

func get_display_descr() -> String:
	return "Setup a trading line from the Retailer to your company."

func begin_step():
	super()
	spawn_goods()
	
func spawn_goods():
	var pos = get_tree().get_first_node_in_group("main_company").position
	var goods :Company = G.world.spawn_company_at(pos + Vector2(1000,0), "Retailer", preload("res://content/producer_company.tscn"))
	goods.description = "Buys and Sells Goods"
	goods.size_mult = 2.5
	goods.circle_color = Color.AQUA
	goods.apply_size()

func skip_step():
	super()
	spawn_goods()

func _physics_process(delta: float) -> void:
	if G.progression.bought_goods:
		finish()
