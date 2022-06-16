extends Node

const agent_classes = [preload("res://Autonomous_Agent/Agent Template/Template.gd"), 
preload("res://Autonomous_Agent/deliberative_agent/deliberative_agent.gd"), 
preload("res://Autonomous_Agent/tony_agent/tony_agent.gd"),
preload("res://Autonomous_Agent/RandomAgent/random_agent.gd"),
preload("res://Autonomous_Agent/imitation_learning/imitation_learning.gd")]

var singlePlayer: bool
var multiplayer_online: bool
var multiplayer_local: bool

func multiplayer_online():
	singlePlayer = false
	multiplayer_online = true
	multiplayer_local = false

func multiplayer_local():
	singlePlayer = false
	multiplayer_online = false
	multiplayer_local = true

func singleplayer():
	singlePlayer = true
	multiplayer_online = false
	multiplayer_local = false

func menu():
	singlePlayer = false
	multiplayer_online = false
	multiplayer_local = false

func is_an_agent(var body):
	if singlePlayer:
		for a in agent_classes:
			if body is a:
				return true
	return false
