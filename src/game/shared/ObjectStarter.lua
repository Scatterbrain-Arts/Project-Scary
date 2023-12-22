local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local require = require(script.Parent.loader).load(script)

local Binder = require("Binder")
local GeneralUtil = require("GeneralUtil")
local GetRemoteEvent = require("GetRemoteEvent")

local EventObjectSpawn = GetRemoteEvent("EventObjectSpawn")
local isSpawned = false

if RunService:IsServer() then
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			if not isSpawned then
				EventObjectSpawn:FireClient(player)
			end
		end)
	end)

	EventObjectSpawn.OnServerEvent:Connect(function(player, object)
		GeneralUtil:SetNetworkOwner(object, player)
		isSpawned = true
	end)
end


if RunService:IsClient() then
	local Doors = require("Doors")
	Doors.BINDER = Binder.new(Doors.TAG_NAME, Doors)
	Doors.BINDER:Start()

	local Objects = require("Objects")
	Objects.BINDER = Binder.new(Objects.TAG_NAME, Objects)
	Objects.BINDER:Start()
end


return {}