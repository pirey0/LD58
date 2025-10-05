extends Control
class_name Company

@onready var vis: TextureRect = $Circle

signal on_vanish

var hovered := false
var selected := false

var company_name : String:
	set(x):
		company_name = x
		$Name.text = x

var size_mult : float
var width_mult := 1.0

var last_money : int
var last_revenue : int
var money : int
var debt : int
var tax : int
var goods : int
var circle_color := Color.FLORAL_WHITE
var player_owned := false
var vanishing := false
var is_in_first_year := true

func _ready() -> void:
	add_to_group("object")
	company_name = Util.get_random_company_name()
	mouse_entered.connect(on_mouse_enter)
	mouse_exited.connect(on_mouse_exit)
	
	update_state()
	
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
	if selected:
		width_mult = 1.5
	elif hovered:
		width_mult = 1.25
	else:
		width_mult = 1.0

func _process(delta: float) -> void:
	queue_redraw()
	
func _draw() -> void:
	draw_circle(Vector2.ZERO,122 * size_mult, circle_color, false, 4.0 * size_mult * width_mult)

func _gui_input(event: InputEvent) -> void:
	G.input.process_input(event)

func get_actions() -> Array[ContextAction]:
	return [
		ContextAction.new(create_subsidiary, preload("res://art/company_icon.png"), preload("res://art/plus.png"), Color.LIME_GREEN, "+ Subsidiary"),
		ContextAction.new(create_buy_line1, preload("res://art/goods_icon.png"), preload("res://art/down.png"), Color.RED, "Sell Goods for $%s"%Balancing.GOOD_VALUE_LOW, Color.LIME_GREEN),
		ContextAction.new(create_buy_line2, preload("res://art/goods_icon.png"), null, Color.RED, "Sell Goods for $%s"%Balancing.GOOD_VALUE_MID, Color.LIME_GREEN),
		ContextAction.new(create_buy_line3, preload("res://art/goods_icon.png"), preload("res://art/up.png"), Color.GREEN, "Sell Goods for $%s"%Balancing.GOOD_VALUE_HIGH, Color.LIME_GREEN),
	]

func create_buy_line1():
	var connection :ConnectionGoodsTransfer = G.world.spawn_goods_connection(self, G.world.get_mouse_angle_to(position), null, 0.0)
	connection.modifier = preload("res://art/down.png")
	connection.modifier_color = Color.GREEN
	connection.good_value = Balancing.GOOD_VALUE_LOW
	connection.no_producer_target = false
	G.input.set_selected(connection)

func create_buy_line2():
	var connection :ConnectionGoodsTransfer = G.world.spawn_goods_connection(self, G.world.get_mouse_angle_to(position), null, 0.0)
	connection.good_value = Balancing.GOOD_VALUE_MID
	connection.no_producer_target = false
	G.input.set_selected(connection)
	
func create_buy_line3():
	var connection :ConnectionGoodsTransfer = G.world.spawn_goods_connection(self, G.world.get_mouse_angle_to(position), null, 0.0)
	connection.modifier = preload("res://art/up.png")
	connection.modifier_color = Color.ORANGE_RED
	connection.good_value = Balancing.GOOD_VALUE_HIGH
	G.input.set_selected(connection)

func create_subsidiary():
	if money < 1000:
		return
	
	var sub = G.world.spawn_company_at(position + Vector2(0, 800.0))
	sub.player_owned = true
	var connection = G.world.spawn_transfer_connection(self, 0.0, sub, 0.0)
	connection.taxable = false
	connection.max_amount = roundi(money * 0.50)
	connection.packet_size = roundi(money * 0.1)
	connection.on_vanish.connect(on_initial_transaction_finished_for_sub.bind(sub))	
	
	connection = G.world.spawn_connection(self, 0.0, sub, 0.0,preload("res://content/connection_ownership.gd"))

func on_initial_transaction_finished_for_sub(x):
	#end of initial transaction marks starting money	
	x.last_money = x.money
	
func create_connection():
	var connection = G.world.spawn_transfer_connection(self, G.world.get_mouse_angle_to(position), null, 0.0)
	G.input.set_selected(connection)

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

func bankrupt(reason):
	if vanishing:
		return
		
	vanishing = true
	
	$Bankrupt.scale = Vector2.ZERO
	$Bankrupt.show()
	$Bankrupt.text = reason
	
	var tw = create_tween()
	tw.tween_property($Bankrupt,"scale", Vector2.ONE , 1.0).from(0.1 * Vector2.ONE)\
			.set_trans(Tween.TransitionType.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(2.0)
	tw.tween_property(self,"scale", Vector2.ZERO , 1.0).from(Vector2.ONE)\
			.set_trans(Tween.TransitionType.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_callback(queue_free)
	
	create_tween().tween_callback(func(): on_vanish.emit()).set_delay(2.0)

func change_goods(amount):
	goods += amount
	update_state()

func add_debt(amount, interest):
	debt += amount * (1.0 + interest)
	change_money(amount, false)

func remove_debt(amount):
	debt -= amount

func apply_size():
	$Circle.size = Vector2.ONE * 256 * size_mult
	$Circle.position = $Circle.size * -0.5
	update_highlight()

func update_state():
	$Money.text = Util.format_money(money)
	size_mult = max(1.0, (log(money)/log(150) - 1.0))
	apply_size()
	
	if last_money == 0 or last_money == money:
		$MoneyDiff.hide()
	else:
		$MoneyDiff.show()
		$MoneyDiff.modulate = Color.GREEN if money > last_money else Color.RED
		var change = (100.0* (money - last_money)/last_money)
		$MoneyDiff.text = ("▲" if change > 0 else "▼")  + ("%.1f%%" %  abs(change))
	
	$Tax.visible = tax != 0
	$Tax.text = "TAX: %s" % Util.format_money(tax) 
	$Tax.modulate = Color.GREEN if tax < 0 else Color.RED
	
	$Debt.visible = debt != 0
	$Debt.text = "DEBT: %s" % Util.format_money(debt)
	$Debt.modulate = Color.RED
	
	$Goods.visible = goods != 0
	$Goods.text = "GOODS: %s" % str(goods)
	$Goods.modulate = Color.GREEN

func on_year_end():
	last_revenue = money - last_money
	last_money = money
	is_in_first_year = false

func create_loan_proposal() -> LoanProposal:
	var out = LoanProposal.new()
	out.period = randi_range(2,5)
	out.evaluation = last_revenue
	out.debt = debt
	
	out.proposed_sum = (out.evaluation - debt) * randf_range(0.6, 4.0)
	out.interest = randf_range(0.10, 0.40)
	out.debt_service = out.proposed_sum * (1.0+out.interest) / out.period
	
	if out.evaluation <= 1000.0:
		out.fail_reason = LoanProposal.FailReason.LowIncome
	elif out.debt > 0.5*out.evaluation:
		out.fail_reason = LoanProposal.FailReason.Debt
	elif out.evaluation <= 0.0 or is_in_first_year:
		out.fail_reason = LoanProposal.FailReason.TooYoung
	
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
