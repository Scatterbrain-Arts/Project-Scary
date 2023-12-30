local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3
local isUpdate = true


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if Blackboard.target then
		if Blackboard.target:IsA("Player") and Blackboard.target.Character and Blackboard.target.Character.PrimaryPart then
			Blackboard.targetPosition = Blackboard.target.Character.PrimaryPart.Position
		elseif Blackboard.target:IsA("Model") and Blackboard.target.PrimaryPart then
			Blackboard.targetPosition = Blackboard.target.PrimaryPart.Position
		elseif Blackboard.target:IsA("BasePart") then
			Blackboard.targetPosition = Blackboard.target.Position
		else
			warn("unexpcted type", typeof(Blackboard.target))
			Blackboard.targetPosition = Blackboard.target.Position
		end
	else
		warn("target is nil, targeting player")
		if Blackboard.player.Character and Blackboard.player.Character.PrimaryPart then
			Blackboard.target = Blackboard.player
			Blackboard.targetPosition = Blackboard.player.Character.PrimaryPart.Position
		else
			warn("failed to target player...")
			isUpdate = false
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

	return (Blackboard.target and isUpdate) and SUCCESS or FAIL
end


return btTask
