extends ProgressionStep


func get_display_title() -> String:
	return "Bank Run"

func get_display_descr() -> String:
	return "Thanks to your 'business acumen' also known as Transfer Pricing Manipulation, you are now elegible for a loan.\n\n Loans are calculated based on prior profits."

func begin_step():
	super()

func skip_step():
	super()
	
func _physics_process(delta: float) -> void:
	if G.progression.received_loan:
		finish()
	
