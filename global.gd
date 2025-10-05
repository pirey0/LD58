extends Node

var world : World
var action_menu : ActionMenu
var input : InputHandler
var meta : Meta
var progression : Progression

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
		if not x.is_closable_by_user or x.closed or x.freeing:
			continue
		
		var close = x.get_point_on_curve_if_close(mouse_pos)
		if close != Vector2.INF:
			return x
	
	return null

func get_all_companies() -> Array:
	var out := []
	for x in get_tree().get_nodes_in_group("object"):
		if x is Company:
			out.append(x)
	return out

func get_all_player_companies() -> Array:
	var out := []
	for x in get_tree().get_nodes_in_group("object"):
		if x is Company and x.player_owned:
			out.append(x)
	return out

func get_open_connections_between(a,b) -> Array:
	var out := []
	
	for x :Connection in get_all_connections():
		if x.closed or x.freeing:
			continue
		if (x.source == a and x.destination == b) or (x.source == b and x.destination == a):
			out.append(x)
	return out

func get_all_connections() -> Array:
	return get_tree().get_nodes_in_group("connection")
