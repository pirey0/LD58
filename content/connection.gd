extends Control
class_name Connection

signal on_vanish
signal connection_established

var source : Company
var destination : Company
var no_producer_target := true
var is_closable_by_user := true

var line_width := 6.0
var size_mult := 0.0
var preview_target = null
var completion := 0.0

var color := Color.WHITE
var base_color := Color.WHITE

var source_angle
var destination_angle

var freeing = false
var connected := false
var closed := false
var active_transfers := 0

func _ready() -> void:
	add_to_group("connection")
	position = source.position
	source.on_vanish.connect(vanish)
	
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "completion", 1.0, 1.0).set_trans(Tween.TransitionType.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "size_mult", 1.0, 1.0).set_trans(Tween.TransitionType.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.set_parallel(false)
	tw.tween_callback(delayed_ready)
	
func delayed_ready():
	if destination and not connected:
		on_connection_established()

func vanish():
	if freeing:
		return
	Audio.play("tshuuhug",-10.0)
	freeing = true
	on_vanish.emit()
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "completion", 0.0, 0.5).set_trans(Tween.TransitionType.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "size_mult", 0.0, 0.5).set_trans(Tween.TransitionType.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.set_parallel(false)
	tw.tween_callback(queue_free)

func _process(_delta):
	if not is_instance_valid(source):
		return
	
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
	draw_polyline(get_spline_points(), color, line_width * size_mult)

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

func get_spline_points():
	var points = PackedVector2Array()
	var steps = 24
	var curve_points = get_points()

	for i in range(steps + 1):
		var t = min(completion, float(i) / steps)
		points.append(get_point_at(curve_points,t))
	return points


func set_preview_target(t):
	if not is_target_valid(t,false):
		preview_target = null
		return
	
	preview_target = t

func is_target_valid(target,verbose):
	if target == source or not target or not target is Company:
		if verbose:
			G.meta.show_feedback("Invalid Target", 1.0)
		return false
	
	if no_producer_target and target is ProducerCompany:
		if verbose:
			G.meta.show_feedback("Retailer refused", 1.0)
		return false
	
	return true

func try_use(target):
	if connected:
		return false
	
	if not is_target_valid(target,true):
		return true

	
	if not target is Company:
		return true
	
	Audio.play("wabib",4)
	destination = target
	G.input.set_selected(null)
	if destination and not connected:
		on_connection_established()
	return true


func on_connection_established():
	connected = true
	connection_established.emit()
	destination.on_vanish.connect(vanish)
	pass

func on_select():
	color = Color.ORANGE
	pass

func on_deselect():
	color = base_color
	
	if not destination:
		vanish()

func get_pos_at(percent:float) -> Vector2:
	return position + get_point_at(get_points(), percent)

func close():
	closed = true
	base_color = Color.DIM_GRAY
	color = base_color

func update_closure():
	if closed:
		if active_transfers <= 0:
			vanish()

func spawn_item(scene) -> ConnectionItem:
	var inst : ConnectionItem = scene.instantiate()
	inst.position = Vector2(-100000.0, -100000.0)
	inst.setup(self)
	G.world.add_child(inst,true)
	inst.tree_exiting.connect(reduce_transfer_counter)
	active_transfers += 1
	return inst

func reduce_transfer_counter():
	active_transfers -= 1
	pass

func get_point_on_curve_if_close(pos: Vector2) -> Vector2:
	pos -= position
	var points = get_spline_points()
	
	for i in range(points.size() - 1):
		var a = points[i]
		var b = points[i + 1]
		var dist = distance_to_segment(pos, a, b)
		if dist < 20:
			return a
	return Vector2.INF

func distance_to_segment(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ap = p - a
	var ab = b - a
	var t = clamp(ap.dot(ab) / ab.length_squared(), 0.0, 1.0)
	var closest = a + ab * t
	return p.distance_to(closest)
