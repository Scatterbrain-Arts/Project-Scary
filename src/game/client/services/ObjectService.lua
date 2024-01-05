local RunService = game:GetService("RunService")

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local ServiceBag = require("ServiceBag")
local GetRemoteEvent = require("GetRemoteEvent")

local EventObjectLoaded = GetRemoteEvent("EventObjectLoaded")

local ObjectService = {}
ObjectService.ServiceName = "ObjectService"


function ObjectService:Init(serviceBag)
    assert(ServiceBag.isServiceBag(serviceBag), "Not valid a service bag...")
	self.maid = Maid.new()

	self.instancesAdded = {}
	self.objects = {}
end


function ObjectService:AddObject(type, object, instance)
	if not self.instancesAdded[type] then
		self.instancesAdded[type] = {}
	end
	table.insert(self.instancesAdded[type], instance)

	if not self.objects[type] then
		self.objects[type] = {}
	end
	table.insert(self.objects[type], object)	-- array of objects
	self.objects[type][instance] = object		-- set of objects, indexed by instance
end


function ObjectService:FinishObject(type)
	EventObjectLoaded:FireServer(self.instancesAdded[type])
	self.instancesAdded[type] = nil
end


function ObjectService:GetType(type)
	return self.objects[type]
end


function ObjectService:Destroy()
    self.maid:DoCleaning()
end


return ObjectService