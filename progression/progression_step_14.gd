extends ProgressionStep


func get_display_title() -> String:
	return "Leveraged Buyout"

func get_display_descr() -> String:
	return "Buying a company directly can be profitable, but it requires a large amount capital. Maybe you can get a bank to share this burden."

func begin_step():
	G.progression.can_leverage_buyout = true
	super()

func skip_step():
	G.progression.can_leverage_buyout = true
	super()
	
func _physics_process(delta: float) -> void:
	if G.progression.received_leveraged_buyout:
		finish()
