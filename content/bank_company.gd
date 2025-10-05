extends Company
class_name BankCompany

var description:String:
	set(x):
		description = x
		%Descr.text = x

func _ready() -> void:
	money = 10000000
	goods = 10000000
	display_value = false
	super()

func get_actions() -> Array[ContextAction]:
	return [
		ContextAction.new(apply_for_loan, preload("res://art/transaction.png"), null, Color.BLUE, "Apply For Loan", Color.BLUE),
	]

func apply_for_loan():
	var connection  = G.world.spawn_loan_connection(self, G.world.get_mouse_angle_to(position), null, 0.0)
	G.input.set_selected(connection)
	pass
