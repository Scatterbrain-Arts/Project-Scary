local Packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local GeneralUtil = require(Packages.GeneralUtil)

local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if not Blackboard.isObjectiveRoomReached then
		warn("Room failed...")
		return FAIL
	end

	if not Blackboard.isActionPositionReached then
		warn("Position failed...")
		return FAIL
	end

	if not Blackboard.isActionPositionAligned then
		warn("Align failed...")
		return FAIL
	end


	return SUCCESS
end


return btTask
