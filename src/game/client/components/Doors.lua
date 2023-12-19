local CollectionService = game:GetService("CollectionService")

local require = require(script.Parent.loader).load(script)

local GeneralUtil = require("GeneralUtil")
local Maid = require("Maid")
local Binder = require("Binder")
local GetRemoteEvent = require("GetRemoteEvent")

local EventObjectSpawn = GetRemoteEvent("EventObjectSpawn")

local Doors = {}
Doors.__index = Doors
Doors.TAG_NAME = "Door"
Doors.TEXT_OPEN = "Open"
Doors.TEXT_CLOSE = "Close"

function Doors.new(doorInstance)
    local self = {}
    setmetatable(self, Doors)

	self.maid = Maid.new()
	self.name = doorInstance.Name
	self.entity = doorInstance
	self.model = GeneralUtil:Get("MeshPart", doorInstance, "Door", true)
	self.prompt = GeneralUtil:Get("ProximityPrompt", doorInstance, "ProximityPrompt", true)
	self.hinge = GeneralUtil:Get("HingeConstraint", doorInstance, "HingeConstraint", true)

	self.isClosed = math.floor(self.hinge.CurrentAngle) == 0 and true or false

	self.prompt.ActionText = self.isClosed and Doors.TEXT_OPEN or Doors.TEXT_CLOSE
	self.prompt.ObjectText = "Door"

	self.hinge.AngularResponsiveness = 20
	self.hinge.AngularSpeed = 40
	self.hinge.ServoMaxTorque = math.huge

	self.debounce = false
	self.prompt.Triggered:Connect(function(player)
		self.debounce = true
		if self.isClosed then
			print("open")
			self.hinge.TargetAngle = self.hinge.UpperAngle
			self.prompt.ActionText = Doors.TEXT_CLOSE
			self.isClosed = false
		else
			print("close")
			self.hinge.TargetAngle = self.hinge.LowerAngle
			self.prompt.ActionText = Doors.TEXT_OPEN
			self.isClosed = true
		end
		self.debounce = false
	end)

	self.hinge.Enabled = true
	print("spawned -- sending to server")
	EventObjectSpawn:FireServer(self.entity)

	return self
end







return Doors