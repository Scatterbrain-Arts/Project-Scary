local Packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local GeneralUtil = require(Packages.GeneralUtil)

local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if not Blackboard.objective or not Blackboard.objective.actionObject or not Blackboard.objective.actionPosition then
		warn("Objective is nil...")
		isForceFail = true
		return
	end
	isForceFail = false

	Blackboard.isActionPositionReached = GeneralUtil:IsDistanceLess(self.root.Position, Blackboard.objective.actionPosition, 1)
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if isForceFail then
		return FAIL
	end

	return Blackboard.isActionPositionReached and SUCCESS or FAIL
end


return btTask
