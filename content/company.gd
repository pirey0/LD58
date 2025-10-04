extends Control
class_name Company

@onready var vis: TextureRect = $Circle

var company_name : String:
	set(x):
		company_name = x
		$Name.text = x

var money : int

func _ready() -> void:
	add_to_group("object")
	company_name = Util.get_random_company_name()
	mouse_entered.connect(on_mouse_enter)
	mouse_exited.connect(on_mouse_exit)
	
	money = 1000
	$Money.text = Util.format_money(money)
	
	var tw = create_tween()
	tw.tween_property(self,"scale", Vector2.ONE , 1.0).from(0.1 * Vector2.ONE)\
			.set_trans(Tween.TransitionType.TRANS_BACK).set_ease(Tween.EASE_OUT)

func on_mouse_enter() -> void:
	set_highlight(true)

func on_mouse_exit() -> void:
	set_highlight(false)


func set_highlight(val):
	vis.modulate = Color.YELLOW if val else Color.WHITE

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
	G.world.spawn_connection(self, null)
	pass
