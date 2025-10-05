extends ProgressionStep


func get_display_title() -> String:
	return "Chapter 7 Bankrupcy"

func get_display_descr() -> String:
	return "The loan gave you more liquidity, but that high interest rate will cost you dearly.. Unless you find a way to not pay it back. \n\nBEWARE: if a parent company goes bankrupt the subsidiaries get liquidated. \n\nMake sure to never loose your starting company."

func begin_step():
	super()

func skip_step():
	super()
	
func _physics_process(delta: float) -> void:
	if G.progression.had_bankrupcy_with_debt:
		finish()
	
