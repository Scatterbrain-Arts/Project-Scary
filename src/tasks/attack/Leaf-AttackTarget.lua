local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3
local STATUS_HOSTILE, STATUS_ALERT, STATUS_CALM = 3, 2, 1


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	Blackboard.isAttacking = false
	if self.mind.status == STATUS_HOSTILE and self.mind.objective.isPlayer then
		Blackboard.isAttacking = self.body:Attack()

		task.spawn(function()
			task.wait(self.config["body"].attackCooldown)
			Blackboard.isAttacking = false
		end)
	end
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	--print("AttackTarget-run")
	local Blackboard = obj.Blackboard
	local self = obj.self

	if not self.mind.objective.isPlayer then
		return FAIL
	end

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
