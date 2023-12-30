local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	Blackboard.lastKnownPosition = Blackboard.targetPosition
	Blackboard.lastKnownRegion = self.navigation:FindRegionWithPlayer()
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if Blackboard.lastKnownRegion then
		return SUCCESS
	else
		Blackboard.target = nil
		Blackboard.targetPosition = nil
		Blackboard.isTargetLost = nil
		Blackboard.lastKnownPosition = nil
		Blackboard.lastKnownRegion = nil
		return FAIL
	end
end


return btTask
