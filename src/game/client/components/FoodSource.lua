local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local GetRemoteEvent = require("GetRemoteEvent")
local FoodObject = require("FoodObject")

local EventObjectSpawn = GetRemoteEvent("EventObjectSpawn")

local FoodSource = {}
FoodSource.__index = FoodSource
FoodSource.TAG_NAME = "Food_Source"
FoodSource.instances = {}

function FoodSource.new(objectInstance)
    local self = {}
    setmetatable(self, FoodSource)

	self.maid = Maid.new()
	self.name = objectInstance.Name
	self.entity = objectInstance
	self.model = objectInstance.Model.bowl

	self.foodObjects = {}

	for _, object in objectInstance.Objects:GetChildren() do
		if object then
			local food = FoodObject.new(object)
			table.insert(self.foodObjects, food)
		end
	end


	function self:activate()
		if next(self.foodObjects) ~= nil then
			local foodObject = table.remove(self.foodObjects, #self.foodObjects)
			foodObject:EatObject()
		else
			FoodSource.instances[self.model] = nil
			self.model:Destory()
			self = nil
		end
	end

	EventObjectSpawn:FireServer(self.entity, "FoodSource")
	FoodSource.instances[objectInstance] = self

	return self
end







return FoodSource