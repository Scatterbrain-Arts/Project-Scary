local Players = game:GetService("Players")

local task = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

function task.start(obj)
	local Blackboard = obj.Blackboard

	obj.MOB:MoveToNextIndex()
	Blackboard.moving = true

	obj.MOB.maid:GiveTask(obj.MOB.humanoid.MoveToFinished:Once(function()
		Blackboard.moving = false

		obj.MOB.navigation.currentIndex = obj.MOB.navigation.nextIndex
		if obj.MOB.navigation.nextIndex < #obj.MOB.navigation.waypoints then
			obj.MOB.navigation.nextIndex += 1
		end

		obj.MOB.btRoot:Run(obj)
	end))
end


function task.finish(obj, status)
	local Blackboard = obj.Blackboard
end


function task.run(obj)
	local Blackboard = obj.Blackboard

	if not Blackboard.path then
		warn("No path for MoveToTarget Task...")
		return FAIL
	end

	if obj.MOB.navigation.currentIndex == #obj.MOB.navigation.waypoints then
		warn("Reached end of path for MoveToTarget Task...")
		return FAIL
	end

	if Blackboard.moving then
		return RUNNING
	else
		return SUCCESS
	end
end


return task
