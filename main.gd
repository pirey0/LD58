extends Node


func _ready() -> void:
	
	var pos = G.world.screen_to_world_pos(get_window().size * 0.5)
	var root :Company = G.world.spawn_company_at(pos, "Private Inequity")
	root.player_owned = true
	root.add_to_group("main_company")
	root.change_money(10000, false)
	root.on_initial_transaction_finished_for_sub(root)

	var goods :Company = G.world.spawn_company_at(pos + Vector2(1000,0), "Retailer", preload("res://content/producer_company.tscn"))
	goods.description = "Buys and Sells Goods"
	goods.size_mult = 2.5
	goods.circle_color = Color.AQUA
	goods.apply_size()
	

	var bank :Company = G.world.spawn_company_at(pos + Vector2(-1200,0), "Corporate Loan Bank", preload("res://content/bank_company.tscn"))
	bank.description = "Offers Loans to worthy\n corporations."
	bank.size_mult = 3.0
	bank.circle_color = Color.GOLD
	bank.apply_size()
	
	var government :Company = G.world.spawn_company_at(pos + Vector2(0,-1400), "IRS", preload("res://content/government_company.tscn"))
	government.description = "National Tax Authority"
	government.size_mult = 4.0
	government.circle_color = Color.NAVY_BLUE
	government.apply_size()


	var companies := load_companies_from_file()

	prints("Spawning", companies.size(), "real companies.")
	var rnd := RandomNumberGenerator.new()
	rnd.seed = 0
	
	companies.sort_custom(func(a,b): return a[1] > b[1])

	
	for data in companies:
		var angle =  rnd.randf_range(0.0, 2*PI)
		var value = data[1]
		var dist = log(value)/log(1.003)
		var spawn_point = dist * Vector2(sin(angle), cos(angle))
		var comp :Company = G.world.spawn_company_at(spawn_point, data[0])
		comp.money = data[1]
		comp.on_initial_transaction_finished_for_sub(comp)
		comp.update_state()

func load_companies_from_file() -> Array:
	var file = FileAccess.open("res://companies.txt", FileAccess.READ)
	
	var next_line := file.get_csv_line()
	next_line = file.get_csv_line()
	#skip header
	
	var out := []
	while not next_line.size()<4:
		var line := next_line
		var value = int(line[3])
		if value > 5000.0:
			out.append([line[1], value])
		var linenr := int(line[0])
		for x in (1 if (linenr < 20 or linenr >= 3518) else 25):
			next_line = file.get_csv_line()
	return out
	
