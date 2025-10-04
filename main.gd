extends Node


func _ready() -> void:
	
	var pos = G.world.screen_to_world_pos(get_window().size * 0.5)
	var root :Company = G.world.spawn_company_at(pos, "Private Inequity")
	root.player_owned = true
	root.add_to_group("main_company")
	root.change_money(10000.0, false)

	var goods :Company = G.world.spawn_company_at(pos + Vector2(1000,0), "Retailer", preload("res://content/producer_company.tscn"))
	goods.description = "Buys and Sells Goods"
	goods.size_mult = 2.5
	goods.base_color = Color.AQUA
	goods.apply_size()
	

	var bank :Company = G.world.spawn_company_at(pos + Vector2(-1200,0), "Corporate Loan Bank", preload("res://content/bank_company.tscn"))
	bank.description = "Offers Loans to worthy\n corporations."
	bank.size_mult = 3.0
	bank.base_color = Color.GOLD
	bank.apply_size()
	
	var government :Company = G.world.spawn_company_at(pos + Vector2(0,-1400), "IRS", preload("res://content/government_company.tscn"))
	government.description = "National Tax Authority"
	government.size_mult = 4.0
	government.base_color = Color.NAVY_BLUE
	government.apply_size()
