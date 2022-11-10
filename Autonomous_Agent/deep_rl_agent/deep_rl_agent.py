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
		self.episode = 0
		self.n_episodes = 300
		self.step = 0
		self.n_steps = 20000
		self.batchSize = 100
		self.cumulativeReward = 0
		self.action = 0
		self.terminated = False
		
	def godotToPython(self, array):
		lst_out = []
		for i in range(len(array)):
			if type(array[i]) is object:
				print("int")
				for j in flatten_recursively(array[i]):
					lst_out.append(j)
			else:
				lst_out.append(array[i])
		return lst_out
		
	def init(self):
		self.lastState = np.array(self.get_parent().world_objects.obs_discrete(), dtype=object)
		self.nextState = self.lastState
		
		for i in range(len(self.nextState)):
			print(not type(self.nextState[i]) is int)
		
		print(self.godotToPython(self.lastState))
		
		self.actions = ["UP", "DOWN", "LEFT", "RIGHT", "STAY", "TNT", "BIG_BOMB", "LAND_MINE", "C4"]
		self.stateSize = len(self.lastState)
		self.action_size = len(self.actions)
		
		#Experiences
		self.expirience_replay = deque(maxlen=2000)
		
		# Hyperparameters
		self.optimizer = Adam(learning_rate=0.00025)
		self.gamma = 0.999
		self.epsilon = 0.75
		
		# Build networks
		self.q_network = self.build_compile_model()
		self.target_network = self.build_compile_model()
		self.alighn_target_model()
		
	def _process(self, delta):
		#print("Comulative Reward: ", self.comulativeReward)
		#get_tree().reload_current_scene()
		
		while(self.step < self.n_steps):
			self.nextState = np.array(self.get_parent().world_objects.obs_discrete(), dtype=object)
			reward = self.calculate_reward()
			self.cumulativeReward += reward
			
			self.store(self.lastState, self.action, reward, self.nextState, self.terminated)
			
			self.lastState = self.nextState
			
			self.action = self.act(self.nextState)
			self.perform_action(self.action)
			
			if self.terminated:
				self.alighn_target_model()
				break
				
			if len(self.expirience_replay) > self.batchSize:
				pass
				#self.retrain(self.batchSize)
				#t = threading.Thread(target=self.retrain, args=(self.batchSize,))
				#t.start()
			
			self.step += 1

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
			
	def calculate_reward(self):
		if self.get_parent().world_objects.getPlayerHP() < 0:
			self.terminated = True
			return 1
		elif self.get_parent().world_objects.getAgentHP() < 0:
			self.terminated = True
			return 0
			
		totalReward = 0
		
		'''
		Rewards
		
		player_health_reward, player_shield_reward,
		agent_health_reward, agent_shield_reward,
		pickup_bombs_reward,
		pickup_xp_reward,
		pickup_hp_reward,
		destroy_walls_reward, 
		weaken_walls_reward
		'''
		
		rewardsWeight = [-0.1, -0.1, 0.05, 0.05, 0.001, 0.001, 0.001, 0.001, 0.001]
		rewards = self.get_parent().world_objects.get_rewards()
		
		for i in range(len(rewards)):
			totalReward += rewardsWeight[i]*rewards[i]
		
		return totalReward

	
	def store(self, state, action, reward, next_state, terminated):
		self.expirience_replay.append((state, action, reward, next_state, terminated))
		
	def build_compile_model(self):
		model = Sequential()
		model.add(InputLayer(input_shape = (1,), batch_size = 1))
		model.add(Dense(units = 64, kernel_initializer=initializers.RandomNormal(0, 1), bias_initializer=initializers.Zeros(), activation='relu'))
		model.add(Dense(units = 64, kernel_initializer=initializers.RandomNormal(0, 1), bias_initializer=initializers.Zeros(), activation='relu'))
		model.add(Dense(self.action_size, activation='linear'))
		
		model.compile(loss='mse', optimizer=self.optimizer)
		return model
		
	def alighn_target_model(self):
		self.target_network.set_weights(self.q_network.get_weights())
		
	def act(self, state):
		if np.random.rand() <= self.epsilon:
			return random.randint(0, len(self.actions) - 1)

		q_values = self.q_network.predict(state, verbose = 0)
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
		return	
	
	
