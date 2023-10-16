local require = require(script.Parent.loader).load(script)

local AiComponentMind = {}
AiComponentMind.__index = AiComponentMind

local PRIORITY_HIGH, PRIORITY_MED, PRIORITY_LOW = 3, 2, 1

local PatrolPoints = {}
for _, point in workspace:FindFirstChild("PatrolPoints"):GetChildren() do
	table.insert(PatrolPoints, {
		priority = PRIORITY_LOW,
		position = point.Position,

		object = point,
		isSearched = false,
		isPlayer = false,
	})
end


function AiComponentMind.new(entity, serviceBag)
    local self = {}
    setmetatable(self, AiComponentMind)

    self.entity = entity
    self.entity.config["mind"] = {}

    self.AIService = serviceBag:GetService(require("AiService"))
    self.currentTarget = nil

    self.memoryQueue = {
		[PRIORITY_HIGH] = {},
		[PRIORITY_MED] = {},
		[PRIORITY_LOW] = {},
	}

	for _, point in PatrolPoints do
		point.index = #self.memoryQueue[point.priority] + 1
		table.insert(self.memoryQueue[point.priority], point)
	end


    self.AIService.moveAISignal:Connect(function(payload)
		payload.startTime = tick()
		payload.index = #self.memoryQueue[payload.priority] + 1
		table.insert(self.memoryQueue[payload.priority], payload)
	end)

	return self
end


local function GetRandomInMemoryQueue(queue)
	local rnd = 0
	repeat
		rnd = math.random(1, #queue)
	until not queue[rnd].isSearched

	return queue[rnd]
end

function AiComponentMind:UpdateMemoryQueue()
	for priority, prioritizedMemory in self.memoryQueue do
		local isSearchedCount = 0

		for index, targetData in prioritizedMemory do
			if priority == PRIORITY_LOW and targetData.isSearched then
				isSearchedCount += 1
			end

			if priority >= PRIORITY_MED then
				if self.currentTarget == targetData or tick() - targetData.startTime > 2 then
					self.memoryQueue[priority][index] = nil
				end
			end
		end

		if isSearchedCount == #self.memoryQueue[PRIORITY_LOW] then
			for _, targetData in self.memoryQueue[PRIORITY_LOW] do
				targetData.isSearched = false
			end
		end
	end
end

function AiComponentMind:ConcludeSearch()
	self.currentTarget.isSearched = true

	self:UpdateMemoryQueue()
end

function AiComponentMind:FindTarget()
	if #self.memoryQueue[PRIORITY_HIGH] >= 1 then
		self.currentTarget = self.memoryQueue[PRIORITY_HIGH][#self.memoryQueue[PRIORITY_HIGH]]
	elseif #self.memoryQueue[PRIORITY_MED] >= 1 then
		self.currentTarget = self.memoryQueue[PRIORITY_MED][#self.memoryQueue[PRIORITY_MED]]
	elseif #self.memoryQueue[PRIORITY_LOW] >= 1 then
		self.currentTarget = GetRandomInMemoryQueue(self.memoryQueue[PRIORITY_LOW])
	else
		warn("AiComponentBody:FindTarget: Unexpected fail...")
	end


	return self.currentTarget
end

return AiComponentMind