extends Control
class_name Company

@onready var vis: TextureRect = $Circle

signal on_vanish

var hovered := false
var selected := false

var company_name : String:
	set(x):
		company_name = x
		%Name.text = x

var size_mult : float
var width_mult := 1.0

var last_money : int
var last_revenue : int
var new_revenue : int
var money : int
var debt : int
var tax : int
var goods : int
var circle_color := Color.FLORAL_WHITE
var player_owned := false
var vanishing := false
var is_in_first_year := true
var display_value := true

@onready var stats_obj := [%NewProfitT, %ProfitT,%GoodsT,%DebtT,%TaxT,%Profit,%Goods,%Debt,%Tax, %NewProfit]

func _ready() -> void:
	add_to_group("object")
	company_name = Util.get_random_company_name()
	mouse_entered.connect(on_mouse_enter)
	mouse_exited.connect(on_mouse_exit)

	dupl_label_settings(%Money)
	dupl_label_settings(%Name)
	dupl_label_settings(%Profit)
	for x in stats_obj:
		x.label_settings = %Profit.label_settings

	update_state()
	
	var tw = create_tween()
	tw.tween_property(self,"scale", Vector2.ONE , 1.0).from(0.1 * Vector2.ONE)\
			.set_trans(Tween.TransitionType.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	tw.tween_callback(update_state)


func dupl_label_settings(x):
	x.label_settings = x.label_settings.duplicate()

func on_mouse_enter() -> void:
	hovered = true
	update_highlight()

func on_mouse_exit() -> void:
	hovered = false
	update_highlight()

func update_highlight():
	if selected:
		width_mult = 2.0
	elif hovered:
		width_mult = 1.5
	else:
		width_mult = 1.0

func _process(delta: float) -> void:
	queue_redraw()
	
func _draw() -> void:
	draw_circle(Vector2.ZERO,122 * size_mult, circle_color, false, 4.0 * size_mult * width_mult)

func _gui_input(event: InputEvent) -> void:
	G.input.process_input(event)

func get_actions() -> Array:
	var out := []
	if G.progression.can_create_subsidiary:
		out.append(ContextAction.new(create_subsidiary, preload("res://art/company_icon.png"), null, Color.LIME_GREEN, "New Subsidiary"))
	if G.progression.can_trade_goods:
		out.append(ContextAction.new(create_sell_low.bind(0), preload("res://art/goods_icon.png"), preload("res://art/down.png"), Color.RED, "Sell Goods for $%s (LOW)"%Balancing.GOOD_VALUE_LOW, Color.LIME_GREEN))
		out.append(ContextAction.new(create_sell_high.bind(0), preload("res://art/goods_icon.png"), preload("res://art/up.png"), Color.GREEN, "Sell Goods for $%s (HIGH)"%Balancing.GOOD_VALUE_HIGH, Color.LIME_GREEN))
		
	if G.progression.trading_goods_tier_2:
		out.append(ContextAction.new(create_sell_low.bind(1), preload("res://art/goods_icon.png"), preload("res://art/down.png"),\
		 Color.RED, "Sell %s Goods for $%s (LOW)"%[Balancing.TIER_2_MULT, Balancing.GOOD_VALUE_LOW * Balancing.TIER_2_MULT], Color.ORANGE))
		out.append(ContextAction.new(create_sell_high.bind(1), preload("res://art/goods_icon.png"), preload("res://art/up.png")\
		, Color.GREEN, "Sell %s Goods for $%s (HIGH)"%[Balancing.TIER_2_MULT,Balancing.GOOD_VALUE_HIGH*Balancing.TIER_2_MULT], Color.ORANGE))

	if G.progression.trading_goods_tier_3:
		out.append(ContextAction.new(create_sell_low.bind(2), preload("res://art/goods_icon.png"), preload("res://art/down.png"),\
		 Color.RED, "Sell %s Goods for $%s (LOW)"%[Balancing.TIER_3_MULT, Balancing.GOOD_VALUE_LOW * Balancing.TIER_3_MULT], Color.RED))
		out.append(ContextAction.new(create_sell_high.bind(2), preload("res://art/goods_icon.png"), preload("res://art/up.png")\
		, Color.GREEN, "Sell %s Goods for $%s (HIGH)"%[Balancing.TIER_3_MULT,Balancing.GOOD_VALUE_HIGH*Balancing.TIER_3_MULT], Color.RED))


	return out

func create_sell_low(tier):
	var connection :ConnectionGoodsTransfer = G.world.spawn_goods_connection(self, G.world.get_mouse_angle_to(position), null, 0.0)
	connection.modifier = preload("res://art/down.png")
	connection.modifier_color = Color.RED
	connection.good_per_trade = Balancing.get_tier_mult(tier)
	connection.good_value = Balancing.GOOD_VALUE_LOW * Balancing.get_tier_mult(tier)
	connection.no_producer_target = false
	connection.connection_established.connect(on_trade_established)
	G.input.set_selected(connection)

func create_sell_high(tier):
	var connection :ConnectionGoodsTransfer = G.world.spawn_goods_connection(self, G.world.get_mouse_angle_to(position), null, 0.0)
	connection.modifier = preload("res://art/up.png")
	connection.modifier_color = Color.GREEN
	connection.good_per_trade = Balancing.get_tier_mult(tier)
	connection.good_value = Balancing.GOOD_VALUE_HIGH * Balancing.get_tier_mult(tier)
	connection.no_producer_target = false
	connection.connection_established.connect(on_trade_established)
	G.input.set_selected(connection)

func on_trade_established():
	G.progression.sold_goods = true	

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
	connection.on_vanish.connect(on_finished_subsidiary)
	connection = G.world.spawn_connection(self, 0.0, sub, 0.0,preload("res://content/connection_ownership.gd"))

func on_finished_subsidiary():
	G.progression.created_subsidiary = true

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
	if not player_owned:
		return
	
	money += amount
	
	if taxable:
		new_revenue += amount
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
	tw.tween_callback(on_bankrupcy_finished)
	tw.tween_callback(queue_free)
	
	create_tween().tween_callback(func(): on_vanish.emit()).set_delay(2.0)

func on_bankrupcy_finished():
	if debt > 0:
		G.progression.had_bankrupcy_width_debt = true
	pass

func change_goods(amount):
	if not player_owned:
		return
		
	goods += amount
	update_state()

func add_debt(amount, interest):
	debt += amount * (1.0 + interest)
	change_money(amount, false)

func remove_debt(amount):
	debt -= amount

func apply_size():
	var draw_size := 256 * size_mult
	$Circle.size = Vector2.ONE * draw_size
	$Circle.position = $Circle.size * -0.5
	update_highlight()
	
	update_label(%Money, %MoneyCtr, draw_size, 0.15, -0.25)
	update_label(%Name, %NameCtr, draw_size, 0.1, 0.0)
	update_label(%Profit, %StatsCtr, draw_size, 0.05, 0.25)

func update_label(label, label_parent, draw_size, rel_size, y_offset):
		label.label_settings.font_size = draw_size*rel_size
		label.label_settings.outline_size = draw_size*rel_size*0.5
		label_parent.position = label_parent.size * -0.5 + Vector2(0.0,draw_size*y_offset)

func update_state():
	if not player_owned:
		%DescrCtr.show()
		%StatsCtr.hide()
		if not display_value:
			%MoneyCtr.hide()
		else:
			%Money.text = Util.format_money(money)
			size_mult = max(1.0, (log(money)/log(150) - 1.0))
			apply_size()			
		return
	
	%StatsCtr.show()
	%DescrCtr.hide()
	%MoneyCtr.show()
	
	%Money.text = Util.format_money(money)
	size_mult = max(1.0, (log(money)/log(150) - 1.0))
	apply_size()
	
	#if last_money == 0 or last_money == money:
	#	$MoneyDiff.hide()
	#else:
	#	$MoneyDiff.show()
	#	$MoneyDiff.modulate = Color.GREEN if money > last_money else Color.RED
	#	var change = (100.0* (money - last_money)/last_money)
	#	$MoneyDiff.text = ("▲" if change > 0 else "▼")  + ("%.1f%%" %  abs(change))
	
	%Tax.visible = tax > 0
	%TaxT.visible = %Tax.visible
	%Tax.text = Util.format_money(tax) 
	%Tax.modulate = Color.GREEN if tax < 0 else Color.RED
	
	%Debt.visible = debt != 0
	%DebtT.visible = %Debt.visible
	%Debt.text = Util.format_money(debt)
	%Debt.modulate = Color.RED
	
	%Goods.visible = goods != 0
	%GoodsT.visible = %Goods.visible
	%Goods.text = str(goods)
	
	%Profit.visible = last_revenue != 0
	%ProfitT.visible = %Profit.visible
	%Profit.text = Util.format_money(last_revenue)
	%Profit.modulate = Color.RED if last_revenue < 0.0 else Color.GREEN

	%NewProfit.visible = new_revenue != 0
	%NewProfitT.visible = %NewProfit.visible
	%NewProfit.text = Util.format_money(new_revenue)
	%NewProfit.modulate = Color.RED if new_revenue < 0.0 else Color.GREEN

func on_year_end():
	last_revenue = new_revenue
	last_money = money
	is_in_first_year = false
	new_revenue = 0

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
