local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	Blackboard.isMoving = self.body:MoveToNextIndex(true)

	self.body.maid:GiveTask(self.humanoid.MoveToFinished:Once(function()
		Blackboard.isMoving = false
		self.body:MoveToNextIndex(false)
	end))

	if Blackboard.isObjective then
		self.body:FindPath(self.body.navigationCurrent.waypoints[self.body.navigationCurrent.currentIndex].Position, self.mind.objective.position, self.body.navigationNext)

		self.body.navigationNext.currentIndex = 1
		self.body.navigationNext.nextIndex = 2
	end
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if status == FAIL then
		self.body:StopPathing()
		Blackboard.isMoving = false
	end
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if self.mind.needAttention then
		warn("MoveToTarget Task: Attention needed else where...")
		return FAIL
	end

	if not Blackboard.isPath then
		warn("MoveToTarget Task: No path...")
		return FAIL
	end

	if self.body.navigationCurrent.currentIndex == #self.body.navigationCurrent.waypoints then
		warn("MoveToTarget Task: Reached end of path...")
		return FAIL
	end

	if Blackboard.isMoving then
		return RUNNING
	elseif not Blackboard.isMoving then
		return SUCCESS
	else
		warn("MoveToTarget Task: Unexpected fail...")
		return FAIL
	end
end


return btTask
