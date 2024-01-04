local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local ServiceBag = require("ServiceBag")
local GetRemoteEvent = require("GetRemoteEvent")

local GeneralUtil = require("GeneralUtil")

local ObjectOwnershipService = {}
ObjectOwnershipService.ServiceName = "ObjectOwnershipService"


function ObjectOwnershipService:Init(serviceBag)
	assert(ServiceBag.isServiceBag(serviceBag), "Not valid a service bag...")

	self.maid = Maid.new()

	self.EventObjectLoaded = GetRemoteEvent("EventObjectLoaded")
	self.EventNPCLoaded = GetRemoteEvent("EventNPCLoaded")
end


function ObjectOwnershipService:Start()

	-- Set Owner for Objects
	self.EventObjectLoaded.OnServerEvent:Connect(function(player, objectsInstancesLoaded)
		if objectsInstancesLoaded and next(objectsInstancesLoaded) ~= nil then
			for objectType, objects in objectsInstancesLoaded do
				for _, instance in objects do
					GeneralUtil:SetNetworkOwner(instance, player)
				end
			end
		end
	end)

	-- Set Owner for NPC
	self.EventNPCLoaded.OnServerEvent:Connect(function(player, objectsInstancesLoaded)
		if objectsInstancesLoaded and next(objectsInstancesLoaded) ~= nil then
			for objectType, objects in objectsInstancesLoaded do
				for _, instance in objects do
					GeneralUtil:SetNetworkOwner(instance, player)
				end
			end
		end
	end)
end




function ObjectOwnershipService:Destroy()
    self.maid:DoCleaning()
end


return ObjectOwnershipService