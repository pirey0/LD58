extends Control

signal finished(conditions)

var proposal : Company.LoanProposal

func setup(company:Company):
	Audio.play("tzuumm")
	proposal = company.create_loan_proposal()
		
	%eval.text = Util.format_money(proposal.evaluation)
	%debt.text = Util.format_money(proposal.debt)
	%proposal.text = Util.format_money(proposal.proposed_sum)
	%debt_service.text = Util.format_money(proposal.debt_service)
	%period.text = "%s years" % str(proposal.period)
	%interest.text = "%0.1f" % (proposal.interest * 100)
	%refusal_reason.visible = not proposal.is_positive()
	if not proposal.is_positive():
		%Decline.hide()
		%parent.hide()
		%Accept.text = "Ok"
		var t := ""
		match proposal.fail_reason:
			Company.LoanProposal.FailReason.TooYoung:
				t = "Company is too young and lacks proven trackrecord. Ask again next year."
			Company.LoanProposal.FailReason.LowIncome:
				t = "Company's profit are too low. Come back once you are profitable."
			Company.LoanProposal.FailReason.Debt:
				t = "Company's outstandig debt is too high. Come back after previous debt is repait or income has increased enough to compensate."
		%refusal_reason.text = t
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
	Audio.play("Click2")
	queue_free()
	pass
