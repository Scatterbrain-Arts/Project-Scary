local Players = game:GetService("Players")

local task = {}		

local SUCCESS,FAIL,RUNNING = 1,2,3

-- Any arguments passed into Tree:run(obj) can be received after the first parameter, obj
-- Example: Tree:run(obj,deltaTime) - > task.start(obj, deltaTime), task.run(obj, deltaTime), task.finish(obj, status, deltaTime)

-- Blackboards
	-- objects attached to the tree have tables injected into them called Blackboards.
	-- these can be read from and written to by the tree using the Blackboard node, and can be accessed in tasks via object.Blackboard
--

function task.start(obj)
	--[[
		(optional) this function is called directly before the run method
  		is called. It allows you to setup things before starting to run
  		Beware: if task is resumed after calling running(), start is not called.
	--]]
	
	local Blackboard = obj.Blackboard
	
end
function task.finish(obj, status)
	--[[
		(optional) this function is called directly after the run method
		is completed with either success() or fail(). It allows you to clean up
		things, after you run the task.
	--]]
	
	local Blackboard = obj.Blackboard 
	
end	
function task.run(obj)
	--[[
		This is the meat of your task. The run method does everything you want it to do.
			
  	 	Finish it by returning one of the following:
	  		SUCCESS - The task did run successfully
	  		FAIL    - The task did fails
	  		RUNNING - The task is still running and will be called directly from parent node
	--]]

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

	if closestPlayer and closetDist <= 30 then
		print(closestPlayer.Name .. " is in range...")
		Blackboard.closestTarget = closestPlayer
		Blackboard.path = obj.MOB:FindPath(Blackboard.closestTarget.Character.PrimaryPart.Position)
		Blackboard.pathStartTime = tick()

		if not Blackboard.path then
			return FAIL
		end

		return SUCCESS
	end

	return FAIL
end
return task
