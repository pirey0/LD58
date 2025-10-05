extends ProgressionStep


func get_display_title() -> String:
	return "Back to the Big 5"

func get_display_descr() -> String:
	return "Aquire and bankrupt one of the Big 6. (Apple, Microsoft, Alphabet, Amazon, NVIDIA, Meta)"

func begin_step():
	super()

func skip_step():
	super()
	
func _physics_process(delta: float) -> void:
	for x in G.get_all_player_companies():
		if x.company_name in ["NVIDIA", "Microsoft", "Apple","Alphabet","Amazon","Meta"]:
			finish()
			return
