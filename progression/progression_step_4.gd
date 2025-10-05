extends ProgressionStep


func get_display_title() -> String:
	return "Wheres my profit?"

func get_display_descr() -> String:
	return "There is no way for you to make more money the 'classical way'. Try applying for a loan from the bank. "

func begin_step():
	super()
	create_bank()

func create_bank():
	var pos = get_tree().get_first_node_in_group("main_company").position
	var bank :Company = G.world.spawn_company_at(pos + Vector2(-1400,0), "Corporate Loan Bank", preload("res://content/bank_company.tscn"))
	bank.description = "Offers Loans to worthy\n corporations."
	bank.size_mult = 3.0
	bank.circle_color = Color.GOLD
	bank.apply_size()

func skip_step():
	super()
	create_bank()
	

func _physics_process(delta: float) -> void:
	if G.progression.attempted_to_get_loan:
		finish()
