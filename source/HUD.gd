extends Node2D

var bombs = [0,0,0,0]
var mirror = false

func _ready():
	if position[0] != 0:
		mirror = true 
	
func updateBombs(b):
	bombs = b
	updateLabels()
	
func updateLabels():
	if GameModes.multiplayer_local || GameModes.multiplayer_online || GameModes.singlePlayer:
		
		if !Settings.static_hud:
		
			$TNT/top.visible = false
			$BigBombs/top.visible = false
			$LandMines/top.visible = false
			$c4/top.visible = false
				
			var sig = 1
			var last_pos = 0
			if mirror:
				last_pos = 168
				sig = -1
			
			if bombs[0] == 0:
				$TNT.visible = false
			else: 
				$TNT.visible = true
				$TNT.set_position(Vector2(last_pos,0))
				last_pos = last_pos + sig*52
			if bombs[1] == 0:
				$BigBombs.visible = false
			else: 
				$BigBombs.visible = true
				$BigBombs.set_position(Vector2(last_pos,0))
				last_pos = last_pos + sig*52
			if bombs[2] == 0:
				$LandMines.visible = false
			else: 
				$LandMines.visible = true
				$LandMines.set_position(Vector2(last_pos,0))
				last_pos = last_pos + sig*52
			if bombs[3] == 0:
				$c4.visible = false
			else: 
				$c4.visible = true
				$c4.set_position(Vector2(last_pos,0))
				last_pos = last_pos + sig*52
		else:
			$TNT.visible = true
			$BigBombs.visible = true
			$LandMines.visible = true
			$c4.visible = true
			set_original_positions()
			
			if bombs[0] == 0:
				$TNT/top.visible = true
			else: 
				$TNT/top.visible = false
			if bombs[1] == 0:
				$BigBombs/top.visible = true
			else: 
				$BigBombs/top.visible = false
			if bombs[2] == 0:
				$LandMines/top.visible = true
			else: 
				$LandMines/top.visible = false
			if bombs[3] == 0:
				$c4/top.visible = true
			else: 
				$c4/top.visible = false
			
		$TNT/Label.set_text(str(bombs[0]))
		$BigBombs/Label.set_text(str(bombs[1]))
		$LandMines/Label.set_text(str(bombs[2]))
		$c4/Label.set_text(str(bombs[3]))

func visible(is_visible): 
	visible = is_visible
	
func set_original_positions():
	var sig = 1
	var last_pos = 0
	if mirror:
		last_pos = 168
		sig = -1
	$TNT.set_position(Vector2(last_pos,0))
	last_pos = last_pos + sig*52
	$BigBombs.set_position(Vector2(last_pos,0))
	last_pos = last_pos + sig*52
	$LandMines.set_position(Vector2(last_pos,0))
	last_pos = last_pos + sig*52
	$c4.set_position(Vector2(last_pos,0))

