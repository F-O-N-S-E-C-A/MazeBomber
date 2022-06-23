extends Node

const agent_classes = [
preload("res://Autonomous_Agent/deliberative_agent/deliberative_agent.gd")]

var singlePlayer: bool
var multiplayer_online: bool
var multiplayer_local: bool

var agent
var agentSprite

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
