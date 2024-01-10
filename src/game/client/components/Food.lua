local CollectionService = game:GetService("CollectionService")

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local ServiceBag = require("ServiceBag")

local GeneralUtil = require("GeneralUtil")

local Food = {}
Food.__index = Food
Food.TAG_NAME = "Food"
Food.total = #CollectionService:GetTagged(Food.TAG_NAME)
Food.count = 0

function Food.new(objectInstance, serviceBag)
    local self = {}
    setmetatable(self, Food)

	assert(ServiceBag.isServiceBag(serviceBag), "Not valid a service bag...")
	self._objectService = serviceBag:GetService(require("ObjectService"))

	self.maid = Maid.new()
	self.name = objectInstance.Name
	self.instance = objectInstance
	self.model = objectInstance.mesh
	self.navStart = objectInstance.NavStart
	self.room = objectInstance.room.Value

	function self:EatObject(hand)
		GeneralUtil:WeldTo(hand, self.model)

		task.wait(2)

		self._objectService:RemoveObject(Food.TAG_NAME, self.instance, self)
		self = nil
		Food.count -= 1
	end


	Food.count += 1
	self._objectService:AddObject(Food.TAG_NAME, self, self.instance)

	if Food.count == Food.total then
		self._objectService:FinishAddObject(Food.TAG_NAME)
	end

	return self
end


return Food