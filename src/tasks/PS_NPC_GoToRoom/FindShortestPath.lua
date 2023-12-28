local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if not self.navigation.objective.goal then
		self.navigation.objective.goal = "Small"
	elseif self.navigation.objective.goal == "Large" then
		self.navigation.objective.goal = "Small"
	elseif self.navigation.objective.goal == "Small" then
		self.navigation.objective.goal = "Large"
	end

	self.navigation.objective.current = self.navigation:FindRegionWithNPC()
	local _, reversePath = self.navigation:FindShortestPath(self.navigation.objective.current, self.navigation.objective.goal)

	table.remove(reversePath, #reversePath)
	Blackboard.reversePath = reversePath
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	return Blackboard.reversePath and SUCCESS or FAIL
end


return btTask
