extends Node2D

var health = 100
var shield = 0

func _draw():
	var bar_size = GlobalVariables.pixel_art_scale * .75
	var split_point_hp = health * bar_size / 100
	var split_point_shield = shield * bar_size / 100
	self.draw_rect(Rect2(-bar_size/2, -GlobalVariables.pixel_art_scale * .5, split_point_shield, 2), Color.yellow)
	self.draw_rect(Rect2(-bar_size/2, -GlobalVariables.pixel_art_scale * .3, split_point_hp, 2), Color.green)
	self.draw_rect(Rect2(-bar_size/2 + split_point_hp, -GlobalVariables.pixel_art_scale * .3, bar_size - split_point_hp, 2), Color.red)

func take_damage(damage):
	shield -= damage
	if shield < 0:
		health += shield
		shield = 0
	update()
	return health <= 0

func add_hp(hp):
	health = min(100, hp + health)
	update()

func add_shield(amount):
	shield = min(100, shield + amount)
	update()
