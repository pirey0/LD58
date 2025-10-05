extends Company
class_name BankCompany

var description:String:
	set(x):
		description = x
		%Descr.text = x

func _ready() -> void:
	money = 100000
	goods = 100000
	super()
	%Descr.show()

func get_actions() -> Array[ContextAction]:
	return [
		ContextAction.new(apply_for_loan, preload("res://art/transaction.png"), null, Color.BLUE, "Apply For Loan", Color.BLUE),
	]

func apply_for_loan():
	var connection  = G.world.spawn_loan_connection(self, G.world.get_mouse_angle_to(position), null, 0.0)
	G.input.set_selected(connection)
	pass

func change_money(amount, taxable):
	return

func change_goods(amount):
	return

func update_state():
	pass
