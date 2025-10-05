extends ProgressionStep


func get_display_title() -> String:
	return "Monopoly"

func get_display_descr() -> String:
	return "Aquire and bankrupt every single public company."

func begin_step():
	super()

func skip_step():
	super()
	
func _physics_process(delta: float) -> void:
	pass
	#TODO
