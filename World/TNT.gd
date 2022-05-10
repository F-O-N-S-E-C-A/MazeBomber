extends StaticBody2D

onready var animationBomb = $AnimationPlayer
const wall = preload("Wall.gd")
var player = load("res://Player/Player.gd")
const base_damage = 200
const base_radius = 6
var time_ellapsed = 0
var lifetime
var damage
var radius
var collision_color
var exploding = false
var collision_points = []

func _process(delta):
	if exploding:
		animationBomb.play("Explosion")
		yield(animationBomb, "animation_finished")
		self.queue_free()
	else:
		time_ellapsed += delta
		animationBomb.set_speed_scale(0.5 + .6*time_ellapsed)
		exploding = time_ellapsed > lifetime
		if exploding:
			doExplosion()

func my_init(owner):
	self.set_scale(GlobalVariables.scale_vector)
	add_collision_exception_with(owner)
	lifetime = Utils.uniform(1500, 2500)/1000
	var average_damage = base_damage * owner.damage_multiplier
	damage = Utils.normal(average_damage, 30, average_damage - GlobalVariables.damage_threshold, average_damage + GlobalVariables.damage_threshold)
	calculate_color(damage - average_damage)
	radius = base_radius * owner.radius_multiplier
	
func doExplosion():
	var ds = get_world_2d().get_direct_space_state()
	var n = GlobalVariables.number_of_rays
	var damage_per_ray = damage/n
	var max_range = GlobalVariables.my_scale * radius
	for i in range(n):
		var end_point = self.position + Vector2(cos(TAU*i/n), sin(TAU*i/n)) * max_range
		var collision = ds.intersect_ray(self.position, end_point, [self], ~collision_layer)
		if collision != null && !collision.empty():
			var collider = collision.get("collider")
			collision_points.append(collision.get("position"))
			if collider is wall || collider is player:
				collider.take_damage(damage_per_ray)
		else:
			collision_points.append(end_point)
	update()

func calculate_color(deviation): # max damage = more redish, min damage = more yellowish
	var s = sign(-deviation)
	deviation = sqrt(deviation * -s)
	var hue_deviation = GlobalVariables.hue_threshold * deviation * s / GlobalVariables.damage_threshold_sqrt
	var hue = GlobalVariables.hue_offset + hue_deviation
	collision_color = Color.from_hsv(hue, 1, 1)

func _draw():
	#draw_rays()
	if exploding:
		for point in collision_points:
			var center = (point - self.position) / GlobalVariables.scale_vector.x
			var rect = Rect2(center.x - 1, center.y - 1, 2, 2)
			self.draw_rect(rect, collision_color)
	pass


func draw_rays():
	var n = GlobalVariables.number_of_rays
	for i in range(n):
		draw_line(Vector2.ZERO, Vector2(cos(TAU*i/n), sin(TAU*i/n)) * GlobalVariables.pixel_art_scale * radius, Color.red)

func _on_Area2D_body_exited(body):
	if body is player:
		remove_collision_exception_with(body)
