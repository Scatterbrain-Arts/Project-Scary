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

	local index = #self.objects[type] + 1
	table.insert(self.objects[type], object)	-- array of objects
	self.objects[type][instance] = index		-- set object indexes, indexed by instance
end


function ObjectService:FinishAddObject(type)
	EventObjectLoaded:FireServer(self.instancesAdded[type])
	self.instancesAdded[type] = nil
end


function ObjectService:RemoveObject(type, instance)
	if not self.objects[type][instance] then
		warn("Object not found...")
		return
	end

	local index = self.objects[type][instance]
	self.objects[type][index] = nil
	self.objects[type][instance] = nil
end


function ObjectService:PrintObjects(type)
	print(self.objects[type])
end


function ObjectService:GetType(type)
	return self.objects[type]
end


function ObjectService:Destroy()
    self.maid:DoCleaning()
end


return ObjectService