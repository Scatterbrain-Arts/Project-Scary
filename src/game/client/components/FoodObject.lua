local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local GetRemoteEvent = require("GetRemoteEvent")

local EventObjectSpawn = GetRemoteEvent("EventObjectSpawn")

local Food = {}
Food.__index = Food
Food.TAG_NAME = "Food_Object"
Food.instances = {}

function Food.new(objectInstance)
    local self = {}
    setmetatable(self, Food)

	self.maid = Maid.new()
	self.name = objectInstance.Name
	self.model = objectInstance

	function self:EatObject()
		Food.instances[self.model] = nil
		self.model:Destory()
		self = nil
	end

	EventObjectSpawn:FireServer(self.model, "Food")
	Food.instances[objectInstance] = self

	return self
end


return Food