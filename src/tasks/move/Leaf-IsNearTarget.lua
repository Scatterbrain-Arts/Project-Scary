local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if self.mind.objective.positionKnown then
		local distance = (self.root.Position - self.mind.objective.positionKnown).Magnitude

		if distance <= self.config["body"].attackRange then
			Blackboard.isNear = true
		else
			Blackboard.isNear = false
		end
	end
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if Blackboard.isNear then
		return SUCCESS
	elseif not Blackboard.isNear then
		return FAIL
	else
		warn("IsNearTarget Task: Unexpected fail...")
		return FAIL
	end
end


return btTask
