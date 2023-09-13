local task = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

function task.start(obj)
	local Blackboard = obj.Blackboard
end


function task.finish(obj, status)
	local Blackboard = obj.Blackboard
end


function task.run(obj)

	local Blackboard = obj.Blackboard
	local targetCharacter = Blackboard.closestTarget.Character
	if not targetCharacter then
		return FAIL
	end

	local dist = (obj.MOB.character.PrimaryPart.Position - targetCharacter.PrimaryPart.Position).Magnitude

	if dist < obj.MOB.stats.attackRange then
		Blackboard.isNear = true
		return SUCCESS
	else
		Blackboard.isNear = false
		return FAIL
	end

end
return task
