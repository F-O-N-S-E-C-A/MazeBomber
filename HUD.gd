extends Node2D

var bombs = [0,0,0,0]

func updateBombs(b):
	bombs = b
	updateLabels()
	
func updateLabels():
	if GameModes.multiplayer_local || GameModes.multiplayer_online:
		if bombs[0] == 0:
			$TNT.visible = false
		else: 
			$TNT.visible = true
		if bombs[1] == 0:
			$BigBombs.visible = false
		else: 
			$BigBombs.visible = true
		if bombs[2] == 0:
			$LandMines.visible = false
		else: 
			$LandMines.visible = true
		if bombs[3] == 0:
			$c4.visible = false
		else: 
			$c4.visible = true
		
		$TNT/Label.set_text(str(bombs[0]))
		$BigBombs/Label.set_text(str(bombs[1]))
		$LandMines/Label.set_text(str(bombs[2]))
		$c4/Label.set_text(str(bombs[3]))

func visible(is_visible): 
	visible = is_visible

