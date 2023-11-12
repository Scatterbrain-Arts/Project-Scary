local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local GeneralUtil = require(packages.GeneralUtil)

local PlayerEntitySignals = require(packages.PlayerEntity)
local ComponentSound = require(packages.PlayerComponentSound)
local Math = require(packages.Math)

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local ConfigFolder = GeneralUtil:Get(Character, "config", "Folder")

local ConfigStamina = GeneralUtil:Get(ConfigFolder, "stamina", "Configuration")
local ConfigSound = GeneralUtil:Get(ConfigFolder, "sound", "Configuration")

local IsDebugStamina = GeneralUtil:GetBool(ConfigStamina, "_DEBUG", true)

local CONFIG = {
	costRun = GeneralUtil:GetNumber(ConfigStamina, "cost run", IsDebugStamina.Value),
	costHoldBreath = GeneralUtil:GetNumber(ConfigStamina, "cost hold breath", IsDebugStamina.Value),
	regenAmount = GeneralUtil:GetNumber(ConfigStamina, "regen amount", IsDebugStamina.Value),
	regenDelay = GeneralUtil:GetNumber(ConfigStamina, "regen delay", IsDebugStamina.Value),
	staminaMax = GeneralUtil:GetNumber(ConfigStamina, "stamina max", IsDebugStamina.Value),
	staminaMin = GeneralUtil:GetNumber(ConfigStamina, "stamina min", IsDebugStamina.Value),

	rangeLow = GeneralUtil:GetVector(ConfigStamina, "range low", IsDebugStamina.Value),
	rangeMed = GeneralUtil:GetVector(ConfigStamina, "range med", IsDebugStamina.Value),
	rangeHigh = GeneralUtil:GetVector(ConfigStamina, "range high", IsDebugStamina.Value),

	modifierStaminaMin = GeneralUtil:GetNumber(ConfigSound, "modifier stamina min", IsDebugStamina.Value),
	modifierStaminaLow = GeneralUtil:GetNumber(ConfigSound, "modifier stamina low",  IsDebugStamina.Value),
	modifierStaminaMed = GeneralUtil:GetNumber(ConfigSound, "modifier stamina med", IsDebugStamina.Value),
	modifierStaminaHigh = GeneralUtil:GetNumber(ConfigSound, "modifier stamina high", IsDebugStamina.Value),
	modifierStaminaMax = GeneralUtil:GetNumber(ConfigSound, "modifier stamina max", IsDebugStamina.Value),
}

local StatusFolder = GeneralUtil:Get(Character, "status", "Folder")

local STATUS = {
	isInhale = GeneralUtil:GetBool(StatusFolder, "isInhale", IsDebugStamina.Value),
	isExhale = GeneralUtil:GetBool(StatusFolder, "isExhale", IsDebugStamina.Value),
	isInhaleToHoldBreath = GeneralUtil:GetBool(StatusFolder, "isExhale", IsDebugStamina.Value),

	isBreathing = GeneralUtil:GetBool(StatusFolder, "isBreathing", IsDebugStamina.Value),
	isIdle = GeneralUtil:GetBool(StatusFolder, "isIdle", IsDebugStamina.Value),
	isSneaking = GeneralUtil:GetBool(StatusFolder, "isSneaking", IsDebugStamina.Value),
	isRunning = GeneralUtil:GetBool(StatusFolder, "isRunning", IsDebugStamina.Value),
	requestHoldBreath = GeneralUtil:GetBool(StatusFolder, "request hold breath", IsDebugStamina.Value),
	requestRun = GeneralUtil:GetBool(StatusFolder, "request run", IsDebugStamina.Value),

	breathState = GeneralUtil:GetNumber(StatusFolder, "breath state", IsDebugStamina.Value),
	moveState = GeneralUtil:GetNumber(StatusFolder, "move state", IsDebugStamina.Value),
	stamina = GeneralUtil:GetNumber(StatusFolder, "stamina", IsDebugStamina.Value),
	staminaState = GeneralUtil:GetNumber(StatusFolder, "stamina state",IsDebugStamina.Value),
}


local STATE_STAMINA_MIN, STATE_STAMINA_LOW, STATE_STAMINA_MED, STATE_STAMINA_HIGH, STATE_STAMINA_MAX = 1, 2, 3, 4, 5
local STATES = { STATE_STAMINA_MIN, STATE_STAMINA_LOW, STATE_STAMINA_MED , STATE_STAMINA_HIGH, STATE_STAMINA_MAX }
local STATE_BREATH_INHALE, STATE_BREATH_INHALE_TO_HOLD_BREATH, STATE_BREATH_EXHALE = 1,2,3

local RANGES = {
	[STATE_STAMINA_MIN] = {
		min = CONFIG.staminaMin.Value,
		max = CONFIG.staminaMin.Value,
		MODIFIER = CONFIG.modifierStaminaMin.Value,
	},
	[STATE_STAMINA_LOW] = {
		min = CONFIG.rangeLow.Value.X,
		max = CONFIG.rangeLow.Value.Y,
		MODIFIER = CONFIG.modifierStaminaLow.Value,
	},
	[STATE_STAMINA_MED] = {
		min = CONFIG.rangeMed.Value.X,
		max = CONFIG.rangeMed.Value.Y,
		MODIFIER = CONFIG.modifierStaminaMed.Value,
	},
	[STATE_STAMINA_HIGH] = {
		min = CONFIG.rangeHigh.Value.X,
		max = CONFIG.rangeHigh.Value.Y,
		MODIFIER = CONFIG.modifierStaminaHigh.Value,
	},
	[STATE_STAMINA_MAX] = {
		min = CONFIG.staminaMax.Value,
		max = CONFIG.staminaMax.Value,
		MODIFIER = CONFIG.modifierStaminaMax.Value,
	},
}

local StaminaGUi = LocalPlayer.PlayerGui:FindFirstChild("stamina")
local StaminaText = StaminaGUi.Frame.TextLabel

STATUS.staminaState.Value = STATE_STAMINA_MIN
STATUS.stamina.Value = CONFIG.staminaMin.Value
StaminaText.Text = STATUS.stamina.Value


local TickLastBreath = tick()
local BreathLength = 1.8
local StaminaAdd = 0
local StaminaRemove = 0
local StaminaBonus = 5
local OverrideHoldBreath = 0


local function Inhale()
	StaminaAdd += CONFIG.regenAmount.Value
	STATUS.breathState.Value = STATE_BREATH_INHALE
end

local function Exhale()
	StaminaRemove -= CONFIG.regenAmount.Value / 2
	STATUS.breathState.Value = STATE_BREATH_EXHALE
end


local function InhaleToHoldBreath()
	StaminaAdd += CONFIG.regenAmount.Value
	STATUS.breathState.Value = STATE_BREATH_INHALE_TO_HOLD_BREATH

	STATUS.isBreathing.Value = false
end


local function CheckStaminaState(isIncrease)
	if isIncrease then
		for i = STATUS.staminaState.Value, STATE_STAMINA_MAX, 1 do
			if STATUS.stamina.Value >= RANGES[i].min and STATUS.stamina.Value <= RANGES[i].max then
				STATUS.staminaState.Value = STATES[i]
				ComponentSound:UpdateStamina(RANGES[STATUS.staminaState.Value].MODIFIER, STATUS.staminaState.Value, STATUS.stamina.Value)
				break
			end
		end
	else
		for i = STATUS.staminaState.Value, STATE_STAMINA_MIN, -1 do
			if STATUS.stamina.Value >= RANGES[i].min and STATUS.stamina.Value <= RANGES[i].max then
				STATUS.staminaState.Value = STATES[i]
				ComponentSound:UpdateStamina(RANGES[STATUS.staminaState.Value].MODIFIER, STATUS.staminaState.Value, STATUS.stamina.Value)
				break
			end
		end
	end
end


local function Breathe()
	STATUS.isInhale.Value = STATUS.isExhale.Value
	STATUS.isExhale.Value = not STATUS.isInhale.Value

	local staminaTotal = StaminaAdd - StaminaRemove + StaminaBonus
	STATUS.stamina.Value = math.clamp(STATUS.stamina.Value+staminaTotal, CONFIG.staminaMin.Value, CONFIG.staminaMax.Value)
	StaminaText.Text = STATUS.stamina.Value

	--print("Breathe Total:", staminaTotal)
	CheckStaminaState(staminaTotal >= 0)

	StaminaAdd, StaminaRemove = 0, 0
	TickLastBreath = tick()
end



local function BeginHoldBreath(deltaTime)
	if (STATUS.stamina.Value - CONFIG.costHoldBreath.Value * deltaTime)  >= CONFIG.staminaMin.Value then
		OverrideHoldBreath = BreathLength

		STATUS.isInhale.Value = true
		STATUS.isExhale.Value = false
	end
end

local function EndHoldBreath()
	STATUS.isBreathing.Value = true
	STATUS.isInhale.Value = false
	STATUS.isExhale.Value = true

	OverrideHoldBreath = 0
end


local function BeginRun(deltaTime)
	if (STATUS.stamina.Value - CONFIG.costRun.Value * deltaTime)  >= CONFIG.staminaMin.Value then
		STATUS.isRunning.Value = true
	else
		STATUS.isRunning.Value = false
	end
end

local function EndRun()
	STATUS.isRunning.Value = false
end



math.randomseed(tick())
local function Update(deltaTime)

	BreathLength = Math.lerp(0.4,1.8,  STATUS.stamina.Value/100)

	if STATUS.requestHoldBreath.Value and STATUS.isBreathing.Value then
		BeginHoldBreath(deltaTime)
	end

	if not STATUS.isBreathing.Value then
		if not STATUS.requestHoldBreath.Value then
			EndHoldBreath()
		end
	end

	if STATUS.requestRun.Value then
		BeginRun(deltaTime)
	else
		EndRun()
	end

	--print(BreathLength)

	if STATUS.isBreathing.Value and tick() - TickLastBreath >= BreathLength-OverrideHoldBreath+math.random(0, 1) then
		if STATUS.requestHoldBreath.Value then
			InhaleToHoldBreath()	
		elseif STATUS.isInhale.Value then
			Inhale()
		elseif STATUS.isExhale.Value  then
			Exhale()
		end

		

		Breathe()
	end

	if STATUS.isRunning.Value or not STATUS.isBreathing.Value then

		local staminaTotal  = ( CONFIG.costRun.Value ) + ( CONFIG.costHoldBreath.Value )
		STATUS.stamina.Value = math.clamp(STATUS.stamina.Value-(staminaTotal*deltaTime), CONFIG.staminaMin.Value, CONFIG.staminaMax.Value)
		StaminaText.Text = STATUS.stamina.Value

		--print("Cost Total:", staminaTotal)
		CheckStaminaState(staminaTotal >= 0)
	end
end





RunService.Heartbeat:Connect(Update)