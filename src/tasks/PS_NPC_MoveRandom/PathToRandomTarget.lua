local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	Blackboard.target = nil
	Blackboard.targetPosition = self.navigation:PathToRandomTarget()
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if not Blackboard.targetPosition then
		return FAIL
	end

	if Blackboard.isSoundHeard then
		return FAIL
	end

	return (Blackboard.isTargetReached == false and RUNNING) or (Blackboard.isTargetReached == true and SUCCESS) or FAIL
end


return btTask
