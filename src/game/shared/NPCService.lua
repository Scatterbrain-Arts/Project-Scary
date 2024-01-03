local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local require = require(script.Parent.loader).load(script)

local GeneralUtil = require("GeneralUtil")
local Signal = require("Signal")

local NPCService = {}

NPCService.objects = {}
NPCService.npc = nil
NPCService.SignalAddObject = Signal.new()
NPCService.SignalAddNPC = Signal.new()


NPCService.SignalAddObject:Connect(function(obj, type)
	if type == "FoodSource" then
		if not NPCService.objects["FoodSource"] then
			NPCService.objects["FoodSource"] = {}
		end
		print("sig obj recieve ", obj)
		table.insert(NPCService.objects["FoodSource"], obj)
	end
end)

NPCService.SignalAddNPC:Connect(function(npc)
	print("sig npc recieve ", npc)
	NPCService.npc = npc
end)


function NPCService:GetFoodSource()
	print(NPCService.objects["FoodSource"])
end






return NPCService