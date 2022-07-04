extends StaticBody2D

onready var animationBomb = $AnimationPlayer
const wall = preload("Wall.gd")
var player = load("res://Player/Player.gd")
const base_damage = 200
const base_radius = 6
var time_ellapsed = 0
var lifetime = 2
var damage
var radius
var collision_color
var exploding = false
var to_explode = false
var collision_points = []
var exploded = false

func _ready():
	if GameModes.singlePlayer:
		WorldObjects.bombs.append(self)
	if GameModes.multiplayer_online or GameModes.waiting_lobby:
		self.name = Network.getName()

func _process(delta):
	if to_explode:
		if !exploded:
			doExplosion()
			exploded = true
		animationBomb.play("Explosion")
		yield(animationBomb, "animation_finished")
		to_explode = false
		self.queue_free()
		if GameModes.singlePlayer:
			WorldObjects.bombs.erase(self)
		
func my_init(owner):
	self.set_scale(GlobalVariables.scale_vector)
	add_collision_exception_with(owner)
	var average_damage = base_damage * owner.damage_multiplier
	if Settings.explosion_damage_random:
		damage = Utils.normal(average_damage, 30, average_damage - GlobalVariables.damage_threshold, average_damage + GlobalVariables.damage_threshold)
	else:
		damage = average_damage + GlobalVariables.damage_threshold/2
		if Settings.nuke_mode:
			damage = damage + 2500
	calculate_color(damage - average_damage)
	radius = base_radius * owner.radius_multiplier
	if Settings.nuke_mode:
		radius = 5000
	
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
			if collider is wall || collider is player || GameModes.is_an_agent(collider):
				collider.take_damage(damage_per_ray)
		else:
			collision_points.append(end_point)
	play_explosion_sound()
	update()

func sym_explosion(entity):
	if not exploding:
		return false
	var ds = get_world_2d().get_direct_space_state()
	var n = GlobalVariables.number_of_rays
	var damage_per_ray = damage/n
	var max_range = GlobalVariables.my_scale * radius
	
	for i in range(n):
		var end_point = self.position + Vector2(cos(TAU*i/n), sin(TAU*i/n)) * max_range
		var collision = ds.intersect_ray(self.position, end_point, [self], ~collision_layer)
		if collision != null && !collision.empty():
			var collider = collision.get("collider")
			if collider == entity:
				return true
	return false
	
func sym_collision_points():
	var cp = []
	var ds = get_world_2d().get_direct_space_state()
	var n = GlobalVariables.number_of_rays
	var damage_per_ray = damage/n
	var max_range = GlobalVariables.my_scale * radius
	for i in range(n):
		var end_point = self.position + Vector2(cos(TAU*i/n), sin(TAU*i/n)) * max_range
		var collision = ds.intersect_ray(self.position, end_point, [self], ~collision_layer)
		if collision != null && !collision.empty():
			cp.append(collision.get("position"))
		else:
			cp.append(end_point)
	return cp

func calculate_color(deviation): # max damage = more redish, min damage = more yellowish
	var s = sign(-deviation)
	deviation = sqrt(deviation * -s)
	var hue_deviation = GlobalVariables.hue_threshold * deviation * s / GlobalVariables.damage_threshold_sqrt
	var hue = GlobalVariables.hue_offset + hue_deviation
	collision_color = Color.from_hsv(hue, 1, 1)

func _draw():
	if to_explode:
		for point in collision_points:
			var center = (point - self.position) / GlobalVariables.scale_vector.x
			var rect = Rect2(center.x - 1, center.y - 1, 2, 2)
			self.draw_rect(rect, collision_color)
	

func draw_rays():
	var n = GlobalVariables.number_of_rays
	for i in range(n):
		draw_line(Vector2.ZERO, Vector2(cos(TAU*i/n), sin(TAU*i/n)) * GlobalVariables.pixel_art_scale * radius, Color.red)

func _on_Area2D_body_exited(body):
	if body is player:
		remove_collision_exception_with(body)
		
func play_explosion_sound():
	if Settings.sound_fx_enabled:
		$explosion_sound_fx.volume_db = Settings.sound_fx_volume - 15
		$explosion_sound_fx.play()
