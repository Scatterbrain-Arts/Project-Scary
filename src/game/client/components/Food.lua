local CollectionService = game:GetService("CollectionService")

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local ServiceBag = require("ServiceBag")

local Food = {}
Food.__index = Food
Food.TAG_NAME = "Food"
Food.total = #CollectionService:GetTagged(Food.TAG_NAME)
Food.count = 0
Food.instances = {}

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

	function self:EatObject()
		Food.instances[self.model] = nil
		self.model:Destory()
		self = nil
	end

	Food.count += 1
	self._objectService:AddObject(Food.TAG_NAME, self, self.instance)
	Food.instances[objectInstance] = self

	if Food.count == Food.total then
		self._objectService:FinishObject(Food.TAG_NAME)
	end

	return self
end


return Food