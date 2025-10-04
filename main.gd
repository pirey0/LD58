extends Node


func _ready() -> void:
	
	var pos = G.world.screen_to_world_pos(get_window().size * 0.5)
	var root :Company = G.world.spawn_company_at(pos, "Private Inequity")
	root.change_money(10000.0, false)

	var goods :Company = G.world.spawn_company_at(pos + Vector2(1000,0), "Goods Inc", preload("res://content/producer_company.tscn"))
	goods.description = "Sells Goods at\n 300$"
	goods.size_mult = 3.0
	goods.base_color = Color.AQUA
	goods.apply_size()
	
