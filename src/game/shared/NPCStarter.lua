local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local require = require(script.Parent.loader).load(script)

local GeneralUtil = require("GeneralUtil")
local GetRemoteEvent = require("GetRemoteEvent")
local NPCService = require("NPCService")

local EventNPCSpawn = GetRemoteEvent("EventNPCSpawn")


if RunService:IsServer() then

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			EventNPCSpawn:FireClient(player)
		end)
	end)

	EventNPCSpawn.OnServerEvent:Connect(function(player, npc)
		GeneralUtil:SetNetworkOwner(npc, player)
		NPCService.SignalAddNPC:Fire(npc)
	end)
end


if RunService:IsClient() then
	local NPC = require("NPC")
	local NPCModel = CollectionService:GetTagged(NPC.TAG_NAME)[1]

	EventNPCSpawn.OnClientEvent:Connect(function()
		local NPCEntity = NPC.new(NPCModel, Players.LocalPlayer)
	end)
end



return {}