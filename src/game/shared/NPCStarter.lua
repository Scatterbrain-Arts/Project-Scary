local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local require = require(script.Parent.loader).load(script)

local GeneralUtil = require("GeneralUtil")
local GetRemoteEvent = require("GetRemoteEvent")

local EventNPCSpawn = GetRemoteEvent("EventNPCSpawn")

local npcstarter = {}

if RunService:IsServer() then

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			EventNPCSpawn:FireClient(player)
		end)
	end)

	EventNPCSpawn.OnServerEvent:Connect(function(player, npc)
		GeneralUtil:SetNetworkOwner(npc, player)
	end)
end


if RunService:IsClient() then
	local NPC = require("NPC")
	local NPCModel = CollectionService:GetTagged(NPC.TAG_NAME)[1]

	EventNPCSpawn.OnClientEvent:Connect(function()
		local NPCEntity = NPC.new(NPCModel, Players.LocalPlayer)
	end)
end









return npcstarter