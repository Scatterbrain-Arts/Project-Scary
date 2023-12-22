local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3
local tickStartListen = nil
local isInitialized = false

function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	--self.navigation:StartPause()

	self.stateUI.Text = ":o"
	task.wait(1)
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self

	--self.navigation:EndPause()
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if not isInitialized then
		Blackboard.isSoundHeard = false
		tickStartListen = tick()
		isInitialized = true
	end

	if Blackboard.isSoundHeard == true then
		self.stateUI.Text = "!!!"
		Blackboard.state = shared.npc.states.perception.alert
		self.soundDetection:UpdateState()
		Blackboard.isSoundHeard = false
		Blackboard.isTargetLost = false
		return SUCCESS
	end

	if tick() - tickStartListen > 3 and Blackboard.isSoundHeard == false then
		self.stateUI.Text = ":("
		return FAIL
	else
		return RUNNING
	end
end


return btTask
