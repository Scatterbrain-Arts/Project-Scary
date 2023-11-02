local require = require(script.Parent.loader).load(script)

local PRIORITY_HIGH, PRIORITY_MED, PRIORITY_LOW = 3, 2, 1

local AiComponentSoul = {}
AiComponentSoul.__index = AiComponentSoul


function AiComponentSoul.new(entity, serviceBag)
    local self = {}
    setmetatable(self, AiComponentSoul)

    self.entity = entity

	return self
end


return AiComponentSoul