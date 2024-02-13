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

	-- check sound origin
	if Blackboard.lastSoundHeardInstance == Blackboard.player.Character then
		Blackboard.lastSoundHeardPosition = Blackboard.lastSoundHeardInstance.RightFoot.Position
	end

	local soundSourceInstance, soundWalkToInstance, room = self:FindSound(Blackboard.lastSoundHeardPosition)
	print(soundSourceInstance, soundWalkToInstance, room)
	if not soundSourceInstance or not soundWalkToInstance then
		warn("sound is nil...")
		isForceFail = true
		return
	end

	Blackboard.objective.interactObject = soundSourceInstance
	Blackboard.objective.walkToInstance = soundWalkToInstance.NavStart
	Blackboard.objective.goalRoom = room

	Blackboard.objective.interactObject.PrimaryPart.Transparency = 0
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self

	isForceFail = false
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
