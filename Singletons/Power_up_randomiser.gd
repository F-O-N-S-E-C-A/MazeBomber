extends Node2D

const power_ups = [
	"HPPowerUp",
	"DamagePowerUp",
	"SpeedPowerUp",
	"ShieldPowerUp",
	"MultipleTNTPowerUp",
	"BigBombPowerUp"
]

func get_random_power_up():
	var choice = Utils.diracs([0.84, 0.04, 0.03, 0.02, 0.02, 0.02, 0.03])
	if choice == 0:
		return null
	return power_ups[choice-1]
