local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local require = require(script.Parent.loader).load(script)

local GeneralUtil = require("GeneralUtil")
local NPC = require("NPC")

local npcstarter = {}

local NPCModel = CollectionService:GetTagged(NPC.TAG_NAME)[1]
local NPCEntity = nil

Players.PlayerAdded:Connect(function(player)
	NPCEntity = NPC.new(NPCModel, player)
	GeneralUtil:SetNetworkOwner(NPCEntity.character, player)
end)

return npcstarter