extends Control
class_name Company

@onready var vis: TextureRect = $Circle

var hovered := false
var selected := false

var company_name : String:
	set(x):
		company_name = x
		$Name.text = x

var money : int
var size_mult : float

func _ready() -> void:
	add_to_group("object")
	company_name = Util.get_random_company_name()
	mouse_entered.connect(on_mouse_enter)
	mouse_exited.connect(on_mouse_exit)
	
	money = 1000
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
	vis.modulate = Color.ORANGE if selected else (Color.YELLOW if hovered else Color.WHITE)

func _gui_input(event: InputEvent) -> void:
	G.input.process_input(event)

func get_actions() -> Array[ContextAction]:
	return [
		ContextAction.new(create_connection, preload("res://art/trade_icon.png"), preload("res://art/plus.png"), Color.ORANGE_RED),
		ContextAction.new(create_subsidiary, preload("res://art/company_icon.png"), preload("res://art/plus.png"), Color.LIME_GREEN),
		ContextAction.new(delete_company, preload("res://art/company_icon.png"), preload("res://art/minus.png"), Color.ORANGE_RED),
	]
	
func delete_company():
	queue_free()

func create_subsidiary():
	var sub = G.world.spawn_company_at(position + Vector2(0, 300))
	
func create_connection():
	var connection = G.world.spawn_connection(self, G.world.get_mouse_angle_to(position), null, 0.0)
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

func change_money(amount):
	money += amount
	update_state()

func update_state():
	$Money.text = Util.format_money(money)
	size_mult = max(1.0, (log(money)/log(10) - 2.0))
	$Circle.size = Vector2.ONE * 256 * size_mult
	$Circle.position = $Circle.size * -0.5
