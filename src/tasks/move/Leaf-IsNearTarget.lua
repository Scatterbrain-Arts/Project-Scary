local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if Blackboard.isObjective then
		local distance = (self.root.Position - self.mind.objective.position).Magnitude
		Blackboard.isNear = distance <= self.config["body"].attackRange and true or false
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
		warn("Unexpected fail: Leaf-IsNearTarget...")
		return FAIL
	end
end


return btTask
