extends Control

signal finished(conditions)

var proposal : PublicCompany.BuyoutProposal

func setup(company:PublicCompany, purchaser : Company):
	proposal = company.create_buyout_proposal(purchaser)
	
	%contribution.text = "%0.1f%%" % (proposal.contribution * 100)
	%proposal.text = Util.format_money(proposal.proposed_sum)
	%debt_service.text = Util.format_money(proposal.debt_service)
	%period.text = "%s years" % str(proposal.period)
	%interest.text = "%0.1f%%" % (proposal.interest * 100)
	
	%refusal_reason.visible = not proposal.is_positive()
	if not proposal.is_positive():
		%Decline.hide()
		%parent.hide()
		%Accept.text = "Ok"
		
func _on_accept_pressed() -> void:
	
	if proposal.is_positive():
		finished.emit(proposal)
	else:
		finished.emit(null)
	vanish()

func _on_decline_pressed() -> void:
	finished.emit(null)
	vanish()
	

func vanish():
	queue_free()
	pass
