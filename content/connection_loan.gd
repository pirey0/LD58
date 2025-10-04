extends Connection


func _ready() -> void:
	super()
	set_physics_process(false)
	self.base_color = Color.SLATE_GRAY

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
	if not proposal:
		vanish()
		return
	
	#TODO
