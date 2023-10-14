local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self


	if Blackboard.target.positionKnown then
		Blackboard.isPath = self:FindPath(self.root.Position, Blackboard.target.positionKnown, self.navigationNext)
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
		warn("FindPath Task: Unexpected fail...")
		return FAIL
	end
end


return btTask
