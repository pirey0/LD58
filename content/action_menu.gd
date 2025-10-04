extends Control
class_name ActionMenu

var subject = null
var spawn_tween : Tween

func _ready() -> void:
	G.action_menu = self

func open_for(object):
	if subject == object and subject != null:
		return
	
	if subject:
		close()
	
	if object == null:
		object = self
	
	subject = object

	if spawn_tween:
		spawn_tween.kill()
	spawn_tween = create_tween()
	
	var actions = subject.get_actions()
	
	var starting_angle := G.world.get_mouse_angle_to(subject.position)
	
	for x in actions.size():
		spawn_tween.tween_callback(spawn_item_for_action.bind(starting_angle, actions[x], x))
		spawn_tween.tween_interval(0.2)

func on_click(x:ContextAction):
	close()
	x.callback.call()

func spawn_item_for_action(starting_angle, x, idx):
	var item = preload("res://content/action_menu_item.tscn").instantiate()
	item.callback = on_click.bind(x)
	
	var angle = 2*PI* float(idx)/8
	
	if subject is Company:
		item.position = subject.position + Util.get_company_surface_offset(subject, starting_angle + angle) * 1.4
	else:
		item.position = G.world.get_mouse_pos_world() + Vector2(sin(angle), -cos(angle)) * 50.0
	
	add_child(item,true)
	item.setup(x)
	
func close():
	subject = null
	
	var tw = create_tween()
	for x in get_children():
		tw.tween_callback(x.vanish)
		tw.tween_interval(0.1)

func get_actions():
	return [
			ContextAction.new(create_subsidiary, preload("res://art/company_icon.png"), preload("res://art/plus.png"), Color.LIME_GREEN)
		]

func create_subsidiary():
	var sub = G.world.spawn_company_at(G.world.get_mouse_pos_world())
