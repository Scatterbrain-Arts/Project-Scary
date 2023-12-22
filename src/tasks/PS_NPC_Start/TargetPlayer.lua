local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if Blackboard.player.Character and Blackboard.player.Character.PrimaryPart then
		Blackboard.target = Blackboard.player
		Blackboard.targetPosition = Blackboard.player.Character.PrimaryPart.Position
		Blackboard.isTargetLost = false
	else
		warn("Failed to target player...")
	end
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	return Blackboard.target == Blackboard.player and SUCCESS or FAIL
end


return btTask
