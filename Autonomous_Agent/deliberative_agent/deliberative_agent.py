from godot import exposed, export
from godot import *
import random
from collections import deque
import time
import sys
import math 

import numpy as np


@exposed
class Autonomous_Agent(Control):
	
	def _ready(self):
		self.worldObjects = self.get_parent().get_worldObjects()
		self.agent = self.get_parent()
		self.history = []
		
	def  _process(self, delta):
		# C4 handler
		if(self.agent.c4 > 0):
			self.agent.place_bomb("C4")
		if(self.agent.c4_planted):
			distance = math.sqrt((self.agent.c4_pos.x - self.worldObjects.player.position.x)**2 + (self.agent.c4_pos.y - self.worldObjects.player.position.y)**2)
			if distance < 50:
				self.agent.place_bomb("C4")
		# If it doesn't have bombs
		if(self.agent.get_number_of_bombs() == 0):
			MinDist = Vector2(sys.maxsize, sys.maxsize)
			for i in self.worldObjects.spawners:
				if not i.boomBoxHere:
					continue
				checkDistanceX = i.position.x - self.agent.position.x
				checkDistanceY = i.position.y - self.agent.position.y
				currentDistanceX = MinDist.x - self.agent.position.x
				currentDistanceY = MinDist.y - self.agent.position.y
				if math.sqrt(checkDistanceX*checkDistanceX + checkDistanceY*checkDistanceY) < math.sqrt(currentDistanceX*currentDistanceX + currentDistanceY*currentDistanceY):
					MinDist = i.position
			retVal = self.agent.go_to(self.worldObjects.discretize(MinDist))
		# if you have bomb
		else:
			retVal = self.agent.go_to(self.worldObjects.discretize(self.worldObjects.player.position))
			if self.worldObjects.discretize(self.agent.position) - self.worldObjects.discretize(self.worldObjects.player.position) == Vector2(0,0):
				self.agent.place_bomb("TNT")
		if retVal == 0:
			self.agent.go_to(self.worldObjects.discretize(self.history[len(self.history) - 1]))
		else:
			self.history.insert(0, self.agent.position)
			if(len(self.history) > 200):
				self.history.pop()
	
	def vector_distance(x, y):
		return math.sqrt(x*x + y*y)
		
		
