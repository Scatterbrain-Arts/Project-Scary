local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if not Blackboard.objective or not Blackboard.objective.goal or Blackboard.objective.current then
		warn("Objective is nil...")
		isForceFail = true
		return
	end
	isForceFail = false

	Blackboard.objective.currentRoom = self.navigation:FindRegionWithNPC()
	Blackboard.isObjectiveRoomReached = Blackboard.objective.currentRoom == Blackboard.objective.goalRoom
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if isForceFail then
		return FAIL
	end

	return Blackboard.isObjectiveRoomReached and SUCCESS or FAIL
end


return btTask
