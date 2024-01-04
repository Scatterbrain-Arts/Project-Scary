local RunService = game:GetService("RunService")

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local ServiceBag = require("ServiceBag")
local GetRemoteEvent = require("GetRemoteEvent")

local EventObjectLoaded = GetRemoteEvent("EventObjectLoaded")
local EventNPCLoaded = GetRemoteEvent("EventNPCLoaded")

local next = next

local ObjectService = {}
ObjectService.ServiceName = "ObjectService"


function ObjectService:Init(serviceBag)
    assert(ServiceBag.isServiceBag(serviceBag), "Not valid a service bag...")

	self.maid = Maid.new()

	self.objectsSpawned = {}
	self.objectsLoaded = {}

	self.objectInstancesSpawned = {}
	self.objectInstancesLoaded = {}

	self.player = nil
	self.npc = nil
end


function ObjectService:Start()
	local objectLoadedConnection = nil
	local tickLast = tick()
	objectLoadedConnection = RunService.Heartbeat:Connect(function()
		if tick() - tickLast > 1 then
			print("checking objects spawned...")
			tickLast = tick()
			if next(self.objectInstancesSpawned) == nil then
				print("send to set owner")

				EventObjectLoaded:FireServer( self.objectInstancesLoaded )
				objectLoadedConnection:Disconnect()
			end
		end
	end)
end


function ObjectService:ObjectSpawnAdd(type, object, instance)
	if not self.objectsSpawned[type] then
		self.objectsSpawned[type] = {}
	end

	if not self.objectInstancesSpawned[type] then
		self.objectInstancesSpawned[type] = {}
	end

	table.insert(self.objectsSpawned[type], object)
	table.insert(self.objectInstancesSpawned[type], instance)
end


function ObjectService:ObjectSpawnComplete(type)
	self.objectsLoaded[type] = self.objectsSpawned[type]
	self.objectsSpawned[type] = nil

	self.objectInstancesLoaded[type] = self.objectInstancesSpawned[type]
	self.objectInstancesSpawned[type] = nil
end


function ObjectService:Destroy()
    self.maid:DoCleaning()
end


return ObjectService