local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	Blackboard.isMoving = self:MoveToNextIndex(true)

	self.maid:GiveTask(self.humanoid.MoveToFinished:Once(function()
		Blackboard.isMoving = false
		self:MoveToNextIndex(false)
	end))

	if Blackboard.nearestTarget.character then
		self:FindPath(self.navigationCurrent.waypoints[self.navigationCurrent.currentIndex].Position, Blackboard.nearestTarget.character.PrimaryPart.Position, self.navigationNext)

		self.navigationNext.currentIndex = 2
		self.navigationNext.nextIndex = 3
	end
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	--print("MoveToTarget-run")
	local Blackboard = obj.Blackboard
	local self = obj.self

	if not Blackboard.isPath then
		warn("MoveToTarget Task: No path...")
		return FAIL
	end

	if self.navigationCurrent.currentIndex == #self.navigationCurrent.waypoints then
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
