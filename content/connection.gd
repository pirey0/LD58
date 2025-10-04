extends Control
class_name Connection

signal on_vanish

var source : Company
var destination : Company

var size_mult := 0.0
var preview_target = null
var completion := 0.0

var color := Color.WHITE

var source_angle
var destination_angle

var freeing = false

func _ready() -> void:
	position = source.position
	
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "completion", 1.0, 1.0).set_trans(Tween.TransitionType.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "size_mult", 1.0, 1.0).set_trans(Tween.TransitionType.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	
func vanish():
	if freeing:
		return
	freeing = true
	on_vanish.emit()
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "completion", 0.0, 0.5).set_trans(Tween.TransitionType.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "size_mult", 0.0, 0.5).set_trans(Tween.TransitionType.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.set_parallel(false)
	tw.tween_callback(queue_free)

func _process(_delta):
	position = source.position
	size = get_dest_pos()
	
	queue_redraw()  # Redraw every frame (if controls can move)

func get_dest_obj():
	if destination:
		return destination
	elif preview_target:
		return preview_target
	else:
		return null

func get_dest_pos():
	var target_pos : Vector2
	if destination:
		target_pos = destination.position + Util.get_company_surface_offset(destination, G.world.get_angle_between(destination.position, source.position) )
	elif preview_target:
		target_pos = preview_target.position + Util.get_company_surface_offset(preview_target, G.world.get_mouse_angle_to(preview_target.position))
	else:
		target_pos =  G.world.screen_to_world_pos(G.get_mouse_pos())
	
	return target_pos - source.position

func _draw():
	if not source:
		return

	draw_connection(get_points())

func _get_canvas_item_visible_rect() -> Rect2:
	# Expand visible area by 2000 pixels in all directions
	return Rect2(Vector2(-2000, -2000), get_size() + Vector2(4000, 4000))

func get_points():
	var dest_obj = get_dest_obj()
	
	var src_angle
	if dest_obj:
		src_angle = G.world.get_angle_between(source.position, dest_obj.position)
	else:
		src_angle = source_angle
	
	var p1 = Util.get_company_surface_offset(source, src_angle)
	var p2 = p1 *2.0
	var p3 = get_dest_pos()
	var p4
	
	if dest_obj:
		p4 = p3 + ((p3 - (dest_obj.position - source.position))) *2.0
	else:
		p4 = p3 + (p3 - p2).normalized() * -100.0
	
	return [p1,p2,p3,p4]

func get_point_at(curve_points,t):
		var u = 1.0 - t
		return (
			u**3 * curve_points[0] +
			3.0 * u*u*t * curve_points[1] +
			3.0 * u*t*t * curve_points[3] +
			t**3 * curve_points[2]
		)

func draw_connection(curve_points):
	var points = PackedVector2Array()
	var steps = 24

	for i in range(steps + 1):
		var t = min(completion, float(i) / steps)
		points.append(get_point_at(curve_points,t))

	draw_polyline(points, Color.WHITE, 6.0 * size_mult)

func set_preview_target(t):
	preview_target = t if t != source else null


func try_use(target):
	if target == source or not target:
		return true
	
	destination = target
	G.input.set_selected(null)
	if destination:
		on_connection_established()
	return true


func on_connection_established():
	pass

func on_select():
	color = Color.ORANGE
	pass

func on_deselect():
	color = Color.WHITE
	
	if not destination:
		vanish()

func get_pos_at(percent:float) -> Vector2:
	return position + get_point_at(get_points(), percent)
