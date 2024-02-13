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

	Blackboard.isObjectivePositionReached = GeneralUtil:IsDistanceLess(self.root.Position, Blackboard.objective.walkToInstance.Position, 1, true)
	return Blackboard.isObjectivePositionReached and SUCCESS or FAIL
end


return btTask
