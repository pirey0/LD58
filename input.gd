extends Node
class_name InputHandler

@export var zoom_minmax : Vector2

var active_element = null

func _ready() -> void:
	G.input = self

func _process(delta: float) -> void:
	update_active_element_preview()
	
func update_active_element_preview():
	if not active_element :
		return
	
	if not active_element is Connection or active_element.closed:
		return 
	
	var target = G.get_hovered_object()
	active_element.set_preview_target(target)
	

func _unhandled_input(event: InputEvent) -> void:
	process_input(event)
	
func process_input(event:InputEvent):
	if event is InputEventMouseMotion:
		
		if event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
			# Middle mouse drag detected
			var delta = event.relative
			G.world.position += delta
		
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			on_drag(event.relative)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			change_zoom(0.1)
		
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			change_zoom(-0.1)
			
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
			on_right_click()
			
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


func on_right_click():
	var target = G.get_hovered_object()
	print(target)
	if active_element and target != active_element:
		clear_selected()
		
	if target is Connection:
		target.close()
	else:
		G.action_menu.open_for(target)

func on_left_click():
	var target = G.get_hovered_object()
	if not active_element:
		G.action_menu.close()
		set_selected(target)
		return
	
	var used = active_element.try_use(target)
	if not used:
		set_selected(target)
		

func set_selected(t:Node):
	if t == active_element:
		return
	
	clear_selected()
	active_element = t
	if t:
		t.tree_exiting.connect(clear_selected)
		active_element.on_select()

func clear_selected():
	if not active_element:
		return
	
	active_element.on_deselect()
	active_element.tree_exiting.disconnect(clear_selected)
	active_element = null


func on_drag(rel):
	if active_element and active_element.has_method("try_drag"):
		active_element.try_drag(rel)
