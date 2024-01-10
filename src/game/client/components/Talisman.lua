local CollectionService = game:GetService("CollectionService")

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local ServiceBag = require("ServiceBag")

local GeneralUtil = require("GeneralUtil")

local Talisman = {}
Talisman.__index = Talisman
Talisman.TAG_NAME = "Talisman"
Talisman.total = #CollectionService:GetTagged(Talisman.TAG_NAME)
Talisman.count = 0

function Talisman.new(objectInstance, serviceBag)
    local self = {}
    setmetatable(self, Talisman)

	assert(ServiceBag.isServiceBag(serviceBag), "Not valid a service bag...")
	self._objectService = serviceBag:GetService(require("ObjectService"))

	self.maid = Maid.new()
	self.name = objectInstance.Name
	self.instance = objectInstance
	self.model = objectInstance.mesh
	self.navStart = objectInstance.NavStart
	self.room = objectInstance.room.Value
	self.lock = objectInstance.lock.Value

	self.debounce = false
	self.prompt = GeneralUtil:Get(nil, objectInstance, "ProximityPrompt", true)

	self.prompt.Triggered:Connect(function(player)
		if self.debounce then
			return
		end

		self.debounce = true
		self.model.Transparency = 1

		self.prompt.Enabled = false
		self.debounce = false
	end)

	Talisman.count += 1
	self._objectService:AddObject(Talisman.TAG_NAME, self, self.instance)

	if Talisman.count == Talisman.total then
		self._objectService:FinishAddObject(Talisman.TAG_NAME)
	end


	self.prompt.Enabled = true

	return self
end


return Talisman