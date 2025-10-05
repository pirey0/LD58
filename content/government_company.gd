extends Company
class_name GovernmentCompany

var description:String:
	set(x):
		description = x
		%Descr.text = x

func _ready() -> void:
	add_to_group("end_of_year_listener")
	money = 100000
	goods = 100000
	display_value = false
	super()

func get_actions() -> Array[ContextAction]:
	return [
	]


func on_year_end():
	
	var tw:= create_tween()
	
	for x in get_tree().get_nodes_in_group("object"):
		if x is Company and x.player_owned:
			tw.tween_callback(send_collector_to.bind(x)).set_delay(1.0)
	
	pass

func send_collector_to(x):
	G.world.spawn_connection(self, 0.0, x, 0.0, preload("res://content/connection_tax.gd"))
