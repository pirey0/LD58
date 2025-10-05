extends Connection

var loan : Company.LoanProposal
var year := 0
var remaining := 0:
	set(x):
		remaining = x
		if remaining<=0:
			on_loan_delivered()

func _ready() -> void:
	super()
	self.base_color = Color.SLATE_GRAY
	is_closable_by_user = false

func _physics_process(delta: float) -> void:
	update_closure()

func on_connection_established():
	super()
	
	var inst := spawn_item( preload("res://content/connection_item_person.tscn"))
	inst.target_reached.connect(on_target_reached)
	inst.person_name = "Financial Analyst"

func on_target_reached():
	var obj = preload("res://content/loan_proposal.tscn").instantiate()
	obj.finished.connect(on_loan_proposal_finished)
	destination.add_child(obj)
	obj.setup(destination)

func on_loan_proposal_finished(proposal :Company.LoanProposal):
	G.progression.attempted_to_get_loan = true
	
	if not proposal:
		vanish()
		return
	
	loan = proposal
	add_to_group("end_of_year_listener")
	remaining = loan.proposed_sum
	
	var step := 1000
	var tw := create_tween()
	for x in ceili(float(loan.proposed_sum)/step):
		tw.tween_callback(func():
				var value = min(step, remaining)
				var item = spawn_item(preload("res://content/connection_item_money.tscn"))
				item.target_reached.connect(deliver_money.bind(value))
				remaining -= value
				item.value = value
						).set_delay(1.0)

func deliver_money(x):
	destination.add_debt(x, loan.interest)
	G.progression.received_loan = true

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

func on_loan_delivered():
	pass
