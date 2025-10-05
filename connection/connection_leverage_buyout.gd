extends Connection

var bank

func _ready() -> void:
	super()
	self.base_color = Color.SLATE_GRAY
	is_closable_by_user = false

func _physics_process(delta: float) -> void:
	update_closure()

func is_target_valid(x):
	return x is Company and x.player_owned	

func on_connection_established():
	super()
	
	bank = G.world.find_closest_bank_to(source.position)
	if not bank:
		close()
		return
	
	var trip1 = G.world.spawn_connection(bank, 0.0, destination, 0.0,preload("res://content/connection.gd"))
	
	var item = trip1.spawn_item(load("res://content/connection_item_person.tscn"))
	item.person_name = "Private Equity Analyst"
	item.target_reached.connect(trip1.vanish)
	item.target_reached.connect(on_trip1_finished)

func on_trip1_finished():
	var item = spawn_item(load("res://content/connection_item_person.tscn"))
	item.person_name = "Private Equity Analyst"
	item.reversed = true
	item.target_reached.connect(on_trip2_finished)

func on_trip2_finished():
	var obj = preload("res://content/buyout_proposal.tscn").instantiate()
	obj.finished.connect(on_proposal_finished)
	source.add_child(obj)
	obj.setup(source,destination)

func on_proposal_finished(proposal :PublicCompany.BuyoutProposal):
	if not proposal:
		vanish()
		return
	
	G.progression.received_leveraged_buyout = true
	destination.change_money(-proposal.remainder, false)
	source.add_debt(proposal.proposed_sum, proposal.interest)
	source.aquired_by_user()
	G.world.spawn_connection(destination, 0.0, source, 0.0,preload("res://content/connection_ownership.gd"))
	var con = G.world.spawn_connection(bank,0.0, source,0.0, preload("res://connection/connection_loan_collection.gd"))
	con.setup(proposal)
	
	close()
