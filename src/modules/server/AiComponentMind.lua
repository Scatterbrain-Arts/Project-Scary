local RunService = game:GetService("RunService")

local require = require(script.Parent.loader).load(script)

local AiHelper = require("AiHelper")

local AiComponentMind = {}
AiComponentMind.__index = AiComponentMind

local PRIORITY_HIGH, PRIORITY_MED, PRIORITY_LOW = 3, 2, 1
local STATUS_HOSTILE, STATUS_ALERT, STATUS_CALM = 3, 2, 1

local function CreateObjective(priority, position, instance, isPlayer, decibel)
	return {
		priority = priority,
		position = position,
		object = instance,
		isPlayer = isPlayer or false,
		decibel = decibel or 0,
		isSearched = false,
		startTime = tick(),
	}
end


function AiComponentMind.new(entity, serviceBag)
    local self = {}
    setmetatable(self, AiComponentMind)

    self.entity = entity
    self.entity.config["mind"] = {
		soundSearchRange = AiHelper:GetValue(self.entity.character, "statSoundSearchRange", self.entity.config["entity"].isDebug) or 100,
		soundFoundRange = AiHelper:GetValue(self.entity.character, "statSoundFoundRange", self.entity.config["entity"].isDebug) or 50,
	}

    self.AIService = serviceBag:GetService(require("AiService"))

	self.hostileTime = 0
	self.memoryForgetTime = 3
	self.memory = {
		[PRIORITY_HIGH] = {},
		[PRIORITY_MED] = {},
		[PRIORITY_LOW] = {},
	}

	for _, point in workspace:FindFirstChild("PatrolPoints"):GetChildren() do
		self:AddObjective(CreateObjective(PRIORITY_LOW, point.Position, point))
	end

	self.objective = nil
	self.needAttention = false
	self.status = STATUS_CALM

	self.searchTimer = 5
	self.searchStartTime = nil
    self.AIService.moveAISignal:Connect(function(sound) self:SoundRecieved(sound) end)

	self.cycleLock = false
	self.cycleRefresh = 3
	self.cycleStartTime = tick()
	RunService.Heartbeat:Connect(function(deltaTime)
		if tick() - self.cycleStartTime >= self.cycleRefresh then
			self:UpdateMemory()
			self.cycleStartTime = tick()

			if self.status == STATUS_HOSTILE and tick() - self.hostileTime > 10 then
				self:UpdateStatus(STATUS_CALM, true)
			end
		end
	end)

	if self.entity.config["entity"].isDebug then
		self.entity.debug:CreateRangeSphere("soundSearchRange", self.entity.root, self.entity.config["mind"].soundSearchRange, Color3.fromRGB(0,255,0))
		self.entity.debug:CreateRangeSphere("soundFoundRange", self.entity.root, self.entity.config["mind"].soundFoundRange, Color3.fromRGB(71, 130, 133))
	end

	return self
end


function AiComponentMind:SoundRecieved(sound)
	local distance = (self.entity.root.Position - sound.position).Magnitude

	--distance = 1 / math.pow(distance,2)
	

	if sound.decibel < distance then
		--print("Sound Not Heard...", " Distance is ", distance, "...")
		return
	end
	
	local objective
	if distance <= self.entity.config["mind"].soundFoundRange then
		--print("High")
		objective = CreateObjective(PRIORITY_HIGH, sound.position, sound.object, sound.decibel)
	elseif distance <= self.entity.config["mind"].soundSearchRange then
		--print("med")
		objective = CreateObjective(PRIORITY_MED, sound.position, sound.object, sound.decibel)
	else
		warn("Unexpected Error: AiComponentMind-MoveAISignal...")
		return
	end
	--print("--------")
	self:AddObjective(objective)
end


function AiComponentMind:AddObjective(objective)
	table.insert(self.memory[objective.priority], objective)
	if objective.priority >= PRIORITY_MED then
		self.needAttention = true

		self:UpdateStatus(STATUS_ALERT)

		if objective.priority == PRIORITY_HIGH and self.status == STATUS_ALERT then
			self:UpdateStatus(STATUS_HOSTILE)
			self.hostileTime = tick()
		end
	end
end


function AiComponentMind:UpdateStatus(status, forceUpdate)
	forceUpdate = forceUpdate or false
	status = math.clamp(status, STATUS_CALM, STATUS_HOSTILE)

	if self.status < status or forceUpdate then
		self.status = status
	end
end


function AiComponentMind:UpdateMemory()
	if self.cycleLock then
		return
	end

	self.cycleLock = true

	-- High Priority Check
	for index, objective in self.memory[PRIORITY_HIGH] do
		if tick() - objective.startTime > self.memoryForgetTime then
			table.remove(self.memory[PRIORITY_HIGH], index)
		end
	end

	-- Med Priority Check
	for index, objective in self.memory[PRIORITY_MED] do
		if tick() - objective.startTime > self.memoryForgetTime then
			table.remove(self.memory[PRIORITY_MED], index)
		end
	end

	-- Low Priority Check
	local isSearchedCount = 0
	for _, objective in self.memory[PRIORITY_LOW] do
		if objective.isSearched then
			isSearchedCount += 1
		end
	end

	-- Low Priority Reset
	if isSearchedCount == #self.memory[PRIORITY_LOW] then
		for _, objective in self.memory[PRIORITY_LOW] do
			objective.isSearched = false
		end
	end

	self.cycleLock = false
end


function AiComponentMind:SearchStart()
	self.searchStartTime = tick()
	--print("Here", self.searchStartTime)
end


function AiComponentMind:SearchEnd()
	self.objective.isSearched = true
	self:UpdateMemory()

	self.searchStartTime = nil
end


local function GetRandomNotSearched(table)
	local rnd = 0
	repeat
		rnd = math.random(1, #table)
	until not table[rnd].isSearched

	return table[rnd]
end




function AiComponentMind:FindTarget()
	if self.needAttention then
		self.needAttention = false
	end

	if self.status == STATUS_HOSTILE then
		self.objective = CreateObjective(PRIORITY_HIGH, self.entity.playerRoot.Position, self.entity.playerCharacter.Head, true)
	elseif #self.memory[PRIORITY_HIGH] >= 1 then
		self.objective = table.remove(self.memory[PRIORITY_HIGH])
	elseif #self.memory[PRIORITY_MED] >= 1 then
		self.objective = table.remove(self.memory[PRIORITY_MED])
	elseif #self.memory[PRIORITY_LOW] >= 1 then
		self.objective = GetRandomNotSearched(self.memory[PRIORITY_LOW])
	else
		warn("Unexpected Error: AiComponentMind-FindTarget...")
		return false
	end

	if self.entity.config["entity"].isDebug then
		self.entity.debug:AddTargetIndicator(self.objective.position, self.objective.object, self.objective.isPlayer)
	end

	return true
end


return AiComponentMind