extends Node
class_name InputHandler

@export var zoom_minmax : Vector2

func _ready() -> void:
	G.input = self

func _unhandled_input(event: InputEvent) -> void:
	process_input(event)
	
func process_input(event:InputEvent):
	if event is InputEventMouseMotion:
		
		if event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
			# Middle mouse drag detected
			var delta = event.relative
			G.world.position += delta

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			change_zoom(0.1)
		
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			change_zoom(-0.1)
			
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
			open_action_menu()
			
		if event.button_index == MOUSE_BUTTON_LEFT:
			on_left_click()


func change_zoom(amount):
	var mouse_pos = G.get_mouse_pos()
	var world = G.world
	var old_scale = world.scale.x
	var new_scale = clamp(old_scale + amount, zoom_minmax.x, zoom_minmax.y)
	world.scale = Vector2.ONE * new_scale
	
	var scale_change = new_scale / old_scale
	world.position = (world.position - mouse_pos) * scale_change + mouse_pos

func open_action_menu():
	G.action_menu.open_for(G.get_hovered_object())
	pass

func on_left_click():
	G.action_menu.close()
