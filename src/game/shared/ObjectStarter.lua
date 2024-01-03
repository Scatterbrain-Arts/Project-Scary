local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local require = require(script.Parent.loader).load(script)

local Binder = require("Binder")
local GeneralUtil = require("GeneralUtil")
local GetRemoteEvent = require("GetRemoteEvent")
local NPCService = require("NPCService")

local EventObjectSpawn = GetRemoteEvent("EventObjectSpawn")


if RunService:IsServer() then
	EventObjectSpawn.OnServerEvent:Connect(function(player, object, type)
		GeneralUtil:SetNetworkOwner(object, player)
		NPCService.SignalAddObject:Fire(object, type)
	end)
end


if RunService:IsClient() then
	local Doors = require("Doors")
	Doors.BINDER = Binder.new(Doors.TAG_NAME, Doors)
	Doors.BINDER:Start()

	-- local Objects = require("Objects")
	-- Objects.BINDER = Binder.new(Objects.TAG_NAME, Objects)
	-- Objects.BINDER:Start()

	local FoodSource = require("FoodSource")
	FoodSource.BINDER = Binder.new(FoodSource.TAG_NAME, FoodSource)
	FoodSource.BINDER:Start()
end


return {}