local require = require(script.Parent.loader).load(script)

local Binder = require("Binder")
local GetRemoteEvent = require("GetRemoteEvent")

print("hibinder")

local Doors = require("Doors")
Doors.BINDER = Binder.new(Doors.TAG_NAME, Doors)
Doors.BINDER:Start()

--local Objects = require("Objects")
--Objects.BINDER = Binder.new(Objects.TAG_NAME, Objects)
--Objects.BINDER:Start()

-- local FoodSource = require("FoodSource")
-- FoodSource.BINDER = Binder.new(FoodSource.TAG_NAME, FoodSource)
-- FoodSource.BINDER:Start()


return {}