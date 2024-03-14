local Packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local GeneralUtil = require(Packages.GeneralUtil)

local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if not Blackboard.objective.interactObject or not Blackboard.objective.walkToInstance then
		warn("InteractObject or WalkToInstance is nil...")
		isForceFail = true
		return
	end

	Blackboard.isObjectivePositionReached = GeneralUtil:IsDistanceLess(self.root.Position, Blackboard.objective.walkToInstance.Position, 1, true)
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self

	isForceFail = false
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if isForceFail then
		return FAIL
	end

	return Blackboard.isObjectivePositionReached and SUCCESS or FAIL
end


return btTask
