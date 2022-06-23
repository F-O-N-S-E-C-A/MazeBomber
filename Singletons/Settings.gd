extends Node

var explosion_damage_random: bool
var explosion_time_random: bool
var center_room: bool
var random_walls: bool

var music_volume: float
var sound_fx_volume: float

var music_enabled: bool
var sound_fx_enabled: bool

var nuke_mode: bool
var fog_of_war: bool

var static_hud: bool

var save_settings_file = "user://save_game.save"
var data = {}


func _ready():
	load_settings()

func save_settings():
	var file = File.new()
	data = {
		"explosion_damage_random" : explosion_damage_random,
		"explosion_time_random" : explosion_time_random, 
		"center_room" : center_room,
		"random_walls" : random_walls,
		"music_volume" : music_volume,
		"sound_fx_volume" : sound_fx_volume,
		"music_enabled" : music_enabled,
		"sound_fx_enabled" : sound_fx_enabled,
		"nuke_mode" : nuke_mode,
		"fog_of_war" : fog_of_war, 
		"static_hud" : static_hud
	}
	file.open(save_settings_file, File.WRITE)
	file.store_var(data)
	file.close()
	
func load_settings():
	#save_settings()
	var file = File.new()
	if not file.file_exists(save_settings_file):
		data = {
			"explosion_damage_random" : false,
			"explosion_time_random" : false, 
			"center_room" : true,
			"random_walls" : true,
			"music_volume" : 5,
			"sound_fx_volume" : 10,
			"music_enabled" : true,
			"sound_fx_enabled" : true,
			"nuke_mode" : false,
			"fog_of_war" : false,
			"static_hud" : false
		}
		save_settings()
	file.open(save_settings_file, File.READ)
	data = file.get_var()
	explosion_damage_random = data["explosion_damage_random"]
	explosion_time_random = data["explosion_time_random"]
	center_room = data["center_room"]
	random_walls = data["random_walls"]
	music_volume = data["music_volume"]
	sound_fx_volume = data["sound_fx_volume"]
	music_enabled = data["music_enabled"]
	sound_fx_enabled = data["sound_fx_enabled"]
	nuke_mode = data["nuke_mode"]
	fog_of_war = data["fog_of_war"]
	static_hud = data["static_hud"]
	file.close()
	


