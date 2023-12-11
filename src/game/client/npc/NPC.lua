local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local require = require(script.Parent.loader).load(script)

local BehaviorTreeCreator = require("BehaviorTreeCreator")
local GetRemoteEvent = require("GetRemoteEvent")
local Maid = require("Maid")

local EventNPCSpawn = GetRemoteEvent("EventNPCSpawn")

local NPCDebug = require("NPCDebug")
local GeneralUtil = require("GeneralUtil")
local Navigation = require("Navigation")
local NPCSoundDetection = require("NPCSoundDetection")

local NPC = {}
NPC.__index = NPC
NPC.TAG_NAME = "NPC"

function NPC.new(npcModel, player)
    local self = {}
    setmetatable(self, NPC)

	self.name = "Pepe"
	self.maid = Maid.new()

	self.character = npcModel or warn("No instance found for ", self.name, "...")
	self.humanoid = npcModel:FindFirstChild("Humanoid") or warn("No humanoid found for", self.name, "...")
	self.root = npcModel:FindFirstChild("HumanoidRootPart") or warn("No root found for", self.name, "...")

	local configFolder = GeneralUtil:Get("Folder", self.character, "config")

	self.config = {
		isDebug = GeneralUtil:GetBool(configFolder, "_DEBUG"),
		isOverride = GeneralUtil:GetBool(configFolder, "_OVERRIDE"),
	}

	if self.config.isDebug.Value then
		self.NPCDebug = NPCDebug.new(self)
	end

	self.player = player
	self.playerCharacter = player.Character or player.CharacterAdded:Wait()
	Players.PlayerAdded:Connect(function(player)
		self.player = player
		player.CharacterAdded:Connect(function(character)
			self.playerCharacter = character
		end)
	end)

	self.btRoot = BehaviorTreeCreator:Create(ReplicatedStorage.Trees.PS_NPC_Start, self)
	self.btState = {
		self = self,
		Blackboard = {
			defaultWaitTime = 2,
			player = player,
			targetPosition = Vector3.new(math.huge, math.huge, math.huge),
			target = nil,
			collisionGroup = "RayNPC",
			state = shared.npc.states.perception.calm,
			isSoundHeard = false,
		},
	}

	self.navigation = Navigation.new(self)
	self.soundDetection = NPCSoundDetection.new(self)

    RunService.Heartbeat:Connect(function(time, deltaTime)
		if not self.config.isOverride.Value then
			self.btRoot:Run(self.btState)

			if self.config.isDebug.Value then
				self.NPCDebug:UpdateBehaviorTreeIndicator(self.btState.Blackboard.node.Name, false)
			end
		end
	end)

	EventNPCSpawn:FireServer(self.character)

	return self
end



return NPC