local Players = game:GetService("Players")

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
	local players = Players:GetPlayers()

	local closetDist = math.huge
	local closestPlayer = nil
	for _, player in players do
		local playerCharacter = player.Character
		if not playerCharacter then return end

		local dist = (obj.MOB.character.PrimaryPart.Position - playerCharacter.PrimaryPart.Position).Magnitude
		if dist < closetDist then
			closetDist = dist
			closestPlayer = player
		end
	end

	if closestPlayer and closetDist <= obj.MOB.stats.sightRange then
		Blackboard.closestTarget = closestPlayer
		Blackboard.path = obj.MOB:FindPath(Blackboard.closestTarget.Character.PrimaryPart.Position)

		if not Blackboard.path then
			return FAIL
		end

		return SUCCESS
	end

	return FAIL
end
return task
