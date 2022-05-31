from godot import exposed, export
from godot import *
import random
from collections import deque

from tensorflow.keras import Model, Sequential
from tensorflow.keras.layers import Dense, Embedding, Reshape
from tensorflow.keras.optimizers import Adam

import numpy as np

@exposed
class Autonomous_Agent(Control):
	def getYSort(self):
		self.nodes = self.YSort.get_children()
		self.sortedNodes = sorted(self.nodes, key = lambda n: (n.position.x, n.position.y))
	
	def _ready(self):
		self.get_parent().model = True
		self.state_size = 2 #position
		self.action_size = 4 #movement
		self.optimizer = Adam(learning_rate=0.01)
		self.expirience_replay = deque(maxlen=2000)
		self.gamma = 0.6
		self.epsilon = 0.1
		self.action_space = ["UP", "DOWN", "LEFT", "RIGHT"]

		self.q_network = self._build_compile_model()
		self.target_network = self._build_compile_model()
		self.alighn_target_model()

		self.world = self.owner.get_parent().owner
		self.mazeGenerator = self.world.get_child(1)
		self.YSort = self.mazeGenerator.get_child(1)
		print(self)

	def  _process(self, delta):
		#1 - send input
		#2 - receive action
		#3 - repeat
		
		#self.getYSort()
		#for node in self.sortedNodes:
		#	if "Wall" in str(node.get_name()):
		#		if node.position.x == 16 and node.position.y == 48:
		#			node.visible = not node.visible
		a = self.act(np.array([[self.get_parent().position.x, self.get_parent().position.y]]))
		
		if a == 0:
			self.get_parent().input_vector.x = 0
			self.get_parent().input_vector.y = -1
		elif a == 1:
			self.get_parent().input_vector.x = 0
			self.get_parent().input_vector.y = 1
		elif a == 2:
			self.get_parent().input_vector.x = -1
			self.get_parent().input_vector.y = 0
		elif a == 3:
			self.get_parent().input_vector.x = 1
			self.get_parent().input_vector.y = 0
	
	def _build_compile_model(self):
		model = Sequential()
		model.add(Dense(50, activation='relu', input_dim=self.state_size))
		model.add(Dense(50, activation='relu'))
		model.add(Dense(self.action_size, activation='linear'))

		model.compile(loss='mse', optimizer=self.optimizer)
		return model
	
	def alighn_target_model(self):
		self.target_network.set_weights(self.q_network.get_weights())
		
	def act(self, state):
		if np.random.rand() <= self.epsilon:
			return random.randint(0, len(self.action_space))

		q_values = self.q_network.predict(state)
		return np.argmax(q_values[0])
