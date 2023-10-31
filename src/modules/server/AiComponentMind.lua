local RunService = game:GetService("RunService")

local require = require(script.Parent.loader).load(script)

local AiComponentMind = {}
AiComponentMind.__index = AiComponentMind

local PRIORITY_HIGH, PRIORITY_MED, PRIORITY_LOW, PRIORITY_ZERO = 3, 2, 1, 0
local ALERT, CAUIOUS, CALM = 3, 2, 1

local function CreateObjective(priority, needsAttention, position, instance, isPlayer)
	return {
		priority = priority,
		positionKnown = position,
		object = instance,
		isSearched = false,
		isAttention = needsAttention or false,
		isPlayer = isPlayer or false,
		startTime = tick(),
	}
end


local PatrolPoints = {}
for _, point in workspace:FindFirstChild("PatrolPoints"):GetChildren() do
	table.insert(PatrolPoints, CreateObjective(PRIORITY_ZERO, false, point.Position, point, false))
end




function AiComponentMind.new(entity, serviceBag)
    local self = {}
    setmetatable(self, AiComponentMind)

    self.entity = entity
    self.entity.config["mind"] = {}

    self.AIService = serviceBag:GetService(require("AiService"))
    self.currentTarget = nil

	self.memoryForgetTime = 3
	self.memory = {
		[PRIORITY_HIGH] = {},
		[PRIORITY_MED] = {},
		[PRIORITY_LOW] = {},
	}
	self.objective = nil

	self.needAttention = false
	self.searchTimer = 5
	self.searchStartTime = nil
    self.AIService.moveAISignal:Connect(function(payload)
		local priority = ( (self.entity.root.Position - payload.positionKnown).Magnitude <= 50 ) and PRIORITY_HIGH or PRIORITY_MED
		self:AddObjective(CreateObjective(priority, true, payload.positionKnown, payload.object, false))
	end)

	self.cycleLock = false
	self.cycleRefresh = 3
	self.cycleStartTime = tick()
	RunService.Heartbeat:Connect(function(deltaTime)
		if tick() - self.cycleStartTime >= self.cycleRefresh then
			self:UpdateMemory()
			self.cycleStartTime = tick()
		end
	end)

	return self
end


function AiComponentMind:AddObjective(objective)
	table.insert(self.memory[objective.priority], objective)
	if objective.isAttention then
		warn("New Task needs attention...")
		self.needAttention = true
	end
end


function AiComponentMind:UpdateMemory()
	if self.cycleLock then
		return
	end

	self.cycleLock = true

	for priorityLevel, prioritizedMemory in self.memory do
		for index, objective in prioritizedMemory do

			if self.objective == objective or tick() - objective.startTime > self.memoryForgetTime then
				self.memory[priorityLevel][index] = nil
			end
		end
	end

	local isSearchedCount = 0
	for _, objective in PatrolPoints do
		if objective.isSearched then
			isSearchedCount += 1
		end
	end

	if isSearchedCount == #PatrolPoints then
		for _, objective in PatrolPoints do
			objective.isSearched = false
		end
	end

	self.cycleLock = false
end


function AiComponentMind:SearchStart()
	self.searchStartTime = tick()
	print("Here", self.searchStartTime)
end


function AiComponentMind:SearchEnd()
	self.objective.isSearched = true
	self:UpdateMemory()

	self.searchStartTime = nil
end


local function GetRandomPatrolNotSearched()
	local rnd = 0
	repeat
		rnd = math.random(1, #PatrolPoints)
	until not PatrolPoints[rnd].isSearched

	return PatrolPoints[rnd]
end


function AiComponentMind:FindTarget()
	if self.needAttention then
		warn("something needs attention")
		self.needAttention = false
	end


	if #self.memory[PRIORITY_HIGH] >= 1 then
		self.objective = self.memory[PRIORITY_HIGH][#self.memory[PRIORITY_HIGH]]

	elseif #self.memory[PRIORITY_MED] >= 1 then
		self.objective = self.memory[PRIORITY_MED][#self.memory[PRIORITY_MED]]

	elseif #self.memory[PRIORITY_LOW] >= 1 then
		self.objective = self.memory[PRIORITY_LOW][#self.memory[PRIORITY_LOW]]

	else
		self.objective = GetRandomPatrolNotSearched()
	end

	if self.objective and self.entity.config["entity"].isDebug then
		self.entity.debug:AddTargetIndicator(self.objective.positionKnown, self.objective.object)
	end

	--print("did i get it?  ->", self.objective.isAttention)

	return self.objective and true or false
end


return AiComponentMind