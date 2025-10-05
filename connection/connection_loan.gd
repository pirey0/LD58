extends Connection

var loan 

var remaining := 0

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
		close()
		return
	var con = G.world.spawn_connection(source,0.0, destination,0.0, preload("res://connection/connection_loan_collection.gd"))
	con.setup(proposal)
	
	loan = proposal
	remaining = loan.proposed_sum
	var step = max(1000, roundi(remaining*0.05))
	var tw := create_tween()
	for x in ceili(float(loan.proposed_sum)/step):
		tw.tween_callback(func():
				var value = min(step, remaining)
				var item = spawn_item(preload("res://content/connection_item_money.tscn"))
				item.target_reached.connect(deliver_money.bind(value))
				remaining -= value
				item.value = value
						).set_delay(1.0)
	
	tw.tween_callback(close)

func deliver_money(x):
	destination.add_debt(x, loan.interest)
	G.progression.received_loan = true
