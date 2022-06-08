from godot import exposed, export
from godot import *
import random
from collections import deque
import time

import numpy as np


@exposed
class Autonomous_Agent(Control):
	def getYSort(self):
		self.nodes = self.YSort.get_children()
		self.sortedNodes = sorted(self.nodes, key = lambda n: (n.position.x, n.position.y))
	
	def _ready(self):
		"""self.world = self.owner.get_parent().owner
		self.mazeGenerator = self.world.get_child(1)
		self.YSort = self.mazeGenerator.get_child(1)
		print(self)"""

	def  _process(self, delta):
		#print(self.get_parent().world_objects.bombs)
		self.get_parent().world_objects.observations()
		
		
