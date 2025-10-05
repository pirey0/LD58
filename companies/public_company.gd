extends Company

func _ready() -> void:
	circle_color = Color.SKY_BLUE
	super()

func get_actions() -> Array:
	if player_owned:
		return super()
	
	var out := []
	
	out.append(ContextAction.new(start_aquisition_process, preload("res://art/company_icon.png"),\
	 		null, Color.LIME_GREEN, "Buyout"))
	
	if G.progression.can_leverage_buyout:
			out.append(ContextAction.new(apply_for_leveraged_buyout, preload("res://art/transaction.png"),\
				null, Color.LIME_GREEN, "Apply for Leveraged Buyout", Color.PURPLE))
	
	return out

func start_aquisition_process():
	var conn = G.world.spawn_connection(self, 0.0, null, 0.0, preload("res://connection/connection_aquisition.gd"))
	G.input.set_selected(conn)

func apply_for_leveraged_buyout():
	var conn = G.world.spawn_connection(self, 0.0, null, 0.0, preload("res://connection/connection_leverage_buyout.gd"))
	G.input.set_selected(conn)
	
func aquired_by_user():
	G.progression.aquired_public_company = true
	
	player_owned = true
	circle_color = Color.FLORAL_WHITE
	
	#convert eval to state
	
	var split := randf_range(0.1,0.9)
	
	var total = money
	money = total*split
	goods = (total*(1.0-split))/Balancing.GOOD_VALUE_MID
	
	update_state()
	#TODO effect
