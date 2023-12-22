local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3
local tickStartListen = nil
local isInitalize = false

function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	self.navigation:Stop()

	self.stateUI.Text = "???"
	task.wait(1)
	self.stateUI.Text = "<))🔊"
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if not isInitalize then
		Blackboard.isSoundHeard = false
		tickStartListen = tick()
		isInitalize = true
	end

	if Blackboard.isSoundHeard == true then
		self.stateUI.Text = "!!!"
		Blackboard.state = shared.npc.states.perception.alert
		self.soundDetection:UpdateState()
		Blackboard.isSoundHeard = false
		return SUCCESS
	end

	if tick() - tickStartListen > 3 and Blackboard.isSoundHeard == false then
		self.stateUI.Text = "..."
		return FAIL
	else
		return RUNNING
	end
end


return btTask
