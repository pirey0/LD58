extends Node


func _ready() -> void:
	
	var pos = G.world.screen_to_world_pos(get_window().size * 0.5)
	var root :Company = G.world.spawn_company_at(pos, "Private Inequity")
	root.player_owned = true
	root.change_money(10000.0, false)

	var goods :Company = G.world.spawn_company_at(pos + Vector2(1000,0), "Retailer", preload("res://content/producer_company.tscn"))
	goods.description = "Buys and Sells Goods"
	goods.size_mult = 3.0
	goods.base_color = Color.AQUA
	goods.apply_size()
	

	var bank :Company = G.world.spawn_company_at(pos + Vector2(-1000,0), "Corporate Loan Bank", preload("res://content/bank_company.tscn"))
	bank.description = "Offers Loans to worthy\n corporations."
	bank.size_mult = 3.0
	bank.base_color = Color.GOLD
	bank.apply_size()
	
