local Packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local GeneralUtil = require(Packages.GeneralUtil)

local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if not Blackboard.target or not Blackboard.targetPosition then
		warn("Target or TargetPosition is nil...")
		isForceFail = true
		return
	end

	self.navigation:PathToTarget(Blackboard.targetPosition)
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if isForceFail or not Blackboard.target or not Blackboard.targetPosition then
		return FAIL
	end

	if Blackboard.target:IsA("Player") and Blackboard.target.Character and Blackboard.target.Character.PrimaryPart then
		if GeneralUtil:IsDistanceGreater(Blackboard.target.Character.PrimaryPart.Position, Blackboard.targetPosition, 5) then

			return FAIL
		end

	elseif Blackboard.target:IsA("Model") and Blackboard.target.PrimaryPart then
		if GeneralUtil:IsDistanceGreater(Blackboard.target.PrimaryPart.Position, Blackboard.targetPosition, 5) then
			return FAIL
		end

	elseif Blackboard.target:IsA("BasePart") then
		if GeneralUtil:IsDistanceGreater(Blackboard.target.Position, Blackboard.targetPosition, 5) then
			return FAIL
		end

	else
		warn("unexpcted type", typeof(Blackboard.target))
		return FAIL
	end

	return (Blackboard.isTargetReached == false and RUNNING) or (Blackboard.isTargetReached == true and SUCCESS) or FAIL
end


return btTask
