from godot import exposed, export
from godot import *
import random
from collections import deque
import time
import math

from tensorflow.keras import Model, Sequential
from tensorflow.keras.layers import Dense, Embedding, Reshape, InputLayer
from tensorflow.keras.optimizers import Adam
from tensorflow.keras import initializers
import tensorflow as tf

import numpy as np
import time
import threading

@exposed
class Autonomous_Agent(Control):
	def _ready(self):
		self.ready = False
		self.n_steps = 0
		
	def init(self):
		self.state, self.player_obs = self.observations()
		self.state = self.obs_discrete()
		#self.state = np.array([[self.get_parent().position.x, self.get_parent().position.y]])
		self.actions = ["UP", "DOWN", "LEFT", "RIGHT", "STAY"]#, "TNT", "BIG_BOMB", "LAND_MINE", "C4"]
		
		self.state_size = len(self.state)
		self.action_size = len(self.actions)
		self.optimizer = Adam(learning_rate=0.1)
		
		self.expirience_replay = deque(maxlen=500)
		
		# Initialize discount and exploration rate
		self.gamma = 0.99
		self.epsilon = 0.5
		
		# Build networks
		self.q_network = self.build_compile_model()
		self.target_network = self.build_compile_model()
		self.alighn_target_model()
		self.ready = True
		self.last_position = np.array([[self.get_parent().position.x, self.get_parent().position.y]])
		self.position = np.array([[self.get_parent().position.x, self.get_parent().position.y]])
		self.comulativeReward = 0
		
		#t = threading.Thread(target=self.constant_training)
		#t.start()
		
	def _process(self, delta):
		if not self.ready:
			return
			
		self.position = np.array([[self.get_parent().position.x, self.get_parent().position.y]])	
		
		
		action = self.act(self.state)
		self.perform_action(action)
		'''
		if self.n_steps <= 300:
			action = self.get_parent().act()
		elif self.n_steps <= 350:
			action = self.act(self.state)
			self.perform_action(action)
		else:
			self.n_steps = 0
			self.get_parent().reset()
			return
		'''
		next_state, next_player_obs = self.observations()
		next_state = self.obs_discrete()
		#next_state = np.array([[self.get_parent().position.x, self.get_parent().position.y]])
		reward = self.calculate_reward(next_player_obs, self.player_obs) # index 4 and 5 
		self.comulativeReward += reward
		self.state = next_state
		
		terminated = False
		if self.n_steps % 300 == 0:
			terminated = True
		#print(self.state, action, reward, next_state, terminated)
		self.store(self.state, action, reward, next_state, terminated)
		#DELETE START
		'''
		target = self.q_network.predict(self.state, verbose = 0)
		if terminated:
			target[0][action] = reward
		else:
			t = self.target_network.predict(next_state, verbose = 0)
			target[0][action] = reward + self.gamma * np.amax(t)
		
		self.q_network.fit(self.state, target, epochs=1, verbose=0)
		self.alighn_target_model()
		'''
		#DELETE END
		
		self.last_position = self.position
		
		self.player_obs = next_player_obs
		
		if terminated:
			self.alighn_target_model()
			
		if self.n_steps % 100 == 0:
			t = threading.Thread(target=self.retrain, args=(100,))
			t.start()
		
		if self.n_steps % 300 == 0:
			self.get_parent().reset()
			
		if self.n_steps % 300 == 0:
			self.epsilon = 0
			print("Comulative Reward: ", self.comulativeReward)
			
		if self.n_steps % 350 == 0:
			self.get_parent().reset()
			self.epsilon = 0.5
			self.n_steps = 0
			self.comulativeReward = 0
			
		self.n_steps += 1
		#print(self.n_steps)
		
		
	def observations(self):
		map = np.array(self.get_parent().world_objects.map_obs()).flatten()
		player = np.array(self.get_parent().world_objects.player_obs_continuous())
		return (np.concatenate([map, player]), player)
		
	def obs_discrete(self):
		agentPos = [self.get_parent().world_objects.posX(self.get_parent()), self.get_parent().world_objects.posY(self.get_parent())]
		lst = []
		obs = self.get_parent().world_objects.map_obs()
		
		offsets = [[-1, -1], [0, -1], [1, -1], [-1, 0], [0, 0], [1, 0], [-1, 1], [0, 1], [1 ,1]]
		
		for i in [0, 1, 2]:
			for offset in offsets:
				lst.append(obs[agentPos[0] + offset[0]][agentPos[1] + offset[1]][i])
		
		obs = self.get_parent().world_objects.player_obs_discrete()
		
		lst = np.append(lst, obs)
		#print(lst)
		return np.array(lst)

	def perform_action(self, a):
		if a == 0:
			self.get_parent().setVec(0, -1)
		elif a == 1:
			self.get_parent().setVec(0, 1)
		elif a == 2:
			self.get_parent().setVec(-1, 0)
		elif a == 3:
			self.get_parent().setVec(1, 0)
		elif a == 4:
			self.get_parent().setVec(0, 0)
		elif a >= 5 and a <= 8:
			self.get_parent().place_bomb(self.actions[a])
			pass
			
	def calculate_reward(self, next, old):
		totalReward = 0
		
		totalReward += (next[5] - old[5]) + (old[4] - next[4]) #health reward
		distance = np.linalg.norm(self.position - self.last_position)
		if distance <= 3:
			totalReward -= 1
		else:
			totalReward += 5
		
		#playerPos = self.get_parent().world_objects.player.position
		#agentPos = self.get_parent().world_objects.agent.position
		#distance = math.sqrt((agentPos.x - playerPos.x)**2 + (agentPos.y - playerPos.y)**2)
		#totalReward -= distance
		
		return totalReward
			
	
	def store(self, state, action, reward, next_state, terminated):
		self.expirience_replay.append((state, action, reward, next_state, terminated))
		
	def build_compile_model(self):
		model = Sequential()
		#model.add(Embedding(self.state_size, 10, input_length=1))
		#model.add(Reshape((10,)))
		#model.add(Reshape(target_shape=(self.state_size,), input_shape=(1,self.state_size)))
		#model.add(Dense(self.state_size, input_shape = (1, ), kernel_initializer=initializers.Zeros(), bias_initializer=initializers.Zeros()))
		model.add(InputLayer(input_shape = (1, ), batch_size = 1))
		model.add(Dense(units = 256, kernel_initializer=initializers.Zeros(), bias_initializer=initializers.Zeros(), activation='relu'))
		model.add(Dense(units = 256, kernel_initializer=initializers.Zeros(), bias_initializer=initializers.Zeros(), activation='relu'))
		model.add(Dense(units = 64, kernel_initializer=initializers.Zeros(), bias_initializer=initializers.Zeros(), activation='relu'))
		model.add(Dense(self.action_size, activation='linear'))
		
		model.compile(loss='mse', optimizer=self.optimizer)
		return model
		
	def alighn_target_model(self):
		self.target_network.set_weights(self.q_network.get_weights())
		
	def act(self, state):
		if np.random.rand() <= self.epsilon:
			return random.randint(0, len(self.actions) - 1)

		q_values = self.q_network.predict(state, verbose = 0)
		print(q_values[0])
		return np.argmax(q_values[0])
		
	def retrain(self, batch_size):
		minibatch = random.sample(self.expirience_replay, batch_size)
		
		for state, action, reward, next_state, terminated in minibatch:
			
			target = self.q_network.predict(state, verbose = 0)
			
			if terminated:
				target[0][action] = reward
			else:
				t = self.target_network.predict(next_state, verbose = 0)
				target[0][action] = reward + self.gamma * np.amax(t)
			
			self.q_network.fit(state, target, epochs=1, verbose=0)
		self.alighn_target_model()
		return	
	
	
