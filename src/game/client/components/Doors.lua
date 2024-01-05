local CollectionService = game:GetService("CollectionService")

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local ServiceBag = require("ServiceBag")

local GeneralUtil = require("GeneralUtil")

local Doors = {}
Doors.__index = Doors
Doors.TAG_NAME = "Door"
Doors.TEXT_OPEN = "Open"
Doors.TEXT_CLOSE = "Close"
Doors.totalDoors = #CollectionService:GetTagged(Doors.TAG_NAME)
Doors.count = 0

Doors.instances = {}
Doors.names = {}

function Doors.new(doorInstance, serviceBag)
    local self = {}
    setmetatable(self, Doors)

	assert(ServiceBag.isServiceBag(serviceBag), "Not valid a service bag...")
	self._objectService = serviceBag:GetService(require("ObjectService"))

	self.maid = Maid.new()
	self.name = doorInstance.Name
	self.instance = doorInstance
	self.model = GeneralUtil:Get("MeshPart", doorInstance, "Door", true)
	self.prompt = GeneralUtil:Get("ProximityPrompt", doorInstance, "ProximityPrompt", true)
	self.hinge = GeneralUtil:Get("HingeConstraint", doorInstance, "HingeConstraint", true)
	self.position = self.model.Position

	self.isClosed = math.floor(self.hinge.CurrentAngle) == 0 and true or false

	self.prompt.ObjectText = "Door"
	self.prompt.ActionText = self.isClosed and Doors.TEXT_OPEN or Doors.TEXT_CLOSE

	self.hinge.AngularResponsiveness = 20
	self.hinge.AngularSpeed = 40
	self.hinge.ServoMaxTorque = math.huge

	self.debounce = false
	self.prompt.Triggered:Connect(function(player) self:activate() end)

	function self:activate()
		if self.debounce then
			return
		end

		self.debounce = true
		if self.isClosed then
			self.hinge.TargetAngle = self.hinge.UpperAngle
			self.prompt.ActionText = Doors.TEXT_CLOSE
			self.isClosed = false
		else
			self.hinge.TargetAngle = self.hinge.LowerAngle
			self.prompt.ActionText = Doors.TEXT_OPEN
			self.isClosed = true
		end
		self.debounce = false
	end

	self.hinge.Enabled = true

	Doors.count += 1
	self._objectService:AddObject(Doors.TAG_NAME, self, self.instance)
	Doors.instances[doorInstance] = self
	Doors.names[doorInstance.Name] = self

	if Doors.count == Doors.totalDoors then
		self._objectService:FinishObject(Doors.TAG_NAME)
	end

	return self
end


return Doors