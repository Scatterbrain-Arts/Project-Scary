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

	obj.MOB:MoveToNextIndex()
	Blackboard.moving = true
	obj.MOB.humanoid.MoveToFinished:Connect(function()
		Blackboard.moving = false

		obj.MOB.navigation.currentIndex = obj.MOB.navigation.nextIndex
			if obj.MOB.navigation.nextIndex < #obj.MOB.navigation.waypoints then
				obj.MOB.navigation.nextIndex += 1
				--obj.MOB.navigation.running = true
				--obj.MOB:MoveToNextIndex()
			--else
				--obj.MOB.navigation.running = false
				--obj.MOB.navigation.connections.reached:Disconnect()
			end

		obj.MOB.btRoot:Run(obj)
	end)

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

	if not Blackboard.path or obj.MOB.navigation.currentIndex == #obj.MOB.navigation.waypoints then
		return FAIL
	end

	
	--Blackboard.startTime = tick()

	if Blackboard.moving then
		return RUNNING
	else
		return SUCCESS
	end

	--print(Blackboard.startTime)
	-- if Blackboard.startTime - tick() >= 3 then
	-- 	return SUCCESS
	-- end
	
	
end
return task
