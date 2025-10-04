extends Node

var world : World
var action_menu : ActionMenu
var input : InputHandler

func get_mouse_pos() -> Vector2:
	return get_viewport().get_mouse_position()

func get_hovered_object() -> Node:
	var t = get_viewport().gui_get_hovered_control()
	
	while (t and not t.is_in_group("object")):
		t = t.get_parent()	
	
	if t:
		return t
	
	var mouse_pos = G.world.get_mouse_pos_world()
	for x in get_tree().get_nodes_in_group("connection"):
		var close = x.get_point_on_curve_if_close(mouse_pos)
		if close != Vector2.INF:
			return x
	
	return null
