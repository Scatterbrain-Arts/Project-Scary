local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local require = require(script.Parent.loader).load(script)

local Binder = require("Binder")
local GeneralUtil = require("GeneralUtil")
local GetRemoteEvent = require("GetRemoteEvent")

local EventObjectSpawn = GetRemoteEvent("EventObjectSpawn")

if RunService:IsServer() then
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			print("characted added - fire client to spawn")
			EventObjectSpawn:FireClient(player)
		end)
	end)

	EventObjectSpawn.OnServerEvent:Connect(function(player, object)
		print("received --setting owner")
		GeneralUtil:SetNetworkOwner(object, player)
	end)
end


if RunService:IsClient() then
	local Doors = require("Doors")

	print("recieved - spawning")
	Doors.BINDER = Binder.new(Doors.TAG_NAME, Doors)
	Doors.BINDER:Start()
end


return {}