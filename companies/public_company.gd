extends Company
class_name PublicCompany

func _ready() -> void:
	circle_color = Color.CYAN
	super()

func get_actions() -> Array:
	if player_owned:
		return super()
	
	var out := []
	
	out.append(ContextAction.new(start_aquisition_process, preload("res://art/company_icon.png"),\
	 		null, Color.LIME_GREEN, "Buyout"))
	
	if G.progression.can_leverage_buyout:
			out.append(ContextAction.new(apply_for_leveraged_buyout, preload("res://art/transaction.png"),\
				null, Color.LIME_GREEN, "Apply for Leveraged Buyout", Color.PURPLE))
	
	return out

func start_aquisition_process():
	var conn = G.world.spawn_connection(self, 0.0, null, 0.0, preload("res://connection/connection_aquisition.gd"))
	G.input.set_selected(conn)

func apply_for_leveraged_buyout():
	var conn = G.world.spawn_connection(self, 0.0, null, 0.0, preload("res://connection/connection_leverage_buyout.gd"))
	G.input.set_selected(conn)
	
func aquired_by_user():
	G.progression.aquired_public_company = true
	G.progression.max_buyout = max(money, G.progression.max_buyout)
	player_owned = true
	circle_color = Color.FLORAL_WHITE
	
	#convert eval to state
	
	var split := randf_range(0.1,0.9)
	
	var total = money
	money = total*split
	goods = (total*(1.0-split))/Balancing.GOOD_VALUE_HIGH
	
	update_state()
	#TODO effect
	Audio.play("phuwhag")

func create_buyout_proposal(other_company) -> BuyoutProposal:
	var out = BuyoutProposal.new()
	
	out.period = randi_range(5,10)
	out.contribution = randf_range(0.2,0.8)
	out.proposed_sum = roundi(out.contribution * money)
	
	out.interest = randf_range(0.20, 0.60)
	out.debt_service = out.proposed_sum * (1.0+out.interest) / out.period
	
	out.remainder = money - out.proposed_sum
	
	if out.remainder > other_company.money:
		out.fail_reason = BuyoutProposal.FailReason.LackingFunds
	return out

class BuyoutProposal extends RefCounted:
	
	enum FailReason {None, LackingFunds }
	
	var contribution : float
	var proposed_sum : int
	var debt_service : int
	var period : int
	var fail_reason := FailReason.None
	var interest : float
	var remainder : int
	
	func is_positive() -> bool:
		return fail_reason == FailReason.None
