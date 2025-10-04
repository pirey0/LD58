extends Control
class_name World

func _ready() -> void:
	G.world = self	

func screen_to_world_pos(p:Vector2) -> Vector2:
	var out = -position/scale + p / scale
	return out

func spawn_company_at(pos:Vector2, _name = null):
	var inst : Company = preload("res://content/company.tscn").instantiate()
	inst.position = pos
	add_child(inst, true)
	if _name:
		inst.company_name = _name
	return inst

func spawn_connection(origin, target):
	var inst : Connection = preload("res://content/connection.tscn").instantiate()
	inst.source = origin
	inst.destination = target
	add_child(inst, true)
