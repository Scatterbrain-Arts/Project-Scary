local Packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local RunService = game:GetService("RunService")
local GeneralUtil = require(Packages.GeneralUtil)

local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self
	local objective = Blackboard.objective

	local doorOutsideOfNextRoom = self.navigation.doorsRooms[objective.currentRoom][objective.reversePathToGoalRoom[#objective.reversePathToGoalRoom]]
	if not doorOutsideOfNextRoom or not doorOutsideOfNextRoom:IsA("BasePart") then
		warn("Door Outside is nil...")
		warn("currentRoom: ", objective.currentRoom, " goalRoom: ", objective.goalRoom, " reversePathToGoalRoom: ", objective.reversePathToGoalRoom)
		isForceFail = true
		return
	end

	self.navigation:PathToTarget(doorOutsideOfNextRoom.Position)
	table.remove(objective.reversePathToGoalRoom, #objective.reversePathToGoalRoom)
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self

	isForceFail = false
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self
	local objective = Blackboard.objective


	if isForceFail then
		return FAIL
	end

	if Blackboard.isTargetReached then
		local reachedRoom = self.navigation:FindRegionWithNPC()
		if objective.currentRoom ~= reachedRoom then
			objective.currentRoom = reachedRoom
		end

		if objective.currentRoom ~= objective.goalRoom then
			local doorOutsideOfNextRoom = self.navigation.doorsRooms[objective.currentRoom][objective.reversePathToGoalRoom[#objective.reversePathToGoalRoom]]
			if not doorOutsideOfNextRoom or not doorOutsideOfNextRoom:IsA("BasePart") then
				warn("Door Outside is nil...")
				warn("currentRoom: ", objective.currentRoom, " goalRoom: ", objective.goalRoom, " reversePathToGoalRoom: ", objective.reversePathToGoalRoom)
				isForceFail = true
				return
			end

			self.navigation:PathToTarget(doorOutsideOfNextRoom.Position)
			table.remove(objective.reversePathToGoalRoom, #objective.reversePathToGoalRoom)
			return RUNNING

		elseif objective.currentRoom == objective.goalRoom then
			Blackboard.isObjectiveRoomReached = true
			return SUCCESS
		end
	end

	return Blackboard.isTargetReached ~= nil and RUNNING or FAIL
end


return btTask
