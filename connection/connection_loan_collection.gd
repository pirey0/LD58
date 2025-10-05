extends Connection

var loan : Company.LoanProposal
var year := 0


func _ready() -> void:
	super()
	self.base_color = Color.SLATE_GRAY
	is_closable_by_user = false

func _physics_process(delta: float) -> void:
	update_closure()

func setup(loan):
	self.loan = loan
	add_to_group("end_of_year_listener")


func on_year_end():
	#dont get returns immediately
	if year == 0:
		year+= 1
		return
	
	var inst := spawn_item( preload("res://content/connection_item_person.tscn"))
	inst.target_reached.connect(on_debt_collector_reached)
	inst.person_name = "Debt Collector"
	

func on_debt_collector_reached():
	destination.remove_debt(loan.debt_service)
	destination.change_money(-loan.debt_service, false)
	
	var item = spawn_item(preload("res://content/connection_item_money.tscn"))
	item.value = loan.debt_service
	item.reversed = true
	
	year += 1
	if year > loan.period:
		close()
