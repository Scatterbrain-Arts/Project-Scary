local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3
local isForceFail = false

function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if not Blackboard.lastSoundHeardInstance then
		warn("Target or TargetPosition is nil...")
		isForceFail = true
		return
	end
	isForceFail = false

	if Blackboard.lastSoundHeardInstance == Blackboard.player.Character then
		print("Sound is from player")
		Blackboard.lastSoundHeardPosition = Blackboard.lastSoundHeardInstance.RightFoot.Position
	end

	isForceFail = self:LocateSound(Blackboard.lastSoundHeardPosition) and true or false
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

	return SUCCESS
end


return btTask
