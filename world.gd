extends Control
class_name World

func _ready() -> void:
	G.world = self	

func get_mouse_pos_world():
	return screen_to_world_pos(G.get_mouse_pos())

func get_mouse_angle_to(p) -> float:
	var m = get_mouse_pos_world()
	var v :Vector2= m-p
	return v.angle() + PI * 0.5

func get_angle_between(p1,p2) -> float:
	var v :Vector2= p2-p1
	return v.angle() + PI * 0.5

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

func spawn_connection(origin, origin_angle:float, target, target_angle : float):
	var inst : Connection = preload("res://content/connection_transfer.gd").new()
	inst.source = origin
	inst.source_angle = origin_angle
	inst.destination = target
	inst.destination_angle = target_angle
	add_child(inst, true)
	return inst
