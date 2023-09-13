local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self


	local nearestTarget = Blackboard.nearestTarget
	if not Blackboard.isAttacking then
		Blackboard.isAttacking = self:Attack(nearestTarget)

		task.spawn(function()
			print("attack-animation-begin")
			task.wait(self.stats.attackCooldown)
			print("attack-animation-end")

			Blackboard.isAttacking = false
		end)
	end
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if Blackboard.isAttacking then
		return RUNNING
	elseif not Blackboard.isAttacking then
		return SUCCESS
	else
		warn("AttackTarget Task: Unexpected fail...")
		return FAIL
	end
end


return btTask
