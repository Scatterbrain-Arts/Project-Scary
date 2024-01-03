local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false

function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	-- TODO: heuristic to choose from list of room with food
	Blackboard.objective.goalRoom = "Small"
	Blackboard.objective.currentRoom = self.navigation:FindRegionWithNPC()

	if not Blackboard.objective.currentRoom then
		warn("Did not find NPC...")
		isForceFail = true
		return
	end
	isForceFail = false
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if isForceFail then
		warn("Did not find NPC...")
		isForceFail = true
		return
	end

	return Blackboard.isObjectiveRoomReached ~= nil and SUCCESS or FAIL
end


return btTask
