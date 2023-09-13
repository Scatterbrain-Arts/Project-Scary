local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	self:MoveToNextIndex()
	Blackboard.isMoving = true

	self.maid:GiveTask(self.humanoid.MoveToFinished:Once(function()
		Blackboard.isMoving = false

		self.navigation.currentIndex = self.navigation.nextIndex
		if self.navigation.nextIndex < #self.navigation.waypoints then
			self.navigation.nextIndex += 1
		end
	end))
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if not Blackboard.isPath then
		warn("MoveToTarget Task: No path...")
		return FAIL
	end

	if self.navigation.currentIndex == #self.navigation.waypoints then
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
