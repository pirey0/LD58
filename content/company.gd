extends Control
class_name Company

@onready var vis: TextureRect = $Circle

var hovered := false
var selected := false

var company_name : String:
	set(x):
		company_name = x
		$Name.text = x

var size_mult : float

var last_money : int
var last_income : int
var money : int
var debt : int
var tax : int
var goods : int
var base_color := Color.WHITE
var player_owned := false

func _ready() -> void:
	add_to_group("object")
	company_name = Util.get_random_company_name()
	mouse_entered.connect(on_mouse_enter)
	mouse_exited.connect(on_mouse_exit)
	
	update_state()
	update_highlight()
	
	var tw = create_tween()
	tw.tween_property(self,"scale", Vector2.ONE , 1.0).from(0.1 * Vector2.ONE)\
			.set_trans(Tween.TransitionType.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	tw.tween_callback(update_state)


func on_mouse_enter() -> void:
	hovered = true
	update_highlight()

func on_mouse_exit() -> void:
	hovered = false
	update_highlight()

func update_highlight():
	vis.modulate = Color.ORANGE if selected else (Color.YELLOW if hovered else base_color)

func _gui_input(event: InputEvent) -> void:
	G.input.process_input(event)

func get_actions() -> Array[ContextAction]:
	return [
		ContextAction.new(create_subsidiary, preload("res://art/company_icon.png"), preload("res://art/plus.png"), Color.LIME_GREEN, "+ Subsidiary"),
		ContextAction.new(create_buy_line1, preload("res://art/goods_icon.png"), preload("res://art/down.png"), Color.GREEN, "Buy Good for $280", Color.LIME_GREEN),
		ContextAction.new(create_buy_line2, preload("res://art/goods_icon.png"), preload("res://art/up.png"), Color.RED, "Buy Good for $320", Color.LIME_GREEN),
	]

func create_buy_line1():
	var connection :ConnectionGoodsTransfer = G.world.spawn_goods_connection(self, G.world.get_mouse_angle_to(position), null, 0.0)
	connection.modifier = preload("res://art/down.png")
	connection.modifier_color = Color.GREEN
	connection.good_value = 280
	connection.no_producer_target = false
	G.input.set_selected(connection)

func create_buy_line2():
	var connection :ConnectionGoodsTransfer = G.world.spawn_goods_connection(self, G.world.get_mouse_angle_to(position), null, 0.0)
	connection.modifier = preload("res://art/up.png")
	connection.modifier_color = Color.ORANGE_RED
	connection.good_value = 320
	G.input.set_selected(connection)

func create_subsidiary():
	var sub = G.world.spawn_company_at(position + Vector2(0, 500.0))
	sub.player_owned = true
	var connection = G.world.spawn_transfer_connection(self, 0.0, sub, 0.0)
	connection.taxable = false
	connection.max_amount = roundi(money * 0.25)
	connection.packet_size = roundi(money * 0.025)

func create_connection():
	var connection = G.world.spawn_transfer_connection(self, G.world.get_mouse_angle_to(position), null, 0.0)
	G.input.set_selected(connection)

func set_preview_target(t):
	pass

func try_use(t):
	return false

func try_drag(rel):
	position += rel

func on_select():
	selected = true
	update_highlight()

func on_deselect():
	selected = false
	update_highlight()

func change_money(amount, taxable):
	money += amount
	
	if taxable:
		tax += roundi(amount * 0.21)
	
	update_state()

func change_goods(amount):
	goods += amount
	update_state()

func add_debt(amount, interest):
	debt += amount * (1.0 + interest)
	
	change_money(amount, false)

func apply_size():
	$Circle.size = Vector2.ONE * 256 * size_mult
	$Circle.position = $Circle.size * -0.5

func update_state():
	$Money.text = Util.format_money(money)
	size_mult = max(1.0, (log(money)/log(10) - 2.0))
	apply_size()
	
	if last_money == 0:
		$MoneyDiff.hide()
	else:
		$MoneyDiff.show()
		$MoneyDiff.modulate = Color.GREEN if money > last_money else Color.RED
		$MoneyDiff.text = "%.1f" % ((money - last_money)/last_money)
	
	$Tax.visible = tax != 0
	$Tax.text = "TAX: %s" % Util.format_money(tax) 
	$Tax.modulate = Color.GREEN if tax < 0 else Color.RED
	
	$Debt.visible = debt != 0
	$Debt.text = "DEBT: %s" % Util.format_money(debt)
	$Debt.modulate = Color.RED
	
	$Goods.visible = goods != 0
	$Goods.text = "GOODS: %s" % str(goods)
	$Debt.modulate = Color.GREEN


func create_loan_proposal() -> LoanProposal:
	var out = LoanProposal.new()
	out.period = randi_range(2,5)
	out.evaluation = last_income
	out.debt = debt
	
	out.proposed_sum = (last_income - debt) * randf_range(0.3, 1.1)
	out.interest = randf_range(0.05, 0.25)
	out.debt_service = out.proposed_sum * (1.0+out.interest)
	
	if out.debt > 0.5*out.evaluation:
		out.fail_reason = LoanProposal.FailReason.Debt
	elif out.evaluation <= 0.0:
		out.fail_reason = LoanProposal.FailReason.TooYoung
	elif out.evaluation <= 1000.0:
		out.fail_reason = LoanProposal.FailReason.LowIncome
	return out

class LoanProposal extends RefCounted:
	
	enum FailReason {None, TooYoung, LowIncome, Debt }
	
	var evaluation : int
	var debt : int
	var proposed_sum : int
	var debt_service : int
	var period : int
	var fail_reason := FailReason.None
	var interest : float
	
	func is_positive() -> bool:
		return fail_reason == FailReason.None
