local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false
local isInitalized = false


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if not Blackboard.lastKnownRegion then
		warn("Target lastKnownRegion is nil...")
		isForceFail = true
		return
	end

	Blackboard.targetPosition = self.navigation:PathToRandomTargetInRegion(Blackboard.lastKnownRegion)
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if isForceFail or not Blackboard.targetPosition then
		return FAIL
	end

	if not isInitalized then
		Blackboard.isSoundHeard = false
		isInitalized = true
	end

	if Blackboard.isSoundHeard then
		Blackboard.isTargetLost = false
		return FAIL
	end

	return (Blackboard.isTargetReached == false and RUNNING) or (Blackboard.isTargetReached == true and SUCCESS) or FAIL
end


return btTask