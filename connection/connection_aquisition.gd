extends Connection


func _ready() -> void:
	super()
	self.base_color = Color.SLATE_GRAY
	is_closable_by_user = false

func _physics_process(delta: float) -> void:
	update_closure()

func is_target_valid(x,verbose):
	if not x is Company or not x.player_owned:
		return false
		
	if x.money < source.money:
		G.meta.show_feedback("Not enougn money", 3.0)
		return false
	
	return true

func on_connection_established():
	super()
	
	destination.change_money(-source.money, false)
	
	var inst := spawn_item(load("res://content/connection_item_money.tscn"))
	inst.reversed = true
	inst.value = source.money
	inst.target_reached.connect(on_target_reached)
	

func on_target_reached():
	source.aquired_by_user()
	G.world.spawn_connection(destination, 0.0, source, 0.0,preload("res://content/connection_ownership.gd"))
	close()
