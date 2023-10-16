local PRIORITY_HIGH, PRIORITY_MED, PRIORITY_LOW = 3, 2, 1

local AiComponentSoul = {}
AiComponentSoul.__index = AiComponentSoul


function AiComponentSoul.new(AiBodyInstance, serviceBag)
    local self = {}
    setmetatable(self, AiComponentSoul)

	return self
end


return AiComponentSoul