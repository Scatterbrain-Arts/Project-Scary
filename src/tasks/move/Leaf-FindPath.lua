local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self


	if Blackboard.isObjective then
		Blackboard.isPath = self.body:FindPath(self.root.Position, self.mind.objective.position, self.body.navigationNext)
	end
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if Blackboard.isPath then
		return SUCCESS
	elseif not Blackboard.isPath then
		return FAIL
	else
		warn("Unexpected fail: Leaf-FindPath...")
		return FAIL
	end
end


return btTask
