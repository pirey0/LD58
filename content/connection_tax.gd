extends Connection

func _ready() -> void:
	super()
	self.base_color = Color.SLATE_GRAY
	is_closable_by_user = false

func _physics_process(_delta: float) -> void:
	update_closure()

func on_connection_established():
	super()
	
	var inst := spawn_item( preload("res://content/connection_item_person.tscn"))
	inst.target_reached.connect(on_target_reached)
	inst.person_name = "Tax Collector"
	
	close()

func on_target_reached():
	var tax = destination.tax
	
	destination.on_year_end()
	
	if destination.money < 0:
		destination.bankrupt("BANKRUPT!")
	
	if tax <= 0.0:
		#goes back with nothing
		var inst := spawn_item( preload("res://content/connection_item_person.tscn"))
		inst.person_name = "Tax Collector"
		inst.reversed = true
		return
	
	destination.tax = 0
	destination.change_money(-tax,false)
	
	var item = spawn_item(preload("res://content/connection_item_money.tscn"))
	item.value = tax
	item.reversed = true
	Audio.play("bguaugh",-5.0)
	
