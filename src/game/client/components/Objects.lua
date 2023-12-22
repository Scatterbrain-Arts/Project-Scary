local CollectionService = game:GetService("CollectionService")

local require = require(script.Parent.loader).load(script)

local GeneralUtil = require("GeneralUtil")
local Maid = require("Maid")
local Binder = require("Binder")
local GetRemoteEvent = require("GetRemoteEvent")

local EventObjectSpawn = GetRemoteEvent("EventObjectSpawn")

local Objects = {}
Objects.__index = Objects
Objects.TAG_NAME = "Object"
Objects.TEXT_ON = "Enable"
Objects.TEXT_OFF = "Disable"
Objects.instances = {}

function Objects.new(objectInstance)
    local self = {}
    setmetatable(self, Objects)

	self.maid = Maid.new()
	self.name = objectInstance.Name
	self.entity = objectInstance
	self.model = GeneralUtil:Get("MeshPart", objectInstance, "model", true)
	self.prompt = GeneralUtil:Get("ProximityPrompt", objectInstance, "ProximityPrompt", true)
	self.position = self.model.Position

	self.isOff = self.model.Material == Enum.Material.Plastic and true or false

	self.prompt.ObjectText = "Object"
	self.prompt.ActionText = self.isOff and Objects.TEXT_ON or Objects.TEXT_OFF

	self.debounce = false
	self.prompt.Triggered:Connect(function(player) self:activate() end)

	function self:activate()
		if self.debounce then
			return
		end

		self.debounce = true
		if self.isOff then
			print("enable")
			self.model.Material = Enum.Material.Neon
			self.prompt.ActionText = Objects.TEXT_OFF
			self.isOff = false
		else
			print("disable")
			self.model.Material = Enum.Material.Plastic
			self.prompt.ActionText = Objects.TEXT_ON
			self.isOff = true
		end
		self.debounce = false
	end

	EventObjectSpawn:FireServer(self.entity)
	Objects.instances[objectInstance] = self

	return self
end







return Objects