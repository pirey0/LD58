extends Company

func _ready() -> void:
	money = 100000
	goods = 100000
	display_value = false
	circle_color = Color.SKY_BLUE
	super()

func get_actions() -> Array[ContextAction]:
	if G.progression.founded:
		return []
	
	return [
		ContextAction.new(create_first_company, preload("res://art/company_icon.png"), preload("res://art/plus.png"), Color.LIME_GREEN, "Found Company")
	]

func create_first_company():
	G.progression.founded = true
	var sub = G.world.spawn_company_at(position + Vector2(0, 400.0), "Private Inequity")
	sub.player_owned = true
	sub.add_to_group("main_company")
	G.meta.hook_up_game_over()
	var connection = G.world.spawn_transfer_connection(self, 0.0, sub, 0.0)
	connection.taxable = false
	connection.max_amount = 10000
	connection.packet_size = 2500
	connection.on_vanish.connect(on_initial_transaction_finished_for_sub.bind(sub))	
	connection.on_vanish.connect(on_finish_startup)	
	connection = G.world.spawn_connection(self, 0.0, sub, 0.0,preload("res://content/connection_ownership.gd"))
	
func on_finish_startup():
	G.progression.root_exists = true
	pass
