extends Node


func _ready() -> void:
	
	var pos = G.world.screen_to_world_pos(get_window().size * 0.5)
	G.world.spawn_company_at(pos, "Private Inequity")
