extends ProgressionStep


func get_display_title() -> String:
	return "0 Sum Game"

func get_display_descr() -> String:
	return "Close the purchase line by right clicking it and sell the goods back to the Retailer. Make sure to not sell below market price."

func begin_step():
	super()
	G.progression.can_trade_goods = true

func skip_step():
	super()
	G.progression.can_trade_goods = true

func _physics_process(delta: float) -> void:
	if G.progression.sold_goods:
		finish()
