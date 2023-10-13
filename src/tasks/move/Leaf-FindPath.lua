local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self


	if Blackboard.target.isActive then
		Blackboard.isPath = self:FindPath(self.root.Position, Blackboard.target.positionKnown, self.navigationNext)

		if self.isDebug then
			self.DebugService:TargetAddIndicator(Blackboard.target.object)
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
