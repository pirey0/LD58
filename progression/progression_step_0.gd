extends ProgressionStep


func get_display_title() -> String:
	return ""

func get_display_descr() -> String:
	return ""

func begin_step():
	G.meta.new_game_clicked.connect(finish)

func skip_step():
	super()
	G.meta.close_main_menu()
	
	
