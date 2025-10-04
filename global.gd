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
	
	return t
