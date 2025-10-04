extends Control
class_name ActionMenu

var subject = null
var spawn_tween : Tween

func _ready() -> void:
	G.action_menu = self

func open_for(object):
	if subject == object:
		return
	
	if subject:
		close()
	
	if not object:
		return
	
	subject = object

	if spawn_tween:
		spawn_tween.kill()
	spawn_tween = create_tween()
	
	var actions = subject.get_actions()
	
	for x in actions.size():
		spawn_tween.tween_callback(spawn_item_for_action.bind(actions[x], x))
		spawn_tween.tween_interval(0.2)

func on_click(x:ContextAction):
	close()
	x.callback.call()

func spawn_item_for_action(x, idx):
	var item = preload("res://content/action_menu_item.tscn").instantiate()
	item.callback = on_click.bind(x)
	
	var angle = 2*PI* float(idx)/8
	item.position = subject.position + Util.get_company_surface_offset(subject, angle) * 1.4
	
	add_child(item)
	item.setup(x)
	
func close():
	subject = null
	
	var tw = create_tween()
	for x in get_children():
		tw.tween_callback(x.selfdestroy)
		tw.tween_interval(0.1)
