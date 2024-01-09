local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local ServiceBag = require("ServiceBag")
local GetRemoteEvent = require("GetRemoteEvent")

local GeneralUtil = require("GeneralUtil")

local EventObjectLoaded = GetRemoteEvent("EventObjectLoaded")

local next = next

local ObjectOwnershipService = {}
ObjectOwnershipService.ServiceName = "ObjectOwnershipService"


function ObjectOwnershipService:Init(serviceBag)
	assert(ServiceBag.isServiceBag(serviceBag), "Not valid a service bag...")

	self.maid = Maid.new()
end


function ObjectOwnershipService:Start()
	-- Set Owner for Objects
	EventObjectLoaded.OnServerEvent:Connect(function(player, instancesAdded)
		if next(instancesAdded) then
			for _, instance in instancesAdded do
				GeneralUtil:SetNetworkOwner(instance, player)
			end
		end
	end)
end


function ObjectOwnershipService:Destroy()
    self.maid:DoCleaning()
end


return ObjectOwnershipService